import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient, createServiceClient } from "@/lib/supabase/server";
import { sendApprovalEmail, sendRejectionEmail, sendWaitlistEmail } from "@/lib/resend";

const schema = z.object({
  action: z.enum(["approve", "reject", "waitlist"]),
  admin_note: z.string().max(1000).optional(),
});

export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { data: profile } = await supabase
    .from("user_profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  if (profile?.role !== "admin") {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  const body = await request.json();
  const result = schema.safeParse(body);
  if (!result.success) {
    return NextResponse.json({ error: result.error.flatten() }, { status: 422 });
  }

  const { action, admin_note } = result.data;
  const serviceClient = await createServiceClient();

  const { data: application, error: fetchError } = await serviceClient
    .from("applications")
    .select("id, applicant_name, applicant_email, cohort_id")
    .eq("id", id)
    .single();

  if (fetchError || !application) {
    return NextResponse.json({ error: "Application not found" }, { status: 404 });
  }

  const statusMap = { approve: "approved", reject: "rejected", waitlist: "waitlisted" } as const;
  const newStatus = statusMap[action];

  await serviceClient
    .from("applications")
    .update({
      status: newStatus,
      reviewed_by: user.id,
      reviewed_at: new Date().toISOString(),
    })
    .eq("id", id);

  const { data: cohort } = application.cohort_id
    ? await serviceClient.from("cohorts").select("name").eq("id", application.cohort_id).single()
    : { data: null };

  const cohortName = cohort?.name ?? "your cohort";
  const applicantEmail = application.applicant_email;
  const applicantName = application.applicant_name;

  if (action === "approve") {
    await sendApprovalEmail({
      to: applicantEmail,
      name: applicantName,
      cohortName,
      stripePaymentLink: `${process.env.NEXT_PUBLIC_APP_URL}/auth/login`,
    });
  } else if (action === "reject") {
    await sendRejectionEmail({
      to: applicantEmail,
      name: applicantName,
      cohortName,
      adminNote: admin_note,
    });
  } else if (action === "waitlist") {
    await sendWaitlistEmail({
      to: applicantEmail,
      name: applicantName,
      cohortName,
    });
  }

  return NextResponse.json({ status: newStatus });
}

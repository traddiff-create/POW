import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createServiceClient } from "@/lib/supabase/server";
import {
  hasPublicSupabaseConfig,
  hasServiceSupabaseConfig,
} from "@/lib/supabase/config";
import { sendApplicationReceived, sendApplicantConfirmation } from "@/lib/resend";

const schema = z.object({
  name: z.string().min(1).max(255),
  email: z.string().email(),
  cohort_id: z.string().uuid(),
  motivation: z.string().min(100).max(5000),
  how_heard: z.string().max(500).optional(),
});

export async function POST(request: NextRequest) {
  if (!hasPublicSupabaseConfig() || !hasServiceSupabaseConfig()) {
    return NextResponse.json(
      { error: "Applications are temporarily unavailable" },
      { status: 503 }
    );
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "Invalid JSON body" }, { status: 400 });
  }

  const result = schema.safeParse(body);

  if (!result.success) {
    return NextResponse.json({ error: result.error.flatten() }, { status: 422 });
  }

  const { name, email, cohort_id, motivation, how_heard } = result.data;

  const supabase = await createServiceClient();

  const { data: cohort, error: cohortError } = await supabase
    .from("cohorts")
    .select("id, name, is_open")
    .eq("id", cohort_id)
    .single();

  if (cohortError || !cohort || !cohort.is_open) {
    return NextResponse.json({ error: "Cohort not available" }, { status: 400 });
  }

  const { data: application, error: insertError } = await supabase
    .from("applications")
    .insert({
      applicant_name: name,
      applicant_email: email,
      cohort_id,
      motivation,
      how_heard,
    })
    .select("id")
    .single();

  if (insertError || !application) {
    console.error("Application insert failed:", {
      code: insertError?.code,
      message: insertError?.message,
    });
    return NextResponse.json({ error: "Failed to save application" }, { status: 500 });
  }

  const adminEmail = process.env.ADMIN_EMAIL ?? process.env.RESEND_FROM_EMAIL ?? "";
  if (adminEmail) {
    await sendApplicationReceived({
      adminEmail,
      applicantName: name,
      applicantEmail: email,
      cohortName: cohort.name,
      motivationExcerpt: motivation.slice(0, 200) + (motivation.length > 200 ? "…" : ""),
      applicationId: application.id,
    });
  }

  await sendApplicantConfirmation({ to: email, name });

  return NextResponse.json({ id: application.id }, { status: 201 });
}

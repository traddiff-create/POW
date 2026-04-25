import { NextRequest, NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";
import { createServiceClient } from "@/lib/supabase/server";
import { sendPaymentConfirmation, sendSignInLink } from "@/lib/resend";

export async function POST(request: NextRequest) {
  const body = await request.text();
  const signature = request.headers.get("stripe-signature");

  if (!signature) {
    return NextResponse.json({ error: "Missing signature" }, { status: 400 });
  }

  let event;
  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch {
    return NextResponse.json({ error: "Invalid signature" }, { status: 400 });
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object;
    const applicationId = session.metadata?.application_id;

    if (!applicationId) {
      return NextResponse.json({ error: "Missing application_id in metadata" }, { status: 400 });
    }

    const supabase = await createServiceClient();

    const { data: application, error: appError } = await supabase
      .from("applications")
      .select("id, applicant_name, applicant_email, cohort_id")
      .eq("id", applicationId)
      .single();

    if (appError || !application) {
      return NextResponse.json({ error: "Application not found" }, { status: 400 });
    }

    const applicantEmail = application.applicant_email;
    const applicantName = application.applicant_name;

    await supabase
      .from("payments")
      .update({ status: "succeeded", stripe_payment_intent_id: session.payment_intent as string })
      .eq("stripe_session_id", session.id);

    // Look up or create an auth user for this applicant.
    // user_profiles doesn't store email — use auth.admin.listUsers to find by email.
    const { data: { users } } = await supabase.auth.admin.listUsers();
    const existingAuthUser = users.find((u) => u.email === applicantEmail);

    let userId: string;

    if (!existingAuthUser) {
      const { data: authData, error: authError } = await supabase.auth.admin.createUser({
        email: applicantEmail,
        email_confirm: true,
        user_metadata: { display_name: applicantName },
      });

      if (authError || !authData.user) {
        console.error("User creation failed:", authError);
        return NextResponse.json({ error: "User creation failed" }, { status: 500 });
      }

      userId = authData.user.id;
      // handle_new_user() trigger auto-creates the user_profile row
    } else {
      userId = existingAuthUser.id;
    }

    const { data: payment } = await supabase
      .from("payments")
      .select("id")
      .eq("stripe_session_id", session.id)
      .single();

    await supabase.from("enrollments").insert({
      user_id: userId,
      cohort_id: application.cohort_id!,
      payment_id: payment?.id ?? null,
    });

    const { data: cohortRow } = application.cohort_id
      ? await supabase.from("cohorts").select("name").eq("id", application.cohort_id).single()
      : { data: null };
    const cohortName = cohortRow?.name ?? "your cohort";
    await sendPaymentConfirmation({
      to: applicantEmail,
      name: applicantName,
      cohortName,
    });

    const { data: linkData } = await supabase.auth.admin.generateLink({
      type: "magiclink",
      email: applicantEmail,
      options: { redirectTo: `${process.env.NEXT_PUBLIC_APP_URL}/home` },
    });
    if (linkData?.properties?.action_link) {
      await sendSignInLink({
        to: applicantEmail,
        name: applicantName,
        link: linkData.properties.action_link,
      });
    }
  }

  if (event.type === "checkout.session.async_payment_failed") {
    const session = event.data.object;
    await (await createServiceClient())
      .from("payments")
      .update({ status: "failed" })
      .eq("stripe_session_id", session.id);
  }

  return NextResponse.json({ received: true });
}

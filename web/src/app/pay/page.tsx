import { redirect } from "next/navigation";
import { createServiceClient } from "@/lib/supabase/server";
import { getStripe } from "@/lib/stripe";
import { Footer } from "@/components/Footer";

export default async function PayPage({
  searchParams,
}: {
  searchParams: Promise<{ a?: string }>;
}) {
  const { a: applicationId } = await searchParams;

  if (!applicationId) {
    return <InvalidLink />;
  }

  const supabase = await createServiceClient();

  const { data: application } = await supabase
    .from("applications")
    .select("id, applicant_name, applicant_email, cohort_id, status")
    .eq("id", applicationId)
    .single();

  if (!application || application.status !== "approved") {
    return <InvalidLink />;
  }

  const { data: cohort } = application.cohort_id
    ? await supabase
        .from("cohorts")
        .select("name, price_cents")
        .eq("id", application.cohort_id)
        .single()
    : { data: null };

  if (!cohort) {
    return <InvalidLink />;
  }

  const session = await getStripe().checkout.sessions.create({
    mode: "payment",
    customer_email: application.applicant_email,
    line_items: [
      {
        price_data: {
          currency: "usd",
          product_data: { name: cohort.name },
          unit_amount: cohort.price_cents,
        },
        quantity: 1,
      },
    ],
    metadata: { application_id: applicationId },
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/pay/success`,
    cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pay/cancel`,
  });

  redirect(session.url!);
}

function InvalidLink() {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 flex items-center justify-center px-6">
        <div className="text-center max-w-sm">
          <h1 className="text-2xl mb-4">
            This link is no longer valid.
          </h1>
          <p className="text-foreground/60 text-sm">
            Your application may not be approved yet, or this link has expired.
            Check your email for the most recent message from us.
          </p>
        </div>
      </main>
      <Footer />
    </div>
  );
}

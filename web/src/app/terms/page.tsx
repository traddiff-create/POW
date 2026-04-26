import { Footer } from "@/components/Footer";

export default function TermsPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16 max-w-2xl mx-auto">
        <h1 className="text-3xl mb-6">Terms of Service</h1>
        <div className="space-y-5 text-foreground/70 leading-relaxed">
          <p>Effective date: April 25, 2026</p>
          <p>
            A Piece of Whole is an 8-week educational and community support program for adults.
            By creating an account or participating in a cohort, you confirm that you are at least
            18 years old and that the information you provide is accurate.
          </p>
          <p>
            This service is not therapy, medical care, legal advice, or crisis intervention. It does not
            diagnose, treat, or prevent any condition and does not create a therapist-client,
            clinician-patient, attorney-client, or emergency-services relationship. If you are in danger
            or crisis, call emergency services or 988 in the United States.
          </p>
          <p>
            You are responsible for what you share. Keep other participants&apos; stories private, do not post
            harassing or harmful content, and do not use the service to solicit, threaten, impersonate, or
            mislead others. We may moderate content, restrict access, or remove participants when needed
            to protect the community or comply with law.
          </p>
          <p>
            Cohort access may require an in-app purchase. Apple handles purchase processing. Refund
            requests are handled under Apple&apos;s App Store policies unless a separate written agreement
            applies.
          </p>
          <p>
            Questions can be sent to hello@apieceofwhole.com.
          </p>
        </div>
      </main>
      <Footer />
    </div>
  );
}

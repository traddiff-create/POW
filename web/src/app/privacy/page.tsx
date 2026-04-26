import { Footer } from "@/components/Footer";

export default function PrivacyPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16 max-w-2xl mx-auto">
        <h1 className="text-3xl mb-6">Privacy Policy</h1>
        <div className="space-y-5 text-foreground/70 leading-relaxed">
          <p>Effective date: April 25, 2026</p>
          <p>
            A Piece of Whole collects the information needed to operate the app and cohort program:
            account identifiers, display name, application responses, cohort enrollment records,
            purchase entitlement records, check-ins, journal entries, circle posts, comments, reports,
            notifications, and account deletion requests.
          </p>
          <p>
            Private check-ins and journal entries are intended to be visible only to you. Circle posts
            and comments are visible to members and facilitators of your cohort according to the app&apos;s
            sharing controls. Reports may be reviewed by facilitators or administrators for moderation
            and safety.
          </p>
          <p>
            We use service providers such as Supabase for authentication, database, storage, and edge
            functions, and Apple for App Store purchases. We do not sell personal data and we do not use
            personal data for cross-app tracking.
          </p>
          <p>
            You can request account deletion in the iOS app under Settings. We process deletion requests
            within 30 days unless limited retention is legally required. Privacy questions can be sent to
            hello@apieceofwhole.com.
          </p>
        </div>
      </main>
      <Footer />
    </div>
  );
}

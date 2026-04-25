import { Footer } from "@/components/Footer";

export default function TermsPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16 max-w-2xl mx-auto">
        <p className="text-sm text-error mb-8 border border-error px-4 py-3">
          DRAFT — FOR ATTORNEY REVIEW BEFORE LAUNCH
        </p>
        <h1 className="text-3xl mb-6">Terms of Service</h1>
        <p className="text-foreground/70">
          Terms of Service content will be added here prior to launch. This page is a placeholder pending attorney review.
        </p>
      </main>
      <Footer />
    </div>
  );
}

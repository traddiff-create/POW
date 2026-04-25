import { Footer } from "@/components/Footer";

export default function PrivacyPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16 max-w-2xl mx-auto">
        <p className="text-sm text-[#C0392B] mb-8 border border-[#C0392B] px-4 py-3">
          DRAFT — FOR ATTORNEY REVIEW BEFORE LAUNCH
        </p>
        <h1 className="text-3xl mb-6" style={{ fontFamily: "Georgia, serif" }}>Privacy Policy</h1>
        <p className="text-[#2C2A28]/70">
          Privacy Policy content will be added here prior to launch. This page is a placeholder pending attorney review.
        </p>
      </main>
      <Footer />
    </div>
  );
}

import Link from "next/link";
import { Footer } from "@/components/Footer";

export default function PaySuccessPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 flex items-center justify-center px-6">
        <div className="text-center max-w-md">
          <h1 className="text-3xl mb-4">
            You&apos;re in.
          </h1>
          <p className="text-foreground/70 mb-6 leading-relaxed">
            Your payment is confirmed and your spot is secured. Check your email — we&apos;ve
            sent you a sign-in link to access your cohort.
          </p>
          <p className="text-sm text-foreground/50">
            Didn&apos;t get the email?{" "}
            <Link href="/auth/login" className="underline">
              Request a new sign-in link →
            </Link>
          </p>
        </div>
      </main>
      <Footer />
    </div>
  );
}

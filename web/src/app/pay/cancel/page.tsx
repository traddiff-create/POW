import Link from "next/link";
import { Footer } from "@/components/Footer";

export default function PayCancelPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 flex items-center justify-center px-6">
        <div className="text-center max-w-md">
          <h1 className="text-2xl mb-4" style={{ fontFamily: "Georgia, serif" }}>
            Payment cancelled.
          </h1>
          <p className="text-[#2C2A28]/70 mb-6">
            No charge was made. Your spot is still being held — you can use your
            original email link to try again.
          </p>
          <p className="text-sm text-[#2C2A28]/50">
            Questions?{" "}
            <Link href="mailto:hello@apieceofwhole.com" className="underline">
              Reply to your approval email
            </Link>{" "}
            and we&apos;ll help.
          </p>
        </div>
      </main>
      <Footer />
    </div>
  );
}

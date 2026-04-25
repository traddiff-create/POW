import Link from "next/link";
import { CrisisBanner } from "./CrisisBanner";

export function Footer() {
  return (
    <footer className="mt-auto">
      <CrisisBanner />
      <div className="border-t border-[#2C2A28]/10 py-8 px-4">
        <div className="max-w-4xl mx-auto flex flex-wrap gap-x-6 gap-y-2 justify-center text-sm text-[#2C2A28]/60">
          <Link href="/about">About</Link>
          <Link href="/faq">FAQ</Link>
          <Link href="/contact">Contact</Link>
          <Link href="/terms">Terms</Link>
          <Link href="/privacy">Privacy</Link>
          <Link href="/disclaimer">Disclaimer</Link>
          <Link href="/crisis">Crisis Resources</Link>
        </div>
        <p className="text-center text-xs text-[#2C2A28]/40 mt-4">
          A Piece of Whole is not therapy and not a substitute for professional mental health treatment.
        </p>
      </div>
    </footer>
  );
}

import Link from "next/link";

export function CrisisBanner() {
  return (
    <div className="bg-[#F9F7F4] border-t border-[#C4A882]/30 py-3 px-4 text-center text-sm text-[#2C2A28]/70">
      If you&apos;re in crisis, please reach out.{" "}
      <Link href="/crisis" className="underline text-[#2C2A28]">
        Crisis Resources →
      </Link>
    </div>
  );
}

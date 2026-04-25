import Link from "next/link";

export function CrisisBanner() {
  return (
    <div className="bg-background border-t border-stone/30 py-3 px-4 text-center text-sm text-foreground/70">
      If you&apos;re in crisis, please reach out.{" "}
      <Link href="/crisis" className="underline text-foreground">
        Crisis Resources →
      </Link>
    </div>
  );
}

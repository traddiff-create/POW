import { LoginForm } from "./LoginForm";
import { Footer } from "@/components/Footer";

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ next?: string; error?: string }>;
}) {
  const { next, error } = await searchParams;

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 flex items-center justify-center px-6 py-16">
        <div className="w-full max-w-sm">
          <h1 className="text-2xl mb-2 text-center">
            Sign in
          </h1>
          <p className="text-foreground/60 text-sm text-center mb-8">
            We&apos;ll email you a sign-in link — no password needed.
          </p>
          {error === "expired" && (
            <p className="text-error text-sm text-center mb-6">
              That link has expired. Request a new one below.
            </p>
          )}
          <LoginForm next={next} />
        </div>
      </main>
      <Footer />
    </div>
  );
}

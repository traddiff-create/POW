"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";

export function LoginForm({ next }: { next?: string }) {
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: `${window.location.origin}/auth/callback?next=${next ?? "/home"}`,
      },
    });
    if (error) {
      setError("Something went wrong. Please try again.");
    } else {
      setSent(true);
    }
    setLoading(false);
  }

  if (sent) {
    return (
      <div className="text-center">
        <p className="text-foreground/80 mb-2">Check your email.</p>
        <p className="text-sm text-foreground/60">
          We sent a link to <strong>{email}</strong>. It expires in 1 hour.
        </p>
        <button
          onClick={() => setSent(false)}
          className="text-sm text-sage underline mt-4"
        >
          Resend link
        </button>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-1" htmlFor="email">Email address</label>
        <input
          id="email"
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full border border-foreground/20 px-4 py-3 bg-white focus:outline-none focus:border-sage"
          placeholder="you@example.com"
        />
      </div>
      {error && <p className="text-error text-sm">{error}</p>}
      <button
        type="submit"
        disabled={loading}
        className="w-full bg-sage text-white py-3 text-sm hover:opacity-90 transition-opacity disabled:opacity-50"
      >
        {loading ? "Sending…" : "Send magic link"}
      </button>
    </form>
  );
}

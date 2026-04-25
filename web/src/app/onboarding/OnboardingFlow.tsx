"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const STEPS = [
  {
    id: "welcome",
    title: "Welcome to the circle.",
    body: "A Piece of Whole is a space for co-regulation, reflection, and civic engagement — not therapy. You're here to practice being human alongside others who are doing the same.",
  },
  {
    id: "values",
    title: "How we hold each other.",
    body: "This circle runs on a few principles: confidentiality (what's shared here stays here), presence over performance, and curiosity over judgment. You don't need to have it figured out.",
  },
  {
    id: "circle",
    title: "Your cohort circle.",
    body: "You'll move through 8 weeks alongside a small group. Each week has a theme, a practice, and a circle prompt. When you're ready, you can share a reflection — it becomes visible to your circle and your facilitator.",
  },
  {
    id: "privacy",
    title: "Your privacy.",
    body: "Your journal entries and check-ins are private — only you can see them. When you share something to the circle, you choose to make it visible. You can always share anonymously. You can delete your account at any time.",
  },
  {
    id: "ready",
    title: "You're ready.",
    body: "That's all. Take a breath. Your circle is waiting. You can always revisit these principles in Settings.",
  },
];

export function OnboardingFlow() {
  const [step, setStep] = useState(0);
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const current = STEPS[step];
  const isLast = step === STEPS.length - 1;

  async function advance() {
    if (!isLast) {
      setStep((s) => s + 1);
      return;
    }
    setLoading(true);
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (user) {
      await supabase
        .from("user_profiles")
        .update({ onboarding_completed_at: new Date().toISOString() })
        .eq("id", user.id);
    }
    router.push("/home");
  }

  return (
    <div className="flex flex-col min-h-screen items-center justify-center px-6 py-16">
      <div className="w-full max-w-sm">
        <div className="flex gap-1.5 mb-10">
          {STEPS.map((_, i) => (
            <div
              key={i}
              className="h-0.5 flex-1 transition-colors duration-300"
              style={{ backgroundColor: i <= step ? "#7A9E7E" : "#2C2A28" + "1A" }}
            />
          ))}
        </div>

        <h1
          className="text-2xl mb-4 leading-snug"
          style={{ fontFamily: "Georgia, serif" }}
        >
          {current.title}
        </h1>
        <p className="text-[#2C2A28]/70 text-base leading-relaxed mb-10">
          {current.body}
        </p>

        <button
          onClick={advance}
          disabled={loading}
          className="w-full bg-[#2C2A28] text-[#F9F7F4] py-3 text-sm hover:opacity-80 transition-opacity disabled:opacity-50"
        >
          {loading ? "One moment…" : isLast ? "Enter the circle →" : "Continue →"}
        </button>

        {step > 0 && (
          <button
            onClick={() => setStep((s) => s - 1)}
            className="w-full text-center text-sm text-[#2C2A28]/40 mt-4 hover:text-[#2C2A28]/70 transition-colors"
          >
            ← Back
          </button>
        )}
      </div>
    </div>
  );
}

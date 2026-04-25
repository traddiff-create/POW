"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

interface Props {
  cohortId: string;
  weekNumber: number;
  circlePrompt: string | null;
}

export function ShareForm({ cohortId, weekNumber, circlePrompt }: Props) {
  const [content, setContent] = useState("");
  const [isAnonymous, setIsAnonymous] = useState(false);
  const [loading, setLoading] = useState(false);
  const [done, setDone] = useState(false);
  const router = useRouter();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!content.trim() || content.trim().length < 20) return;
    setLoading(true);
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (user) {
      await supabase.from("circle_shares").insert({
        user_id: user.id,
        cohort_id: cohortId,
        week_number: weekNumber,
        content: content.trim(),
        is_anonymous: isAnonymous,
      });
    }
    setDone(true);
    setLoading(false);
  }

  if (done) {
    return (
      <div className="text-center py-12">
        <p className="text-2xl mb-3" style={{ fontFamily: "Georgia, serif" }}>
          Your reflection is in the circle.
        </p>
        <p className="text-[#2C2A28]/60 text-sm mb-8">
          {isAnonymous ? "Shared anonymously." : "Shared with your circle."}
        </p>
        <button
          onClick={() => router.push("/circle")}
          className="text-sm text-[#7A9E7E] underline"
        >
          View circle →
        </button>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {circlePrompt && (
        <blockquote className="border-l-2 border-[#C4A882] pl-4 text-[#2C2A28]/70 italic text-sm">
          {circlePrompt}
        </blockquote>
      )}

      <div>
        <label className="block text-sm font-medium mb-2" htmlFor="content">
          Your reflection
        </label>
        <textarea
          id="content"
          required
          rows={7}
          minLength={20}
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="What wants to be said?"
          className="w-full border border-[#2C2A28]/20 px-4 py-3 bg-white focus:outline-none focus:border-[#7A9E7E] resize-none leading-relaxed"
        />
        <p className="text-xs text-[#2C2A28]/40 mt-1">
          {content.trim().length < 20
            ? `At least ${20 - content.trim().length} more characters`
            : ""}
        </p>
      </div>

      <label className="flex items-center gap-3 cursor-pointer">
        <input
          type="checkbox"
          checked={isAnonymous}
          onChange={(e) => setIsAnonymous(e.target.checked)}
          className="w-4 h-4"
        />
        <span className="text-sm text-[#2C2A28]/70">Share anonymously</span>
      </label>

      <div className="border border-[#2C2A28]/10 p-4 text-xs text-[#2C2A28]/50 leading-relaxed">
        Once shared, your reflection is visible to all members of your cohort circle and your facilitator.
        You cannot edit it after posting. Use discretion — only share what you&apos;re ready to hold openly.
      </div>

      <button
        type="submit"
        disabled={loading || content.trim().length < 20}
        className="w-full bg-[#2C2A28] text-[#F9F7F4] py-3 text-sm hover:opacity-80 transition-opacity disabled:opacity-50"
      >
        {loading ? "Sharing…" : "Share with circle"}
      </button>
    </form>
  );
}

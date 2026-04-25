"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const MOOD_LABELS: Record<number, string> = {
  1: "Struggling",
  2: "Low",
  3: "Okay",
  4: "Good",
  5: "Thriving",
};

const SENSATIONS = [
  "Tight chest", "Open heart", "Heavy limbs", "Light energy", "Grounded",
  "Scattered", "Numb", "Restless", "Calm", "Tender",
];

interface Props {
  weekNumber: number;
}

export function CheckInForm({ weekNumber }: Props) {
  const [mood, setMood] = useState<number>(3);
  const [sensation, setSensation] = useState("");
  const [oneWord, setOneWord] = useState("");
  const [note, setNote] = useState("");
  const [loading, setLoading] = useState(false);
  const [done, setDone] = useState(false);
  const router = useRouter();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!oneWord.trim()) return;
    setLoading(true);
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (user) {
      await supabase.from("check_ins").insert({
        user_id: user.id,
        week_number: weekNumber,
        mood_score: mood,
        body_sensation: sensation || null,
        one_word: oneWord.trim(),
        free_note: note.trim() || null,
      });
    }
    setDone(true);
    setLoading(false);
  }

  if (done) {
    return (
      <div className="text-center py-12">
        <p className="text-2xl mb-3" style={{ fontFamily: "Georgia, serif" }}>Thank you.</p>
        <p className="text-[#2C2A28]/60 text-sm mb-8">Your check-in for Week {weekNumber} is saved.</p>
        <button
          onClick={() => router.push("/home")}
          className="text-sm text-[#7A9E7E] underline"
        >
          Return home →
        </button>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-8">
      <div>
        <p className="text-sm font-medium mb-3">How are you this week?</p>
        <div className="flex gap-3">
          {[1, 2, 3, 4, 5].map((n) => (
            <button
              key={n}
              type="button"
              onClick={() => setMood(n)}
              className="flex-1 flex flex-col items-center gap-1 py-3 border transition-colors"
              style={{
                borderColor: mood === n ? "#7A9E7E" : "#2C2A28" + "1A",
                backgroundColor: mood === n ? "#7A9E7E" + "1A" : "transparent",
              }}
            >
              <span className="text-lg font-medium">{n}</span>
              <span className="text-[10px] text-[#2C2A28]/60 leading-tight text-center">
                {MOOD_LABELS[n]}
              </span>
            </button>
          ))}
        </div>
      </div>

      <div>
        <p className="text-sm font-medium mb-3">What are you noticing in your body?</p>
        <div className="flex flex-wrap gap-2">
          {SENSATIONS.map((s) => (
            <button
              key={s}
              type="button"
              onClick={() => setSensation(sensation === s ? "" : s)}
              className="px-3 py-1.5 text-sm border transition-colors"
              style={{
                borderColor: sensation === s ? "#7A9E7E" : "#2C2A28" + "1A",
                backgroundColor: sensation === s ? "#7A9E7E" + "1A" : "transparent",
              }}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium mb-2" htmlFor="one-word">
          One word for where you are right now <span className="text-[#C0392B]">*</span>
        </label>
        <input
          id="one-word"
          type="text"
          required
          maxLength={30}
          value={oneWord}
          onChange={(e) => setOneWord(e.target.value)}
          placeholder="e.g. hopeful, scattered, present…"
          className="w-full border border-[#2C2A28]/20 px-4 py-3 bg-white focus:outline-none focus:border-[#7A9E7E]"
        />
      </div>

      <div>
        <label className="block text-sm font-medium mb-2" htmlFor="note">
          Anything else you want to note? <span className="text-[#2C2A28]/40 font-normal">(private, optional)</span>
        </label>
        <textarea
          id="note"
          rows={3}
          value={note}
          onChange={(e) => setNote(e.target.value)}
          placeholder="This stays with you."
          className="w-full border border-[#2C2A28]/20 px-4 py-3 bg-white focus:outline-none focus:border-[#7A9E7E] resize-none"
        />
      </div>

      <button
        type="submit"
        disabled={loading || !oneWord.trim()}
        className="w-full bg-[#2C2A28] text-[#F9F7F4] py-3 text-sm hover:opacity-80 transition-opacity disabled:opacity-50"
      >
        {loading ? "Saving…" : "Save check-in"}
      </button>
    </form>
  );
}

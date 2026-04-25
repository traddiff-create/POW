import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

const CATEGORY_LABELS: Record<string, string> = {
  somatic: "Somatic",
  breathwork: "Breathwork",
  mindfulness: "Mindfulness",
  journaling: "Journaling",
  relational: "Relational",
  civic: "Civic",
};

export default async function PracticesPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: enrollment } = await supabase
    .from("enrollments")
    .select("cohort_id, cohorts(start_date)")
    .eq("user_id", user.id)
    .order("enrolled_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  const cohort = enrollment
    ? (enrollment as unknown as { cohorts: { start_date: string } }).cohorts
    : null;

  const weekNumber = cohort
    ? Math.min(8, Math.max(1, Math.ceil((Date.now() - new Date(cohort.start_date).getTime()) / (7 * 24 * 60 * 60 * 1000))))
    : null;

  const { data: practices } = await supabase
    .from("practices")
    .select("id, title, category, duration_minutes, week_number, has_audio")
    .order("week_number", { ascending: true, nullsFirst: false });

  const thisWeek = weekNumber ? practices?.filter((p) => p.week_number === weekNumber) : [];
  const other = practices?.filter((p) => !weekNumber || p.week_number !== weekNumber) ?? [];

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-10">
        <h1 className="text-2xl" style={{ fontFamily: "Georgia, serif" }}>Practices</h1>

        {thisWeek && thisWeek.length > 0 && (
          <section>
            <p className="text-xs text-[#7A9E7E] uppercase tracking-wide mb-3">This week · Week {weekNumber}</p>
            <ul className="space-y-3">
              {thisWeek.map((p) => (
                <PracticeCard key={p.id} practice={p} highlight />
              ))}
            </ul>
          </section>
        )}

        {other.length > 0 && (
          <section>
            <p className="text-xs text-[#2C2A28]/40 uppercase tracking-wide mb-3">All practices</p>
            <ul className="space-y-3">
              {other.map((p) => (
                <PracticeCard key={p.id} practice={p} />
              ))}
            </ul>
          </section>
        )}

        {(!practices || practices.length === 0) && (
          <p className="text-[#2C2A28]/50 text-sm">No practices available yet.</p>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

function PracticeCard({
  practice,
  highlight,
}: {
  practice: {
    id: string;
    title: string;
    category: string | null;
    duration_minutes: number | null;
    week_number: number | null;
    has_audio: boolean;
  };
  highlight?: boolean;
}) {
  return (
    <li>
      <Link
        href={`/practices/${practice.id}`}
        className="block border p-4 hover:border-[#7A9E7E]/40 transition-colors"
        style={{ borderColor: highlight ? "#7A9E7E" + "40" : "#2C2A28" + "1A" }}
      >
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-sm font-medium">{practice.title}</p>
            <div className="flex gap-3 mt-1 text-xs text-[#2C2A28]/50">
              {practice.category && (
                <span>{CATEGORY_LABELS[practice.category] ?? practice.category}</span>
              )}
              {practice.duration_minutes && (
                <span>{practice.duration_minutes} min</span>
              )}
              {practice.has_audio && <span>🎧</span>}
            </div>
          </div>
          {practice.week_number && (
            <span className="text-xs text-[#7A9E7E] shrink-0">Week {practice.week_number}</span>
          )}
        </div>
      </Link>
    </li>
  );
}

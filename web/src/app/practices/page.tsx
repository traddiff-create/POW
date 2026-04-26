import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";
import { currentProgramWeek } from "@/lib/week";

const CATEGORY_LABELS: Record<string, string> = {
  self_regulation: "Self-Regulation",
  co_regulation: "Co-Regulation",
  community: "Community",
  agency: "Agency",
  civic_engagement: "Civic Engagement",
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

  const weekNumber = cohort ? currentProgramWeek(cohort.start_date) : null;

  const { data: practices } = await supabase
    .from("practices")
    .select("id, title, subtitle, category, duration_minutes, week_number, has_audio, audio_source, source_kind, evidence_level, risk_level, sort_order")
    .order("sort_order", { ascending: true, nullsFirst: false })
    .order("week_number", { ascending: true, nullsFirst: false });

  const thisWeek = weekNumber ? practices?.filter((p) => p.week_number === weekNumber) : [];
  const other = practices?.filter((p) => !weekNumber || p.week_number !== weekNumber) ?? [];

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-10">
        <h1 className="text-2xl">Practices</h1>

        {thisWeek && thisWeek.length > 0 && (
          <section>
            <p className="text-xs text-sage uppercase tracking-wide mb-3">This week · Week {weekNumber}</p>
            <ul className="space-y-3">
              {thisWeek.map((p) => (
                <PracticeCard key={p.id} practice={p} highlight />
              ))}
            </ul>
          </section>
        )}

        {other.length > 0 && (
          <section>
            <p className="text-xs text-foreground/40 uppercase tracking-wide mb-3">All practices</p>
            <ul className="space-y-3">
              {other.map((p) => (
                <PracticeCard key={p.id} practice={p} />
              ))}
            </ul>
          </section>
        )}

        {(!practices || practices.length === 0) && (
          <p className="text-foreground/50 text-sm">No practices available yet.</p>
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
    subtitle: string | null;
    category: string | null;
    duration_minutes: number | null;
    week_number: number | null;
    has_audio: boolean;
    audio_source: string | null;
    source_kind: string | null;
    evidence_level: string | null;
    risk_level: string | null;
  };
  highlight?: boolean;
}) {
  return (
    <li>
      <Link
        href={`/practices/${practice.id}`}
        className={`block border p-4 hover:border-sage/40 transition-colors ${highlight ? "border-sage/40" : "border-foreground/10"}`}
      >
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-sm font-medium">{practice.title}</p>
            {practice.subtitle && (
              <p className="text-xs text-foreground/50 mt-1">{practice.subtitle}</p>
            )}
            <div className="flex gap-3 mt-1 text-xs text-foreground/50">
              {practice.category && (
                <span>{CATEGORY_LABELS[practice.category] ?? practice.category}</span>
              )}
              {practice.duration_minutes && (
                <span>{practice.duration_minutes} min</span>
              )}
              {practice.has_audio && (
                <span>{practice.audio_source === "ios_bundle" ? "Audio in iOS" : "Audio"}</span>
              )}
            </div>
            <div className="flex flex-wrap gap-2 mt-2 text-[11px] text-foreground/40">
              {practice.source_kind && <span>{labelize(practice.source_kind)}</span>}
              {practice.evidence_level && <span>Evidence: {labelize(practice.evidence_level)}</span>}
              {practice.risk_level && <span>Risk: {labelize(practice.risk_level)}</span>}
            </div>
          </div>
          {practice.week_number && (
            <span className="text-xs text-sage shrink-0">Week {practice.week_number}</span>
          )}
        </div>
      </Link>
    </li>
  );
}

function labelize(value: string) {
  return value.replaceAll("_", " ").replace(/\b\w/g, (char) => char.toUpperCase());
}

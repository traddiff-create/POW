import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function MyPiecePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const [profileRes, enrollmentRes, checkInsRes, journalRes, sharesRes] = await Promise.all([
    supabase.from("user_profiles").select("display_name, onboarding_completed_at").eq("id", user.id).single(),
    supabase.from("enrollments").select("cohort_id, enrolled_at, cohorts(name, start_date)").eq("user_id", user.id).order("enrolled_at", { ascending: false }).limit(1).maybeSingle(),
    supabase.from("check_ins").select("id, week_number").eq("user_id", user.id),
    supabase.from("journal_entries").select("id").eq("user_id", user.id),
    supabase.from("circle_shares").select("id").eq("user_id", user.id),
  ]);

  const profile = profileRes.data;
  const enrollment = enrollmentRes.data;
  const cohort = enrollment
    ? (enrollment as unknown as { cohorts: { name: string; start_date: string } }).cohorts
    : null;

  const weekNumber = cohort
    ? Math.min(8, Math.max(1, Math.ceil((Date.now() - new Date(cohort.start_date).getTime()) / (7 * 24 * 60 * 60 * 1000))))
    : null;

  const checkIns = checkInsRes.data ?? [];
  const journalCount = journalRes.data?.length ?? 0;
  const shareCount = sharesRes.data?.length ?? 0;
  const checkedWeeks = new Set(checkIns.map((c) => c.week_number));

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-10">
        <h1 className="text-2xl">My piece</h1>

        {cohort ? (
          <section className="border border-foreground/10 p-6 space-y-4">
            <div>
              <p className="text-xs text-foreground/40 uppercase tracking-wide mb-1">Cohort</p>
              <p className="font-medium">{cohort.name}</p>
            </div>
            {weekNumber && (
              <div>
                <p className="text-xs text-foreground/40 uppercase tracking-wide mb-2">Check-ins</p>
                <div className="flex gap-2">
                  {Array.from({ length: 8 }, (_, i) => i + 1).map((w) => (
                    <div
                      key={w}
                      className={`w-8 h-8 flex items-center justify-center text-xs border ${
                        checkedWeeks.has(w)
                          ? "border-sage bg-sage/10"
                          : "border-foreground/10 bg-transparent"
                      } ${w === weekNumber ? "text-foreground font-semibold" : "text-foreground/50 font-normal"}`}
                    >
                      {w}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </section>
        ) : (
          <section className="border border-foreground/10 p-6">
            <p className="text-foreground/50 text-sm">You&apos;re not enrolled in a cohort yet.</p>
            <Link href="/cohorts" className="text-sm text-sage underline mt-2 block">
              Browse cohorts →
            </Link>
          </section>
        )}

        <section className="grid grid-cols-2 gap-4">
          <div className="border border-foreground/10 p-4 text-center">
            <p className="text-3xl font-light mb-1">{journalCount}</p>
            <p className="text-xs text-foreground/50 uppercase tracking-wide">Journal entries</p>
          </div>
          <div className="border border-foreground/10 p-4 text-center">
            <p className="text-3xl font-light mb-1">{shareCount}</p>
            <p className="text-xs text-foreground/50 uppercase tracking-wide">Circle shares</p>
          </div>
        </section>

        <nav className="text-sm space-y-2">
          <Link href="/journal" className="block text-sage underline">Journal →</Link>
          <Link href="/practices" className="block text-sage underline">Practices →</Link>
          <Link href="/circle" className="block text-sage underline">Circle →</Link>
        </nav>
      </main>
      <CrisisBanner />
    </div>
  );
}

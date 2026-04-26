import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";
import { currentDateLabel, currentGreeting, currentProgramWeek } from "@/lib/week";

export default async function HomePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: profile } = await supabase
    .from("user_profiles")
    .select("display_name, onboarding_completed_at")
    .eq("id", user.id)
    .single();

  if (profile && !profile.onboarding_completed_at) {
    redirect("/onboarding");
  }

  const { data: enrollment } = await supabase
    .from("enrollments")
    .select("cohort_id, cohorts(name, start_date, cohort_curriculum(week_number, title, theme, circle_prompt))")
    .eq("user_id", user.id)
    .order("enrolled_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  const cohort = enrollment ? (enrollment as unknown as {
    cohort_id: string;
    cohorts: {
      name: string;
      start_date: string;
      cohort_curriculum: Array<{ week_number: number; title: string; theme: string; circle_prompt: string }>;
    };
  }).cohorts : null;

  const weekNumber = currentProgramWeek(cohort?.start_date);

  const currentWeek = cohort?.cohort_curriculum?.find((w) => w.week_number === weekNumber);

  const { data: checkIn } = await supabase
    .from("check_ins")
    .select("id")
    .eq("user_id", user.id)
    .eq("week_number", weekNumber)
    .maybeSingle();

  const firstName = profile?.display_name?.split(" ")[0] ?? "there";
  const greeting = currentGreeting();

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-10">
        <div>
          <p className="text-foreground/50 text-sm mb-1">
            {currentDateLabel()}
          </p>
          <h1 className="text-3xl">
            {greeting}, {firstName}.
          </h1>
        </div>

        {currentWeek && (
          <section className="border border-foreground/10 p-6">
            <p className="text-xs text-sage uppercase tracking-wide mb-2">Week {weekNumber}</p>
            <h2 className="text-xl mb-1">{currentWeek.title}</h2>
            <p className="text-foreground/60 text-sm mb-4">{currentWeek.theme}</p>
            {currentWeek.circle_prompt && (
              <blockquote className="border-l-2 border-stone pl-4 text-foreground/70 italic text-sm mb-4">
                {currentWeek.circle_prompt}
              </blockquote>
            )}
            <Link href="/practices" className="text-sm text-sage underline">
              This week&apos;s practice →
            </Link>
          </section>
        )}

        <section className="border border-foreground/10 p-6">
          <h2 className="font-medium mb-3">Weekly check-in</h2>
          {checkIn ? (
            <p className="text-sage text-sm">✓ Check-in complete for this week.</p>
          ) : (
            <Link
              href="/check-in"
              className="inline-block bg-foreground text-background px-5 py-2.5 text-sm hover:opacity-80 transition-opacity"
            >
              How are you this week?
            </Link>
          )}
        </section>

        <section className="border border-foreground/10 p-6">
          <h2 className="font-medium mb-3">Your circle</h2>
          <Link href="/circle" className="text-sm text-sage underline">View circle →</Link>
        </section>

        <nav className="pt-4 border-t border-foreground/10">
          <ul className="flex flex-wrap gap-x-6 gap-y-2 text-sm text-sage">
            <li><Link href="/practices" className="underline">Practices</Link></li>
            <li><Link href="/journal" className="underline">Journal</Link></li>
            <li><Link href="/civic" className="underline">Civic</Link></li>
            <li><Link href="/my-piece" className="underline">My progress</Link></li>
            <li><Link href="/settings" className="underline">Settings</Link></li>
          </ul>
        </nav>
      </main>
      <CrisisBanner />
    </div>
  );
}

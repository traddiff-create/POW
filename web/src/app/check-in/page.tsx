import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";
import { currentProgramWeek } from "@/lib/week";
import { CheckInForm } from "./CheckInForm";

export default async function CheckInPage() {
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
    ? (enrollment as unknown as { cohort_id: string; cohorts: { start_date: string } }).cohorts
    : null;

  const weekNumber = currentProgramWeek(cohort?.start_date);

  const { data: existing } = await supabase
    .from("check_ins")
    .select("id")
    .eq("user_id", user.id)
    .eq("week_number", weekNumber)
    .maybeSingle();

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-lg mx-auto w-full">
        <div className="mb-8">
          <p className="text-xs text-sage uppercase tracking-wide mb-1">Week {weekNumber}</p>
          <h1 className="text-2xl">
            How are you this week?
          </h1>
          <p className="text-foreground/50 text-sm mt-1">This check-in is private — only you can see it.</p>
        </div>

        {existing ? (
          <div className="text-center py-12 border border-foreground/10 p-6">
            <p className="text-sage text-sm mb-4">✓ You&apos;ve already checked in this week.</p>
            <a href="/home" className="text-sm text-foreground/60 underline">Return home →</a>
          </div>
        ) : (
          <CheckInForm weekNumber={weekNumber} />
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

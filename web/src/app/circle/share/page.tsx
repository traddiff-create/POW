import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";
import { ShareForm } from "./ShareForm";

export default async function SharePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: enrollment } = await supabase
    .from("enrollments")
    .select("cohort_id, cohorts(start_date, cohort_curriculum(week_number, circle_prompt))")
    .eq("user_id", user.id)
    .order("enrolled_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (!enrollment) redirect("/home");

  const cohort = (enrollment as unknown as {
    cohort_id: string;
    cohorts: { start_date: string; cohort_curriculum: Array<{ week_number: number; circle_prompt: string }> };
  }).cohorts;

  const weekNumber = Math.min(8, Math.max(1, Math.ceil(
    (Date.now() - new Date(cohort.start_date).getTime()) / (7 * 24 * 60 * 60 * 1000)
  )));

  const curriculumWeek = cohort.cohort_curriculum?.find((w) => w.week_number === weekNumber);
  const cohortId = (enrollment as unknown as { cohort_id: string }).cohort_id;

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-lg mx-auto w-full">
        <div className="mb-8">
          <p className="text-xs text-sage uppercase tracking-wide mb-1">Week {weekNumber}</p>
          <h1 className="text-2xl">
            Share with your circle
          </h1>
        </div>
        <ShareForm
          cohortId={cohortId}
          weekNumber={weekNumber}
          circlePrompt={curriculumWeek?.circle_prompt ?? null}
        />
      </main>
      <CrisisBanner />
    </div>
  );
}

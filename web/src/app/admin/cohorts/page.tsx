import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function AdminCohortsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: profile } = await supabase.from("user_profiles").select("role").eq("id", user.id).single();
  if (profile?.role !== "admin") redirect("/home");

  const { data: cohorts } = await supabase
    .from("cohorts")
    .select("id, name, slug, start_date, is_open, max_participants")
    .order("start_date", { ascending: false });

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-8">
        <div>
          <a href="/admin" className="text-sm text-foreground/40 hover:text-foreground/70">← Admin</a>
          <h1 className="text-2xl mt-2">Cohorts</h1>
        </div>

        {cohorts && cohorts.length > 0 ? (
          <ul className="space-y-3">
            {cohorts.map((cohort) => (
              <li key={cohort.id} className="border border-foreground/10 p-4">
                <div className="flex items-center justify-between gap-4">
                  <div>
                    <p className="text-sm font-medium">{cohort.name}</p>
                    {cohort.start_date && (
                      <p className="text-xs text-foreground/50 mt-0.5">
                        {new Date(cohort.start_date).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}
                      </p>
                    )}
                  </div>
                  <span
                    className={`text-xs px-2 py-0.5 border shrink-0 ${
                      cohort.is_open
                        ? "border-sage/40 text-sage"
                        : "border-foreground/10 text-foreground/50"
                    }`}
                  >
                    {cohort.is_open ? "Open" : "Closed"}
                  </span>
                </div>
                <div className="flex gap-4 mt-3">
                  <Link href={`/facilitator/cohort/${cohort.id}`} className="text-xs text-sage underline">
                    View circle
                  </Link>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-foreground/50 text-sm">No cohorts yet.</p>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

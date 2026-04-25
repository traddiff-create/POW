import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function FacilitatorPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: profile } = await supabase
    .from("user_profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  if (!profile || !["facilitator", "admin"].includes(profile.role ?? "")) {
    redirect("/home");
  }

  const { data: cohorts } = await supabase
    .from("cohorts")
    .select("id, name, start_date, enrollments(count)")
    .order("start_date", { ascending: false });

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-8">
        <h1 className="text-2xl" style={{ fontFamily: "Georgia, serif" }}>Facilitator dashboard</h1>

        <section>
          <h2 className="font-medium mb-3">Your cohorts</h2>
          {cohorts && cohorts.length > 0 ? (
            <ul className="space-y-3">
              {cohorts.map((cohort) => {
                const c = cohort as unknown as {
                  id: string; name: string; start_date: string;
                  enrollments: { count: number }[];
                };
                return (
                  <li key={c.id}>
                    <Link
                      href={`/facilitator/cohort/${c.id}`}
                      className="block border border-[#2C2A28]/10 p-4 hover:border-[#7A9E7E]/40 transition-colors"
                    >
                      <div className="flex items-center justify-between gap-4">
                        <div>
                          <p className="text-sm font-medium">{c.name}</p>
                          {c.start_date && (
                            <p className="text-xs text-[#2C2A28]/50 mt-0.5">
                              Started {new Date(c.start_date).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}
                            </p>
                          )}
                        </div>
                        <span className="text-xs text-[#2C2A28]/40 shrink-0">
                          View circle →
                        </span>
                      </div>
                    </Link>
                  </li>
                );
              })}
            </ul>
          ) : (
            <p className="text-[#2C2A28]/50 text-sm">No cohorts assigned.</p>
          )}
        </section>
      </main>
      <CrisisBanner />
    </div>
  );
}

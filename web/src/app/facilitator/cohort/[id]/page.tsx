import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function FacilitatorCohortPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
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

  const { data: cohort } = await supabase
    .from("cohorts")
    .select("id, name, start_date")
    .eq("id", id)
    .single();

  if (!cohort) notFound();

  const { data: shares } = await supabase
    .from("circle_shares")
    .select("id, content, is_anonymous, created_at, week_number, user_profiles(display_name)")
    .eq("cohort_id", id)
    .order("created_at", { ascending: false });

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-8">
        <div>
          <p className="text-xs text-[#2C2A28]/40 mb-1">Facilitator view</p>
          <h1 className="text-2xl" style={{ fontFamily: "Georgia, serif" }}>{cohort.name}</h1>
        </div>

        <section>
          <h2 className="font-medium mb-4">Circle shares</h2>
          {shares && shares.length > 0 ? (
            <ul className="space-y-4">
              {shares.map((share) => {
                const s = share as unknown as {
                  id: string;
                  content: string;
                  is_anonymous: boolean;
                  created_at: string;
                  week_number: number | null;
                  user_profiles: { display_name: string } | null;
                };
                const name = s.is_anonymous ? "Anonymous" : s.user_profiles?.display_name ?? "Member";
                return (
                  <li key={s.id} className="border border-[#2C2A28]/10 p-5">
                    <div className="flex items-baseline justify-between gap-4 mb-2">
                      <span className="text-xs text-[#7A9E7E]">
                        {name}
                        {s.week_number ? ` · Week ${s.week_number}` : ""}
                      </span>
                      <span className="text-xs text-[#2C2A28]/40">
                        {new Date(s.created_at).toLocaleDateString("en-US", { month: "short", day: "numeric" })}
                      </span>
                    </div>
                    <p className="text-sm text-[#2C2A28]/80 leading-relaxed whitespace-pre-wrap">{s.content}</p>
                  </li>
                );
              })}
            </ul>
          ) : (
            <p className="text-[#2C2A28]/50 text-sm">No shares yet in this cohort.</p>
          )}
        </section>
      </main>
      <CrisisBanner />
    </div>
  );
}

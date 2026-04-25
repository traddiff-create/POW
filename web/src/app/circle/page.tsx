import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function CirclePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: enrollment } = await supabase
    .from("enrollments")
    .select("cohort_id")
    .eq("user_id", user.id)
    .order("enrolled_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  const cohortId = enrollment?.cohort_id ?? null;

  const { data: shares } = cohortId
    ? await supabase
        .from("circle_shares")
        .select("id, content, is_anonymous, created_at, week_number, user_id, user_profiles(display_name)")
        .eq("cohort_id", cohortId)
        .order("created_at", { ascending: false })
    : { data: null };

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-8">
        <div className="flex items-baseline justify-between">
          <h1 className="text-2xl" style={{ fontFamily: "Georgia, serif" }}>Your circle</h1>
          <Link
            href="/circle/share"
            className="text-sm text-[#7A9E7E] underline"
          >
            Share a reflection →
          </Link>
        </div>

        <p className="text-xs text-[#2C2A28]/40 uppercase tracking-wide -mt-4">
          Visible to everyone in your cohort
        </p>

        {shares && shares.length > 0 ? (
          <ul className="space-y-4">
            {shares.map((share) => {
              const s = share as unknown as {
                id: string;
                content: string;
                is_anonymous: boolean;
                created_at: string;
                week_number: number | null;
                user_id: string;
                user_profiles: { display_name: string } | null;
              };
              const isOwn = s.user_id === user.id;
              const name = s.is_anonymous
                ? "Anonymous"
                : s.user_profiles?.display_name ?? "A circle member";
              return (
                <li key={s.id} className="border border-[#2C2A28]/10 p-5">
                  <div className="flex items-baseline justify-between gap-4 mb-3">
                    <span className="text-xs text-[#7A9E7E]">
                      {isOwn ? "You" : name}
                      {s.week_number ? ` · Week ${s.week_number}` : ""}
                    </span>
                    <span className="text-xs text-[#2C2A28]/40 shrink-0">
                      {new Date(s.created_at).toLocaleDateString("en-US", {
                        month: "short", day: "numeric",
                      })}
                    </span>
                  </div>
                  <p className="text-[#2C2A28]/80 text-sm leading-relaxed whitespace-pre-wrap">
                    {s.content}
                  </p>
                </li>
              );
            })}
          </ul>
        ) : (
          <div className="border border-[#2C2A28]/10 p-8 text-center">
            <p className="text-[#2C2A28]/50 text-sm mb-4">
              Your circle is quiet. Be the first to share.
            </p>
            <Link href="/circle/share" className="text-sm text-[#7A9E7E] underline">
              Share a reflection →
            </Link>
          </div>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

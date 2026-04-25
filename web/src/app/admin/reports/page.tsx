import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function AdminReportsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: profile } = await supabase.from("user_profiles").select("role").eq("id", user.id).single();
  if (profile?.role !== "admin") redirect("/home");

  const { data: reports } = await supabase
    .from("reports")
    .select("id, reason, status, created_at, reporter_id, reported_content_id, user_profiles!reporter_id(display_name)")
    .order("created_at", { ascending: false });

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-8">
        <div>
          <a href="/admin" className="text-sm text-foreground/40 hover:text-foreground/70">← Admin</a>
          <h1 className="text-2xl mt-2">Content reports</h1>
        </div>

        {reports && reports.length > 0 ? (
          <ul className="space-y-4">
            {reports.map((report) => {
              const r = report as unknown as {
                id: string;
                reason: string | null;
                status: string;
                created_at: string;
                reported_content_id: string | null;
                user_profiles: { display_name: string } | null;
              };
              return (
                <li key={r.id} className="border border-foreground/10 p-5">
                  <div className="flex items-baseline justify-between gap-4 mb-2">
                    <span className="text-xs font-medium uppercase tracking-wide text-error">
                      {r.status}
                    </span>
                    <span className="text-xs text-foreground/40">
                      {new Date(r.created_at).toLocaleDateString("en-US", { month: "short", day: "numeric" })}
                    </span>
                  </div>
                  <p className="text-sm text-foreground/70">{r.reason ?? "No reason provided."}</p>
                  {r.user_profiles?.display_name && (
                    <p className="text-xs text-foreground/40 mt-1">
                      Reported by: {r.user_profiles.display_name}
                    </p>
                  )}
                </li>
              );
            })}
          </ul>
        ) : (
          <p className="text-foreground/50 text-sm">No reports.</p>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

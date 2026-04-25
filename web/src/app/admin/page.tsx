import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function AdminPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: profile } = await supabase
    .from("user_profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  if (profile?.role !== "admin") redirect("/home");

  const [appRes, cohortRes, memberRes, reportRes] = await Promise.all([
    supabase.from("applications").select("id", { count: "exact" }).eq("status", "pending"),
    supabase.from("cohorts").select("id", { count: "exact" }),
    supabase.from("user_profiles").select("id", { count: "exact" }).eq("role", "participant"),
    supabase.from("reports").select("id", { count: "exact" }).eq("status", "open"),
  ]);

  const stats = [
    { label: "Pending applications", count: appRes.count ?? 0, href: "/admin/applications" },
    { label: "Active cohorts", count: cohortRes.count ?? 0, href: "/admin/cohorts" },
    { label: "Participants", count: memberRes.count ?? 0, href: "/admin/members" },
    { label: "Open reports", count: reportRes.count ?? 0, href: "/admin/reports" },
  ];

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-10">
        <h1 className="text-2xl">Admin</h1>

        <div className="grid grid-cols-2 gap-4">
          {stats.map((s) => (
            <Link key={s.href} href={s.href}
              className="border border-foreground/10 p-5 hover:border-sage/40 transition-colors"
            >
              <p className="text-3xl font-light mb-1">{s.count}</p>
              <p className="text-xs text-foreground/50 uppercase tracking-wide">{s.label}</p>
            </Link>
          ))}
        </div>

        <nav className="space-y-2 text-sm">
          <Link href="/admin/applications" className="block text-sage underline">Applications queue →</Link>
          <Link href="/admin/cohorts" className="block text-sage underline">Cohorts →</Link>
          <Link href="/admin/members" className="block text-sage underline">Members →</Link>
          <Link href="/admin/reports" className="block text-sage underline">Reports →</Link>
        </nav>
      </main>
      <CrisisBanner />
    </div>
  );
}

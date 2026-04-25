import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";
import { ApplicationCard } from "./ApplicationCard";

export default async function AdminApplicationsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: profile } = await supabase
    .from("user_profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  if (profile?.role !== "admin") redirect("/home");

  const { data: rawApplications } = await supabase
    .from("applications")
    .select("id, applicant_name, applicant_email, motivation, status, created_at, cohort_id")
    .order("created_at", { ascending: false });

  const cohortIds = [...new Set((rawApplications ?? []).map((a) => a.cohort_id).filter(Boolean))] as string[];
  const { data: cohortRows } = cohortIds.length > 0
    ? await supabase.from("cohorts").select("id, name").in("id", cohortIds)
    : { data: [] };

  const cohortMap = Object.fromEntries((cohortRows ?? []).map((c) => [c.id, c.name]));

  const applications = (rawApplications ?? []).map((a) => ({
    ...a,
    cohorts: a.cohort_id && cohortMap[a.cohort_id] ? { name: cohortMap[a.cohort_id] } : null,
  }));

  const pending = applications.filter((a) => a.status === "pending");
  const reviewed = applications.filter((a) => a.status !== "pending");

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-10">
        <div>
          <a href="/admin" className="text-sm text-[#2C2A28]/40 hover:text-[#2C2A28]/70">← Admin</a>
          <h1 className="text-2xl mt-2" style={{ fontFamily: "Georgia, serif" }}>Applications</h1>
        </div>

        <section>
          <h2 className="font-medium mb-4">Pending ({pending.length})</h2>
          {pending.length > 0 ? (
            <ul className="space-y-4">
              {pending.map((app) => (
                <ApplicationCard key={app.id} application={app as never} />
              ))}
            </ul>
          ) : (
            <p className="text-[#2C2A28]/50 text-sm">No pending applications.</p>
          )}
        </section>

        {reviewed.length > 0 && (
          <section>
            <h2 className="font-medium mb-4">Reviewed ({reviewed.length})</h2>
            <ul className="space-y-4">
              {reviewed.map((app) => (
                <ApplicationCard key={app.id} application={app as never} />
              ))}
            </ul>
          </section>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

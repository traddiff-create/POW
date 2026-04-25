import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function AdminMembersPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: profile } = await supabase.from("user_profiles").select("role").eq("id", user.id).single();
  if (profile?.role !== "admin") redirect("/home");

  const { data: members } = await supabase
    .from("user_profiles")
    .select("id, display_name, role, created_at, onboarding_completed_at")
    .order("created_at", { ascending: false });

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-8">
        <div>
          <a href="/admin" className="text-sm text-[#2C2A28]/40 hover:text-[#2C2A28]/70">← Admin</a>
          <h1 className="text-2xl mt-2" style={{ fontFamily: "Georgia, serif" }}>Members</h1>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-[#2C2A28]/10">
                <th className="text-left py-2 pr-4 text-xs text-[#2C2A28]/40 uppercase tracking-wide font-normal">Name</th>
                <th className="text-left py-2 pr-4 text-xs text-[#2C2A28]/40 uppercase tracking-wide font-normal">Role</th>
                <th className="text-left py-2 text-xs text-[#2C2A28]/40 uppercase tracking-wide font-normal">Joined</th>
              </tr>
            </thead>
            <tbody>
              {(members ?? []).map((m) => (
                <tr key={m.id} className="border-b border-[#2C2A28]/05">
                  <td className="py-3 pr-4 text-[#2C2A28]">{m.display_name ?? "—"}</td>
                  <td className="py-3 pr-4">
                    <span className="text-xs text-[#2C2A28]/50">{m.role ?? "participant"}</span>
                  </td>
                  <td className="py-3 text-xs text-[#2C2A28]/50">
                    {new Date(m.created_at).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {(!members || members.length === 0) && (
            <p className="text-[#2C2A28]/50 text-sm py-4">No members yet.</p>
          )}
        </div>
      </main>
      <CrisisBanner />
    </div>
  );
}

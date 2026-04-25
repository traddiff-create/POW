import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";
import { SettingsForm } from "./SettingsForm";

export default async function SettingsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: profile } = await supabase
    .from("user_profiles")
    .select("display_name")
    .eq("id", user.id)
    .single();

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-lg mx-auto w-full">
        <h1 className="text-2xl mb-8">Settings</h1>
        <SettingsForm
          initialName={profile?.display_name ?? ""}
          userId={user.id}
        />
      </main>
      <CrisisBanner />
    </div>
  );
}

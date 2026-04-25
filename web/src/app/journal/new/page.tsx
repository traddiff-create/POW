import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";
import { JournalEditor } from "../JournalEditor";

export default async function NewJournalPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full">
        <JournalEditor entryId={null} initialTitle="" initialBody="" />
      </main>
      <CrisisBanner />
    </div>
  );
}

import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";
import { JournalEditor } from "../JournalEditor";

export default async function JournalEntryPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: entry } = await supabase
    .from("journal_entries")
    .select("id, title, body, created_at, week_number")
    .eq("id", id)
    .eq("user_id", user.id)
    .single();

  if (!entry) notFound();

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full">
        <p className="text-xs text-foreground/40 mb-6">
          {new Date(entry.created_at).toLocaleDateString("en-US", {
            weekday: "long", year: "numeric", month: "long", day: "numeric",
          })}
          {entry.week_number ? ` · Week ${entry.week_number}` : ""}
        </p>
        <JournalEditor
          entryId={entry.id}
          initialTitle={entry.title ?? ""}
          initialBody={entry.body ?? ""}
        />
      </main>
      <CrisisBanner />
    </div>
  );
}

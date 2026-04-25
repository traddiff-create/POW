import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function JournalPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: entries } = await supabase
    .from("journal_entries")
    .select("id, title, created_at, week_number")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false });

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full">
        <div className="flex items-baseline justify-between mb-8">
          <h1 className="text-2xl">Journal</h1>
          <Link
            href="/journal/new"
            className="text-sm bg-foreground text-background px-4 py-2 hover:opacity-80 transition-opacity"
          >
            New entry
          </Link>
        </div>

        <p className="text-xs text-foreground/40 mb-6 uppercase tracking-wide">
          Private — only visible to you
        </p>

        {entries && entries.length > 0 ? (
          <ul className="space-y-3">
            {entries.map((entry) => (
              <li key={entry.id}>
                <Link
                  href={`/journal/${entry.id}`}
                  className="block border border-foreground/10 p-4 hover:border-sage/40 transition-colors"
                >
                  <div className="flex items-baseline justify-between gap-4">
                    <p className="text-sm font-medium truncate">
                      {entry.title || "Untitled"}
                    </p>
                    <p className="text-xs text-foreground/40 shrink-0">
                      {new Date(entry.created_at).toLocaleDateString("en-US", {
                        month: "short",
                        day: "numeric",
                      })}
                    </p>
                  </div>
                  {entry.week_number && (
                    <p className="text-xs text-sage mt-1">Week {entry.week_number}</p>
                  )}
                </Link>
              </li>
            ))}
          </ul>
        ) : (
          <div className="border border-foreground/10 p-8 text-center">
            <p className="text-foreground/50 text-sm mb-4">
              Your journal is empty. This is your private space.
            </p>
            <Link href="/journal/new" className="text-sm text-sage underline">
              Write your first entry →
            </Link>
          </div>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

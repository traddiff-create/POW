import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { Footer } from "@/components/Footer";

export default async function CohortsPage() {
  const supabase = await createServiceClient();
  const { data: cohorts } = await supabase
    .from("cohorts")
    .select("id, name, slug, start_date, description, max_participants, is_open")
    .eq("is_open", true)
    .order("start_date", { ascending: true });

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16 max-w-2xl mx-auto w-full">
        <h1 className="text-3xl mb-4" style={{ fontFamily: "Georgia, serif" }}>Open cohorts</h1>
        <p className="text-[#2C2A28]/60 mb-10">
          Each cohort is a small group moving through 8 weeks together. Apply to join one below.
        </p>

        {cohorts && cohorts.length > 0 ? (
          <ul className="space-y-4">
            {cohorts.map((cohort) => (
              <li key={cohort.id}>
                <div className="border border-[#2C2A28]/10 p-6">
                  <div className="flex items-start justify-between gap-4 mb-2">
                    <h2 className="text-lg" style={{ fontFamily: "Georgia, serif" }}>{cohort.name}</h2>
                    <span className="text-xs text-[#7A9E7E] border border-[#7A9E7E]/30 px-2 py-0.5 shrink-0">
                      Open
                    </span>
                  </div>
                  {cohort.start_date && (
                    <p className="text-sm text-[#2C2A28]/50 mb-3">
                      Starts {new Date(cohort.start_date).toLocaleDateString("en-US", {
                        month: "long", day: "numeric", year: "numeric",
                      })}
                    </p>
                  )}
                  {cohort.description && (
                    <p className="text-sm text-[#2C2A28]/70 mb-4">{cohort.description}</p>
                  )}
                  <Link
                    href={`/apply?cohort=${cohort.slug ?? cohort.id}`}
                    className="inline-block bg-[#2C2A28] text-[#F9F7F4] px-5 py-2.5 text-sm hover:opacity-80 transition-opacity"
                  >
                    Apply →
                  </Link>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <div className="border border-[#2C2A28]/10 p-8 text-center">
            <p className="text-[#2C2A28]/50 text-sm">No open cohorts right now. Check back soon.</p>
          </div>
        )}
      </main>
      <Footer />
    </div>
  );
}

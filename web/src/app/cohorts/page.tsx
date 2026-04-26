import Link from "next/link";
import { Footer } from "@/components/Footer";
import { getOpenCohorts } from "@/lib/public-data";

export default async function CohortsPage() {
  const cohorts = await getOpenCohorts();

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16 max-w-2xl mx-auto w-full">
        <h1 className="text-3xl mb-4">Open cohorts</h1>
        <p className="text-foreground/60 mb-10">
          Each cohort is a small group moving through 8 weeks together. Apply to join one below.
        </p>

        {cohorts.length > 0 ? (
          <ul className="space-y-4">
            {cohorts.map((cohort) => (
              <li key={cohort.id}>
                <div className="border border-foreground/10 p-6">
                  <div className="flex items-start justify-between gap-4 mb-2">
                    <h2 className="text-lg">{cohort.name}</h2>
                    <span className="text-xs text-sage border border-sage/30 px-2 py-0.5 shrink-0">
                      Open
                    </span>
                  </div>
                  {cohort.start_date && (
                    <p className="text-sm text-foreground/50 mb-3">
                      Starts {new Date(cohort.start_date).toLocaleDateString("en-US", {
                        month: "long", day: "numeric", year: "numeric",
                      })}
                    </p>
                  )}
                  {cohort.description && (
                    <p className="text-sm text-foreground/70 mb-4">{cohort.description}</p>
                  )}
                  <Link
                    href={`/apply?cohort=${cohort.slug ?? cohort.id}`}
                    className="inline-block bg-foreground text-background px-5 py-2.5 text-sm hover:opacity-80 transition-opacity"
                  >
                    Apply →
                  </Link>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <div className="border border-foreground/10 p-8 text-center">
            <p className="text-foreground/50 text-sm">No open cohorts right now. Check back soon.</p>
          </div>
        )}
      </main>
      <Footer />
    </div>
  );
}

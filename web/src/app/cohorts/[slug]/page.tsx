import { notFound } from "next/navigation";
import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { Footer } from "@/components/Footer";

export default async function CohortDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const supabase = await createServiceClient();

  const { data: cohort } = await supabase
    .from("cohorts")
    .select("id, name, slug, start_date, description, is_open")
    .eq("slug", slug)
    .single();

  if (!cohort) notFound();

  const { data: curriculumRows } = await supabase
    .from("cohort_curriculum")
    .select("week_number, title, theme")
    .eq("cohort_id", cohort.id)
    .order("week_number");

  const curriculum = curriculumRows ?? [];

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16 max-w-2xl mx-auto w-full space-y-10">
        <div>
          <h1 className="text-3xl mb-3">{cohort.name}</h1>
          {cohort.start_date && (
            <p className="text-foreground/50 text-sm">
              Starts {new Date(cohort.start_date).toLocaleDateString("en-US", {
                month: "long", day: "numeric", year: "numeric",
              })}
            </p>
          )}
        </div>

        {cohort.description && (
          <p className="text-foreground/70 leading-relaxed">{cohort.description}</p>
        )}

        {curriculum.length > 0 && (
          <section>
            <h2 className="text-lg mb-4">8 weeks</h2>
            <ul className="space-y-3">
              {curriculum.map((week) => (
                <li key={week.week_number} className="flex gap-4 border border-foreground/10 p-4">
                  <span className="text-xs text-sage w-14 shrink-0 pt-0.5">Week {week.week_number}</span>
                  <div>
                    <p className="text-sm font-medium">{week.title}</p>
                    {week.theme && (
                      <p className="text-xs text-foreground/50 mt-0.5">{week.theme}</p>
                    )}
                  </div>
                </li>
              ))}
            </ul>
          </section>
        )}

        {cohort.is_open && (
          <Link
            href={`/apply?cohort=${cohort.slug ?? cohort.id}`}
            className="inline-block bg-foreground text-background px-6 py-3 text-sm hover:opacity-80 transition-opacity"
          >
            Apply for this cohort →
          </Link>
        )}
      </main>
      <Footer />
    </div>
  );
}

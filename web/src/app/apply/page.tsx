import { createServiceClient } from "@/lib/supabase/server";
import { Footer } from "@/components/Footer";
import { ApplyForm } from "./ApplyForm";

export default async function ApplyPage({
  searchParams,
}: {
  searchParams: Promise<{ cohort?: string }>;
}) {
  const { cohort: cohortSlug } = await searchParams;
  const supabase = await createServiceClient();

  const { data: cohorts } = await supabase
    .from("cohorts")
    .select("id, name, slug")
    .eq("is_open", true)
    .order("start_date");

  const openCohorts = cohorts ?? [];
  const defaultCohortId = cohortSlug
    ? openCohorts.find((c) => c.slug === cohortSlug)?.id
    : undefined;

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16">
        <div className="max-w-xl mx-auto">
          <h1 className="text-3xl mb-2">Apply to Join</h1>
          <p className="text-foreground/60 mb-12">
            Applications are reviewed by a human within 48 hours.
          </p>
          <ApplyForm cohorts={openCohorts} defaultCohortId={defaultCohortId} />
        </div>
      </main>
      <Footer />
    </div>
  );
}

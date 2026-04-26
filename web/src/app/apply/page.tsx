import { Footer } from "@/components/Footer";
import { getOpenCohorts, isDemoDataMode } from "@/lib/public-data";
import { ApplyForm } from "./ApplyForm";

export default async function ApplyPage({
  searchParams,
}: {
  searchParams: Promise<{ cohort?: string }>;
}) {
  const { cohort: cohortSlug } = await searchParams;
  const openCohorts = await getOpenCohorts();
  const defaultCohortId = cohortSlug
    ? openCohorts.find((c) => c.slug === cohortSlug || c.id === cohortSlug)?.id
    : undefined;
  const isDemoMode = isDemoDataMode();

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-16">
        <div className="max-w-xl mx-auto">
          <h1 className="text-3xl mb-2">Apply to Join</h1>
          <p className="text-foreground/60 mb-12">
            Applications are reviewed by a human within 48 hours.
          </p>
          <ApplyForm
            cohorts={openCohorts}
            defaultCohortId={defaultCohortId}
            isDemoMode={isDemoMode}
          />
        </div>
      </main>
      <Footer />
    </div>
  );
}

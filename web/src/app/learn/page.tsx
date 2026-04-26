import Link from "next/link";
import { CrisisBanner } from "@/components/CrisisBanner";
import {
  getLearningResources,
  type PublicLearningResource,
} from "@/lib/public-data";

const LAYER_LABELS: Record<string, string> = {
  self_regulation: "Self-Regulation",
  co_regulation: "Co-Regulation",
  community: "Community",
  agency: "Agency",
  civic_engagement: "Civic Engagement",
};

export default async function LearnPage() {
  const resources = await getLearningResources();

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-3xl mx-auto w-full space-y-10">
        <div className="space-y-4">
          <Link href="/" className="text-sm text-foreground/40 hover:text-foreground/70">
            ← Home
          </Link>
          <div>
            <p className="text-xs text-sage uppercase tracking-wide mb-2">Learn Library</p>
            <h1 className="text-3xl leading-tight">Readings for practice, reflection, and circle.</h1>
            <p className="text-sm text-foreground/60 mt-3 leading-relaxed">
              These are reviewed Alexandria shelf resources. Web shows metadata only; full readings,
              journal reflection, and circle sharing are available in the iOS app.
            </p>
          </div>
        </div>

        {resources.length > 0 ? (
          <ul className="space-y-4">
            {resources.map((resource) => (
              <ResourceCard key={resource.id} resource={resource} />
            ))}
          </ul>
        ) : (
          <p className="text-sm text-foreground/50">No Learn resources are published yet.</p>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

function ResourceCard({ resource }: { resource: PublicLearningResource }) {
  return (
    <li className="border border-foreground/10 p-5">
      <div className="flex items-start justify-between gap-4">
        <div className="space-y-2">
          <div>
            <h2 className="text-base font-medium">{resource.title}</h2>
            {resource.subtitle && (
              <p className="text-sm text-foreground/50 mt-1">{resource.subtitle}</p>
            )}
          </div>
          {resource.summary && (
            <p className="text-sm text-foreground/70 leading-relaxed">{resource.summary}</p>
          )}
          <div className="flex flex-wrap gap-2 text-xs text-foreground/45">
            {resource.reading_minutes && <span>{resource.reading_minutes} min</span>}
            <span>{statusLabel(resource.content_status)}</span>
            <span>{labelize(resource.file_type)}</span>
            {resource.layers.map((layer) => (
              <span key={layer}>{LAYER_LABELS[layer] ?? labelize(layer)}</span>
            ))}
          </div>
          {resource.subjects.length > 0 && (
            <p className="text-[11px] text-foreground/35">
              Alexandria subjects: {resource.subjects.slice(0, 4).join(", ")}
            </p>
          )}
        </div>
      </div>
    </li>
  );
}

function statusLabel(status: string) {
  if (status === "full_text") return "Full text in iOS";
  if (status === "excerpt") return "Summary in web";
  return "Metadata";
}

function labelize(value: string) {
  return value.replaceAll("_", " ").replace(/\b\w/g, (char) => char.toUpperCase());
}

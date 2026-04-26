import { demoCohorts, demoCurriculum, demoLearningResources } from "@/lib/demo-data";
import type {
  PublicCohort,
  PublicCurriculumItem,
  PublicLearningResource,
} from "@/lib/demo-data";
import { hasPublicSupabaseConfig } from "@/lib/supabase/config";
import { createClient } from "@/lib/supabase/server";

export type { PublicCohort, PublicCurriculumItem, PublicLearningResource };

const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function isDemoDataMode() {
  return !hasPublicSupabaseConfig();
}

export async function getOpenCohorts(options: { limit?: number } = {}) {
  if (isDemoDataMode()) {
    const cohorts = demoCohorts.filter((cohort) => cohort.is_open);
    return options.limit ? cohorts.slice(0, options.limit) : cohorts;
  }

  const supabase = await createClient();
  let query = supabase
    .from("cohorts")
    .select("id, name, slug, start_date, description, max_participants, is_open")
    .eq("is_open", true)
    .order("start_date", { ascending: true });

  if (options.limit) {
    query = query.limit(options.limit);
  }

  const { data } = await query;
  return (data ?? []) as PublicCohort[];
}

export async function getCohortBySlugOrID(slugOrID: string) {
  if (isDemoDataMode()) {
    return (
      demoCohorts.find(
        (cohort) => cohort.slug === slugOrID || cohort.id === slugOrID
      ) ?? null
    );
  }

  const supabase = await createClient();
  const query = supabase
    .from("cohorts")
    .select("id, name, slug, start_date, description, max_participants, is_open");

  const { data } = UUID_PATTERN.test(slugOrID)
    ? await query.eq("id", slugOrID).single()
    : await query.eq("slug", slugOrID).single();

  return (data as PublicCohort | null) ?? null;
}

export async function getCurriculumForCohort(cohortID: string) {
  if (isDemoDataMode()) {
    return demoCurriculum
      .filter((item) => item.cohort_id === cohortID)
      .sort((a, b) => a.week_number - b.week_number);
  }

  const supabase = await createClient();
  const { data } = await supabase
    .from("cohort_curriculum")
    .select("cohort_id, week_number, title, theme")
    .eq("cohort_id", cohortID)
    .order("week_number");

  return (data ?? []) as PublicCurriculumItem[];
}

export async function getLearningResources() {
  if (isDemoDataMode()) {
    return [...demoLearningResources].sort((a, b) => {
      const aSort = a.sort_order ?? Number.MAX_SAFE_INTEGER;
      const bSort = b.sort_order ?? Number.MAX_SAFE_INTEGER;
      return aSort - bSort || a.title.localeCompare(b.title);
    });
  }

  const supabase = await createClient();
  const { data } = await supabase
    .from("learning_resource_metadata")
    .select(
      "id, title, subtitle, summary, content_status, file_type, layers, subjects, tags, reading_minutes, published, sort_order, source_kind, source_id, source_uuid, created_at, updated_at"
    )
    .order("sort_order", { ascending: true, nullsFirst: false })
    .order("title", { ascending: true });

  return (data ?? []) as PublicLearningResource[];
}

import type { Database } from "@/types/database";

export type PublicCohort = Pick<
  Database["public"]["Tables"]["cohorts"]["Row"],
  "id" | "name" | "slug" | "start_date" | "description" | "max_participants" | "is_open"
>;

export type PublicCurriculumItem = Pick<
  Database["public"]["Tables"]["cohort_curriculum"]["Row"],
  "cohort_id" | "week_number" | "title" | "theme"
>;

export type PublicLearningResource =
  Database["public"]["Views"]["learning_resource_metadata"]["Row"];

export const demoCohorts: PublicCohort[] = [
  {
    id: "11111111-1111-4111-8111-111111111111",
    name: "Spring 2026 Starter Circle",
    slug: "spring-2026-starter-circle",
    start_date: "2026-05-18",
    description:
      "A small 8-week cohort for practicing self-regulation, co-regulation, and grounded community participation.",
    max_participants: 12,
    is_open: true,
  },
  {
    id: "22222222-2222-4222-8222-222222222222",
    name: "Summer 2026 Community Practice",
    slug: "summer-2026-community-practice",
    start_date: "2026-07-13",
    description:
      "A slower summer cohort focused on embodied capacity, repair, and local civic care.",
    max_participants: 10,
    is_open: true,
  },
];

export const demoCurriculum: PublicCurriculumItem[] = [
  {
    cohort_id: demoCohorts[0].id,
    week_number: 1,
    title: "Arriving",
    theme: "Orienting to body, consent, and the circle container.",
  },
  {
    cohort_id: demoCohorts[0].id,
    week_number: 2,
    title: "The Nervous System Is Not a Problem to Solve",
    theme: "Understanding signals without shame.",
  },
  {
    cohort_id: demoCohorts[0].id,
    week_number: 3,
    title: "Co-Regulation Is Not Weakness",
    theme: "Practicing connection as capacity.",
  },
  {
    cohort_id: demoCohorts[0].id,
    week_number: 4,
    title: "The Inner Critic Is Not the Enemy",
    theme: "Meeting protection with steadiness.",
  },
  {
    cohort_id: demoCohorts[0].id,
    week_number: 5,
    title: "Grief Is a Form of Love",
    theme: "Making room for loss without collapse.",
  },
  {
    cohort_id: demoCohorts[0].id,
    week_number: 6,
    title: "Agency Is a Practice",
    theme: "Small choices, honest boundaries, and repair.",
  },
  {
    cohort_id: demoCohorts[0].id,
    week_number: 7,
    title: "You Are Embedded",
    theme: "Relationship, community, place, and the living world.",
  },
  {
    cohort_id: demoCohorts[0].id,
    week_number: 8,
    title: "Carrying It Forward",
    theme: "Integrating practice into everyday civic care.",
  },
  {
    cohort_id: demoCohorts[1].id,
    week_number: 1,
    title: "Arriving",
    theme: "Orienting to body, consent, and the circle container.",
  },
  {
    cohort_id: demoCohorts[1].id,
    week_number: 2,
    title: "The Nervous System Is Not a Problem to Solve",
    theme: "Understanding signals without shame.",
  },
];

export const demoLearningResources: PublicLearningResource[] = [
  {
    id: "33333333-3333-4333-8333-333333333333",
    source_kind: "alexandria",
    source_id: "demo:window-of-tolerance",
    source_uuid: "33333333-3333-4333-8333-333333333333",
    title: "Window of Tolerance",
    subtitle: "A gentle map for nervous-system capacity",
    summary:
      "A short orientation to noticing activation, shutdown, and the middle zone where choice becomes more available.",
    content_status: "excerpt",
    file_type: "reading",
    layers: ["self_regulation"],
    subjects: ["somatic awareness", "trauma-informed practice"],
    tags: ["capacity", "regulation", "body"],
    reading_minutes: 6,
    published: true,
    sort_order: 10,
    created_at: "2026-04-25T12:00:00Z",
    updated_at: "2026-04-25T12:00:00Z",
  },
  {
    id: "44444444-4444-4444-8444-444444444444",
    source_kind: "alexandria",
    source_id: "demo:co-regulation",
    source_uuid: "44444444-4444-4444-8444-444444444444",
    title: "Co-Regulation as Practice",
    subtitle: "Connection without collapse or control",
    summary:
      "A reflection on how steady presence, consent, and attunement support shared capacity.",
    content_status: "metadata",
    file_type: "reading",
    layers: ["co_regulation", "community"],
    subjects: ["relationships", "facilitation"],
    tags: ["connection", "repair", "circle"],
    reading_minutes: 8,
    published: true,
    sort_order: 20,
    created_at: "2026-04-25T12:00:00Z",
    updated_at: "2026-04-25T12:00:00Z",
  },
  {
    id: "55555555-5555-4555-8555-555555555555",
    source_kind: "alexandria",
    source_id: "demo:civic-care",
    source_uuid: "55555555-5555-4555-8555-555555555555",
    title: "Civic Care Starts Nearby",
    subtitle: "Local participation without shame or domination",
    summary:
      "A values-based introduction to small, nonpartisan actions that connect inward practice to public life.",
    content_status: "excerpt",
    file_type: "reading",
    layers: ["agency", "civic_engagement"],
    subjects: ["local government", "mutual care"],
    tags: ["agency", "civic", "community"],
    reading_minutes: 7,
    published: true,
    sort_order: 30,
    created_at: "2026-04-25T12:00:00Z",
    updated_at: "2026-04-25T12:00:00Z",
  },
];

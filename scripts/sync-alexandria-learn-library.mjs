#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const root = process.cwd();
const defaultManifestPath = path.join(root, "shared/content/alexandria-pow-shelf.json");
const defaultDBPath = path.join(os.homedir(), "Documents/Alexandria/library.db");

const validLayers = new Set([
  "self_regulation",
  "co_regulation",
  "community",
  "agency",
  "civic_engagement",
]);
const validStatuses = new Set(["metadata_only", "excerpt", "full_text"]);
const fullTextTypes = new Set(["markdown", "text"]);
const fullTextRoots = [
  "/Applications/Apps/research/",
  "/Applications/Apps/DharmaGit/",
  "/Applications/Apps/Piece of Whole/",
];

const layerSubjects = {
  self_regulation: ["Health & Wellness", "Breathwork", "Mindfulness", "MBSR", "Somatic", "Wellness", "Health", "Meditation"],
  co_regulation: ["Co-Regulation", "Relational Health", "Nervous System", "Meditation", "Wellness"],
  community: ["Community", "Group Practice", "Facilitation"],
  agency: ["Walter Russell", "Neville Goddard", "Personal Development", "Purpose", "Consciousness"],
  civic_engagement: ["Civic Education", "Democracy", "Community Organizing"],
};

function parseArgs(argv) {
  const args = {
    mode: "validate",
    manifestPath: defaultManifestPath,
    dbPath: process.env.ALEXANDRIA_DB_PATH ?? defaultDBPath,
  };

  for (let index = 2; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--validate") args.mode = "validate";
    else if (arg === "--sql") args.mode = "sql";
    else if (arg === "--json") args.mode = "json";
    else if (arg === "--candidates") args.mode = "candidates";
    else if (arg === "--manifest") args.manifestPath = path.resolve(argv[++index]);
    else if (arg === "--db") args.dbPath = expandHome(argv[++index]);
    else fail(`Unknown argument: ${arg}`);
  }

  args.dbPath = expandHome(args.dbPath);
  return args;
}

function expandHome(filePath) {
  if (filePath.startsWith("~/")) return path.join(os.homedir(), filePath.slice(2));
  return filePath;
}

function fail(message) {
  throw new Error(message);
}

function readJSON(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function sqliteJSON(dbPath, query) {
  const uri = `file:${dbPath}?mode=ro`;
  const output = execFileSync("sqlite3", ["-json", uri, query], { encoding: "utf8" });
  return output.trim() ? JSON.parse(output) : [];
}

function sqlList(values) {
  return values.map((value) => sqlString(value)).join(", ");
}

function sqlString(value) {
  if (value === null || value === undefined) return "NULL";
  return `'${String(value).replaceAll("'", "''")}'`;
}

function sqlArray(values) {
  if (!values || values.length === 0) return "ARRAY[]::text[]";
  return `ARRAY[${sqlList(values)}]::text[]`;
}

function sqlNumber(value) {
  return Number.isFinite(value) ? String(value) : "NULL";
}

function sqlBoolean(value) {
  return value ? "true" : "false";
}

function estimateReadingMinutes(text) {
  const words = text.trim().split(/\s+/).filter(Boolean).length;
  return Math.max(1, Math.ceil(words / 220));
}

function unique(values) {
  return [...new Set(values.filter(Boolean))];
}

function sanitizeBody(body) {
  return body
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .trim();
}

function assertNoClientLeaks(resource) {
  const serialized = JSON.stringify(resource);
  const forbidden = [
    "/Users/rorystone",
    "/Applications/Apps",
    "library.traddiff.com",
    "Basic Auth",
    "SUPABASE_SERVICE_ROLE_KEY",
    "SUPABASE_ACCESS_TOKEN",
  ];
  for (const needle of forbidden) {
    if (serialized.includes(needle)) fail(`${resource.source_id} exposes forbidden client text: ${needle}`);
  }
}

function allowedFullTextPath(filePath) {
  return fullTextRoots.some((rootPath) => filePath.startsWith(rootPath));
}

function validateManifest(manifest) {
  if (!Array.isArray(manifest.resources) || manifest.resources.length === 0) {
    fail("Manifest must contain at least one resource");
  }

  const sourceIDs = new Set();
  const sourceUUIDs = new Set();

  for (const resource of manifest.resources) {
    if (!resource.source_id?.startsWith("alexandria:")) fail(`Invalid source_id: ${resource.source_id}`);
    if (!/^[0-9a-f-]{36}$/i.test(resource.source_uuid ?? "")) fail(`${resource.source_id} has invalid source_uuid`);
    if (!validStatuses.has(resource.content_status)) fail(`${resource.source_id} has invalid content_status`);
    if (!Array.isArray(resource.layers) || resource.layers.length === 0) fail(`${resource.source_id} needs at least one layer`);
    if (resource.layers.some((layer) => !validLayers.has(layer))) fail(`${resource.source_id} has an invalid layer`);
    if (typeof resource.published !== "boolean") fail(`${resource.source_id} must set published`);
    if (sourceIDs.has(resource.source_id)) fail(`Duplicate source_id: ${resource.source_id}`);
    if (sourceUUIDs.has(resource.source_uuid)) fail(`Duplicate source_uuid: ${resource.source_uuid}`);
    sourceIDs.add(resource.source_id);
    sourceUUIDs.add(resource.source_uuid);
  }
}

function loadEntries(dbPath, manifest) {
  const quotedUUIDs = manifest.resources.map((resource) => sqlString(resource.source_uuid.toUpperCase())).join(", ");
  const rows = sqliteJSON(
    dbPath,
    `select
       e.id,
       upper(e.uuid) as uuid,
       e.title,
       e.file_type,
       e.path,
       e.excerpt,
       group_concat(distinct s.name) as subjects,
       group_concat(distinct t.name) as tags
     from entries e
     left join entry_subjects es on e.id = es.entry_id
     left join subjects s on s.id = es.subject_id
     left join entry_tags et on e.id = et.entry_id
     left join tags t on t.id = et.tag_id
     where upper(e.uuid) in (${quotedUUIDs})
     group by e.id`
  );
  return new Map(rows.map((row) => [row.uuid, row]));
}

function buildResources({ manifest, entriesByUUID }) {
  return manifest.resources.map((item) => {
    const entry = entriesByUUID.get(item.source_uuid.toUpperCase());
    if (!entry) fail(`${item.source_id} source_uuid not found in Alexandria`);

    if (item.content_status === "full_text") {
      if (!fullTextTypes.has(entry.file_type)) fail(`${item.source_id} full_text requires markdown/text, found ${entry.file_type}`);
      if (!allowedFullTextPath(entry.path)) fail(`${item.source_id} full_text path is not in an approved source root`);
      if (!fs.existsSync(entry.path)) fail(`${item.source_id} source file is missing: ${entry.path}`);
    }

    const bodyMarkdown = item.content_status === "full_text"
      ? sanitizeBody(fs.readFileSync(entry.path, "utf8"))
      : null;
    if (item.content_status === "full_text" && !bodyMarkdown) fail(`${item.source_id} full_text source is empty`);

    const subjects = unique([
      ...(item.subjects ?? []),
      ...(entry.subjects ? entry.subjects.split(",") : []),
    ]);
    const tags = unique([
      ...(item.tags ?? []),
      ...(entry.tags ? entry.tags.split(",") : []),
    ]);
    const summary = item.summary || entry.excerpt || item.subtitle || item.title;
    const readingMinutes = item.reading_minutes ?? estimateReadingMinutes(bodyMarkdown ?? summary);

    const resource = {
      source_kind: "alexandria",
      source_id: item.source_id,
      source_uuid: item.source_uuid.toUpperCase(),
      title: item.title,
      subtitle: item.subtitle ?? null,
      summary,
      body_markdown: bodyMarkdown,
      content_status: item.content_status,
      file_type: entry.file_type,
      layers: item.layers,
      subjects,
      tags,
      reading_minutes: readingMinutes,
      reflection_prompt: item.reflection_prompt ?? null,
      published: item.published,
      sort_order: item.sort_order ?? null,
    };

    assertNoClientLeaks(resource);
    return resource;
  });
}

function toSQL(resources) {
  const rows = resources.map((resource) => `  (${[
    sqlString(resource.source_kind),
    sqlString(resource.source_id),
    `${sqlString(resource.source_uuid)}::uuid`,
    sqlString(resource.title),
    sqlString(resource.subtitle),
    sqlString(resource.summary),
    sqlString(resource.body_markdown),
    sqlString(resource.content_status),
    sqlString(resource.file_type),
    sqlArray(resource.layers),
    sqlArray(resource.subjects),
    sqlArray(resource.tags),
    sqlNumber(resource.reading_minutes),
    sqlString(resource.reflection_prompt),
    sqlBoolean(resource.published),
    sqlNumber(resource.sort_order),
  ].join(", ")})`);

  return `INSERT INTO learning_resources (
  source_kind,
  source_id,
  source_uuid,
  title,
  subtitle,
  summary,
  body_markdown,
  content_status,
  file_type,
  layers,
  subjects,
  tags,
  reading_minutes,
  reflection_prompt,
  published,
  sort_order
) VALUES
${rows.join(",\n")}
ON CONFLICT (source_id) DO UPDATE SET
  source_kind = EXCLUDED.source_kind,
  source_uuid = EXCLUDED.source_uuid,
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  summary = EXCLUDED.summary,
  body_markdown = EXCLUDED.body_markdown,
  content_status = EXCLUDED.content_status,
  file_type = EXCLUDED.file_type,
  layers = EXCLUDED.layers,
  subjects = EXCLUDED.subjects,
  tags = EXCLUDED.tags,
  reading_minutes = EXCLUDED.reading_minutes,
  reflection_prompt = EXCLUDED.reflection_prompt,
  published = EXCLUDED.published,
  sort_order = EXCLUDED.sort_order,
  updated_at = now();`;
}

function listCandidates(dbPath) {
  const allSubjects = unique(Object.values(layerSubjects).flat());
  const rows = sqliteJSON(
    dbPath,
    `select
       upper(e.uuid) as source_uuid,
       e.title,
       e.file_type,
       e.source_project,
       substr(replace(replace(coalesce(e.excerpt, ''), char(10), ' '), char(13), ' '), 1, 280) as excerpt,
       group_concat(distinct s.name) as subjects
     from entries e
     join entry_subjects es on e.id = es.entry_id
     join subjects s on s.id = es.subject_id
     where s.name in (${sqlList(allSubjects)})
       and e.file_type in ('markdown', 'text', 'pdf', 'html')
       and e.title not like 'Screenshot:%'
       and e.path not like '%/notes/%'
     group by e.id
     order by e.modified_date desc
     limit 100`
  );

  return rows.map((row) => ({
    ...row,
    suggested_layers: Object.entries(layerSubjects)
      .filter(([, subjects]) => (row.subjects ?? "").split(",").some((subject) => subjects.includes(subject)))
      .map(([layer]) => layer),
  }));
}

const args = parseArgs(process.argv);
try {
  if (!fs.existsSync(args.manifestPath)) fail(`Missing manifest: ${args.manifestPath}`);
  if (!fs.existsSync(args.dbPath)) fail(`Missing Alexandria DB: ${args.dbPath}`);

  if (args.mode === "candidates") {
    console.log(JSON.stringify(listCandidates(args.dbPath), null, 2));
    process.exit(0);
  }

  const manifest = readJSON(args.manifestPath);
  validateManifest(manifest);
  const entriesByUUID = loadEntries(args.dbPath, manifest);
  const resources = buildResources({ manifest, entriesByUUID });

  if (args.mode === "sql") {
    console.log(toSQL(resources));
  } else if (args.mode === "json") {
    console.log(JSON.stringify(resources, null, 2));
  } else {
    const fullTextCount = resources.filter((resource) => resource.content_status === "full_text").length;
    console.log(`Alexandria Learn validation passed: ${resources.length} reviewed resources, ${fullTextCount} full-text imports.`);
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
}

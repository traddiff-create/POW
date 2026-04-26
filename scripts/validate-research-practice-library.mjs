#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const migrationPath = path.join(root, "supabase/migrations/20260425000002_research_practice_library.sql");
const techniquesPath = path.join(root, "shared/content/meditation-techniques.json");
const audioPath = path.join(root, "shared/content/audio-library.json");
const bundledAudioRoot = path.join(root, "ios/APieceOfWhole/APieceOfWhole/Resources/Audio");

const layerMap = new Map([
  [1, "self_regulation"],
  [2, "co_regulation"],
  [3, "community"],
  [4, "agency"],
  [5, "civic_engagement"],
]);
const advancedAudioTags = new Set(["advanced", "non_dual", "spiritual_practice", "sound_current"]);

function readJSON(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function fail(message) {
  throw new Error(message);
}

const techniques = readJSON(techniquesPath).techniques;
const audio = readJSON(audioPath);
const migration = fs.readFileSync(migrationPath, "utf8");
const audioFiles = [
  ...audio.learn.files,
  ...audio.sleep.files,
  ...audio.meditation_ambient.files,
  ...audio.session_tones.files,
];

const sourceIDs = [
  ...techniques.map((item) => `technique:${item.id}`),
  ...audio.learn.files.map((item) => `audio:${item.id}`),
];

if (new Set(sourceIDs).size !== sourceIDs.length) {
  fail("Expected research source IDs to be unique");
}

for (const sourceID of sourceIDs) {
  if (!migration.includes(`'${sourceID}'`)) {
    fail(`Migration is missing ${sourceID}`);
  }
}

for (const item of techniques) {
  const layers = item.layers.map((layer) => layerMap.get(layer)).filter(Boolean);
  if (layers.length === 0) fail(`${item.id} has no valid layer mapping`);

  const shouldPublish = ["strong", "moderate"].includes(item.evidence_level);
  const sourceID = `technique:${item.id}`;
  const publishedNeedle = shouldPublish
    ? `true, '${sourceID}', 'meditation_technique'`
    : `false, '${sourceID}', 'meditation_technique'`;
  if (!migration.includes(publishedNeedle)) {
    fail(`${sourceID} has the wrong published gate`);
  }
}

for (const item of audio.learn.files) {
  const isAdvanced = item.tags?.some((tag) => advancedAudioTags.has(tag)) ?? false;
  const sourceID = `audio:${item.id}`;
  const publishedNeedle = isAdvanced
    ? `false, '${sourceID}', 'audio_library'`
    : `true, '${sourceID}', 'audio_library'`;
  if (!migration.includes(publishedNeedle)) {
    fail(`${sourceID} has the wrong advanced gate`);
  }
}

for (const item of audioFiles) {
  const bundledPath = path.join(bundledAudioRoot, item.path);
  if (!fs.existsSync(bundledPath)) {
    fail(`Missing bundled audio: ${item.path}`);
  }
}

const bundledFiles = [];
function walk(directory) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      walk(entryPath);
    } else if (entry.name.endsWith(".mp3") || entry.name.endsWith(".m4a")) {
      bundledFiles.push(path.relative(bundledAudioRoot, entryPath));
    }
  }
}
walk(bundledAudioRoot);

if (bundledFiles.length !== audioFiles.length) {
  fail(`Expected ${audioFiles.length} bundled audio files, found ${bundledFiles.length}`);
}

console.log(`Research practice library validation passed: ${sourceIDs.length} seeded rows, ${audioFiles.length} bundled audio files.`);

import { redirect, notFound } from "next/navigation";
import Link from "next/link";
import { createClient, createServiceClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";
import { AudioPlayer } from "./AudioPlayer";

export default async function PracticePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: practice } = await supabase
    .from("practices")
    .select("id, title, subtitle, category, duration_minutes, week_number, has_audio, audio_path, audio_source, body_text, source_kind, evidence_level, risk_level, risk_note")
    .eq("id", id)
    .single();

  if (!practice) notFound();

  let audioUrl: string | null = null;
  if (practice.has_audio && practice.audio_path && practice.audio_source === "supabase_storage") {
    const serviceClient = await createServiceClient();
    const { data } = await serviceClient.storage
      .from("audio")
      .createSignedUrl(practice.audio_path, 3600);
    audioUrl = data?.signedUrl ?? null;
  } else if (practice.has_audio && practice.audio_path && practice.audio_source === "remote_url") {
    audioUrl = practice.audio_path;
  }

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-6">
        <Link href="/practices" className="text-sm text-foreground/40 hover:text-foreground/70">
          ← Practices
        </Link>

        <div>
          {practice.week_number && (
            <p className="text-xs text-sage uppercase tracking-wide mb-2">Week {practice.week_number}</p>
          )}
          <h1 className="text-2xl leading-snug">
            {practice.title}
          </h1>
          {practice.subtitle && (
            <p className="text-sm text-foreground/50 mt-1">{practice.subtitle}</p>
          )}
          {practice.duration_minutes && (
            <p className="text-sm text-foreground/50 mt-1">{practice.duration_minutes} minutes</p>
          )}
          <div className="flex flex-wrap gap-2 mt-3 text-xs text-foreground/50">
            {practice.category && <span>{labelize(practice.category)}</span>}
            {practice.source_kind && <span>{labelize(practice.source_kind)}</span>}
            {practice.evidence_level && <span>Evidence: {labelize(practice.evidence_level)}</span>}
            {practice.risk_level && <span>Risk: {labelize(practice.risk_level)}</span>}
          </div>
        </div>

        {audioUrl && <AudioPlayer signedUrl={audioUrl} />}
        {!audioUrl && practice.has_audio && practice.audio_source === "ios_bundle" && (
          <p className="border border-foreground/10 p-4 text-sm text-foreground/50">
            Audio for this practice is bundled in the iOS app.
          </p>
        )}

        {practice.body_text && (
          <div className="text-foreground/80 leading-relaxed whitespace-pre-wrap text-sm">
            {practice.body_text}
          </div>
        )}

        {practice.risk_note && (
          <p className="border border-foreground/10 p-4 text-sm text-foreground/50">
            {practice.risk_note}
          </p>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

function labelize(value: string) {
  return value.replaceAll("_", " ").replace(/\b\w/g, (char) => char.toUpperCase());
}

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
    .select("id, title, category, duration_minutes, week_number, has_audio, audio_path, body_text")
    .eq("id", id)
    .single();

  if (!practice) notFound();

  let audioUrl: string | null = null;
  if (practice.has_audio && practice.audio_path) {
    const serviceClient = await createServiceClient();
    const { data } = await serviceClient.storage
      .from("audio")
      .createSignedUrl(practice.audio_path, 3600);
    audioUrl = data?.signedUrl ?? null;
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
          {practice.duration_minutes && (
            <p className="text-sm text-foreground/50 mt-1">{practice.duration_minutes} minutes</p>
          )}
        </div>

        {audioUrl && <AudioPlayer signedUrl={audioUrl} />}

        {practice.body_text && (
          <div className="text-foreground/80 leading-relaxed whitespace-pre-wrap text-sm">
            {practice.body_text}
          </div>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

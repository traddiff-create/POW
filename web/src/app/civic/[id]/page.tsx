import { redirect, notFound } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { CrisisBanner } from "@/components/CrisisBanner";

export default async function CivicLessonPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  const { data: lesson } = await supabase
    .from("civic_lessons")
    .select("id, title, category, estimated_minutes, body_text, reflection_prompt")
    .eq("id", id)
    .single();

  if (!lesson) notFound();

  return (
    <div className="flex flex-col min-h-screen">
      <main className="flex-1 px-6 py-12 max-w-2xl mx-auto w-full space-y-6">
        <Link href="/civic" className="text-sm text-foreground/40 hover:text-foreground/70">
          ← Civic
        </Link>

        <div>
          {lesson.category && (
            <p className="text-xs text-foreground/40 uppercase tracking-wide mb-2">{lesson.category}</p>
          )}
          <h1 className="text-2xl leading-snug">
            {lesson.title}
          </h1>
          {lesson.estimated_minutes && (
            <p className="text-sm text-foreground/50 mt-1">{lesson.estimated_minutes} minutes</p>
          )}
        </div>

        {lesson.body_text && (
          <div className="text-foreground/80 leading-relaxed whitespace-pre-wrap text-sm space-y-4">
            {lesson.body_text}
          </div>
        )}

        {lesson.reflection_prompt && (
          <div className="border-l-2 border-stone pl-4 space-y-2">
            <p className="text-xs text-foreground/40 uppercase tracking-wide">Reflection</p>
            <p className="text-foreground/70 italic text-sm">{lesson.reflection_prompt}</p>
            <Link href="/journal/new" className="text-xs text-sage underline block mt-2">
              Journal about this →
            </Link>
          </div>
        )}
      </main>
      <CrisisBanner />
    </div>
  );
}

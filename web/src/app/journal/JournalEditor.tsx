"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

interface Props {
  entryId: string | null;
  initialTitle: string;
  initialBody: string;
}

export function JournalEditor({ entryId, initialTitle, initialBody }: Props) {
  const [title, setTitle] = useState(initialTitle);
  const [body, setBody] = useState(initialBody);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const router = useRouter();

  async function save() {
    if (!body.trim()) return;
    setSaving(true);
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) { router.push("/auth/login"); return; }

    if (entryId) {
      await supabase.from("journal_entries")
        .update({ title: title.trim() || null, body: body.trim(), updated_at: new Date().toISOString() })
        .eq("id", entryId);
    } else {
      const { data } = await supabase.from("journal_entries")
        .insert({ user_id: user.id, title: title.trim() || null, body: body.trim() })
        .select("id")
        .single();
      if (data) { router.push(`/journal/${data.id}`); return; }
    }
    setSaving(false);
  }

  async function deleteEntry() {
    if (!entryId || !confirm("Delete this entry? This can't be undone.")) return;
    setDeleting(true);
    const supabase = createClient();
    await supabase.from("journal_entries").delete().eq("id", entryId);
    router.push("/journal");
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-4 mb-2">
        <button
          onClick={() => router.back()}
          className="text-sm text-foreground/40 hover:text-foreground/70 transition-colors"
        >
          ← Back
        </button>
        <div className="flex gap-3">
          {entryId && (
            <button
              onClick={deleteEntry}
              disabled={deleting}
              className="text-sm text-error hover:opacity-70 transition-opacity"
            >
              {deleting ? "Deleting…" : "Delete"}
            </button>
          )}
          <button
            onClick={save}
            disabled={saving || !body.trim()}
            className="text-sm bg-foreground text-background px-4 py-2 hover:opacity-80 transition-opacity disabled:opacity-50"
          >
            {saving ? "Saving…" : "Save"}
          </button>
        </div>
      </div>

      <input
        type="text"
        placeholder="Title (optional)"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        className="w-full text-xl font-serif border-none outline-none bg-transparent placeholder-foreground/30"
      />

      <textarea
        placeholder="What's present for you?"
        value={body}
        onChange={(e) => setBody(e.target.value)}
        rows={20}
        className="w-full border-none outline-none bg-transparent resize-none text-foreground/80 leading-relaxed placeholder-foreground/30"
      />
    </div>
  );
}

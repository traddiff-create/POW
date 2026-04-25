"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

interface Props {
  initialName: string;
  userId: string;
}

export function SettingsForm({ initialName, userId }: Props) {
  const [displayName, setDisplayName] = useState(initialName);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const router = useRouter();

  async function saveName(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    const supabase = createClient();
    await supabase.from("user_profiles").update({ display_name: displayName.trim() }).eq("id", userId);
    setSaved(true);
    setSaving(false);
    setTimeout(() => setSaved(false), 2000);
  }

  async function signOut() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/auth/login");
  }

  async function deleteAccount() {
    const supabase = createClient();
    await supabase.from("user_profiles").update({ display_name: "[deleted]" }).eq("id", userId);
    await supabase.auth.signOut();
    router.push("/");
  }

  return (
    <div className="space-y-10">
      <form onSubmit={saveName} className="space-y-4">
        <h2 className="font-medium">Display name</h2>
        <div>
          <input
            type="text"
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            required
            maxLength={60}
            className="w-full border border-foreground/20 px-4 py-3 bg-white focus:outline-none focus:border-sage"
          />
        </div>
        <button
          type="submit"
          disabled={saving || !displayName.trim()}
          className="bg-foreground text-background px-5 py-2.5 text-sm hover:opacity-80 transition-opacity disabled:opacity-50"
        >
          {saving ? "Saving…" : saved ? "Saved ✓" : "Save"}
        </button>
      </form>

      <div className="space-y-3 border-t border-foreground/10 pt-8">
        <h2 className="font-medium">Account</h2>
        <button
          onClick={signOut}
          className="block text-sm text-foreground/60 underline hover:text-foreground transition-colors"
        >
          Sign out
        </button>
      </div>

      <div className="space-y-3 border-t border-foreground/10 pt-8">
        <h2 className="font-medium text-error">Danger zone</h2>
        {!confirmDelete ? (
          <button
            onClick={() => setConfirmDelete(true)}
            className="text-sm text-error underline"
          >
            Delete my account
          </button>
        ) : (
          <div className="space-y-3">
            <p className="text-sm text-foreground/70">
              This will sign you out and anonymize your data. Journal entries and check-ins will be removed.
              This cannot be undone.
            </p>
            <div className="flex gap-3">
              <button
                onClick={deleteAccount}
                className="text-sm bg-error text-white px-4 py-2 hover:opacity-80 transition-opacity"
              >
                Yes, delete my account
              </button>
              <button
                onClick={() => setConfirmDelete(false)}
                className="text-sm text-foreground/60 underline"
              >
                Cancel
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

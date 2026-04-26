import { createBrowserClient } from "@supabase/ssr";
import { requirePublicSupabaseConfig } from "@/lib/supabase/config";
import type { Database } from "@/types/database";

export function createClient() {
  const config = requirePublicSupabaseConfig();

  return createBrowserClient<Database>(
    config.url,
    config.anonKey
  );
}

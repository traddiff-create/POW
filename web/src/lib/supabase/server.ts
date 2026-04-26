import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import {
  requirePublicSupabaseConfig,
  requireServiceSupabaseConfig,
} from "@/lib/supabase/config";
import type { Database } from "@/types/database";

export async function createClient() {
  const cookieStore = await cookies();
  const config = requirePublicSupabaseConfig();

  return createServerClient<Database>(
    config.url,
    config.anonKey,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {}
        },
      },
    }
  );
}

export async function createServiceClient() {
  const cookieStore = await cookies();
  const config = requireServiceSupabaseConfig();

  return createServerClient<Database>(
    config.url,
    config.serviceRoleKey,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {}
        },
      },
    }
  );
}

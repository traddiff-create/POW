type PublicSupabaseConfig = {
  url: string;
  anonKey: string;
};

type ServiceSupabaseConfig = PublicSupabaseConfig & {
  serviceRoleKey: string;
};

function present(value: string | undefined) {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

export function getPublicSupabaseConfig(): PublicSupabaseConfig | null {
  const url = present(process.env.NEXT_PUBLIC_SUPABASE_URL);
  const anonKey = present(process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

  if (!url || !anonKey) return null;

  return { url, anonKey };
}

export function hasPublicSupabaseConfig() {
  return getPublicSupabaseConfig() !== null;
}

export function requirePublicSupabaseConfig(): PublicSupabaseConfig {
  const config = getPublicSupabaseConfig();
  if (!config) {
    throw new Error("Supabase public configuration is unavailable.");
  }
  return config;
}

export function getServiceSupabaseConfig(): ServiceSupabaseConfig | null {
  const publicConfig = getPublicSupabaseConfig();
  const serviceRoleKey = present(process.env.SUPABASE_SERVICE_ROLE_KEY);

  if (!publicConfig || !serviceRoleKey) return null;

  return { ...publicConfig, serviceRoleKey };
}

export function hasServiceSupabaseConfig() {
  return getServiceSupabaseConfig() !== null;
}

export function requireServiceSupabaseConfig(): ServiceSupabaseConfig {
  const config = getServiceSupabaseConfig();
  if (!config) {
    throw new Error("Supabase service configuration is unavailable.");
  }
  return config;
}

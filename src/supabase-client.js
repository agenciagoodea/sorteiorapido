import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const getEnv = (key) => {
  if (typeof window !== 'undefined' && window[key]) return window[key];
  if (typeof process !== 'undefined' && process.env && process.env[key]) return process.env[key];
  if (typeof import.meta !== 'undefined' && import.meta.env && import.meta.env[key]) return import.meta.env[key];
  return null;
};

export const SUPABASE_URL = getEnv('VITE_SUPABASE_URL');
export const SUPABASE_ANON_KEY = getEnv('VITE_SUPABASE_ANON_KEY');

export const isDefaultKey = (url, key) =>
  !url || url.includes('your-project') || !key || key.includes('your-anon-key');

export const getSupabaseClient = () => {
  if (!globalThis.__supabaseClientSingleton) {
    globalThis.__supabaseClientSingleton = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  }
  return globalThis.__supabaseClientSingleton;
};

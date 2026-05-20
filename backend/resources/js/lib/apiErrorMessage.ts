import { isAxiosError } from 'axios';

/** Laravel validation yoki JSend `message` dan qisqa xabar olish */
export function getApiErrorMessage(error: unknown, fallback: string): string {
  if (isAxiosError(error)) {
    const d = error.response?.data as
      | { message?: string | string[]; errors?: Record<string, string[] | string> }
      | undefined;
    if (d?.message) {
      if (Array.isArray(d.message)) return d.message.join(' ');
      if (typeof d.message === 'string') return d.message;
    }
    if (d?.errors && typeof d.errors === 'object') {
      for (const v of Object.values(d.errors)) {
        if (Array.isArray(v) && v[0]) return String(v[0]);
        if (typeof v === 'string') return v;
      }
    }
    if (error.message) return error.message;
  }
  if (error instanceof Error) return error.message;
  return fallback;
}

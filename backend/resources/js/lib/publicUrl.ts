/** Laravel `storage/` (public disk) fayl yo‘llari uchun to‘liq URL */
export function getPublicStorageUrl(relativePath: string | null | undefined): string {
  if (!relativePath) return '';
  if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) return relativePath;
  const path = relativePath.replace(/^\/+/, '');

  const storageOrigin = (import.meta.env.VITE_STORAGE_ORIGIN as string | undefined)?.replace(/\/+$/, '');
  if (storageOrigin) {
    return `${storageOrigin}/storage/${path}`;
  }

  const apiUrl = import.meta.env.VITE_API_URL as string | undefined;
  if (apiUrl) {
    const origin = apiUrl.replace(/\/api\/v1\/?$/i, '').replace(/\/+$/, '');
    return `${origin}/storage/${path}`;
  }

  // Build `api/public` orqali ochilganda — `/storage` shu hostda (8081, 8000 va hokazo)
  if (typeof window !== 'undefined') {
    return `${window.location.origin}/storage/${path}`;
  }

  return `/storage/${path}`;
}

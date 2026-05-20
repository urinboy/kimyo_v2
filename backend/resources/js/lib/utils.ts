import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/** Switch track — nofaol holat (light: kontrastli kulrang; dark: shaffof) */
export const switchInactiveTrackCn =
  'border border-neutral-400/60 bg-neutral-200 shadow-[inset_0_1px_2px_rgba(0,0,0,0.07)] dark:border-white/15 dark:bg-white/10 dark:shadow-none';

/** Bir xil nomli maktablar (turli id) selectda chalkashmasligi uchun qo'shimcha qism. */
export function schoolsWithSelectLabel<
  T extends { id: number; name: string; region?: string | null; city?: string | null },
>(schools: T[], displayName: (s: T) => string = s => s.name): Array<T & { selectLabel: string }> {
  const list = [...schools];
  const keyOf = (label: string) => label.trim().toLowerCase();
  const counts = new Map<string, number>();
  for (const s of list) {
    const k = keyOf(displayName(s));
    counts.set(k, (counts.get(k) ?? 0) + 1);
  }
  return list.map(s => {
    const base = displayName(s);
    const dup = (counts.get(keyOf(base)) ?? 0) > 1;
    const place = [s.region, s.city].filter(Boolean).join(', ');
    const selectLabel = dup ? (place ? `${base} (${place})` : `${base} (ID ${s.id})`) : base;
    return { ...s, selectLabel };
  });
}

/** Maktab kartochkalarida / jadvalda: bazadagi aniq yozuvni ajratish (id + viloyat/tuman). */
export function schoolLocationSubtitle(s: {
  id: number;
  region?: string | null;
  city?: string | null;
}): string {
  const place = [s.region, s.city].filter(Boolean).join(', ');
  return place ? `ID ${s.id} · ${place}` : `ID ${s.id}`;
}

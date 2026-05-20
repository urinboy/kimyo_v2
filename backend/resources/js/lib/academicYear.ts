/**
 * O‘quv yili boshlanishi: 1-sentabrdan (shu qoida ilova testlari / topshiriqlar bilan mos).
 * Masalan, 2026-yil 7-may → hali 2025-2026 o‘quv yili.
 */
export function academicYearStartFromDate(d: Date): number {
  const y = d.getFullYear();
  const m = d.getMonth() + 1;
  const day = d.getDate();
  if (m > 9 || (m === 9 && day >= 1)) {
    return y;
  }
  return y - 1;
}

export function getCurrentAcademicYearLabel(referenceDate = new Date()): string {
  const start = academicYearStartFromDate(referenceDate);
  return `${start}-${start + 1}`;
}

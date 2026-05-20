const UNICODE_SUB = '₀₁₂₃₄₅₆₇₈₉';
const SUB_TO_DIGIT: Record<string, string> = Object.fromEntries(
  [...UNICODE_SUB].map((u, i) => [u, String(i)]),
);

/**
 * Kiritishda bo‘shliqlar va yunikod subscriptlarni (₀…₉) oddiy raqamga aylantiradi.
 */
export function normalizeChemicalString(raw: string): string {
  const s = raw.replace(/\s+/g, '');
  let out = '';
  for (let i = 0; i < s.length; i++) {
    const c = s[i]!;
    out += SUB_TO_DIGIT[c] ?? c;
  }
  return out;
}

function isDigit(c: string | undefined): boolean {
  return c !== undefined && c >= '0' && c <= '9';
}

function isSubscriptTrigger(before: string | undefined): boolean {
  if (before === undefined) return false;
  if (/[A-Za-z]/.test(before)) return true;
  if (before === ')' || before === ']') return true;
  return false;
}

export type ChemPart = string | { sub: string };

/**
 * H2O, Ca(OH)2, (NH4)2CO3, 2H2O, C6H12O6 — koeffitsient va indekslarni farqlaydi.
 */
export function formatChemicalFormulaToParts(formula: string): ChemPart[] {
  const s = normalizeChemicalString(formula);
  if (!s) return [];

  const out: ChemPart[] = [];
  let i = 0;

  if (isDigit(s[0])) {
    let j = 0;
    while (j < s.length && isDigit(s[j])) j++;
    out.push(s.slice(0, j));
    i = j;
  }

  while (i < s.length) {
    if (isDigit(s[i])) {
      const start = i;
      let j = i;
      while (j < s.length && isDigit(s[j])) j++;
      const run = s.slice(start, j);
      const before = start > 0 ? s[start - 1] : undefined;
      if (isSubscriptTrigger(before)) {
        out.push({ sub: run });
      } else {
        out.push(run);
      }
      i = j;
    } else {
      out.push(s[i]!);
      i += 1;
    }
  }

  return out;
}

export function chemicalFormulaA11yLabel(formula: string): string {
  return normalizeChemicalString(formula);
}

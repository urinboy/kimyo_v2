/**
 * i18n / til kodi (uz, ru, en, kaa) → flagcdn.com 2 xonali mamlakat.
 * @see https://flagpedia.net/download/api
 */
const LANG_TO_COUNTRY: Record<string, string> = {
  uz: 'uz',
  ru: 'ru',
  en: 'gb',
  kaa: 'uz',
};

export function langCodeToFlagCdn(isoOrLang: string): string {
  const c = isoOrLang.split('-')[0]!.toLowerCase();
  const country = LANG_TO_COUNTRY[c] || 'un';
  return `https://flagcdn.com/w20/${country}.png`;
}

/** Emoji (Windows/emoji shrifti bo‘lmasa ham) zaxira */
const EMOJI: Record<string, string> = {
  uz: '🇺🇿',
  ru: '🇷🇺',
  en: '🇬🇧',
  kaa: '🇺🇿',
};

export function getFlagEmojiForLangCode(isoOrLang: string): string {
  const c = isoOrLang.split('-')[0]!.toLowerCase();
  return EMOJI[c] ?? '🌐';
}

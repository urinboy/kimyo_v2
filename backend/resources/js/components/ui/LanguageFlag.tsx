import { useState } from 'react';
import { cn } from '@/lib/utils';
import { getFlagEmojiForLangCode, langCodeToFlagCdn } from '@/lib/languageFlags';

type LanguageFlagProps = {
  code: string;
  className?: string;
  title?: string;
  /** Balandlik (rem emas) */
  size?: 'sm' | 'md';
};

/**
 * Bayroq: flagcdn (barqaror) + xato/sayt-oflayn uchun emoji.
 */
export function LanguageFlag({ code, className, title, size = 'md' }: LanguageFlagProps) {
  const [useEmoji, setUseEmoji] = useState(false);
  const base = code.includes('-') ? code.split('-')[0]! : code;
  const src = langCodeToFlagCdn(base);
  const emoji = getFlagEmojiForLangCode(base);
  const h = size === 'sm' ? 14 : 18;
  const w = size === 'sm' ? 20 : 26;

  if (useEmoji || !src) {
    return (
      <span
        className={cn('flag-emoji inline-flex shrink-0 select-none items-center justify-center', className)}
        style={{ fontSize: size === 'sm' ? '0.9rem' : '1.1rem' }}
        title={title}
        role="img"
        aria-hidden={!title}
      >
        {emoji}
      </span>
    );
  }

  return (
    <img
      src={src}
      srcSet={`${src.replace('w20', 'w40')} 2x`}
      width={w}
      height={h}
      alt=""
      title={title}
      className={cn(
        'rounded-[3px] object-cover shadow-sm ring-1 ring-black/10 dark:ring-white/10',
        size === 'sm' ? 'h-3.5 w-5' : 'h-[18px] w-[26px]',
        className,
      )}
      loading="lazy"
      decoding="async"
      onError={() => setUseEmoji(true)}
    />
  );
}

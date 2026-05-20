import { useState, useRef, useEffect } from 'react';
import { Check, Languages } from 'lucide-react';
import { cn } from '@/lib/utils';
import { LanguageFlag } from './LanguageFlag';

export interface GlassSelectOption {
  value: string;
  label: string;
}

interface GlassSelectProps {
  options: GlassSelectOption[];
  value: string;
  onChange: (value: string) => void;
  className?: string;
  /** Tashqi konteyner (masalan Headerdagi tugmalar bilan bir xil balandlik) */
  triggerClassName?: string;
  /** Tanlangan/variant yo‘q bo‘lsa — Languages ikonkasi (bayroq o‘rniga) */
  showDefaultLangIcon?: boolean;
}

export const GlassSelect = ({ options, value, onChange, className, triggerClassName, showDefaultLangIcon = true }: GlassSelectProps) => {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  const code = value?.includes?.('-') ? value.split('-')[0]! : (value || '');
  const selectedOption = options.find((opt) => opt.value === code) ?? options.find((opt) => opt.value === value);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div className={cn('relative min-w-[150px] max-w-[220px]', className)} ref={containerRef}>
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className={cn(
          // Header ikonkа tugmalari: p-3 + w-5 ikon ≈ 44px; rounded-2xl glass — bir xil ko‘rinish
          'flex h-11 w-full items-center justify-start gap-2.5 rounded-2xl px-3 text-left text-app-primary glass transition-all duration-300 hover:bg-black/5 dark:hover:bg-white/10',
          triggerClassName,
        )}
        aria-expanded={isOpen}
        aria-haspopup="listbox"
      >
        {showDefaultLangIcon ? (
          selectedOption ? (
            <LanguageFlag code={selectedOption.value} size="md" className="shrink-0" />
          ) : (
            <Languages className="h-4 w-4 shrink-0 text-purple-500 dark:text-purple-400" aria-hidden />
          )
        ) : null}
        <span className="min-w-0 flex-1 truncate text-sm font-medium">{selectedOption?.label}</span>
      </button>

      {isOpen && (
        <div className="absolute top-full right-0 z-[210] mt-2 w-full min-w-[180px] overflow-hidden rounded-2xl glass animate-in fade-in slide-in-from-top-2 duration-200">
          {options.map((option) => (
            <button
              key={option.value}
              type="button"
              onClick={() => {
                onChange(option.value);
                setIsOpen(false);
              }}
              className={cn(
                'flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm transition-colors hover:bg-black/5 dark:hover:bg-white/10 text-app-primary',
                option.value === code && 'bg-black/5 dark:bg-white/5 text-purple-600 dark:text-purple-400',
              )}
            >
              <span className="flex min-w-0 items-center gap-2.5">
                <LanguageFlag code={option.value} size="sm" className="shrink-0" />
                <span className="truncate">{option.label}</span>
              </span>
              {option.value === code && <Check className="h-4 w-4 shrink-0" />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
};

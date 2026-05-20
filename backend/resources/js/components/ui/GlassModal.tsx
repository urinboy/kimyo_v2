import { createPortal } from 'react-dom';
import { cn } from '@/lib/utils';
import { GlassCard } from './GlassCard';
import { X } from 'lucide-react';

interface GlassModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  className?: string;
  /**
   * true: kartochka flex ustuni; pastki qism `flex-1 min-h-0` — ichki scroll ishlashi uchun zanjir.
   * Katta modallar (masalan laboratoriya resurslari) uchun ishlating.
   */
  flexBody?: boolean;
}

export const GlassModal = ({
  isOpen,
  onClose,
  title,
  children,
  className,
  flexBody = false,
}: GlassModalProps) => {
  if (!isOpen) return null;

  /* body → global z-index; main (z-10) ichida bo‘lsa sidebar (z-20) modaldan yuqorida qolmasligi uchun */
  return createPortal(
    <div
      className="fixed inset-0 z-[200] flex items-center justify-center p-6"
      role="dialog"
      aria-modal="true"
    >
      <div
        className="absolute inset-0 bg-slate-900/30 backdrop-blur-sm animate-in fade-in duration-300 dark:bg-slate-950/50"
        onClick={onClose}
        aria-hidden
      />
      <GlassCard
        className={cn(
          'relative w-full max-w-md animate-in zoom-in-95 duration-200',
          flexBody && 'flex min-h-0 flex-col overflow-hidden',
          className
        )}
      >
        <div className={cn('mb-6 flex shrink-0 items-center justify-between gap-3', flexBody && 'mb-4')}>
          <h2 className="text-xl font-bold text-app-primary pr-2">{title}</h2>
          <button
            onClick={onClose}
            className="p-2 rounded-xl transition-colors group hover:bg-black/5 focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500/50 dark:hover:bg-white/10"
            type="button"
            aria-label="Close"
          >
            <X className="h-5 w-5 text-slate-600 transition-colors group-hover:text-slate-900 dark:text-slate-100 dark:group-hover:text-white" />
          </button>
        </div>
        {flexBody ? (
          <div className="flex min-h-0 flex-1 flex-col overflow-hidden">{children}</div>
        ) : (
          children
        )}
      </GlassCard>
    </div>,
    document.body
  );
};

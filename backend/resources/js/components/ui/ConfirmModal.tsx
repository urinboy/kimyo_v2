import { GlassModal } from './GlassModal';
import { AlertCircle, CheckCircle2, HelpCircle, Info } from 'lucide-react';

interface ConfirmModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  type?: 'danger' | 'warning' | 'info' | 'success';
  isLoading?: boolean;
}

export const ConfirmModal = ({
  isOpen,
  onClose,
  onConfirm,
  title,
  message,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  type = 'warning',
  isLoading = false
}: ConfirmModalProps) => {
  const icons = {
    danger: <AlertCircle className="w-12 h-12 text-red-500" />,
    warning: <HelpCircle className="w-12 h-12 text-amber-500" />,
    info: <Info className="w-12 h-12 text-blue-500" />,
    success: <CheckCircle2 className="w-12 h-12 text-emerald-500" />
  };

  const buttonStyles = {
    danger: 'bg-red-500 hover:bg-red-600 shadow-[0_0_20px_rgba(239,68,68,0.3)]',
    warning: 'bg-amber-500 hover:bg-amber-600 shadow-[0_0_20px_rgba(245,158,11,0.3)]',
    info: 'bg-blue-500 hover:bg-blue-600 shadow-[0_0_20px_rgba(59,130,246,0.3)]',
    success: 'bg-emerald-500 hover:bg-emerald-600 shadow-[0_0_20px_rgba(16,185,129,0.3)]'
  };

  return (
    <GlassModal isOpen={isOpen} onClose={onClose} title={title}>
      <div className="flex flex-col items-center text-center space-y-6">
        <div className="p-4 rounded-3xl bg-white/5 border border-white/10">
          {icons[type]}
        </div>
        <p className="text-app-muted leading-relaxed">
          {message}
        </p>
        <div className="flex gap-4 w-full pt-4">
          <button
            type="button"
            onClick={onClose}
            className="flex-1 btn-modal-secondary"
          >
            {cancelText}
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={isLoading}
            className={`flex-1 rounded-2xl px-6 py-3 font-bold text-white transition-all disabled:opacity-50 ${buttonStyles[type]}`}
          >
            {isLoading ? '...' : confirmText}
          </button>
        </div>
      </div>
    </GlassModal>
  );
};

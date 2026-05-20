import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, Globe, Loader2 } from 'lucide-react';
import { languageApi, type Language } from '@/api/languages';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';

const LanguagesPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingLanguage, setEditingLanguage] = useState<Language | null>(null);
  
  // Form State
  const [formData, setFormData] = useState({ name: '', code: '', is_active: true });

  const { data, isLoading } = useQuery({
    queryKey: ['languages'],
    queryFn: languageApi.getAll,
  });

  const createMutation = useMutation({
    mutationFn: languageApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['languages'] });
      handleCloseModal();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<Language> }) => languageApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['languages'] });
      handleCloseModal();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: languageApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['languages'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
    },
  });

  const handleOpenModal = (lang: Language | null = null) => {
    if (lang) {
      setEditingLanguage(lang);
      setFormData({ name: lang.name, code: lang.code, is_active: lang.is_active });
    } else {
      setEditingLanguage(null);
      setFormData({ name: '', code: '', is_active: true });
    }
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingLanguage(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editingLanguage) {
      updateMutation.mutate({ id: editingLanguage.id, data: formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('languages.title')}</h1>
          <p className="text-app-muted mt-1">{t('languages.subtitle')}</p>
        </div>
        <button
          onClick={() => handleOpenModal()}
          className="btn-primary flex items-center gap-2"
        >
          <Plus className="w-5 h-5" />
          {t('languages.add_button')}
        </button>
      </div>

      <GlassCard className="overflow-hidden p-0">
        <div className="overflow-x-auto scrollbar-none">
          <table className="data-table-shell w-full text-left border-collapse">
            <thead>
              <tr>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('languages.table_id')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('languages.table_name')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('languages.table_code')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('languages.table_status')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle text-right">{t('languages.table_actions')}</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={5} className="px-6 py-10 text-center">
                    <Loader2 className="w-8 h-8 animate-spin mx-auto text-purple-500" />
                  </td>
                </tr>
              ) : (
                data?.data.languages.map((lang) => (
                  <tr key={lang.id} className="group">
                    <td className="px-6 py-4 text-sm text-app-muted">#{lang.id}</td>
                    <td className="px-6 py-4 text-sm font-medium">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg glass flex items-center justify-center text-purple-600 dark:text-purple-400">
                          <Globe className="w-4 h-4" />
                        </div>
                        <span className="text-app-primary">{lang.name}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm font-mono text-purple-600 dark:text-purple-400">{lang.code.toUpperCase()}</td>
                    <td className="px-6 py-4 text-sm">
                      <span className={cn(
                        "px-3 py-1 rounded-full text-xs font-semibold",
                        lang.is_active ? "bg-emerald-500/10 text-emerald-500" : "bg-red-500/10 text-red-500"
                      )}>
                        {lang.is_active ? t('languages.active') : t('languages.inactive')}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-right">
                      <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button 
                          onClick={() => handleOpenModal(lang)}
                          className="p-2 rounded-xl hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-app-primary transition-all"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => {
                            setDeletingId(lang.id);
                            setIsDeleteModalOpen(true);
                          }}
                          className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </GlassCard>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingId && deleteMutation.mutate(deletingId)}
        title={t('languages.delete_title')}
        message={t('languages.delete_confirm')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingLanguage ? t('languages.edit_title') : t('languages.create_title')}
      >
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('languages.form_name')}</label>
            <input
              type="text"
              required
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="input-glass"
              placeholder={t('languages.form_name_placeholder')}
            />
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('languages.form_code')}</label>
            <input
              type="text"
              required
              value={formData.code}
              onChange={(e) => setFormData({ ...formData, code: e.target.value })}
              className="input-glass font-mono uppercase"
              placeholder={t('languages.form_code_placeholder')}
            />
          </div>

          <div className="flex items-center gap-3 p-4 rounded-2xl border border-black/10 bg-black/[0.03] dark:border-white/10 dark:bg-white/5">
            <input
              type="checkbox"
              id="is_active"
              checked={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
              className="w-5 h-5 rounded-lg border-white/20 bg-transparent text-purple-500 focus:ring-purple-500/50"
            />
            <label htmlFor="is_active" className="text-sm font-medium text-app-subtle cursor-pointer select-none">
              {t('languages.form_is_active')}
            </label>
          </div>

          <div className="flex gap-4 pt-4">
            <button
              type="button"
              onClick={handleCloseModal}
              className="flex-1 btn-modal-secondary"
            >
              {t('common.cancel')}
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending || updateMutation.isPending}
              className="flex-1 btn-primary flex items-center justify-center gap-2"
            >
              {(createMutation.isPending || updateMutation.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
              {editingLanguage ? t('common.save') : t('common.create')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

// Utility function for conditional classes
function cn(...classes: (string | boolean | undefined)[]) {
  return classes.filter(Boolean).join(' ');
}

export default LanguagesPage;

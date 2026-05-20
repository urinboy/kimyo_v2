import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, MapPin, Loader2, CheckCircle2, XCircle } from 'lucide-react';
import { regionApi, type Region } from '@/api/regions';
import { languageApi } from '@/api/languages';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';

const RegionsPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingRegion, setEditingRegion] = useState<Region | null>(null);
  const [activeTab, setActiveTab] = useState('base');
  const [isActive, setIsActive] = useState(true);
  const [translationsData, setTranslationsData] = useState<Record<number, { name: string; description: string }>>({});

  const { data: langData } = useQuery({ queryKey: ['languages'], queryFn: languageApi.getAll });
  const { data: regionsData, isLoading } = useQuery({ queryKey: ['regions'], queryFn: regionApi.getAll });

  const activeLanguages = useMemo(() => langData?.data.languages.filter(l => l.is_active) || [], [langData]);

  const createMutation = useMutation({
    mutationFn: regionApi.create,
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['regions'] }); handleCloseModal(); },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Parameters<typeof regionApi.update>[1] }) => regionApi.update(id, data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['regions'] }); handleCloseModal(); },
  });

  const deleteMutation = useMutation({
    mutationFn: regionApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['regions'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
    },
  });

  const handleOpenModal = (region: Region | null = null) => {
    if (region) {
      setEditingRegion(region);
      setIsActive(region.is_active);
      const trans: Record<number, { name: string; description: string }> = {};
      region.translations.forEach(tr => {
        trans[tr.language_id] = { name: tr.name, description: tr.description || '' };
      });
      setTranslationsData(trans);
    } else {
      setEditingRegion(null);
      setIsActive(true);
      setTranslationsData({});
    }
    setActiveTab('base');
    setIsModalOpen(true);
  };

  const handleCloseModal = () => { setIsModalOpen(false); setEditingRegion(null); };

  const handleTranslationChange = (langId: number, field: 'name' | 'description', value: string) => {
    setTranslationsData(prev => ({
      ...prev,
      [langId]: { ...(prev[langId] || { name: '', description: '' }), [field]: value },
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { is_active: isActive, translations: translationsData };
    if (editingRegion) {
      updateMutation.mutate({ id: editingRegion.id, data: payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const getRegionName = (region: Region) =>
    region.translations[0]?.name || region.translations.find(tr => tr.name)?.name || '—';

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('regions.title')}</h1>
          <p className="text-app-muted mt-1">{t('regions.subtitle')}</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('regions.add_button')}
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {isLoading ? (
          <div className="col-span-full py-20 text-center">
            <Loader2 className="w-10 h-10 animate-spin mx-auto text-purple-500" />
          </div>
        ) : !regionsData?.data.regions.length ? (
          <div className="col-span-full py-20 text-center text-app-muted">
            <MapPin className="w-12 h-12 mx-auto mb-4 opacity-30" />
            <p>{t('regions.empty')}</p>
          </div>
        ) : (
          regionsData.data.regions.map(region => (
            <GlassCard key={region.id} className="group">
              <div className="flex justify-between items-start mb-6">
                <div className="w-12 h-12 rounded-2xl glass flex items-center justify-center text-emerald-400">
                  <MapPin className="w-6 h-6" />
                </div>
                <div className="flex gap-1">
                  <button onClick={() => handleOpenModal(region)} className="p-2 rounded-xl hover:bg-white/10 text-app-muted hover:text-app-primary transition-all">
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => { setDeletingId(region.id); setIsDeleteModalOpen(true); }}
                    className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <h3 className="text-xl font-bold text-app-primary mb-2">{getRegionName(region)}</h3>

              <div className="pt-4 border-t border-white/5 flex items-center justify-between">
                <span className={`flex items-center gap-1.5 text-xs font-medium ${region.is_active ? 'text-emerald-400' : 'text-app-muted'}`}>
                  {region.is_active ? <CheckCircle2 className="w-3 h-3" /> : <XCircle className="w-3 h-3" />}
                  {region.is_active ? t('languages.active') : t('languages.inactive')}
                </span>
                <span className="text-xs text-app-muted">#{region.id}</span>
              </div>
            </GlassCard>
          ))
        )}
      </div>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingId && deleteMutation.mutate(deletingId)}
        title={t('regions.delete_title')}
        message={t('regions.delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingRegion ? t('regions.edit_title') : t('regions.create_title')}
        className="max-w-2xl"
      >
        <div className="flex gap-2 mb-8 p-1 rounded-2xl bg-black/[0.04] dark:bg-white/5 border border-black/10 dark:border-white/10">
          <button
            onClick={() => setActiveTab('base')}
            className={`flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all ${
              activeTab === 'base' ? 'bg-purple-500 text-white shadow-lg shadow-purple-500/20' : 'text-app-muted hover:text-app-primary'
            }`}
          >
            {t('mines.form_base_data')}
          </button>
          {activeLanguages.map(lang => (
            <button
              key={lang.id}
              onClick={() => setActiveTab(lang.code)}
              className={`flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2 ${
                activeTab === lang.code ? 'bg-purple-500 text-white shadow-lg shadow-purple-500/20' : 'text-app-muted hover:text-app-primary'
              }`}
            >
              <LanguageFlag code={lang.code} size="sm" className="shrink-0" />
              {lang.code.toUpperCase()}
            </button>
          ))}
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {activeTab === 'base' && (
            <div className="space-y-6 animate-in fade-in duration-300">
              <label className="flex items-center gap-3 cursor-pointer group">
                <div className="relative">
                  <input type="checkbox" checked={isActive} onChange={e => setIsActive(e.target.checked)} className="sr-only" />
                  <div className={`w-12 h-6 rounded-full transition-colors ${isActive ? 'bg-emerald-500/30' : 'bg-white/10'}`} />
                  <div className={`absolute left-1 top-1 w-4 h-4 rounded-full transition-transform ${isActive ? 'translate-x-6 bg-emerald-400' : 'bg-gray-500'}`} />
                </div>
                <span className="text-sm font-medium text-app-subtle">{t('languages.active')}</span>
              </label>
            </div>
          )}

          {activeLanguages.map(lang => activeTab === lang.code && (
            <div key={lang.id} className="space-y-6 animate-in fade-in duration-300">
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('languages.table_name')} ({lang.name})</label>
                <input
                  type="text"
                  required
                  value={translationsData[lang.id]?.name || ''}
                  onChange={e => handleTranslationChange(lang.id, 'name', e.target.value)}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('elements.form_description_with_lang', { lang: lang.name })}</label>
                <textarea
                  rows={4}
                  value={translationsData[lang.id]?.description || ''}
                  onChange={e => handleTranslationChange(lang.id, 'description', e.target.value)}
                  className="input-glass resize-none"
                />
              </div>
            </div>
          ))}

          <div className="flex gap-4 pt-4">
            <button type="button" onClick={handleCloseModal} className="flex-1 btn-modal-secondary">
              {t('common.cancel')}
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending || updateMutation.isPending}
              className="flex-1 btn-primary flex items-center justify-center gap-2"
            >
              {(createMutation.isPending || updateMutation.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
              {editingRegion ? t('common.save') : t('common.add')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

export default RegionsPage;

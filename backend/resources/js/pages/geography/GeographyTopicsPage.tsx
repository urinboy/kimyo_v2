import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router-dom';
import { Plus, Edit2, Trash2, Loader2, Info } from 'lucide-react';
import { geographyTopicApi, type GeographyTopic } from '@/api/geographyTopics';
import { languageApi } from '@/api/languages';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';

const GeographyTopicsPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [searchParams] = useSearchParams();
  const category = searchParams.get('category') || 'landscapes';

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingItem, setEditingItem] = useState<GeographyTopic | null>(null);
  const [activeTab, setActiveTab] = useState('base');

  const [baseData, setBaseData] = useState({
    category: category,
    icon: '',
    sort_order: 0,
    is_active: true,
  });

  const [translationsData, setTranslationsData] = useState<Record<number, { title: string; content: string }>>({});

  const { data: langData } = useQuery({ queryKey: ['languages'], queryFn: languageApi.getAll });
  const { data: topicsData, isLoading } = useQuery({ 
    queryKey: ['geography-topics', category], 
    queryFn: () => geographyTopicApi.getAll(category) 
  });

  const activeLanguages = useMemo(() => langData?.data.languages.filter(l => l.is_active) || [], [langData]);

  const createMutation = useMutation({
    mutationFn: geographyTopicApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['geography-topics'] });
      handleCloseModal();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) => geographyTopicApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['geography-topics'] });
      handleCloseModal();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: geographyTopicApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['geography-topics'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
    },
  });

  const handleOpenModal = (item: GeographyTopic | null = null) => {
    if (item) {
      setEditingItem(item);
      setBaseData({
        category: item.category,
        icon: item.icon || '',
        sort_order: item.sort_order,
        is_active: item.is_active,
      });
      const trans: Record<number, { title: string; content: string }> = {};
      item.translations.forEach(t => {
        trans[t.language_id] = { title: t.title, content: t.content || '' };
      });
      setTranslationsData(trans);
    } else {
      setEditingItem(null);
      setBaseData({ category: category, icon: '', sort_order: (topicsData?.data.topics.length || 0) + 1, is_active: true });
      setTranslationsData({});
    }
    setActiveTab('base');
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingItem(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      ...baseData,
      category: category, // Ensure category matches search param
      translations: Object.entries(translationsData).map(([langId, data]) => ({
        language_id: parseInt(langId),
        ...data,
      })),
    };

    if (editingItem) {
      updateMutation.mutate({ id: editingItem.id, data: payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const handleTranslationChange = (langId: number, field: 'title' | 'content', value: string) => {
    setTranslationsData(prev => ({
      ...prev,
      [langId]: {
        ...(prev[langId] || { title: '', content: '' }),
        [field]: value
      }
    }));
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">
            {t(`geography.topics.categories.${category}`)}
          </h1>
          <p className="text-app-muted mt-1">{t('geography.topics.subtitle')}</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 shadow-emerald-500/20">
          <Plus className="w-5 h-5" />
          {t('geography.topics.add_button')}
        </button>
      </div>

      <GlassCard className="overflow-hidden p-0">
        <div className="overflow-x-auto scrollbar-none">
          <table className="data-table-shell w-full text-left border-collapse">
            <thead>
              <tr>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">Icon</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('geography.topics.table_title')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('geography.topics.table_status')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle text-right">{t('geography.topics.table_actions')}</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={4} className="px-6 py-10 text-center">
                    <Loader2 className="w-8 h-8 animate-spin mx-auto text-emerald-500" />
                  </td>
                </tr>
              ) : topicsData?.data.topics.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-10 text-center text-app-muted">
                    {t('geography.topics.empty')}
                  </td>
                </tr>
              ) : (
                topicsData?.data.topics.map((item) => (
                  <tr key={item.id} className="group">
                    <td className="px-6 py-4">
                      <div className="w-10 h-10 rounded-xl bg-emerald-500/10 flex items-center justify-center text-emerald-500 border border-emerald-500/20">
                        <Info className="w-5 h-5" />
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-medium text-app-primary">
                        {item.translations.find(t => t.language?.code === 'uz')?.title || 'N/A'}
                      </div>
                      <div className="text-xs text-app-muted">Order: {item.sort_order}</div>
                    </td>
                    <td className="px-6 py-4 text-sm">
                      <span className={cn(
                        "px-2 py-1 rounded-lg text-xs font-medium",
                        item.is_active ? "bg-emerald-500/10 text-emerald-500" : "bg-red-500/10 text-red-500"
                      )}>
                        {item.is_active ? t('common.active') : t('common.inactive')}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-right">
                      <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button onClick={() => handleOpenModal(item)} className="p-2 rounded-xl hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-emerald-500 transition-all">
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => {
                            setDeletingId(item.id);
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
        title={t('geography.topics.delete_title')}
        message={t('geography.topics.delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingItem ? t('geography.topics.edit_title') : t('geography.topics.create_title')}
        className="max-w-4xl"
      >
        <div className="flex gap-2 mb-8 p-1 rounded-2xl bg-black/[0.04] dark:bg-white/5 border border-black/10 dark:border-white/10">
          <button
            onClick={() => setActiveTab('base')}
            className={cn(
              "flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all",
              activeTab === 'base' ? "bg-emerald-500 text-white shadow-lg shadow-emerald-500/20" : "text-app-muted hover:text-app-primary"
            )}
          >
            {t('elements.form_base_data')}
          </button>
          {activeLanguages.map(lang => (
            <button
              key={lang.id}
              onClick={() => setActiveTab(lang.code)}
              className={cn(
                "flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2",
                activeTab === lang.code ? "bg-emerald-500 text-white shadow-lg shadow-emerald-500/20" : "text-app-muted hover:text-app-primary"
              )}
            >
              <LanguageFlag code={lang.code} size="sm" className="shrink-0" />
              {lang.code.toUpperCase()}
            </button>
          ))}
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {activeTab === 'base' && (
            <div className="grid grid-cols-2 gap-6 animate-in fade-in duration-300">
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.topics.form_icon')}</label>
                <input
                  type="text"
                  value={baseData.icon}
                  onChange={e => setBaseData({ ...baseData, icon: e.target.value })}
                  placeholder="Lucide icon name"
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.topics.form_sort')}</label>
                <input
                  type="number"
                  value={baseData.sort_order}
                  onChange={e => setBaseData({ ...baseData, sort_order: parseInt(e.target.value) })}
                  className="input-glass"
                />
              </div>
              <div className="flex items-center gap-3 p-4 rounded-2xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/5 dark:border-white/5 col-span-2">
                <input
                  type="checkbox"
                  id="is_active"
                  checked={baseData.is_active}
                  onChange={e => setBaseData({ ...baseData, is_active: e.target.checked })}
                  className="w-5 h-5 rounded border-emerald-500/50 text-emerald-500 focus:ring-emerald-500/20"
                />
                <label htmlFor="is_active" className="text-sm font-medium text-app-primary select-none cursor-pointer">
                  {t('geography.topics.form_is_active')}
                </label>
              </div>
            </div>
          )}

          {activeLanguages.map(lang => activeTab === lang.code && (
            <div key={lang.id} className="space-y-6 animate-in fade-in duration-300">
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">
                  {t('geography.topics.form_title')} ({lang.name})
                </label>
                <input
                  type="text"
                  required
                  value={translationsData[lang.id]?.title || ''}
                  onChange={e => handleTranslationChange(lang.id, 'title', e.target.value)}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">
                  {t('geography.topics.form_content')} ({lang.name})
                </label>
                <textarea
                  rows={8}
                  value={translationsData[lang.id]?.content || ''}
                  onChange={e => handleTranslationChange(lang.id, 'content', e.target.value)}
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
              className="flex-1 btn-primary flex items-center justify-center gap-2 bg-emerald-500 hover:bg-emerald-600 shadow-emerald-500/20"
            >
              {(createMutation.isPending || updateMutation.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
              {editingItem ? t('common.save') : t('common.add')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

function cn(...classes: (string | boolean | undefined)[]) {
  return classes.filter(Boolean).join(' ');
}

export default GeographyTopicsPage;

import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, Loader2 } from 'lucide-react';
import { elementApi, type Element, type ElementTranslation } from '@/api/elements';
import { languageApi } from '@/api/languages';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';

const ElementsPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingElement, setEditingElement] = useState<Element | null>(null);
  const [activeTab, setActiveTab] = useState('base');
  
  const [baseData, setBaseData] = useState({
    atomic_number: 0,
    symbol: '',
    mass: 0,
    color_hex: '#A855F7',
    type: 'metal',
  });

  const [translationsData, setTranslationsData] = useState<Record<number, { name: string; description: string }>>({});

  const { data: langData } = useQuery({ queryKey: ['languages'], queryFn: languageApi.getAll });
  const { data: elementsData, isLoading } = useQuery({ queryKey: ['elements'], queryFn: elementApi.getAll });

  const activeLanguages = useMemo(() => langData?.data.languages.filter(l => l.is_active) || [], [langData]);

  const createMutation = useMutation({
    mutationFn: elementApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['elements'] });
      handleCloseModal();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<Element> & { translations: Partial<ElementTranslation>[] } }) => elementApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['elements'] });
      handleCloseModal();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: elementApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['elements'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
    },
  });

  const handleOpenModal = (elem: Element | null = null) => {
    if (elem) {
      setEditingElement(elem);
      setBaseData({
        atomic_number: elem.atomic_number,
        symbol: elem.symbol,
        mass: elem.mass,
        color_hex: elem.color_hex || '#A855F7',
        type: elem.type,
      });
      const trans: Record<number, { name: string; description: string }> = {};
      elem.translations.forEach(t => {
        trans[t.language_id] = { name: t.name, description: t.description || '' };
      });
      setTranslationsData(trans);
    } else {
      setEditingElement(null);
      setBaseData({ atomic_number: 0, symbol: '', mass: 0, color_hex: '#A855F7', type: 'metal' });
      setTranslationsData({});
    }
    setActiveTab('base');
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingElement(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      ...baseData,
      translations: Object.entries(translationsData).map(([langId, data]) => ({
        language_id: parseInt(langId),
        ...data,
      })),
    };

    if (editingElement) {
      updateMutation.mutate({ id: editingElement.id, data: payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const handleTranslationChange = (langId: number, field: 'name' | 'description', value: string) => {
    setTranslationsData(prev => ({
      ...prev,
      [langId]: {
        ...(prev[langId] || { name: '', description: '' }),
        [field]: value
      }
    }));
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('elements.title')}</h1>
          <p className="text-app-muted mt-1">{t('elements.subtitle')}</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('elements.add_button')}
        </button>
      </div>

      <GlassCard className="overflow-hidden p-0">
        <div className="overflow-x-auto scrollbar-none">
          <table className="data-table-shell w-full text-left border-collapse">
            <thead>
              <tr>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('elements.table_id')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('elements.table_symbol')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('elements.table_name')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('elements.table_mass')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('elements.table_type')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle text-right">{t('elements.table_actions')}</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-10 text-center">
                    <Loader2 className="w-8 h-8 animate-spin mx-auto text-purple-500" />
                  </td>
                </tr>
              ) : (
                elementsData?.data.elements.map((elem) => (
                  <tr key={elem.id} className="group">
                    <td className="px-6 py-4 text-sm font-mono text-app-muted">{elem.atomic_number}</td>
                    <td className="px-6 py-4">
                      <div className="w-10 h-10 rounded-xl flex items-center justify-center font-bold text-white shadow-lg shadow-purple-500/10" style={{ backgroundColor: elem.color_hex || '#A855F7' }}>
                        {elem.symbol}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm font-medium text-app-primary">
                      {elem.translations.find(t => t.language?.code === 'uz')?.name || 'N/A'}
                    </td>
                    <td className="px-6 py-4 text-sm text-app-muted">{elem.mass}</td>
                    <td className="px-6 py-4 text-sm">
                      <span className="table-pill text-app-muted">
                        {elem.type}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-right">
                      <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button onClick={() => handleOpenModal(elem)} className="p-2 rounded-xl hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-app-primary transition-all">
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => {
                            setDeletingId(elem.id);
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
        title={t('elements.delete_title')}
        message={t('elements.delete_confirm_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingElement ? t('common.edit') : t('common.add')}
        className="max-w-3xl"
      >
        <div className="flex gap-2 mb-8 p-1 rounded-2xl bg-black/[0.04] dark:bg-white/5 border border-black/10 dark:border-white/10">
          <button
            onClick={() => setActiveTab('base')}
            className={cn(
              "flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all",
              activeTab === 'base' ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary"
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
                activeTab === lang.code ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary"
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
                <label className="text-sm font-medium text-app-subtle ml-1">{t('elements.form_atomic_number')}</label>
                <input
                  type="number"
                  required
                  value={baseData.atomic_number}
                  onChange={e => setBaseData({ ...baseData, atomic_number: parseInt(e.target.value) })}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('elements.form_symbol')}</label>
                <input
                  type="text"
                  required
                  value={baseData.symbol}
                  onChange={e => setBaseData({ ...baseData, symbol: e.target.value })}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('elements.form_mass')}</label>
                <input
                  type="number"
                  step="0.0001"
                  required
                  value={baseData.mass}
                  onChange={e => setBaseData({ ...baseData, mass: parseFloat(e.target.value) })}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('elements.form_color')}</label>
                <div className="flex gap-2">
                  <input
                    type="color"
                    value={baseData.color_hex}
                    onChange={e => setBaseData({ ...baseData, color_hex: e.target.value })}
                    className="w-12 h-12 rounded-xl border-0 bg-transparent cursor-pointer"
                  />
                  <input
                    type="text"
                    value={baseData.color_hex}
                    onChange={e => setBaseData({ ...baseData, color_hex: e.target.value })}
                    className="input-glass"
                  />
                </div>
              </div>
              <div className="space-y-2 col-span-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('elements.form_type')}</label>
                <select
                  value={baseData.type}
                  onChange={e => setBaseData({ ...baseData, type: e.target.value })}
                  className="input-glass"
                >
                  <option value="metal">Metal</option>
                  <option value="nonmetal">Non-metal</option>
                  <option value="noble_gas">Noble Gas</option>
                  <option value="metalloid">Metalloid</option>
                </select>
              </div>
            </div>
          )}

          {activeLanguages.map(lang => activeTab === lang.code && (
            <div key={lang.id} className="space-y-6 animate-in fade-in duration-300">
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">
                  {t('elements.form_name_with_lang', { lang: lang.name })}
                </label>
                <input
                  type="text"
                  required
                  value={translationsData[lang.id]?.name || ''}
                  onChange={e => handleTranslationChange(lang.id, 'name', e.target.value)}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">
                  {t('elements.form_description_with_lang', { lang: lang.name })}
                </label>
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
              {editingElement ? t('common.save') : t('common.add')}
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

export default ElementsPage;

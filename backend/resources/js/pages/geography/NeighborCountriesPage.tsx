import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, Loader2 } from 'lucide-react';
import { neighborApi, type NeighborCountry } from '@/api/neighbors';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';

const NeighborCountriesPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingItem, setEditingItem] = useState<NeighborCountry | null>(null);
  const [activeTab, setActiveTab] = useState('uz');

  const [formData, setFormData] = useState<Partial<NeighborCountry>>({
    code: '',
    name_uz: '',
    name_ru: '',
    name_en: '',
    capital_uz: '',
    capital_ru: '',
    capital_en: '',
    description_uz: '',
    description_ru: '',
    description_en: '',
    area_km2: 0,
    population_mn: 0,
    languages_uz: '',
    languages_ru: '',
    languages_en: '',
    currency_uz: '',
    currency_ru: '',
    currency_en: '',
    border_with_uz_km: 0,
    flag_emoji: '',
    sort_order: 0,
  });

  const { data: countriesData, isLoading } = useQuery({ 
    queryKey: ['neighbor-countries'], 
    queryFn: neighborApi.getAll 
  });

  const createMutation = useMutation({
    mutationFn: neighborApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['neighbor-countries'] });
      handleCloseModal();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<NeighborCountry> }) => neighborApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['neighbor-countries'] });
      handleCloseModal();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: neighborApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['neighbor-countries'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
    },
  });

  const handleOpenModal = (item: NeighborCountry | null = null) => {
    if (item) {
      setEditingItem(item);
      setFormData({ ...item });
    } else {
      setEditingItem(null);
      setFormData({
        code: '',
        name_uz: '',
        name_ru: '',
        name_en: '',
        capital_uz: '',
        capital_ru: '',
        capital_en: '',
        description_uz: '',
        description_ru: '',
        description_en: '',
        area_km2: 0,
        population_mn: 0,
        languages_uz: '',
        languages_ru: '',
        languages_en: '',
        currency_uz: '',
        currency_ru: '',
        currency_en: '',
        border_with_uz_km: 0,
        flag_emoji: '',
        sort_order: (countriesData?.data.countries.length || 0) + 1,
      });
    }
    setActiveTab('uz');
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingItem(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editingItem) {
      updateMutation.mutate({ id: editingItem.id, data: formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const handleInputChange = (field: keyof NeighborCountry, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('geography.neighbors.title')}</h1>
          <p className="text-app-muted mt-1">{t('geography.neighbors.subtitle')}</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('geography.neighbors.add_button')}
        </button>
      </div>

      <GlassCard className="overflow-hidden p-0">
        <div className="overflow-x-auto scrollbar-none">
          <table className="data-table-shell w-full text-left border-collapse">
            <thead>
              <tr>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">Flag</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('geography.neighbors.table_name')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('geography.neighbors.table_capital')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle text-right">{t('geography.neighbors.table_actions')}</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={4} className="px-6 py-10 text-center">
                    <Loader2 className="w-8 h-8 animate-spin mx-auto text-emerald-500" />
                  </td>
                </tr>
              ) : countriesData?.data.countries.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-10 text-center text-app-muted">
                    {t('geography.neighbors.empty')}
                  </td>
                </tr>
              ) : (
                countriesData?.data.countries.map((item) => (
                  <tr key={item.id} className="group">
                    <td className="px-6 py-4 text-2xl">{item.flag_emoji || '🏳️'}</td>
                    <td className="px-6 py-4">
                      <div className="font-medium text-app-primary">{item.name_uz}</div>
                      <div className="text-xs text-app-muted">{item.code}</div>
                    </td>
                    <td className="px-6 py-4 text-sm text-app-muted">{item.capital_uz || '-'}</td>
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
        title={t('geography.neighbors.delete_title')}
        message={t('geography.neighbors.delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingItem ? t('geography.neighbors.edit_title') : t('geography.neighbors.create_title')}
        className="max-w-4xl"
      >
        <div className="flex gap-2 mb-8 p-1 rounded-2xl bg-black/[0.04] dark:bg-white/5 border border-black/10 dark:border-white/10 overflow-x-auto scrollbar-none">
          {['uz', 'ru', 'en'].map(lang => (
            <button
              key={lang}
              onClick={() => setActiveTab(lang)}
              className={cn(
                "flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all whitespace-nowrap",
                activeTab === lang ? "bg-emerald-500 text-white shadow-lg shadow-emerald-500/20" : "text-app-muted hover:text-app-primary"
              )}
            >
              {lang.toUpperCase()}
            </button>
          ))}
          <button
            onClick={() => setActiveTab('stats')}
            className={cn(
              "flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all whitespace-nowrap",
              activeTab === 'stats' ? "bg-emerald-500 text-white shadow-lg shadow-emerald-500/20" : "text-app-muted hover:text-app-primary"
            )}
          >
            Stats & Info
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {['uz', 'ru', 'en'].map(lang => activeTab === lang && (
            <div key={lang} className="space-y-6 animate-in fade-in duration-300">
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_name')} ({lang.toUpperCase()})</label>
                  <input
                    type="text"
                    required={lang === 'uz'}
                    value={(formData as any)[`name_${lang}`] || ''}
                    onChange={e => handleInputChange(`name_${lang}` as any, e.target.value)}
                    className="input-glass"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_capital')} ({lang.toUpperCase()})</label>
                  <input
                    type="text"
                    value={(formData as any)[`capital_${lang}`] || ''}
                    onChange={e => handleInputChange(`capital_${lang}` as any, e.target.value)}
                    className="input-glass"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_languages')} ({lang.toUpperCase()})</label>
                  <input
                    type="text"
                    value={(formData as any)[`languages_${lang}`] || ''}
                    onChange={e => handleInputChange(`languages_${lang}` as any, e.target.value)}
                    className="input-glass"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_currency')} ({lang.toUpperCase()})</label>
                  <input
                    type="text"
                    value={(formData as any)[`currency_${lang}`] || ''}
                    onChange={e => handleInputChange(`currency_${lang}` as any, e.target.value)}
                    className="input-glass"
                  />
                </div>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_description')} ({lang.toUpperCase()})</label>
                <textarea
                  rows={4}
                  value={(formData as any)[`description_${lang}`] || ''}
                  onChange={e => handleInputChange(`description_${lang}` as any, e.target.value)}
                  className="input-glass resize-none"
                />
              </div>
            </div>
          ))}

          {activeTab === 'stats' && (
            <div className="grid grid-cols-2 gap-6 animate-in fade-in duration-300">
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_code')}</label>
                <input
                  type="text"
                  required
                  value={formData.code}
                  onChange={e => handleInputChange('code', e.target.value)}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_flag')}</label>
                <input
                  type="text"
                  placeholder="e.g. 🇰🇿"
                  value={formData.flag_emoji}
                  onChange={e => handleInputChange('flag_emoji', e.target.value)}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_area')}</label>
                <input
                  type="number"
                  value={formData.area_km2}
                  onChange={e => handleInputChange('area_km2', parseFloat(e.target.value))}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_population')}</label>
                <input
                  type="number"
                  step="0.1"
                  value={formData.population_mn}
                  onChange={e => handleInputChange('population_mn', parseFloat(e.target.value))}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.neighbors.form_border')}</label>
                <input
                  type="number"
                  value={formData.border_with_uz_km}
                  onChange={e => handleInputChange('border_with_uz_km', parseFloat(e.target.value))}
                  className="input-glass"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('geography.topics.form_sort')}</label>
                <input
                  type="number"
                  value={formData.sort_order}
                  onChange={e => handleInputChange('sort_order', parseInt(e.target.value))}
                  className="input-glass"
                />
              </div>
            </div>
          )}

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

export default NeighborCountriesPage;

import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, MapPin, Loader2, Globe, CheckCircle2, XCircle } from 'lucide-react';
import { mineApi, type Mine } from '@/api/mines';
import { languageApi } from '@/api/languages';
import { elementApi } from '@/api/elements';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';

const MinesPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingMine, setEditingMine] = useState<Mine | null>(null);
  const [activeTab, setActiveTab] = useState('base');

  const [formData, setFormData] = useState({
    latitude: 0,
    longitude: 0,
    is_active: true,
  });

  const [translationsData, setTranslationsData] = useState<Record<number, { name: string; description: string }>>({});
  const [selectedElements, setSelectedElements] = useState<number[]>([]);
  const [elementSearch, setElementSearch] = useState('');

  const { data: langData } = useQuery({ queryKey: ['languages'], queryFn: languageApi.getAll });
  const { data: elementsData } = useQuery({ queryKey: ['elements'], queryFn: elementApi.getAll });
  const { data: minesData, isLoading } = useQuery({ queryKey: ['mines'], queryFn: mineApi.getAll });

  const activeLanguages = useMemo(() => langData?.data.languages.filter(l => l.is_active) || [], [langData]);

  const createMutation = useMutation({
    mutationFn: (data: any) => mineApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['mines'] });
      handleCloseModal();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) => mineApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['mines'] });
      handleCloseModal();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: mineApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['mines'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
    },
  });

  const handleOpenModal = (mine: Mine | null = null) => {
    if (mine) {
      setEditingMine(mine);
      setFormData({
        latitude: mine.latitude,
        longitude: mine.longitude,
        is_active: mine.is_active,
      });
      const trans: Record<number, { name: string; description: string }> = {};
      mine.translations.forEach(tr => {
        trans[tr.language_id] = { name: tr.name, description: tr.description || '' };
      });
      setTranslationsData(trans);
      setSelectedElements(mine.elements.map(e => e.id));
    } else {
      setEditingMine(null);
      setFormData({ latitude: 42.46, longitude: 59.61, is_active: true }); // Default Nukus coords
      setTranslationsData({});
      setSelectedElements([]);
    }
    setActiveTab('base');
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingMine(null);
  };

  const handleTranslationChange = (langId: number, field: 'name' | 'description', value: string) => {
    setTranslationsData(prev => ({
      ...prev,
      [langId]: { ...(prev[langId] || { name: '', description: '' }), [field]: value }
    }));
  };

  const toggleElement = (id: number) => {
    setSelectedElements(prev => prev.includes(id) ? prev.filter(e => e !== id) : [...prev, id]);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      ...formData,
      translations: translationsData,
      elements: selectedElements
    };

    if (editingMine) {
      updateMutation.mutate({ id: editingMine.id, data: payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('sidebar.mines')}</h1>
          <p className="text-app-muted mt-1">{t('mines.subtitle')}</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('mines.add_button')}
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {isLoading ? (
          <div className="col-span-full py-20 text-center">
            <Loader2 className="w-10 h-10 animate-spin mx-auto text-purple-500" />
          </div>
        ) : (
          minesData?.data.mines.map((mine) => (
            <GlassCard key={mine.id} className="group">
              <div className="flex justify-between items-start mb-6">
                <div className="w-12 h-12 rounded-2xl glass flex items-center justify-center text-purple-400">
                  <MapPin className="w-6 h-6" />
                </div>
                <div className="flex gap-1">
                  <button onClick={() => handleOpenModal(mine)} className="p-2 rounded-xl hover:bg-white/10 text-app-muted hover:text-app-primary transition-all">
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={() => {
                      setDeletingId(mine.id);
                      setIsDeleteModalOpen(true);
                    }} 
                    className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <h3 className="text-xl font-bold text-app-primary mb-2">
                {mine.translations.find(t => t.language_id === 1)?.name || 'N/A'}
              </h3>
              <p className="text-sm text-app-muted mb-6 flex items-center gap-2">
                <Globe className="w-3 h-3" />
                {mine.latitude}, {mine.longitude}
              </p>

              <div className="flex flex-wrap gap-2 mb-6">
                {mine.elements.map(el => (
                  <span key={el.id} className="px-2 py-1 rounded-lg bg-purple-500/10 border border-purple-500/20 text-[10px] text-purple-400 font-bold uppercase">
                    {el.symbol}
                  </span>
                ))}
              </div>

              <div className="pt-4 border-t border-white/5 flex items-center justify-between">
                <span className={`flex items-center gap-1.5 text-xs font-medium ${mine.is_active ? 'text-emerald-400' : 'text-app-muted'}`}>
                  {mine.is_active ? <CheckCircle2 className="w-3 h-3" /> : <XCircle className="w-3 h-3" />}
                  {mine.is_active ? t('languages.active') : t('languages.inactive')}
                </span>
              </div>
            </GlassCard>
          ))
        )}
      </div>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingId && deleteMutation.mutate(deletingId)}
        title={t('mines.delete_title')}
        message={t('mines.delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingMine ? t('mines.edit_title') : t('mines.create_title')}
        className="max-w-3xl"
      >
        <div className="flex gap-2 mb-8 p-1 rounded-2xl bg-black/[0.04] dark:bg-white/5 border border-black/10 dark:border-white/10">
          <button
            onClick={() => setActiveTab('base')}
            className={`flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all ${
              activeTab === 'base' ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary"
            }`}
          >
            {t('mines.form_base_data')}
          </button>
          {activeLanguages.map(lang => (
            <button
              key={lang.id}
              onClick={() => setActiveTab(lang.code)}
              className={`flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2 ${
                activeTab === lang.code ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary"
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
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('mines.form_latitude')}</label>
                  <input
                    type="number"
                    step="0.00000001"
                    required
                    value={formData.latitude}
                    onChange={e => setFormData({ ...formData, latitude: parseFloat(e.target.value) })}
                    className="input-glass"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('mines.form_longitude')}</label>
                  <input
                    type="number"
                    step="0.00000001"
                    required
                    value={formData.longitude}
                    onChange={e => setFormData({ ...formData, longitude: parseFloat(e.target.value) })}
                    className="input-glass"
                  />
                </div>
              </div>

              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('mines.form_elements')}</label>
                  <div className="text-xs font-medium text-app-muted">
                    {selectedElements.length} {t('common.selected', 'selected')}
                  </div>
                </div>
                
                <div className="relative">
                  <input
                    type="text"
                    placeholder={t('common.search', 'Search elements...')}
                    value={elementSearch}
                    onChange={e => setElementSearch(e.target.value)}
                    className="input-glass text-sm mb-4"
                  />
                </div>

                <div className="max-h-[300px] overflow-y-auto pr-2 space-y-4 scrollbar-none">
                  {/* Selected elements first summary */}
                  {selectedElements.length > 0 && (
                    <div className="flex flex-wrap gap-2 pb-4 border-b border-white/5">
                      {elementsData?.data.elements
                        .filter(el => selectedElements.includes(el.id))
                        .map(el => (
                          <div 
                            key={`sel-${el.id}`}
                            className="px-2 py-1 rounded-lg bg-purple-500/20 border border-purple-500/30 flex items-center gap-2"
                          >
                            <span className="text-[10px] font-bold text-white">{el.symbol}</span>
                            <button 
                              type="button" 
                              onClick={() => toggleElement(el.id)}
                              className="hover:text-red-400 transition-colors"
                            >
                              <XCircle className="w-3 h-3" />
                            </button>
                          </div>
                        ))}
                    </div>
                  )}

                  <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-3">
                    {elementsData?.data.elements
                      .filter(el => 
                        el.symbol.toLowerCase().includes(elementSearch.toLowerCase()) ||
                        el.translations.some(tr => tr.name.toLowerCase().includes(elementSearch.toLowerCase()))
                      )
                      .map(el => (
                        <button
                          key={el.id}
                          type="button"
                          onClick={() => toggleElement(el.id)}
                          className={`flex flex-col items-center justify-center p-3 rounded-2xl border transition-all ${
                            selectedElements.includes(el.id)
                              ? 'bg-purple-500/20 border-purple-500/50 text-white shadow-lg shadow-purple-500/10'
                              : 'bg-white/5 border-white/10 text-app-muted hover:border-white/20'
                          }`}
                        >
                          <span className="text-xs font-black mb-1">{el.symbol}</span>
                          <span className="text-[8px] text-app-muted truncate w-full text-center">
                            {el.translations.find(t => t.language_id === 1)?.name}
                          </span>
                        </button>
                      ))}
                  </div>
                </div>
              </div>

              <label className="flex items-center gap-3 cursor-pointer group">
                <div className="relative">
                  <input
                    type="checkbox"
                    checked={formData.is_active}
                    onChange={e => setFormData({ ...formData, is_active: e.target.checked })}
                    className="sr-only"
                  />
                  <div className={`w-12 h-6 rounded-full transition-colors ${formData.is_active ? 'bg-emerald-500/30' : 'bg-white/10'}`} />
                  <div className={`absolute left-1 top-1 w-4 h-4 rounded-full transition-transform ${formData.is_active ? 'translate-x-6 bg-emerald-400' : 'bg-gray-500'}`} />
                </div>
                <span className="text-sm font-medium text-app-subtle">{t('form_is_active', 'Active')}</span>
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
              {editingMine ? t('common.save') : t('common.add')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

export default MinesPage;

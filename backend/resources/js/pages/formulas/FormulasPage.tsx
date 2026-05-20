import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, Atom, Loader2, Calculator, Tag, Beaker } from 'lucide-react';
import { formulaApi, type Formula } from '@/api/formulas';
import { elementApi } from '@/api/elements';
import { languageApi } from '@/api/languages';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { ChemicalFormulaText } from '@/components/ui/ChemicalFormulaText';
import { LanguageFlag } from '@/components/ui/LanguageFlag';

const FormulasPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingFormula, setEditingFormula] = useState<Formula | null>(null);
  const [activeTab, setActiveTab] = useState('base');

  const [formData, setFormData] = useState({
    formula: '',
    molar_mass: 0,
    category: 'salt',
  });

  const [translationsData, setTranslationsData] = useState<Record<number, { name: string }>>({});
  const [elementsData, setElementsData] = useState<{ element_id: number; amount: number }[]>([]);

  const { data: langData } = useQuery({ queryKey: ['languages'], queryFn: languageApi.getAll });
  const { data: elementsDataList } = useQuery({ queryKey: ['elements'], queryFn: elementApi.getAll });
  const { data: formulasData, isLoading } = useQuery({ queryKey: ['formulas'], queryFn: formulaApi.getAll });

  const activeLanguages = useMemo(() => langData?.data.languages.filter(l => l.is_active) || [], [langData]);

  const createMutation = useMutation({
    mutationFn: (data: { formula: string; molar_mass: number; category: string; translations: Record<number, { name: string }> }) => formulaApi.create(data as any),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['formulas'] });
      handleCloseModal();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: { formula: string; molar_mass: number; category: string; translations: Record<number, { name: string }> } }) => formulaApi.update(id, data as any),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['formulas'] });
      handleCloseModal();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: formulaApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['formulas'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
    },
  });

  const handleOpenModal = (formula: Formula | null = null) => {
    if (formula) {
      setEditingFormula(formula);
      setFormData({
        formula: formula.formula,
        molar_mass: formula.molar_mass || 0,
        category: formula.category || 'salt',
      });
      const trans: Record<number, { name: string }> = {};
      formula.translations.forEach(tr => {
        trans[tr.language_id] = { name: tr.name };
      });
      setTranslationsData(trans);
      setElementsData(formula.elements?.map(e => ({ element_id: e.id, amount: e.pivot.amount })) || []);
    } else {
      setEditingFormula(null);
      setFormData({ formula: '', molar_mass: 0, category: 'salt' });
      setTranslationsData({});
      setElementsData([]);
    }
    setActiveTab('base');
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingFormula(null);
  };

  const handleTranslationChange = (langId: number, field: 'name', value: string) => {
    setTranslationsData(prev => ({
      ...prev,
      [langId]: { ...(prev[langId] || { name: '' }), [field]: value }
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      ...formData,
      translations: translationsData,
      elements: elementsData,
    };

    if (editingFormula) {
      updateMutation.mutate({ id: editingFormula.id, data: payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('formulas.title')}</h1>
          <p className="text-app-muted mt-1">{t('formulas.subtitle')}</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('formulas.add_button')}
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {isLoading ? (
          <div className="col-span-full py-20 text-center">
            <Loader2 className="w-10 h-10 animate-spin mx-auto text-purple-500" />
          </div>
        ) : (
          formulasData?.data.formulas.map((formula) => (
            <GlassCard key={formula.id} className="group">
              <div className="flex justify-between items-start mb-6">
                <div className="w-12 h-12 rounded-2xl glass flex items-center justify-center text-emerald-400">
                  <Atom className="w-6 h-6" />
                </div>
                <div className="flex gap-1">
                  <button onClick={() => handleOpenModal(formula)} className="p-2 rounded-xl hover:bg-white/10 text-app-muted hover:text-app-primary transition-all">
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={() => {
                      setDeletingId(formula.id);
                      setIsDeleteModalOpen(true);
                    }} 
                    className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <div className="mb-4">
                <span className="text-sm font-medium text-app-muted block mb-1">
                  {formula.translations.find(t => t.language_id === 1)?.name || t('common.unknown')}
                </span>
                <ChemicalFormulaText
                  formula={formula.formula}
                  className="text-2xl font-black text-app-primary font-mono tracking-normal"
                />
              </div>

              <div className="grid grid-cols-2 gap-4 py-4 border-t border-white/5">
                <div className="space-y-1">
                  <span className="text-[10px] font-bold text-app-muted uppercase tracking-widest flex items-center gap-1">
                    <Calculator className="w-3 h-3" /> {t('formulas.table_mass')}
                  </span>
                  <span className="text-sm font-bold text-app-primary">
                    {formula.molar_mass != null && !Number.isNaN(Number(formula.molar_mass))
                      ? Number(formula.molar_mass).toFixed(4)
                      : '—'}{' '}
                    <small className="text-app-muted">g/mol</small>
                  </span>
                </div>
                <div className="space-y-1">
                  <span className="text-[10px] font-bold text-app-muted uppercase tracking-widest flex items-center gap-1">
                    <Tag className="w-3 h-3" /> {t('formulas.table_category')}
                  </span>
                  <span className="text-sm font-bold text-purple-400 capitalize">
                    {formula.category || 'N/A'}
                  </span>
                </div>
              </div>

              {formula.elements && formula.elements.length > 0 && (
                <div className="flex flex-wrap gap-2 mt-4">
                  {formula.elements.map(el => (
                    <div 
                      key={el.id}
                      className="px-2 py-1 rounded-lg bg-white/5 border border-white/10 flex items-center gap-1"
                    >
                      <span className="text-xs font-bold text-app-primary inline-flex items-baseline gap-0">
                        {el.symbol}
                        {el.pivot.amount > 1 && (
                          <sub className="text-[10px] font-bold text-purple-400 ml-px leading-none">
                            {el.pivot.amount}
                          </sub>
                        )}
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </GlassCard>
          ))
        )}
      </div>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingId && deleteMutation.mutate(deletingId)}
        title={t('formulas.delete_title')}
        message={t('formulas.delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingFormula ? t('formulas.edit_title') : t('formulas.create_title')}
        className="max-w-2xl"
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
        <button
          onClick={() => setActiveTab('elements')}
          className={`flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2 ${
            activeTab === 'elements' ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary"
          }`}
        >
          <Beaker className="w-3 h-3" />
          {t('formulas.form_elements')}
        </button>
      </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {activeTab === 'base' && (
            <div className="space-y-6 animate-in fade-in duration-300">
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('formulas.form_formula')}</label>
                <div className="relative">
                  <Atom className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                  <input
                    type="text"
                    required
                    value={formData.formula}
                    onChange={e => setFormData({ ...formData, formula: e.target.value })}
                    className="input-glass pl-12 font-mono"
                    placeholder="e.g. H2SO4"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('formulas.form_mass')}</label>
                  <div className="relative">
                    <Calculator className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                    <input
                      type="number"
                      step="0.0001"
                      value={formData.molar_mass}
                      onChange={e => setFormData({ ...formData, molar_mass: parseFloat(e.target.value) })}
                      className="input-glass pl-12"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('formulas.form_category')}</label>
                  <div className="relative">
                    <Tag className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                    <select
                      value={formData.category}
                      onChange={e => setFormData({ ...formData, category: e.target.value })}
                      className="input-glass pl-12"
                    >
                      <option value="popular">{t('formulas.category_popular')}</option>
                      <option value="acid">{t('formulas.category_acid')}</option>
                      <option value="base">{t('formulas.category_base')}</option>
                      <option value="salt">{t('formulas.category_salt')}</option>
                      <option value="oxide">{t('formulas.category_oxide')}</option>
                      <option value="carbonate">{t('formulas.category_carbonate')}</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeLanguages.map(lang => activeTab === lang.code && (
            <div key={lang.id} className="space-y-6 animate-in fade-in duration-300">
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('formulas.form_name')} ({lang.name})</label>
                <input
                  type="text"
                  required
                  value={translationsData[lang.id]?.name || ''}
                  onChange={e => handleTranslationChange(lang.id, 'name', e.target.value)}
                  className="input-glass"
                  placeholder="e.g. Sulfat kislota"
                />
              </div>
            </div>
          ))}

          {activeTab === 'elements' && (
            <div className="space-y-4 animate-in fade-in duration-300">
              <div className="flex justify-between items-center mb-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('formulas.form_elements')}</label>
                <button
                  type="button"
                  onClick={() => {
                    const firstEl = elementsDataList?.data.elements[0];
                    if (firstEl) {
                      setElementsData([...elementsData, { element_id: firstEl.id, amount: 1 }]);
                    }
                  }}
                  className="text-xs font-bold text-purple-400 hover:text-purple-300 transition-colors flex items-center gap-1"
                >
                  <Plus className="w-3 h-3" /> {t('common.add')}
                </button>
              </div>

              {elementsData.map((item, index) => (
                <div key={index} className="flex gap-4 items-end animate-in slide-in-from-left-2 duration-200">
                  <div className="flex-1 space-y-2">
                    <label className="text-[10px] font-bold text-app-muted uppercase tracking-widest ml-1">{t('sidebar.elements')}</label>
                    <select
                      value={item.element_id}
                      onChange={e => {
                        const newElements = [...elementsData];
                        newElements[index].element_id = parseInt(e.target.value);
                        setElementsData(newElements);
                      }}
                      className="input-glass"
                    >
                      {elementsDataList?.data.elements.map(el => (
                        <option key={el.id} value={el.id}>
                          {el.symbol} - {el.translations.find(t => t.language_id === 1)?.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="w-24 space-y-2">
                    <label className="text-[10px] font-bold text-app-muted uppercase tracking-widest ml-1">{t('formulas.element_amount')}</label>
                    <input
                      type="number"
                      min="1"
                      value={item.amount}
                      onChange={e => {
                        const newElements = [...elementsData];
                        newElements[index].amount = parseInt(e.target.value);
                        setElementsData(newElements);
                      }}
                      className="input-glass"
                    />
                  </div>
                  <button
                    type="button"
                    onClick={() => setElementsData(elementsData.filter((_, i) => i !== index))}
                    className="p-3 rounded-xl bg-red-500/10 text-red-500 hover:bg-red-500/20 transition-all mb-0.5"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}

              {elementsData.length === 0 && (
                <div className="py-8 text-center border-2 border-dashed border-white/5 rounded-2xl">
                  <p className="text-app-muted text-sm">{t('common.no_results', 'No elements added')}</p>
                </div>
              )}
            </div>
          )}

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
              {editingFormula ? t('common.save') : t('common.create')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

export default FormulasPage;

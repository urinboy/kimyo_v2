import { useState, type FormEvent, type ReactNode } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, Loader2, TestTube } from 'lucide-react';
import { toast } from 'sonner';
import {
  chemicalReactionsApi,
  type ChemicalReactionType,
  type ChemicalReactionSymbol,
} from '@/api/chemicalReactions';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';
import { cn } from '@/lib/utils';

const NAME_LANGS = ['uz', 'ru', 'en', 'kaa'] as const;
type NameLang = (typeof NAME_LANGS)[number];

const FORMULA_CHIPS = ['→', '←', '↔', '+', '=', '↑', '↓', '₂', '₃', 'Δ', '(g)', '(l)', '(s)'] as const;

function FormLabel({ children, required }: { children: ReactNode; required?: boolean }) {
  return (
    <span className="text-sm font-medium text-app-subtle">
      {children}
      {required ? <span className="ml-0.5 text-rose-500" aria-hidden>*</span> : null}
    </span>
  );
}

function pickHexForPreview(hex: string): string {
  const s = hex.replace(/#/g, '');
  if (/^[0-9A-Fa-f]{6}$/.test(s)) return `#${s.toUpperCase()}`;
  return '#9CA3AF';
}

function HexColorRow({
  label,
  value,
  onChange,
  required,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  required?: boolean;
}) {
  const safe = pickHexForPreview(value);
  return (
    <div className="space-y-1.5">
      <FormLabel required={required}>{label}</FormLabel>
      <div className="flex min-w-0 items-center gap-2">
        <span
          className="h-10 w-10 shrink-0 rounded-xl border border-black/10 shadow-inner dark:border-white/15"
          style={{ background: safe }}
          aria-hidden
        />
        <input
          value={value}
          onChange={(e) => onChange(e.target.value.replace(/#/g, '').slice(0, 6).toUpperCase())}
          className="input-glass min-w-0 flex-1 font-mono"
          placeholder="E8F5E9"
          maxLength={6}
          spellCheck={false}
        />
        <input
          type="color"
          className="h-10 w-12 shrink-0 cursor-pointer overflow-hidden rounded-xl border border-black/10 p-0.5 dark:border-white/15"
          value={safe}
          onChange={(e) => onChange(e.target.value.replace('#', '').toUpperCase())}
          title="Color"
        />
      </div>
    </div>
  );
}

const emptyType = (): Omit<ChemicalReactionType, 'id'> => ({
  name_uz: '',
  name_ru: null,
  name_en: null,
  name_kaa: null,
  formula: '',
  color_hex: 'E8F5E9',
  icon_color_hex: '4CAF50',
  order: 0,
});

const emptySymbol = (): Omit<ChemicalReactionSymbol, 'id'> => ({
  symbol: '',
  desc_uz: '',
  desc_ru: null,
  desc_en: null,
  desc_kaa: null,
  order: 0,
});

const ChemicalReactionsPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<'types' | 'symbols'>('types');

  const [typeModalOpen, setTypeModalOpen] = useState(false);
  const [editingType, setEditingType] = useState<ChemicalReactionType | null>(null);
  const [typeForm, setTypeForm] = useState(emptyType);
  const [nameLangTab, setNameLangTab] = useState<NameLang>('uz');

  const [symbolModalOpen, setSymbolModalOpen] = useState(false);
  const [editingSymbol, setEditingSymbol] = useState<ChemicalReactionSymbol | null>(null);
  const [symbolForm, setSymbolForm] = useState(emptySymbol);
  const [descLangTab, setDescLangTab] = useState<NameLang>('uz');

  const [deleteOpen, setDeleteOpen] = useState(false);
  const [deleteKind, setDeleteKind] = useState<'type' | 'symbol'>('type');
  const [deleteId, setDeleteId] = useState<number | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['chemical-reactions'],
    queryFn: chemicalReactionsApi.getAll,
  });

  const types = data?.data.reaction_types ?? [];
  const symbols = data?.data.reaction_symbols ?? [];

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ['chemical-reactions'] });

  const createTypeMut = useMutation({
    mutationFn: () => chemicalReactionsApi.createType(typeForm),
    onSuccess: (res) => {
      if (res?.status === 'success') {
        invalidate();
        setTypeModalOpen(false);
        toast.success(t('common.save_success'));
      }
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const updateTypeMut = useMutation({
    mutationFn: () => {
      if (!editingType) throw new Error('no id');
      return chemicalReactionsApi.updateType(editingType.id, typeForm);
    },
    onSuccess: (res) => {
      if (res?.status === 'success') {
        invalidate();
        setTypeModalOpen(false);
        toast.success(t('common.save_success'));
      }
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const createSymbolMut = useMutation({
    mutationFn: () => chemicalReactionsApi.createSymbol(symbolForm),
    onSuccess: (res) => {
      if (res?.status === 'success') {
        invalidate();
        setSymbolModalOpen(false);
        toast.success(t('common.save_success'));
      }
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const updateSymbolMut = useMutation({
    mutationFn: () => {
      if (!editingSymbol) throw new Error('no id');
      return chemicalReactionsApi.updateSymbol(editingSymbol.id, symbolForm);
    },
    onSuccess: (res) => {
      if (res?.status === 'success') {
        invalidate();
        setSymbolModalOpen(false);
        toast.success(t('common.save_success'));
      }
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const deleteTypeMut = useMutation({
    mutationFn: (id: number) => chemicalReactionsApi.deleteType(id),
    onSuccess: (res) => {
      if (res?.status === 'success') {
        invalidate();
        setDeleteOpen(false);
        toast.success(t('toast.deleted'));
      }
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.delete_error'))),
  });

  const deleteSymbolMut = useMutation({
    mutationFn: (id: number) => chemicalReactionsApi.deleteSymbol(id),
    onSuccess: (res) => {
      if (res?.status === 'success') {
        invalidate();
        setDeleteOpen(false);
        toast.success(t('toast.deleted'));
      }
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.delete_error'))),
  });

  const openTypeNew = () => {
    setEditingType(null);
    setTypeForm(emptyType());
    setNameLangTab('uz');
    setTypeModalOpen(true);
  };

  const openTypeEdit = (row: ChemicalReactionType) => {
    setEditingType(row);
    setNameLangTab('uz');
    setTypeForm({
      name_uz: row.name_uz,
      name_ru: row.name_ru,
      name_en: row.name_en,
      name_kaa: row.name_kaa,
      formula: row.formula,
      color_hex: row.color_hex,
      icon_color_hex: row.icon_color_hex,
      order: row.order,
    });
    setTypeModalOpen(true);
  };

  const openSymbolNew = () => {
    setEditingSymbol(null);
    setSymbolForm(emptySymbol());
    setDescLangTab('uz');
    setSymbolModalOpen(true);
  };

  const openSymbolEdit = (row: ChemicalReactionSymbol) => {
    setEditingSymbol(row);
    setDescLangTab('uz');
    setSymbolForm({
      symbol: row.symbol,
      desc_uz: row.desc_uz,
      desc_ru: row.desc_ru,
      desc_en: row.desc_en,
      desc_kaa: row.desc_kaa,
      order: row.order,
    });
    setSymbolModalOpen(true);
  };

  const submitType = (e: FormEvent) => {
    e.preventDefault();
    if (!typeForm.name_uz?.trim() || !typeForm.formula?.trim()) {
      toast.error(t('chemicalReactions.type_required'));
      return;
    }
    if (editingType) updateTypeMut.mutate();
    else createTypeMut.mutate();
  };

  const submitSymbol = (e: FormEvent) => {
    e.preventDefault();
    if (!symbolForm.symbol?.trim() || !symbolForm.desc_uz?.trim()) {
      toast.error(t('chemicalReactions.symbol_required'));
      return;
    }
    if (editingSymbol) updateSymbolMut.mutate();
    else createSymbolMut.mutate();
  };

  const pendingType = createTypeMut.isPending || updateTypeMut.isPending;
  const pendingSymbol = createSymbolMut.isPending || updateSymbolMut.isPending;
  const pendingDelete = deleteTypeMut.isPending || deleteSymbolMut.isPending;

  const nameLabel = (code: NameLang) => {
    if (code === 'uz') return t('chemicalReactions.name_uz');
    if (code === 'ru') return t('chemicalReactions.name_ru');
    if (code === 'en') return t('chemicalReactions.name_en');
    return t('chemicalReactions.name_kaa');
  };

  const descLabel = (code: NameLang) => {
    if (code === 'uz') return t('chemicalReactions.desc_uz');
    if (code === 'ru') return t('chemicalReactions.desc_ru');
    if (code === 'en') return t('chemicalReactions.desc_en');
    return t('chemicalReactions.desc_kaa');
  };

  const currentNameValue =
    nameLangTab === 'uz'
      ? typeForm.name_uz
      : nameLangTab === 'ru'
        ? (typeForm.name_ru ?? '')
        : nameLangTab === 'en'
          ? (typeForm.name_en ?? '')
          : (typeForm.name_kaa ?? '');

  const setCurrentName = (v: string) => {
    setTypeForm((f) => {
      if (nameLangTab === 'uz') return { ...f, name_uz: v };
      if (nameLangTab === 'ru') return { ...f, name_ru: v || null };
      if (nameLangTab === 'en') return { ...f, name_en: v || null };
      return { ...f, name_kaa: v || null };
    });
  };

  const currentDescValue =
    descLangTab === 'uz'
      ? symbolForm.desc_uz
      : descLangTab === 'ru'
        ? (symbolForm.desc_ru ?? '')
        : descLangTab === 'en'
          ? (symbolForm.desc_en ?? '')
          : (symbolForm.desc_kaa ?? '');

  const setCurrentDesc = (v: string) => {
    setSymbolForm((f) => {
      if (descLangTab === 'uz') return { ...f, desc_uz: v };
      if (descLangTab === 'ru') return { ...f, desc_ru: v || null };
      if (descLangTab === 'en') return { ...f, desc_en: v || null };
      return { ...f, desc_kaa: v || null };
    });
  };

  const appendFormula = (ch: string) => {
    setTypeForm((f) => ({ ...f, formula: f.formula + ch }));
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex flex-col gap-4 sm:flex-row sm:justify-between sm:items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary flex items-center gap-2">
            <TestTube className="w-8 h-8 text-purple-500" />
            {t('chemicalReactions.title')}
          </h1>
          <p className="text-app-muted mt-1">{t('chemicalReactions.subtitle')}</p>
        </div>
        {activeTab === 'types' ? (
          <button type="button" onClick={openTypeNew} className="btn-primary flex w-fit items-center gap-2">
            <Plus className="w-5 h-5" />
            {t('chemicalReactions.add_type')}
          </button>
        ) : (
          <button type="button" onClick={openSymbolNew} className="btn-primary flex w-fit items-center gap-2">
            <Plus className="w-5 h-5" />
            {t('chemicalReactions.add_symbol')}
          </button>
        )}
      </div>

      <div className="flex w-fit gap-2 rounded-2xl border border-white/10 bg-white/5 p-1">
        <button
          type="button"
          onClick={() => setActiveTab('types')}
          className={`rounded-xl px-6 py-2 text-sm font-bold transition-all ${
            activeTab === 'types' ? 'bg-purple-500 text-white shadow-lg shadow-purple-500/20' : 'text-app-muted hover:text-app-primary'
          }`}
        >
          {t('chemicalReactions.tab_types')}
        </button>
        <button
          type="button"
          onClick={() => setActiveTab('symbols')}
          className={`rounded-xl px-6 py-2 text-sm font-bold transition-all ${
            activeTab === 'symbols' ? 'bg-purple-500 text-white shadow-lg shadow-purple-500/20' : 'text-app-muted hover:text-app-primary'
          }`}
        >
          {t('chemicalReactions.tab_symbols')}
        </button>
      </div>

      {isLoading ? (
        <div className="py-20 text-center">
          <Loader2 className="mx-auto h-10 w-10 animate-spin text-purple-500" />
        </div>
      ) : activeTab === 'types' ? (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          {types.map((row) => (
            <GlassCard key={row.id} className="group">
              <div className="mb-2 flex items-start justify-between gap-2">
                <div className="min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <span
                      className="h-3 w-3 shrink-0 rounded-sm border border-white/20"
                      style={{ background: `#${row.color_hex}` }}
                      title={`#${row.color_hex}`}
                    />
                    <span className="font-bold text-app-primary">{row.name_uz}</span>
                  </div>
                  <p className="mt-1 break-all font-mono text-sm text-app-muted">{row.formula}</p>
                </div>
                <div className="flex shrink-0 gap-1">
                  <button
                    type="button"
                    onClick={() => openTypeEdit(row)}
                    className="rounded-xl p-2 text-app-muted transition-colors hover:bg-white/10 hover:text-app-primary"
                  >
                    <Edit2 className="h-4 w-4" />
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setDeleteKind('type');
                      setDeleteId(row.id);
                      setDeleteOpen(true);
                    }}
                    className="rounded-xl p-2 text-app-muted transition-colors hover:bg-red-500/10 hover:text-red-500"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </GlassCard>
          ))}
          {types.length === 0 && (
            <p className="col-span-full py-8 text-center text-app-muted">{t('chemicalReactions.empty_types')}</p>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {symbols.map((row) => (
            <GlassCard key={row.id} className="group">
              <div className="flex items-start justify-between">
                <div className="min-w-0 pr-2">
                  <span className="text-2xl font-bold font-mono text-app-primary">{row.symbol}</span>
                  <p className="mt-1 text-sm text-app-muted break-words">{row.desc_uz}</p>
                </div>
                <div className="flex shrink-0 gap-1">
                  <button
                    type="button"
                    onClick={() => openSymbolEdit(row)}
                    className="rounded-xl p-2 text-app-muted transition-colors hover:bg-white/10 hover:text-app-primary"
                  >
                    <Edit2 className="h-4 w-4" />
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setDeleteKind('symbol');
                      setDeleteId(row.id);
                      setDeleteOpen(true);
                    }}
                    className="rounded-xl p-2 text-app-muted transition-colors hover:bg-red-500/10 hover:text-red-500"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </GlassCard>
          ))}
          {symbols.length === 0 && (
            <p className="col-span-full py-8 text-center text-app-muted">{t('chemicalReactions.empty_symbols')}</p>
          )}
        </div>
      )}

      <GlassModal
        isOpen={typeModalOpen}
        onClose={() => setTypeModalOpen(false)}
        title={editingType ? t('chemicalReactions.edit_type') : t('chemicalReactions.add_type')}
        className="w-full max-w-md sm:max-w-2xl"
      >
        <form
          onSubmit={submitType}
          className="max-h-[min(78vh,720px)] space-y-0 overflow-y-auto overscroll-contain pr-0.5 scrollbar-none sm:pr-1"
        >
          <section className="space-y-3 rounded-2xl border border-black/5 bg-black/2 p-4 dark:border-white/10 dark:bg-white/5">
            <h3 className="text-xs font-bold uppercase tracking-wide text-app-muted">{t('chemicalReactions.section_names')}</h3>
            <div className="flex flex-wrap gap-1.5 rounded-2xl border border-black/10 bg-black/4 p-1 dark:border-white/10 dark:bg-white/5">
              {NAME_LANGS.map((code) => (
                <button
                  key={code}
                  type="button"
                  onClick={() => setNameLangTab(code)}
                  className={cn(
                    'flex items-center gap-1.5 rounded-xl px-3 py-2 text-xs font-bold transition-all',
                    nameLangTab === code
                      ? 'bg-purple-500 text-white shadow-md shadow-purple-500/20'
                      : 'text-app-muted hover:text-app-primary',
                  )}
                >
                  <LanguageFlag code={code} size="sm" className="shrink-0" />
                  {code.toUpperCase()}
                  {code === 'uz' ? <span className="text-rose-300">*</span> : null}
                </button>
              ))}
            </div>
            <div className="space-y-1.5">
              <FormLabel required={nameLangTab === 'uz'}>{nameLabel(nameLangTab)}</FormLabel>
              <input
                value={currentNameValue}
                onChange={(e) => setCurrentName(e.target.value)}
                className="input-glass w-full min-w-0"
                required={nameLangTab === 'uz'}
              />
            </div>
          </section>

          <section className="mt-4 space-y-2 rounded-2xl border border-black/5 bg-black/2 p-4 dark:border-white/10 dark:bg-white/5">
            <h3 className="text-xs font-bold uppercase tracking-wide text-app-muted">{t('chemicalReactions.section_formula')}</h3>
            <div className="space-y-1.5">
              <FormLabel required>{t('chemicalReactions.formula_field')}</FormLabel>
              <textarea
                value={typeForm.formula}
                onChange={(e) => setTypeForm((f) => ({ ...f, formula: e.target.value }))}
                className="input-glass min-h-[3rem] w-full resize-y font-mono text-sm leading-relaxed"
                required
                rows={3}
                spellCheck={false}
              />
            </div>
            <div>
              <p className="mb-1.5 text-[11px] text-app-subtle">{t('chemicalReactions.formula_chips')}</p>
              <div className="flex flex-wrap gap-1.5">
                {FORMULA_CHIPS.map((ch) => (
                  <button
                    key={ch}
                    type="button"
                    onClick={() => appendFormula(ch)}
                    className="rounded-lg border border-black/10 bg-white/50 px-2 py-1 font-mono text-sm text-app-primary transition-colors hover:border-purple-500/40 hover:bg-purple-500/10 dark:border-white/10 dark:bg-white/5"
                  >
                    {ch}
                  </button>
                ))}
              </div>
            </div>
          </section>

          <section className="mt-4 space-y-3 rounded-2xl border border-black/5 bg-black/2 p-4 dark:border-white/10 dark:bg-white/5">
            <h3 className="text-xs font-bold uppercase tracking-wide text-app-muted">{t('chemicalReactions.section_appearance')}</h3>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 sm:gap-5">
              <HexColorRow
                label={t('chemicalReactions.color_hex')}
                value={typeForm.color_hex}
                onChange={(v) => setTypeForm((f) => ({ ...f, color_hex: v }))}
                required
              />
              <HexColorRow
                label={t('chemicalReactions.icon_color_hex')}
                value={typeForm.icon_color_hex}
                onChange={(v) => setTypeForm((f) => ({ ...f, icon_color_hex: v }))}
                required
              />
            </div>
            <p className="text-[11px] text-app-muted leading-snug">{t('chemicalReactions.hex_hint')}</p>
            <div className="max-w-xs space-y-1.5">
              <FormLabel>{t('chemicalReactions.order')}</FormLabel>
              <input
                type="number"
                min={0}
                value={typeForm.order}
                onChange={(e) => setTypeForm((f) => ({ ...f, order: Number(e.target.value) || 0 }))}
                className="input-glass w-full"
              />
            </div>
          </section>

          <div className="mt-5 flex gap-2 border-t border-black/5 pt-4 dark:border-white/10">
            <button
              type="button"
              onClick={() => setTypeModalOpen(false)}
              className="btn-modal-secondary flex-1 rounded-xl py-3"
            >
              {t('common.cancel')}
            </button>
            <button type="submit" disabled={pendingType} className="btn-primary flex-1">
              {pendingType ? '...' : t('common.save')}
            </button>
          </div>
        </form>
      </GlassModal>

      <GlassModal
        isOpen={symbolModalOpen}
        onClose={() => setSymbolModalOpen(false)}
        title={editingSymbol ? t('chemicalReactions.edit_symbol') : t('chemicalReactions.add_symbol')}
        className="w-full max-w-md sm:max-w-lg"
      >
        <form
          onSubmit={submitSymbol}
          className="max-h-[min(78vh,640px)] space-y-0 overflow-y-auto overscroll-contain scrollbar-none"
        >
          <section className="space-y-2 rounded-2xl border border-black/5 bg-black/2 p-4 dark:border-white/10 dark:bg-white/5">
            <div className="space-y-1.5">
              <FormLabel required>{t('chemicalReactions.symbol_char')}</FormLabel>
              <input
                value={symbolForm.symbol}
                onChange={(e) => setSymbolForm((f) => ({ ...f, symbol: e.target.value }))}
                className="input-glass w-full min-w-0 text-center text-2xl font-mono"
                maxLength={16}
                required
                spellCheck={false}
              />
            </div>
          </section>

          <section className="mt-4 space-y-3 rounded-2xl border border-black/5 bg-black/2 p-4 dark:border-white/10 dark:bg-white/5">
            <h3 className="text-xs font-bold uppercase tracking-wide text-app-muted">{t('chemicalReactions.section_descriptions')}</h3>
            <div className="flex flex-wrap gap-1.5 rounded-2xl border border-black/10 bg-black/4 p-1 dark:border-white/10 dark:bg-white/5">
              {NAME_LANGS.map((code) => (
                <button
                  key={code}
                  type="button"
                  onClick={() => setDescLangTab(code)}
                  className={cn(
                    'flex items-center gap-1.5 rounded-xl px-3 py-2 text-xs font-bold transition-all',
                    descLangTab === code
                      ? 'bg-purple-500 text-white shadow-md shadow-purple-500/20'
                      : 'text-app-muted hover:text-app-primary',
                  )}
                >
                  <LanguageFlag code={code} size="sm" className="shrink-0" />
                  {code.toUpperCase()}
                  {code === 'uz' ? <span className="text-rose-300">*</span> : null}
                </button>
              ))}
            </div>
            <div className="space-y-1.5">
              <FormLabel required={descLangTab === 'uz'}>{descLabel(descLangTab)}</FormLabel>
              <input
                value={currentDescValue}
                onChange={(e) => setCurrentDesc(e.target.value)}
                className="input-glass w-full min-w-0"
                required={descLangTab === 'uz'}
              />
            </div>
          </section>

          <div className="mt-4 max-w-xs space-y-1.5 rounded-2xl border border-black/5 bg-black/2 p-4 dark:border-white/10 dark:bg-white/5">
            <FormLabel>{t('chemicalReactions.order')}</FormLabel>
            <input
              type="number"
              min={0}
              value={symbolForm.order}
              onChange={(e) => setSymbolForm((f) => ({ ...f, order: Number(e.target.value) || 0 }))}
              className="input-glass w-full"
            />
          </div>

          <div className="mt-5 flex gap-2 border-t border-black/5 pt-4 dark:border-white/10">
            <button
              type="button"
              onClick={() => setSymbolModalOpen(false)}
              className="btn-modal-secondary flex-1 rounded-xl py-3"
            >
              {t('common.cancel')}
            </button>
            <button type="submit" disabled={pendingSymbol} className="btn-primary flex-1">
              {pendingSymbol ? '...' : t('common.save')}
            </button>
          </div>
        </form>
      </GlassModal>

      <ConfirmModal
        isOpen={deleteOpen}
        onClose={() => setDeleteOpen(false)}
        onConfirm={() => {
          if (deleteId == null) return;
          if (deleteKind === 'type') deleteTypeMut.mutate(deleteId);
          else deleteSymbolMut.mutate(deleteId);
        }}
        title={t('settings.delete_confirm_title')}
        message={t('settings.delete_confirm_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={pendingDelete}
      />
    </div>
  );
};

export default ChemicalReactionsPage;

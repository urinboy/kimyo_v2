import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { labWorksApi } from '@/api/labWorks';
import type { LabWork, LabExperiment, LabReaction, LabProduct } from '@/api/labWorks';
import { X, Plus, Trash2, FlaskConical, ChevronDown, ChevronUp } from 'lucide-react';
import { toast } from 'sonner';

// ─── Types ────────────────────────────────────────────────────────────────────
interface Props {
  labWork: LabWork | null;
  onClose: () => void;
}

const LANGS = ['uz', 'ru', 'en'] as const;
type LangCode = typeof LANGS[number];

const LANG_LABELS: Record<LangCode, string> = { uz: "O'zbek", ru: 'Русский', en: 'English' };

function emptyExperiment(): LabExperiment {
  return {
    type: 'probirka',
    order_index: 1,
    status: 'active',
    translations: LANGS.map(lc => ({ language_code: lc, title: '', scientific_explanation: '' })),
    reactions: [{ formula: '', type: 'molecular', order_index: 1 }],
    observations: [{ order_index: 1, translations: LANGS.map(lc => ({ language_code: lc, text: '' })) }],
    products: [{ chemical_formula: '', state: 'dissolved', order_index: 1, translations: LANGS.map(lc => ({ language_code: lc, name: '' })) }],
  };
}

// ─── Main Modal ───────────────────────────────────────────────────────────────
export function LabWorkModal({ labWork, onClose }: Props) {
  const qc = useQueryClient();
  const isEdit = !!labWork;

  const [number, setNumber] = useState(labWork?.number ?? 1);
  const [status, setStatus] = useState<'active' | 'inactive'>(labWork?.status ?? 'active');
  const [translations, setTranslations] = useState(
    LANGS.map(lc => ({
      language_code: lc,
      title: labWork?.translations.find(t => (t as unknown as { language?: { code: string } }).language?.code === lc)?.title ?? '',
      description: labWork?.translations.find(t => (t as unknown as { language?: { code: string } }).language?.code === lc)?.description ?? '',
    }))
  );
  const [experiments, setExperiments] = useState<LabExperiment[]>(labWork?.experiments ?? []);
  const [activeLang, setActiveLang] = useState<LangCode>('uz');
  const [expandedExp, setExpandedExp] = useState<number | null>(0);

  const mutation = useMutation({
    mutationFn: (data: Partial<LabWork>) =>
      isEdit ? labWorksApi.update(labWork!.id, data) : labWorksApi.create(data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['lab-works'] });
      toast.success(isEdit ? 'Laboratoriya yangilandi' : 'Laboratoriya qo\'shildi');
      onClose();
    },
    onError: () => toast.error('Xato yuz berdi'),
  });

  const handleSubmit = () => {
    if (!translations.find(t => t.language_code === 'uz')?.title.trim()) {
      toast.error("O'zbek tilidagi sarlavha majburiy");
      return;
    }
    mutation.mutate({ number, status, translations, experiments });
  };

  // ─── Experiment helpers ───────────────────────────────────────────────────
  const addExperiment = () => {
    const e = emptyExperiment();
    e.order_index = experiments.length + 1;
    setExperiments(prev => [...prev, e]);
    setExpandedExp(experiments.length);
  };

  const removeExperiment = (idx: number) => {
    setExperiments(prev => prev.filter((_, i) => i !== idx));
    setExpandedExp(null);
  };

  const updateExp = (idx: number, partial: Partial<LabExperiment>) => {
    setExperiments(prev => prev.map((e, i) => i === idx ? { ...e, ...partial } : e));
  };

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto pt-8 pb-8 px-4 bg-black/40 backdrop-blur-sm">
      <div className="w-full max-w-3xl glass rounded-3xl border border-white/20 shadow-2xl animate-in fade-in slide-in-from-bottom-4 duration-300">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-black/5 dark:border-white/10">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-xl bg-purple-500/10">
              <FlaskConical className="w-5 h-5 text-purple-600 dark:text-purple-400" />
            </div>
            <h2 className="text-xl font-bold text-app-primary">
              {isEdit ? 'Laboratoriyani tahrirlash' : 'Yangi laboratoriya'}
            </h2>
          </div>
          <button onClick={onClose} className="p-2 rounded-xl hover:bg-black/5 dark:hover:bg-white/5 text-app-muted transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-6 space-y-6">
          {/* Basic info */}
          <div className="flex gap-4">
            <div className="w-28">
              <label className="text-kpi-label block mb-2">Lab raqami</label>
              <input
                type="number"
                min={1}
                max={255}
                value={number}
                onChange={e => setNumber(Number(e.target.value))}
                className="w-full px-3 py-2.5 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm font-bold bg-transparent focus:outline-none focus:border-purple-500/50"
              />
            </div>
            <div className="w-36">
              <label className="text-kpi-label block mb-2">Status</label>
              <select
                value={status}
                onChange={e => setStatus(e.target.value as 'active' | 'inactive')}
                className="w-full px-3 py-2.5 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm bg-transparent focus:outline-none focus:border-purple-500/50"
              >
                <option value="active">Faol</option>
                <option value="inactive">Nofaol</option>
              </select>
            </div>
          </div>

          {/* Language tabs */}
          <div>
            <div className="flex gap-1 mb-3 border-b border-black/5 dark:border-white/5">
              {LANGS.map(lc => (
                <button
                  key={lc}
                  onClick={() => setActiveLang(lc)}
                  className={`px-4 py-2 text-sm font-bold rounded-t-xl transition-colors ${
                    activeLang === lc
                      ? 'bg-purple-500/10 text-purple-600 dark:text-purple-400 border-b-2 border-purple-500'
                      : 'text-app-muted hover:text-app-primary'
                  }`}
                >
                  {LANG_LABELS[lc]}
                </button>
              ))}
            </div>

            {translations.map((t, idx) => (
              <div key={t.language_code} className={t.language_code !== activeLang ? 'hidden' : 'space-y-3'}>
                <div>
                  <label className="text-kpi-label block mb-1.5">Sarlavha *</label>
                  <input
                    value={t.title}
                    onChange={e => setTranslations(prev => prev.map((x, i) => i === idx ? { ...x, title: e.target.value } : x))}
                    placeholder={`${number}-Laboratoriya: ...`}
                    className="w-full px-3 py-2.5 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm bg-transparent focus:outline-none focus:border-purple-500/50"
                  />
                </div>
                <div>
                  <label className="text-kpi-label block mb-1.5">Tavsif (ixtiyoriy)</label>
                  <textarea
                    value={t.description ?? ''}
                    onChange={e => setTranslations(prev => prev.map((x, i) => i === idx ? { ...x, description: e.target.value } : x))}
                    rows={2}
                    className="w-full px-3 py-2.5 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm bg-transparent focus:outline-none focus:border-purple-500/50 resize-none"
                  />
                </div>
              </div>
            ))}
          </div>

          {/* Experiments */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-bold text-app-primary text-sm">Tajribalar ({experiments.length})</h3>
              <button onClick={addExperiment} className="flex items-center gap-1.5 text-xs font-bold text-purple-600 dark:text-purple-400 hover:underline">
                <Plus className="w-3.5 h-3.5" /> Tajriba qo'shish
              </button>
            </div>

            <div className="space-y-2">
              {experiments.map((exp, expIdx) => (
                <ExperimentBlock
                  key={expIdx}
                  exp={exp}
                  expIdx={expIdx}
                  activeLang={activeLang}
                  isExpanded={expandedExp === expIdx}
                  onToggle={() => setExpandedExp(expandedExp === expIdx ? null : expIdx)}
                  onChange={partial => updateExp(expIdx, partial)}
                  onRemove={() => removeExperiment(expIdx)}
                />
              ))}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-end gap-3 px-6 py-4 border-t border-black/5 dark:border-white/10">
          <button onClick={onClose} className="px-5 py-2.5 rounded-xl glass border border-black/10 dark:border-white/10 text-sm font-bold text-app-muted hover:bg-black/5 dark:hover:bg-white/5 transition-colors">
            Bekor
          </button>
          <button
            onClick={handleSubmit}
            disabled={mutation.isPending}
            className="btn-primary px-6 py-2.5 text-sm disabled:opacity-50"
          >
            {mutation.isPending ? 'Saqlanmoqda...' : isEdit ? 'Saqlash' : 'Qo\'shish'}
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Experiment block ─────────────────────────────────────────────────────────
interface ExpBlockProps {
  exp: LabExperiment;
  expIdx: number;
  activeLang: LangCode;
  isExpanded: boolean;
  onToggle: () => void;
  onChange: (partial: Partial<LabExperiment>) => void;
  onRemove: () => void;
}

function ExperimentBlock({ exp, expIdx, activeLang, isExpanded, onToggle, onChange, onRemove }: ExpBlockProps) {
  const uzTrans = exp.translations.find(t => t.language_code === 'uz');
  const label = uzTrans?.title || `${expIdx + 1}-tajriba`;

  const updateTrans = (lc: string, field: string, value: string) => {
    onChange({
      translations: exp.translations.map(t =>
        t.language_code === lc ? { ...t, [field]: value } : t
      ),
    });
  };

  const updateReaction = (i: number, partial: Partial<LabReaction>) => {
    onChange({ reactions: exp.reactions.map((r, ri) => ri === i ? { ...r, ...partial } : r) });
  };

  const addReaction = () => {
    onChange({ reactions: [...exp.reactions, { formula: '', type: 'molecular', order_index: exp.reactions.length + 1 }] });
  };

  const removeReaction = (i: number) => {
    onChange({ reactions: exp.reactions.filter((_, ri) => ri !== i) });
  };

  const updateObsTrans = (obsIdx: number, lc: string, value: string) => {
    onChange({
      observations: exp.observations.map((ob, oi) =>
        oi === obsIdx
          ? { ...ob, translations: ob.translations.map(t => t.language_code === lc ? { ...t, text: value } : t) }
          : ob
      ),
    });
  };

  const addObs = () => {
    onChange({
      observations: [...exp.observations, { order_index: exp.observations.length + 1, translations: LANGS.map(lc => ({ language_code: lc, text: '' })) }],
    });
  };

  const removeObs = (i: number) => {
    onChange({ observations: exp.observations.filter((_, oi) => oi !== i) });
  };

  const updateProduct = (i: number, partial: Partial<LabProduct>) => {
    onChange({ products: exp.products.map((p, pi) => pi === i ? { ...p, ...partial } : p) });
  };

  const updateProdTrans = (prodIdx: number, lc: string, value: string) => {
    onChange({
      products: exp.products.map((p, pi) =>
        pi === prodIdx
          ? { ...p, translations: p.translations.map(t => t.language_code === lc ? { ...t, name: value } : t) }
          : p
      ),
    });
  };

  const addProduct = () => {
    onChange({
      products: [...exp.products, { chemical_formula: '', state: 'dissolved', order_index: exp.products.length + 1, translations: LANGS.map(lc => ({ language_code: lc, name: '' })) }],
    });
  };

  const removeProduct = (i: number) => {
    onChange({ products: exp.products.filter((_, pi) => pi !== i) });
  };

  return (
    <div className="rounded-2xl border border-black/10 dark:border-white/10 overflow-hidden">
      {/* Exp header */}
      <div
        className="flex items-center gap-3 px-4 py-3 bg-black/[0.02] dark:bg-white/[0.02] cursor-pointer select-none"
        onClick={onToggle}
      >
        <div className="w-6 h-6 rounded-lg bg-purple-500/10 flex items-center justify-center text-purple-600 dark:text-purple-400 text-xs font-black flex-shrink-0">
          {expIdx + 1}
        </div>
        <span className="flex-1 text-sm font-bold text-app-primary truncate">{label}</span>
        <select
          value={exp.type}
          onClick={e => e.stopPropagation()}
          onChange={e => onChange({ type: e.target.value as LabExperiment['type'] })}
          className="text-xs bg-transparent border border-black/10 dark:border-white/10 rounded-lg px-2 py-1 text-app-muted"
        >
          <option value="probirka">Probirka</option>
          <option value="tajriba">Tajriba</option>
          <option value="bosqich">Bosqich</option>
        </select>
        <button onClick={e => { e.stopPropagation(); onRemove(); }} className="p-1 hover:text-red-500 text-app-muted transition-colors">
          <Trash2 className="w-3.5 h-3.5" />
        </button>
        {isExpanded ? <ChevronUp className="w-4 h-4 text-app-muted" /> : <ChevronDown className="w-4 h-4 text-app-muted" />}
      </div>

      {isExpanded && (
        <div className="p-4 space-y-4 border-t border-black/5 dark:border-white/5">
          {/* Translations */}
          <div className="space-y-2">
            <p className="text-xs font-bold text-app-muted uppercase tracking-wide">Tarjima ({LANG_LABELS[activeLang]})</p>
            {exp.translations.filter(t => t.language_code === activeLang).map((t) => (
              <div key={t.language_code} className="space-y-2">
                <input
                  value={t.title}
                  onChange={e => updateTrans(t.language_code!, 'title', e.target.value)}
                  placeholder="Sarlavha (masalan: 1-probirka: ...)"
                  className="w-full px-3 py-2 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm bg-transparent focus:outline-none focus:border-purple-500/50"
                />
                <textarea
                  value={t.scientific_explanation ?? ''}
                  onChange={e => updateTrans(t.language_code!, 'scientific_explanation', e.target.value)}
                  placeholder="Ilmiy izoh (ixtiyoriy)"
                  rows={2}
                  className="w-full px-3 py-2 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm bg-transparent focus:outline-none focus:border-purple-500/50 resize-none"
                />
              </div>
            ))}
          </div>

          {/* Reactions */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <p className="text-xs font-bold text-app-muted uppercase tracking-wide">Reaksiyalar</p>
              <button onClick={addReaction} className="text-xs text-purple-600 dark:text-purple-400 font-bold hover:underline flex items-center gap-1">
                <Plus className="w-3 h-3" /> Qo'shish
              </button>
            </div>
            {exp.reactions.map((r, ri) => (
              <div key={ri} className="flex gap-2 items-center">
                <input
                  value={r.formula}
                  onChange={e => updateReaction(ri, { formula: e.target.value })}
                  placeholder="Cu+2AgNO3→Cu(NO3)2+2Ag↓"
                  className="flex-1 px-3 py-2 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm font-mono bg-transparent focus:outline-none focus:border-purple-500/50"
                />
                <select
                  value={r.type}
                  onChange={e => updateReaction(ri, { type: e.target.value as LabReaction['type'] })}
                  className="text-xs bg-transparent border border-black/10 dark:border-white/10 rounded-xl px-2 py-2 text-app-muted"
                >
                  <option value="molecular">Mol.</option>
                  <option value="full_ionic">To'la ion</option>
                  <option value="short_ionic">Qisqa ion</option>
                </select>
                {exp.reactions.length > 1 && (
                  <button onClick={() => removeReaction(ri)} className="p-1.5 hover:text-red-500 text-app-muted">
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                )}
              </div>
            ))}
          </div>

          {/* Observations */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <p className="text-xs font-bold text-app-muted uppercase tracking-wide">Kuzatish holatlari ({LANG_LABELS[activeLang]})</p>
              <button onClick={addObs} className="text-xs text-purple-600 dark:text-purple-400 font-bold hover:underline flex items-center gap-1">
                <Plus className="w-3 h-3" /> Qo'shish
              </button>
            </div>
            {exp.observations.map((ob, oi) => {
              const t = ob.translations.find(x => x.language_code === activeLang);
              return (
                <div key={oi} className="flex gap-2 items-center">
                  <span className="text-xs text-app-muted w-5 text-center">{oi + 1}.</span>
                  <input
                    value={t?.text ?? ''}
                    onChange={e => updateObsTrans(oi, activeLang, e.target.value)}
                    placeholder="Kuzatish holati..."
                    className="flex-1 px-3 py-2 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm bg-transparent focus:outline-none focus:border-purple-500/50"
                  />
                  {exp.observations.length > 1 && (
                    <button onClick={() => removeObs(oi)} className="p-1.5 hover:text-red-500 text-app-muted">
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  )}
                </div>
              );
            })}
          </div>

          {/* Products */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <p className="text-xs font-bold text-app-muted uppercase tracking-wide">Hosil bo'lgan moddalar</p>
              <button onClick={addProduct} className="text-xs text-purple-600 dark:text-purple-400 font-bold hover:underline flex items-center gap-1">
                <Plus className="w-3 h-3" /> Qo'shish
              </button>
            </div>
            {exp.products.map((prod, pi) => {
              const t = prod.translations.find(x => x.language_code === activeLang);
              return (
                <div key={pi} className="flex gap-2 items-center">
                  <input
                    value={prod.chemical_formula}
                    onChange={e => updateProduct(pi, { chemical_formula: e.target.value })}
                    placeholder="Cu(NO3)2"
                    className="w-28 px-3 py-2 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm font-mono bg-transparent focus:outline-none focus:border-purple-500/50"
                  />
                  <input
                    value={t?.name ?? ''}
                    onChange={e => updateProdTrans(pi, activeLang, e.target.value)}
                    placeholder="Mis(II)-nitrat"
                    className="flex-1 px-3 py-2 rounded-xl glass border border-black/10 dark:border-white/10 text-app-primary text-sm bg-transparent focus:outline-none focus:border-purple-500/50"
                  />
                  <select
                    value={prod.state}
                    onChange={e => updateProduct(pi, { state: e.target.value as LabProduct['state'] })}
                    className="text-xs bg-transparent border border-black/10 dark:border-white/10 rounded-xl px-2 py-2 text-app-muted"
                  >
                    <option value="dissolved">Erigan</option>
                    <option value="precipitate">Cho'kma↓</option>
                    <option value="gas">Gaz↑</option>
                    <option value="solid">Qattiq</option>
                    <option value="unknown">Noma'lum</option>
                  </select>
                  {exp.products.length > 1 && (
                    <button onClick={() => removeProduct(pi)} className="p-1.5 hover:text-red-500 text-app-muted">
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}

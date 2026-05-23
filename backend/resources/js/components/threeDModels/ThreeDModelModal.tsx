import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Upload, X, Box } from 'lucide-react';
import { GlassModal } from '@/components/ui/GlassModal';
import type { ThreeDModel, ThreeDModelPayload, ThreeDModelTranslation } from '@/api/threeDModels';

type LangTab = 'uz' | 'ru' | 'en';

const emptyTranslations = (): Record<LangTab, { name: string; description: string }> => ({
  uz: { name: '', description: '' },
  ru: { name: '', description: '' },
  en: { name: '', description: '' },
});

interface ThreeDModelModalProps {
  isOpen: boolean;
  onClose: () => void;
  editing: ThreeDModel | null;
  onSubmit: (payload: ThreeDModelPayload) => void;
  isPending: boolean;
}

export function ThreeDModelModal({ isOpen, onClose, editing, onSubmit, isPending }: ThreeDModelModalProps) {
  const { t } = useTranslation();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [slug, setSlug]                         = useState('');
  const [modelFile, setModelFile]               = useState<File | null>(null);
  const [removeModelFile, setRemoveModelFile]   = useState(false);
  const [elementId, setElementId]               = useState<string>('');
  const [sortOrder, setSortOrder]               = useState(0);
  const [isActive, setIsActive]                 = useState(true);
  const [langTab, setLangTab]                   = useState<LangTab>('uz');
  const [translations, setTranslations]         = useState(emptyTranslations());

  useEffect(() => {
    if (!isOpen) return;
    if (editing) {
      setSlug(editing.slug);
      setElementId(editing.element_id != null ? String(editing.element_id) : '');
      setSortOrder(editing.sort_order);
      setIsActive(editing.is_active);
      setModelFile(null);
      setRemoveModelFile(false);
      const next = emptyTranslations();
      for (const tr of editing.translations) {
        const code = (tr.language_code || 'uz') as LangTab;
        if (code in next) {
          next[code] = { name: tr.name, description: tr.description || '' };
        }
      }
      setTranslations(next);
    } else {
      setSlug('');
      setElementId('');
      setSortOrder(0);
      setIsActive(true);
      setModelFile(null);
      setRemoveModelFile(false);
      setTranslations(emptyTranslations());
    }
    setLangTab('uz');
  }, [isOpen, editing]);

  const existingModelUrl  = editing?.model_url;
  const existingModelName = editing?.model_path?.split('/').pop();

  const canSave = slug.trim() && translations.uz.name.trim();

  const handleSave = () => {
    if (!canSave) return;

    const translationList: ThreeDModelTranslation[] = (['uz', 'ru', 'en'] as LangTab[])
      .filter((code) => translations[code].name.trim())
      .map((code) => ({
        language_code: code,
        name: translations[code].name.trim(),
        description: translations[code].description.trim() || null,
      }));

    const payload: ThreeDModelPayload = {
      slug: slug.trim(),
      model_file: modelFile ?? null,
      remove_model_file: removeModelFile,
      element_id: elementId.trim() ? Number(elementId) : null,
      sort_order: sortOrder,
      is_active: isActive,
      translations: translationList,
    };

    onSubmit(payload);
  };

  return (
    <GlassModal
      isOpen={isOpen}
      onClose={onClose}
      title={editing ? t('three_d_models.edit_title') : t('three_d_models.add_title')}
      className="max-w-2xl"
    >
      <div className="space-y-5 max-h-[70vh] overflow-y-auto pr-1">

        {/* Slug */}
        <div>
          <label className="text-caption block mb-1">{t('three_d_models.slug_label')}</label>
          <input
            className="input-glass w-full font-mono"
            value={slug}
            onChange={(e) => setSlug(e.target.value.toLowerCase().replace(/\s+/g, '_'))}
            placeholder="masalan: iron_ore"
          />
          <p className="text-xs text-gray-400 mt-1">{t('three_d_models.slug_hint')}</p>
        </div>

        {/* GLB fayl yuklash */}
        <div>
          <label className="text-caption block mb-2">{t('three_d_models.model_file_label')}</label>

          {/* Mavjud fayl */}
          {existingModelUrl && !modelFile && !removeModelFile && (
            <div className="flex items-center gap-3 mb-3 p-3 rounded-xl bg-black/5 dark:bg-white/5">
              <div className="w-12 h-12 rounded-xl bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center">
                <Box className="w-6 h-6 text-purple-500" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">{existingModelName}</p>
                <p className="text-xs text-gray-400">{t('three_d_models.current_file')}</p>
              </div>
              <button
                type="button"
                onClick={() => setRemoveModelFile(true)}
                className="text-red-400 hover:text-red-600"
                title={t('three_d_models.remove_file')}
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          )}

          {removeModelFile && (
            <div className="mb-3 p-2 rounded-xl bg-red-50 dark:bg-red-900/20 text-red-500 text-sm flex justify-between items-center">
              <span>{t('three_d_models.file_will_be_removed')}</span>
              <button type="button" onClick={() => setRemoveModelFile(false)} className="underline">
                {t('common.cancel')}
              </button>
            </div>
          )}

          <input
            ref={fileInputRef}
            type="file"
            accept=".glb,.gltf"
            className="hidden"
            onChange={(e) => {
              const f = e.target.files?.[0] ?? null;
              setModelFile(f);
              setRemoveModelFile(false);
            }}
          />

          {modelFile ? (
            <div className="flex items-center gap-3 p-3 rounded-xl bg-purple-50 dark:bg-purple-900/20">
              <div className="w-12 h-12 rounded-xl bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center">
                <Box className="w-6 h-6 text-purple-500" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">{modelFile.name}</p>
                <p className="text-xs text-gray-400">{(modelFile.size / 1024 / 1024).toFixed(2)} MB</p>
              </div>
              <button
                type="button"
                onClick={() => {
                  setModelFile(null);
                  if (fileInputRef.current) fileInputRef.current.value = '';
                }}
                className="text-red-400 hover:text-red-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          ) : (
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              className="w-full border-2 border-dashed border-purple-300 dark:border-purple-700 rounded-2xl p-8 flex flex-col items-center gap-2 hover:border-purple-500 transition-colors"
            >
              <Upload className="w-8 h-8 text-purple-400" />
              <span className="text-sm text-gray-500">{t('three_d_models.upload_hint')}</span>
              <span className="text-xs text-gray-400">GLB / GLTF — max 100MB</span>
            </button>
          )}
        </div>

        {/* Element ID (ixtiyoriy) */}
        <div>
          <label className="text-caption block mb-1">{t('three_d_models.element_id_label')}</label>
          <input
            type="number"
            min={1}
            className="input-glass w-full"
            value={elementId}
            onChange={(e) => setElementId(e.target.value)}
            placeholder={t('three_d_models.element_id_placeholder')}
          />
        </div>

        {/* Sort & Active */}
        <div className="flex gap-4 flex-wrap">
          <div className="flex-1 min-w-[120px]">
            <label className="text-caption block mb-1">{t('three_d_models.sort_order')}</label>
            <input
              type="number"
              min={0}
              className="input-glass w-full"
              value={sortOrder}
              onChange={(e) => setSortOrder(Number(e.target.value) || 0)}
            />
          </div>
          <label className="flex items-center gap-2 mt-6 cursor-pointer select-none">
            <input type="checkbox" checked={isActive} onChange={(e) => setIsActive(e.target.checked)} />
            <span className="text-sm">{t('three_d_models.is_active')}</span>
          </label>
        </div>

        {/* Tarjimalar */}
        <div className="flex gap-2">
          {(['uz', 'ru', 'en'] as LangTab[]).map((code) => (
            <button
              key={code}
              type="button"
              onClick={() => setLangTab(code)}
              className={`px-3 py-1.5 rounded-xl text-sm font-medium ${
                langTab === code ? 'bg-purple-500 text-white' : 'bg-black/5 dark:bg-white/10'
              }`}
            >
              {code.toUpperCase()}
            </button>
          ))}
        </div>

        <div>
          <label className="text-caption block mb-1">{t('three_d_models.name_label')}</label>
          <input
            className="input-glass w-full"
            value={translations[langTab].name}
            onChange={(e) =>
              setTranslations((prev) => ({
                ...prev,
                [langTab]: { ...prev[langTab], name: e.target.value },
              }))
            }
          />
        </div>
        <div>
          <label className="text-caption block mb-1">{t('three_d_models.description_label')}</label>
          <textarea
            className="input-glass w-full min-h-[80px]"
            value={translations[langTab].description}
            onChange={(e) =>
              setTranslations((prev) => ({
                ...prev,
                [langTab]: { ...prev[langTab], description: e.target.value },
              }))
            }
          />
        </div>
      </div>

      <div className="flex gap-3 mt-6">
        <button type="button" onClick={onClose} className="flex-1 btn-modal-secondary">
          {t('common.cancel')}
        </button>
        <button
          type="button"
          onClick={handleSave}
          disabled={isPending || !canSave}
          className="flex-1 btn-primary"
        >
          {isPending ? '...' : t('common.save')}
        </button>
      </div>
    </GlassModal>
  );
}

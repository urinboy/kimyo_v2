import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { GlassModal } from '@/components/ui/GlassModal';
import type { Video, VideoTranslation } from '@/api/videos';

type LangTab = 'uz' | 'ru' | 'en';

const emptyTranslations = (): Record<LangTab, { title: string; description: string }> => ({
  uz: { title: '', description: '' },
  ru: { title: '', description: '' },
  en: { title: '', description: '' },
});

function extractYoutubeId(url: string): string | null {
  const t = url.trim();
  if (/^[a-zA-Z0-9_-]{11}$/.test(t)) return t;
  const patterns = [
    /(?:youtube\.com\/watch\?[^#]*v=|youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})/,
    /youtu\.be\/([a-zA-Z0-9_-]{11})/,
    /youtube\.com\/embed\/([a-zA-Z0-9_-]{11})/,
    /youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})/,
  ];
  for (const p of patterns) {
    const m = t.match(p);
    if (m) return m[1];
  }
  return null;
}

interface VideoModalProps {
  isOpen: boolean;
  onClose: () => void;
  editing: Video | null;
  onSubmit: (payload: {
    youtube_url: string;
    channel_name: string;
    sort_order: number;
    is_active: boolean;
    translations: VideoTranslation[];
  }) => void;
  isPending: boolean;
}

export function VideoModal({ isOpen, onClose, editing, onSubmit, isPending }: VideoModalProps) {
  const { t } = useTranslation();
  const [youtubeUrl, setYoutubeUrl] = useState('');
  const [channelName, setChannelName] = useState('');
  const [sortOrder, setSortOrder] = useState(0);
  const [isActive, setIsActive] = useState(true);
  const [langTab, setLangTab] = useState<LangTab>('uz');
  const [translations, setTranslations] = useState(emptyTranslations());

  useEffect(() => {
    if (!isOpen) return;
    if (editing) {
      setYoutubeUrl(editing.youtube_url || '');
      setChannelName(editing.channel_name || '');
      setSortOrder(editing.sort_order);
      setIsActive(editing.is_active);
      const next = emptyTranslations();
      for (const tr of editing.translations) {
        const code = (tr.language_code || 'uz') as LangTab;
        if (code in next) {
          next[code] = { title: tr.title, description: tr.description || '' };
        }
      }
      setTranslations(next);
    } else {
      setYoutubeUrl('');
      setChannelName('');
      setSortOrder(0);
      setIsActive(true);
      setTranslations(emptyTranslations());
    }
    setLangTab('uz');
  }, [isOpen, editing]);

  const previewId = useMemo(() => extractYoutubeId(youtubeUrl), [youtubeUrl]);
  const thumbnail = previewId ? `https://img.youtube.com/vi/${previewId}/hqdefault.jpg` : null;

  const handleSave = () => {
    const id = extractYoutubeId(youtubeUrl);
    if (!id) return;
    if (!translations.uz.title.trim()) return;

    onSubmit({
      youtube_url: youtubeUrl.trim(),
      channel_name: channelName.trim(),
      sort_order: sortOrder,
      is_active: isActive,
      translations: (['uz', 'ru', 'en'] as LangTab[])
        .filter((code) => translations[code].title.trim())
        .map((code) => ({
          language_code: code,
          title: translations[code].title.trim(),
          description: translations[code].description.trim() || null,
        })),
    });
  };

  return (
    <GlassModal
      isOpen={isOpen}
      onClose={onClose}
      title={editing ? t('videos.edit_title') : t('videos.add_title')}
      className="max-w-2xl"
    >
      <div className="space-y-5 max-h-[70vh] overflow-y-auto pr-1">
        <div>
          <label className="text-caption block mb-1">{t('videos.youtube_url')}</label>
          <input
            className="input-glass w-full"
            value={youtubeUrl}
            onChange={(e) => setYoutubeUrl(e.target.value)}
            placeholder="https://www.youtube.com/watch?v=..."
          />
          {!previewId && youtubeUrl.trim() && (
            <p className="text-xs text-red-500 mt-1">{t('videos.invalid_url')}</p>
          )}
        </div>

        {thumbnail && (
          <img src={thumbnail} alt="" className="w-full max-w-md rounded-2xl border border-black/10 dark:border-white/10" />
        )}

        <div>
          <label className="text-caption block mb-1">{t('videos.channel_name')}</label>
          <input
            className="input-glass w-full"
            value={channelName}
            onChange={(e) => setChannelName(e.target.value)}
            placeholder={t('videos.channel_placeholder')}
          />
        </div>

        <div className="flex gap-4 flex-wrap">
          <div className="flex-1 min-w-[120px]">
            <label className="text-caption block mb-1">{t('videos.sort_order')}</label>
            <input
              type="number"
              min={0}
              className="input-glass w-full"
              value={sortOrder}
              onChange={(e) => setSortOrder(Number(e.target.value) || 0)}
            />
          </div>
          <label className="flex items-center gap-2 mt-6 cursor-pointer">
            <input type="checkbox" checked={isActive} onChange={(e) => setIsActive(e.target.checked)} />
            <span className="text-sm">{t('videos.is_active')}</span>
          </label>
        </div>

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
          <label className="text-caption block mb-1">{t('videos.title_label')}</label>
          <input
            className="input-glass w-full"
            value={translations[langTab].title}
            onChange={(e) =>
              setTranslations((prev) => ({
                ...prev,
                [langTab]: { ...prev[langTab], title: e.target.value },
              }))
            }
          />
        </div>
        <div>
          <label className="text-caption block mb-1">{t('videos.description_label')}</label>
          <textarea
            className="input-glass w-full min-h-[100px]"
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
          disabled={isPending || !previewId || !translations.uz.title.trim()}
          className="flex-1 btn-primary"
        >
          {isPending ? '...' : t('common.save')}
        </button>
      </div>
    </GlassModal>
  );
}

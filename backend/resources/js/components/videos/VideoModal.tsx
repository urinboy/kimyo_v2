import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Upload, X } from 'lucide-react';
import { GlassModal } from '@/components/ui/GlassModal';
import type { Video, VideoPayload, VideoTranslation } from '@/api/videos';

type LangTab = 'uz' | 'ru' | 'en';
type SourceType = 'youtube' | 'file';

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
  onSubmit: (payload: VideoPayload) => void;
  isPending: boolean;
}

export function VideoModal({ isOpen, onClose, editing, onSubmit, isPending }: VideoModalProps) {
  const { t } = useTranslation();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [sourceType, setSourceType] = useState<SourceType>('youtube');
  const [youtubeUrl, setYoutubeUrl] = useState('');
  const [videoFile, setVideoFile] = useState<File | null>(null);
  const [removeVideoFile, setRemoveVideoFile] = useState(false);
  const [channelName, setChannelName] = useState('');
  const [sortOrder, setSortOrder] = useState(0);
  const [isActive, setIsActive] = useState(true);
  const [langTab, setLangTab] = useState<LangTab>('uz');
  const [translations, setTranslations] = useState(emptyTranslations());

  useEffect(() => {
    if (!isOpen) return;
    if (editing) {
      // Tahrirlashda manba turini aniqlash
      setSourceType(editing.video_path ? 'file' : 'youtube');
      setYoutubeUrl(editing.youtube_url || '');
      setChannelName(editing.channel_name || '');
      setSortOrder(editing.sort_order);
      setIsActive(editing.is_active);
      setVideoFile(null);
      setRemoveVideoFile(false);
      const next = emptyTranslations();
      for (const tr of editing.translations) {
        const code = (tr.language_code || 'uz') as LangTab;
        if (code in next) {
          next[code] = { title: tr.title, description: tr.description || '' };
        }
      }
      setTranslations(next);
    } else {
      setSourceType('youtube');
      setYoutubeUrl('');
      setVideoFile(null);
      setRemoveVideoFile(false);
      setChannelName('');
      setSortOrder(0);
      setIsActive(true);
      setTranslations(emptyTranslations());
    }
    setLangTab('uz');
  }, [isOpen, editing]);

  const previewId = useMemo(() => extractYoutubeId(youtubeUrl), [youtubeUrl]);
  const thumbnail = previewId ? `https://img.youtube.com/vi/${previewId}/hqdefault.jpg` : null;

  const existingVideoUrl = editing?.video_url;
  const existingVideoName = editing?.video_path?.split('/').pop();

  const canSave =
    translations.uz.title.trim() &&
    (sourceType === 'youtube' ? !!previewId : (!!videoFile || (!!existingVideoUrl && !removeVideoFile)));

  const handleSave = () => {
    if (!canSave) return;

    const translationList: VideoTranslation[] = (['uz', 'ru', 'en'] as LangTab[])
      .filter((code) => translations[code].title.trim())
      .map((code) => ({
        language_code: code,
        title: translations[code].title.trim(),
        description: translations[code].description.trim() || null,
      }));

    const payload: VideoPayload = {
      youtube_url: sourceType === 'youtube' ? youtubeUrl.trim() : null,
      video_file: sourceType === 'file' && videoFile ? videoFile : null,
      remove_video_file: sourceType === 'youtube' && removeVideoFile,
      channel_name: channelName.trim(),
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
      title={editing ? t('videos.edit_title') : t('videos.add_title')}
      className="max-w-2xl"
    >
      <div className="space-y-5 max-h-[70vh] overflow-y-auto pr-1">

        {/* Manba tanlash */}
        <div className="flex rounded-2xl overflow-hidden border border-black/10 dark:border-white/10">
          <button
            type="button"
            onClick={() => setSourceType('youtube')}
            className={`flex-1 py-2.5 text-sm font-medium transition-colors ${
              sourceType === 'youtube'
                ? 'bg-red-500 text-white'
                : 'hover:bg-black/5 dark:hover:bg-white/5'
            }`}
          >
            ▶ YouTube
          </button>
          <button
            type="button"
            onClick={() => setSourceType('file')}
            className={`flex-1 py-2.5 text-sm font-medium transition-colors ${
              sourceType === 'file'
                ? 'bg-purple-500 text-white'
                : 'hover:bg-black/5 dark:hover:bg-white/5'
            }`}
          >
            ⬆ Fayl yuklash
          </button>
        </div>

        {/* YouTube URL */}
        {sourceType === 'youtube' && (
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
            {thumbnail && (
              <img
                src={thumbnail}
                alt=""
                className="w-full max-w-md rounded-2xl border border-black/10 dark:border-white/10 mt-3"
              />
            )}
          </div>
        )}

        {/* Video fayl yuklash */}
        {sourceType === 'file' && (
          <div>
            <label className="text-caption block mb-2">Video fayl (MP4, WebM, AVI — max 512MB)</label>

            {/* Mavjud fayl ko'rsatish */}
            {existingVideoUrl && !videoFile && (
              <div className="flex items-center gap-3 mb-3 p-3 rounded-xl bg-black/5 dark:bg-white/5">
                <video
                  src={existingVideoUrl}
                  className="w-32 h-20 rounded-lg object-cover"
                  muted
                />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{existingVideoName}</p>
                  <p className="text-xs text-gray-400">Joriy video</p>
                </div>
                <button
                  type="button"
                  onClick={() => setRemoveVideoFile(true)}
                  className="text-red-400 hover:text-red-600"
                  title="Videoni o'chirish"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            )}

            {removeVideoFile && (
              <div className="mb-3 p-2 rounded-xl bg-red-50 dark:bg-red-900/20 text-red-500 text-sm flex justify-between">
                <span>Video o'chiriladi</span>
                <button type="button" onClick={() => setRemoveVideoFile(false)} className="underline">
                  Bekor qilish
                </button>
              </div>
            )}

            {/* Fayl tanlash */}
            <input
              ref={fileInputRef}
              type="file"
              accept="video/mp4,video/webm,video/avi,video/quicktime,video/x-matroska"
              className="hidden"
              onChange={(e) => {
                const f = e.target.files?.[0] ?? null;
                setVideoFile(f);
                setRemoveVideoFile(false);
              }}
            />

            {videoFile ? (
              <div className="flex items-center gap-3 p-3 rounded-xl bg-purple-50 dark:bg-purple-900/20">
                <video
                  src={URL.createObjectURL(videoFile)}
                  className="w-32 h-20 rounded-lg object-cover"
                  muted
                />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{videoFile.name}</p>
                  <p className="text-xs text-gray-400">{(videoFile.size / 1024 / 1024).toFixed(1)} MB</p>
                </div>
                <button
                  type="button"
                  onClick={() => { setVideoFile(null); if (fileInputRef.current) fileInputRef.current.value = ''; }}
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
                <span className="text-sm text-gray-500">Fayl tanlash yoki bu yerga tashlang</span>
              </button>
            )}
          </div>
        )}

        {/* Kanal nomi */}
        <div>
          <label className="text-caption block mb-1">{t('videos.channel_name')}</label>
          <input
            className="input-glass w-full"
            value={channelName}
            onChange={(e) => setChannelName(e.target.value)}
            placeholder={t('videos.channel_placeholder')}
          />
        </div>

        {/* Sort & Active */}
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
          disabled={isPending || !canSave}
          className="flex-1 btn-primary"
        >
          {isPending ? '...' : t('common.save')}
        </button>
      </div>
    </GlassModal>
  );
}

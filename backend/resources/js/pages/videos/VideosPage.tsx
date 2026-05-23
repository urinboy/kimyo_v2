import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { toast } from 'sonner';
import { Play, Plus, Pencil, Trash2, Video } from 'lucide-react';
import { videosApi, type Video as AppVideo } from '@/api/videos';
import { GlassCard } from '@/components/ui/GlassCard';
import { VideoModal } from '@/components/videos/VideoModal';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';

export default function VideosPage() {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<AppVideo | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['videos'],
    queryFn: videosApi.getAll,
  });

  const createMutation = useMutation({
    mutationFn: videosApi.create,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['videos'] });
      toast.success(t('common.save_success'));
      setModalOpen(false);
    },
    onError: (e: unknown) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: Parameters<typeof videosApi.update>[1] }) =>
      videosApi.update(id, payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['videos'] });
      toast.success(t('common.save_success'));
      setModalOpen(false);
    },
    onError: (e: unknown) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });

  const deleteMutation = useMutation({
    mutationFn: videosApi.remove,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['videos'] });
      toast.success(t('videos.deleted'));
    },
    onError: (e: unknown) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });

  const videos = data?.data.videos ?? [];

  const titleFor = (v: AppVideo) =>
    v.translations.find((tr) => tr.language_code === 'uz')?.title
    ?? v.translations[0]?.title
    ?? v.youtube_video_id
    ?? `Video #${v.id}`;

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-6 duration-700">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-4xl font-black tracking-tight text-transparent bg-clip-text bg-gradient-to-r from-gray-900 via-gray-800 to-gray-500 dark:from-white dark:to-white/40">
            {t('videos.page_title')}
          </h1>
          <p className="text-body-secondary mt-2 flex items-center gap-2">
            <Video className="w-4 h-4 text-purple-600 dark:text-purple-400" />
            {t('videos.page_subtitle')}
          </p>
        </div>
        <button
          type="button"
          onClick={() => {
            setEditing(null);
            setModalOpen(true);
          }}
          className="btn-primary px-6 py-3 flex items-center gap-2"
        >
          <Plus className="w-4 h-4" />
          {t('videos.add_button')}
        </button>
      </div>

      <GlassCard className="overflow-hidden">
        {isLoading ? (
          <div className="p-8 space-y-3">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-16 rounded-xl bg-black/5 dark:bg-white/5 animate-pulse" />
            ))}
          </div>
        ) : videos.length === 0 ? (
          <div className="p-16 text-center text-body-secondary">{t('videos.empty')}</div>
        ) : (
          <div className="divide-y divide-black/5 dark:divide-white/5">
            {videos.map((v) => (
              <div
                key={v.id}
                className="flex items-center gap-4 px-6 py-4 hover:bg-black/[0.02] dark:hover:bg-white/[0.02]"
              >
                {v.thumbnail_url ? (
                  <img
                    src={v.thumbnail_url}
                    alt=""
                    className="w-28 h-16 object-cover rounded-xl shrink-0 bg-black/5"
                  />
                ) : (
                  <div className="w-28 h-16 rounded-xl shrink-0 bg-purple-500/10 flex items-center justify-center">
                    <Video className="w-6 h-6 text-purple-400" />
                  </div>
                )}
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-app-primary truncate">{titleFor(v)}</p>
                  <p className="text-caption truncate">
                    {v.channel_name || '—'} · {v.video_path ? '📁 Server video' : v.youtube_video_id}
                  </p>
                  <span
                    className={`text-xs font-bold px-2 py-0.5 rounded-lg inline-block mt-1 ${
                      v.is_active
                        ? 'bg-emerald-500/10 text-emerald-600'
                        : 'bg-gray-500/10 text-gray-500'
                    }`}
                  >
                    {v.is_active ? t('videos.active') : t('videos.inactive')}
                  </span>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  {(v.youtube_url || v.video_url) && (
                    <a
                      href={v.video_url ?? v.youtube_url ?? '#'}
                      target="_blank"
                      rel="noreferrer"
                      className="p-2 rounded-xl hover:bg-black/5 dark:hover:bg-white/10"
                      title={v.video_url ? 'Video (server)' : 'YouTube'}
                    >
                      <Play className="w-4 h-4" />
                    </a>
                  )}
                  <button
                    type="button"
                    onClick={() => {
                      setEditing(v);
                      setModalOpen(true);
                    }}
                    className="p-2 rounded-xl hover:bg-purple-500/10 text-purple-600"
                  >
                    <Pencil className="w-4 h-4" />
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      if (!confirm(t('videos.delete_confirm'))) return;
                      deleteMutation.mutate(v.id);
                    }}
                    className="p-2 rounded-xl hover:bg-red-500/10 text-red-500"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </GlassCard>

      <VideoModal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        editing={editing}
        isPending={createMutation.isPending || updateMutation.isPending}
        onSubmit={(payload) => {
          if (editing) {
            updateMutation.mutate({ id: editing.id, payload });
          } else {
            createMutation.mutate(payload);
          }
        }}
      />
    </div>
  );
}

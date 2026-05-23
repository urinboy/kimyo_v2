import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Pencil, Trash2, Box, Download } from 'lucide-react';
import { toast } from 'sonner';
import { threeDModelsApi } from '@/api/threeDModels';
import type { ThreeDModel, ThreeDModelPayload } from '@/api/threeDModels';
import { ThreeDModelModal } from '@/components/threeDModels/ThreeDModelModal';
import { GlassCard } from '@/components/ui/GlassCard';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';

export default function ThreeDModelsPage() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing]     = useState<ThreeDModel | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['3d-models'],
    queryFn:  () => threeDModelsApi.getAll(),
  });

  const models = data?.data?.three_d_models ?? [];

  const createMutation = useMutation({
    mutationFn: (payload: ThreeDModelPayload) => threeDModelsApi.create(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['3d-models'] });
      toast.success(t('three_d_models.created'));
      setModalOpen(false);
    },
    onError: (err: unknown) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: ThreeDModelPayload }) =>
      threeDModelsApi.update(id, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['3d-models'] });
      toast.success(t('three_d_models.updated'));
      setModalOpen(false);
    },
    onError: (err: unknown) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => threeDModelsApi.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['3d-models'] });
      toast.success(t('three_d_models.deleted'));
    },
    onError: (err: unknown) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const handleSubmit = (payload: ThreeDModelPayload) => {
    if (editing) {
      updateMutation.mutate({ id: editing.id, payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const handleDelete = (model: ThreeDModel) => {
    const name = nameFor(model);
    if (!window.confirm(t('three_d_models.delete_confirm', { name }))) return;
    deleteMutation.mutate(model.id);
  };

  function nameFor(m: ThreeDModel): string {
    const uz = m.translations.find((tr) => tr.language_code === 'uz');
    const first = m.translations[0];
    return uz?.name || first?.name || m.slug;
  }

  const isPending = createMutation.isPending || updateMutation.isPending;

  return (
    <div className="space-y-8">
      {/* Sarlavha */}
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-3xl font-bold gradient-text">{t('three_d_models.page_title')}</h1>
          <p className="text-app-muted mt-1">{t('three_d_models.page_subtitle')}</p>
        </div>
        <button
          type="button"
          onClick={() => { setEditing(null); setModalOpen(true); }}
          className="btn-primary flex items-center gap-2"
        >
          <Plus className="w-4 h-4" />
          {t('three_d_models.add_button')}
        </button>
      </div>

      {/* Ro'yxat */}
      <GlassCard>
        {isLoading ? (
          <div className="text-center py-12 text-app-muted">{t('common.loading')}</div>
        ) : models.length === 0 ? (
          <div className="flex flex-col items-center gap-4 py-16 text-app-muted">
            <Box className="w-16 h-16 opacity-30" />
            <p className="text-lg">{t('three_d_models.empty')}</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-black/5 dark:border-white/10">
                  <th className="text-left py-3 px-4 font-semibold text-app-muted">ID</th>
                  <th className="text-left py-3 px-4 font-semibold text-app-muted">
                    {t('three_d_models.col_name')}
                  </th>
                  <th className="text-left py-3 px-4 font-semibold text-app-muted">
                    {t('three_d_models.col_slug')}
                  </th>
                  <th className="text-left py-3 px-4 font-semibold text-app-muted">
                    {t('three_d_models.col_element')}
                  </th>
                  <th className="text-left py-3 px-4 font-semibold text-app-muted">
                    {t('three_d_models.col_file')}
                  </th>
                  <th className="text-left py-3 px-4 font-semibold text-app-muted">
                    {t('three_d_models.col_status')}
                  </th>
                  <th className="text-right py-3 px-4 font-semibold text-app-muted">
                    {t('common.actions')}
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-black/5 dark:divide-white/5">
                {models.map((m) => (
                  <tr key={m.id} className="hover:bg-black/2 dark:hover:bg-white/2 transition-colors">
                    <td className="py-3 px-4 text-app-muted">{m.id}</td>
                    <td className="py-3 px-4 font-medium">{nameFor(m)}</td>
                    <td className="py-3 px-4">
                      <code className="text-xs bg-black/5 dark:bg-white/10 px-2 py-0.5 rounded-lg font-mono">
                        {m.slug}
                      </code>
                    </td>
                    <td className="py-3 px-4 text-app-muted">
                      {m.element
                        ? <span className="font-mono font-semibold text-purple-600 dark:text-purple-400">{m.element.symbol}</span>
                        : <span className="text-gray-400">—</span>}
                    </td>
                    <td className="py-3 px-4">
                      {m.model_url ? (
                        <a
                          href={m.model_url}
                          target="_blank"
                          rel="noreferrer"
                          className="inline-flex items-center gap-1 text-xs text-purple-500 hover:underline"
                        >
                          <Download className="w-3 h-3" />
                          GLB
                        </a>
                      ) : (
                        <span className="text-gray-400 text-xs">{t('three_d_models.no_file')}</span>
                      )}
                    </td>
                    <td className="py-3 px-4">
                      <span
                        className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
                          m.is_active
                            ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400'
                            : 'bg-gray-100 text-gray-500 dark:bg-gray-800 dark:text-gray-400'
                        }`}
                      >
                        {m.is_active ? t('three_d_models.active') : t('three_d_models.inactive')}
                      </span>
                    </td>
                    <td className="py-3 px-4">
                      <div className="flex gap-2 justify-end">
                        <button
                          type="button"
                          onClick={() => { setEditing(m); setModalOpen(true); }}
                          className="p-2 rounded-xl hover:bg-purple-50 dark:hover:bg-purple-900/20 text-purple-500 transition-colors"
                          title={t('common.edit')}
                        >
                          <Pencil className="w-4 h-4" />
                        </button>
                        <button
                          type="button"
                          onClick={() => handleDelete(m)}
                          disabled={deleteMutation.isPending}
                          className="p-2 rounded-xl hover:bg-red-50 dark:hover:bg-red-900/20 text-red-400 transition-colors"
                          title={t('common.delete')}
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>

      <ThreeDModelModal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        editing={editing}
        onSubmit={handleSubmit}
        isPending={isPending}
      />
    </div>
  );
}

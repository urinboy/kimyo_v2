import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, KeyRound, Loader2 } from 'lucide-react';
import { permissionsApi, type PermissionRow } from '@/api/permissions';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';

const PermissionsPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingPerm, setDeletingPerm] = useState<PermissionRow | null>(null);
  const [editingPerm, setEditingPerm] = useState<PermissionRow | null>(null);
  const [formName, setFormName] = useState('');

  const { data, isLoading } = useQuery({
    queryKey: ['permissions'],
    queryFn: permissionsApi.getAll,
  });

  const createMutation = useMutation({
    mutationFn: permissionsApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['permissions'] });
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      handleCloseModal();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, name }: { id: number; name: string }) => permissionsApi.update(id, { name }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['permissions'] });
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      handleCloseModal();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: permissionsApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['permissions'] });
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      setIsDeleteModalOpen(false);
      setDeletingPerm(null);
    },
  });

  const formatPerm = (s: string) => s.replace(/_/g, ' ');

  const permLabel = (name: string) => {
    const k = `roles.permission.${name}`;
    const tr = t(k);
    return tr === k ? formatPerm(name) : tr;
  };

  const handleOpenModal = (perm: PermissionRow | null = null) => {
    if (perm) {
      setEditingPerm(perm);
      setFormName(perm.name);
    } else {
      setEditingPerm(null);
      setFormName('');
    }
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingPerm(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const name = formName.trim();
    if (!name) return;
    if (editingPerm) {
      updateMutation.mutate({ id: editingPerm.id, name });
    } else {
      createMutation.mutate({ name });
    }
  };

  const rows = data?.data.permissions ?? [];

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex flex-col gap-4 sm:flex-row sm:justify-between sm:items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('permissions_module.title')}</h1>
          <p className="text-app-muted mt-1 max-w-2xl">{t('permissions_module.subtitle')}</p>
        </div>
        <button type="button" onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('permissions_module.add_button')}
        </button>
      </div>

      <GlassCard className="overflow-hidden p-0">
        <div className="overflow-x-auto scrollbar-none">
          <table className="data-table-shell w-full text-left border-collapse">
            <thead>
              <tr>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('permissions_module.table_key')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('permissions_module.table_label')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('permissions_module.table_roles')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle text-right">{t('permissions_module.table_actions')}</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={4} className="px-6 py-16 text-center text-app-muted">
                    <Loader2 className="w-8 h-8 animate-spin mx-auto text-purple-500" />
                  </td>
                </tr>
              ) : rows.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-10 text-center text-app-muted">
                    {t('permissions_module.empty')}
                  </td>
                </tr>
              ) : (
                rows.map((perm) => (
                  <tr key={perm.id} className="border-t border-black/5 dark:border-white/10">
                    <td className="px-6 py-4">
                      <span className="font-mono text-sm font-semibold text-app-primary">{perm.name}</span>
                    </td>
                    <td className="px-6 py-4 text-sm text-app-primary">{permLabel(perm.name)}</td>
                    <td className="px-6 py-4 text-sm tabular-nums text-app-muted">{perm.roles_count ?? 0}</td>
                    <td className="px-6 py-4">
                      <div className="flex justify-end gap-0.5">
                        <button
                          type="button"
                          onClick={() => handleOpenModal(perm)}
                          className="p-2.5 rounded-xl border border-transparent hover:bg-black/[0.04] dark:hover:bg-white/10 text-app-muted hover:text-purple-600 dark:hover:text-purple-300 transition-all"
                          aria-label={t('common.edit', 'Tahrirlash')}
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button
                          type="button"
                          onClick={() => {
                            setDeletingPerm(perm);
                            setIsDeleteModalOpen(true);
                          }}
                          className="p-2.5 rounded-xl border border-transparent hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"
                          aria-label={t('common.delete', "O'chirish")}
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

      <p className="text-xs text-app-muted max-w-3xl leading-relaxed">{t('permissions_module.hint')}</p>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingPerm && deleteMutation.mutate(deletingPerm.id)}
        title={t('permissions_module.delete_title')}
        message={
          deletingPerm
            ? t('permissions_module.delete_message', {
                name: deletingPerm.name,
                count: deletingPerm.roles_count ?? 0,
              })
            : ''
        }
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingPerm ? t('permissions_module.edit_title') : t('permissions_module.create_title')}
        className="max-w-lg"
      >
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="flex items-start gap-3 rounded-2xl border border-purple-500/25 bg-purple-500/5 px-4 py-3 dark:bg-purple-500/10">
            <KeyRound className="w-5 h-5 shrink-0 text-purple-600 dark:text-purple-400 mt-0.5" />
            <p className="text-sm text-app-muted leading-snug">{t('permissions_module.form_hint')}</p>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('permissions_module.form_name')}</label>
            <input
              type="text"
              required
              value={formName}
              onChange={(e) => setFormName(e.target.value)}
              className="input-glass font-mono"
              placeholder={t('permissions_module.form_placeholder')}
              autoComplete="off"
            />
          </div>
          <div className="flex gap-4 pt-2">
            <button type="button" onClick={handleCloseModal} className="flex-1 btn-modal-secondary">
              {t('common.cancel')}
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending || updateMutation.isPending}
              className="flex-1 btn-primary flex items-center justify-center gap-2"
            >
              {(createMutation.isPending || updateMutation.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
              {editingPerm ? t('common.save') : t('common.create')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

export default PermissionsPage;

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, Shield, Loader2, Check } from 'lucide-react';
import { roleApi, type Role } from '@/api/roles';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';

const RolesPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingRole, setEditingRole] = useState<Role | null>(null);

  const [formData, setFormData] = useState<{ name: string; permissions: string[] }>({
    name: '',
    permissions: []
  });

  const { data: rolesData, isLoading } = useQuery({ queryKey: ['roles'], queryFn: roleApi.getAll });

  const createMutation = useMutation({
    mutationFn: roleApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      handleCloseModal();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: { name: string; permissions: string[] } }) => roleApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      handleCloseModal();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: roleApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
    },
  });

  const handleOpenModal = (role: Role | null = null) => {
    if (role) {
      setEditingRole(role);
      setFormData({
        name: role.name,
        permissions: role.permissions.map(p => p.name)
      });
    } else {
      setEditingRole(null);
      setFormData({ name: '', permissions: [] });
    }
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingRole(null);
  };

  const togglePermission = (permName: string) => {
    setFormData(prev => ({
      ...prev,
      permissions: prev.permissions.includes(permName)
        ? prev.permissions.filter(p => p !== permName)
        : [...prev.permissions, permName]
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editingRole) {
      updateMutation.mutate({ id: editingRole.id, data: formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const formatPerm = (s: string) => s.replace(/_/g, ' ');

  const permLabel = (name: string) => {
    const k = `roles.permission.${name}`;
    const tr = t(k);
    return tr === k ? formatPerm(name) : tr;
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex flex-col gap-4 sm:flex-row sm:justify-between sm:items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('roles.title')}</h1>
          <p className="text-app-muted mt-1 max-w-2xl">{t('roles.subtitle')}</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('roles.add_button')}
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {isLoading ? (
          <div className="col-span-full py-20 text-center">
            <Loader2 className="w-10 h-10 animate-spin mx-auto text-purple-500" />
          </div>
        ) : (
          rolesData?.data.roles.map((role) => (
            <GlassCard key={role.id} className="relative group flex flex-col p-6 sm:p-8">
              <div className="flex justify-between items-start gap-3 mb-5">
                <div className="w-12 h-12 shrink-0 rounded-2xl glass flex items-center justify-center text-purple-600 dark:text-purple-400 shadow-inner shadow-purple-500/10">
                  <Shield className="w-6 h-6" />
                </div>
                <div className="flex items-center gap-0.5 shrink-0 -mr-1">
                  <button
                    type="button"
                    onClick={() => handleOpenModal(role)}
                    className="p-2.5 rounded-xl border border-transparent hover:bg-black/[0.04] dark:hover:bg-white/10 text-app-muted hover:text-purple-600 dark:hover:text-purple-300 transition-all"
                    aria-label={t('common.edit', 'Tahrirlash')}
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    type="button"
                    disabled={role.name === 'super_admin'}
                    onClick={() => {
                      setDeletingId(role.id);
                      setIsDeleteModalOpen(true);
                    }}
                    className="p-2.5 rounded-xl border border-transparent hover:bg-red-500/10 text-app-muted hover:text-red-500 disabled:opacity-30 disabled:pointer-events-none transition-all"
                    aria-label={t('common.delete', "O'chirish")}
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <h3 className="text-xl font-bold text-app-primary mb-3 leading-snug">
                {formatPerm(role.name)}
              </h3>

              <div className="mb-4 space-y-1">
                <p className="text-[11px] font-bold uppercase tracking-wider text-kpi-header">
                  {t('roles.active_permissions')}
                </p>
                <p className="text-sm font-semibold tabular-nums text-app-primary">
                  {role.permissions.length}
                </p>
              </div>

              <div className="flex flex-wrap gap-2 pt-1 border-t border-black/5 dark:border-white/10">
                {role.permissions.slice(0, 4).map((p) => (
                  <span
                    key={p.id}
                    className="inline-flex max-w-full items-center rounded-lg border border-slate-200/90 bg-slate-100/90 px-2.5 py-1.5 text-[10px] font-semibold uppercase tracking-wide text-slate-700 shadow-sm dark:border-white/10 dark:bg-white/5 dark:text-slate-200 dark:shadow-none"
                    title={formatPerm(p.name)}
                  >
                    <span className="truncate">{permLabel(p.name)}</span>
                  </span>
                ))}
                {role.permissions.length > 4 && (
                  <span className="inline-flex items-center rounded-lg border border-dashed border-slate-300/80 bg-slate-50/80 px-2.5 py-1.5 text-[10px] font-bold text-app-muted dark:border-white/15 dark:bg-white/[0.03]">
                    {t('roles.permissions_extra', { count: role.permissions.length - 4 })}
                  </span>
                )}
              </div>
            </GlassCard>
          ))
        )}
      </div>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingId && deleteMutation.mutate(deletingId)}
        title={t('roles.delete_title')}
        message={t('roles.delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingRole ? t('roles.edit_title') : t('roles.create_title')}
        className="max-w-2xl"
      >
        <form onSubmit={handleSubmit} className="space-y-8">
          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('roles.form_name')}</label>
            <input
              type="text"
              required
              value={formData.name}
              onChange={e => setFormData({ ...formData, name: e.target.value })}
              className="input-glass"
              placeholder={t('roles.form_name_placeholder')}
            />
          </div>

          <div className="space-y-4">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('roles.form_permissions')}</label>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {rolesData?.data.permissions.map((perm) => (
                <button
                  key={perm.id}
                  type="button"
                  onClick={() => togglePermission(perm.name)}
                  className={`flex items-center justify-between p-4 rounded-2xl border transition-all ${
                    formData.permissions.includes(perm.name)
                      ? 'bg-purple-500/15 border-purple-500/50 text-app-primary shadow-md shadow-purple-500/10 dark:bg-purple-500/20'
                      : 'bg-black/[0.03] dark:bg-white/5 border-slate-200/80 dark:border-white/10 text-app-muted hover:border-purple-300/40 dark:hover:border-white/20'
                  }`}
                >
                  <span className="text-sm font-medium text-left">{permLabel(perm.name)}</span>
                  {formData.permissions.includes(perm.name) && (
                    <div className="w-5 h-5 rounded-full bg-purple-500 flex items-center justify-center">
                      <Check className="w-3 h-3 text-white" />
                    </div>
                  )}
                </button>
              ))}
            </div>
          </div>

          <div className="flex gap-4 pt-4">
            <button
              type="button"
              onClick={handleCloseModal}
              className="flex-1 btn-modal-secondary"
            >
              {t('common.cancel')}
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending || updateMutation.isPending}
              className="flex-1 btn-primary flex items-center justify-center gap-2"
            >
              {(createMutation.isPending || updateMutation.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
              {editingRole ? t('common.save') : t('common.create')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

export default RolesPage;

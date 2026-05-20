import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { Plus, Edit2, Trash2, Building2, Loader2, Eye, GraduationCap, CalendarDays } from 'lucide-react';
import { schoolsApi, type School } from '@/api/schools';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { getCurrentAcademicYearLabel } from '@/lib/academicYear';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

const SchoolsPage = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editing, setEditing] = useState<School | null>(null);

  const [formData, setFormData] = useState({
    name: '',
    short_name: '',
    region: '',
    city: '',
    address: '',
    is_active: true,
  });

  const { data, isLoading } = useQuery({
    queryKey: ['schools'],
    queryFn: schoolsApi.getAll,
  });

  const createMutation = useMutation({
    mutationFn: schoolsApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['schools'] });
      queryClient.invalidateQueries({ queryKey: ['schools-list'] });
      handleCloseModal();
      toast.success(t('schools.toast_created'));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: Partial<School> }) => schoolsApi.update(id, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['schools'] });
      queryClient.invalidateQueries({ queryKey: ['schools-list'] });
      handleCloseModal();
      toast.success(t('schools.toast_updated'));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const deleteMutation = useMutation({
    mutationFn: schoolsApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['schools'] });
      queryClient.invalidateQueries({ queryKey: ['schools-list'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
      toast.success(t('schools.toast_deleted'));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.delete_error'))),
  });

  const handleOpenModal = (school: School | null = null) => {
    if (school) {
      setEditing(school);
      setFormData({
        name: school.name,
        short_name: school.short_name ?? '',
        region: school.region ?? '',
        city: school.city ?? '',
        address: school.address ?? '',
        is_active: school.is_active,
      });
    } else {
      setEditing(null);
      setFormData({
        name: '',
        short_name: '',
        region: '',
        city: '',
        address: '',
        is_active: true,
      });
    }
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditing(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      name: formData.name.trim(),
      short_name: formData.short_name.trim() || undefined,
      region: formData.region.trim() || undefined,
      city: formData.city.trim() || undefined,
      address: formData.address.trim() || undefined,
      is_active: formData.is_active,
    };
    if (editing) {
      updateMutation.mutate({ id: editing.id, payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const rows = data?.data.schools ?? [];

  const stats = useMemo(() => {
    const activeSchools = rows.filter((s) => s.is_active).length;
    const studentsInSchools = rows.reduce((sum, s) => sum + (s.users_count ?? 0), 0);
    return { activeSchools, studentsInSchools };
  }, [rows]);

  const academicYearLabel = useMemo(() => getCurrentAcademicYearLabel(), []);

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex flex-col gap-4 sm:flex-row sm:justify-between sm:items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('schools.title')}</h1>
          <p className="text-app-muted mt-1 max-w-2xl">{t('schools.subtitle')}</p>
        </div>
        <button type="button" onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('schools.add_button')}
        </button>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <GlassCard className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-purple-500/15">
            <Building2 className="h-6 w-6 text-purple-500" />
          </div>
          <div className="min-w-0">
            <p className="text-2xl font-bold text-app-primary tabular-nums">
              {isLoading ? <Loader2 className="h-5 w-5 animate-spin text-purple-500" /> : stats.activeSchools}
            </p>
            <p className="truncate text-xs text-app-muted">{t('schools.stat_active_schools')}</p>
          </div>
        </GlassCard>

        <GlassCard className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-emerald-500/15">
            <GraduationCap className="h-6 w-6 text-emerald-500" />
          </div>
          <div className="min-w-0">
            <p className="text-2xl font-bold text-app-primary tabular-nums">
              {isLoading ? <Loader2 className="h-5 w-5 animate-spin text-emerald-500" /> : stats.studentsInSchools}
            </p>
            <p className="truncate text-xs text-app-muted">{t('schools.stat_students_linked')}</p>
          </div>
        </GlassCard>

        <GlassCard className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-sky-500/15">
            <CalendarDays className="h-6 w-6 text-sky-500" />
          </div>
          <div className="min-w-0">
            <p className="text-2xl font-bold text-app-primary tabular-nums">{academicYearLabel}</p>
            <p className="truncate text-xs text-app-muted">{t('schools.stat_current_academic_year')}</p>
          </div>
        </GlassCard>
      </div>

      <GlassCard className="overflow-hidden p-0">
        <div className="overflow-x-auto scrollbar-none">
          <table className="data-table-shell w-full text-left border-collapse">
            <thead>
              <tr>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('schools.table_id')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('schools.table_name')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('schools.table_city')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('schools.table_users')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('schools.table_status')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle text-right">{t('schools.table_actions')}</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-10 text-center">
                    <Loader2 className="w-8 h-8 animate-spin mx-auto text-purple-500" />
                  </td>
                </tr>
              ) : (
                rows.map((school, index) => (
                  <tr key={school.id} className="group">
                    <td className="px-6 py-4 text-sm text-app-muted tabular-nums">{index + 1}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-xl glass flex items-center justify-center text-purple-600 dark:text-purple-400">
                          <Building2 className="w-4 h-4" />
                        </div>
                        <div>
                          <div className="font-medium text-app-primary">{school.name}</div>
                          {school.short_name ? (
                            <div className="text-xs text-app-muted mt-0.5">{school.short_name}</div>
                          ) : null}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-app-muted">
                      {[school.city, school.region].filter(Boolean).join(', ') || '—'}
                    </td>
                    <td className="px-6 py-4 text-sm tabular-nums text-app-muted">{school.users_count ?? 0}</td>
                    <td className="px-6 py-4 text-sm">
                      <span
                        className={cn(
                          'px-3 py-1 rounded-full text-xs font-semibold',
                          school.is_active ? 'bg-emerald-500/10 text-emerald-600' : 'bg-red-500/10 text-red-500',
                        )}
                      >
                        {school.is_active ? t('schools.active') : t('schools.inactive')}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-right">
                      <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button
                          type="button"
                          onClick={() => navigate(`/schools/${school.id}`)}
                          className="p-2 rounded-xl hover:bg-purple-500/10 text-app-muted hover:text-purple-500 transition-all"
                          title={t('common.view')}
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button
                          type="button"
                          onClick={() => handleOpenModal(school)}
                          className="p-2 rounded-xl hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-app-primary transition-all"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button
                          type="button"
                          onClick={() => {
                            setDeletingId(school.id);
                            setIsDeleteModalOpen(true);
                          }}
                          className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"
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

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingId && deleteMutation.mutate(deletingId)}
        title={t('schools.delete_title')}
        message={t('schools.delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editing ? t('schools.edit_title') : t('schools.create_title')}
        className="max-w-lg"
      >
        <form onSubmit={handleSubmit} className="space-y-5">
          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('schools.form_name')}</label>
            <input
              type="text"
              required
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="input-glass"
              placeholder={t('schools.form_name_placeholder')}
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('schools.form_short_name')}</label>
            <input
              type="text"
              value={formData.short_name}
              onChange={(e) => setFormData({ ...formData, short_name: e.target.value })}
              className="input-glass"
              placeholder={t('schools.form_short_name_placeholder')}
            />
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium text-app-subtle ml-1">{t('schools.form_region')}</label>
              <input
                type="text"
                value={formData.region}
                onChange={(e) => setFormData({ ...formData, region: e.target.value })}
                className="input-glass"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-app-subtle ml-1">{t('schools.form_city')}</label>
              <input
                type="text"
                value={formData.city}
                onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                className="input-glass"
              />
            </div>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('schools.form_address')}</label>
            <input
              type="text"
              value={formData.address}
              onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              className="input-glass"
            />
          </div>
          <div className="flex items-center gap-3 p-4 rounded-2xl border border-black/10 bg-black/[0.03] dark:border-white/10 dark:bg-white/5">
            <input
              type="checkbox"
              id="school_active"
              checked={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
              className="w-5 h-5 rounded-lg border-white/20 bg-transparent text-purple-500 focus:ring-purple-500/50"
            />
            <label htmlFor="school_active" className="text-sm font-medium text-app-subtle cursor-pointer select-none">
              {t('schools.form_is_active')}
            </label>
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
              {editing ? t('common.save') : t('common.create')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

export default SchoolsPage;

import { useMemo, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { toast } from 'sonner';
import {
  ArrowLeft,
  Building2,
  Users,
  Trophy,
  Activity,
  MapPin,
  Phone,
  GraduationCap,
  Loader2,
  CheckCircle2,
  Clock,
  Star,
  UserPlus,
  Search,
  UserMinus,
} from 'lucide-react';
import { schoolsApi, type Student, type AssignableUser } from '@/api/schools';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { cn } from '@/lib/utils';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';

const StatCard = ({
  icon: Icon,
  label,
  value,
  color,
}: {
  icon: React.ElementType;
  label: string;
  value: string | number;
  color: string;
}) => (
  <GlassCard className="flex items-center gap-4 p-5">
    <div className={cn('w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0', color)}>
      <Icon className="w-5 h-5 text-white" />
    </div>
    <div>
      <p className="text-xs text-app-muted font-medium uppercase tracking-wide">{label}</p>
      <p className="text-2xl font-bold text-app-primary mt-0.5">{value}</p>
    </div>
  </GlassCard>
);

const PerformanceBar = ({ value, max = 10 }: { value: number; max?: number }) => {
  const pct = Math.min((value / max) * 100, 100);
  const color =
    pct >= 70 ? 'bg-emerald-500' : pct >= 40 ? 'bg-amber-500' : 'bg-red-400';
  return (
    <div className="flex items-center gap-2 w-full">
      <div className="flex-1 h-2 bg-black/10 dark:bg-white/10 rounded-full overflow-hidden">
        <div
          className={cn('h-full rounded-full transition-all duration-500', color)}
          style={{ width: `${pct}%` }}
        />
      </div>
      <span className="text-xs tabular-nums text-app-muted w-8 text-right">{value}</span>
    </div>
  );
};

const SchoolDetailPage = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const schoolId = Number(id);

  const [addModalOpen, setAddModalOpen] = useState(false);
  const [assignSearch, setAssignSearch] = useState('');
  const [selectedIds, setSelectedIds] = useState<Set<number>>(() => new Set());
  const [detachTarget, setDetachTarget] = useState<Student | null>(null);

  const { data, isLoading, isError } = useQuery({
    queryKey: ['school-detail', id],
    queryFn: () => schoolsApi.getDetail(schoolId),
    enabled: !!id && !Number.isNaN(schoolId),
  });

  const { data: assignableData, isLoading: assignableLoading } = useQuery({
    queryKey: ['school-assignable', id],
    queryFn: () => schoolsApi.getAssignableUsers(schoolId),
    enabled: addModalOpen && !!id && !Number.isNaN(schoolId),
  });

  const attachMutation = useMutation({
    mutationFn: (userIds: number[]) => schoolsApi.attachStudents(schoolId, userIds),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['school-detail', id] });
      queryClient.invalidateQueries({ queryKey: ['schools'] });
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['school-assignable', id] });
      toast.success(t('schools.detail_attach_success'));
      setAddModalOpen(false);
      setSelectedIds(new Set());
      setAssignSearch('');
    },
    onError: e => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });

  const detachMutation = useMutation({
    mutationFn: (userIds: number[]) => schoolsApi.detachStudents(schoolId, userIds),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['school-detail', id] });
      queryClient.invalidateQueries({ queryKey: ['schools'] });
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['school-assignable', id] });
      toast.success(t('schools.detail_detach_success'));
      setDetachTarget(null);
    },
    onError: e => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });

  const assignableUsers = assignableData?.data.users ?? [];

  const filteredAssignable = useMemo(() => {
    const q = assignSearch.trim().toLowerCase();
    if (!q) return assignableUsers;
    return assignableUsers.filter(u => {
      const blob = [u.name, u.phone, u.email, u.username, u.grade].filter(Boolean).join(' ').toLowerCase();
      return blob.includes(q);
    });
  }, [assignableUsers, assignSearch]);

  const toggleSelect = (uid: number) => {
    setSelectedIds(prev => {
      const next = new Set(prev);
      if (next.has(uid)) next.delete(uid);
      else next.add(uid);
      return next;
    });
  };

  const openAddModal = () => {
    setSelectedIds(new Set());
    setAssignSearch('');
    setAddModalOpen(true);
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="w-8 h-8 animate-spin text-purple-500" />
      </div>
    );
  }

  if (isError || !data?.data) {
    return (
      <div className="flex flex-col items-center justify-center h-64 gap-4">
        <p className="text-app-muted">{t('common.error_loading')}</p>
        <button type="button" onClick={() => navigate(-1)} className="btn-primary">
          {t('common.back')}
        </button>
      </div>
    );
  }

  const { school, students, stats } = data.data;

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      {/* Header */}
      <div className="flex items-start gap-4">
        <button
          type="button"
          onClick={() => navigate(-1)}
          className="p-2.5 rounded-xl hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-app-primary transition-all flex-shrink-0 mt-1"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div className="flex-1">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-purple-500/10 flex items-center justify-center">
              <Building2 className="w-5 h-5 text-purple-500" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-app-primary">{school.name}</h1>
              {school.short_name && (
                <p className="text-sm text-app-muted">{school.short_name}</p>
              )}
            </div>
            <span
              className={cn(
                'ml-auto px-3 py-1 rounded-full text-xs font-semibold flex-shrink-0',
                school.is_active
                  ? 'bg-emerald-500/10 text-emerald-600'
                  : 'bg-red-500/10 text-red-500',
              )}
            >
              {school.is_active ? t('schools.active') : t('schools.inactive')}
            </span>
          </div>

          {/* School meta */}
          <div className="flex flex-wrap gap-4 mt-3 text-sm text-app-muted">
            {(school.city || school.region) && (
              <span className="flex items-center gap-1.5">
                <MapPin className="w-4 h-4" />
                {[school.city, school.region].filter(Boolean).join(', ')}
              </span>
            )}
            {school.address && (
              <span className="flex items-center gap-1.5">
                <Building2 className="w-4 h-4" />
                {school.address}
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Stats cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={Users}
          label={t('schools.detail_total_students')}
          value={stats.total_students}
          color="bg-purple-500"
        />
        <StatCard
          icon={Activity}
          label={t('schools.detail_active_students')}
          value={stats.active_students}
          color="bg-blue-500"
        />
        <StatCard
          icon={Star}
          label={t('schools.detail_avg_score')}
          value={stats.avg_score}
          color="bg-amber-500"
        />
        <StatCard
          icon={Trophy}
          label={t('schools.detail_top_score')}
          value={stats.top_score}
          color="bg-emerald-500"
        />
      </div>

      {/* Performance summary */}
      <GlassCard className="p-6">
        <h2 className="text-lg font-bold text-app-primary mb-4 flex items-center gap-2">
          <Activity className="w-5 h-5 text-purple-500" />
          {t('schools.detail_performance_overview')}
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
          <div className="text-center p-4 rounded-2xl bg-purple-500/5 border border-purple-500/10">
            <div className="text-3xl font-black text-purple-500">{stats.total_students}</div>
            <div className="text-sm text-app-muted mt-1">{t('schools.detail_registered')}</div>
          </div>
          <div className="text-center p-4 rounded-2xl bg-blue-500/5 border border-blue-500/10">
            <div className="text-3xl font-black text-blue-500">{stats.active_students}</div>
            <div className="text-sm text-app-muted mt-1">{t('schools.detail_participated')}</div>
          </div>
          <div className="text-center p-4 rounded-2xl bg-emerald-500/5 border border-emerald-500/10">
            <div className="text-3xl font-black text-emerald-500">
              {stats.total_students > 0
                ? Math.round((stats.active_students / stats.total_students) * 100)
                : 0}
              %
            </div>
            <div className="text-sm text-app-muted mt-1">{t('schools.detail_engagement')}</div>
          </div>
        </div>
      </GlassCard>

      {/* Students table */}
      <GlassCard className="overflow-hidden p-0">
        <div className="px-6 py-4 border-b border-black/5 dark:border-white/5 flex flex-wrap items-center justify-between gap-3">
          <h2 className="text-lg font-bold text-app-primary flex items-center gap-2">
            <GraduationCap className="w-5 h-5 text-purple-500" />
            {t('schools.detail_students_list')}
          </h2>
          <div className="flex items-center gap-2 flex-wrap">
            <span className="px-3 py-1 rounded-full bg-purple-500/10 text-purple-600 text-xs font-semibold">
              {students.length} {t('schools.detail_students_count')}
            </span>
            <button type="button" onClick={openAddModal} className="btn-primary flex items-center gap-2 text-sm py-2">
              <UserPlus className="w-4 h-4" />
              {t('schools.detail_add_students')}
            </button>
          </div>
        </div>

        {students.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 gap-3 text-app-muted">
            <Users className="w-12 h-12 opacity-30" />
            <p>{t('schools.detail_no_students')}</p>
            <button type="button" onClick={openAddModal} className="btn-primary flex items-center gap-2 text-sm mt-2">
              <UserPlus className="w-4 h-4" />
              {t('schools.detail_add_students')}
            </button>
          </div>
        ) : (
          <div className="overflow-x-auto scrollbar-none">
            <table className="data-table-shell w-full text-left border-collapse">
              <thead>
                <tr>
                  <th className="px-6 py-3 text-xs font-semibold text-app-subtle uppercase tracking-wide">
                    #
                  </th>
                  <th className="px-6 py-3 text-xs font-semibold text-app-subtle uppercase tracking-wide">
                    {t('schools.detail_col_name')}
                  </th>
                  <th className="px-6 py-3 text-xs font-semibold text-app-subtle uppercase tracking-wide">
                    {t('schools.detail_col_phone')}
                  </th>
                  <th className="px-6 py-3 text-xs font-semibold text-app-subtle uppercase tracking-wide">
                    {t('schools.detail_col_grade')}
                  </th>
                  <th className="px-6 py-3 text-xs font-semibold text-app-subtle uppercase tracking-wide">
                    {t('schools.detail_col_submissions')}
                  </th>
                  <th className="px-6 py-3 text-xs font-semibold text-app-subtle uppercase tracking-wide">
                    {t('schools.detail_col_avg_score')}
                  </th>
                  <th className="px-6 py-3 text-xs font-semibold text-app-subtle uppercase tracking-wide">
                    {t('schools.detail_col_status')}
                  </th>
                  <th className="px-6 py-3 text-xs font-semibold text-app-subtle uppercase tracking-wide text-right">
                    {t('schools.detail_col_actions')}
                  </th>
                </tr>
              </thead>
              <tbody>
                {students.map((student: Student, idx: number) => (
                  <StudentRow key={student.id} student={student} index={idx + 1} onDetach={() => setDetachTarget(student)} />
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>

      <GlassModal
        isOpen={addModalOpen}
        onClose={() => {
          setAddModalOpen(false);
          setSelectedIds(new Set());
        }}
        title={t('schools.detail_add_students')}
        className="max-w-lg max-h-[85vh] flex flex-col"
      >
        <p className="text-sm text-app-muted mb-3">{t('schools.detail_add_students_hint')}</p>
        <div className="relative mb-3">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
          <input
            type="search"
            value={assignSearch}
            onChange={e => setAssignSearch(e.target.value)}
            placeholder={t('schools.detail_search_users')}
            className="input-glass w-full pl-10"
          />
        </div>
        <p className="text-xs text-app-muted mb-2">
          {t('schools.detail_selected_count', { count: selectedIds.size })}
        </p>
        <div className="flex-1 min-h-[200px] max-h-[45vh] overflow-y-auto rounded-xl border border-black/5 dark:border-white/10">
          {assignableLoading ? (
            <div className="flex justify-center py-12">
              <Loader2 className="w-7 h-7 animate-spin text-purple-500" />
            </div>
          ) : filteredAssignable.length === 0 ? (
            <div className="text-center py-12 text-app-muted text-sm px-4">{t('schools.detail_no_assignable')}</div>
          ) : (
            <ul className="divide-y divide-black/5 dark:divide-white/5">
              {filteredAssignable.map((u: AssignableUser) => (
                <li key={u.id}>
                  <label className="flex items-start gap-3 px-4 py-3 cursor-pointer hover:bg-purple-500/[0.04]">
                    <input
                      type="checkbox"
                      checked={selectedIds.has(u.id)}
                      onChange={() => toggleSelect(u.id)}
                      className="mt-1 rounded border-white/20"
                    />
                    <div className="min-w-0">
                      <div className="font-medium text-app-primary">{u.name}</div>
                      <div className="text-xs text-app-muted truncate">
                        {[u.phone, u.email].filter(Boolean).join(' · ') || '—'}
                      </div>
                    </div>
                  </label>
                </li>
              ))}
            </ul>
          )}
        </div>
        <div className="flex justify-end gap-2 mt-4 pt-2 border-t border-black/5 dark:border-white/10">
          <button type="button" className="btn-secondary" onClick={() => setAddModalOpen(false)}>
            {t('common.cancel')}
          </button>
          <button
            type="button"
            className="btn-primary"
            disabled={selectedIds.size === 0 || attachMutation.isPending}
            onClick={() => attachMutation.mutate([...selectedIds])}
          >
            {attachMutation.isPending ? (
              <Loader2 className="w-4 h-4 animate-spin" />
            ) : (
              t('schools.detail_attach')
            )}
          </button>
        </div>
      </GlassModal>

      <ConfirmModal
        isOpen={detachTarget !== null}
        onClose={() => setDetachTarget(null)}
        onConfirm={() => detachTarget && detachMutation.mutate([detachTarget.id])}
        title={t('schools.detail_remove_from_school')}
        message={
          detachTarget
            ? t('schools.detail_remove_confirm', { name: detachTarget.name })
            : ''
        }
        confirmText={t('common.confirm')}
        cancelText={t('common.cancel')}
        type="warning"
        isLoading={detachMutation.isPending}
      />
    </div>
  );
};

const StudentRow = ({
  student,
  index,
  onDetach,
}: {
  student: Student;
  index: number;
  onDetach: () => void;
}) => {
  const { t } = useTranslation();
  const isActive = student.total_submissions > 0;
  return (
    <tr className="group hover:bg-purple-500/[0.03] transition-colors">
      <td className="px-6 py-4 text-sm text-app-muted tabular-nums">{index}</td>
      <td className="px-6 py-4">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-xl bg-purple-500/10 flex items-center justify-center text-purple-600 font-bold text-sm flex-shrink-0">
            {student.name.charAt(0).toUpperCase()}
          </div>
          <span className="font-medium text-app-primary">{student.name}</span>
        </div>
      </td>
      <td className="px-6 py-4 text-sm text-app-muted">
        {student.phone ? (
          <span className="flex items-center gap-1.5">
            <Phone className="w-3.5 h-3.5" />
            {student.phone}
          </span>
        ) : (
          '—'
        )}
      </td>
      <td className="px-6 py-4 text-sm text-app-muted">{student.grade ?? '—'}</td>
      <td className="px-6 py-4 text-sm tabular-nums">
        <span className="font-medium text-app-primary">{student.total_submissions}</span>
      </td>
      <td className="px-6 py-4 min-w-[140px]">
        <PerformanceBar value={student.avg_score} max={100} />
      </td>
      <td className="px-6 py-4 text-sm">
        {isActive ? (
          <span className="flex items-center gap-1.5 text-emerald-600">
            <CheckCircle2 className="w-4 h-4" />
            <span className="text-xs font-medium">Faol</span>
          </span>
        ) : (
          <span className="flex items-center gap-1.5 text-app-muted">
            <Clock className="w-4 h-4" />
            <span className="text-xs font-medium">Faolsiz</span>
          </span>
        )}
      </td>
      <td className="px-6 py-4 text-right">
        <button
          type="button"
          onClick={onDetach}
          className="p-2 rounded-xl text-app-muted hover:text-red-500 hover:bg-red-500/10 transition-colors"
          title={t('schools.detail_remove_from_school')}
        >
          <UserMinus className="w-4 h-4" />
        </button>
      </td>
    </tr>
  );
};

export default SchoolDetailPage;

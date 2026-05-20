import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, User as UserIcon, Shield, Loader2, Key, Eye, EyeOff, AtSign, Phone, GraduationCap, Building, Search, MapPin, School as SchoolIcon, X, Users, BookOpen, Building2 } from 'lucide-react';
import { userApi, type User } from '@/api/users';
import { schoolsApi } from '@/api/schools';
import { roleApi } from '@/api/roles';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { schoolsWithSelectLabel, schoolLocationSubtitle } from '@/lib/utils';
import { toast } from 'sonner';

function buildUserSearchHaystack(user: User): string {
  const roleVariants = user.roles.flatMap((r) => {
    const n = r.name;
    return [n, n.replace(/_/g, ' '), n.replace(/_/g, '')];
  });
  const schoolBlock = user.school
    ? [
        user.school.name,
        schoolLocationSubtitle(user.school),
        user.school.region ?? '',
        user.school.city ?? '',
        user.school.short_name ?? '',
      ].filter(Boolean)
    : [];

  const parts = [
    String(user.id),
    user.name,
    user.username ?? '',
    user.email ?? '',
    user.phone ?? '',
    user.grade ?? '',
    user.school_name ?? '',
    ...schoolBlock,
    ...user.roles.map((r) => r.name),
    ...roleVariants,
  ];

  return parts.join(' ').toLowerCase();
}

function userMatchesSearch(user: User, raw: string): boolean {
  const q = raw.trim().toLowerCase();
  if (!q) return true;
  const hay = buildUserSearchHaystack(user);
  const tokens = q.split(/\s+/).filter(Boolean);
  return tokens.every((t) => hay.includes(t));
}

const UsersPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [showPassword, setShowPassword] = useState(false);

  const [formData, setFormData] = useState({
    name: '',
    username: '',
    password: '',
    role: 'user',
    school_id: '' as '' | string,
    phone: '',
    grade: '',
    school_name: '',
  });

  const [userSearch, setUserSearch] = useState('');
  const [filterCity, setFilterCity]     = useState('');
  const [filterSchoolId, setFilterSchoolId] = useState('');

  const { data: usersData, isLoading } = useQuery({ queryKey: ['users'], queryFn: userApi.getAll });
  const { data: rolesData } = useQuery({ queryKey: ['roles'], queryFn: roleApi.getAll });
  const { data: schoolsData } = useQuery({ queryKey: ['schools'], queryFn: schoolsApi.getAll });

  const activeSchoolsForSelect = useMemo(() => {
    const active = (schoolsData?.data.schools ?? []).filter((s) => s.is_active);
    return schoolsWithSelectLabel(active);
  }, [schoolsData?.data.schools]);

  // Barcha mavjud tumanlar (city) — schools dan olinadi
  const cityOptions = useMemo(() => {
    const cities = (schoolsData?.data.schools ?? [])
      .map((s) => s.city)
      .filter((c): c is string => !!c);
    return [...new Set(cities)].sort((a, b) => a.localeCompare(b, 'uz'));
  }, [schoolsData?.data.schools]);

  // Tanlangan tumanga mos maktablar ro'yxati
  const schoolsForFilter = useMemo(() => {
    const all = (schoolsData?.data.schools ?? []).filter((s) => s.is_active);
    if (!filterCity) return schoolsWithSelectLabel(all);
    return schoolsWithSelectLabel(all.filter((s) => s.city === filterCity));
  }, [schoolsData?.data.schools, filterCity]);

  const hasActiveFilter = filterCity !== '' || filterSchoolId !== '';

  // Statistika kartochkalari uchun hisob-kitob
  const stats = useMemo(() => {
    const all = usersData?.data.users ?? [];
    const total      = all.length;
    const admins     = all.filter((u) => u.roles.some((r) => r.name === 'admin' || r.name === 'super_admin' || r.name === 'editor')).length;
    const students   = all.filter((u) => u.roles.some((r) => r.name === 'user')).length;
    const withSchool = all.filter((u) => u.school_id != null).length;
    const withPhone  = all.filter((u) => !!u.phone?.trim()).length;
    return { total, admins, students, withSchool, withPhone };
  }, [usersData?.data.users]);

  const filteredUsers = useMemo(() => {
    const list = usersData?.data.users ?? [];
    return list.filter((u) => {
      if (!userMatchesSearch(u, userSearch)) return false;
      if (filterCity) {
        if (!u.school || u.school.city !== filterCity) return false;
      }
      if (filterSchoolId) {
        if (u.school_id !== Number(filterSchoolId)) return false;
      }
      return true;
    });
  }, [usersData?.data.users, userSearch, filterCity, filterSchoolId]);

  const createMutation = useMutation({
    mutationFn: userApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['schools'] });
      handleCloseModal();
      toast.success(t('users.toast_created'));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Record<string, unknown> }) => userApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['schools'] });
      handleCloseModal();
      toast.success(t('users.toast_updated'));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const deleteMutation = useMutation({
    mutationFn: userApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['schools'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
      toast.success(t('users.toast_deleted'));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.delete_error'))),
  });

  const handleOpenModal = (user: User | null = null) => {
    if (user) {
      setEditingUser(user);
      setFormData({
        name: user.name,
        username: user.username || '',
        password: '',
        role: user.roles[0]?.name || 'user',
        school_id: user.school_id != null ? String(user.school_id) : '',
        phone: user.phone ?? '',
        grade: user.grade ?? '',
        school_name: user.school_name ?? '',
      });
    } else {
      setEditingUser(null);
      setFormData({
        name: '',
        username: '',
        password: '',
        role: 'user',
        school_id: '',
        phone: '',
        grade: '',
        school_name: '',
      });
    }
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingUser(null);
    setShowPassword(false);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const schoolId = formData.school_id === '' ? null : Number(formData.school_id);
    const phone = formData.phone.trim() || null;
    const grade = formData.grade.trim() || null;
    const school_name = formData.school_name.trim() || null;
    if (editingUser) {
      const data: Record<string, unknown> = {
        name: formData.name,
        username: formData.username || null,
        role: formData.role,
        school_id: schoolId,
        phone,
        grade,
        school_name,
      };
      if (formData.password) data.password = formData.password;
      updateMutation.mutate({ id: editingUser.id, data });
    } else {
      createMutation.mutate({
        name: formData.name,
        username: formData.username || undefined,
        password: formData.password,
        role: formData.role,
        school_id: schoolId,
        phone: phone ?? undefined,
        grade: grade ?? undefined,
        school_name: school_name ?? undefined,
      });
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('users.title')}</h1>
          <p className="text-app-muted mt-1">{t('users.subtitle')}</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('users.add_button')}
        </button>
      </div>

      {/* Statistika kartochkalari */}
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        <GlassCard className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-purple-500/15">
            <Users className="h-6 w-6 text-purple-500" />
          </div>
          <div className="min-w-0">
            <p className="text-2xl font-bold text-app-primary tabular-nums">
              {isLoading ? <Loader2 className="h-5 w-5 animate-spin text-purple-500" /> : stats.total}
            </p>
            <p className="truncate text-xs text-app-muted">{t('users.stat_total')}</p>
          </div>
        </GlassCard>

        <GlassCard className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-emerald-500/15">
            <BookOpen className="h-6 w-6 text-emerald-500" />
          </div>
          <div className="min-w-0">
            <p className="text-2xl font-bold text-app-primary tabular-nums">
              {isLoading ? <Loader2 className="h-5 w-5 animate-spin text-emerald-500" /> : stats.students}
            </p>
            <p className="truncate text-xs text-app-muted">{t('users.stat_students')}</p>
          </div>
        </GlassCard>

        <GlassCard className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-amber-500/15">
            <Shield className="h-6 w-6 text-amber-500" />
          </div>
          <div className="min-w-0">
            <p className="text-2xl font-bold text-app-primary tabular-nums">
              {isLoading ? <Loader2 className="h-5 w-5 animate-spin text-amber-500" /> : stats.admins}
            </p>
            <p className="truncate text-xs text-app-muted">{t('users.stat_admins')}</p>
          </div>
        </GlassCard>

        <GlassCard className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-sky-500/15">
            <Building2 className="h-6 w-6 text-sky-500" />
          </div>
          <div className="min-w-0">
            <p className="text-2xl font-bold text-app-primary tabular-nums">
              {isLoading ? <Loader2 className="h-5 w-5 animate-spin text-sky-500" /> : stats.withSchool}
            </p>
            <p className="truncate text-xs text-app-muted">{t('users.stat_with_school')}</p>
          </div>
        </GlassCard>
      </div>

      <GlassCard className="overflow-hidden p-0">
        <div className="border-b border-white/10 dark:border-white/10 px-4 py-3 sm:px-6">
          <div className="flex min-w-0 flex-nowrap items-center gap-2 overflow-x-auto scrollbar-none">
            <div className="relative min-w-[10rem] flex-1 basis-0">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-app-muted" aria-hidden />
              <input
                type="search"
                value={userSearch}
                onChange={(e) => setUserSearch(e.target.value)}
                placeholder={t('users.search_placeholder')}
                className="input-glass w-full min-w-0 pl-10 pr-3 py-2.5 text-sm"
                autoComplete="off"
              />
            </div>

            <div className="relative w-44 shrink-0 sm:w-48">
              <MapPin className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-app-muted" aria-hidden />
              <select
                value={filterCity}
                onChange={(e) => {
                  setFilterCity(e.target.value);
                  setFilterSchoolId('');
                }}
                className="input-glass w-full pl-9 pr-3 py-2.5 text-sm appearance-none"
              >
                <option value="">{t('users.filter_city_all')}</option>
                {cityOptions.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
            </div>

            <div className="relative w-52 shrink-0 sm:w-56">
              <SchoolIcon className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-app-muted" aria-hidden />
              <select
                value={filterSchoolId}
                onChange={(e) => setFilterSchoolId(e.target.value)}
                className="input-glass w-full pl-9 pr-3 py-2.5 text-sm appearance-none"
                disabled={schoolsForFilter.length === 0}
              >
                <option value="">{t('users.filter_school_all')}</option>
                {schoolsForFilter.map((s) => (
                  <option key={s.id} value={String(s.id)}>{s.selectLabel}</option>
                ))}
              </select>
            </div>

            {hasActiveFilter ? (
              <button
                type="button"
                onClick={() => { setFilterCity(''); setFilterSchoolId(''); }}
                className="flex shrink-0 items-center gap-1.5 rounded-2xl border border-red-500/20 px-3 py-2.5 text-sm text-red-500 transition-all hover:bg-red-500/10 dark:text-red-400 whitespace-nowrap"
                title={t('users.filter_clear')}
              >
                <X className="h-4 w-4 shrink-0" />
                {t('users.filter_clear')}
              </button>
            ) : null}
          </div>
        </div>
        <div className="overflow-x-auto scrollbar-none">
          <table className="data-table-shell w-full text-left border-collapse">
            <thead>
              <tr>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('users.table_user')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('users.table_username')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('users.table_phone')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('users.table_grade')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('users.table_school')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('users.table_role')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle text-right">{t('users.table_actions')}</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={7} className="px-6 py-10 text-center">
                    <Loader2 className="w-8 h-8 animate-spin mx-auto text-purple-500" />
                  </td>
                </tr>
              ) : filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-10 text-center text-app-muted">
                    {userSearch.trim() || hasActiveFilter
                      ? t('users.search_none')
                      : t('users.empty_list')}
                  </td>
                </tr>
              ) : (
                filteredUsers.map((user) => (
                  <tr key={user.id}>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl glass flex items-center justify-center text-purple-600 dark:text-purple-400">
                          <UserIcon className="w-5 h-5" />
                        </div>
                        <span className="font-medium text-app-primary">{user.name}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-app-muted">
                      {user.username ? (
                        <span className="font-mono text-purple-400">@{user.username}</span>
                      ) : (
                        <span className="text-app-muted/40">—</span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-sm text-app-muted whitespace-nowrap">
                      {user.phone?.trim() ? user.phone : <span className="text-app-muted/40">—</span>}
                    </td>
                    <td className="px-6 py-4 text-sm text-app-muted whitespace-nowrap">
                      {user.grade?.trim() ? user.grade : <span className="text-app-muted/40">—</span>}
                    </td>
                    <td className="px-6 py-4 text-sm max-w-[min(22rem,40vw)]">
                      {user.school ? (
                        <div className="space-y-0.5">
                          <div className="font-medium text-app-primary leading-snug">{user.school.name}</div>
                          <div
                            className="text-xs text-app-muted tabular-nums leading-snug"
                            title={schoolLocationSubtitle(user.school)}
                          >
                            {schoolLocationSubtitle(user.school)}
                          </div>
                        </div>
                      ) : user.school_id != null && user.school_id > 0 ? (
                        <span className="text-xs text-amber-600 dark:text-amber-400" title={t('users.school_record_missing_hint')}>
                          {t('users.school_id_only', { id: user.school_id })}
                        </span>
                      ) : (
                        <span className="text-app-muted/40">—</span>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      {user.roles.length > 0 ? (
                        user.roles.map(role => (
                          <span
                            key={role.id}
                            className="px-3 py-1 rounded-full bg-purple-500/10 text-purple-700 dark:text-purple-300 text-xs font-semibold flex items-center w-fit gap-1 capitalize"
                          >
                            <Shield className="w-3 h-3" />
                            {role.name.replace('_', ' ')}
                          </span>
                        ))
                      ) : (
                        <span className="text-app-muted/40 text-sm">—</span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-sm text-right">
                      <div className="flex justify-end gap-1 sm:gap-2">
                        <button
                          type="button"
                          onClick={() => handleOpenModal(user)}
                          className="p-2 rounded-xl hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-purple-500 dark:hover:text-purple-300 transition-all"
                          title={t('common.edit')}
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button
                          type="button"
                          disabled={user.username === 'admin' || user.email === 'admin@kimyo.uz'}
                          onClick={() => {
                            setDeletingId(user.id);
                            setIsDeleteModalOpen(true);
                          }}
                          className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 disabled:opacity-30 disabled:hover:bg-transparent transition-all"
                          title={t('common.delete')}
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
        title={t('users.delete_title')}
        message={t('users.delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingUser ? t('users.edit_title') : t('users.create_title')}
        className="max-w-3xl w-full max-h-[min(92vh,52rem)] flex flex-col overflow-hidden"
      >
        <form onSubmit={handleSubmit} className="flex min-h-0 flex-1 flex-col">
          <div className="min-h-0 flex-1 space-y-5 overflow-y-auto overflow-x-hidden overscroll-contain pb-2 scrollbar-none">
            {editingUser ? (
              <p className="text-xs font-mono text-app-muted tabular-nums">
                {t('users.form_meta_id', { id: editingUser.id })}
              </p>
            ) : null}

            <div className="grid grid-cols-1 gap-5 md:grid-cols-2">
              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('users.form_name')}</label>
                <div className="relative">
                  <UserIcon className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={e => setFormData({ ...formData, name: e.target.value })}
                    className="input-glass pl-12"
                    placeholder="John Doe"
                  />
                </div>
              </div>

              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('users.form_username')}</label>
                <div className="relative">
                  <AtSign className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                  <input
                    type="text"
                    value={formData.username}
                    onChange={e => setFormData({ ...formData, username: e.target.value })}
                    className="input-glass pl-12"
                    placeholder={t('users.form_username_placeholder')}
                  />
                </div>
              </div>

              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-medium text-app-subtle ml-1">
                  {t('users.form_password')} {editingUser && t('users.form_password_hint')}
                </label>
                <div className="relative">
                  <Key className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    required={!editingUser}
                    value={formData.password}
                    onChange={e => setFormData({ ...formData, password: e.target.value })}
                    className="input-glass pl-12 pr-12"
                    placeholder="••••••••"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-app-muted transition-colors hover:text-app-primary dark:hover:text-white"
                  >
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('users.form_phone')}</label>
                <div className="relative">
                  <Phone className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                  <input
                    type="text"
                    inputMode="tel"
                    autoComplete="tel"
                    value={formData.phone}
                    onChange={e => setFormData({ ...formData, phone: e.target.value })}
                    className="input-glass pl-12"
                    placeholder={t('users.form_phone_placeholder')}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('users.form_grade')}</label>
                <div className="relative">
                  <GraduationCap className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                  <input
                    type="text"
                    value={formData.grade}
                    onChange={e => setFormData({ ...formData, grade: e.target.value })}
                    className="input-glass pl-12"
                    placeholder={t('users.form_grade_placeholder')}
                  />
                </div>
              </div>

              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('users.form_school')}</label>
                <select
                  value={formData.school_id}
                  onChange={(e) => setFormData({ ...formData, school_id: e.target.value as '' | string })}
                  className="input-glass w-full"
                >
                  <option value="">{t('users.form_school_none')}</option>
                  {activeSchoolsForSelect.map((s) => (
                    <option key={s.id} value={String(s.id)}>
                      {s.selectLabel}
                    </option>
                  ))}
                </select>
                <p className="text-xs text-app-muted ml-1">{t('users.form_school_hint')}</p>
              </div>

              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('users.form_school_name')}</label>
                <div className="relative">
                  <Building className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                  <input
                    type="text"
                    value={formData.school_name}
                    onChange={e => setFormData({ ...formData, school_name: e.target.value })}
                    className="input-glass pl-12"
                    placeholder={t('schools.form_name_placeholder')}
                  />
                </div>
                <p className="text-xs text-app-muted ml-1">{t('users.form_school_name_hint')}</p>
              </div>

              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('users.form_role')}</label>
                <select
                  value={formData.role}
                  onChange={e => setFormData({ ...formData, role: e.target.value })}
                  className="input-glass w-full"
                >
                  {rolesData?.data.roles.map(role => (
                    <option key={role.id} value={role.name}>
                      {role.name.charAt(0).toUpperCase() + role.name.slice(1).replace('_', ' ')}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>

          <div className="mt-4 flex shrink-0 gap-4 border-t border-white/10 pt-4 dark:border-white/10">
            <button type="button" onClick={handleCloseModal} className="flex-1 btn-modal-secondary">
              {t('common.cancel')}
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending || updateMutation.isPending}
              className="flex-1 btn-primary flex items-center justify-center gap-2"
            >
              {(createMutation.isPending || updateMutation.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
              {editingUser ? t('common.save') : t('common.create')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

export default UsersPage;

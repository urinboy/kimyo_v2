import type { ElementType } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import {
  User,
  Mail,
  AtSign,
  Shield,
  Phone,
  GraduationCap,
  Building2,
  Hash,
  ChevronLeft,
  Loader2,
} from 'lucide-react';
import { authApi } from '@/api/auth';
import { useAuthStore, type User as AuthUser } from '@/store/useAuthStore';
import { GlassCard } from '@/components/ui/GlassCard';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';

function ProfileField({
  icon: Icon,
  label,
  value,
}: {
  icon: ElementType;
  label: string;
  value: string;
}) {
  return (
    <div className="flex gap-4 rounded-2xl border border-black/5 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.03] p-5">
      <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-purple-500/15 text-purple-600 dark:text-purple-400">
        <Icon className="h-5 w-5" />
      </div>
      <div className="min-w-0 flex-1">
        <p className="text-xs font-bold uppercase tracking-wider text-app-muted">{label}</p>
        <p className="mt-1 truncate text-sm font-semibold text-app-primary">{value}</p>
      </div>
    </div>
  );
}

export default function ProfilePage() {
  const { t } = useTranslation();
  const storeUser = useAuthStore((s) => s.user);

  const { data, isLoading, isError, error, refetch, isFetching } = useQuery({
    queryKey: ['auth-me'],
    queryFn: authApi.me,
  });

  const apiUser = data?.status === 'success' ? (data.data?.user as AuthUser | undefined) : undefined;
  const user = apiUser ?? storeUser;

  const initials = (user?.name || '?')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase())
    .join('');

  return (
    <div className="space-y-10 animate-in fade-in slide-in-from-bottom-6 duration-700">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <Link
            to="/"
            className="mb-3 inline-flex items-center gap-2 text-sm font-semibold text-app-muted transition-colors hover:text-purple-600 dark:hover:text-purple-400"
          >
            <ChevronLeft className="h-4 w-4" />
            {t('profile.back_dashboard')}
          </Link>
          <h1 className="text-4xl font-black tracking-tight text-app-primary">
            {t('profile.title')}
          </h1>
          <p className="mt-2 flex items-center gap-2 text-body-secondary">
            <Shield className="h-4 w-4 text-purple-600 dark:text-purple-400" />
            {t('profile.subtitle')}
          </p>
        </div>
        <button
          type="button"
          onClick={() => refetch()}
          disabled={isFetching}
          className="self-start rounded-2xl glass px-6 py-3 text-sm font-bold text-app-primary transition-all hover:bg-black/5 dark:hover:bg-white/5 disabled:opacity-60"
        >
          {isFetching ? (
            <span className="inline-flex items-center gap-2">
              <Loader2 className="h-4 w-4 animate-spin" />
              {t('profile.refreshing')}
            </span>
          ) : (
            t('profile.refresh')
          )}
        </button>
      </div>

      {isError && (
        <GlassCard className="border-red-500/20 bg-red-500/5 p-6">
          <p className="text-sm font-semibold text-red-600 dark:text-red-400">
            {getApiErrorMessage(error, t('profile.load_error'))}
          </p>
        </GlassCard>
      )}

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-12">
        <GlassCard className="relative overflow-hidden p-10 lg:col-span-5">
          <div className="absolute right-0 top-0 p-8 opacity-[0.06]">
            <User className="h-40 w-40 text-app-primary" />
          </div>
          <div className="relative z-10 flex flex-col items-center text-center">
            {isLoading && !user ? (
              <div className="flex flex-col items-center gap-4 py-8">
                <Loader2 className="h-10 w-10 animate-spin text-purple-500" />
                <p className="text-sm text-app-muted">{t('profile.loading')}</p>
              </div>
            ) : (
              <>
                <div className="mb-6 flex h-28 w-28 items-center justify-center rounded-3xl bg-gradient-to-br from-purple-500 to-indigo-600 text-3xl font-black text-white shadow-lg shadow-purple-500/30">
                  {initials || <User className="h-12 w-12" />}
                </div>
                <h2 className="text-2xl font-bold text-app-primary">{user?.name ?? '—'}</h2>
                <p className="mt-1 text-sm text-app-muted">{t('header.role')}</p>
                <div className="mt-6 w-full rounded-2xl border border-black/5 dark:border-white/10 bg-black/[0.02] dark:bg-white/[0.03] px-4 py-3 text-xs font-mono text-app-muted">
                  ID · {user?.id ?? '—'}
                </div>
              </>
            )}
          </div>
        </GlassCard>

        <div className="space-y-6 lg:col-span-7">
          <GlassCard className="p-8">
            <h3 className="mb-6 text-lg font-bold text-app-primary">{t('profile.account_section')}</h3>
            {!user && !isLoading ? (
              <p className="text-sm text-app-muted">{t('profile.no_user')}</p>
            ) : (
              <div className="grid gap-4 sm:grid-cols-2">
                {user && (
                  <>
                    <ProfileField icon={Mail} label={t('profile.email')} value={user.email || '—'} />
                    <ProfileField
                      icon={Shield}
                      label={t('profile.role')}
                      value={user.role || t('header.role')}
                    />
                  </>
                )}
                {(user?.username != null && String(user.username).trim() !== '') && (
                  <ProfileField icon={AtSign} label={t('profile.username')} value={String(user.username)} />
                )}
                {(user?.phone != null && String(user.phone).trim() !== '') && (
                  <ProfileField icon={Phone} label={t('profile.phone')} value={String(user.phone)} />
                )}
                {(user?.school_name != null && String(user.school_name).trim() !== '') && (
                  <ProfileField icon={Building2} label={t('profile.school')} value={String(user.school_name)} />
                )}
                {(user?.grade != null && String(user.grade).trim() !== '') && (
                  <ProfileField icon={GraduationCap} label={t('profile.grade')} value={String(user.grade)} />
                )}
                {user?.school_id != null && user.school_id > 0 && (
                  <ProfileField icon={Hash} label={t('profile.school_id')} value={String(user.school_id)} />
                )}
              </div>
            )}
          </GlassCard>

          <GlassCard className="border-purple-500/10 bg-purple-500/[0.04] p-6 dark:bg-purple-500/10">
            <p className="text-sm leading-relaxed text-app-muted">{t('profile.readonly_hint')}</p>
          </GlassCard>
        </div>
      </div>
    </div>
  );
}

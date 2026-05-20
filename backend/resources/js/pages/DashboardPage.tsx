import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { dashboardApi } from '../api/dashboard';
import { GlassCard } from '../components/ui/GlassCard';
import { ResearchStatsSection } from '@/components/dashboard/ResearchStatsSection';
import { KpiStatCard } from '@/components/dashboard/KpiStatCard';
import { ContentOverviewChart } from '@/components/dashboard/ContentOverviewChart';
import { ModuleMixChart } from '@/components/dashboard/ModuleMixChart';
import { ActivityTrendChart } from '@/components/dashboard/ActivityTrendChart';
import { SystemHealthChart } from '@/components/dashboard/SystemHealthChart';
import {
  Atom,
  BookOpen,
  Users,
  FlaskConical,
  LayoutDashboard,
  Activity,
  Globe2,
  Clock,
  ChevronRight,
  Sparkles,
} from 'lucide-react';
import { ChemicalFormulaText } from '@/components/ui/ChemicalFormulaText';

export default function DashboardPage() {
  const { t, i18n } = useTranslation();

  const { data: statsData } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: dashboardApi.getStats,
  });

  const { data: activityData, isLoading: activityLoading } = useQuery({
    queryKey: ['dashboard-activity'],
    queryFn: dashboardApi.getActivity,
  });

  const { data: researchRes } = useQuery({
    queryKey: ['dashboard-research-stats'],
    queryFn: dashboardApi.getResearchStats,
    staleTime: 1000 * 60 * 60,
  });

  const stats = statsData?.data.stats;
  const activity = activityData?.data;

  const formatUserDate = (iso: string) =>
    new Intl.DateTimeFormat(i18n.language, { dateStyle: 'medium' }).format(new Date(iso));

  const quickActions = [
    { name: t('dashboard.action_periodic_table'), desc: t('dashboard.action_periodic_table_desc') },
    { name: t('dashboard.action_languages'), desc: t('dashboard.action_languages_desc') },
    { name: t('dashboard.action_backup'), desc: t('dashboard.action_backup_desc') },
    { name: t('dashboard.action_support'), desc: t('dashboard.action_support_desc') },
  ];

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-6 duration-700">
      {/* Hero header */}
      <div className="relative overflow-hidden rounded-3xl border border-black/5 dark:border-white/10 bg-gradient-to-br from-purple-500/10 via-white/40 to-emerald-500/10 dark:from-purple-900/30 dark:via-slate-900/40 dark:to-emerald-900/20 p-8 md:p-10">
        <div className="absolute -right-8 -top-8 w-48 h-48 rounded-full bg-purple-500/10 blur-3xl pointer-events-none" />
        <div className="absolute -left-8 bottom-0 w-40 h-40 rounded-full bg-emerald-500/10 blur-3xl pointer-events-none" />
        <div className="relative flex flex-col lg:flex-row lg:items-center justify-between gap-6">
          <div className="max-w-2xl">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-purple-500/15 border border-purple-500/25 text-xs font-bold text-purple-700 dark:text-purple-300 mb-4">
              <Sparkles className="w-3.5 h-3.5" />
              Kimyo V2 · {t('dashboard.hero_badge')}
            </div>
            <h1 className="text-3xl md:text-4xl font-black tracking-tight text-app-primary">
              {t('dashboard.title')}
            </h1>
            <p className="text-body-secondary mt-3 flex items-center gap-2 text-base">
              <Activity className="w-4 h-4 text-purple-600 dark:text-purple-400 shrink-0" />
              {t('dashboard.subtitle')}
            </p>
          </div>
          <div className="flex gap-3 shrink-0">
            <button className="px-5 py-3 rounded-2xl glass text-sm font-bold text-app-primary hover:bg-black/5 dark:hover:bg-white/5 transition-all">
              {t('dashboard.export_data')}
            </button>
            <button className="btn-primary px-5 py-3">{t('dashboard.new_report')}</button>
          </div>
        </div>
      </div>

      {/* KPI row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">
        <KpiStatCard
          title={t('dashboard.stat_elements')}
          value={stats?.total_elements || 0}
          icon={Atom}
          color="purple"
          growthLabel={t('dashboard.growth_badge')}
        />
        <KpiStatCard
          title={t('dashboard.stat_lessons')}
          value={stats?.total_lessons || 0}
          icon={BookOpen}
          color="emerald"
          growthLabel={t('dashboard.growth_badge')}
        />
        <KpiStatCard
          title={t('dashboard.stat_users')}
          value={stats?.total_users || 0}
          icon={Users}
          color="blue"
          growthLabel={t('dashboard.growth_badge')}
        />
        <KpiStatCard
          title={t('dashboard.stat_formulas')}
          value={stats?.total_formulas || 0}
          icon={FlaskConical}
          color="amber"
          growthLabel={t('dashboard.growth_badge')}
        />
      </div>

      {/* Analytics charts */}
      <div className="grid grid-cols-1 xl:grid-cols-12 gap-6">
        <div className="xl:col-span-8">
          <ContentOverviewChart stats={stats} />
        </div>
        <div className="xl:col-span-4">
          <ModuleMixChart stats={stats} />
        </div>
      </div>

      {researchRes?.data && <ResearchStatsSection data={researchRes.data} />}

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <div className="lg:col-span-5">
          <GlassCard className="!p-8 h-full flex flex-col justify-center relative overflow-hidden min-h-[320px]">
            <div className="absolute top-0 right-0 p-8 opacity-[0.04]">
              <LayoutDashboard className="w-56 h-56" />
            </div>
            <div className="relative z-10">
              <div className="w-12 h-12 rounded-2xl bg-purple-500/20 flex items-center justify-center mb-5">
                <Globe2 className="w-6 h-6 text-purple-600 dark:text-purple-400" />
              </div>
              <h2 className="text-2xl font-bold mb-3 leading-tight text-app-primary">
                {t('dashboard.welcome_title')}
              </h2>
              <p className="text-body-secondary leading-relaxed mb-6">{t('dashboard.welcome_body')}</p>
              <div className="flex gap-3 flex-wrap">
                <div className="px-4 py-2 rounded-xl bg-black/5 dark:bg-white/5 border border-black/5 dark:border-white/10 text-xs font-bold text-app-muted">
                  {t('dashboard.latest_version', { version: '2.5.13' })}
                </div>
                <div className="px-4 py-2 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-xs font-bold text-emerald-700 dark:text-emerald-400">
                  {t('dashboard.system_health', { percent: 100 })}
                </div>
              </div>
            </div>
          </GlassCard>
        </div>

        <div className="lg:col-span-7">
          <SystemHealthChart />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <div className="lg:col-span-8">
          <ActivityTrendChart activity={activity} loading={activityLoading} />
        </div>
        <div className="lg:col-span-4">
          <GlassCard className="!p-6 h-full flex flex-col">
            <h3 className="text-lg font-bold mb-5 flex items-center gap-2 text-app-primary">
              <Activity className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
              {t('dashboard.quick_actions')}
            </h3>
            <div className="space-y-2.5 flex-1">
              {quickActions.map((action, i) => (
                <button
                  key={i}
                  className="w-full p-4 rounded-2xl bg-black/5 dark:bg-white/5 border border-black/5 dark:border-white/5 hover:border-purple-500/30 hover:bg-purple-500/5 text-left transition-all group"
                >
                  <p className="font-bold text-sm text-app-primary group-hover:text-purple-600 dark:group-hover:text-purple-400 transition-colors">
                    {action.name}
                  </p>
                  <p className="text-xs text-app-subtle mt-1">{action.desc}</p>
                </button>
              ))}
            </div>
          </GlassCard>
        </div>
      </div>

      {/* Recent activity lists */}
      <GlassCard className="!p-6 md:!p-8">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-xl font-bold flex items-center gap-2 text-app-primary">
            <Clock className="w-5 h-5 text-purple-600 dark:text-purple-400" />
            {t('dashboard.recent_activity')}
          </h3>
          <button className="text-sm text-purple-600 dark:text-purple-400 font-bold hover:underline flex items-center gap-1">
            {t('dashboard.view_all')} <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        {activityLoading ? (
          <div className="animate-pulse grid grid-cols-1 md:grid-cols-3 gap-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-40 bg-black/5 dark:bg-white/5 rounded-2xl" />
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="space-y-3">
              <h4 className="text-kpi-header">{t('dashboard.latest_elements')}</h4>
              {activity?.latest_elements.map((element) => (
                <div
                  key={element.id}
                  className="flex items-center gap-3 p-3 rounded-xl bg-black/5 dark:bg-white/5 border border-black/5 dark:border-white/5 hover:border-purple-500/20 transition-colors"
                >
                  <div className="w-10 h-10 rounded-xl bg-purple-500/20 flex items-center justify-center font-bold text-purple-600 dark:text-purple-400">
                    {element.symbol}
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-bold text-app-primary truncate">
                      {element.translations[0]?.name || t('dashboard.unknown')}
                    </p>
                    <p className="text-caption">{t('dashboard.atomic_number', { number: element.atomic_number })}</p>
                  </div>
                </div>
              ))}
            </div>
            <div className="space-y-3">
              <h4 className="text-kpi-header">{t('dashboard.latest_formulas')}</h4>
              {activity?.latest_formulas.map((formula) => (
                <div
                  key={formula.id}
                  className="flex items-center gap-3 p-3 rounded-xl bg-black/5 dark:bg-white/5 border border-black/5 dark:border-white/5 hover:border-amber-500/20 transition-colors"
                >
                  <div className="w-10 h-10 rounded-xl bg-amber-500/20 flex items-center justify-center px-0.5 overflow-hidden">
                    <ChemicalFormulaText
                      formula={formula.formula}
                      className="text-[10px] font-mono font-bold leading-tight text-center line-clamp-2 text-amber-700 dark:text-amber-400"
                    />
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-bold text-app-primary truncate">
                      {formula.translations[0]?.name || t('dashboard.unknown')}
                    </p>
                    <p className="text-caption">
                      {formula.molar_mass != null && !Number.isNaN(Number(formula.molar_mass))
                        ? `${Number(formula.molar_mass).toFixed(4)} g/mol`
                        : '—'}
                    </p>
                  </div>
                </div>
              ))}
            </div>
            <div className="space-y-3">
              <h4 className="text-kpi-header">{t('dashboard.new_users')}</h4>
              {activity?.latest_users.map((user) => (
                <div
                  key={user.id}
                  className="flex items-center gap-3 p-3 rounded-xl bg-black/5 dark:bg-white/5 border border-black/5 dark:border-white/5 hover:border-emerald-500/20 transition-colors"
                >
                  <div className="w-10 h-10 rounded-xl bg-emerald-500/20 flex items-center justify-center font-bold text-emerald-600 dark:text-emerald-400 uppercase">
                    {user.name.charAt(0)}
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-bold text-app-primary truncate">{user.name}</p>
                    <p className="text-caption">{formatUserDate(user.created_at)}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </GlassCard>
    </div>
  );
}

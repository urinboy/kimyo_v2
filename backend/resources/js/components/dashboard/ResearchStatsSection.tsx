import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { GlassCard } from '@/components/ui/GlassCard';
import { FlaskConical, TrendingUp, BarChart2, CheckCircle2, BookOpen } from 'lucide-react';
import type { ResearchStatsData, ResearchGradeRow, DistrictStats } from '@/api/dashboard';
import { ResearchChartsRow } from './ResearchCharts';

const GRADE_COLORS: { grade: number; bg: string; text: string }[] = [
  { grade: 5, bg: 'bg-purple-500',  text: 'text-purple-500' },
  { grade: 4, bg: 'bg-emerald-500', text: 'text-emerald-500' },
  { grade: 3, bg: 'bg-amber-400',   text: 'text-amber-400' },
  { grade: 2, bg: 'bg-red-400',     text: 'text-red-400' },
];

type GradeKey =
  | 'tajriba_tb_pct' | 'tajriba_to_pct'
  | 'nazorat_tb_pct' | 'nazorat_to_pct';

type GradeCountKey =
  | 'tajriba_tb' | 'tajriba_to'
  | 'nazorat_tb' | 'nazorat_to';

const PCT_TO_COUNT: Record<GradeKey, GradeCountKey> = {
  tajriba_tb_pct: 'tajriba_tb',
  tajriba_to_pct: 'tajriba_to',
  nazorat_tb_pct: 'nazorat_tb',
  nazorat_to_pct: 'nazorat_to',
};

function gradeLabelKey(grade: number): string {
  return `research_stats.grade_${grade}`;
}

function StackedBar({
  grades,
  dataKey,
  label,
  total,
  countSuffix,
}: {
  grades: ResearchGradeRow[];
  dataKey: GradeKey;
  label: string;
  total: number;
  countSuffix: string;
}) {
  const { t } = useTranslation();
  const countKey = PCT_TO_COUNT[dataKey];

  const segments = useMemo(() => {
    return [...GRADE_COLORS].reverse().map((meta) => {
      const row = grades.find((g) => g.grade === meta.grade);
      return {
        ...meta,
        label: t(gradeLabelKey(meta.grade)),
        pct:   (row?.[dataKey]  as number) ?? 0,
        count: (row?.[countKey] as number) ?? 0,
      };
    });
  }, [grades, dataKey, countKey, t]);

  return (
    <div className="flex flex-col items-center gap-2 flex-1 min-w-[68px]">
      <div className="relative w-full h-44 flex flex-col-reverse rounded-xl overflow-hidden border border-black/10 dark:border-white/10 shadow-sm">
        {segments.map((seg) =>
          seg.pct > 0 ? (
            <div
              key={seg.grade}
              className={`${seg.bg} transition-all duration-500 relative`}
              style={{ height: `${seg.pct}%` }}
              title={`${seg.label}: ${seg.pct}% (${seg.count} ${countSuffix})`}
            >
              {seg.pct >= 9 && (
                <span className="absolute inset-0 flex items-center justify-center text-[10px] font-bold text-white drop-shadow leading-tight">
                  {seg.pct}%
                </span>
              )}
            </div>
          ) : null,
        )}
      </div>
      <p className="text-[10px] font-semibold text-center text-app-muted leading-tight whitespace-pre-line">
        {label}
      </p>
      <p className="text-[10px] text-app-subtle">{total} {countSuffix}</p>
    </div>
  );
}

function ResearchStatCard({
  label,
  value,
  sub,
  colorClass,
  icon: Icon,
}: {
  label: string;
  value: string;
  sub?: string;
  colorClass: string;
  icon: React.ElementType;
}) {
  return (
    <div className="glass rounded-2xl p-4 flex items-start gap-3 border border-black/5 dark:border-white/10">
      <div className={`p-2 rounded-xl bg-black/5 dark:bg-white/5 ${colorClass} flex-shrink-0`}>
        <Icon className="w-5 h-5" />
      </div>
      <div className="min-w-0">
        <p className="text-[10px] font-bold text-app-muted uppercase tracking-wider leading-tight">{label}</p>
        <p className="text-xl font-black text-app-primary mt-0.5 truncate">{value}</p>
        {sub && <p className="text-[10px] text-app-subtle mt-0.5 leading-tight">{sub}</p>}
      </div>
    </div>
  );
}

function GradeTableRow({ row }: { row: ResearchGradeRow }) {
  const { t } = useTranslation();
  const meta = GRADE_COLORS.find((m) => m.grade === row.grade);
  if (!meta) return null;
  return (
    <tr className="border-b border-black/5 dark:border-white/5 hover:bg-black/[0.02] dark:hover:bg-white/[0.02] transition-colors">
      <td className="py-2.5 pr-3">
        <span className={`inline-flex items-center gap-1.5 font-semibold text-sm ${meta.text}`}>
          <span className={`w-2 h-2 rounded-full flex-shrink-0 ${meta.bg}`} />
          {t(gradeLabelKey(row.grade))}
        </span>
      </td>
      <td className="py-2.5 pr-3 text-sm text-app-muted whitespace-nowrap">
        {row.tajriba_tb} <span className="text-xs opacity-60">({row.tajriba_tb_pct}%)</span>
      </td>
      <td className="py-2.5 pr-3 text-sm font-semibold text-purple-600 dark:text-purple-400 whitespace-nowrap">
        {row.tajriba_to} <span className="text-xs font-normal opacity-70">({row.tajriba_to_pct}%)</span>
      </td>
      <td className="py-2.5 pr-3 text-sm text-app-muted whitespace-nowrap">
        {row.nazorat_tb} <span className="text-xs opacity-60">({row.nazorat_tb_pct}%)</span>
      </td>
      <td className="py-2.5 text-sm text-app-muted whitespace-nowrap">
        {row.nazorat_to} <span className="text-xs opacity-60">({row.nazorat_to_pct}%)</span>
      </td>
    </tr>
  );
}

interface ResearchStatsSectionProps {
  data: ResearchStatsData;
}

type TabId = 'totals' | string;

export function ResearchStatsSection({ data }: ResearchStatsSectionProps) {
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = useState<TabId>('totals');

  const countSuffix = t('research_stats.count_suffix');
  const beforeLabel = t('research_stats.before');
  const afterLabel = t('research_stats.after');

  const tabs: { id: TabId; label: string }[] = [
    { id: 'totals', label: t('research_stats.tab_all') },
    ...data.districts.map((d) => ({ id: d.id, label: d.name })),
  ];

  const isTotal = activeTab === 'totals';
  const currentDistrict = isTotal ? null : data.districts.find((d) => d.id === activeTab);

  const grades: ResearchGradeRow[] = isTotal ? data.totals.grades : (currentDistrict?.grades ?? []);
  const stats: DistrictStats = isTotal ? data.totals.stats : (currentDistrict?.stats ?? data.totals.stats);
  const tajribaCount = isTotal ? data.totals.tajriba_count : (currentDistrict?.tajriba_count ?? 0);
  const nazoratCount = isTotal ? data.totals.nazorat_count : (currentDistrict?.nazorat_count ?? 0);
  const chi2Critical = data.totals.stats.chi2_critical ?? 7.81;
  const h1Confirmed = stats.chi2_end > chi2Critical;

  return (
    <GlassCard className="p-6 md:p-8 space-y-7">
      <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
        <div className="flex items-start gap-3">
          <div className="p-3 rounded-2xl bg-purple-500/10 border border-purple-500/20 flex-shrink-0">
            <FlaskConical className="w-6 h-6 text-purple-600 dark:text-purple-400" />
          </div>
          <div>
            <h3 className="text-xl font-bold text-app-primary">
              {t('research_stats.title')}
            </h3>
            <p className="text-sm text-app-muted mt-1 leading-relaxed">
              {t('research_stats.subtitle')}
            </p>
          </div>
        </div>

        <div
          className={`flex items-center gap-2 px-4 py-2 rounded-2xl border text-sm font-bold whitespace-nowrap self-start ${
            h1Confirmed
              ? 'bg-emerald-500/10 border-emerald-500/30 text-emerald-700 dark:text-emerald-400'
              : 'bg-amber-500/10 border-amber-500/30 text-amber-700 dark:text-amber-400'
          }`}
        >
          <CheckCircle2 className="w-4 h-4" />
          {h1Confirmed
            ? t('research_stats.h1_confirmed')
            : t('research_stats.h0_not_confirmed')}
        </div>
      </div>

      <div className="flex flex-wrap gap-2">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            type="button"
            onClick={() => setActiveTab(tab.id)}
            className={`px-4 py-2 rounded-2xl text-sm font-bold transition-all duration-200 ${
              activeTab === tab.id
                ? 'bg-purple-500/20 border border-purple-500/40 text-purple-700 dark:text-purple-300'
                : 'glass border border-black/5 dark:border-white/10 text-app-muted hover:text-app-primary hover:bg-black/5 dark:hover:bg-white/5'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <ResearchStatCard
          label={t('research_stats.eta_label')}
          value={`η = ${stats.eta.toFixed(2)}`}
          sub={t('research_stats.improvement_sub', { pct: stats.improvement_pct.toFixed(0) })}
          colorClass="text-purple-600 dark:text-purple-400"
          icon={TrendingUp}
        />
        <ResearchStatCard
          label={t('research_stats.chi2_label')}
          value={stats.chi2_end.toFixed(2)}
          sub={h1Confirmed
            ? t('research_stats.chi2_sub_confirmed', { critical: chi2Critical })
            : t('research_stats.chi2_sub_not_confirmed', { critical: chi2Critical })}
          colorClass={h1Confirmed ? 'text-emerald-600 dark:text-emerald-400' : 'text-amber-600 dark:text-amber-400'}
          icon={BarChart2}
        />
        <ResearchStatCard
          label={t('research_stats.mean_tajriba')}
          value={`x̄ = ${stats.mean_tajriba.toFixed(2)}`}
          sub={t('research_stats.students_count', { count: tajribaCount })}
          colorClass="text-blue-600 dark:text-blue-400"
          icon={BookOpen}
        />
        <ResearchStatCard
          label={t('research_stats.mean_nazorat')}
          value={`ȳ = ${stats.mean_nazorat.toFixed(2)}`}
          sub={t('research_stats.students_count', { count: nazoratCount })}
          colorClass="text-slate-500 dark:text-slate-400"
          icon={BookOpen}
        />
      </div>

      <ResearchChartsRow data={data} grades={grades} />

      <div>
        <h4 className="text-xs font-bold text-app-muted uppercase tracking-wider mb-5 flex items-center gap-2">
          <BarChart2 className="w-4 h-4" />
          {t('research_stats.chart_title')}
          {' — '}
          {isTotal ? t('research_stats.tab_all') : (currentDistrict?.name ?? '')}
        </h4>

        <div className="flex items-end gap-4 overflow-x-auto pb-2">
          <div className="flex flex-col items-center gap-2 flex-shrink-0">
            <span className="text-[11px] font-extrabold text-purple-600 dark:text-purple-400 uppercase tracking-widest">
              {t('research_stats.tajriba_group')}
            </span>
            <div className="flex gap-2">
              <StackedBar grades={grades} dataKey="tajriba_tb_pct" label={beforeLabel} total={tajribaCount} countSuffix={countSuffix} />
              <StackedBar grades={grades} dataKey="tajriba_to_pct" label={afterLabel} total={tajribaCount} countSuffix={countSuffix} />
            </div>
          </div>

          <div className="w-px self-stretch bg-black/10 dark:bg-white/10 flex-shrink-0" />

          <div className="flex flex-col items-center gap-2 flex-shrink-0">
            <span className="text-[11px] font-extrabold text-slate-500 dark:text-slate-400 uppercase tracking-widest">
              {t('research_stats.nazorat_group')}
            </span>
            <div className="flex gap-2">
              <StackedBar grades={grades} dataKey="nazorat_tb_pct" label={beforeLabel} total={nazoratCount} countSuffix={countSuffix} />
              <StackedBar grades={grades} dataKey="nazorat_to_pct" label={afterLabel} total={nazoratCount} countSuffix={countSuffix} />
            </div>
          </div>

          <div className="flex flex-col gap-2.5 ml-2 flex-shrink-0 self-center">
            {GRADE_COLORS.map((m) => (
              <div key={m.grade} className="flex items-center gap-2">
                <span className={`w-3 h-3 rounded-sm flex-shrink-0 ${m.bg}`} />
                <span className="text-xs text-app-muted whitespace-nowrap">{t(gradeLabelKey(m.grade))}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="overflow-x-auto">
        <h4 className="text-xs font-bold text-app-muted uppercase tracking-wider mb-3">
          {t('research_stats.table_title')}
        </h4>
        <table className="w-full text-sm min-w-[520px]">
          <thead>
            <tr className="text-left border-b border-black/10 dark:border-white/10">
              <th className="pb-2 pr-3 text-xs font-bold text-app-muted uppercase tracking-wider">
                {t('research_stats.grade_col')}
              </th>
              <th className="pb-2 pr-3 text-xs font-bold text-app-muted uppercase tracking-wider">
                {t('research_stats.tajriba_before_col')}
              </th>
              <th className="pb-2 pr-3 text-xs font-bold text-purple-600 dark:text-purple-400 uppercase tracking-wider">
                {t('research_stats.tajriba_after_col')}
              </th>
              <th className="pb-2 pr-3 text-xs font-bold text-app-muted uppercase tracking-wider">
                {t('research_stats.nazorat_before_col')}
              </th>
              <th className="pb-2 text-xs font-bold text-app-muted uppercase tracking-wider">
                {t('research_stats.nazorat_after_col')}
              </th>
            </tr>
          </thead>
          <tbody>
            {[...grades].reverse().map((row) => (
              <GradeTableRow key={row.grade} row={row} />
            ))}
          </tbody>
          <tfoot>
            <tr className="border-t border-black/10 dark:border-white/10 font-bold">
              <td className="pt-2.5 pr-3 text-sm text-app-primary">{t('research_stats.total_row')}</td>
              <td className="pt-2.5 pr-3 text-sm text-app-muted">{tajribaCount}</td>
              <td className="pt-2.5 pr-3 text-sm text-purple-600 dark:text-purple-400">{tajribaCount}</td>
              <td className="pt-2.5 pr-3 text-sm text-app-muted">{nazoratCount}</td>
              <td className="pt-2.5 text-sm text-app-muted">{nazoratCount}</td>
            </tr>
          </tfoot>
        </table>
      </div>

      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pt-4 border-t border-black/5 dark:border-white/10">
        <p className="text-xs text-app-subtle">
          χ²boshi = {stats.chi2_start.toFixed(2)}
          {' · '}
          χ²oxiri = {stats.chi2_end.toFixed(2)}
          {' · '}
          χ²krit = {chi2Critical}
          {' (α=0.05, df=3)'}
        </p>
        <p className="text-xs text-app-subtle italic">
          {t('research_stats.source_note')}
        </p>
      </div>
    </GlassCard>
  );
}

import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import {
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import type { ResearchGradeRow, ResearchStatsData } from '@/api/dashboard';
import { CHART_COLORS, useChartTheme } from './chartTheme';

function gradeLabelKey(grade: number): string {
  return `research_stats.grade_${grade}`;
}

interface ResearchChartsProps {
  data: ResearchStatsData;
  grades: ResearchGradeRow[];
}

function ResearchGradeCompareChart({ grades }: { grades: ResearchGradeRow[] }) {
  const { t } = useTranslation();
  const theme = useChartTheme();

  const chartData = useMemo(
    () =>
      [...grades]
        .sort((a, b) => b.grade - a.grade)
        .map((g) => ({
          name: t(gradeLabelKey(g.grade)),
          tajriba: g.tajriba_to_pct,
          nazorat: g.nazorat_to_pct,
        })),
    [grades, t],
  );

  return (
    <div className="min-h-[240px]">
      <ResponsiveContainer width="100%" height={240}>
        <BarChart data={chartData} margin={{ top: 8, right: 8, left: -8, bottom: 0 }} barGap={4}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke={theme.grid} />
          <XAxis dataKey="name" tick={{ fill: theme.tick, fontSize: 11 }} axisLine={false} tickLine={false} />
          <YAxis tick={{ fill: theme.axis, fontSize: 11 }} axisLine={false} tickLine={false} unit="%" />
          <Tooltip
            cursor={{ fill: theme.cursor }}
            contentStyle={{
              background: theme.tooltipBg,
              border: `1px solid ${theme.tooltipBorder}`,
              borderRadius: 12,
              fontSize: 12,
            }}
            formatter={(v) => [`${Number(v ?? 0)}%`, '']}
          />
          <Legend wrapperStyle={{ fontSize: 11, paddingTop: 8 }} />
          <Bar dataKey="tajriba" name={t('research_stats.tajriba_group')} fill={CHART_COLORS.purple} radius={[6, 6, 0, 0]} />
          <Bar dataKey="nazorat" name={t('research_stats.nazorat_group')} fill={CHART_COLORS.slate} radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}

function ResearchDistrictTrendChart({ data }: { data: ResearchStatsData }) {
  const { t } = useTranslation();
  const theme = useChartTheme();

  const chartData = useMemo(
    () =>
      data.districts.map((d) => ({
        name: d.name.replace(' tumani', '').replace(' район', ''),
        tajriba: d.stats.mean_tajriba,
        nazorat: d.stats.mean_nazorat,
      })),
    [data.districts],
  );

  return (
    <div className="min-h-[240px]">
      <ResponsiveContainer width="100%" height={240}>
        <LineChart data={chartData} margin={{ top: 8, right: 8, left: -8, bottom: 0 }}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke={theme.grid} />
          <XAxis dataKey="name" tick={{ fill: theme.tick, fontSize: 10 }} axisLine={false} tickLine={false} />
          <YAxis domain={[0, 5]} tick={{ fill: theme.axis, fontSize: 11 }} axisLine={false} tickLine={false} />
          <Tooltip
            contentStyle={{
              background: theme.tooltipBg,
              border: `1px solid ${theme.tooltipBorder}`,
              borderRadius: 12,
              fontSize: 12,
            }}
          />
          <Legend wrapperStyle={{ fontSize: 11, paddingTop: 8 }} />
          <Line type="monotone" dataKey="tajriba" name={t('research_stats.mean_tajriba')} stroke={CHART_COLORS.purple} strokeWidth={2.5} dot={{ r: 4 }} />
          <Line type="monotone" dataKey="nazorat" name={t('research_stats.mean_nazorat')} stroke={CHART_COLORS.slate} strokeWidth={2.5} dot={{ r: 4 }} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}

export function ResearchChartsRow({ data, grades }: ResearchChartsProps) {
  const { t } = useTranslation();

  return (
    <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
      <div className="rounded-2xl border border-black/5 dark:border-white/10 p-5 bg-black/[0.02] dark:bg-white/[0.02]">
        <h4 className="text-xs font-bold text-app-muted uppercase tracking-wider mb-4">
          {t('dashboard.chart_grade_compare')}
        </h4>
        <ResearchGradeCompareChart grades={grades} />
      </div>
      <div className="rounded-2xl border border-black/5 dark:border-white/10 p-5 bg-black/[0.02] dark:bg-white/[0.02]">
        <h4 className="text-xs font-bold text-app-muted uppercase tracking-wider mb-4">
          {t('dashboard.chart_district_trend')}
        </h4>
        <ResearchDistrictTrendChart data={data} />
      </div>
    </div>
  );
}

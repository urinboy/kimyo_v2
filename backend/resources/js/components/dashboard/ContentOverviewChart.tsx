import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { BarChart3 } from 'lucide-react';
import { GlassCard } from '@/components/ui/GlassCard';
import type { DashboardStats } from '@/api/dashboard';
import { CHART_COLORS, useChartTheme } from './chartTheme';

const BAR_COLORS = [CHART_COLORS.purple, CHART_COLORS.emerald, CHART_COLORS.blue, CHART_COLORS.amber, CHART_COLORS.cyan];

interface ContentOverviewChartProps {
  stats?: DashboardStats;
}

export function ContentOverviewChart({ stats }: ContentOverviewChartProps) {
  const { t } = useTranslation();
  const theme = useChartTheme();

  const data = useMemo(
    () => [
      { name: t('dashboard.stat_elements'), value: stats?.total_elements ?? 0, key: 'elements' },
      { name: t('dashboard.stat_lessons'), value: stats?.total_lessons ?? 0, key: 'lessons' },
      { name: t('dashboard.stat_users'), value: stats?.total_users ?? 0, key: 'users' },
      { name: t('dashboard.stat_formulas'), value: stats?.total_formulas ?? 0, key: 'formulas' },
      { name: t('dashboard.stat_quizzes'), value: stats?.total_quizzes ?? 0, key: 'quizzes' },
    ],
    [stats, t],
  );

  return (
    <GlassCard className="!p-6 md:!p-8 h-full flex flex-col">
      <div className="flex items-start gap-3 mb-6">
        <div className="p-2.5 rounded-xl bg-purple-500/10 border border-purple-500/20">
          <BarChart3 className="w-5 h-5 text-purple-600 dark:text-purple-400" />
        </div>
        <div>
          <h3 className="text-lg font-bold text-app-primary">{t('dashboard.chart_content_title')}</h3>
          <p className="text-sm text-app-muted mt-0.5">{t('dashboard.chart_content_subtitle')}</p>
        </div>
      </div>

      <div className="flex-1 min-h-[260px]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 8, right: 8, left: -8, bottom: 0 }} barSize={36}>
            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke={theme.grid} />
            <XAxis
              dataKey="name"
              tick={{ fill: theme.tick, fontSize: 11 }}
              axisLine={false}
              tickLine={false}
              interval={0}
              angle={-12}
              textAnchor="end"
              height={52}
            />
            <YAxis
              tick={{ fill: theme.axis, fontSize: 11 }}
              axisLine={false}
              tickLine={false}
              allowDecimals={false}
            />
            <Tooltip
              cursor={{ fill: theme.cursor }}
              contentStyle={{
                background: theme.tooltipBg,
                border: `1px solid ${theme.tooltipBorder}`,
                borderRadius: 12,
                fontSize: 12,
              }}
              formatter={(value) => [Number(value ?? 0).toLocaleString(), t('dashboard.chart_value')]}
            />
            <Bar dataKey="value" radius={[10, 10, 4, 4]}>
              {data.map((entry, index) => (
                <Cell key={entry.key} fill={BAR_COLORS[index % BAR_COLORS.length]} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </GlassCard>
  );
}

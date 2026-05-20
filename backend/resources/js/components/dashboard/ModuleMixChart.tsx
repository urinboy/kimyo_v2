import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from 'recharts';
import { PieChart as PieIcon } from 'lucide-react';
import { GlassCard } from '@/components/ui/GlassCard';
import type { DashboardStats } from '@/api/dashboard';
import { CHART_COLORS, useChartTheme } from './chartTheme';

interface ModuleMixChartProps {
  stats?: DashboardStats;
}

export function ModuleMixChart({ stats }: ModuleMixChartProps) {
  const { t } = useTranslation();
  const theme = useChartTheme();

  const slices = useMemo(() => {
    const items = [
      { name: t('dashboard.stat_elements'), value: stats?.total_elements ?? 0, color: CHART_COLORS.purple },
      { name: t('dashboard.stat_lessons'), value: stats?.total_lessons ?? 0, color: CHART_COLORS.emerald },
      { name: t('dashboard.stat_formulas'), value: stats?.total_formulas ?? 0, color: CHART_COLORS.amber },
      { name: t('dashboard.stat_quizzes'), value: stats?.total_quizzes ?? 0, color: CHART_COLORS.blue },
    ].filter((x) => x.value > 0);
    return items.length ? items : [{ name: t('dashboard.stat_users'), value: 1, color: CHART_COLORS.slate }];
  }, [stats, t]);

  const total = slices.reduce((s, x) => s + x.value, 0);

  return (
    <GlassCard className="!p-6 md:!p-8 h-full flex flex-col">
      <div className="flex items-start gap-3 mb-4">
        <div className="p-2.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20">
          <PieIcon className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
        </div>
        <div>
          <h3 className="text-lg font-bold text-app-primary">{t('dashboard.chart_mix_title')}</h3>
          <p className="text-sm text-app-muted mt-0.5">{t('dashboard.chart_mix_subtitle')}</p>
        </div>
      </div>

      <div className="relative flex-1 min-h-[200px]">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={slices}
              cx="50%"
              cy="50%"
              innerRadius={58}
              outerRadius={88}
              paddingAngle={3}
              dataKey="value"
              stroke="none"
            >
              {slices.map((entry) => (
                <Cell key={entry.name} fill={entry.color} />
              ))}
            </Pie>
            <Tooltip
              contentStyle={{
                background: theme.tooltipBg,
                border: `1px solid ${theme.tooltipBorder}`,
                borderRadius: 12,
                fontSize: 12,
              }}
              formatter={(value, _name, props) => {
                const v = Number(value ?? 0);
                const pct = total ? Math.round((v / total) * 100) : 0;
                return [`${v.toLocaleString()} (${pct}%)`, props?.payload?.name ?? ''];
              }}
            />
          </PieChart>
        </ResponsiveContainer>
        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
          <span className="text-2xl font-black text-app-primary tabular-nums">{total.toLocaleString()}</span>
          <span className="text-[10px] font-bold text-app-muted uppercase tracking-wider">{t('dashboard.chart_total')}</span>
        </div>
      </div>

      <div className="mt-4 grid grid-cols-2 gap-2">
        {slices.map((s) => (
          <div key={s.name} className="flex items-center gap-2 text-xs text-app-muted">
            <span className="w-2.5 h-2.5 rounded-full shrink-0" style={{ backgroundColor: s.color }} />
            <span className="truncate">{s.name}</span>
          </div>
        ))}
      </div>
    </GlassCard>
  );
}

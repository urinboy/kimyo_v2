import { useTranslation } from 'react-i18next';
import {
  RadialBar,
  RadialBarChart,
  ResponsiveContainer,
  Tooltip,
} from 'recharts';
import { Activity } from 'lucide-react';
import { GlassCard } from '@/components/ui/GlassCard';
import { CHART_COLORS, useChartTheme } from './chartTheme';

const METRICS = [
  { name: 'cpu', value: 12, fill: CHART_COLORS.emerald },
  { name: 'memory', value: 42, fill: CHART_COLORS.purple },
  { name: 'storage', value: 68, fill: CHART_COLORS.amber },
] as const;

export function SystemHealthChart() {
  const { t } = useTranslation();
  const theme = useChartTheme();

  const labels: Record<string, string> = {
    cpu: t('dashboard.cpu_usage'),
    memory: t('dashboard.memory'),
    storage: t('dashboard.storage'),
  };

  return (
    <GlassCard className="!p-6 md:!p-8 bg-gradient-to-br from-purple-600/10 to-emerald-600/10 dark:from-purple-600/20 dark:to-emerald-600/20 border-purple-500/20 dark:border-purple-500/30 h-full flex flex-col">
      <div className="flex items-start gap-3 mb-2">
        <div className="p-2.5 rounded-xl bg-white/40 dark:bg-white/10 border border-white/30">
          <Activity className="w-5 h-5 text-purple-600 dark:text-purple-400" />
        </div>
        <div>
          <h3 className="text-lg font-bold text-app-primary">{t('dashboard.intelligence_title')}</h3>
          <p className="text-sm text-body-secondary leading-relaxed mt-1">
            {t('dashboard.intelligence_body')}
          </p>
        </div>
      </div>

      <div className="flex-1 min-h-[220px] relative mt-2">
        <ResponsiveContainer width="100%" height="100%">
          <RadialBarChart
            cx="50%"
            cy="50%"
            innerRadius="28%"
            outerRadius="95%"
            barSize={14}
            data={METRICS.map((m) => ({ ...m, label: labels[m.name] }))}
            startAngle={90}
            endAngle={-270}
          >
            <RadialBar background={{ fill: theme.isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)' }} dataKey="value" cornerRadius={8} />
            <Tooltip
              contentStyle={{
                background: theme.tooltipBg,
                border: `1px solid ${theme.tooltipBorder}`,
                borderRadius: 12,
                fontSize: 12,
              }}
              formatter={(value, _n, p) => [`${Number(value ?? 0)}%`, p?.payload?.label ?? '']}
            />
          </RadialBarChart>
        </ResponsiveContainer>
        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none pt-6">
          <span className="text-3xl font-black text-emerald-600 dark:text-emerald-400">100%</span>
          <span className="text-[10px] font-bold text-app-muted uppercase tracking-wider">
            {t('dashboard.system_health', { percent: 100 })}
          </span>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-2 mt-2">
        {METRICS.map((m) => (
          <div key={m.name} className="text-center p-2 rounded-xl bg-black/5 dark:bg-white/5">
            <p className="text-lg font-black tabular-nums" style={{ color: m.fill }}>{m.value}%</p>
            <p className="text-[10px] text-app-muted font-semibold truncate">{labels[m.name]}</p>
          </div>
        ))}
      </div>
    </GlassCard>
  );
}

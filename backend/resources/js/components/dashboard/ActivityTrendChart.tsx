import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { Users } from 'lucide-react';
import { GlassCard } from '@/components/ui/GlassCard';
import type { ActivityData } from '@/api/dashboard';
import { CHART_COLORS, useChartTheme } from './chartTheme';

interface ActivityTrendChartProps {
  activity?: ActivityData;
  loading?: boolean;
}

export function ActivityTrendChart({ activity, loading }: ActivityTrendChartProps) {
  const { t, i18n } = useTranslation();
  const theme = useChartTheme();

  const data = useMemo(() => {
    const users = activity?.latest_users ?? [];
    const counts = new Map<string, number>();

    users.forEach((u) => {
      const d = new Date(u.created_at);
      const key = d.toISOString().slice(0, 10);
      counts.set(key, (counts.get(key) ?? 0) + 1);
    });

    const sorted = [...counts.entries()].sort(([a], [b]) => a.localeCompare(b));

    if (sorted.length === 0) {
      return [{ label: '—', count: 0 }];
    }

    return sorted.map(([iso, count]) => ({
      label: new Intl.DateTimeFormat(i18n.language, { month: 'short', day: 'numeric' }).format(new Date(iso)),
      count,
    }));
  }, [activity, i18n.language]);

  return (
    <GlassCard className="!p-6 md:!p-8">
      <div className="flex items-start gap-3 mb-6">
        <div className="p-2.5 rounded-xl bg-blue-500/10 border border-blue-500/20">
          <Users className="w-5 h-5 text-blue-600 dark:text-blue-400" />
        </div>
        <div>
          <h3 className="text-lg font-bold text-app-primary">{t('dashboard.chart_activity_title')}</h3>
          <p className="text-sm text-app-muted mt-0.5">{t('dashboard.chart_activity_subtitle')}</p>
        </div>
      </div>

      {loading ? (
        <div className="h-[220px] rounded-2xl bg-black/5 dark:bg-white/5 animate-pulse" />
      ) : (
        <div className="h-[220px]">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={data} margin={{ top: 8, right: 8, left: -12, bottom: 0 }}>
              <defs>
                <linearGradient id="activityArea" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor={CHART_COLORS.blue} stopOpacity={0.35} />
                  <stop offset="100%" stopColor={CHART_COLORS.blue} stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke={theme.grid} />
              <XAxis dataKey="label" tick={{ fill: theme.tick, fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis allowDecimals={false} tick={{ fill: theme.axis, fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip
                contentStyle={{
                  background: theme.tooltipBg,
                  border: `1px solid ${theme.tooltipBorder}`,
                  borderRadius: 12,
                  fontSize: 12,
                }}
                formatter={(value) => [Number(value ?? 0), t('dashboard.new_users')]}
              />
              <Area
                type="monotone"
                dataKey="count"
                stroke={CHART_COLORS.blue}
                strokeWidth={2.5}
                fill="url(#activityArea)"
                dot={{ r: 4, fill: CHART_COLORS.blue, strokeWidth: 0 }}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      )}
    </GlassCard>
  );
}

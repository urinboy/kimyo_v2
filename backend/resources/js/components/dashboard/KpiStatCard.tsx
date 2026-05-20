import { Area, AreaChart, ResponsiveContainer } from 'recharts';
import { TrendingUp } from 'lucide-react';
import { GlassCard } from '@/components/ui/GlassCard';
import { buildSparklinePoints, CHART_COLORS } from './chartTheme';

interface KpiStatCardProps {
  title: string;
  value: number;
  icon: React.ElementType;
  color: keyof typeof CHART_COLORS;
  growthLabel: string;
}

export function KpiStatCard({ title, value, icon: Icon, color, growthLabel }: KpiStatCardProps) {
  const stroke = CHART_COLORS[color];
  const sparkData = buildSparklinePoints(value);

  return (
    <GlassCard className="!p-6 group hover:scale-[1.01] transition-all duration-300 overflow-hidden relative">
      <div className="absolute inset-0 bg-gradient-to-br from-transparent via-transparent to-black/[0.02] dark:to-white/[0.02] pointer-events-none" />
      <div className="relative flex flex-col gap-4">
        <div className="flex items-start justify-between gap-3">
          <div
            className="p-3 rounded-2xl border border-black/5 dark:border-white/10 w-fit"
            style={{ backgroundColor: `${stroke}18` }}
          >
            <Icon className="w-6 h-6" style={{ color: stroke }} />
          </div>
          <div className="text-emerald-600 dark:text-emerald-400 font-bold text-xs flex items-center gap-1 bg-emerald-500/10 px-2.5 py-1 rounded-lg shrink-0">
            <TrendingUp className="w-3 h-3" />
            {growthLabel}
          </div>
        </div>

        <div>
          <p className="text-kpi-label">{title}</p>
          <p className="text-4xl font-black tracking-tight text-app-primary mt-1 tabular-nums">
            {value.toLocaleString()}
          </p>
        </div>

        <div className="h-14 -mx-1 mt-1">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={sparkData} margin={{ top: 4, right: 0, left: 0, bottom: 0 }}>
              <defs>
                <linearGradient id={`spark-${color}`} x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor={stroke} stopOpacity={0.35} />
                  <stop offset="100%" stopColor={stroke} stopOpacity={0} />
                </linearGradient>
              </defs>
              <Area
                type="monotone"
                dataKey="v"
                stroke={stroke}
                strokeWidth={2}
                fill={`url(#spark-${color})`}
                dot={false}
                isAnimationActive
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>
    </GlassCard>
  );
}

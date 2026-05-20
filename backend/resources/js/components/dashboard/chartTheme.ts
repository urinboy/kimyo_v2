import { useThemeStore } from '@/store/useThemeStore';

export const CHART_COLORS = {
  purple: '#A855F7',
  emerald: '#10B981',
  blue: '#3B82F6',
  amber: '#F59E0B',
  red: '#F87171',
  slate: '#64748B',
  violet: '#8B5CF6',
  cyan: '#06B6D4',
} as const;

export function useChartTheme() {
  const isDark = useThemeStore((s) => s.isDarkMode);

  return {
    isDark,
    grid: isDark ? 'rgba(148,163,184,0.14)' : 'rgba(15,23,42,0.08)',
    axis: isDark ? '#94a3b8' : '#64748b',
    tick: isDark ? '#cbd5e1' : '#475569',
    tooltipBg: isDark ? '#1e293b' : '#ffffff',
    tooltipBorder: isDark ? 'rgba(148,163,184,0.25)' : 'rgba(15,23,42,0.1)',
    cursor: isDark ? 'rgba(168,85,247,0.15)' : 'rgba(168,85,247,0.08)',
  };
}

/** KPI sparkline — joriy qiymatga o‘sish trendi */
export function buildSparklinePoints(value: number, steps = 8): { i: number; v: number }[] {
  const base = Math.max(value * 0.55, 1);
  const delta = (value - base) / (steps - 1);
  return Array.from({ length: steps }, (_, i) => ({
    i,
    v: Math.round(base + delta * i),
  }));
}

import apiClient from './client';
import type { JSendResponse } from './lessons';

export interface DashboardStats {
  total_elements: number;
  total_lessons: number;
  total_formulas: number;
  total_quizzes: number;
  total_users: number;
  active_languages: number;
}

export interface ActivityData {
  latest_elements: Array<{
    id: number;
    symbol: string;
    atomic_number: number;
    translations: Array<{ name: string }>;
  }>;
  latest_users: Array<{
    id: number;
    name: string;
    email: string;
    created_at: string;
  }>;
  latest_formulas: Array<{
    id: number;
    formula: string;
    molar_mass: number;
    translations: Array<{ name: string }>;
  }>;
}

export interface ResearchGradeRow {
  label: string;
  grade: number;
  tajriba_tb: number;
  tajriba_tb_pct: number;
  tajriba_to: number;
  tajriba_to_pct: number;
  nazorat_tb: number;
  nazorat_tb_pct: number;
  nazorat_to: number;
  nazorat_to_pct: number;
}

export interface DistrictStats {
  chi2_start: number;
  chi2_end: number;
  mean_tajriba: number;
  mean_nazorat: number;
  eta: number;
  improvement_pct: number;
  chi2_critical?: number;
}

export interface ResearchDistrict {
  id: string;
  name: string;
  tajriba_count: number;
  nazorat_count: number;
  grades: ResearchGradeRow[];
  stats: DistrictStats;
}

export interface ResearchStatsData {
  districts: ResearchDistrict[];
  totals: {
    tajriba_count: number;
    nazorat_count: number;
    grades: ResearchGradeRow[];
    stats: DistrictStats;
  };
}

export const dashboardApi = {
  getStats: async () => {
    const response = await apiClient.get<JSendResponse<{ stats: DashboardStats }>>('/dashboard/stats');
    return response.data;
  },
  getActivity: async () => {
    const response = await apiClient.get<JSendResponse<ActivityData>>('/dashboard/activity');
    return response.data;
  },
  getResearchStats: async () => {
    const response = await apiClient.get<JSendResponse<ResearchStatsData>>('/dashboard/research-stats');
    return response.data;
  },
};

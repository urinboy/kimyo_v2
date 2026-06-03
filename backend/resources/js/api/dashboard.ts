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

export interface StudentResultsData {
  filters: {
    academic_year: string;
    from: string | null;
    to: string | null;
    school_id: number | null;
    lang_id: number;
  };
  summary: {
    total_attempts: number;
    unique_students: number;
    avg_percent: number | null;
  };
  by_quiz: Array<{
    quiz_id: number;
    title: string;
    attempts_count: number;
    students_count: number;
    avg_percent: number | null;
    correct_sum: number;
    total_sum: number;
  }>;
  by_school: Array<{
    school_id: number | null;
    school_name: string | null;
    school_short_name: string | null;
    attempts_count: number;
    students_count: number;
    avg_percent: number | null;
  }>;
  by_grade: Array<{
    grade: number | null;
    attempts_count: number;
    students_count: number;
    avg_percent: number | null;
  }>;
  recent_attempts: Array<{
    id: number;
    quiz_id: number;
    quiz_title: string;
    user_name: string | null;
    user_username: string | null;
    grade: number | null;
    school_name: string | null;
    correct_count: number;
    total_count: number;
    percent: number | null;
    created_at: string | null;
  }>;
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
  getStudentResults: async (params?: { academic_year?: string; school_id?: number; lang_id?: number }) => {
    const sp = new URLSearchParams();
    if (params?.academic_year) sp.set('academic_year', params.academic_year);
    if (params?.school_id) sp.set('school_id', String(params.school_id));
    if (params?.lang_id) sp.set('lang_id', String(params.lang_id));
    const response = await apiClient.get<JSendResponse<StudentResultsData>>(`/dashboard/student-results?${sp.toString()}`);
    return response.data;
  },
};

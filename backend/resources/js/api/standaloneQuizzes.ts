import apiClient from './client';

export interface StandaloneQuiz {
  id: number;
  lesson_id: number | null;
  category: string;
  type: 'chemistry' | 'geography';
  title_uz: string | null;
  title_ru: string | null;
  title_en: string | null;
  is_active: boolean;
  sort_order: number;
  questions_count?: number;
}

export interface StandaloneQuizPayload {
  type: 'chemistry' | 'geography';
  category: string;
  title_uz: string;
  title_ru?: string | null;
  title_en?: string | null;
  sort_order?: number;
  is_active?: boolean;
}

export interface QuizAttemptsReportData {
  filters: {
    academic_year: string;
    from: string;
    to: string;
    school_id: number | null;
    lang_id: number;
  };
  summary: {
    total_attempts: number;
    unique_students: number;
  };
  questions: Array<{
    question_id: number;
    order: number;
    text: string;
    options: Array<{
      option_id: number;
      text: string;
      is_correct: boolean;
      count: number;
      percent: number;
    }>;
  }>;
  attempts: Array<{
    id: number;
    user_name: string | null;
    user_email: string | null;
    school_name: string | null;
    correct_count: number;
    total_count: number;
    created_at: string | null;
  }>;
}

export const standaloneQuizApi = {
  list: async (type?: 'chemistry' | 'geography') => {
    const q = type ? `?type=${type}` : '';
    const response = await apiClient.get<{
      status: string;
      data: { quizzes: StandaloneQuiz[] };
    }>(`/standalone-quizzes${q}`);
    return response.data;
  },

  get: async (id: number) => {
    const response = await apiClient.get<{
      status: string;
      data: { quiz: import('./quizzes').Quiz };
    }>(`/standalone-quizzes/${id}`);
    return response.data;
  },

  create: async (data: StandaloneQuizPayload) => {
    const response = await apiClient.post<{ status: string; data: { quiz: StandaloneQuiz } }>('/standalone-quizzes', data);
    return response.data;
  },

  update: async (id: number, data: Partial<StandaloneQuizPayload> & { is_active?: boolean }) => {
    const response = await apiClient.put<{ status: string; data: { quiz: StandaloneQuiz } }>(
      `/standalone-quizzes/${id}`,
      data,
    );
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<{ status: string; data: null }>(`/standalone-quizzes/${id}`);
    return response.data;
  },

  getAttemptsReport: async (id: number, params: { academic_year: string; school_id?: number }) => {
    const sp = new URLSearchParams();
    sp.set('academic_year', params.academic_year);
    if (params.school_id != null && params.school_id > 0) {
      sp.set('school_id', String(params.school_id));
    }
    const response = await apiClient.get<{ status: string; data: QuizAttemptsReportData }>(
      `/standalone-quizzes/${id}/attempts-report?${sp.toString()}`,
    );
    return response.data;
  },
};

import apiClient from './client';

export type InterestingTaskKind = 'interesting' | 'project';

export interface InterestingTask {
  id: number;
  title: string;
  description: string | null;
  is_active: boolean;
  sort_order: number;
  task_kind?: InterestingTaskKind;
  questions_count?: number;
  submissions_count?: number;
  questions?: TaskQuestion[];
  created_at: string;
}

export type TaskQuestionType = 'text' | 'image' | 'match' | 'word_search' | 'matrix_classification';

export interface TaskMatchData {
  left: string[];
  right: string[];
}

export interface TaskWordSearchClue {
  id: number;
  formula: string;
  common_name: string;
  answer: string;
}

export interface TaskWordSearchData {
  grid: string[][];
  clues: TaskWordSearchClue[];
}

export interface TaskMatrixRow {
  id: number;
  text: string;
}

export interface TaskMatrixData {
  rows: TaskMatrixRow[];
  method_columns?: Array<{ key: 'solve' | 'ammonia'; label: string }>;
  sequence?: {
    enabled: boolean;
    label?: string;
    max_step?: number;
  };
  answer_key?: {
    method?: Record<string, 'solve' | 'ammonia' | 'none'>;
    order?: Record<string, number>;
  };
}

export interface TaskQuestion {
  id: number;
  task_id: number;
  body: string;
  sort_order: number;
  question_type: TaskQuestionType;
  image_path?: string | null;
  image_url?: string | null;
  match_data?: TaskMatchData | TaskWordSearchData | TaskMatrixData | null;
}

export type TaskQuestionCreatePayload =
  | FormData
  | {
      body: string;
      question_type: TaskQuestionType;
      sort_order?: number;
      match_left?: string[];
      match_right?: string[];
    }
  | {
      body: string;
      question_type: 'word_search';
      sort_order?: number;
      word_search_grid: string[][];
      word_search_clues: Omit<TaskWordSearchClue, 'id'>[];
    }
  | {
      body: string;
      question_type: 'matrix_classification';
      sort_order?: number;
      matrix_data: TaskMatrixData;
    };

export interface TaskAnswer {
  id: number;
  question_id: number;
  answer_text: string;
  is_correct: boolean | null;
  score: number;
  teacher_comment: string | null;
  auto_check?: {
    supported: boolean;
    is_correct: boolean | null;
    score: number | null;
    reason: string;
  };
  question?: TaskQuestion;
}

export interface TaskSubmission {
  id: number;
  task_id: number;
  user_id: number | null;
  student_name: string;
  student_email: string | null;
  status: 'pending' | 'checked';
  result_visible: boolean;
  teacher_comment: string | null;
  total_score: number;
  checked_at: string | null;
  created_at: string;
  task?: { id: number; title: string };
  user?: { id: number; name: string; email: string };
  answers?: TaskAnswer[];
}

export const interestingTaskApi = {
  // Tasks
  getAll: async (params?: { kind?: InterestingTaskKind }) => {
    const res = await apiClient.get('/interesting-tasks', { params });
    return res.data;
  },
  getOne: async (id: number) => {
    const res = await apiClient.get(`/interesting-tasks/${id}`);
    return res.data;
  },
  create: async (data: Partial<InterestingTask>) => {
    const res = await apiClient.post('/interesting-tasks', data);
    return res.data;
  },
  update: async (id: number, data: Partial<InterestingTask>) => {
    const res = await apiClient.put(`/interesting-tasks/${id}`, data);
    return res.data;
  },
  remove: async (id: number) => {
    const res = await apiClient.delete(`/interesting-tasks/${id}`);
    return res.data;
  },

  // Questions (JSON yoki FormData — rasm uchun)
  addQuestion: async (taskId: number, data: TaskQuestionCreatePayload) => {
    const res = await apiClient.post(`/interesting-tasks/${taskId}/questions`, data);
    return res.data;
  },
  updateQuestion: async (taskId: number, qId: number, data: TaskQuestionCreatePayload) => {
    const url = `/interesting-tasks/${taskId}/questions/${qId}`;
    if (data instanceof FormData) {
      const res = await apiClient.post(url, data);
      return res.data;
    }
    const res = await apiClient.put(url, data);
    return res.data;
  },
  removeQuestion: async (taskId: number, qId: number) => {
    const res = await apiClient.delete(`/interesting-tasks/${taskId}/questions/${qId}`);
    return res.data;
  },

  // Submissions
  getSubmissions: async (params?: { task_id?: number; status?: string; school_id?: number; academic_year?: string }) => {
    const res = await apiClient.get('/task-submissions', { params });
    return res.data;
  },
  getSubmission: async (id: number) => {
    const res = await apiClient.get(`/task-submissions/${id}`);
    return res.data;
  },
  checkSubmission: async (id: number, data: {
    teacher_comment?: string;
    result_visible?: boolean;
    use_auto_grading?: boolean;
    answers?: { id: number; is_correct?: boolean | null; score?: number; teacher_comment?: string | null }[];
  }) => {
    const res = await apiClient.put(`/task-submissions/${id}/check`, data);
    return res.data;
  },
  /** Tekshirilgan topshiriq uchun ko‘rinuvchanlik (toggle yoki aniq qiymat) */
  updateSubmissionVisibility: async (id: number, result_visible: boolean) => {
    const res = await apiClient.patch(`/task-submissions/${id}/visibility`, { result_visible });
    return res.data;
  },
  bulkUpdateSubmissionVisibility: async (submission_ids: number[], result_visible: boolean) => {
    const res = await apiClient.patch('/task-submissions/visibility-bulk', { submission_ids, result_visible });
    return res.data;
  },
  /** Bitta topshiriqni o'chirish */
  deleteSubmission: async (id: number) => {
    const res = await apiClient.delete(`/task-submissions/${id}`);
    return res.data;
  },
  /** Bitta topshiriqni pending'ga qaytarish */
  resetSubmission: async (id: number) => {
    const res = await apiClient.patch(`/task-submissions/${id}/reset`);
    return res.data;
  },
  /** Tanlanganlarni o'chirish */
  bulkDeleteSubmissions: async (submission_ids: number[]) => {
    const res = await apiClient.delete('/task-submissions/bulk', { data: { submission_ids } });
    return res.data;
  },
  /** Tanlanganlarni qayta pending'ga qaytarish */
  bulkResetSubmissions: async (submission_ids: number[]) => {
    const res = await apiClient.patch('/task-submissions/reset-bulk', { submission_ids });
    return res.data;
  },
};

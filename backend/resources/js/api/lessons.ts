import apiClient from './client';

export interface LessonTranslation {
  language_id: number;
  title: string;
  content: string | null;
}

export interface Lesson {
  id: number;
  type: 'theory' | 'lab';
  order: number;
  is_active: boolean;
  translations: LessonTranslation[];
}

export type LessonLabItemCategory = 'equipment' | 'reagent' | 'element' | 'vessel';

export interface LessonLabItem {
  id: number;
  lesson_id: number;
  category: LessonLabItemCategory;
  name: string;
  formula: string | null;
  quantity: string | null;
  unit: string | null;
  notes: string | null;
  sort_order: number;
  is_required: boolean;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export type LessonUpdatePayload = {
  type?: 'theory' | 'lab';
  order?: number;
  is_active?: boolean;
  translations?: Array<{ language_id: number; title: string; content?: string | null }>;
};

export type LessonLabItemPayload = {
  category: LessonLabItemCategory;
  name: string;
  formula?: string | null;
  quantity?: string | null;
  unit?: string | null;
  notes?: string | null;
  sort_order?: number;
  is_required?: boolean;
  is_active?: boolean;
};

export const lessonApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ lessons: Lesson[] }>>('/lessons');
    return response.data;
  },

  create: async (data: Partial<Lesson> & { translations: Record<number, Partial<LessonTranslation>> }) => {
    const response = await apiClient.post<JSendResponse<{ lesson: Lesson }>>('/lessons', data);
    return response.data;
  },

  update: async (id: number, data: LessonUpdatePayload) => {
    const response = await apiClient.put<JSendResponse<{ lesson: Lesson }>>(`/lessons/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/lessons/${id}`);
    return response.data;
  },

  getLabItems: async (lessonId: number) => {
    const response = await apiClient.get<JSendResponse<{ items: LessonLabItem[] }>>(
      `/lessons/${lessonId}/lab-items`,
    );
    return response.data;
  },

  createLabItem: async (lessonId: number, data: LessonLabItemPayload) => {
    const response = await apiClient.post<JSendResponse<{ item: LessonLabItem }>>(
      `/lessons/${lessonId}/lab-items`,
      data,
    );
    return response.data;
  },

  updateLabItem: async (id: number, data: LessonLabItemPayload) => {
    const response = await apiClient.put<JSendResponse<{ item: LessonLabItem }>>(
      `/lesson-lab-items/${id}`,
      data,
    );
    return response.data;
  },

  deleteLabItem: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/lesson-lab-items/${id}`);
    return response.data;
  },
};

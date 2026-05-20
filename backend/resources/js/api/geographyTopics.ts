import apiClient from './client';

export interface GeographyTopicTranslation {
  language_id: number;
  title: string;
  content: string | null;
  language?: {
    id: number;
    name: string;
    code: string;
  };
}

export interface GeographyTopic {
  id: number;
  category: string;
  parent_id: number | null;
  icon: string | null;
  sort_order: number;
  is_active: boolean;
  translations: GeographyTopicTranslation[];
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const geographyTopicApi = {
  getAll: async (category?: string) => {
    const url = category ? `/geography-topics?category=${category}` : '/geography-topics';
    const response = await apiClient.get<JSendResponse<{ topics: GeographyTopic[] }>>(url);
    return response.data;
  },

  create: async (data: any) => {
    const response = await apiClient.post<JSendResponse<{ topic: GeographyTopic }>>('/geography-topics', data);
    return response.data;
  },

  update: async (id: number, data: any) => {
    const response = await apiClient.put<JSendResponse<{ topic: GeographyTopic }>>(`/geography-topics/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/geography-topics/${id}`);
    return response.data;
  },
};

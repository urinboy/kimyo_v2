import apiClient from './client';

export interface Language {
  id: number;
  code: string;
  name: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const languageApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ languages: Language[] }>>('/languages');
    return response.data;
  },

  create: async (data: Partial<Language>) => {
    const response = await apiClient.post<JSendResponse<{ language: Language }>>('/languages', data);
    return response.data;
  },

  update: async (id: number, data: Partial<Language>) => {
    const response = await apiClient.put<JSendResponse<{ language: Language }>>(`/languages/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/languages/${id}`);
    return response.data;
  },
};

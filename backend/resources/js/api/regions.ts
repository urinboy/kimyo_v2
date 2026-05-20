import apiClient from './client';

export interface RegionTranslation {
  language_id: number;
  name: string;
  description: string | null;
}

export interface Region {
  id: number;
  is_active: boolean;
  translations: RegionTranslation[];
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const regionApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ regions: Region[] }>>('/regions');
    return response.data;
  },

  create: async (data: { is_active: boolean; translations: Record<number, { name: string; description: string }> }) => {
    const response = await apiClient.post<JSendResponse<{ region: Region }>>('/regions', data);
    return response.data;
  },

  update: async (id: number, data: { is_active: boolean; translations: Record<number, { name: string; description: string }> }) => {
    const response = await apiClient.put<JSendResponse<{ region: Region }>>(`/regions/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/regions/${id}`);
    return response.data;
  },
};

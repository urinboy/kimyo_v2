import apiClient from './client';

export interface MineTranslation {
  language_id: number;
  name: string;
  description: string | null;
}

export interface Mine {
  id: number;
  latitude: number;
  longitude: number;
  is_active: boolean;
  images: string[];
  translations: MineTranslation[];
  elements: { id: number; symbol: string }[];
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const mineApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ mines: Mine[] }>>('/mines');
    return response.data;
  },

  create: async (data: Partial<Mine> & { translations: Record<number, Partial<MineTranslation>> }) => {
    const response = await apiClient.post<JSendResponse<{ mine: Mine }>>('/mines', data);
    return response.data;
  },

  update: async (id: number, data: Partial<Mine> & { translations: Record<number, Partial<MineTranslation>> }) => {
    const response = await apiClient.put<JSendResponse<{ mine: Mine }>>(`/mines/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/mines/${id}`);
    return response.data;
  },
};

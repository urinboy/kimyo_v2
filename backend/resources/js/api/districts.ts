import apiClient from './client';

export interface DistrictTranslation {
  language_id: number;
  name: string;
  description: string | null;
}

export interface District {
  id: number;
  region_id: number;
  is_active: boolean;
  translations: DistrictTranslation[];
  region?: { id: number; translations: { language_id: number; name: string }[] };
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const districtApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ districts: District[] }>>('/districts');
    return response.data;
  },

  create: async (data: { region_id: number; is_active: boolean; translations: Record<number, { name: string; description: string }> }) => {
    const response = await apiClient.post<JSendResponse<{ district: District }>>('/districts', data);
    return response.data;
  },

  update: async (id: number, data: { region_id: number; is_active: boolean; translations: Record<number, { name: string; description: string }> }) => {
    const response = await apiClient.put<JSendResponse<{ district: District }>>(`/districts/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/districts/${id}`);
    return response.data;
  },
};

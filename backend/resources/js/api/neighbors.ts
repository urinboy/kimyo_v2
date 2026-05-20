import apiClient from './client';

export interface NeighborCountry {
  id: number;
  code: string;
  name_uz: string;
  name_ru?: string;
  name_en?: string;
  capital_uz?: string;
  capital_ru?: string;
  capital_en?: string;
  description_uz?: string;
  description_ru?: string;
  description_en?: string;
  area_km2?: number;
  population_mn?: number;
  languages_uz?: string;
  languages_ru?: string;
  languages_en?: string;
  currency_uz?: string;
  currency_ru?: string;
  currency_en?: string;
  border_with_uz_km?: number;
  flag_emoji?: string;
  sort_order: number;
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const neighborApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ countries: NeighborCountry[] }>>('/neighbor-countries');
    return response.data;
  },

  create: async (data: Partial<NeighborCountry>) => {
    const response = await apiClient.post<JSendResponse<{ country: NeighborCountry }>>('/neighbor-countries', data);
    return response.data;
  },

  update: async (id: number, data: Partial<NeighborCountry>) => {
    const response = await apiClient.put<JSendResponse<{ country: NeighborCountry }>>(`/neighbor-countries/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/neighbor-countries/${id}`);
    return response.data;
  },
};

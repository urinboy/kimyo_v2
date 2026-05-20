import apiClient from './client';
import { type Language } from './languages';

export interface ElementTranslation {
  language_id: number;
  name: string;
  description: string | null;
  language?: Language;
}

export interface Element {
  id: number;
  atomic_number: number;
  symbol: string;
  mass: number;
  color_hex: string | null;
  type: string;
  translations: ElementTranslation[];
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const elementApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ elements: Element[] }>>('/elements');
    return response.data;
  },

  create: async (data: Partial<Element> & { translations: Partial<ElementTranslation>[] }) => {
    const response = await apiClient.post<JSendResponse<{ element: Element }>>('/elements', data);
    return response.data;
  },

  update: async (id: number, data: Partial<Element> & { translations: Partial<ElementTranslation>[] }) => {
    const response = await apiClient.put<JSendResponse<{ element: Element }>>(`/elements/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/elements/${id}`);
    return response.data;
  },
};

import apiClient from './client';
import type { JSendResponse } from './lessons';

export interface ThreeDModelTranslation {
  language_id?: number;
  language_code?: string;
  name: string;
  description?: string | null;
}

export interface ThreeDModelElement {
  id: number;
  symbol: string;
  atomic_number: number;
}

export interface ThreeDModel {
  id: number;
  slug: string;
  model_path: string | null;
  model_url: string | null;
  element_id: number | null;
  element: ThreeDModelElement | null;
  sort_order: number;
  is_active: boolean;
  created_at?: string;
  translations: ThreeDModelTranslation[];
}

export interface ThreeDModelPayload {
  slug: string;
  model_file?: File | null;
  remove_model_file?: boolean;
  element_id?: number | null;
  sort_order: number;
  is_active: boolean;
  translations: ThreeDModelTranslation[];
}

function buildFormData(payload: ThreeDModelPayload): FormData | ThreeDModelPayload {
  if (!payload.model_file && !payload.remove_model_file) {
    return payload;
  }
  const fd = new FormData();
  fd.append('slug', payload.slug);
  if (payload.model_file) fd.append('model_file', payload.model_file);
  if (payload.remove_model_file) fd.append('remove_model_file', '1');
  if (payload.element_id != null) fd.append('element_id', String(payload.element_id));
  fd.append('sort_order', String(payload.sort_order));
  fd.append('is_active', payload.is_active ? '1' : '0');
  payload.translations.forEach((t, i) => {
    if (t.language_code) fd.append(`translations[${i}][language_code]`, t.language_code);
    fd.append(`translations[${i}][name]`, t.name);
    if (t.description) fd.append(`translations[${i}][description]`, t.description);
  });
  return fd;
}

export const threeDModelsApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ three_d_models: ThreeDModel[] }>>('/3d-models');
    return response.data;
  },

  getOne: async (id: number) => {
    const response = await apiClient.get<JSendResponse<{ three_d_model: ThreeDModel }>>(`/3d-models/${id}`);
    return response.data;
  },

  create: async (payload: ThreeDModelPayload) => {
    const body = buildFormData(payload);
    const response = await apiClient.post<JSendResponse<{ three_d_model: ThreeDModel }>>('/3d-models', body, {
      headers: body instanceof FormData ? { 'Content-Type': 'multipart/form-data' } : undefined,
    });
    return response.data;
  },

  update: async (id: number, payload: ThreeDModelPayload) => {
    const body = buildFormData(payload);
    const method = body instanceof FormData ? 'post' : 'put';
    const response = await apiClient.request<JSendResponse<{ three_d_model: ThreeDModel }>>({
      method,
      url: `/3d-models/${id}`,
      data: body,
      headers: body instanceof FormData ? { 'Content-Type': 'multipart/form-data' } : undefined,
    });
    return response.data;
  },

  remove: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/3d-models/${id}`);
    return response.data;
  },
};

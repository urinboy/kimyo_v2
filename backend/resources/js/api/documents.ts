import apiClient from './client';
import type { JSendResponse } from './lessons';

export type DocumentCategory = 'decisions' | 'laws';

export interface AppDocument {
  id: number;
  category: DocumentCategory;
  title_uz: string;
  title_ru: string | null;
  title_en: string | null;
  file_path: string;
  original_filename: string;
  mime_type: string;
  file_size: number;
  sort_order: number;
  is_active: boolean;
  file_url: string;
  created_at: string;
  updated_at: string;
}

function appendDocumentFields(
  fd: FormData,
  data: {
    category: DocumentCategory;
    title_uz: string;
    title_ru: string;
    title_en: string;
    sort_order: number;
    is_active: boolean;
    file?: File | null;
  },
) {
  fd.append('category', data.category);
  fd.append('title_uz', data.title_uz);
  fd.append('title_ru', data.title_ru);
  fd.append('title_en', data.title_en);
  fd.append('sort_order', String(data.sort_order));
  fd.append('is_active', data.is_active ? '1' : '0');
  if (data.file) {
    fd.append('file', data.file);
  }
}

export const documentApi = {
  getAll: async (category?: string) => {
    const response = await apiClient.get<JSendResponse<{ documents: AppDocument[] }>>('/documents', {
      params: category ? { category } : undefined,
    });
    return response.data;
  },

  getOne: async (id: number) => {
    const response = await apiClient.get<JSendResponse<{ document: AppDocument }>>(`/documents/${id}`);
    return response.data;
  },

  create: async (data: {
    category: DocumentCategory;
    title_uz: string;
    title_ru: string;
    title_en: string;
    file: File;
    sort_order: number;
    is_active: boolean;
  }) => {
    const fd = new FormData();
    appendDocumentFields(fd, { ...data, file: data.file });
    const response = await apiClient.post<JSendResponse<{ document: AppDocument }>>('/documents', fd);
    return response.data;
  },

  /**
   * Multipart: POST (PUT ba'zida fayl kelmasligi) — `documents/{id}`.
   * `file` bo'lmasa, serverdagi fayl o'zgarishsiz.
   */
  update: async (
    id: number,
    data: {
      category: DocumentCategory;
      title_uz: string;
      title_ru: string;
      title_en: string;
      sort_order: number;
      is_active: boolean;
      file: File | null;
    },
  ) => {
    const fd = new FormData();
    appendDocumentFields(fd, data);
    const response = await apiClient.post<JSendResponse<{ document: AppDocument }>>(`/documents/${id}`, fd);
    return response.data;
  },

  /** Faqat holatni almashtirish — POST ishlatiladi (PUT + FormData ko‘pincha tana yetmay qoladi). */
  patchIsActive: async (id: number, is_active: boolean) => {
    const fd = new FormData();
    fd.append('is_active', is_active ? '1' : '0');
    const response = await apiClient.post<JSendResponse<{ document: AppDocument }>>(`/documents/${id}`, fd);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/documents/${id}`);
    return response.data;
  },
};

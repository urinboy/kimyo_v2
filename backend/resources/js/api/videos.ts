import apiClient from './client';
import type { JSendResponse } from './lessons';

export interface VideoTranslation {
  id?: number;
  language_id?: number;
  language_code?: string;
  title: string;
  description?: string | null;
}

export interface Video {
  id: number;
  youtube_video_id: string | null;
  youtube_url: string | null;
  video_path: string | null;
  video_url: string | null;
  channel_name: string | null;
  thumbnail_url: string | null;
  sort_order: number;
  is_active: boolean;
  created_at?: string;
  translations: VideoTranslation[];
}

export interface VideoPayload {
  youtube_url?: string | null;
  video_file?: File | null;
  remove_video_file?: boolean;
  channel_name: string;
  sort_order: number;
  is_active: boolean;
  translations: VideoTranslation[];
}

function buildFormData(payload: VideoPayload): FormData | VideoPayload {
  // Faqat fayl yuklanganda FormData ishlatamiz
  if (!payload.video_file && !payload.remove_video_file) {
    return payload;
  }
  const fd = new FormData();
  if (payload.youtube_url != null) fd.append('youtube_url', payload.youtube_url);
  if (payload.video_file) fd.append('video_file', payload.video_file);
  if (payload.remove_video_file) fd.append('remove_video_file', '1');
  fd.append('channel_name', payload.channel_name);
  fd.append('sort_order', String(payload.sort_order));
  fd.append('is_active', payload.is_active ? '1' : '0');
  payload.translations.forEach((t, i) => {
    if (t.language_code) fd.append(`translations[${i}][language_code]`, t.language_code);
    fd.append(`translations[${i}][title]`, t.title);
    if (t.description) fd.append(`translations[${i}][description]`, t.description);
  });
  return fd;
}

export const videosApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ videos: Video[] }>>('/videos');
    return response.data;
  },

  getOne: async (id: number) => {
    const response = await apiClient.get<JSendResponse<{ video: Video }>>(`/videos/${id}`);
    return response.data;
  },

  create: async (payload: VideoPayload) => {
    const body = buildFormData(payload);
    const response = await apiClient.post<JSendResponse<{ video: Video }>>('/videos', body, {
      headers: body instanceof FormData ? { 'Content-Type': 'multipart/form-data' } : undefined,
    });
    return response.data;
  },

  update: async (id: number, payload: VideoPayload) => {
    const body = buildFormData(payload);
    // Multipart bo'lsa POST bilan yuboramiz (Laravel PUT + file muammosi)
    const url = body instanceof FormData ? `/videos/${id}` : `/videos/${id}`;
    const method = body instanceof FormData ? 'post' : 'put';
    const response = await apiClient.request<JSendResponse<{ video: Video }>>({
      method,
      url,
      data: body,
      headers: body instanceof FormData ? { 'Content-Type': 'multipart/form-data' } : undefined,
    });
    return response.data;
  },

  remove: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/videos/${id}`);
    return response.data;
  },
};

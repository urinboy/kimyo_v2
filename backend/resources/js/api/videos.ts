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
  youtube_video_id: string;
  youtube_url: string;
  channel_name: string | null;
  thumbnail_url: string;
  sort_order: number;
  is_active: boolean;
  created_at?: string;
  translations: VideoTranslation[];
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

  create: async (payload: {
    youtube_url: string;
    channel_name: string;
    sort_order: number;
    is_active: boolean;
    translations: VideoTranslation[];
  }) => {
    const response = await apiClient.post<JSendResponse<{ video: Video }>>('/videos', payload);
    return response.data;
  },

  update: async (
    id: number,
    payload: {
      youtube_url?: string;
      channel_name: string;
      sort_order: number;
      is_active: boolean;
      translations: VideoTranslation[];
    },
  ) => {
    const response = await apiClient.put<JSendResponse<{ video: Video }>>(`/videos/${id}`, payload);
    return response.data;
  },

  remove: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/videos/${id}`);
    return response.data;
  },
};

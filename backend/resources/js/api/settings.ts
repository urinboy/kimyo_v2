import apiClient from './client';

export interface AppSetting {
  id: number;
  app_version: string;
  app_version_code: number;
  author_name: string;
  author_role: string;
  author_image: string;
  author_birth_date: string;
  author_birth_place: string;
  author_nationality: string;
  author_education: string;
  author_specialization: string;
  author_languages: string;
  author_work_position: string;
  author_work_organization: string;
  about_app_uz: string;
  about_app_ru: string;
  about_app_en: string;
  privacy_policy_url: string;
  terms_url: string;
}

export interface Review {
  id: number;
  user_id: number | null;
  rating: number;
  comment: string | null;
  device_info: string | null;
  created_at: string;
  user?: {
    id: number;
    name: string;
    email: string;
  };
}

export interface ReviewsListData {
  reviews: Review[];
  summary?: {
    average_rating: number;
    total_reviews: number;
  };
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export interface AuthorExperience {
  id: number;
  years: string;
  description_uz: string;
  description_ru: string;
  description_en: string;
  description_kaa?: string | null;
  order: number;
}

export interface AuthorAdditionalInfo {
  id: number;
  key_uz: string;
  key_ru: string;
  key_en: string;
  value_uz: string;
  value_ru: string;
  value_en: string;
  order: number;
}

export const appSettingApi = {
  get: async () => {
    const response = await apiClient.get<JSendResponse<{ settings: AppSetting }>>('/settings');
    return response.data;
  },
  update: async (data: Record<string, unknown> & { author_image?: File | string | null }) => {
    const formData = new FormData();
    const fillable: (keyof AppSetting)[] = [
      'app_version', 'app_version_code', 'author_name', 'author_role', 'author_birth_date', 'author_birth_place', 'author_nationality', 'author_education', 'author_specialization', 'author_languages', 'author_work_position', 'author_work_organization', 'about_app_uz', 'about_app_ru', 'about_app_en', 'privacy_policy_url', 'terms_url',
    ];
    const img = data['author_image'];
    if (img instanceof File) {
      formData.append('author_image', img);
    } else if (typeof img === 'string' && img.length > 0) {
      formData.append('author_image', img);
    }
    for (const key of fillable) {
      const v = data[key as string];
      if (v === undefined || v === null) continue;
      formData.append(String(key), String(v));
    }
    const response = await apiClient.post<JSendResponse<{ settings: AppSetting }>>('/settings', formData);
    return response.data;
  },
};

export const authorApi = {
  getExperience: async () => {
    const response = await apiClient.get<JSendResponse<{ experiences: AuthorExperience[] }>>('/author/experience');
    return response.data;
  },
  saveExperience: async (data: Partial<AuthorExperience>) => {
    if (data.id) {
      const response = await apiClient.put<JSendResponse<{ experience: AuthorExperience }>>(`/author/experience/${data.id}`, data);
      return response.data;
    }
    const response = await apiClient.post<JSendResponse<{ experience: AuthorExperience }>>('/author/experience', data);
    return response.data;
  },
  deleteExperience: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/author/experience/${id}`);
    return response.data;
  },
  getAdditionalInfo: async () => {
    const response = await apiClient.get<JSendResponse<{ additional_infos: AuthorAdditionalInfo[] }>>('/author/additional-info');
    return response.data;
  },
  saveAdditionalInfo: async (data: Partial<AuthorAdditionalInfo>) => {
    if (data.id) {
      const response = await apiClient.put<JSendResponse<{ additional_info: AuthorAdditionalInfo }>>(`/author/additional-info/${data.id}`, data);
      return response.data;
    }
    const response = await apiClient.post<JSendResponse<{ additional_info: AuthorAdditionalInfo }>>('/author/additional-info', data);
    return response.data;
  },
  deleteAdditionalInfo: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/author/additional-info/${id}`);
    return response.data;
  },
};

export const reviewApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<ReviewsListData>>('/reviews');
    return response.data;
  },
  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/reviews/${id}`);
    return response.data;
  },
};

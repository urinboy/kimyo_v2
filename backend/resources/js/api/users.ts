import apiClient from './client';

export interface User {
  id: number;
  name: string;
  username: string | null;
  email: string | null;
  roles: { id: number; name: string }[];
  school_id?: number | null;
  school?: {
    id: number;
    name: string;
    short_name?: string | null;
    region?: string | null;
    city?: string | null;
    address?: string | null;
  } | null;
  phone?: string | null;
  grade?: string | null;
  school_name?: string | null;
  created_at: string;
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const userApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ users: User[] }>>('/users');
    return response.data;
  },

  create: async (data: Partial<User> & { password?: string; role?: string; school_id?: number | null }) => {
    const response = await apiClient.post<JSendResponse<{ user: User }>>('/users', data);
    return response.data;
  },

  update: async (id: number, data: Partial<User> & { password?: string; role?: string; school_id?: number | null }) => {
    const response = await apiClient.put<JSendResponse<{ user: User }>>(`/users/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/users/${id}`);
    return response.data;
  },
};

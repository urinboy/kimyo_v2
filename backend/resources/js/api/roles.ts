import apiClient from './client';

export interface Permission {
  id: number;
  name: string;
}

export interface Role {
  id: number;
  name: string;
  permissions: Permission[];
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const roleApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ roles: Role[]; permissions: Permission[] }>>('/roles');
    return response.data;
  },

  create: async (data: { name: string; permissions: string[] }) => {
    const response = await apiClient.post<JSendResponse<{ role: Role }>>('/roles', data);
    return response.data;
  },

  update: async (id: number, data: { name: string; permissions: string[] }) => {
    const response = await apiClient.put<JSendResponse<{ role: Role }>>(`/roles/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/roles/${id}`);
    return response.data;
  },
};

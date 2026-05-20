import apiClient from './client';

export interface PermissionRow {
  id: number;
  name: string;
  roles_count?: number;
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const permissionsApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ permissions: PermissionRow[] }>>('/permissions');
    return response.data;
  },

  create: async (data: { name: string }) => {
    const response = await apiClient.post<JSendResponse<{ permission: PermissionRow }>>('/permissions', data);
    return response.data;
  },

  update: async (id: number, data: { name: string }) => {
    const response = await apiClient.put<JSendResponse<{ permission: PermissionRow }>>(`/permissions/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/permissions/${id}`);
    return response.data;
  },
};

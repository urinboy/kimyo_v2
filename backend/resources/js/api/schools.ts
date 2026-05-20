import apiClient from './client';

export interface School {
  id: number;
  name: string;
  short_name: string | null;
  region: string | null;
  city: string | null;
  address: string | null;
  is_active: boolean;
  users_count?: number;
  created_at: string;
  updated_at: string;
}

export interface Student {
  id: number;
  name: string;
  phone: string | null;
  grade: string | null;
  created_at: string;
  total_submissions: number;
  avg_score: number;
}

export interface SchoolStats {
  total_students: number;
  active_students: number;
  avg_score: number;
  top_score: number;
}

export interface SchoolDetail {
  school: School;
  students: Student[];
  stats: SchoolStats;
}

export interface AssignableUser {
  id: number;
  name: string;
  phone: string | null;
  email: string | null;
  username: string | null;
  grade: string | null;
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}


export const schoolsApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ schools: School[] }>>('/schools');
    return response.data;
  },

  getDetail: async (id: number) => {
    const response = await apiClient.get<JSendResponse<SchoolDetail>>(`/schools/${id}/students`);
    return response.data;
  },

  getAssignableUsers: async (schoolId: number) => {
    const response = await apiClient.get<JSendResponse<{ users: AssignableUser[] }>>(
      `/schools/${schoolId}/assignable-users`,
    );
    return response.data;
  },

  attachStudents: async (schoolId: number, userIds: number[]) => {
    const response = await apiClient.post<JSendResponse<{ attached: number }>>(
      `/schools/${schoolId}/students/attach`,
      { user_ids: userIds },
    );
    return response.data;
  },

  detachStudents: async (schoolId: number, userIds: number[]) => {
    const response = await apiClient.post<JSendResponse<{ detached: number }>>(
      `/schools/${schoolId}/students/detach`,
      { user_ids: userIds },
    );
    return response.data;
  },

  create: async (data: Partial<School>) => {
    const response = await apiClient.post<JSendResponse<{ school: School }>>('/schools', data);
    return response.data;
  },

  update: async (id: number, data: Partial<School>) => {
    const response = await apiClient.put<JSendResponse<{ school: School }>>(`/schools/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/schools/${id}`);
    return response.data;
  },
};

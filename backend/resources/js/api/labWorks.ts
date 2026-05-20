import apiClient from './client';
import type { JSendResponse } from './lessons';

// ─── Types ────────────────────────────────────────────────────────────────────

export interface LabWorkTranslation {
  id?: number;
  language_id?: number;
  language_code?: string;
  title: string;
  description?: string | null;
}

export interface LabReaction {
  id?: number;
  formula: string;
  type: 'molecular' | 'full_ionic' | 'short_ionic';
  order_index: number;
}

export interface LabObservationTranslation {
  id?: number;
  language_id?: number;
  language_code?: string;
  text: string;
}

export interface LabObservation {
  id?: number;
  order_index: number;
  translations: LabObservationTranslation[];
}

export interface LabProductTranslation {
  id?: number;
  language_id?: number;
  language_code?: string;
  name: string;
}

export interface LabProduct {
  id?: number;
  chemical_formula: string;
  state: 'dissolved' | 'precipitate' | 'gas' | 'solid' | 'unknown';
  order_index: number;
  translations: LabProductTranslation[];
}

export interface LabExperimentTranslation {
  id?: number;
  language_id?: number;
  language_code?: string;
  title: string;
  scientific_explanation?: string | null;
}

export interface LabExperiment {
  id?: number;
  type: 'probirka' | 'tajriba' | 'bosqich';
  order_index: number;
  status: 'active' | 'inactive';
  translations: LabExperimentTranslation[];
  reactions: LabReaction[];
  observations: LabObservation[];
  products: LabProduct[];
}

export interface LabWork {
  id: number;
  number: number;
  status: 'active' | 'inactive';
  experiments_count?: number;
  translations: LabWorkTranslation[];
  experiments?: LabExperiment[];
}

// ─── API ──────────────────────────────────────────────────────────────────────

export const labWorksApi = {
  getAll: async () => {
    const res = await apiClient.get<JSendResponse<{ lab_works: LabWork[] }>>('/lab-works');
    return res.data;
  },

  getOne: async (id: number) => {
    const res = await apiClient.get<JSendResponse<{ lab_work: LabWork }>>(`/lab-works/${id}`);
    return res.data;
  },

  create: async (data: Partial<LabWork>) => {
    const res = await apiClient.post<JSendResponse<{ lab_work: LabWork }>>('/lab-works', data);
    return res.data;
  },

  update: async (id: number, data: Partial<LabWork>) => {
    const res = await apiClient.put<JSendResponse<{ lab_work: LabWork }>>(`/lab-works/${id}`, data);
    return res.data;
  },

  remove: async (id: number) => {
    const res = await apiClient.delete<JSendResponse<null>>(`/lab-works/${id}`);
    return res.data;
  },
};

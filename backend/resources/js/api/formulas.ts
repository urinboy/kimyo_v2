import apiClient from './client';

export interface FormulaTranslation {
  language_id: number;
  name: string;
}

export interface FormulaElement {
  id: number;
  symbol: string;
  pivot: {
    amount: number;
  };
}

export interface Formula {
  id: number;
  formula: string;
  molar_mass: number | null;
  category: string | null;
  translations: FormulaTranslation[];
  elements: FormulaElement[];
}

export interface JSendResponse<T> {
  status: 'success' | 'fail' | 'error';
  data: T;
  message?: string;
}

export const formulaApi = {
  getAll: async () => {
    const response = await apiClient.get<JSendResponse<{ formulas: Formula[] }>>('/formulas');
    return response.data;
  },

  create: async (data: Partial<Formula> & { translations: Record<number, Partial<FormulaTranslation>>; elements?: { element_id: number; amount: number }[] }) => {
    const response = await apiClient.post<JSendResponse<{ formula: Formula }>>('/formulas', data);
    return response.data;
  },

  update: async (id: number, data: Partial<Formula> & { translations: Record<number, Partial<FormulaTranslation>>; elements?: { element_id: number; amount: number }[] }) => {
    const response = await apiClient.put<JSendResponse<{ formula: Formula }>>(`/formulas/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/formulas/${id}`);
    return response.data;
  },
};

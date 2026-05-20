import apiClient from './client';

export interface ChemicalReactionType {
  id: number;
  name_uz: string;
  name_ru: string | null;
  name_en: string | null;
  name_kaa: string | null;
  formula: string;
  color_hex: string;
  icon_color_hex: string;
  order: number;
}

export interface ChemicalReactionSymbol {
  id: number;
  symbol: string;
  desc_uz: string;
  desc_ru: string | null;
  desc_en: string | null;
  desc_kaa: string | null;
  order: number;
}

export interface ChemicalReactionsListResponse {
  status: 'success' | 'fail' | 'error';
  data: {
    reaction_types: ChemicalReactionType[];
    reaction_symbols: ChemicalReactionSymbol[];
  };
}

export type TypePayload = Omit<ChemicalReactionType, 'id'>;
export type SymbolPayload = Omit<ChemicalReactionSymbol, 'id'>;

export const chemicalReactionsApi = {
  getAll: async () => {
    const response = await apiClient.get<ChemicalReactionsListResponse>('/chemical-reactions');
    return response.data;
  },

  createType: async (data: TypePayload) => {
    const response = await apiClient.post<{ status: string; data: { reaction_type: ChemicalReactionType } }>(
      '/chemical-reaction-types',
      data,
    );
    return response.data;
  },

  updateType: async (id: number, data: Partial<TypePayload>) => {
    const response = await apiClient.put<{ status: string; data: { reaction_type: ChemicalReactionType } }>(
      `/chemical-reaction-types/${id}`,
      data,
    );
    return response.data;
  },

  deleteType: async (id: number) => {
    const response = await apiClient.delete<{ status: string; data: null }>(`/chemical-reaction-types/${id}`);
    return response.data;
  },

  createSymbol: async (data: SymbolPayload) => {
    const response = await apiClient.post<{ status: string; data: { reaction_symbol: ChemicalReactionSymbol } }>(
      '/chemical-reaction-symbols',
      data,
    );
    return response.data;
  },

  updateSymbol: async (id: number, data: Partial<SymbolPayload>) => {
    const response = await apiClient.put<{ status: string; data: { reaction_symbol: ChemicalReactionSymbol } }>(
      `/chemical-reaction-symbols/${id}`,
      data,
    );
    return response.data;
  },

  deleteSymbol: async (id: number) => {
    const response = await apiClient.delete<{ status: string; data: null }>(`/chemical-reaction-symbols/${id}`);
    return response.data;
  },
};

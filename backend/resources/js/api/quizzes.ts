import apiClient from './client';
import type { JSendResponse } from './lessons';

export interface QuizTranslation {
  language_id: number;
  text: string;
}

export interface OptionTranslation {
  language_id: number;
  text: string;
}

export interface Option {
  id?: number;
  question_id?: number;
  is_correct: boolean;
  translations: Record<number, OptionTranslation>;
}

export interface Question {
  id?: number;
  quiz_id?: number;
  order: number;
  points: number;
  translations: Record<number, QuestionTranslation>;
  options: Option[];
}

export interface QuestionTranslation {
  language_id: number;
  text: string;
  image_url?: string | null;
}

export interface Quiz {
  id: number;
  lesson_id: number;
  is_active: boolean;
  questions: Question[];
}

export const quizApi = {
  getByLesson: async (lessonId: number) => {
    const response = await apiClient.get<JSendResponse<{ quiz: Quiz }>>(`/lessons/${lessonId}/quiz`);
    return response.data;
  },

  create: async (data: { lesson_id: number; is_active?: boolean }) => {
    const response = await apiClient.post<JSendResponse<{ quiz: Quiz }>>('/quizzes', data);
    return response.data;
  },

  syncQuestions: async (quizId: number, questions: Question[]) => {
    const response = await apiClient.post<JSendResponse<{ quiz: Quiz }>>(`/quizzes/${quizId}/sync`, { questions });
    return response.data;
  },

  update: async (id: number, data: Partial<Quiz>) => {
    const response = await apiClient.put<JSendResponse<{ quiz: Quiz }>>(`/quizzes/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await apiClient.delete<JSendResponse<null>>(`/quizzes/${id}`);
    return response.data;
  },
};

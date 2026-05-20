import { useState, useMemo, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { 
  Plus, 
  Trash2, 
  ChevronLeft, 
  Save, 
  Loader2, 
  CheckCircle2, 
  XCircle, 
  GripVertical
} from 'lucide-react';
import { quizApi, type Question } from '@/api/quizzes';
import { standaloneQuizApi } from '@/api/standaloneQuizzes';
import { languageApi } from '@/api/languages';
import { GlassCard } from '@/components/ui/GlassCard';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';
import { toast } from 'sonner';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';

const AppQuizQuestionsPage = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const quizId = parseInt(id || '0', 10);

  const [activeLangTab, setActiveLangTab] = useState('uz');
  const [questions, setQuestions] = useState<Question[]>([]);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingIndex, setDeletingIndex] = useState<number | null>(null);

  // Queries
  const { data: langData } = useQuery({ queryKey: ['languages'], queryFn: languageApi.getAll });
  const { data: quizData, isLoading: isQuizLoading, isError: isQuizError } = useQuery({
    queryKey: ['standalone-quiz', quizId],
    queryFn: () => standaloneQuizApi.get(quizId),
    enabled: Number.isFinite(quizId) && quizId > 0,
    retry: false,
  });

  const activeLanguages = useMemo(() => langData?.data.languages.filter(l => l.is_active) || [], [langData]);

  // Use a ref or simple check to see if we've initialized questions from quizData
  const [isInitialized, setIsInitialized] = useState(false);

  useEffect(() => {
    if (quizData?.data?.quiz?.questions && !isInitialized) {
      const toTranslationMap = (arr: any[]): Record<number, any> =>
        Object.fromEntries(
          (arr ?? []).map((t: any) => [
            t.language_id,
            { text: t.text ?? '', language_id: t.language_id },
          ]),
        );

      const mapped: Question[] = quizData.data.quiz.questions.map(q => ({
        id: q.id,
        points: q.points,
        order: q.order,
        translations: toTranslationMap(q.translations as unknown as any[]),
        options: q.options.map(o => ({
          id: o.id,
          is_correct: o.is_correct,
          translations: toTranslationMap(o.translations as unknown as any[]),
        })),
      }));
      setQuestions(mapped);
      setIsInitialized(true);
    }
  }, [quizData, isInitialized]);

  const syncMutation = useMutation({
    mutationFn: (data: { quizId: number; questions: Question[] }) => quizApi.syncQuestions(data.quizId, data.questions),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['standalone-quiz', quizId] });
      queryClient.invalidateQueries({ queryKey: ['standalone-quizzes'] });
      toast.success(t('common.save_success'));
    },
    onError: (error) => {
      toast.error(getApiErrorMessage(error, t('toast.error_generic')));
    },
  });

  const addQuestion = () => {
    const newQuestion: Question = {
      order: questions.length,
      points: 1,
      translations: {},
      options: [
        { is_correct: true, translations: {} },
        { is_correct: false, translations: {} }
      ]
    };
    setQuestions([...questions, newQuestion]);
  };

  const removeQuestion = (index: number) => {
    setQuestions(questions.filter((_, i) => i !== index));
    setIsDeleteModalOpen(false);
    setDeletingIndex(null);
  };

  const handleQuestionChange = (index: number, field: keyof Question, value: any) => {
    const newQuestions = [...questions];
    newQuestions[index] = { ...newQuestions[index], [field]: value };
    setQuestions(newQuestions);
  };

  const handleTranslationChange = (qIndex: number, langId: number, text: string) => {
    const newQuestions = [...questions];
    newQuestions[qIndex].translations[langId] = { text, language_id: langId };
    setQuestions(newQuestions);
  };

  const handleOptionChange = (qIndex: number, oIndex: number, field: string, value: any) => {
    const newQuestions = [...questions];
    if (field === 'is_correct' && value === true) {
      // Reset others in the same question
      newQuestions[qIndex].options = newQuestions[qIndex].options.map((o, i) => ({
        ...o,
        is_correct: i === oIndex
      }));
    } else {
      newQuestions[qIndex].options[oIndex] = { ...newQuestions[qIndex].options[oIndex], [field]: value };
    }
    setQuestions(newQuestions);
  };

  const handleOptionTranslationChange = (qIndex: number, oIndex: number, langId: number, text: string) => {
    const newQuestions = [...questions];
    if (!newQuestions[qIndex].options[oIndex].translations) {
      newQuestions[qIndex].options[oIndex].translations = {};
    }
    newQuestions[qIndex].options[oIndex].translations[langId] = { text, language_id: langId };
    setQuestions(newQuestions);
  };

  const addOption = (qIndex: number) => {
    const newQuestions = [...questions];
    newQuestions[qIndex].options.push({ is_correct: false, translations: {} });
    setQuestions(newQuestions);
  };

  const removeOption = (qIndex: number, oIndex: number) => {
    const newQuestions = [...questions];
    newQuestions[qIndex].options = newQuestions[qIndex].options.filter((_: any, i: number) => i !== oIndex);
    setQuestions(newQuestions);
  };

  const handleSave = () => {
    if (!quizData?.data?.quiz?.id) return;
    
    // Format questions to match backend expectation (translations as arrays)
    const formattedQuestions = questions.map(q => ({
      ...q,
      translations: Object.values(q.translations),
      options: q.options.map(o => ({
        ...o,
        translations: Object.values(o.translations || {})
      }))
    }));

    syncMutation.mutate({ quizId: quizData.data.quiz.id, questions: formattedQuestions });
  };

  if (isQuizLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 className="w-10 h-10 animate-spin text-purple-500" />
      </div>
    );
  }

  if (isQuizError || !quizData?.data?.quiz) {
    return (
      <div className="space-y-6 p-4">
        <button type="button" onClick={() => navigate('/app-tests')} className="p-3 rounded-2xl glass text-app-muted">
          <ChevronLeft className="w-6 h-6" />
        </button>
        <GlassCard className="py-12 text-center text-app-muted">{t('appTests.quiz_not_found')}</GlassCard>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-20">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/app-tests')}
            className="p-3 rounded-2xl glass hover:bg-white/10 transition-all text-app-muted hover:text-app-primary"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <div>
            <h1 className="text-3xl font-bold flex items-center gap-3 text-app-primary">
              {t('appTests.questions_header')}
              <span className="text-sm font-normal text-purple-400 bg-purple-500/10 px-3 py-1 rounded-full border border-purple-500/20">
                ID {quizId}
              </span>
            </h1>
            <p className="text-app-muted mt-1 max-w-2xl">{t('quiz.subtitle')}</p>
          </div>
        </div>

        <button
          onClick={handleSave}
          disabled={syncMutation.isPending}
          className="btn-primary flex items-center gap-2 px-8"
        >
          {syncMutation.isPending ? <Loader2 className="w-5 h-5 animate-spin" /> : <Save className="w-5 h-5" />}
          {t('common.save')}
        </button>
      </div>

      <div className="space-y-8">
          {/* Language Selector */}
          <div className="flex gap-2 p-1 rounded-2xl bg-black/[0.04] dark:bg-white/5 border border-black/10 dark:border-white/10 w-fit">
            {activeLanguages.map(lang => (
              <button
                key={lang.id}
                onClick={() => setActiveLangTab(lang.code)}
                className={`py-2 px-6 rounded-xl text-sm font-medium transition-all flex items-center gap-2 ${
                  activeLangTab === lang.code ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary"
                }`}
              >
                <LanguageFlag code={lang.code} size="md" className="shrink-0" />
                {lang.name}
              </button>
            ))}
          </div>

          {/* Questions List */}
          <div className="space-y-6">
            {questions.map((q, qIndex) => (
              <GlassCard key={qIndex} className="relative overflow-visible group">
                <div className="absolute -left-3 top-1/2 -translate-y-1/2 cursor-grab text-app-subtle opacity-0 group-hover:opacity-100 transition-opacity">
                  <GripVertical className="w-6 h-6" />
                </div>

                <div className="flex justify-between items-start mb-6">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-xl bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-purple-400 font-bold">
                      {qIndex + 1}
                    </div>
                    <div className="space-y-1">
                      <h4 className="font-bold text-app-primary">{t('quiz.section_question')}</h4>
                      <p className="text-xs text-app-muted">{t('quiz.section_hint')}</p>
                    </div>
                  </div>
                  <button 
                    onClick={() => {
                      setDeletingIndex(qIndex);
                      setIsDeleteModalOpen(true);
                    }}
                    className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"
                  >
                    <Trash2 className="w-5 h-5" />
                  </button>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
                  {/* Left Side: Question Content */}
                  <div className="lg:col-span-12 space-y-6">
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1">
                        {t('quiz.field_question', { code: activeLangTab.toUpperCase() })}
                      </label>
                      <textarea
                        rows={3}
                        value={q.translations[activeLanguages.find(l => l.code === activeLangTab)?.id || 0]?.text || ''}
                        onChange={(e) => handleTranslationChange(qIndex, activeLanguages.find(l => l.code === activeLangTab)?.id || 0, e.target.value)}
                        className="input-glass resize-none"
                        placeholder={t('quiz.placeholder_question')}
                      />
                    </div>
                    
                    <div className="flex gap-6">
                      <div className="space-y-2 flex-1">
                        <label className="text-sm font-medium text-app-subtle ml-1">{t('quiz.field_points')}</label>
                        <input
                          type="number"
                          value={q.points}
                          onChange={(e) => handleQuestionChange(qIndex, 'points', parseInt(e.target.value))}
                          className="input-glass"
                        />
                      </div>
                      <div className="space-y-2 flex-1">
                        <label className="text-sm font-medium text-app-subtle ml-1">{t('quiz.field_order')}</label>
                        <input
                          type="number"
                          value={q.order}
                          onChange={(e) => handleQuestionChange(qIndex, 'order', parseInt(e.target.value))}
                          className="input-glass"
                        />
                      </div>
                    </div>
                  </div>

                  {/* Options Section */}
                  <div className="lg:col-span-12 space-y-4">
                    <div className="flex justify-between items-center mb-2">
                       <label className="text-sm font-bold text-app-subtle ml-1 uppercase tracking-widest text-[10px]">{t('quiz.options_title')}</label>
                       <button 
                         onClick={() => addOption(qIndex)}
                         className="text-xs font-bold text-purple-400 hover:text-purple-300 flex items-center gap-1"
                         type="button"
                       >
                         <Plus className="w-3 h-3" /> {t('quiz.add_option')}
                       </button>
                    </div>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {q.options.map((option: any, oIndex: number) => (
                        <div key={oIndex} className={`p-4 rounded-2xl glass border transition-all ${option.is_correct ? 'border-emerald-500/50 bg-emerald-500/5' : 'border-white/10'}`}>
                          <div className="flex items-center gap-3 mb-3">
                            <button 
                              onClick={() => handleOptionChange(qIndex, oIndex, 'is_correct', true)}
                              className={`p-1.5 rounded-lg transition-all ${option.is_correct ? 'bg-emerald-500 text-white' : 'bg-white/5 text-app-muted hover:border-white/20'}`}
                            >
                              {option.is_correct ? <CheckCircle2 className="w-4 h-4" /> : <XCircle className="w-4 h-4" />}
                            </button>
                            <input
                              type="text"
                              value={option.translations?.[activeLanguages.find(l => l.code === activeLangTab)?.id || 0]?.text || ''}
                              onChange={(e) => handleOptionTranslationChange(qIndex, oIndex, activeLanguages.find(l => l.code === activeLangTab)?.id || 0, e.target.value)}
                              className="bg-transparent border-none focus:ring-0 text-sm w-full p-0 text-app-primary placeholder:text-app-muted"
                              placeholder={t('quiz.option_placeholder', { n: oIndex + 1 })}
                            />
                            {q.options.length > 2 && (
                              <button 
                                onClick={() => removeOption(qIndex, oIndex)}
                                className="p-1 text-app-muted hover:text-red-500"
                              >
                                <Trash2 className="w-4 h-4" />
                              </button>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </GlassCard>
            ))}
          </div>

          <button 
            type="button"
            onClick={addQuestion}
            className="w-full py-8 rounded-3xl border-2 border-dashed border-white/10 hover:border-purple-500/50 hover:bg-purple-500/5 text-app-muted hover:text-purple-400 transition-all flex flex-col items-center justify-center gap-2"
          >
            <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center group-hover:scale-110 transition-transform">
              <Plus className="w-6 h-6" />
            </div>
            <span className="font-bold text-app-primary">{t('quiz.add_question')}</span>
          </button>
        </div>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingIndex !== null && removeQuestion(deletingIndex)}
        title={t('quiz.delete_question_title')}
        message={t('quiz.delete_question_confirm')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
      />
    </div>
  );
};

export default AppQuizQuestionsPage;

import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { toast } from 'sonner';
import { Plus, Edit2, Trash2, Loader2, ListChecks, BookOpen, HelpCircle, ClipboardList } from 'lucide-react';
import { standaloneQuizApi, type StandaloneQuiz, type StandaloneQuizPayload } from '@/api/standaloneQuizzes';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';
import { cn } from '@/lib/utils';

type TabType = 'chemistry' | 'geography';
type TitleLang = 'uz' | 'ru' | 'en';

const titleLangConfig: { key: TitleLang; flag: string; labelKey: 'lang_tab_uz' | 'lang_tab_ru' | 'lang_tab_en' }[] = [
  { key: 'uz', flag: 'uz', labelKey: 'lang_tab_uz' },
  { key: 'ru', flag: 'ru', labelKey: 'lang_tab_ru' },
  { key: 'en', flag: 'en', labelKey: 'lang_tab_en' },
];

const emptyForm = (): StandaloneQuizPayload => ({
  type: 'chemistry',
  category: '',
  title_uz: '',
  title_ru: '',
  title_en: '',
  sort_order: 0,
  is_active: true,
});

const AppTestsPage = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [tab, setTab] = useState<TabType>('chemistry');
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<StandaloneQuiz | null>(null);
  const [form, setForm] = useState<StandaloneQuizPayload>(emptyForm);
  const [titleLang, setTitleLang] = useState<TitleLang>('uz');
  const [deleteId, setDeleteId] = useState<number | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['standalone-quizzes', tab],
    queryFn: () => standaloneQuizApi.list(tab),
  });

  const quizzes = data?.data.quizzes ?? [];

  const createMut = useMutation({
    mutationFn: () => standaloneQuizApi.create(form),
    onSuccess: (res) => {
      if (res?.status === 'success') {
        queryClient.invalidateQueries({ queryKey: ['standalone-quizzes'] });
        setModalOpen(false);
        toast.success(t('common.save_success'));
      }
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });

  const updateMut = useMutation({
    mutationFn: () => {
      if (!editing) throw new Error('id');
      return standaloneQuizApi.update(editing.id, form);
    },
    onSuccess: (res) => {
      if (res?.status === 'success') {
        queryClient.invalidateQueries({ queryKey: ['standalone-quizzes'] });
        setModalOpen(false);
        toast.success(t('common.save_success'));
      }
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });

  const deleteMut = useMutation({
    mutationFn: (id: number) => standaloneQuizApi.delete(id),
    onSuccess: (res) => {
      if (res?.status === 'success') {
        queryClient.invalidateQueries({ queryKey: ['standalone-quizzes'] });
        setDeleteId(null);
        toast.success(t('toast.deleted'));
      }
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.delete_error'))),
  });

  const openNew = () => {
    setEditing(null);
    setForm({ ...emptyForm(), type: tab });
    setTitleLang('uz');
    setModalOpen(true);
  };

  const openEdit = (q: StandaloneQuiz) => {
    setEditing(q);
    setForm({
      type: q.type,
      category: q.category,
      title_uz: q.title_uz || '',
      title_ru: q.title_ru || '',
      title_en: q.title_en || '',
      sort_order: q.sort_order,
      is_active: q.is_active,
    });
    setTitleLang('uz');
    setModalOpen(true);
  };

  const setTitleForLang = (value: string) => {
    setForm((f) => {
      if (titleLang === 'uz') return { ...f, title_uz: value };
      if (titleLang === 'ru') return { ...f, title_ru: value };
      return { ...f, title_en: value };
    });
  };

  const titleInputValue = titleLang === 'uz' ? form.title_uz : titleLang === 'ru' ? (form.title_ru ?? '') : (form.title_en ?? '');

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.category.trim() || !form.title_uz.trim()) {
      toast.error(t('appTests.validation_required'));
      return;
    }
    if (editing) updateMut.mutate();
    else createMut.mutate();
  };

  const pending = createMut.isPending || updateMut.isPending;

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="flex items-center gap-2 text-3xl font-bold text-app-primary">
            <ListChecks className="h-8 w-8 text-purple-500" />
            {t('appTests.title')}
          </h1>
          <p className="mt-1 text-app-muted">{t('appTests.subtitle')}</p>
        </div>
        <button type="button" onClick={openNew} className="btn-primary flex w-fit items-center gap-2">
          <Plus className="h-5 w-5" />
          {t('appTests.add_quiz')}
        </button>
      </div>

      <div className="flex w-fit gap-2 rounded-2xl border border-black/10 bg-black/[0.04] p-1 dark:border-white/10 dark:bg-white/5">
        {(['chemistry', 'geography'] as const).map((key) => (
          <button
            key={key}
            type="button"
            onClick={() => setTab(key)}
            className={cn(
              'rounded-xl px-6 py-2 text-sm font-bold transition-all',
              tab === key
                ? 'bg-purple-500 text-white shadow-lg shadow-purple-500/20'
                : 'text-app-muted hover:bg-black/5 hover:text-app-primary dark:hover:bg-white/5',
            )}
          >
            {key === 'chemistry' ? t('appTests.tab_chemistry') : t('appTests.tab_geography')}
          </button>
        ))}
      </div>

      {isLoading ? (
        <div className="py-20 text-center">
          <Loader2 className="mx-auto h-10 w-10 animate-spin text-purple-500" />
        </div>
      ) : (
        <div className="space-y-3">
          {quizzes.length === 0 ? (
            <GlassCard className="py-12 text-center text-app-muted">{t('appTests.empty')}</GlassCard>
          ) : (
            quizzes.map((q) => (
              <GlassCard key={q.id} className="flex flex-col gap-3 py-4 sm:flex-row sm:items-center sm:justify-between">
                <div className="min-w-0">
                  <p className="font-bold text-app-primary">{q.title_uz}</p>
                  <p className="text-sm text-app-muted">
                    <code className="rounded bg-black/5 px-1 dark:bg-white/10">{q.category}</code> · {q.questions_count ?? 0}{' '}
                    {t('appTests.questions_short')}
                  </p>
                </div>
                <div className="flex shrink-0 flex-wrap gap-1">
                  <button
                    type="button"
                    onClick={() => navigate(`/app-tests/${q.id}/answers`)}
                    className="flex items-center gap-1 rounded-xl p-2 text-app-muted transition-colors hover:bg-emerald-500/10 hover:text-emerald-600 dark:hover:text-emerald-400"
                    title={t('appTests.answers_link')}
                  >
                    <ClipboardList className="h-4 w-4" />
                    <span className="hidden text-xs font-bold sm:inline">{t('appTests.answers_link')}</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => navigate(`/app-tests/${q.id}/questions`)}
                    className="flex items-center gap-1 rounded-xl p-2 text-app-muted transition-colors hover:bg-purple-500/10 hover:text-purple-600"
                    title={t('appTests.open_questions')}
                  >
                    <BookOpen className="h-4 w-4" />
                    <span className="text-xs font-bold">{t('appTests.questions')}</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => openEdit(q)}
                    className="rounded-xl p-2 text-app-muted hover:bg-white/10 hover:text-app-primary"
                  >
                    <Edit2 className="h-4 w-4" />
                  </button>
                  <button
                    type="button"
                    onClick={() => setDeleteId(q.id)}
                    className="rounded-xl p-2 text-app-muted hover:bg-red-500/10 hover:text-red-500"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </GlassCard>
            ))
          )}
        </div>
      )}

      <GlassModal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editing ? t('appTests.edit_quiz') : t('appTests.add_quiz')}
        className="max-w-xl"
      >
        <form onSubmit={submit} className="space-y-5">
          <div className="space-y-3">
            <h3 className="text-[11px] font-bold uppercase tracking-widest text-app-muted/90">{t('appTests.section_basic')}</h3>
            <div
              className="rounded-2xl border border-white/10 bg-white/3 p-3 dark:border-white/10"
              role="group"
              aria-label={t('appTests.field_type')}
            >
              <p className="mb-2 text-sm font-medium text-app-subtle">{t('appTests.field_type')}</p>
              <div className="grid grid-cols-2 gap-2">
                {(['chemistry', 'geography'] as const).map((k) => (
                  <button
                    key={k}
                    type="button"
                    onClick={() => setForm((f) => ({ ...f, type: k }))}
                    className={cn(
                      'rounded-xl px-3 py-2.5 text-sm font-bold transition-all',
                      form.type === k
                        ? 'bg-purple-500 text-white shadow-md shadow-purple-500/20'
                        : 'border border-white/10 bg-white/5 text-app-muted hover:border-purple-500/30 hover:text-app-primary',
                    )}
                  >
                    {k === 'chemistry' ? t('appTests.tab_chemistry') : t('appTests.tab_geography')}
                  </button>
                ))}
              </div>
            </div>
            <div className="rounded-2xl border border-white/10 bg-white/3 p-3 dark:border-white/10">
              <div className="mb-1 flex items-start justify-between gap-2">
                <label htmlFor="quiz-category" className="text-sm font-medium text-app-subtle">
                  {t('appTests.field_category')}
                </label>
                <span className="text-app-muted" title={t('appTests.field_category_hint')}>
                  <HelpCircle className="h-4 w-4 shrink-0" aria-hidden />
                </span>
              </div>
              <input
                id="quiz-category"
                value={form.category}
                onChange={(e) => setForm((f) => ({ ...f, category: e.target.value }))}
                className="input-glass font-mono text-sm"
                placeholder="periodic_table, geo_uz, ..."
                autoComplete="off"
                required
                spellCheck={false}
              />
              <p className="mt-2 text-xs leading-relaxed text-app-muted">{t('appTests.field_category_hint')}</p>
            </div>
          </div>

          <div className="space-y-3">
            <h3 className="text-[11px] font-bold uppercase tracking-widest text-app-muted/90">{t('appTests.section_titles')}</h3>
            <div className="rounded-2xl border border-white/10 bg-white/3 p-3 dark:border-white/10">
              <div className="mb-3 flex w-full gap-1 rounded-xl border border-white/10 bg-black/5 p-1 dark:bg-white/5">
                {titleLangConfig.map(({ key, flag, labelKey }) => (
                  <button
                    key={key}
                    type="button"
                    onClick={() => setTitleLang(key)}
                    className={cn(
                      'flex min-w-0 flex-1 items-center justify-center gap-1.5 rounded-lg py-2 text-xs font-bold transition-all sm:text-sm',
                      titleLang === key
                        ? 'bg-purple-500 text-white shadow-sm'
                        : 'text-app-muted hover:text-app-primary',
                    )}
                  >
                    <LanguageFlag code={flag} size="sm" className="opacity-90" />
                    {t(`appTests.${labelKey}`)}
                    {key === 'uz' && <span className="text-red-300/90">*</span>}
                  </button>
                ))}
              </div>
              <label htmlFor="quiz-title-input" className="mb-1.5 block text-sm font-medium text-app-subtle">
                {titleLang === 'uz' ? (
                  t('appTests.title_label_required')
                ) : (
                  <>
                    {t(`appTests.field_title_${titleLang}`)}
                    <span className="ml-1.5 text-xs font-normal text-app-muted">
                      ({t('appTests.optional_short')})
                    </span>
                  </>
                )}
              </label>
              <input
                id="quiz-title-input"
                value={titleInputValue}
                onChange={(e) => setTitleForLang(e.target.value)}
                className="input-glass w-full"
                required={titleLang === 'uz'}
                placeholder={titleLang === 'uz' ? t('appTests.placeholder_title_uz') : t('appTests.placeholder_title_other')}
                autoComplete="off"
              />
              <p className="mt-1.5 text-xs leading-relaxed text-app-muted sm:text-left">
                {titleLang === 'uz' ? t('appTests.title_subhint_uz') : t('appTests.title_subhint_other')}
              </p>
            </div>
          </div>
          <div className="space-y-3">
            <h3 className="text-[11px] font-bold uppercase tracking-widest text-app-muted/90">{t('appTests.section_publish')}</h3>
            <div className="grid gap-3 sm:grid-cols-2">
              <div className="rounded-2xl border border-white/10 bg-white/3 p-3 dark:border-white/10">
                <label htmlFor="quiz-order" className="text-sm font-medium text-app-subtle">
                  {t('appTests.field_order')}
                </label>
                <input
                  id="quiz-order"
                  type="number"
                  min={0}
                  value={form.sort_order ?? 0}
                  onChange={(e) => setForm((f) => ({ ...f, sort_order: Number(e.target.value) || 0 }))}
                  className="input-glass mt-2 w-full"
                />
                <p className="mt-2 text-xs text-app-muted">{t('appTests.field_order_hint')}</p>
              </div>
              <div
                className="flex items-center justify-between gap-3 rounded-2xl border border-white/10 bg-white/3 p-3 dark:border-white/10"
                role="group"
                aria-label={t('appTests.field_active')}
              >
                <div className="min-w-0">
                  <p className="text-sm font-medium text-app-primary">{t('appTests.field_active')}</p>
                </div>
                <button
                  type="button"
                  role="switch"
                  aria-checked={form.is_active !== false}
                  onClick={() => setForm((f) => ({ ...f, is_active: !(f.is_active !== false) }))}
                  className={cn(
                    'relative h-8 w-14 shrink-0 rounded-full p-0.5 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500/60',
                    form.is_active !== false ? 'bg-purple-500' : 'bg-slate-500/50 dark:bg-slate-600/50',
                  )}
                >
                  <span
                    className={cn(
                      'block h-7 w-7 rounded-full bg-white shadow transition-transform duration-200',
                      form.is_active !== false ? 'translate-x-6' : 'translate-x-0.5',
                    )}
                    aria-hidden
                  />
                </button>
              </div>
            </div>
          </div>

          <div className="flex gap-2 border-t border-white/10 pt-4">
            <button type="button" onClick={() => setModalOpen(false)} className="btn-modal-secondary flex-1 rounded-xl py-3">
              {t('common.cancel')}
            </button>
            <button type="submit" disabled={pending} className="btn-primary flex-1">
              {pending ? '...' : t('common.save')}
            </button>
          </div>
        </form>
      </GlassModal>

      <ConfirmModal
        isOpen={deleteId !== null}
        onClose={() => setDeleteId(null)}
        onConfirm={() => deleteId !== null && deleteMut.mutate(deleteId)}
        title={t('settings.delete_confirm_title')}
        message={t('settings.delete_confirm_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMut.isPending}
      />
    </div>
  );
};

export default AppTestsPage;

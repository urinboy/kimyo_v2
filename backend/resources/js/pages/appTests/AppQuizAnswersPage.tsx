import { useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { BarChart2, ChevronLeft, ClipboardList, Loader2, Users } from 'lucide-react';
import { standaloneQuizApi, type QuizAttemptsReportData, type StandaloneQuiz } from '@/api/standaloneQuizzes';
import { schoolsApi } from '@/api/schools';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { GlassCard } from '@/components/ui/GlassCard';
import { toast } from 'sonner';
import { cn, schoolsWithSelectLabel } from '@/lib/utils';

type ReportTab = 'students' | 'answers';

/** Joriy sana bo'yicha o'quv yilining boshlang'ich yili (masalan 2025 → "2025-2026"). */
function academicYearStartFromDate(d: Date): number {
  const y = d.getFullYear();
  const m = d.getMonth() + 1;
  const day = d.getDate();
  if (m > 9 || (m === 9 && day >= 1)) {
    return y;
  }
  return y - 1;
}

function defaultAcademicYear(): string {
  const start = academicYearStartFromDate(new Date());
  return `${start}-${start + 1}`;
}

/** Eng eski: 2022-2023; eng yangi: faqat allaqachon boshlangan o'quv yili (kelajakdagi yillarsiz). */
function academicYearChoices(): string[] {
  const minStart = 2022;
  const maxStart = academicYearStartFromDate(new Date());
  const out: string[] = [];
  for (let y = minStart; y <= maxStart; y++) {
    out.push(`${y}-${y + 1}`);
  }
  return out.reverse();
}

export default function AppQuizAnswersPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const quizId = parseInt(id || '0', 10);

  const [academicYear, setAcademicYear] = useState(defaultAcademicYear);
  const [schoolId, setSchoolId] = useState<number>(0);
  const [activeTab, setActiveTab] = useState<ReportTab>('students');
  const [applied, setApplied] = useState(() => ({
    year: defaultAcademicYear(),
    school: 0,
  }));

  const { data: quizRes, isLoading: quizLoading } = useQuery({
    queryKey: ['standalone-quiz', quizId],
    queryFn: () => standaloneQuizApi.get(quizId),
    enabled: Number.isFinite(quizId) && quizId > 0,
    retry: false,
  });

  const { data: schoolsRes } = useQuery({
    queryKey: ['schools-list'],
    queryFn: () => schoolsApi.getAll(),
  });

  const schools = schoolsRes?.data?.schools ?? [];
  const schoolsForSelect = useMemo(
    () => schoolsWithSelectLabel(schools, s => (s.short_name?.trim() ? s.short_name : s.name)),
    [schools],
  );

  const {
    data: report,
    isLoading: reportLoading,
    isError,
    error,
  } = useQuery<QuizAttemptsReportData>({
    queryKey: ['quiz-attempts-report', quizId, applied.year, applied.school],
    queryFn: async () => {
      const res = await standaloneQuizApi.getAttemptsReport(quizId, {
        academic_year: applied.year,
        school_id: applied.school > 0 ? applied.school : undefined,
      });
      if (res.status !== 'success') {
        throw new Error('Report failed');
      }
      return res.data;
    },
    enabled: Number.isFinite(quizId) && quizId > 0,
  });

  useEffect(() => {
    if (isError) {
      toast.error(getApiErrorMessage(error, t('toast.error_generic')), { id: 'quiz-report-err' });
    }
  }, [isError, error, t]);

  const years = useMemo(() => academicYearChoices(), []);

  if (!Number.isFinite(quizId) || quizId <= 0) {
    return (
      <div className="p-8">
        <p className="text-app-muted">{t('appTests.quiz_not_found')}</p>
      </div>
    );
  }

  const quizMeta = quizRes?.data?.quiz as unknown as StandaloneQuiz | undefined;

  const quizTitle = quizMeta?.title_uz ?? `Test #${quizId}`;

  return (
    <div className="animate-in fade-in slide-in-from-bottom-4 space-y-8 duration-500">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div className="space-y-2">
          <button
            type="button"
            onClick={() => navigate('/app-tests')}
            className="mb-2 flex items-center gap-2 text-sm font-medium text-app-muted hover:text-purple-600"
          >
            <ChevronLeft className="h-4 w-4" />
            {t('appTests.answers_back')}
          </button>
          <h1 className="flex items-center gap-2 text-2xl font-bold text-app-primary sm:text-3xl">
            <ClipboardList className="h-8 w-8 shrink-0 text-purple-500" />
            {t('appTests.answers_title')}
          </h1>
          <p className="text-app-muted">
            {quizTitle}
            <span className="mx-2 text-app-subtle">·</span>
            <code className="rounded bg-black/5 px-1 dark:bg-white/10">{quizMeta?.category}</code>
          </p>
        </div>
      </div>

      <GlassCard className="space-y-4 py-5">
        <h2 className="text-xs font-bold uppercase tracking-widest text-app-muted">{t('appTests.answers_filters')}</h2>
        <div className="flex flex-col gap-4 sm:flex-row sm:flex-wrap sm:items-end">
          <div className="min-w-[200px] flex-1 space-y-1.5">
            <label className="text-sm font-medium text-app-subtle">{t('appTests.filter_academic_year')}</label>
            <select
              value={academicYear}
              onChange={(e) => setAcademicYear(e.target.value)}
              className="input-glass w-full"
            >
              {years.map((y) => (
                <option key={y} value={y}>
                  {y} ({t('appTests.year_range_hint')})
                </option>
              ))}
            </select>
          </div>
          <div className="min-w-[220px] flex-1 space-y-1.5">
            <label className="text-sm font-medium text-app-subtle">{t('appTests.filter_school')}</label>
            <select
              value={schoolId}
              onChange={(e) => setSchoolId(parseInt(e.target.value, 10) || 0)}
              className="input-glass w-full"
            >
              <option value={0}>{t('appTests.all_schools')}</option>
              {schoolsForSelect.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.selectLabel}
                </option>
              ))}
            </select>
          </div>
          <button
            type="button"
            onClick={() => setApplied({ year: academicYear, school: schoolId })}
            className="btn-primary h-11 px-6"
          >
            {t('appTests.load_report')}
          </button>
        </div>
      </GlassCard>

      {quizLoading || reportLoading ? (
        <div className="py-16 text-center">
          <Loader2 className="mx-auto h-10 w-10 animate-spin text-purple-500" />
        </div>
      ) : isError ? (
        <GlassCard className="py-10 text-center text-red-500">
          {getApiErrorMessage(error, t('toast.error_generic'))}
        </GlassCard>
      ) : report ? (
        <>
          {/* Summary cards */}
          <div className="grid gap-4 sm:grid-cols-2">
            <GlassCard className="py-5">
              <p className="text-xs font-bold uppercase tracking-widest text-app-muted">{t('appTests.summary_attempts')}</p>
              <p className="mt-2 text-3xl font-black text-purple-500">{report.summary.total_attempts}</p>
            </GlassCard>
            <GlassCard className="py-5">
              <p className="text-xs font-bold uppercase tracking-widest text-app-muted">{t('appTests.summary_students')}</p>
              <p className="mt-2 text-3xl font-black text-emerald-500">{report.summary.unique_students}</p>
            </GlassCard>
          </div>

          {/* Tabs */}
          <div className="flex gap-1 rounded-2xl border border-black/10 bg-black/[0.03] p-1 dark:border-white/10 dark:bg-white/[0.04]">
            {(
              [
                { key: 'students', label: t('appTests.tab_students'), Icon: Users },
                { key: 'answers', label: t('appTests.tab_answers'), Icon: BarChart2 },
              ] as { key: ReportTab; label: string; Icon: React.ElementType }[]
            ).map(({ key, label, Icon }) => (
              <button
                key={key}
                type="button"
                onClick={() => setActiveTab(key)}
                className={cn(
                  'flex flex-1 items-center justify-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold transition-all',
                  activeTab === key
                    ? 'bg-white text-purple-600 shadow-sm dark:bg-white/10 dark:text-purple-400'
                    : 'text-app-muted hover:text-app-primary',
                )}
              >
                <Icon className="h-4 w-4 shrink-0" />
                {label}
              </button>
            ))}
          </div>

          {/* Tab: O'quvchilar ro'yxati */}
          {activeTab === 'students' && (
            <div className="space-y-3">
              <div className="scrollbar-none overflow-x-auto rounded-2xl border border-black/10 dark:border-white/10">
                <table className="w-full min-w-[720px] text-left text-sm">
                  <thead className="bg-black/[0.04] dark:bg-white/5">
                    <tr>
                      <th className="px-4 py-3 font-bold text-app-muted">#</th>
                      <th className="px-4 py-3 font-bold text-app-muted">{t('appTests.table_user')}</th>
                      <th className="px-4 py-3 font-bold text-app-muted">{t('appTests.table_school')}</th>
                      <th className="px-4 py-3 font-bold text-app-muted">{t('appTests.table_score')}</th>
                      <th className="px-4 py-3 font-bold text-app-muted shrink-0 whitespace-nowrap">
                        {t('appTests.table_date')}
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-black/5 dark:divide-white/5">
                    {report.attempts.length === 0 ? (
                      <tr>
                        <td colSpan={5} className="px-4 py-10 text-center text-app-muted">
                          {t('appTests.attempts_empty')}
                        </td>
                      </tr>
                    ) : (
                      report.attempts.map((a) => (
                        <tr key={a.id} className="hover:bg-black/[0.02] dark:hover:bg-white/[0.03]">
                          <td className="px-4 py-3 text-app-muted">{a.id}</td>
                          <td className="px-4 py-3">
                            <div className="font-medium text-app-primary">{a.user_name ?? '—'}</div>
                            <div className="text-xs text-app-muted">{a.user_email}</div>
                          </td>
                          <td className="px-4 py-3 text-app-muted">{a.school_name ?? '—'}</td>
                          <td className="px-4 py-3 font-mono text-app-primary">
                            {a.correct_count} / {a.total_count}
                          </td>
                          <td className="px-4 py-3 whitespace-nowrap text-app-muted">
                            {a.created_at ? new Date(a.created_at).toLocaleString() : '—'}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* Tab: Javoblar diagrammasi */}
          {activeTab === 'answers' && (
            <div className="space-y-4">
              {report.questions.length === 0 ? (
                <GlassCard className="py-10 text-center text-app-muted">{t('appTests.answers_empty_questions')}</GlassCard>
              ) : (
                report.questions.map((q) => (
                  <GlassCard key={q.question_id} className="space-y-4 py-5">
                    <p className="text-sm font-bold text-app-primary">
                      {(q.order ?? 0) + 1}. {q.text || `Savol #${q.question_id}`}
                    </p>
                    <div className="space-y-3">
                      {q.options.map((opt) => (
                        <div key={opt.option_id} className="space-y-1">
                          <div className="flex justify-between gap-2 text-xs">
                            <span
                              className={cn(
                                'font-medium',
                                opt.is_correct ? 'text-emerald-600 dark:text-emerald-400' : 'text-app-primary',
                              )}
                            >
                              {opt.text || `Variant #${opt.option_id}`}
                              {opt.is_correct ? ` (${t('appTests.correct_badge')})` : ''}
                            </span>
                            <span className="shrink-0 text-app-muted">
                              {opt.count} ({opt.percent}%)
                            </span>
                          </div>
                          <div className="h-2 overflow-hidden rounded-full bg-black/10 dark:bg-white/10">
                            <div
                              className={cn(
                                'h-full rounded-full transition-all',
                                opt.is_correct ? 'bg-emerald-500/80' : 'bg-purple-500/70',
                              )}
                              style={{ width: `${opt.percent <= 0 ? 0 : Math.max(6, opt.percent)}%` }}
                            />
                          </div>
                        </div>
                      ))}
                    </div>
                  </GlassCard>
                ))
              )}
            </div>
          )}
        </>
      ) : null}
    </div>
  );
}

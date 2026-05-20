import { useState, useEffect, useRef, useMemo, type ReactNode } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Loader2, Eye, EyeOff, CheckCircle, Clock, ChevronRight, Star, RotateCcw, Trash2 } from 'lucide-react';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { interestingTaskApi, type TaskSubmission, type TaskAnswer, type InterestingTask } from '@/api/interestingTasks';
import { schoolsApi, type School } from '@/api/schools';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { switchInactiveTrackCn, schoolsWithSelectLabel } from '@/lib/utils';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { toast } from 'sonner';

function academicYearStartFromDate(d: Date): number {
  const m = d.getMonth() + 1;
  return m >= 9 ? d.getFullYear() : d.getFullYear() - 1;
}
function defaultAcademicYear(): string {
  const s = academicYearStartFromDate(new Date());
  return `${s}-${s + 1}`;
}
function academicYearChoices(): string[] {
  const min = 2022;
  const max = academicYearStartFromDate(new Date());
  const out: string[] = [];
  for (let y = min; y <= max; y++) out.push(`${y}-${y + 1}`);
  return out.reverse();
}

export default function SubmissionsPage() {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const [selected, setSelected] = useState<TaskSubmission | null>(null);
  const [answerEdits, setAnswerEdits] = useState<Record<number, { is_correct?: boolean; score: number; teacher_comment: string }>>({});
  const [teacherComment, setTeacherComment] = useState('');
  const [resultVisible, setResultVisible] = useState(false);
  const [filterStatus, setFilterStatus] = useState<string>('');
  const [filterTaskId, setFilterTaskId] = useState<string>('');
  const [filterSchoolId, setFilterSchoolId] = useState<string>('');
  const [filterYear, setFilterYear] = useState(defaultAcademicYear);
  const [selectedIds, setSelectedIds] = useState<Set<number>>(() => new Set());
  const selectAllRef = useRef<HTMLInputElement>(null);
  const [confirmReset, setConfirmReset] = useState<{ id: number; name: string } | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<{ id: number; name: string } | null>(null);
  const [confirmBulkReset, setConfirmBulkReset] = useState(false);
  const [confirmBulkDelete, setConfirmBulkDelete] = useState(false);

  const years = useMemo(() => academicYearChoices(), []);

  const { data: tasksListData } = useQuery({
    queryKey: ['interesting-tasks', 'all-for-filter'],
    queryFn: () => interestingTaskApi.getAll({ kind: 'interesting' }),
  });
  const tasksForFilter: InterestingTask[] = (tasksListData?.data?.tasks ?? []).filter(
    (task: InterestingTask) => (task.task_kind ?? 'interesting') === 'interesting',
  );
  const tasksSorted = [...tasksForFilter].sort(
    (a, b) =>
      (a.sort_order ?? 0) - (b.sort_order ?? 0) ||
      (a.title ?? '').localeCompare(b.title ?? '', undefined, { sensitivity: 'base' }),
  );

  const { data: schoolsRes } = useQuery({
    queryKey: ['schools-list'],
    queryFn: () => schoolsApi.getAll(),
  });
  const schools: School[] = schoolsRes?.data?.schools ?? [];
  const schoolsForSelect = useMemo(() => schoolsWithSelectLabel(schools), [schools]);

  const { data, isLoading } = useQuery({
    queryKey: ['task-submissions', filterStatus, filterTaskId, filterSchoolId, filterYear],
    queryFn: () => {
      const params: Record<string, string | number> = {};
      if (filterStatus) params.status = filterStatus;
      if (filterTaskId) params.task_id = Number(filterTaskId);
      if (filterSchoolId) params.school_id = Number(filterSchoolId);
      if (filterYear) params.academic_year = filterYear;
      return interestingTaskApi.getSubmissions(Object.keys(params).length ? params : undefined);
    },
  });
  const submissions: TaskSubmission[] = data?.data?.submissions ?? [];

  useEffect(() => {
    setSelectedIds(new Set());
  }, [filterStatus, filterTaskId, filterSchoolId, filterYear]);

  const checkedOnPage = submissions.filter(s => s.status === 'checked');
  const allCheckedSelected =
    checkedOnPage.length > 0 && checkedOnPage.every(s => selectedIds.has(s.id));

  useEffect(() => {
    const el = selectAllRef.current;
    if (!el) return;
    el.indeterminate = selectedIds.size > 0 && !allCheckedSelected;
  }, [selectedIds, allCheckedSelected]);

  const toggleSelectRow = (id: number) => {
    setSelectedIds(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const toggleSelectAllChecked = () => {
    setSelectedIds(prev => {
      if (checkedOnPage.length > 0 && checkedOnPage.every(s => prev.has(s.id))) {
        return new Set();
      }
      return new Set(checkedOnPage.map(s => s.id));
    });
  };

  const { data: detailData, isLoading: detailLoading } = useQuery({
    queryKey: ['task-submission', selected?.id],
    queryFn: () => interestingTaskApi.getSubmission(selected!.id),
    enabled: !!selected,
  });
  const detail: TaskSubmission | undefined = detailData?.data?.submission;

  const checkMutation = useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: Parameters<typeof interestingTaskApi.checkSubmission>[1] }) =>
      interestingTaskApi.checkSubmission(id, payload),
    onSuccess: () => {
      const sid = selected?.id;
      qc.invalidateQueries({ queryKey: ['task-submissions'] });
      if (sid != null) {
        qc.invalidateQueries({ queryKey: ['task-submission', sid] });
      }
      setSelected(null);
      toast.success(t('common.save_success'));
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('toast.error_generic')));
    },
  });

  const visibilityMutation = useMutation({
    mutationFn: ({ id, result_visible }: { id: number; result_visible: boolean }) =>
      interestingTaskApi.updateSubmissionVisibility(id, result_visible),
    onSuccess: (_res, variables) => {
      qc.invalidateQueries({ queryKey: ['task-submissions'] });
      if (selected?.id != null) {
        qc.invalidateQueries({ queryKey: ['task-submission', selected.id] });
      }
      toast.success(
        variables.result_visible
          ? t('submissions.toast_visibility_shown')
          : t('submissions.toast_visibility_hidden'),
      );
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('toast.error_generic')));
    },
  });

  const resetMutation = useMutation({
    mutationFn: (id: number) => interestingTaskApi.resetSubmission(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['task-submissions'] });
      setConfirmReset(null);
      toast.success(t('submissions.toast_reset_done'));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => interestingTaskApi.deleteSubmission(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['task-submissions'] });
      setConfirmDelete(null);
      toast.success(t('submissions.toast_deleted'));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const bulkResetMutation = useMutation({
    mutationFn: (ids: number[]) => interestingTaskApi.bulkResetSubmissions(ids),
    onSuccess: (res) => {
      qc.invalidateQueries({ queryKey: ['task-submissions'] });
      setSelectedIds(new Set());
      setConfirmBulkReset(false);
      const n = (res as { data?: { reset?: number } } | undefined)?.data?.reset ?? 0;
      toast.success(t('submissions.toast_bulk_reset_done', { count: n }));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const bulkDeleteMutation = useMutation({
    mutationFn: (ids: number[]) => interestingTaskApi.bulkDeleteSubmissions(ids),
    onSuccess: (res) => {
      qc.invalidateQueries({ queryKey: ['task-submissions'] });
      setSelectedIds(new Set());
      setConfirmBulkDelete(false);
      const n = (res as { data?: { deleted?: number } } | undefined)?.data?.deleted ?? 0;
      toast.success(t('submissions.toast_bulk_delete_done', { count: n }));
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const bulkVisibilityMutation = useMutation({
    mutationFn: ({ ids, result_visible }: { ids: number[]; result_visible: boolean }) =>
      interestingTaskApi.bulkUpdateSubmissionVisibility(ids, result_visible),
    onSuccess: (res, variables) => {
      qc.invalidateQueries({ queryKey: ['task-submissions'] });
      setSelectedIds(new Set());
      const payload = res as { data?: { updated?: number } } | undefined;
      const updated =
        typeof payload?.data?.updated === 'number' ? payload.data.updated : variables.ids.length;
      if (updated < 1) {
        toast.info(t('submissions.toast_bulk_none'));
        return;
      }
      toast.success(
        variables.result_visible
          ? t('submissions.toast_bulk_shown', { count: updated })
          : t('submissions.toast_bulk_hidden', { count: updated }),
      );
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('toast.error_generic')));
    },
  });

  const openDetail = (sub: TaskSubmission) => {
    setSelected(sub);
    setTeacherComment(sub.teacher_comment ?? '');
    setResultVisible(sub.result_visible);
    setAnswerEdits({});
  };

  const autoEditForAnswer = (ans: TaskAnswer) => {
    const auto = ans.auto_check;
    if (!auto?.supported) return null;
    return {
      is_correct: auto.is_correct ?? undefined,
      score: typeof auto.score === 'number' ? auto.score : 0,
      teacher_comment: auto.reason || ans.teacher_comment || '',
    };
  };

  const applyAutoToAllAnswers = () => {
    const answers = detail?.answers ?? [];
    if (!answers.length) return;
    setAnswerEdits(() => {
      const next: Record<number, { is_correct?: boolean; score: number; teacher_comment: string }> = {};
      for (const ans of answers) {
        const autoEdit = autoEditForAnswer(ans);
        if (!autoEdit) continue;
        next[ans.id] = autoEdit;
      }
      return next;
    });
  };

  useEffect(() => {
    if (!detail?.answers?.length) return;
    if (Object.keys(answerEdits).length > 0) return;
    applyAutoToAllAnswers();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [detail?.id, detail?.answers?.length]);

  const handleSaveCheck = () => {
    if (!selected) return;
    if (!detail?.answers?.length) {
      toast.error(t('submissions.save_no_answers'));
      return;
    }
    /** Har bir savol uchun joriy UI qiymatlari (faqat o'zgartirilganlar emas) — bo'sh payload 422/yoki "saqlanmadi" hissini berardi */
    const answersPayload = detail.answers.map((ans) => {
      const ed = getAnswerEdit(ans);
      const rawScore = ed.score;
      const score = typeof rawScore === 'number' && Number.isFinite(rawScore)
        ? Math.max(0, Math.min(100, Math.trunc(rawScore)))
        : 0;
      const isCorrect = ed.is_correct;
      return {
        id: ans.id,
        is_correct: isCorrect === undefined ? null : isCorrect,
        score,
        teacher_comment: ed.teacher_comment?.trim() ? ed.teacher_comment.trim() : null,
      };
    });
    checkMutation.mutate({
      id: selected.id,
      payload: {
        teacher_comment: teacherComment || undefined,
        result_visible: resultVisible,
        use_auto_grading: true,
        answers: answersPayload,
      },
    });
  };

  const getAnswerEdit = (answer: TaskAnswer) => ({
    is_correct: answerEdits[answer.id]?.is_correct ?? answer.is_correct ?? undefined,
    score: answerEdits[answer.id]?.score ?? answer.score,
    teacher_comment: answerEdits[answer.id]?.teacher_comment ?? answer.teacher_comment ?? '',
  });

  const renderStudentAnswer = (ans: TaskAnswer): ReactNode => {
    const qt = ans.question?.question_type ?? 'text';
    if (qt === 'match') {
      try {
        const raw = JSON.parse(ans.answer_text) as { pairs?: [number, number][] };
        const pairs = raw.pairs ?? [];
        const md = ans.question?.match_data as { left?: string[]; right?: string[] } | null;
        const left = md?.left ?? [];
        const right = md?.right ?? [];
        if (!pairs.length) {
          return <p className="text-sm text-app-primary whitespace-pre-wrap">{ans.answer_text}</p>;
        }
        return (
          <ul className="text-sm text-app-primary list-none space-y-1.5">
            {pairs.map(([li, ri], idx) => (
              <li key={idx} className="flex flex-wrap gap-1">
                <span className="font-medium text-purple-400">{left[li] ?? `[${li}]`}</span>
                <span className="text-app-muted">—</span>
                <span>{right[ri] ?? `[${ri}]`}</span>
              </li>
            ))}
          </ul>
        );
      } catch {
        return <p className="text-sm text-app-primary whitespace-pre-wrap">{ans.answer_text}</p>;
      }
    }
    if (qt === 'word_search') {
      try {
        const raw = JSON.parse(ans.answer_text) as { found_ids?: number[] };
        const foundIds = new Set((raw.found_ids ?? []).map(Number));
        const md = ans.question?.match_data as { clues?: Array<{ id: number; formula: string; common_name: string }> } | null;
        const clues = md?.clues ?? [];
        if (!clues.length) {
          return <p className="text-sm text-app-primary whitespace-pre-wrap">{ans.answer_text}</p>;
        }
        return (
          <div className="space-y-2">
            <p className="text-xs text-emerald-300">Topilganlari: {foundIds.size}/{clues.length}</p>
            <ul className="space-y-2">
              {clues.map((clue) => {
                const ok = foundIds.has(clue.id);
                return (
                  <li
                    key={clue.id}
                    className={[
                      'rounded-lg border px-3 py-2 text-sm',
                      ok ? 'border-emerald-400/40 bg-emerald-500/10' : 'border-white/10 bg-white/5',
                    ].join(' ')}
                  >
                    <div className="flex items-center gap-2">
                      <span className={ok ? 'text-emerald-300' : 'text-app-muted'}>{ok ? '✓' : '•'}</span>
                      <span className="font-semibold text-purple-300">{clue.formula}</span>
                    </div>
                    {clue.common_name ? (
                      <p className="mt-0.5 text-xs text-app-muted">{clue.common_name}</p>
                    ) : null}
                  </li>
                );
              })}
            </ul>
          </div>
        );
      } catch {
        return <p className="text-sm text-app-primary whitespace-pre-wrap">{ans.answer_text}</p>;
      }
    }
    if (qt === 'matrix_classification') {
      try {
        const raw = JSON.parse(ans.answer_text) as {
          method?: Record<string, string>;
          order?: Record<string, number>;
        };
        const methodMap = raw.method ?? {};
        const orderMap = raw.order ?? {};
        const md = ans.question?.match_data as { rows?: Array<{ id: number; text: string }> } | null;
        const rows = md?.rows ?? [];
        if (!rows.length) {
          return <p className="text-sm text-app-primary whitespace-pre-wrap">{ans.answer_text}</p>;
        }
        const methodLabel = (m?: string) =>
          m === 'solve' ? 'Solve' : m === 'ammonia' ? 'Ammiakli' : m === 'none' ? 'Tegishli emas' : '—';
        return (
          <ul className="space-y-2 text-sm">
            {rows.map((row, idx) => (
              <li key={row.id} className="rounded-lg border border-white/10 bg-white/5 px-3 py-2">
                <p className="text-app-primary font-medium">{idx + 1}. {row.text}</p>
                <p className="mt-1 text-xs text-app-muted">
                  Usul: <span className="text-purple-300">{methodLabel(methodMap[String(row.id)])}</span>
                  {' · '}
                  Ketma-ketlik: <span className="text-purple-300">{orderMap[String(row.id)] ?? '—'}</span>
                </p>
              </li>
            ))}
          </ul>
        );
      } catch {
        return <p className="text-sm text-app-primary whitespace-pre-wrap">{ans.answer_text}</p>;
      }
    }
    return <p className="text-sm text-app-primary whitespace-pre-wrap">{ans.answer_text}</p>;
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div>
        <h1 className="text-3xl font-bold text-app-primary">{t('submissions.title')}</h1>
        <p className="text-app-muted mt-1">{t('submissions.subtitle')}</p>
      </div>

      {/* Filtrlar paneli */}
      <GlassCard className="space-y-4 py-5">
        <h2 className="text-xs font-bold uppercase tracking-widest text-app-muted">{t('submissions.filters_title')}</h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {/* O'quv yili */}
          <div className="space-y-1.5">
            <label className="text-sm font-medium text-app-subtle">{t('submissions.filter_academic_year')}</label>
            <select
              value={filterYear}
              onChange={e => setFilterYear(e.target.value)}
              className="input-glass w-full"
            >
              {years.map(y => (
                <option key={y} value={y}>
                  {y} (09.01–05.25)
                </option>
              ))}
            </select>
          </div>
          {/* Maktab */}
          <div className="space-y-1.5">
            <label className="text-sm font-medium text-app-subtle">{t('submissions.filter_school')}</label>
            <select
              value={filterSchoolId}
              onChange={e => setFilterSchoolId(e.target.value)}
              className="input-glass w-full"
            >
              <option value="">{t('submissions.filter_all_schools')}</option>
              {schoolsForSelect.map(s => (
                <option key={s.id} value={String(s.id)}>{s.selectLabel}</option>
              ))}
            </select>
          </div>
          {/* Topshiriq */}
          <div className="space-y-1.5">
            <label className="text-sm font-medium text-app-subtle">{t('submissions.col_task')}</label>
            <select
              value={filterTaskId}
              onChange={e => setFilterTaskId(e.target.value)}
              className="input-glass w-full"
              aria-label={t('submissions.filter_by_task_aria')}
            >
              <option value="">{t('submissions.filter_all_tasks')}</option>
              {tasksSorted.map(task => (
                <option key={task.id} value={String(task.id)}>
                  {task.title}
                </option>
              ))}
            </select>
          </div>
          {/* Holat */}
          <div className="space-y-1.5">
            <label className="text-sm font-medium text-app-subtle">{t('submissions.col_status')}</label>
            <select
              value={filterStatus}
              onChange={e => setFilterStatus(e.target.value)}
              className="input-glass w-full"
            >
              <option value="">{t('submissions.filter_all')}</option>
              <option value="pending">{t('submissions.filter_pending')}</option>
              <option value="checked">{t('submissions.filter_checked')}</option>
            </select>
          </div>
        </div>
      </GlassCard>

      <GlassCard className="overflow-hidden p-0">
        {selectedIds.size > 0 && (
          <div className="flex flex-wrap items-center gap-3 border-b border-white/10 px-4 py-3 sm:px-6 bg-white/[0.03] dark:bg-black/20">
            <span className="text-sm text-app-primary font-medium">
              {t('submissions.bulk_selected', { count: selectedIds.size })}
            </span>
            <div className="flex flex-wrap items-center gap-2 ml-auto">
              <button
                type="button"
                className="text-sm py-2 px-4 rounded-lg font-medium bg-emerald-600/90 hover:bg-emerald-600 text-white transition-colors disabled:opacity-50"
                disabled={bulkVisibilityMutation.isPending}
                onClick={() =>
                  bulkVisibilityMutation.mutate({ ids: [...selectedIds], result_visible: true })
                }
              >
                {t('submissions.bulk_show')}
              </button>
              <button
                type="button"
                className="text-sm py-2 px-4 rounded-lg font-medium bg-white/15 hover:bg-white/20 text-app-primary transition-colors disabled:opacity-50"
                disabled={bulkVisibilityMutation.isPending}
                onClick={() =>
                  bulkVisibilityMutation.mutate({ ids: [...selectedIds], result_visible: false })
                }
              >
                {t('submissions.bulk_hide')}
              </button>
              <span className="h-5 w-px bg-white/15 mx-1" />
              <button
                type="button"
                className="flex items-center gap-1.5 text-sm py-2 px-4 rounded-lg font-medium bg-amber-600/80 hover:bg-amber-600 text-white transition-colors disabled:opacity-50"
                disabled={bulkResetMutation.isPending || bulkDeleteMutation.isPending}
                onClick={() => setConfirmBulkReset(true)}
              >
                <RotateCcw className="w-3.5 h-3.5" />
                {t('submissions.bulk_reset')}
              </button>
              <button
                type="button"
                className="flex items-center gap-1.5 text-sm py-2 px-4 rounded-lg font-medium bg-red-600/80 hover:bg-red-600 text-white transition-colors disabled:opacity-50"
                disabled={bulkDeleteMutation.isPending || bulkResetMutation.isPending}
                onClick={() => setConfirmBulkDelete(true)}
              >
                <Trash2 className="w-3.5 h-3.5" />
                {t('submissions.bulk_delete')}
              </button>
              <button
                type="button"
                className="text-sm py-2 px-3 text-app-muted hover:text-app-primary transition-colors"
                disabled={bulkVisibilityMutation.isPending}
                onClick={() => setSelectedIds(new Set())}
              >
                {t('submissions.bulk_clear')}
              </button>
            </div>
          </div>
        )}
        <div className="overflow-x-auto">
          <table className="data-table-shell w-full text-left border-collapse">
            <thead>
              <tr>
                <th className="px-3 py-4 w-12 align-middle">
                  <input
                    ref={selectAllRef}
                    type="checkbox"
                    className="w-4 h-4 accent-purple-500 rounded border-white/20"
                    checked={allCheckedSelected}
                    disabled={checkedOnPage.length === 0}
                    onChange={toggleSelectAllChecked}
                    aria-label={t('submissions.select_all_aria')}
                  />
                </th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('submissions.col_student')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('submissions.col_task')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('submissions.col_status')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('submissions.col_score')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('submissions.col_visible')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle">{t('submissions.col_date')}</th>
                <th className="px-6 py-4 text-sm font-semibold text-app-subtle text-right">{t('common.actions')}</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr><td colSpan={8} className="px-6 py-10 text-center"><Loader2 className="w-8 h-8 animate-spin mx-auto text-purple-500" /></td></tr>
              ) : submissions.length === 0 ? (
                <tr><td colSpan={8} className="px-6 py-10 text-center text-app-muted">{t('submissions.empty')}</td></tr>
              ) : submissions.map(sub => (
                <tr key={sub.id} className="group">
                  <td className="px-3 py-4 align-middle">
                    {sub.status === 'checked' ? (
                      <input
                        type="checkbox"
                        className="w-4 h-4 accent-purple-500 rounded border-white/20"
                        checked={selectedIds.has(sub.id)}
                        onChange={() => toggleSelectRow(sub.id)}
                        aria-label={t('submissions.select_row_aria')}
                      />
                    ) : (
                      <span className="inline-block w-4 h-4" aria-hidden />
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <div className="font-medium text-app-primary">{sub.student_name}</div>
                    {sub.student_email && <div className="text-xs text-app-muted">{sub.student_email}</div>}
                  </td>
                  <td className="px-6 py-4 text-sm text-app-muted">{sub.task?.title ?? `#${sub.task_id}`}</td>
                  <td className="px-6 py-4">
                    {sub.status === 'checked' ? (
                      <span className="flex items-center gap-1.5 text-emerald-500 text-xs font-semibold">
                        <CheckCircle className="w-3.5 h-3.5" />{t('submissions.status_checked')}
                      </span>
                    ) : (
                      <span className="flex items-center gap-1.5 text-amber-500 text-xs font-semibold">
                        <Clock className="w-3.5 h-3.5" />{t('submissions.status_pending')}
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 text-sm font-bold text-purple-400">{sub.total_score}</td>
                  <td className="px-6 py-4">
                    {sub.status === 'checked' ? (
                      <div
                        className="flex items-center gap-2 flex-shrink-0"
                        title={sub.result_visible ? t('submissions.visible') : t('submissions.hidden')}
                      >
                        <span className="text-[11px] text-app-muted hidden sm:inline max-w-[4rem] text-right leading-tight">
                          {sub.result_visible ? t('submissions.visible') : t('submissions.hidden')}
                        </span>
                        <button
                          type="button"
                          role="switch"
                          aria-checked={sub.result_visible}
                          aria-label={
                            sub.result_visible
                              ? t('submissions.visibility_aria_hide')
                              : t('submissions.visibility_aria_show')
                          }
                          disabled={
                            visibilityMutation.isPending &&
                            visibilityMutation.variables?.id === sub.id
                          }
                          onClick={(e) => {
                            e.stopPropagation();
                            visibilityMutation.mutate({
                              id: sub.id,
                              result_visible: !sub.result_visible,
                            });
                          }}
                          className={[
                            'relative h-7 w-12 shrink-0 rounded-full transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500/70 focus-visible:ring-offset-2 focus-visible:ring-offset-transparent disabled:opacity-50',
                            sub.result_visible ? 'bg-emerald-500/90' : switchInactiveTrackCn,
                          ].join(' ')}
                        >
                          <span
                            className={[
                              'absolute top-0.5 flex h-6 w-6 items-center justify-center rounded-full bg-white shadow-md transition-transform duration-200',
                              sub.result_visible ? 'translate-x-5' : 'translate-x-0.5',
                            ].join(' ')}
                          />
                        </button>
                      </div>
                    ) : (
                      <span
                        className="text-xs text-app-muted/70 tabular-nums"
                        title={t('submissions.visibility_after_check')}
                      >
                        —
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 text-sm text-app-muted">
                    {new Date(sub.created_at).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        title={t('submissions.action_reset')}
                        onClick={() =>
                          setConfirmReset({ id: sub.id, name: sub.student_name ?? String(sub.id) })
                        }
                        className="p-1.5 rounded-md text-amber-400 hover:text-amber-300 hover:bg-amber-500/10 transition-colors"
                      >
                        <RotateCcw className="w-4 h-4" />
                      </button>
                      <button
                        title={t('submissions.action_delete')}
                        onClick={() =>
                          setConfirmDelete({ id: sub.id, name: sub.student_name ?? String(sub.id) })
                        }
                        className="p-1.5 rounded-md text-red-400 hover:text-red-300 hover:bg-red-500/10 transition-colors"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => openDetail(sub)}
                        className="flex items-center gap-1 text-sm text-purple-400 hover:text-purple-300 font-medium transition-colors"
                      >
                        {t('submissions.check_btn')}
                        <ChevronRight className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </GlassCard>

      {/* Detail / Check Modal */}
      <GlassModal
        isOpen={!!selected}
        onClose={() => setSelected(null)}
        title={`${t('submissions.check_title')} — ${selected?.student_name}`}
        className="max-h-[min(92vh,56rem)] max-w-[min(96vw,80rem)] min-h-0 min-w-0 w-full flex flex-col overflow-hidden"
      >
        {detailLoading ? (
          <div className="flex justify-center py-8"><Loader2 className="w-8 h-8 animate-spin text-purple-500" /></div>
        ) : detail ? (
          <div className="min-h-0 flex-1 space-y-6 overflow-y-auto overflow-x-hidden overscroll-contain pr-1 scrollbar-none">
            {/* Info */}
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div className="glass rounded-xl p-3">
                <span className="text-app-muted">{t('submissions.col_task')}: </span>
                <span className="font-medium">{detail.task?.title}</span>
              </div>
              <div className="glass rounded-xl p-3">
                <span className="text-app-muted">{t('submissions.col_status')}: </span>
                <span className={`font-medium ${detail.status === 'checked' ? 'text-emerald-500' : 'text-amber-500'}`}>
                  {detail.status === 'checked' ? t('submissions.status_checked') : t('submissions.status_pending')}
                </span>
              </div>
            </div>

            {/* Answers */}
            <div className="space-y-4">
              <div className="flex items-center justify-between gap-3">
                <h3 className="font-semibold text-app-primary">{t('submissions.answers_title')}</h3>
                <button
                  type="button"
                  onClick={applyAutoToAllAnswers}
                  className="text-xs px-3 py-1.5 rounded-lg border border-purple-400/40 text-purple-300 hover:bg-purple-500/10 transition-colors"
                >
                  {t('submissions.auto_fill')}
                </button>
              </div>
              {detail.answers?.map((ans) => {
                const edit = getAnswerEdit(ans);
                const auto = ans.auto_check;
                return (
                  <div key={ans.id} className="glass rounded-xl p-4 space-y-3">
                    {ans.question?.question_type === 'image' && ans.question.image_url && (
                      <img
                        src={ans.question.image_url}
                        alt=""
                        className="max-h-40 rounded-lg border border-white/10 object-contain"
                      />
                    )}
                    <p className="text-sm font-semibold text-purple-400">{ans.question?.body}</p>
                    <div className="bg-black/10 dark:bg-white/5 rounded-lg p-3">
                      {renderStudentAnswer(ans)}
                    </div>
                    {auto?.supported && (
                      <div className="rounded-lg border border-emerald-400/25 bg-emerald-500/10 px-3 py-2 text-xs">
                        <p className="text-emerald-300 font-medium">
                          {t('submissions.auto_hint')}: {auto.is_correct === true
                            ? t('submissions.correct')
                            : auto.is_correct === false
                              ? t('submissions.incorrect')
                              : t('submissions.not_graded')
                          } · {t('submissions.score')}: {typeof auto.score === 'number' ? auto.score : '—'}
                        </p>
                        <p className="text-app-muted mt-1">{auto.reason}</p>
                      </div>
                    )}
                    <div className="grid grid-cols-1 gap-4 lg:grid-cols-12 lg:items-end lg:gap-4">
                      <div className="min-w-0 lg:col-span-4">
                        <label className="text-xs text-app-muted mb-1 block">{t('submissions.is_correct')}</label>
                        <select
                          value={edit.is_correct === undefined ? '' : edit.is_correct ? '1' : '0'}
                          onChange={e => setAnswerEdits(prev => ({
                            ...prev,
                            [ans.id]: { ...getAnswerEdit(ans), is_correct: e.target.value === '' ? undefined : e.target.value === '1' },
                          }))}
                          className="input-glass w-full text-sm py-2"
                        >
                          <option value="">{t('submissions.not_graded')}</option>
                          <option value="1">✓ {t('submissions.correct')}</option>
                          <option value="0">✗ {t('submissions.incorrect')}</option>
                        </select>
                      </div>
                      <div className="min-w-0 lg:col-span-2">
                        <label className="text-xs text-app-muted mb-1 block">{t('submissions.score')} (0–100)</label>
                        <input
                          type="number"
                          min={0}
                          max={100}
                          value={edit.score}
                          onChange={e => setAnswerEdits(prev => ({
                            ...prev,
                            [ans.id]: { ...getAnswerEdit(ans), score: +e.target.value },
                          }))}
                          className="input-glass w-full text-sm py-2"
                        />
                      </div>
                      <div className="min-w-0 lg:col-span-6">
                        <label className="text-xs text-app-muted mb-1 block">{t('submissions.answer_comment')}</label>
                        <input
                          type="text"
                          value={edit.teacher_comment}
                          onChange={e => setAnswerEdits(prev => ({
                            ...prev,
                            [ans.id]: { ...getAnswerEdit(ans), teacher_comment: e.target.value },
                          }))}
                          className="input-glass w-full text-sm py-2"
                          placeholder={t('submissions.comment_placeholder')}
                        />
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>

            {/* Teacher comment */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-app-subtle">{t('submissions.teacher_comment')}</label>
              <textarea
                rows={3}
                value={teacherComment}
                onChange={e => setTeacherComment(e.target.value)}
                className="input-glass resize-none"
                placeholder={t('submissions.teacher_comment_placeholder')}
              />
            </div>

            {/* Visibility toggle */}
            <label className="flex items-center gap-3 cursor-pointer glass rounded-xl p-4">
              <input
                type="checkbox"
                checked={resultVisible}
                onChange={e => setResultVisible(e.target.checked)}
                className="w-4 h-4 accent-purple-500"
              />
              <div>
                <p className="font-medium text-app-primary text-sm">{t('submissions.show_result_to_student')}</p>
                <p className="text-xs text-app-muted">{t('submissions.show_result_hint')}</p>
              </div>
              {resultVisible ? <Eye className="w-5 h-5 text-emerald-500 ml-auto" /> : <EyeOff className="w-5 h-5 text-app-muted ml-auto" />}
            </label>

            <div className="flex gap-4 pt-2">
              <button onClick={() => setSelected(null)} className="flex-1 btn-modal-secondary">{t('common.cancel')}</button>
              <button
                onClick={handleSaveCheck}
                disabled={checkMutation.isPending}
                className="flex-1 btn-primary flex items-center justify-center gap-2"
              >
                {checkMutation.isPending && <Loader2 className="w-4 h-4 animate-spin" />}
                <Star className="w-4 h-4" />
                {t('submissions.save_check')}
              </button>
            </div>
          </div>
        ) : null}
      </GlassModal>

      {/* Single reset confirm */}
      <ConfirmModal
        isOpen={!!confirmReset}
        onClose={() => setConfirmReset(null)}
        onConfirm={() => confirmReset && resetMutation.mutate(confirmReset.id)}
        title={t('submissions.confirm_reset_title')}
        message={t('submissions.confirm_reset_msg', { name: confirmReset?.name ?? '' })}
        confirmText={t('submissions.action_reset')}
        cancelText={t('common.cancel')}
        type="warning"
        isLoading={resetMutation.isPending}
      />

      {/* Single delete confirm */}
      <ConfirmModal
        isOpen={!!confirmDelete}
        onClose={() => setConfirmDelete(null)}
        onConfirm={() => confirmDelete && deleteMutation.mutate(confirmDelete.id)}
        title={t('submissions.confirm_delete_title')}
        message={t('submissions.confirm_delete_msg', { name: confirmDelete?.name ?? '' })}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      {/* Bulk reset confirm */}
      <ConfirmModal
        isOpen={confirmBulkReset}
        onClose={() => setConfirmBulkReset(false)}
        onConfirm={() => bulkResetMutation.mutate([...selectedIds])}
        title={t('submissions.confirm_reset_title')}
        message={t('submissions.confirm_bulk_reset_msg', { count: selectedIds.size })}
        confirmText={t('submissions.bulk_reset')}
        cancelText={t('common.cancel')}
        type="warning"
        isLoading={bulkResetMutation.isPending}
      />

      {/* Bulk delete confirm */}
      <ConfirmModal
        isOpen={confirmBulkDelete}
        onClose={() => setConfirmBulkDelete(false)}
        onConfirm={() => bulkDeleteMutation.mutate([...selectedIds])}
        title={t('submissions.confirm_delete_title')}
        message={t('submissions.confirm_bulk_delete_msg', { count: selectedIds.size })}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={bulkDeleteMutation.isPending}
      />
    </div>
  );
}

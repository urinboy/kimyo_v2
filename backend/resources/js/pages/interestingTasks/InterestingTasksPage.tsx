import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import {
  Plus, Edit2, Trash2, ChevronDown, ChevronUp, Loader2,
  FileQuestion, GripVertical, BookOpen,
} from 'lucide-react';
import {
  interestingTaskApi,
  type InterestingTask,
  type InterestingTaskKind,
  type TaskQuestion,
  type TaskQuestionType,
  type TaskQuestionCreatePayload,
  type TaskWordSearchData,
  type TaskMatrixData,
} from '@/api/interestingTasks';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { switchInactiveTrackCn } from '@/lib/utils';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { toast } from 'sonner';

type PageMode = InterestingTaskKind;

export default function InterestingTasksPage({ mode = 'interesting' }: { mode?: PageMode }) {
  const { t } = useTranslation();
  const qc = useQueryClient();

  const [taskModal, setTaskModal] = useState<{ open: boolean; task: InterestingTask | null }>({ open: false, task: null });
  const [deleteTask, setDeleteTask] = useState<InterestingTask | null>(null);
  const [expandedTask, setExpandedTask] = useState<number | null>(null);
  const [qModal, setQModal] = useState<{ open: boolean; taskId: number; q: TaskQuestion | null } | null>(null);
  const [deleteQ, setDeleteQ] = useState<{ taskId: number; q: TaskQuestion } | null>(null);

  const defaultTaskKind: PageMode = mode;
  const [taskForm, setTaskForm] = useState({
    title: '',
    description: '',
    sort_order: 0,
    is_active: true,
    task_kind: defaultTaskKind,
  });
  const [qBody, setQBody] = useState('');
  const [qType, setQType] = useState<TaskQuestionType>('text');
  const [matchLeft, setMatchLeft] = useState<string[]>(['', '']);
  const [matchRight, setMatchRight] = useState<string[]>(['', '']);
  const [qImage, setQImage] = useState<File | null>(null);
  const [qImageObjectUrl, setQImageObjectUrl] = useState<string | null>(null);

  const emptyWsClue = () => ({ formula: '', common_name: '', answer: '' });
  const [wsGridText, setWsGridText] = useState('');
  const [wsClues, setWsClues] = useState([emptyWsClue(), emptyWsClue()]);
  const [matrixRows, setMatrixRows] = useState<Array<{ id: number; text: string; method: 'solve' | 'ammonia' | 'none'; order: string }>>([
    { id: 1, text: '', method: 'none', order: '' },
    { id: 2, text: '', method: 'none', order: '' },
  ]);
  const [matrixSequenceEnabled, setMatrixSequenceEnabled] = useState(true);
  const [matrixSequenceLabel, setMatrixSequenceLabel] = useState("Qo‘ng‘irot soda zavodida qo‘llaniladigan soda olish usulining ketma-ketligi");
  const [matrixSequenceMaxStep, setMatrixSequenceMaxStep] = useState(20);

  useEffect(() => {
    if (!qImage) { setQImageObjectUrl(null); return; }
    const url = URL.createObjectURL(qImage);
    setQImageObjectUrl(url);
    return () => { URL.revokeObjectURL(url); };
  }, [qImage]);

  const { data, isLoading } = useQuery({
    queryKey: ['interesting-tasks', mode],
    queryFn: () => interestingTaskApi.getAll({ kind: mode }),
  });
  const tasks: InterestingTask[] = (data?.data?.tasks ?? []).filter(
    (task: InterestingTask) => (task.task_kind ?? 'interesting') === mode,
  );

  const { data: expandedData } = useQuery({
    queryKey: ['interesting-task', expandedTask],
    queryFn: () => interestingTaskApi.getOne(expandedTask!),
    enabled: !!expandedTask,
  });
  const expandedTaskData: InterestingTask | undefined = expandedData?.data?.task;

  const createTask = useMutation({
    mutationFn: interestingTaskApi.create,
    onSuccess: () => {
      toast.success(t('tasks.toast_task_created'));
      qc.invalidateQueries({ queryKey: ['interesting-tasks'], exact: false });
      closeTaskModal();
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });
  const updateTask = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) => interestingTaskApi.update(id, data),
    onSuccess: () => {
      toast.success(t('tasks.toast_task_updated'));
      qc.invalidateQueries({ queryKey: ['interesting-tasks'], exact: false });
      closeTaskModal();
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });
  const toggleTaskActive = useMutation({
    mutationFn: ({ id, is_active }: { id: number; is_active: boolean }) => interestingTaskApi.update(id, { is_active }),
    onSuccess: (_, { is_active }) => {
      qc.invalidateQueries({ queryKey: ['interesting-tasks'], exact: false });
      qc.invalidateQueries({ queryKey: ['interesting-task'] });
      toast.success(is_active ? t('tasks.toast_activated') : t('tasks.toast_deactivated'));
    },
    onError: () => toast.error(t('tasks.toast_toggle_error')),
  });
  const removeTask = useMutation({
    mutationFn: interestingTaskApi.remove,
    onSuccess: () => {
      toast.success(t('tasks.toast_task_deleted'));
      qc.invalidateQueries({ queryKey: ['interesting-tasks'], exact: false });
      setDeleteTask(null);
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.delete_error'))),
  });
  const addQ = useMutation({
    mutationFn: ({ taskId, payload }: { taskId: number; payload: TaskQuestionCreatePayload }) =>
      interestingTaskApi.addQuestion(taskId, payload),
    onSuccess: (_, { taskId }) => {
      toast.success(t('tasks.toast_question_created'));
      qc.invalidateQueries({ queryKey: ['interesting-task', taskId] });
      qc.invalidateQueries({ queryKey: ['interesting-tasks'], exact: false });
      closeQModal();
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });
  const updateQ = useMutation({
    mutationFn: ({ taskId, qId, payload }: { taskId: number; qId: number; payload: TaskQuestionCreatePayload }) =>
      interestingTaskApi.updateQuestion(taskId, qId, payload),
    onSuccess: (_, { taskId }) => {
      toast.success(t('tasks.toast_question_updated'));
      qc.invalidateQueries({ queryKey: ['interesting-task', taskId] });
      qc.invalidateQueries({ queryKey: ['interesting-tasks'], exact: false });
      closeQModal();
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });
  const removeQ = useMutation({
    mutationFn: ({ taskId, qId }: { taskId: number; qId: number }) => interestingTaskApi.removeQuestion(taskId, qId),
    onSuccess: (_, { taskId }) => {
      toast.success(t('tasks.toast_question_deleted'));
      qc.invalidateQueries({ queryKey: ['interesting-task', taskId] });
      qc.invalidateQueries({ queryKey: ['interesting-tasks'], exact: false });
      setDeleteQ(null);
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.delete_error'))),
  });

  const openTaskModal = (task: InterestingTask | null = null) => {
    setTaskForm(task
      ? {
          title: task.title,
          description: task.description ?? '',
          sort_order: task.sort_order,
          is_active: task.is_active,
          task_kind: task.task_kind ?? defaultTaskKind,
        }
      : { title: '', description: '', sort_order: 0, is_active: true, task_kind: defaultTaskKind });
    setTaskModal({ open: true, task });
  };
  const closeTaskModal = () => setTaskModal({ open: false, task: null });

  const closeQModal = () => {
    setQModal(null);
    setQImage(null);
    setWsGridText('');
    setWsClues([emptyWsClue(), emptyWsClue()]);
    setMatrixRows([
      { id: 1, text: '', method: 'none', order: '' },
      { id: 2, text: '', method: 'none', order: '' },
    ]);
    setMatrixSequenceEnabled(true);
    setMatrixSequenceLabel("Qo‘ng‘irot soda zavodida qo‘llaniladigan soda olish usulining ketma-ketligi");
    setMatrixSequenceMaxStep(20);
  };

  const openQModal = (taskId: number, q: TaskQuestion | null = null) => {
    setQBody(q?.body ?? '');
    const type = (q?.question_type ?? 'text') as TaskQuestionType;
    setQType(type);
    setQImage(null);
    const md = q?.match_data as any;
    setMatchLeft(md?.left?.length ? [...md.left] : ['', '']);
    setMatchRight(md?.right?.length ? [...md.right] : ['', '']);
    if (type === 'word_search') {
      const ws = md as TaskWordSearchData | null;
      setWsGridText(ws?.grid?.length ? ws.grid.map((r: string[]) => r.join(' ')).join('\n') : '');
      setWsClues(ws?.clues?.length
        ? ws.clues.map((c) => ({ formula: c.formula, common_name: c.common_name, answer: c.answer }))
        : [emptyWsClue(), emptyWsClue()]);
      setMatrixRows([
        { id: 1, text: '', method: 'none', order: '' },
        { id: 2, text: '', method: 'none', order: '' },
      ]);
      setMatrixSequenceEnabled(true);
      setMatrixSequenceLabel("Qo‘ng‘irot soda zavodida qo‘llaniladigan soda olish usulining ketma-ketligi");
      setMatrixSequenceMaxStep(20);
    } else if (type === 'matrix_classification') {
      const m = md as TaskMatrixData | null;
      const mRows = m?.rows?.length ? m.rows : [{ id: 1, text: '' }, { id: 2, text: '' }];
      const methodMap = m?.answer_key?.method ?? {};
      const orderMap = m?.answer_key?.order ?? {};
      setMatrixRows(
        mRows.map((r, idx) => ({
          id: r.id ?? idx + 1,
          text: r.text ?? '',
          method: (methodMap[String(r.id)] ?? 'none') as 'solve' | 'ammonia' | 'none',
          order: orderMap[String(r.id)] != null ? String(orderMap[String(r.id)]) : '',
        })),
      );
      setMatrixSequenceEnabled(m?.sequence?.enabled ?? true);
      setMatrixSequenceLabel(m?.sequence?.label ?? "Qo‘ng‘irot soda zavodida qo‘llaniladigan soda olish usulining ketma-ketligi");
      setMatrixSequenceMaxStep(m?.sequence?.max_step ?? 20);
      setWsGridText('');
      setWsClues([emptyWsClue(), emptyWsClue()]);
    } else {
      setWsGridText('');
      setWsClues([emptyWsClue(), emptyWsClue()]);
      setMatrixRows([
        { id: 1, text: '', method: 'none', order: '' },
        { id: 2, text: '', method: 'none', order: '' },
      ]);
      setMatrixSequenceEnabled(true);
      setMatrixSequenceLabel("Qo‘ng‘irot soda zavodida qo‘llaniladigan soda olish usulining ketma-ketligi");
      setMatrixSequenceMaxStep(20);
    }
    setQModal({ open: true, taskId, q });
  };

  const handleTaskSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = { ...taskForm, task_kind: defaultTaskKind };
    if (taskModal.task) updateTask.mutate({ id: taskModal.task.id, data: payload });
    else createTask.mutate(payload);
  };

  const addMatchRow = () => { setMatchLeft((a) => [...a, '']); setMatchRight((a) => [...a, '']); };
  const removeMatchRow = (i: number) => {
    setMatchLeft((a) => (a.length <= 2 ? a : a.filter((_, j) => j !== i)));
    setMatchRight((a) => (a.length <= 2 ? a : a.filter((_, j) => j !== i)));
  };
  const addMatrixRow = () => {
    setMatrixRows((a) => [...a, { id: (a[a.length - 1]?.id ?? 0) + 1, text: '', method: 'none', order: '' }]);
  };
  const removeMatrixRow = (idx: number) => {
    setMatrixRows((a) => (a.length <= 2 ? a : a.filter((_, i) => i !== idx)));
  };

  const parseWsGrid = (text: string): string[][] =>
    text.split('\n').map((r) => r.trim()).filter(Boolean)
      .map((r) => r.split(/\s+/).filter(Boolean));

  const handleQSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!qModal) return;
    const { taskId, q } = qModal;

    if (qType === 'match') {
      const ml = matchLeft.map((s) => s.trim());
      const mr = matchRight.map((s) => s.trim());
      if (ml.length !== mr.length || ml.length < 2) { toast.error(t('tasks.question_match_hint')); return; }
      if (ml.some((s) => !s) || mr.some((s) => !s)) { toast.error(t('tasks.question_match_fill_rows')); return; }
    }

    if (qType === 'word_search') {
      const grid = parseWsGrid(wsGridText);
      if (grid.length < 2) { toast.error(t('tasks.question_ws_error_no_grid')); return; }
      const validClues = wsClues.filter((c) => c.formula.trim() && c.common_name.trim() && c.answer.trim());
      if (validClues.length === 0) { toast.error(t('tasks.question_ws_error_no_clues')); return; }
      const payload: TaskQuestionCreatePayload = {
        body: qBody,
        question_type: 'word_search',
        word_search_grid: grid,
        word_search_clues: validClues.map((c) => ({
          formula: c.formula.trim(),
          common_name: c.common_name.trim(),
          answer: c.answer.trim().toUpperCase(),
        })),
      };
      if (q) updateQ.mutate({ taskId, qId: q.id, payload });
      else addQ.mutate({ taskId, payload });
      return;
    }

    if (qType === 'matrix_classification') {
      const normalizedRows = matrixRows
        .map((r, idx) => ({
          id: r.id || idx + 1,
          text: r.text.trim(),
          method: r.method,
          order: r.order.trim(),
        }))
        .filter((r) => r.text);

      if (normalizedRows.length < 2) {
        toast.error(t('tasks.question_matrix_error_rows'));
        return;
      }

      const answerMethod: Record<string, 'solve' | 'ammonia' | 'none'> = {};
      const answerOrder: Record<string, number> = {};
      for (const row of normalizedRows) {
        answerMethod[String(row.id)] = row.method;
        if (row.order) {
          const n = Number(row.order);
          if (!Number.isFinite(n) || n < 1) {
            toast.error(t('tasks.question_matrix_error_order'));
            return;
          }
          answerOrder[String(row.id)] = n;
        }
      }

      const payload: TaskQuestionCreatePayload = {
        body: qBody,
        question_type: 'matrix_classification',
        matrix_data: {
          rows: normalizedRows.map((r) => ({ id: r.id, text: r.text })),
          method_columns: [
            { key: 'solve', label: 'Solve usuli' },
            { key: 'ammonia', label: 'Ammiakli usul' },
          ],
          sequence: {
            enabled: matrixSequenceEnabled,
            label: matrixSequenceLabel.trim() || t('tasks.question_matrix_sequence_label_default'),
            max_step: Math.max(1, Number(matrixSequenceMaxStep) || 20),
          },
          answer_key: {
            method: answerMethod,
            order: answerOrder,
          },
        },
      };
      if (q) updateQ.mutate({ taskId, qId: q.id, payload });
      else addQ.mutate({ taskId, payload });
      return;
    }

    const needsNewImage = qType === 'image' && !q;
    const missingImageOnEdit = qType === 'image' && q && !q.image_url && !qImage;
    if (needsNewImage && !qImage) { toast.error(t('tasks.question_image_required')); return; }
    if (missingImageOnEdit) { toast.error(t('tasks.question_image_required')); return; }

    const ml = matchLeft.map((s) => s.trim());
    const mr = matchRight.map((s) => s.trim());
    let payload: TaskQuestionCreatePayload;
    if (qType === 'image' && !!qImage) {
      const fd = new FormData();
      fd.append('body', qBody);
      fd.append('question_type', qType);
      fd.append('image', qImage!);
      payload = fd;
    } else {
      payload = { body: qBody, question_type: qType, ...(qType === 'match' ? { match_left: ml, match_right: mr } : {}) };
    }
    if (q) updateQ.mutate({ taskId, qId: q.id, payload });
    else addQ.mutate({ taskId, payload });
  };

  const questionTypeBadge = (qt: TaskQuestionType | undefined) => {
    if (qt === 'image') return t('tasks.question_badge_image');
    if (qt === 'match') return t('tasks.question_badge_match');
    if (qt === 'word_search') return t('tasks.question_badge_word_search');
    if (qt === 'matrix_classification') return t('tasks.question_badge_matrix');
    return t('tasks.question_badge_text');
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{mode === 'project' ? t('tasks.title_projects') : t('tasks.title')}</h1>
          <p className="text-app-muted mt-1">{mode === 'project' ? t('tasks.subtitle_projects') : t('tasks.subtitle')}</p>
        </div>
        <button onClick={() => openTaskModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />{t('tasks.add_button')}
        </button>
      </div>

      <GlassCard className="overflow-hidden p-0">
        {isLoading ? (
          <div className="flex items-center justify-center py-16"><Loader2 className="w-8 h-8 animate-spin text-purple-500" /></div>
        ) : tasks.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 text-app-muted gap-3">
            <BookOpen className="w-12 h-12 opacity-30" /><p>{mode === 'project' ? t('tasks.empty_projects') : t('tasks.empty')}</p>
          </div>
        ) : (
          <div className="divide-y divide-white/5">
            {tasks.map((task) => (
              <div key={task.id}>
                <div className="flex items-center gap-4 px-6 py-4 group">
                  <GripVertical className="w-4 h-4 text-app-muted/40 flex-shrink-0" />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className={`w-2 h-2 rounded-full flex-shrink-0 ${task.is_active ? 'bg-emerald-400' : 'bg-gray-400'}`} />
                      <span className="font-semibold text-app-primary truncate">{task.title}</span>
                    </div>
                    {task.description && <p className="text-sm text-app-muted truncate mt-0.5">{task.description}</p>}
                  </div>
                  <div className="flex items-center gap-2 flex-shrink-0" title={task.is_active ? t('tasks.toggle_hint_on') : t('tasks.toggle_hint_off')}>
                    <span className="text-xs text-app-muted hidden sm:inline max-w-[4.5rem] text-right leading-tight">
                      {task.is_active ? t('tasks.status_on') : t('tasks.status_off')}
                    </span>
                    <button
                      type="button" role="switch" aria-checked={task.is_active}
                      aria-label={task.is_active ? t('tasks.toggle_aria_on') : t('tasks.toggle_aria_off')}
                      disabled={toggleTaskActive.isPending && toggleTaskActive.variables?.id === task.id}
                      onClick={(e) => { e.stopPropagation(); toggleTaskActive.mutate({ id: task.id, is_active: !task.is_active }); }}
                      className={['relative h-7 w-12 shrink-0 rounded-full transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500/70 focus-visible:ring-offset-2 focus-visible:ring-offset-transparent disabled:opacity-50', task.is_active ? 'bg-emerald-500/90' : switchInactiveTrackCn].join(' ')}
                    >
                      <span className={['absolute top-0.5 flex h-6 w-6 items-center justify-center rounded-full bg-white shadow-md transition-transform duration-200', task.is_active ? 'translate-x-5' : 'translate-x-0.5'].join(' ')} />
                    </button>
                  </div>
                  <div className="flex items-center gap-3 text-sm text-app-muted flex-shrink-0">
                    <span className="flex items-center gap-1"><FileQuestion className="w-4 h-4" />{task.questions_count ?? 0}</span>
                    <button onClick={() => setExpandedTask(expandedTask === task.id ? null : task.id)} className="p-2 rounded-xl hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-app-primary transition-all">
                      {expandedTask === task.id ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
                    </button>
                    <button onClick={() => openTaskModal(task)} className="p-2 rounded-xl hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-app-primary transition-all"><Edit2 className="w-4 h-4" /></button>
                    <button onClick={() => setDeleteTask(task)} className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"><Trash2 className="w-4 h-4" /></button>
                  </div>
                </div>

                {expandedTask === task.id && (
                  <div className="bg-black/5 dark:bg-white/5 px-6 pb-4 pt-2">
                    <div className="flex items-center justify-between mb-3">
                      <span className="text-sm font-semibold text-app-subtle">{t('tasks.questions_title')}</span>
                      <button onClick={() => openQModal(task.id)} className="flex items-center gap-1.5 text-sm text-purple-500 hover:text-purple-400 font-medium transition-colors">
                        <Plus className="w-4 h-4" />{t('tasks.add_question')}
                      </button>
                    </div>
                    <div className="space-y-2">
                      {expandedTaskData?.questions?.map((q, idx) => (
                        <div key={q.id} className="flex items-start gap-3 p-3 rounded-xl bg-white/5 group/q">
                          <div className="flex flex-col items-start gap-1 mt-0.5 shrink-0">
                            <span className="text-xs text-purple-400 font-bold">{idx + 1}.</span>
                            <span className="text-[10px] px-1.5 py-0.5 rounded-md bg-purple-500/20 text-purple-300 font-medium">{questionTypeBadge(q.question_type)}</span>
                          </div>
                          <div className="flex-1 min-w-0">
                            {q.question_type === 'image' && q.image_url ? (
                              <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:gap-4">
                                <img src={q.image_url} alt="" className="mx-auto h-auto w-full max-w-[200px] shrink-0 rounded-lg border border-white/10 bg-black/20 object-contain sm:mx-0 sm:max-h-40" />
                                <p className="min-w-0 flex-1 text-sm text-app-primary whitespace-pre-wrap">{q.body}</p>
                              </div>
                            ) : q.question_type === 'word_search' ? (
                              <div className="space-y-1">
                                <p className="text-sm text-app-primary whitespace-pre-wrap">{q.body}</p>
                                {(() => {
                                  const ws = q.match_data as TaskWordSearchData | null;
                                  if (!ws) return null;
                                  return (
                                    <p className="text-xs text-purple-400 mt-1">
                                      Grid: {ws.grid?.length ?? 0}x{ws.grid?.[0]?.length ?? 0}
                                      {' '}&middot; {ws.clues?.length ?? 0} ta maslahat
                                      {ws.clues?.length ? ` (${ws.clues.map((c) => c.answer).join(', ')})` : ''}
                                    </p>
                                  );
                                })()}
                              </div>
                            ) : q.question_type === 'matrix_classification' ? (
                              <div className="space-y-1">
                                <p className="text-sm text-app-primary whitespace-pre-wrap">{q.body}</p>
                                {(() => {
                                  const m = q.match_data as TaskMatrixData | null;
                                  if (!m) return null;
                                  return (
                                    <p className="text-xs text-purple-400 mt-1">
                                      {t('tasks.question_matrix_rows_count').replace('{count}', String(m.rows?.length ?? 0))}
                                      {m.sequence?.enabled ? ` · ${m.sequence.label ?? t('tasks.question_matrix_sequence_short')}` : ''}
                                    </p>
                                  );
                                })()}
                              </div>
                            ) : (
                              <p className="text-sm text-app-primary whitespace-pre-wrap">{q.body}</p>
                            )}
                          </div>
                          <div className="flex gap-1 opacity-0 group-hover/q:opacity-100 transition-opacity flex-shrink-0">
                            <button type="button" onClick={() => openQModal(task.id, q)} className="p-1.5 rounded-lg hover:bg-black/10 dark:hover:bg-white/10 text-app-muted hover:text-app-primary transition-all"><Edit2 className="w-3.5 h-3.5" /></button>
                            <button type="button" onClick={() => setDeleteQ({ taskId: task.id, q })} className="p-1.5 rounded-lg hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"><Trash2 className="w-3.5 h-3.5" /></button>
                          </div>
                        </div>
                      ))}
                      {!expandedTaskData?.questions?.length && <p className="text-sm text-app-muted text-center py-4">{t('tasks.no_questions')}</p>}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </GlassCard>

      {/* Task Modal */}
      <GlassModal isOpen={taskModal.open} onClose={closeTaskModal} title={taskModal.task ? t('tasks.edit_title') : t('tasks.create_title')}>
        <form onSubmit={handleTaskSubmit} className="space-y-5">
          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('tasks.form_title')}</label>
            <input type="text" required value={taskForm.title} onChange={e => setTaskForm(p => ({ ...p, title: e.target.value }))} className="input-glass" placeholder={t('tasks.form_title_placeholder')} />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">{t('tasks.form_description')}</label>
            <textarea rows={3} value={taskForm.description} onChange={e => setTaskForm(p => ({ ...p, description: e.target.value }))} className="input-glass resize-none" placeholder={t('tasks.form_description_placeholder')} />
          </div>
          <p className="text-xs rounded-lg bg-purple-500/15 px-3 py-2 text-purple-700 dark:text-purple-300">
            {mode === 'project' ? t('tasks.kind_badge_project') : t('tasks.kind_badge_interesting')}
          </p>
          <input type="hidden" value={taskForm.task_kind} readOnly aria-hidden />
          <div className="flex gap-4">
            <div className="flex-1 space-y-2">
              <label className="text-sm font-medium text-app-subtle ml-1">{t('tasks.form_sort')}</label>
              <input type="number" min={0} value={taskForm.sort_order} onChange={e => setTaskForm(p => ({ ...p, sort_order: +e.target.value }))} className="input-glass" />
            </div>
            <div className="flex items-end pb-1">
              <label className="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" checked={taskForm.is_active} onChange={e => setTaskForm(p => ({ ...p, is_active: e.target.checked }))} className="w-4 h-4 accent-purple-500" />
                <span className="text-sm font-medium text-app-subtle">{t('common.active')}</span>
              </label>
            </div>
          </div>
          <div className="flex gap-4 pt-2">
            <button type="button" onClick={closeTaskModal} className="flex-1 btn-modal-secondary">{t('common.cancel')}</button>
            <button type="submit" disabled={createTask.isPending || updateTask.isPending} className="flex-1 btn-primary flex items-center justify-center gap-2">
              {(createTask.isPending || updateTask.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
              {taskModal.task ? t('common.save') : t('common.create')}
            </button>
          </div>
        </form>
      </GlassModal>

      {/* Question Modal */}
      <GlassModal isOpen={!!qModal?.open} onClose={closeQModal} title={qModal?.q ? t('tasks.edit_question') : t('tasks.add_question')} className="max-h-[min(92vh,60rem)] max-w-[min(96vw,80rem)] min-w-0 flex flex-col overflow-hidden">
        <form onSubmit={handleQSubmit} className="flex min-h-0 flex-1 flex-col">
          <div className="min-h-0 flex-1 space-y-5 overflow-x-hidden overflow-y-auto overscroll-contain pr-1 scrollbar-none">

            <div className="space-y-2">
              <label className="text-sm font-medium text-app-subtle ml-1">{t('tasks.question_type')}</label>
              <select value={qType} onChange={(e) => setQType(e.target.value as TaskQuestionType)} className="input-glass w-full">
                <option value="text">{t('tasks.question_type_text')}</option>
                <option value="image">{t('tasks.question_type_image')}</option>
                <option value="match">{t('tasks.question_type_match')}</option>
                <option value="word_search">{t('tasks.question_type_word_search')}</option>
                <option value="matrix_classification">{t('tasks.question_type_matrix')}</option>
              </select>
            </div>

            {qType === 'image' && (
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('tasks.question_image')}</label>
                <input type="file" accept="image/*" className="block w-full text-sm text-app-muted file:mr-3 file:rounded-lg file:border-0 file:bg-purple-500/20 file:px-3 file:py-2 file:text-sm file:font-medium file:text-purple-200" onChange={(e) => setQImage(e.target.files?.[0] ?? null)} />
                <p className="text-xs text-app-muted">{t('tasks.question_image_hint')}</p>
                {(qImageObjectUrl || (qModal?.q?.image_url && !qImage)) && (
                  <div className="space-y-1 rounded-xl border border-white/10 bg-black/20 p-3">
                    <p className="text-xs text-app-muted">{t('tasks.question_image_preview')}</p>
                    <img src={qImageObjectUrl ?? qModal?.q?.image_url ?? ''} alt="" className="mx-auto max-h-56 w-full max-w-full rounded-lg object-contain" />
                  </div>
                )}
              </div>
            )}

            <div className="space-y-2">
              <label className="text-sm font-medium text-app-subtle ml-1">{t('tasks.question_body')}</label>
              <textarea rows={qType === 'word_search' ? 3 : 5} required value={qBody} onChange={(e) => setQBody(e.target.value)} className="input-glass min-w-0 resize-none break-words" placeholder={t('tasks.question_body_placeholder')} />
            </div>

            {qType === 'match' && (
              <div className="min-w-0 space-y-4 rounded-xl border border-white/10 bg-black/10 p-4">
                <p className="text-xs text-app-muted">{t('tasks.question_match_hint')}</p>
                <div className="grid min-w-0 grid-cols-1 gap-4 sm:grid-cols-2">
                  <div className="min-w-0 space-y-2">
                    <span className="text-sm font-medium text-app-subtle">{t('tasks.question_match_left')}</span>
                    <div className="space-y-2">
                      {matchLeft.map((row, i) => (
                        <div key={`ml-${i}`} className="flex min-w-0 gap-2">
                          <span className="w-7 shrink-0 pt-2 text-xs text-app-muted">{i + 1}</span>
                          <textarea rows={2} value={row} onChange={(e) => setMatchLeft((a) => a.map((v, j) => (j === i ? e.target.value : v)))} className="input-glass min-h-[2.5rem] min-w-0 flex-1 resize-none break-words text-sm" placeholder={`${t('tasks.question_match_row')} ${i + 1}`} />
                        </div>
                      ))}
                    </div>
                  </div>
                  <div className="min-w-0 space-y-2">
                    <span className="text-sm font-medium text-app-subtle">{t('tasks.question_match_right')}</span>
                    <div className="space-y-2">
                      {matchRight.map((row, i) => (
                        <div key={`mr-${i}`} className="flex min-w-0 gap-2">
                          <span className="w-7 shrink-0 pt-2 text-xs text-app-muted">{i + 1}</span>
                          <textarea rows={2} value={row} onChange={(e) => setMatchRight((a) => a.map((v, j) => (j === i ? e.target.value : v)))} className="input-glass min-h-[2.5rem] min-w-0 flex-1 resize-none break-words text-sm" placeholder={`${t('tasks.question_match_row')} ${i + 1}`} />
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
                <div className="flex flex-wrap gap-2">
                  <button type="button" onClick={addMatchRow} className="rounded-lg bg-purple-500/20 px-3 py-1.5 text-sm font-medium text-purple-200 hover:bg-purple-500/30">{t('tasks.question_match_add_row')}</button>
                  {matchLeft.length > 2 && (
                    <button type="button" onClick={() => removeMatchRow(matchLeft.length - 1)} className="rounded-lg bg-white/10 px-3 py-1.5 text-sm text-app-muted hover:bg-white/15">{t('tasks.question_match_remove_row')}</button>
                  )}
                </div>
              </div>
            )}

            {qType === 'word_search' && (
              <div className="min-w-0 space-y-5 rounded-xl border border-purple-500/20 bg-purple-500/5 p-4">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('tasks.question_ws_grid_label')}</label>
                  <p className="text-xs text-app-muted leading-relaxed">{t('tasks.question_ws_grid_hint')}</p>
                  <textarea rows={8} value={wsGridText} onChange={(e) => setWsGridText(e.target.value)} className="input-glass w-full resize-y font-mono text-sm" placeholder={t('tasks.question_ws_grid_placeholder')} spellCheck={false} />
                  {wsGridText.trim() && (() => {
                    const rows = wsGridText.trim().split('\n').filter((r) => r.trim());
                    const cols = rows[0]?.split(/\s+/).filter(Boolean).length ?? 0;
                    return <p className="text-xs text-emerald-400 font-medium">✓ {t('tasks.question_ws_grid_size').replace('{rows}', String(rows.length)).replace('{cols}', String(cols))}</p>;
                  })()}
                </div>

                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <label className="text-sm font-medium text-app-subtle ml-1">{t('tasks.question_ws_clues_label')}</label>
                    <button type="button" onClick={() => setWsClues((a) => [...a, emptyWsClue()])} className="flex items-center gap-1.5 text-xs text-purple-400 hover:text-purple-300 font-medium transition-colors">
                      <Plus className="w-3.5 h-3.5" />{t('tasks.question_ws_clues_add')}
                    </button>
                  </div>
                  <div className="flex gap-2 rounded-lg bg-black/15 px-3 py-2 border border-white/10">
                    <span className="text-purple-400 text-xs mt-0.5 shrink-0">&#9432;</span>
                    <p className="text-xs text-app-muted leading-relaxed">{t('tasks.question_ws_clues_hint')}</p>
                  </div>
                  <div className="grid grid-cols-[1fr_1fr_1fr_2rem] gap-2 px-1">
                    <span className="text-xs font-semibold text-app-muted">{t('tasks.question_ws_clues_formula')}</span>
                    <span className="text-xs font-semibold text-app-muted">{t('tasks.question_ws_clues_common')}</span>
                    <span className="text-xs font-semibold text-purple-400">{t('tasks.question_ws_clues_answer')}</span>
                    <span />
                  </div>
                  {wsClues.map((clue, i) => (
                    <div key={i} className="grid grid-cols-[1fr_1fr_1fr_2rem] gap-2 items-center">
                      <input type="text" value={clue.formula} onChange={(e) => setWsClues((a) => a.map((c, j) => (j === i ? { ...c, formula: e.target.value } : c)))} className="input-glass text-sm min-w-0" placeholder="NaCl" />
                      <input type="text" value={clue.common_name} onChange={(e) => setWsClues((a) => a.map((c, j) => (j === i ? { ...c, common_name: e.target.value } : c)))} className="input-glass text-sm min-w-0" placeholder="osh tuzi" />
                      <input type="text" value={clue.answer} onChange={(e) => setWsClues((a) => a.map((c, j) => (j === i ? { ...c, answer: e.target.value.toUpperCase() } : c)))} className="input-glass text-sm min-w-0 font-mono tracking-wide" placeholder="HALIT" />
                      <button type="button" disabled={wsClues.length <= 1} onClick={() => setWsClues((a) => a.filter((_, j) => j !== i))} className="flex items-center justify-center p-1 rounded-lg hover:bg-red-500/15 text-app-muted hover:text-red-400 transition-all disabled:opacity-30 disabled:cursor-not-allowed">
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {qType === 'matrix_classification' && (
              <div className="min-w-0 space-y-4 rounded-xl border border-purple-500/20 bg-purple-500/5 p-4">
                <p className="text-xs text-app-muted">{t('tasks.question_matrix_hint')}</p>
                <div className="space-y-2">
                  <div className="grid grid-cols-[3rem_1fr_9rem_7rem_2rem] items-center gap-2 px-1">
                    <span className="text-xs font-semibold text-app-muted">#</span>
                    <span className="text-xs font-semibold text-app-muted">{t('tasks.question_matrix_col_text')}</span>
                    <span className="text-xs font-semibold text-app-muted">{t('tasks.question_matrix_col_method')}</span>
                    <span className="text-xs font-semibold text-app-muted">{t('tasks.question_matrix_col_order')}</span>
                    <span />
                  </div>
                  {matrixRows.map((row, idx) => (
                    <div key={row.id} className="grid grid-cols-[3rem_1fr_9rem_7rem_2rem] items-start gap-2">
                      <div className="pt-2 text-xs text-app-muted">#{row.id}</div>
                      <textarea
                        rows={2}
                        value={row.text}
                        onChange={(e) => setMatrixRows((a) => a.map((x, j) => (j === idx ? { ...x, text: e.target.value } : x)))}
                        className="input-glass min-h-[2.5rem] min-w-0 resize-none break-words text-sm"
                        placeholder={t('tasks.question_matrix_row_placeholder').replace('{n}', String(row.id))}
                      />
                      <select
                        value={row.method}
                        onChange={(e) => setMatrixRows((a) => a.map((x, j) => (j === idx ? { ...x, method: e.target.value as 'solve' | 'ammonia' | 'none' } : x)))}
                        className="input-glass text-sm"
                      >
                        <option value="none">{t('tasks.question_matrix_method_none')}</option>
                        <option value="solve">{t('tasks.question_matrix_method_solve')}</option>
                        <option value="ammonia">{t('tasks.question_matrix_method_ammonia')}</option>
                      </select>
                      <input
                        type="number"
                        min={1}
                        value={row.order}
                        onChange={(e) => setMatrixRows((a) => a.map((x, j) => (j === idx ? { ...x, order: e.target.value } : x)))}
                        className="input-glass text-sm"
                        placeholder={t('tasks.question_matrix_order_placeholder')}
                      />
                      <button
                        type="button"
                        disabled={matrixRows.length <= 2}
                        onClick={() => removeMatrixRow(idx)}
                        className="mt-1 flex items-center justify-center p-1 rounded-lg hover:bg-red-500/15 text-app-muted hover:text-red-400 transition-all disabled:opacity-30 disabled:cursor-not-allowed"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  ))}
                </div>
                <div className="flex flex-wrap gap-2">
                  <button
                    type="button"
                    onClick={addMatrixRow}
                    className="rounded-lg bg-purple-500/20 px-3 py-1.5 text-sm font-medium text-purple-200 hover:bg-purple-500/30"
                  >
                    {t('tasks.question_matrix_add_row')}
                  </button>
                </div>
                <div className="space-y-3 rounded-xl border border-white/10 bg-black/10 p-3">
                  <label className="flex items-center gap-2 text-sm text-app-subtle">
                    <input type="checkbox" checked={matrixSequenceEnabled} onChange={(e) => setMatrixSequenceEnabled(e.target.checked)} className="h-4 w-4 accent-purple-500" />
                    {t('tasks.question_matrix_sequence_enabled')}
                  </label>
                  <input
                    type="text"
                    value={matrixSequenceLabel}
                    onChange={(e) => setMatrixSequenceLabel(e.target.value)}
                    className="input-glass text-sm"
                    placeholder={t('tasks.question_matrix_sequence_label')}
                  />
                  <input
                    type="number"
                    min={1}
                    value={matrixSequenceMaxStep}
                    onChange={(e) => setMatrixSequenceMaxStep(Number(e.target.value))}
                    className="input-glass text-sm"
                    placeholder={t('tasks.question_matrix_sequence_max_step')}
                  />
                </div>
              </div>
            )}

          </div>

          <div className="mt-4 flex shrink-0 gap-4 border-t border-black/5 pt-4 dark:border-white/10">
            <button type="button" onClick={closeQModal} className="flex-1 btn-modal-secondary">{t('common.cancel')}</button>
            <button type="submit" disabled={addQ.isPending || updateQ.isPending} className="flex-1 btn-primary flex items-center justify-center gap-2">
              {(addQ.isPending || updateQ.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
              {qModal?.q ? t('common.save') : t('common.create')}
            </button>
          </div>
        </form>
      </GlassModal>

      <ConfirmModal isOpen={!!deleteTask} onClose={() => setDeleteTask(null)} onConfirm={() => deleteTask && removeTask.mutate(deleteTask.id)} title={t('tasks.delete_title')} message={t('tasks.delete_message')} confirmText={t('common.delete')} cancelText={t('common.cancel')} type="danger" isLoading={removeTask.isPending} />
      <ConfirmModal isOpen={!!deleteQ} onClose={() => setDeleteQ(null)} onConfirm={() => deleteQ && removeQ.mutate({ taskId: deleteQ.taskId, qId: deleteQ.q.id })} title={t('tasks.delete_question_title')} message={t('tasks.delete_question_message')} confirmText={t('common.delete')} cancelText={t('common.cancel')} type="danger" isLoading={removeQ.isPending} />
    </div>
  );
}

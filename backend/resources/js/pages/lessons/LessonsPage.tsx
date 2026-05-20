import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, BookOpen, Loader2, ListOrdered, FlaskConical, Boxes, PackageCheck } from 'lucide-react';
import { lessonApi, type Lesson, type LessonLabItem, type LessonLabItemCategory, type LessonLabItemPayload } from '@/api/lessons';
import { languageApi } from '@/api/languages';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { switchInactiveTrackCn } from '@/lib/utils';
import { toast } from 'sonner';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';
import { LessonContentEditor } from '@/components/lessons/LessonContentEditor';

const defaultLabItemForm: LessonLabItemPayload = {
  category: 'equipment',
  name: '',
  formula: '',
  quantity: '',
  unit: '',
  notes: '',
  sort_order: 0,
  is_required: true,
  is_active: true,
};

const LessonsPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingLesson, setEditingLesson] = useState<Lesson | null>(null);
  const [activeTab, setActiveTab] = useState('base');
  const [filterType, setFilterType] = useState<'all' | 'theory' | 'lab'>('all');
  const [labLesson, setLabLesson] = useState<Lesson | null>(null);
  const [editingLabItem, setEditingLabItem] = useState<LessonLabItem | null>(null);
  const [deletingLabItemId, setDeletingLabItemId] = useState<number | null>(null);
  const [labItemForm, setLabItemForm] = useState<LessonLabItemPayload>(defaultLabItemForm);

  const [formData, setFormData] = useState({
    type: 'theory',
    order: 0,
    is_active: true,
  });

  const [translationsData, setTranslationsData] = useState<Record<number, { title: string; content: string }>>({});

  const { data: langData } = useQuery({ queryKey: ['languages'], queryFn: languageApi.getAll });
  const { data: lessonsData, isLoading } = useQuery({ queryKey: ['lessons'], queryFn: lessonApi.getAll });
  const { data: labItemsData, isLoading: labItemsLoading } = useQuery({
    queryKey: ['lesson-lab-items', labLesson?.id],
    queryFn: () => lessonApi.getLabItems(labLesson!.id),
    enabled: !!labLesson,
  });

  const activeLanguages = useMemo(() => langData?.data.languages.filter(l => l.is_active) || [], [langData]);

  const filteredLessons = useMemo(() => {
    if (!lessonsData?.data.lessons) return [];
    if (filterType === 'all') return lessonsData.data.lessons;
    return lessonsData.data.lessons.filter(lesson => lesson.type === filterType);
  }, [lessonsData, filterType]);
  const labItems = labItemsData?.data.items ?? [];

  const createMutation = useMutation({
    mutationFn: (data: { type: 'theory' | 'lab'; order: number; is_active: boolean; translations: any }) => lessonApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
      handleCloseModal();
      toast.success(t('lessons.toast_created'), { id: 'lessons-crud' });
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('lessons.toast_save_error')), { id: 'lessons-crud' });
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: { type: 'theory' | 'lab'; order: number; is_active: boolean; translations: any } }) => lessonApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
      handleCloseModal();
      toast.success(t('lessons.toast_updated'), { id: 'lessons-crud' });
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('lessons.toast_save_error')), { id: 'lessons-crud' });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: lessonApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
      toast.success(t('lessons.toast_deleted'), { id: 'lessons-crud' });
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('lessons.toast_delete_error')), { id: 'lessons-crud' });
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: ({ id, is_active }: { id: number; is_active: boolean }) => lessonApi.update(id, { is_active }),
    onSuccess: (_, { is_active }) => {
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
      toast.success(is_active ? t('lessons.toast_activated') : t('lessons.toast_deactivated'), { id: 'lessons-toggle' });
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('lessons.toast_toggle_error')), { id: 'lessons-toggle' });
    },
  });

  const createLabItemMutation = useMutation({
    mutationFn: ({ lessonId, data }: { lessonId: number; data: LessonLabItemPayload }) =>
      lessonApi.createLabItem(lessonId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lesson-lab-items', labLesson?.id] });
      setLabItemForm(defaultLabItemForm);
      setEditingLabItem(null);
      toast.success(t('lessons.lab_items_toast_created'), { id: 'lesson-lab-items' });
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('lessons.toast_save_error')), { id: 'lesson-lab-items' });
    },
  });

  const updateLabItemMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: LessonLabItemPayload }) =>
      lessonApi.updateLabItem(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lesson-lab-items', labLesson?.id] });
      setLabItemForm(defaultLabItemForm);
      setEditingLabItem(null);
      toast.success(t('lessons.lab_items_toast_updated'), { id: 'lesson-lab-items' });
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('lessons.toast_save_error')), { id: 'lesson-lab-items' });
    },
  });

  const deleteLabItemMutation = useMutation({
    mutationFn: lessonApi.deleteLabItem,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lesson-lab-items', labLesson?.id] });
      setDeletingLabItemId(null);
      toast.success(t('lessons.lab_items_toast_deleted'), { id: 'lesson-lab-items' });
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('lessons.toast_delete_error')), { id: 'lesson-lab-items' });
    },
  });

  const handleOpenModal = (lesson: Lesson | null = null) => {
    if (lesson) {
      setEditingLesson(lesson);
      setFormData({
        type: lesson.type,
        order: lesson.order,
        is_active: lesson.is_active,
      });
      const trans: Record<number, { title: string; content: string }> = {};
      lesson.translations.forEach(tr => {
        trans[tr.language_id] = { title: tr.title, content: tr.content || '' };
      });
      setTranslationsData(trans);
    } else {
      setEditingLesson(null);
      setFormData({ type: 'theory', order: 0, is_active: true });
      setTranslationsData({});
    }
    setActiveTab('base');
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingLesson(null);
  };

  const openLabItemsModal = (lesson: Lesson) => {
    setLabLesson(lesson);
    setEditingLabItem(null);
    setLabItemForm(defaultLabItemForm);
  };

  const closeLabItemsModal = () => {
    setLabLesson(null);
    setEditingLabItem(null);
    setDeletingLabItemId(null);
    setLabItemForm(defaultLabItemForm);
  };

  const handleEditLabItem = (item: LessonLabItem) => {
    setEditingLabItem(item);
    setLabItemForm({
      category: item.category,
      name: item.name,
      formula: item.formula ?? '',
      quantity: item.quantity ?? '',
      unit: item.unit ?? '',
      notes: item.notes ?? '',
      sort_order: item.sort_order ?? 0,
      is_required: item.is_required,
      is_active: item.is_active,
    });
  };

  const handleLabItemSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!labLesson) return;

    const payload: LessonLabItemPayload = {
      ...labItemForm,
      name: labItemForm.name.trim(),
      formula: labItemForm.formula?.trim() || null,
      quantity: labItemForm.quantity?.trim() || null,
      unit: labItemForm.unit?.trim() || null,
      notes: labItemForm.notes?.trim() || null,
      sort_order: Number(labItemForm.sort_order ?? 0),
    };

    if (editingLabItem) {
      updateLabItemMutation.mutate({ id: editingLabItem.id, data: payload });
    } else {
      createLabItemMutation.mutate({ lessonId: labLesson.id, data: payload });
    }
  };

  const handleTranslationChange = (langId: number, field: 'title' | 'content', value: string) => {
    setTranslationsData(prev => ({
      ...prev,
      [langId]: { ...(prev[langId] || { title: '', content: '' }), [field]: value }
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      ...formData,
      type: formData.type as 'theory' | 'lab',
      translations: Object.entries(translationsData).map(([langId, data]) => ({
        language_id: parseInt(langId),
        ...data,
      })),
    };

    if (editingLesson) {
      updateMutation.mutate({ id: editingLesson.id, data: payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'theory': return <BookOpen className="w-5 h-5" />;
      case 'lab': return <FlaskConical className="w-5 h-5" />;
      default: return <BookOpen className="w-5 h-5" />;
    }
  };

  const labItemCategoryLabel = (category: LessonLabItemCategory) => {
    return t(`lessons.lab_item_category_${category}`);
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('lessons.title')}</h1>
          <p className="text-app-muted mt-1">{t('lessons.subtitle')}</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          {t('lessons.add_button')}
        </button>
      </div>

      <div className="flex w-fit gap-2 rounded-2xl border border-black/10 bg-black/[0.04] p-1 dark:border-white/10 dark:bg-white/5">
        {[
          { id: 'all', label: t('common.all', 'Barchasi'), icon: <BookOpen className="w-4 h-4" /> },
          { id: 'theory', label: t('lessons.theory'), icon: <BookOpen className="w-4 h-4" /> },
          { id: 'lab', label: t('lessons.lab'), icon: <FlaskConical className="w-4 h-4" /> },
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setFilterType(tab.id as any)}
            className={`flex items-center gap-2 py-2 px-6 rounded-xl text-sm font-bold transition-all ${
              filterType === tab.id 
                ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" 
                : "text-app-muted hover:text-app-primary hover:bg-black/5 dark:hover:bg-white/5"
            }`}
          >
            {tab.icon}
            {tab.label}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 gap-4">
        {isLoading ? (
          <div className="py-20 text-center">
            <Loader2 className="w-10 h-10 animate-spin mx-auto text-purple-500" />
          </div>
        ) : (
          filteredLessons.map((lesson) => (
            <GlassCard key={lesson.id} className="group py-4">
              <div className="flex items-center justify-between gap-6">
                <div className="flex items-center gap-6 flex-1">
                  <div className="flex flex-col items-center gap-1 min-w-12">
                    <span className="text-[10px] font-bold text-app-muted uppercase tracking-widest">{t('lessons.table_order')}</span>
                    <span className="text-xl font-black text-purple-500/50">#{lesson.order}</span>
                  </div>

                  <div className={`w-12 h-12 rounded-2xl glass flex items-center justify-center ${
                    lesson.type === 'theory' ? 'text-blue-400' : 'text-emerald-400'
                  }`}>
                    {getTypeIcon(lesson.type)}
                  </div>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-3 mb-1">
                      <h3 className="text-lg font-bold text-app-primary truncate">
                        {lesson.translations.find(t => t.language_id === 1)?.title || 'Untitled Lesson'}
                      </h3>
                      <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider border ${
                        lesson.type === 'theory' ? 'bg-blue-500/10 border-blue-500/20 text-blue-400' :
                        'bg-emerald-500/10 border-emerald-500/20 text-emerald-400'
                      }`}>
                        {t(`lessons.${lesson.type}`)}
                      </span>
                    </div>
                    <p className="text-sm text-app-muted truncate max-w-xl">
                      {lesson.translations.find(t => t.language_id === 1)?.content?.substring(0, 100) || 'No content description available...'}
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-4">
                  <div
                    className="flex shrink-0 items-center gap-2"
                    title={lesson.is_active ? t('lessons.toggle_hint_on') : t('lessons.toggle_hint_off')}
                  >
                    <span className="hidden max-w-[4.5rem] text-right text-xs leading-tight text-app-muted sm:inline">
                      {lesson.is_active ? t('lessons.status_on') : t('lessons.status_off')}
                    </span>
                    <button
                      type="button"
                      role="switch"
                      aria-checked={lesson.is_active}
                      aria-label={lesson.is_active ? t('lessons.toggle_aria_on') : t('lessons.toggle_aria_off')}
                      disabled={
                        toggleActiveMutation.isPending && toggleActiveMutation.variables?.id === lesson.id
                      }
                      onClick={(e) => {
                        e.stopPropagation();
                        toggleActiveMutation.mutate({ id: lesson.id, is_active: !lesson.is_active });
                      }}
                      className={[
                        'relative h-7 w-12 shrink-0 rounded-full transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500/70 focus-visible:ring-offset-2 focus-visible:ring-offset-transparent disabled:opacity-50',
                        lesson.is_active ? 'bg-emerald-500/90' : switchInactiveTrackCn,
                      ].join(' ')}
                    >
                      <span
                        className={[
                          'absolute top-0.5 flex h-6 w-6 items-center justify-center rounded-full bg-white shadow-md transition-transform duration-200',
                          lesson.is_active ? 'translate-x-5' : 'translate-x-0.5',
                        ].join(' ')}
                      />
                    </button>
                  </div>

                  <div className="flex gap-2">
                    {lesson.type === 'lab' && (
                      <button
                        type="button"
                        onClick={() => openLabItemsModal(lesson)}
                        className="flex items-center gap-1.5 rounded-xl bg-emerald-500/10 px-3 py-2 text-xs font-bold text-emerald-400 transition-all hover:bg-emerald-500/20 hover:text-emerald-300"
                        title={t('lessons.lab_items_link_hint')}
                      >
                        <PackageCheck className="w-4 h-4" />
                        <span className="hidden xl:inline">{t('lessons.lab_items_link')}</span>
                      </button>
                    )}
                    <button onClick={() => handleOpenModal(lesson)} className="p-2 rounded-xl hover:bg-white/10 text-app-muted hover:text-app-primary transition-all">
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button 
                      onClick={() => {
                        setDeletingId(lesson.id);
                        setIsDeleteModalOpen(true);
                      }} 
                      className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            </GlassCard>
          ))
        )}
      </div>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingId && deleteMutation.mutate(deletingId)}
        title={t('lessons.delete_title')}
        message={t('lessons.delete_confirm_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <ConfirmModal
        isOpen={deletingLabItemId != null}
        onClose={() => setDeletingLabItemId(null)}
        onConfirm={() => deletingLabItemId && deleteLabItemMutation.mutate(deletingLabItemId)}
        title={t('lessons.lab_item_delete_title')}
        message={t('lessons.lab_item_delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteLabItemMutation.isPending}
      />

      <GlassModal
        isOpen={!!labLesson}
        onClose={closeLabItemsModal}
        title={t('lessons.lab_items_title')}
        flexBody
        className="w-full max-h-[min(94vh,60rem)] max-w-[min(98vw,92rem)] overflow-hidden"
      >
        <div className="flex min-h-0 flex-1 flex-col gap-4 overflow-hidden">
          <div className="shrink-0 rounded-2xl border border-emerald-500/20 bg-emerald-500/10 px-5 py-4">
            <div className="flex items-start gap-3">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-emerald-500/15 text-emerald-300">
                <FlaskConical className="h-5 w-5" />
              </div>
              <div className="min-w-0">
                <p className="font-bold text-app-primary">
                  {labLesson?.translations.find(t => t.language_id === 1)?.title ?? t('lessons.lab')}
                </p>
                <p className="mt-0.5 text-sm text-app-muted">{t('lessons.lab_items_subtitle')}</p>
              </div>
            </div>
          </div>

          <div className="grid min-h-0 flex-1 grid-cols-1 grid-rows-[minmax(0,1fr)_minmax(0,1fr)] gap-4 overflow-hidden xl:grid-cols-[minmax(0,1.15fr)_minmax(27rem,0.85fr)] xl:grid-rows-1">
            <div className="min-h-0 overflow-y-auto overscroll-contain rounded-2xl border border-white/10 bg-white/[0.025] p-3 pr-2 scrollbar-none">
            {labItemsLoading ? (
              <div className="py-14 text-center">
                <Loader2 className="mx-auto h-8 w-8 animate-spin text-purple-500" />
              </div>
            ) : labItems.length === 0 ? (
              <div className="rounded-2xl border border-dashed border-white/15 px-5 py-10 text-center">
                <Boxes className="mx-auto mb-3 h-9 w-9 text-app-muted" />
                <p className="font-semibold text-app-primary">{t('lessons.lab_items_empty')}</p>
                <p className="mt-1 text-sm text-app-muted">{t('lessons.lab_items_empty_hint')}</p>
              </div>
            ) : (
              <div className="space-y-3">
                {labItems.map(item => (
                  <div
                    key={item.id}
                    className="rounded-2xl border border-white/10 bg-white/[0.04] p-4 shadow-sm transition-colors hover:bg-white/[0.07] xl:p-5"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <div className="mb-2 flex flex-wrap items-center gap-2">
                          <span className="rounded-full bg-purple-500/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-purple-300">
                            {labItemCategoryLabel(item.category)}
                          </span>
                          {item.is_required ? (
                            <span className="rounded-full bg-amber-500/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-amber-300">
                              {t('lessons.lab_item_required')}
                            </span>
                          ) : null}
                          {!item.is_active ? (
                            <span className="rounded-full bg-red-500/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-red-300">
                              {t('lessons.status_off')}
                            </span>
                          ) : null}
                        </div>
                        <h3 className="text-base font-bold leading-snug text-app-primary">{item.name}</h3>
                        <p className="mt-1 text-sm text-app-muted">
                          {[item.formula, item.quantity, item.unit].filter(Boolean).join(' · ') || t('lessons.lab_item_no_meta')}
                        </p>
                        {item.notes ? <p className="mt-2 text-sm text-app-muted line-clamp-2">{item.notes}</p> : null}
                      </div>
                      <div className="flex shrink-0 gap-1">
                        <button
                          type="button"
                          onClick={() => handleEditLabItem(item)}
                          className="rounded-xl p-2 text-app-muted transition-all hover:bg-white/10 hover:text-app-primary"
                          title={t('common.edit')}
                        >
                          <Edit2 className="h-4 w-4" />
                        </button>
                        <button
                          type="button"
                          onClick={() => setDeletingLabItemId(item.id)}
                          className="rounded-xl p-2 text-app-muted transition-all hover:bg-red-500/10 hover:text-red-400"
                          title={t('common.delete')}
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <form
            onSubmit={handleLabItemSubmit}
            className="flex min-h-0 flex-col overflow-hidden rounded-2xl border border-white/10 bg-white/[0.03]"
          >
            <div className="flex shrink-0 items-center justify-between gap-3 border-b border-white/10 px-5 py-4">
              <h3 className="text-lg font-bold text-app-primary">
                {editingLabItem ? t('lessons.lab_item_edit_title') : t('lessons.lab_item_create_title')}
              </h3>
              {editingLabItem ? (
                <button
                  type="button"
                  onClick={() => {
                    setEditingLabItem(null);
                    setLabItemForm(defaultLabItemForm);
                  }}
                  className="text-xs font-semibold text-app-muted transition-colors hover:text-app-primary"
                >
                  {t('common.cancel')}
                </button>
              ) : null}
            </div>

            <div className="min-h-0 flex-1 space-y-4 overflow-y-auto overscroll-contain px-5 py-4 pr-4 scrollbar-none">
            <div className="space-y-2">
              <label className="ml-1 text-sm font-medium text-app-subtle">{t('lessons.lab_item_category')}</label>
              <select
                value={labItemForm.category}
                onChange={(e) => setLabItemForm({ ...labItemForm, category: e.target.value as LessonLabItemCategory })}
                className="input-glass w-full"
              >
                <option value="equipment">{t('lessons.lab_item_category_equipment')}</option>
                <option value="reagent">{t('lessons.lab_item_category_reagent')}</option>
                <option value="element">{t('lessons.lab_item_category_element')}</option>
                <option value="vessel">{t('lessons.lab_item_category_vessel')}</option>
              </select>
            </div>

            <div className="space-y-2">
              <label className="ml-1 text-sm font-medium text-app-subtle">{t('lessons.lab_item_name')}</label>
              <input
                required
                value={labItemForm.name}
                onChange={(e) => setLabItemForm({ ...labItemForm, name: e.target.value })}
                className="input-glass w-full"
                placeholder={t('lessons.lab_item_name_placeholder')}
              />
            </div>

            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              <div className="space-y-2">
                <label className="ml-1 text-sm font-medium text-app-subtle">{t('lessons.lab_item_formula')}</label>
                <input
                  value={labItemForm.formula ?? ''}
                  onChange={(e) => setLabItemForm({ ...labItemForm, formula: e.target.value })}
                  className="input-glass w-full"
                  placeholder="H2SO4"
                />
              </div>
              <div className="space-y-2">
                <label className="ml-1 text-sm font-medium text-app-subtle">{t('lessons.lab_item_order')}</label>
                <input
                  type="number"
                  min={0}
                  value={labItemForm.sort_order ?? 0}
                  onChange={(e) => setLabItemForm({ ...labItemForm, sort_order: Number(e.target.value) || 0 })}
                  className="input-glass w-full"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              <div className="space-y-2">
                <label className="ml-1 text-sm font-medium text-app-subtle">{t('lessons.lab_item_quantity')}</label>
                <input
                  value={labItemForm.quantity ?? ''}
                  onChange={(e) => setLabItemForm({ ...labItemForm, quantity: e.target.value })}
                  className="input-glass w-full"
                  placeholder="10"
                />
              </div>
              <div className="space-y-2">
                <label className="ml-1 text-sm font-medium text-app-subtle">{t('lessons.lab_item_unit')}</label>
                <input
                  value={labItemForm.unit ?? ''}
                  onChange={(e) => setLabItemForm({ ...labItemForm, unit: e.target.value })}
                  className="input-glass w-full"
                  placeholder="ml, g, dona"
                />
              </div>
            </div>

            <div className="space-y-2">
              <label className="ml-1 text-sm font-medium text-app-subtle">{t('lessons.lab_item_notes')}</label>
              <textarea
                value={labItemForm.notes ?? ''}
                onChange={(e) => setLabItemForm({ ...labItemForm, notes: e.target.value })}
                className="input-glass min-h-24 w-full resize-y"
                placeholder={t('lessons.lab_item_notes_placeholder')}
              />
            </div>

            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              <label className="flex cursor-pointer items-center gap-3 rounded-2xl border border-white/10 bg-white/[0.03] p-3">
                <input
                  type="checkbox"
                  checked={!!labItemForm.is_required}
                  onChange={(e) => setLabItemForm({ ...labItemForm, is_required: e.target.checked })}
                  className="h-4 w-4 accent-purple-500"
                />
                <span className="text-sm font-medium text-app-subtle">{t('lessons.lab_item_required')}</span>
              </label>
              <label className="flex cursor-pointer items-center gap-3 rounded-2xl border border-white/10 bg-white/[0.03] p-3">
                <input
                  type="checkbox"
                  checked={!!labItemForm.is_active}
                  onChange={(e) => setLabItemForm({ ...labItemForm, is_active: e.target.checked })}
                  className="h-4 w-4 accent-purple-500"
                />
                <span className="text-sm font-medium text-app-subtle">{t('lessons.status_on')}</span>
              </label>
            </div>

            </div>

            <div className="shrink-0 border-t border-white/10 bg-white/[0.025] p-4">
            <button
              type="submit"
              disabled={createLabItemMutation.isPending || updateLabItemMutation.isPending}
              className="btn-primary flex w-full items-center justify-center gap-2 py-3.5"
            >
              {(createLabItemMutation.isPending || updateLabItemMutation.isPending) && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              {editingLabItem ? t('common.save') : t('common.create')}
            </button>
            </div>
          </form>
          </div>
        </div>
      </GlassModal>

      <GlassModal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingLesson ? t('common.edit') : t('lessons.add_button')}
        className="max-w-4xl"
      >
        <div className="flex gap-2 mb-8 p-1 rounded-2xl bg-black/[0.04] dark:bg-white/5 border border-black/10 dark:border-white/10">
          <button
            onClick={() => setActiveTab('base')}
            className={`flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all ${
              activeTab === 'base' ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary"
            }`}
          >
            {t('mines.form_base_data')}
          </button>
          {activeLanguages.map(lang => (
            <button
              key={lang.id}
              onClick={() => setActiveTab(lang.code)}
              className={`flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-all flex items-center justify-center gap-2 ${
                activeTab === lang.code ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary"
              }`}
            >
              <LanguageFlag code={lang.code} size="sm" className="shrink-0" />
              {lang.code.toUpperCase()}
            </button>
          ))}
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {activeTab === 'base' && (
            <div className="space-y-6 animate-in fade-in duration-300">
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('lessons.form_type')}</label>
                  <select
                    value={formData.type}
                    onChange={e => setFormData({ ...formData, type: e.target.value })}
                    className="input-glass"
                  >
                    <option value="theory">{t('lessons.theory')}</option>
                    <option value="lab">{t('lessons.lab')}</option>
                  </select>
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium text-app-subtle ml-1">{t('lessons.form_order')}</label>
                  <div className="relative">
                    <ListOrdered className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-app-muted" />
                    <input
                      type="number"
                      required
                      value={formData.order}
                      onChange={e => setFormData({ ...formData, order: parseInt(e.target.value) })}
                      className="input-glass pl-12"
                    />
                  </div>
                </div>
              </div>

              <label className="flex items-center gap-3 cursor-pointer group">
                <div className="relative">
                  <input
                    type="checkbox"
                    checked={formData.is_active}
                    onChange={e => setFormData({ ...formData, is_active: e.target.checked })}
                    className="sr-only"
                  />
                  <div className={`w-12 h-6 rounded-full transition-colors ${formData.is_active ? 'bg-emerald-500/30' : 'bg-white/10'}`} />
                  <div className={`absolute left-1 top-1 w-4 h-4 rounded-full transition-transform ${formData.is_active ? 'translate-x-6 bg-emerald-400' : 'bg-gray-500'}`} />
                </div>
                <span className="text-sm font-medium text-app-subtle">{t('lessons.form_is_active')}</span>
              </label>
            </div>
          )}

          {activeLanguages.map(lang => activeTab === lang.code && (
            <div key={lang.id} className="space-y-6 animate-in fade-in duration-300">
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('lessons.form_title')} ({lang.name})</label>
                <input
                  type="text"
                  required
                  value={translationsData[lang.id]?.title || ''}
                  onChange={e => handleTranslationChange(lang.id, 'title', e.target.value)}
                  className="input-glass"
                  placeholder="e.g. Introduction to Metals"
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-app-subtle ml-1">{t('lessons.form_content')} ({lang.name})</label>
                <p className="text-xs text-app-muted ml-1">{t('lessons.content_editor_hint')}</p>
                <LessonContentEditor
                  resetKey={`${editingLesson?.id ?? 'new'}-${lang.id}`}
                  value={translationsData[lang.id]?.content || ''}
                  onChange={(md) => handleTranslationChange(lang.id, 'content', md)}
                  placeholder={t('lessons.editor_placeholder')}
                />
              </div>
            </div>
          ))}

          <div className="flex gap-4 pt-4">
            <button type="button" onClick={handleCloseModal} className="flex-1 btn-modal-secondary">
              {t('common.cancel')}
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending || updateMutation.isPending}
              className="flex-1 btn-primary flex items-center justify-center gap-2"
            >
              {(createMutation.isPending || updateMutation.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
              {editingLesson ? t('common.save') : t('common.create')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

export default LessonsPage;

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Plus, Edit2, Trash2, FileText, Loader2, CheckCircle2, ExternalLink } from 'lucide-react';
import { toast } from 'sonner';
import { documentApi, type AppDocument, type DocumentCategory } from '@/api/documents';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassModal } from '@/components/ui/GlassModal';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { cn, switchInactiveTrackCn } from '@/lib/utils';

type CategoryFilter = '' | DocumentCategory;
type TitleLang = 'uz' | 'ru' | 'en';

const titleLangConfig: { key: TitleLang; flag: string; labelKey: 'lang_tab_uz' | 'lang_tab_ru' | 'lang_tab_en' }[] = [
  { key: 'uz', flag: 'uz', labelKey: 'lang_tab_uz' },
  { key: 'ru', flag: 'ru', labelKey: 'lang_tab_ru' },
  { key: 'en', flag: 'en', labelKey: 'lang_tab_en' },
];

function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

const emptyForm = {
  category: 'decisions' as DocumentCategory,
  title_uz: '',
  title_ru: '',
  title_en: '',
  sort_order: 0,
  is_active: true,
  file: null as File | null,
};

const DocumentsPage = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [categoryFilter, setCategoryFilter] = useState<CategoryFilter>('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [editingDoc, setEditingDoc] = useState<AppDocument | null>(null);
  const [form, setForm] = useState(emptyForm);
  const [titleLang, setTitleLang] = useState<TitleLang>('uz');

  const { data, isLoading } = useQuery({
    queryKey: ['documents', categoryFilter || 'all'],
    queryFn: () => documentApi.getAll(categoryFilter || undefined),
  });

  const createMutation = useMutation({
    mutationFn: () => {
      if (!form.file) {
        return Promise.reject(new Error('no_file'));
      }
      return documentApi.create({
        category: form.category,
        title_uz: form.title_uz,
        title_ru: form.title_ru,
        title_en: form.title_en,
        file: form.file,
        sort_order: form.sort_order,
        is_active: form.is_active,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['documents'] });
      toast.success(t('common.save_success'));
      closeModal();
    },
    onError: (e: unknown) => {
      if (e instanceof Error && e.message === 'no_file') {
        toast.error(t('documents.validation_file'));
        return;
      }
      toast.error(getApiErrorMessage(e, t('toast.error_generic')));
    },
  });

  const updateMutation = useMutation({
    mutationFn: () => {
      if (!editingDoc) return Promise.reject();
      return documentApi.update(editingDoc.id, {
        category: form.category,
        title_uz: form.title_uz,
        title_ru: form.title_ru,
        title_en: form.title_en,
        sort_order: form.sort_order,
        is_active: form.is_active,
        file: form.file,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['documents'] });
      toast.success(t('common.save_success'));
      closeModal();
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.error_generic'))),
  });

  const deleteMutation = useMutation({
    mutationFn: documentApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['documents'] });
      setIsDeleteModalOpen(false);
      setDeletingId(null);
      toast.success(t('toast.deleted'));
    },
    onError: (e) => toast.error(getApiErrorMessage(e, t('toast.delete_error'))),
  });

  const toggleActiveMutation = useMutation({
    mutationFn: ({ id, is_active }: { id: number; is_active: boolean }) => documentApi.patchIsActive(id, is_active),
    onSuccess: (_, { is_active }) => {
      queryClient.invalidateQueries({ queryKey: ['documents'] });
      toast.success(is_active ? t('documents.toast_activated') : t('documents.toast_deactivated'), {
        id: 'documents-toggle',
      });
    },
    onError: (e) => {
      toast.error(getApiErrorMessage(e, t('documents.toast_toggle_error')), { id: 'documents-toggle' });
    },
  });

  const openModal = (doc: AppDocument | null) => {
    if (doc) {
      setEditingDoc(doc);
      setForm({
        category: doc.category,
        title_uz: doc.title_uz,
        title_ru: doc.title_ru ?? '',
        title_en: doc.title_en ?? '',
        sort_order: doc.sort_order,
        is_active: doc.is_active,
        file: null,
      });
    } else {
      setEditingDoc(null);
      setForm(emptyForm);
    }
    setTitleLang('uz');
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingDoc(null);
    setForm(emptyForm);
    setTitleLang('uz');
  };

  const setTitleForLang = (value: string) => {
    setForm((f) => {
      if (titleLang === 'uz') return { ...f, title_uz: value };
      if (titleLang === 'ru') return { ...f, title_ru: value };
      return { ...f, title_en: value };
    });
  };

  const titleInputValue = titleLang === 'uz' ? form.title_uz : titleLang === 'ru' ? form.title_ru : form.title_en;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingDoc) {
      createMutation.mutate();
    } else {
      updateMutation.mutate();
    }
  };

  const documents = data?.data.documents ?? [];

  const filterBtn = (key: CategoryFilter, label: string) => (
    <button
      key={key || 'all'}
      type="button"
      onClick={() => setCategoryFilter(key)}
      className={cn(
        'rounded-xl px-4 py-2 text-sm font-medium transition-all',
        categoryFilter === key
          ? 'bg-purple-500 text-white shadow-md shadow-purple-500/30'
          : 'bg-black/5 text-app-muted hover:bg-black/10 dark:bg-white/5 dark:hover:bg-white/10',
      )}
    >
      {label}
    </button>
  );

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex flex-col gap-4 sm:flex-row sm:justify-between sm:items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('documents.title')}</h1>
          <p className="text-app-muted mt-1">{t('documents.subtitle')}</p>
        </div>
        <button type="button" onClick={() => openModal(null)} className="btn-primary flex items-center justify-center gap-2 shrink-0">
          <Plus className="w-5 h-5" />
          {t('documents.add_button')}
        </button>
      </div>

      <div className="flex flex-wrap gap-2">
        {filterBtn('', t('documents.filter_all'))}
        {filterBtn('decisions', t('documents.category_decisions'))}
        {filterBtn('laws', t('documents.category_laws'))}
      </div>

      <GlassCard className="overflow-hidden p-0">
        {isLoading ? (
          <div className="py-20 text-center">
            <Loader2 className="w-10 h-10 animate-spin mx-auto text-purple-500" />
          </div>
        ) : documents.length === 0 ? (
          <div className="py-20 text-center text-app-muted">
            <FileText className="w-12 h-12 mx-auto mb-4 opacity-30" />
            <p>{t('documents.empty')}</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead>
                <tr className="border-b border-white/10 bg-white/5 dark:bg-white/[0.03]">
                  <th className="px-4 py-3 font-semibold text-app-primary">{t('documents.table_id')}</th>
                  <th className="px-4 py-3 font-semibold text-app-primary">{t('documents.table_category')}</th>
                  <th className="px-4 py-3 font-semibold text-app-primary">{t('documents.table_title_uz')}</th>
                  <th className="px-4 py-3 font-semibold text-app-primary hidden md:table-cell">{t('documents.table_file')}</th>
                  <th className="px-4 py-3 font-semibold text-app-primary hidden lg:table-cell">{t('documents.table_size')}</th>
                  <th className="px-4 py-3 font-semibold text-app-primary hidden sm:table-cell">{t('documents.table_order')}</th>
                  <th className="px-4 py-3 font-semibold text-app-primary">{t('documents.table_status')}</th>
                  <th className="px-4 py-3 font-semibold text-app-primary text-right">{t('common.actions')}</th>
                </tr>
              </thead>
              <tbody>
                {documents.map((doc) => (
                  <tr key={doc.id} className="border-b border-white/5 hover:bg-white/[0.02]">
                    <td className="px-4 py-3 text-app-muted">{doc.id}</td>
                    <td className="px-4 py-3">
                      <span
                        className={cn(
                          'inline-flex rounded-lg px-2 py-0.5 text-xs font-medium',
                          doc.category === 'decisions'
                            ? 'bg-amber-500/15 text-amber-600 dark:text-amber-400'
                            : 'bg-sky-500/15 text-sky-600 dark:text-sky-400',
                        )}
                      >
                        {doc.category === 'decisions' ? t('documents.category_decisions') : t('documents.category_laws')}
                      </span>
                    </td>
                    <td className="px-4 py-3 max-w-[200px] truncate text-app-primary" title={doc.title_uz}>
                      {doc.title_uz}
                    </td>
                    <td className="px-4 py-3 hidden md:table-cell max-w-[180px]">
                      <a
                        href={doc.file_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1 text-purple-500 hover:underline truncate"
                        title={doc.original_filename}
                      >
                        {doc.original_filename}
                        <ExternalLink className="w-3 h-3 shrink-0" />
                      </a>
                    </td>
                    <td className="px-4 py-3 text-app-muted hidden lg:table-cell">{formatFileSize(doc.file_size)}</td>
                    <td className="px-4 py-3 text-app-muted hidden sm:table-cell">{doc.sort_order}</td>
                    <td className="px-4 py-3 align-middle">
                      <div
                        className="flex max-w-[10rem] shrink-0 items-center gap-2"
                        title={doc.is_active ? t('documents.toggle_hint_on') : t('documents.toggle_hint_off')}
                      >
                        <span className="hidden text-right text-xs leading-tight text-app-muted sm:inline">
                          {doc.is_active ? t('languages.active') : t('languages.inactive')}
                        </span>
                        <button
                          type="button"
                          role="switch"
                          aria-checked={doc.is_active}
                          aria-label={
                            doc.is_active ? t('documents.toggle_aria_deactivate') : t('documents.toggle_aria_activate')
                          }
                          disabled={
                            toggleActiveMutation.isPending && toggleActiveMutation.variables?.id === doc.id
                          }
                          onClick={(e) => {
                            e.stopPropagation();
                            toggleActiveMutation.mutate({ id: doc.id, is_active: !doc.is_active });
                          }}
                          className={[
                            'relative h-7 w-12 shrink-0 rounded-full transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-purple-500/70 focus-visible:ring-offset-2 focus-visible:ring-offset-transparent disabled:opacity-50',
                            doc.is_active ? 'bg-emerald-500/90' : switchInactiveTrackCn,
                          ].join(' ')}
                        >
                          <span
                            className={[
                              'absolute top-0.5 flex h-6 w-6 items-center justify-center rounded-full bg-white shadow-md transition-transform duration-200',
                              doc.is_active ? 'translate-x-5' : 'translate-x-0.5',
                            ].join(' ')}
                          />
                        </button>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <div className="inline-flex gap-1">
                        <button
                          type="button"
                          onClick={() => openModal(doc)}
                          className="p-2 rounded-xl hover:bg-white/10 text-app-muted hover:text-app-primary"
                          aria-label={t('common.edit')}
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button
                          type="button"
                          onClick={() => {
                            setDeletingId(doc.id);
                            setIsDeleteModalOpen(true);
                          }}
                          className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500"
                          aria-label={t('common.delete')}
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingId != null && deleteMutation.mutate(deletingId)}
        title={t('documents.delete_title')}
        message={t('documents.delete_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />

      <GlassModal
        isOpen={isModalOpen}
        onClose={closeModal}
        title={editingDoc ? t('documents.edit_title') : t('documents.create_title')}
        className="max-w-lg"
      >
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="space-y-4">
            <div className="rounded-2xl border border-white/10 bg-white/3 p-3 dark:border-white/10">
              <p className="mb-2 text-sm font-medium text-app-subtle">{t('documents.form_category')}</p>
              <div className="grid grid-cols-2 gap-2">
                {(['decisions', 'laws'] as const).map((k) => (
                  <button
                    key={k}
                    type="button"
                    onClick={() => setForm((f) => ({ ...f, category: k }))}
                    className={cn(
                      'rounded-xl px-3 py-2.5 text-sm font-bold transition-all',
                      form.category === k
                        ? 'bg-purple-500 text-white shadow-md shadow-purple-500/20'
                        : 'border border-white/10 bg-white/5 text-app-muted hover:border-purple-500/30 hover:text-app-primary',
                    )}
                  >
                    {k === 'decisions' ? t('documents.category_decisions') : t('documents.category_laws')}
                  </button>
                ))}
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
                <label htmlFor="doc-title-input" className="mb-1.5 block text-sm font-medium text-app-subtle">
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
                  id="doc-title-input"
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

            <div>
              <label className="block text-sm font-medium text-app-secondary mb-1.5 ml-1">
                {t('documents.form_file')} {!editingDoc && <span className="text-red-500">*</span>}
              </label>
              
              <div className="flex flex-col gap-2">
                <div className="flex items-center gap-3">
                  <label className="cursor-pointer bg-purple-500/10 text-purple-500 dark:text-purple-400 px-5 py-2.5 rounded-2xl border border-purple-500/20 hover:bg-purple-500/20 transition-all text-sm font-bold shrink-0">
                    {t('documents.select_file')}
                    <input
                      type="file"
                      accept="application/pdf,.pdf"
                      className="hidden"
                      onChange={(e) => {
                        const f = e.target.files?.[0] ?? null;
                        setForm((prev) => ({ ...prev, file: f }));
                      }}
                    />
                  </label>
                  <span className="text-app-muted text-sm truncate flex-1 italic">
                    {form.file ? form.file.name : (editingDoc ? editingDoc.original_filename : t('documents.no_file_selected'))}
                  </span>
                </div>
                <p className="text-[11px] text-app-muted leading-relaxed ml-1">
                  {t('documents.hint_pdf')}
                </p>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4 items-end">
              <div>
                <label className="block text-sm font-medium text-app-secondary mb-1.5 ml-1">{t('documents.form_sort')}</label>
                <input
                  type="number"
                  min={0}
                  className="input-glass"
                  value={form.sort_order}
                  onChange={(e) => setForm((f) => ({ ...f, sort_order: parseInt(e.target.value, 10) || 0 }))}
                />
              </div>
              <div className="pb-3.5 pl-1">
                <label className="flex items-center gap-3 cursor-pointer group">
                  <div className="relative flex items-center">
                    <input
                      type="checkbox"
                      className="peer h-5 w-5 cursor-pointer appearance-none rounded-lg border border-purple-500/30 bg-purple-500/5 transition-all checked:bg-purple-500 checked:border-purple-500"
                      checked={form.is_active}
                      onChange={(e) => setForm((f) => ({ ...f, is_active: e.target.checked }))}
                    />
                    <CheckCircle2 className="absolute h-3.5 w-3.5 text-white opacity-0 peer-checked:opacity-100 left-0.5 pointer-events-none" />
                  </div>
                  <span className="text-sm font-medium text-app-secondary group-hover:text-app-primary transition-colors">
                    {t('documents.form_is_active')}
                  </span>
                </label>
              </div>
            </div>
          </div>

          <div className="flex gap-4 pt-4">
            <button 
              type="button" 
              onClick={closeModal} 
              className="btn-modal-secondary flex-1"
            >
              {t('common.cancel')}
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending || updateMutation.isPending}
              className="btn-primary flex-1 shadow-lg shadow-purple-500/20"
            >
              {createMutation.isPending || updateMutation.isPending ? t('common.loading') : t('common.save')}
            </button>
          </div>
        </form>
      </GlassModal>
    </div>
  );
};

export default DocumentsPage;

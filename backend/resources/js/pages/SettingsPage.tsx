import { useState, useEffect, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { toast } from 'sonner';
import { Save, Loader2, User, Info, Star, Trash2, Smartphone, Calendar, MapPin, Globe, Briefcase, Building2, Plus, Image as ImageIcon } from 'lucide-react';
import { appSettingApi, reviewApi, authorApi, type AppSetting, type AuthorExperience, type AuthorAdditionalInfo } from '@/api/settings';
import { getPublicStorageUrl } from '@/lib/publicUrl';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';
import { GlassCard } from '@/components/ui/GlassCard';
import { ConfirmModal } from '@/components/ui/ConfirmModal';
import { GlassModal } from '@/components/ui/GlassModal';
import { LanguageFlag } from '@/components/ui/LanguageFlag';
import { cn } from '@/lib/utils';

const SETTINGS_LANGS = ['uz', 'ru', 'en', 'kaa'] as const;
type SettingsLang = (typeof SETTINGS_LANGS)[number];

function pickExpDescription(
  exp: {
    description_uz: string;
    description_ru?: string | null;
    description_en?: string | null;
    description_kaa?: string | null;
  },
  i18n: { language: string },
): string {
  const c = (i18n.language || 'uz').split('-')[0] as 'uz' | 'ru' | 'en' | 'kaa';
  if (c === 'ru' && exp.description_ru?.trim()) return exp.description_ru;
  if (c === 'en' && exp.description_en?.trim()) return exp.description_en;
  if (c === 'kaa' && exp.description_kaa?.trim()) return exp.description_kaa;
  return exp.description_uz || exp.description_ru || exp.description_en || exp.description_kaa || '';
}

function pickInfoField(
  info: { key_uz: string; key_ru: string; key_en: string; value_uz: string; value_ru: string; value_en: string },
  field: 'key' | 'value',
  i18n: { language: string },
): string {
  const c = (i18n.language || 'uz').split('-')[0] as 'uz' | 'ru' | 'en';
  const ku = `${field}_uz` as 'key_uz' | 'value_uz';
  const kr = `${field}_ru` as 'key_ru' | 'value_ru';
  const ke = `${field}_en` as 'key_en' | 'value_en';
  if (c === 'ru' && info[kr]?.trim()) return info[kr];
  if (c === 'en' && info[ke]?.trim()) return info[ke];
  return info[ku] || info[kr] || info[ke] || '';
}

const SettingsPage = () => {
  const { t, i18n } = useTranslation();
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<'app' | 'author' | 'reviews'>('app');
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [deleteType, setDeletingType] = useState<'review' | 'experience' | 'additional'>('review');

  const [isExpModalOpen, setIsExpModalOpen] = useState(false);
  const [isInfoModalOpen, setIsInfoModalOpen] = useState(false);
  const [editingExp, setEditingExp] = useState<Partial<AuthorExperience> | null>(null);
  const [editingInfo, setEditingInfo] = useState<Partial<AuthorAdditionalInfo> | null>(null);
  const [expFormLang, setExpFormLang] = useState<SettingsLang>('uz');
  const [infoFormLang, setInfoFormLang] = useState<SettingsLang>('uz');

  const { data: settingsData, isLoading: isSettingsLoading } = useQuery({
    queryKey: ['settings'],
    queryFn: appSettingApi.get,
  });

  const { data: reviewsData, isLoading: isReviewsLoading } = useQuery({
    queryKey: ['reviews'],
    queryFn: reviewApi.getAll,
  });

  const { data: expData } = useQuery({
    queryKey: ['author_experience'],
    queryFn: authorApi.getExperience,
    enabled: activeTab === 'author',
  });

  const { data: addInfoData } = useQuery({
    queryKey: ['author_additional'],
    queryFn: authorApi.getAdditionalInfo,
    enabled: activeTab === 'author',
  });

  const [formData, setFormData] = useState<Partial<AppSetting>>({});
  const [imageFile, setImageFile] = useState<File | null>(null);

  const imagePreviewUrl = useMemo(() => (imageFile ? URL.createObjectURL(imageFile) : null), [imageFile]);
  useEffect(() => {
    return () => {
      if (imagePreviewUrl) URL.revokeObjectURL(imagePreviewUrl);
    };
  }, [imagePreviewUrl]);

  useEffect(() => {
    if (settingsData?.data.settings) {
      setFormData(settingsData.data.settings);
    }
  }, [settingsData]);

  const updateMutation = useMutation({
    mutationFn: (payload: { data: Partial<AppSetting>; file: File | null }) => {
      const next: Record<string, unknown> = { ...payload.data };
      if (payload.file) next.author_image = payload.file;
      return appSettingApi.update(next);
    },
    onSuccess: (res) => {
      if (res?.status === 'success') {
        queryClient.invalidateQueries({ queryKey: ['settings'] });
        setImageFile(null);
        toast.success(t('toast.settings_saved'));
      } else {
        toast.error(t('toast.settings_save_error'));
      }
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('toast.settings_save_error')));
    },
  });

  const saveExpMutation = useMutation({
    mutationFn: authorApi.saveExperience,
    onSuccess: (res) => {
      if (res?.status === 'success') {
        queryClient.invalidateQueries({ queryKey: ['author_experience'] });
        setIsExpModalOpen(false);
        toast.success(t('toast.experience_saved'));
      }
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const saveInfoMutation = useMutation({
    mutationFn: authorApi.saveAdditionalInfo,
    onSuccess: (res) => {
      if (res?.status === 'success') {
        queryClient.invalidateQueries({ queryKey: ['author_additional'] });
        setIsInfoModalOpen(false);
        toast.success(t('toast.additional_saved'));
      }
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.error_generic'))),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => {
      if (deleteType === 'review') return reviewApi.delete(id);
      if (deleteType === 'experience') return authorApi.deleteExperience(id);
      return authorApi.deleteAdditionalInfo(id);
    },
    onSuccess: (res) => {
      if (res?.status === 'success') {
        queryClient.invalidateQueries({ queryKey: [deleteType === 'review' ? 'reviews' : (deleteType === 'experience' ? 'author_experience' : 'author_additional')] });
        setIsDeleteModalOpen(false);
        toast.success(t('toast.deleted'));
      } else {
        toast.error(t('toast.delete_error'));
      }
    },
    onError: (err) => toast.error(getApiErrorMessage(err, t('toast.delete_error'))),
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    updateMutation.mutate({ data: formData, file: imageFile });
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value } as Partial<AppSetting>));
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setImageFile(e.target.files[0]);
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-app-primary">{t('sidebar.settings')}</h1>
          <p className="text-app-muted mt-1">{t('settings.page_subtitle')}</p>
        </div>
      </div>

      <div className="flex w-fit gap-2 rounded-2xl border border-black/10 bg-black/[0.04] p-1 dark:border-white/10 dark:bg-white/5">
        <button
          onClick={() => setActiveTab('app')}
          className={`flex items-center gap-2 py-2 px-6 rounded-xl text-sm font-bold transition-all ${
            activeTab === 'app' ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary hover:bg-black/5 dark:hover:bg-white/5"
          }`}
        >
          <Info className="w-4 h-4" />
          {t('settings.tab_app')}
        </button>
        <button
          onClick={() => setActiveTab('author')}
          className={`flex items-center gap-2 py-2 px-6 rounded-xl text-sm font-bold transition-all ${
            activeTab === 'author' ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary hover:bg-black/5 dark:hover:bg-white/5"
          }`}
        >
          <User className="w-4 h-4" />
          {t('settings.tab_author')}
        </button>
        <button
          onClick={() => setActiveTab('reviews')}
          className={`flex items-center gap-2 py-2 px-6 rounded-xl text-sm font-bold transition-all ${
            activeTab === 'reviews' ? "bg-purple-500 text-white shadow-lg shadow-purple-500/20" : "text-app-muted hover:text-app-primary hover:bg-black/5 dark:hover:bg-white/5"
          }`}
        >
          <Star className="w-4 h-4" />
          {t('settings.tab_reviews')}
        </button>
      </div>

      {(isSettingsLoading || isReviewsLoading) ? (
        <div className="py-20 text-center">
          <Loader2 className="w-10 h-10 animate-spin mx-auto text-purple-500" />
        </div>
      ) : (
        <div className="space-y-6">
          {activeTab === 'app' && (
            <form onSubmit={handleSubmit} className="space-y-6 animate-in fade-in duration-300">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <GlassCard className="md:col-span-2">
                  <h3 className="text-lg font-bold mb-6 flex items-center gap-2">
                    <Info className="w-5 h-5 text-purple-500" />
                    {t('settings.section_version_links')}
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1">{t('settings.app_version')}</label>
                      <input
                        name="app_version"
                        value={formData.app_version || ''}
                        onChange={handleInputChange}
                        className="input-glass"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1">{t('settings.app_version_code')}</label>
                      <input
                        type="number"
                        name="app_version_code"
                        value={formData.app_version_code || ''}
                        onChange={handleInputChange}
                        className="input-glass"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1">{t('settings.privacy_url')}</label>
                      <input
                        name="privacy_policy_url"
                        value={formData.privacy_policy_url || ''}
                        onChange={handleInputChange}
                        className="input-glass"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1">{t('settings.terms_url')}</label>
                      <input
                        name="terms_url"
                        value={formData.terms_url || ''}
                        onChange={handleInputChange}
                        className="input-glass"
                      />
                    </div>
                  </div>
                </GlassCard>

                <GlassCard className="md:col-span-2">
                  <h3 className="text-lg font-bold mb-6 flex items-center gap-2">
                    <Globe className="w-5 h-5 text-purple-500" />
                    {t('settings.section_about')}
                  </h3>
                  <div className="space-y-6">
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1">{t('languages.uz')}</label>
                      <textarea
                        name="about_app_uz"
                        rows={4}
                        value={formData.about_app_uz || ''}
                        onChange={handleInputChange}
                        className="input-glass resize-none"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1">{t('languages.ru')}</label>
                      <textarea
                        name="about_app_ru"
                        rows={4}
                        value={formData.about_app_ru || ''}
                        onChange={handleInputChange}
                        className="input-glass resize-none"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1">{t('languages.en')}</label>
                      <textarea
                        name="about_app_en"
                        rows={4}
                        value={formData.about_app_en || ''}
                        onChange={handleInputChange}
                        className="input-glass resize-none"
                      />
                    </div>
                  </div>
                </GlassCard>
              </div>
              <div className="flex justify-end pt-4">
                <button type="submit" disabled={updateMutation.isPending} className="btn-primary flex items-center gap-2 px-10">
                  {updateMutation.isPending ? <Loader2 className="w-5 h-5 animate-spin" /> : <Save className="w-5 h-5" />}
                  {t('common.save')}
                </button>
              </div>
            </form>
          )}

          {activeTab === 'author' && (
            <div className="space-y-8 animate-in fade-in duration-300">
              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <GlassCard className="md:col-span-1 flex flex-col items-center justify-center py-10">
                    <div className="relative group cursor-pointer" onClick={() => document.getElementById('author_image_input')?.click()}>
                      <div className="w-40 h-40 rounded-full border-4 border-purple-500/30 overflow-hidden bg-white/5 flex items-center justify-center">
                        {imageFile && imagePreviewUrl ? (
                          <img src={imagePreviewUrl} className="w-full h-full object-cover" alt="" />
                        ) : formData.author_image ? (
                          <img src={getPublicStorageUrl(formData.author_image)} className="w-full h-full object-cover" alt="" />
                        ) : (
                          <ImageIcon className="w-12 h-12 text-app-subtle" />
                        )}
                      </div>
                      <div className="absolute inset-0 rounded-full bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                        <Plus className="w-8 h-8 text-white" />
                      </div>
                      <input id="author_image_input" type="file" className="hidden" onChange={handleFileChange} accept="image/*" />
                    </div>
                    <p className="mt-4 text-sm text-app-muted">{t('settings.tap_to_upload_image')}</p>
                  </GlassCard>

                  <GlassCard className="md:col-span-2">
                    <h3 className="text-lg font-bold mb-6 flex items-center gap-2">
                      <User className="w-5 h-5 text-purple-500" />
                      {t('settings.section_main_info')}
                    </h3>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div className="space-y-2">
                        <label className="text-sm font-medium text-app-subtle ml-1">{t('settings.author_full_name')}</label>
                        <input name="author_name" value={formData.author_name || ''} onChange={handleInputChange} className="input-glass" />
                      </div>
                      <div className="space-y-2">
                        <label className="text-sm font-medium text-app-subtle ml-1">{t('settings.author_role_label')}</label>
                        <input name="author_role" value={formData.author_role || ''} onChange={handleInputChange} className="input-glass" />
                      </div>
                      <div className="space-y-2">
                        <label className="text-sm font-medium text-app-subtle ml-1 flex items-center gap-2"><Calendar className="w-3 h-3" /> {t('settings.author_birth_date')}</label>
                        <input name="author_birth_date" value={formData.author_birth_date || ''} onChange={handleInputChange} className="input-glass" />
                      </div>
                      <div className="space-y-2">
                        <label className="text-sm font-medium text-app-subtle ml-1 flex items-center gap-2"><MapPin className="w-3 h-3" /> {t('settings.author_birth_place')}</label>
                        <input name="author_birth_place" value={formData.author_birth_place || ''} onChange={handleInputChange} className="input-glass" />
                      </div>
                      <div className="space-y-2">
                        <label className="text-sm font-medium text-app-subtle ml-1">{t('settings.author_nationality')}</label>
                        <input name="author_nationality" value={formData.author_nationality || ''} onChange={handleInputChange} className="input-glass" />
                      </div>
                      <div className="space-y-2">
                        <label className="text-sm font-medium text-app-subtle ml-1 flex items-center gap-2"><Globe className="w-3 h-3" /> {t('settings.author_languages')}</label>
                        <input name="author_languages" value={formData.author_languages || ''} onChange={handleInputChange} className="input-glass" />
                      </div>
                    </div>
                  </GlassCard>
                </div>

                <GlassCard>
                  <h3 className="text-lg font-bold mb-6 flex items-center gap-2">
                    <Briefcase className="w-5 h-5 text-purple-500" />
                    {t('settings.current_work')}
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1">{t('settings.work_position')}</label>
                      <input name="author_work_position" value={formData.author_work_position || ''} onChange={handleInputChange} className="input-glass" />
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-app-subtle ml-1 flex items-center gap-2"><Building2 className="w-3 h-3" /> {t('settings.work_organization')}</label>
                      <input name="author_work_organization" value={formData.author_work_organization || ''} onChange={handleInputChange} className="input-glass" />
                    </div>
                  </div>
                </GlassCard>

                <div className="flex justify-end">
                  <button type="submit" disabled={updateMutation.isPending} className="btn-primary flex items-center gap-2 px-10">
                    {updateMutation.isPending ? <Loader2 className="w-5 h-5 animate-spin" /> : <Save className="w-5 h-5" />}
                    {t('settings.save_main_info')}
                  </button>
                </div>
              </form>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <h3 className="text-xl font-bold flex items-center gap-2">
                      <Briefcase className="w-5 h-5 text-purple-500" />
                      {t('settings.section_experience')}
                    </h3>
                    <button
                      type="button"
                      onClick={() => {
                        setExpFormLang('uz');
                        setEditingExp({
                          years: '',
                          description_uz: '',
                          description_ru: '',
                          description_en: '',
                          description_kaa: '',
                        });
                        setIsExpModalOpen(true);
                      }}
                      className="p-2 rounded-xl bg-purple-500/10 text-purple-500 hover:bg-purple-500 hover:text-white transition-all"
                    >
                      <Plus className="w-5 h-5" />
                    </button>
                  </div>
                  <div className="space-y-3">
                    {expData?.data.experiences.map((exp) => (
                      <GlassCard key={exp.id} className="py-3 px-4 group">
                        <div className="flex justify-between items-start">
                          <div>
                            <span className="text-xs font-bold text-purple-500">{exp.years}</span>
                            <p className="text-sm text-app-primary font-medium mt-1">{pickExpDescription(exp, i18n)}</p>
                          </div>
                          <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button
                              type="button"
                              onClick={() => {
                                setExpFormLang('uz');
                                setEditingExp(exp);
                                setIsExpModalOpen(true);
                              }}
                              className="p-1.5 rounded-lg hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-app-primary"
                            >
                              <Save className="w-3.5 h-3.5" />
                            </button>
                            <button onClick={() => { setDeletingId(exp.id); setDeletingType('experience'); setIsDeleteModalOpen(true); }} className="p-1.5 rounded-lg hover:bg-red-500/10 text-app-muted hover:text-red-500"><Trash2 className="w-3.5 h-3.5" /></button>
                          </div>
                        </div>
                      </GlassCard>
                    ))}
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <h3 className="text-xl font-bold flex items-center gap-2">
                      <Info className="w-5 h-5 text-purple-500" />
                      {t('settings.section_additional')}
                    </h3>
                    <button
                      type="button"
                      onClick={() => {
                        setInfoFormLang('uz');
                        setEditingInfo({
                          key_uz: '',
                          key_ru: '',
                          key_en: '',
                          value_uz: '',
                          value_ru: '',
                          value_en: '',
                        });
                        setIsInfoModalOpen(true);
                      }}
                      className="p-2 rounded-xl bg-purple-500/10 text-purple-500 hover:bg-purple-500 hover:text-white transition-all"
                    >
                      <Plus className="w-5 h-5" />
                    </button>
                  </div>
                  <div className="space-y-3">
                    {addInfoData?.data.additional_infos.map((info) => (
                      <GlassCard key={info.id} className="py-3 px-4 group">
                        <div className="flex justify-between items-center">
                          <div className="flex-1 grid grid-cols-2 gap-2 min-w-0">
                            <span className="text-sm text-app-muted truncate">{pickInfoField(info, 'key', i18n)}</span>
                            <span className="text-sm text-app-primary font-bold truncate">{pickInfoField(info, 'value', i18n)}</span>
                          </div>
                          <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity shrink-0">
                            <button
                              type="button"
                              onClick={() => {
                                setInfoFormLang('uz');
                                setEditingInfo(info);
                                setIsInfoModalOpen(true);
                              }}
                              className="p-1.5 rounded-lg hover:bg-black/5 dark:hover:bg-white/10 text-app-muted hover:text-app-primary"
                            >
                              <Save className="w-3.5 h-3.5" />
                            </button>
                            <button onClick={() => { setDeletingId(info.id); setDeletingType('additional'); setIsDeleteModalOpen(true); }} className="p-1.5 rounded-lg hover:bg-red-500/10 text-app-muted hover:text-red-500"><Trash2 className="w-3.5 h-3.5" /></button>
                          </div>
                        </div>
                      </GlassCard>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'reviews' && (
            <div className="space-y-4 animate-in fade-in duration-300">
              {(() => {
                const list = reviewsData?.data?.reviews ?? [];
                const summary = reviewsData?.data?.summary;
                return (
                  <>
                    {summary && summary.total_reviews > 0 && (
                      <GlassCard className="py-4 px-5 flex flex-wrap items-center gap-6 justify-between">
                        <div>
                          <p className="text-xs font-bold uppercase tracking-wide text-app-muted">{t('settings.reviews_summary_title')}</p>
                          <p className="text-2xl font-black text-app-primary mt-1">
                            {summary.average_rating.toFixed(1)}
                            <span className="text-yellow-500 text-lg ml-1">★</span>
                          </p>
                        </div>
                        <div className="text-right">
                          <p className="text-xs text-app-muted">{t('settings.reviews_total_label')}</p>
                          <p className="text-lg font-bold text-app-primary">{summary.total_reviews}</p>
                        </div>
                      </GlassCard>
                    )}
                    {list.length === 0 ? (
                      <div className="py-20 text-center glass-card">
                        <p className="text-app-muted">{t('settings.reviews_empty')}</p>
                      </div>
                    ) : (
                      list.map((review) => (
                        <GlassCard key={review.id} className="py-4">
                          <div className="flex justify-between items-start gap-2">
                            <div className="flex gap-4 min-w-0 flex-1">
                              <div className="w-12 h-12 shrink-0 rounded-full bg-purple-500/10 flex items-center justify-center text-purple-500 font-bold">
                                {review.user?.name?.charAt(0) || '·'}
                              </div>
                              <div className="min-w-0">
                                <div className="flex flex-wrap items-center gap-3">
                                  <h4 className="font-bold text-app-primary truncate">
                                    {review.user?.name || t('settings.review_anonymous')}
                                  </h4>
                                  <div className="flex items-center gap-0.5 shrink-0">
                                    {[...Array(5)].map((_, i) => (
                                      <Star
                                        key={`${review.id}-s-${i}`}
                                        className={`w-3 h-3 ${i < review.rating ? 'text-yellow-500 fill-yellow-500' : 'text-app-subtle'}`}
                                      />
                                    ))}
                                  </div>
                                </div>
                                {review.comment?.trim() ? (
                                  <p className="text-body-secondary mt-1 break-words">{review.comment}</p>
                                ) : null}
                                <div className="flex flex-wrap items-center gap-4 mt-2 text-[10px] text-app-muted">
                                  <span className="flex items-center gap-1 min-w-0">
                                    <Smartphone className="w-3 h-3 shrink-0" />
                                    <span className="truncate">{review.device_info || t('settings.device_unknown')}</span>
                                  </span>
                                  <span>{new Date(review.created_at).toLocaleDateString()}</span>
                                </div>
                              </div>
                            </div>
                            <button
                              type="button"
                              onClick={() => {
                                setDeletingId(review.id);
                                setDeletingType('review');
                                setIsDeleteModalOpen(true);
                              }}
                              className="p-2 rounded-xl hover:bg-red-500/10 text-app-muted hover:text-red-500 transition-all shrink-0"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        </GlassCard>
                      ))
                    )}
                  </>
                );
              })()}
            </div>
          )}
        </div>
      )}

      {/* Experience Modal — UZ / RU / EN */}
      <GlassModal isOpen={isExpModalOpen} onClose={() => setIsExpModalOpen(false)} title={editingExp?.id ? t('common.edit') : t('common.add')}>
        <form
          onSubmit={(e) => {
            e.preventDefault();
            if (!editingExp?.years?.trim()) return;
            if (!editingExp?.description_uz?.trim()) {
              toast.error(t('settings.exp_uz_required'));
              return;
            }
            saveExpMutation.mutate(editingExp);
          }}
          className="space-y-4"
        >
          <div className="space-y-2">
            <label className="text-sm text-app-subtle">{t('settings.exp_years')}</label>
            <input
              value={editingExp?.years || ''}
              onChange={(e) => setEditingExp({ ...editingExp!, years: e.target.value })}
              className="input-glass"
              required
            />
          </div>
          <p className="text-xs font-semibold text-app-subtle tracking-wide uppercase">{t('settings.exp_description')}</p>
          <div className="flex flex-wrap gap-1.5 p-1 rounded-2xl bg-black/[0.04] dark:bg-white/5 border border-black/10 dark:border-white/10">
            {SETTINGS_LANGS.map((code) => (
              <button
                key={code}
                type="button"
                onClick={() => setExpFormLang(code)}
                className={cn(
                  'flex items-center gap-1.5 rounded-xl px-3 py-2 text-xs font-bold transition-all',
                  expFormLang === code
                    ? 'bg-purple-500 text-white shadow-md shadow-purple-500/20'
                    : 'text-app-muted hover:text-app-primary',
                )}
              >
                <LanguageFlag code={code} size="sm" className="shrink-0" />
                {code.toUpperCase()}
              </button>
            ))}
          </div>
          {(() => {
            const k = `description_${expFormLang}` as 'description_uz' | 'description_ru' | 'description_en' | 'description_kaa';
            const sub = {
              uz: t('languages.uz'),
              ru: t('languages.ru'),
              en: t('languages.en'),
              kaa: t('languages.kaa'),
            }[expFormLang];
            return (
              <div className="space-y-2">
                <label className="text-sm text-app-subtle">
                  {t('settings.exp_description')} — {sub}
                </label>
                <textarea
                  value={editingExp?.[k] || ''}
                  onChange={(e) => setEditingExp({ ...editingExp!, [k]: e.target.value })}
                  className="input-glass min-h-[88px] resize-y"
                  rows={3}
                />
              </div>
            );
          })()}
          <p className="text-[11px] text-app-muted">{t('settings.exp_hint')}</p>
          <div className="flex gap-3 pt-2">
            <button type="button" onClick={() => setIsExpModalOpen(false)} className="flex-1 btn-modal-secondary !rounded-xl py-3">
              {t('common.cancel')}
            </button>
            <button type="submit" disabled={saveExpMutation.isPending} className="flex-1 btn-primary">
              {saveExpMutation.isPending ? '...' : t('common.save')}
            </button>
          </div>
        </form>
      </GlassModal>

      {/* Additional Info Modal — UZ / RU / EN */}
      <GlassModal isOpen={isInfoModalOpen} onClose={() => setIsInfoModalOpen(false)} title={editingInfo?.id ? t('common.edit') : t('common.add')}>
        <form
          onSubmit={(e) => {
            e.preventDefault();
            if (!editingInfo?.key_uz?.trim() || !editingInfo?.value_uz?.trim()) {
              toast.error(t('settings.info_uz_required'));
              return;
            }
            saveInfoMutation.mutate(editingInfo);
          }}
          className="space-y-4"
        >
          <div className="flex flex-wrap gap-1.5 p-1 rounded-2xl bg-black/[0.04] dark:bg-white/5 border border-black/10 dark:border-white/10">
            {SETTINGS_LANGS.map((code) => (
              <button
                key={code}
                type="button"
                onClick={() => setInfoFormLang(code)}
                className={cn(
                  'flex items-center gap-1.5 rounded-xl px-3 py-2 text-xs font-bold transition-all',
                  infoFormLang === code
                    ? 'bg-purple-500 text-white shadow-md shadow-purple-500/20'
                    : 'text-app-muted hover:text-app-primary',
                )}
              >
                <LanguageFlag code={code} size="sm" className="shrink-0" />
                {code.toUpperCase()}
              </button>
            ))}
          </div>
          {(() => {
            const keyField = `key_${infoFormLang}` as 'key_uz' | 'key_ru' | 'key_en';
            const valField = `value_${infoFormLang}` as 'value_uz' | 'value_ru' | 'value_en';
            const sub =
              infoFormLang === 'uz' ? t('languages.uz') : infoFormLang === 'ru' ? t('languages.ru') : t('languages.en');
            return (
              <>
                <div className="space-y-2">
                  <label className="text-sm text-app-subtle">
                    {t('settings.info_key')} — {sub}
                  </label>
                  <input
                    value={editingInfo?.[keyField] || ''}
                    onChange={(e) => setEditingInfo({ ...editingInfo!, [keyField]: e.target.value })}
                    className="input-glass"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm text-app-subtle">
                    {t('settings.info_value')} — {sub}
                  </label>
                  <input
                    value={editingInfo?.[valField] || ''}
                    onChange={(e) => setEditingInfo({ ...editingInfo!, [valField]: e.target.value })}
                    className="input-glass"
                  />
                </div>
              </>
            );
          })()}
          <p className="text-[11px] text-app-muted">{t('settings.info_hint')}</p>
          <div className="flex gap-3 pt-2">
            <button type="button" onClick={() => setIsInfoModalOpen(false)} className="flex-1 btn-modal-secondary !rounded-xl py-3">
              {t('common.cancel')}
            </button>
            <button type="submit" disabled={saveInfoMutation.isPending} className="flex-1 btn-primary">
              {saveInfoMutation.isPending ? '...' : t('common.save')}
            </button>
          </div>
        </form>
      </GlassModal>

      <ConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => deletingId && deleteMutation.mutate(deletingId)}
        title={t('settings.delete_confirm_title')}
        message={t('settings.delete_confirm_message')}
        confirmText={t('common.delete')}
        cancelText={t('common.cancel')}
        type="danger"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
};

export default SettingsPage;

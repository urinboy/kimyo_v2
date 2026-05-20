import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useMutation } from '@tanstack/react-query';
import { toast } from 'sonner';
import { LogIn, AtSign, Lock, Loader2, Eye, EyeOff } from 'lucide-react';
import { GlassCard } from '@/components/ui/GlassCard';
import { GlassSelect } from '@/components/ui/GlassSelect';
import { authApi } from '@/api/auth';
import { useAuthStore } from '@/store/useAuthStore';
import { getApiErrorMessage } from '@/lib/apiErrorMessage';

const LoginPage = () => {
  const { t, i18n } = useTranslation();
  const setAuth = useAuthStore((state) => state.setAuth);
  
  const [login, setLogin] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const languages = [
    { value: 'uz', label: t('languages.uz') },
    { value: 'ru', label: t('languages.ru') },
    { value: 'en', label: t('languages.en') },
  ];

  const loginMutation = useMutation({
    mutationFn: authApi.login,
    onSuccess: (response) => {
      if (response.status === 'success') {
        const { user, token } = response.data;
        setAuth(user, token);
        toast.success(t('toast.login_success'));
      } else {
        toast.error(t('auth.error_invalid'));
      }
    },
    onError: (err) => {
      toast.error(getApiErrorMessage(err, t('auth.error_invalid')));
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    loginMutation.mutate({ login, password });
  };

  const handleLanguageChange = (value: string) => {
    i18n.changeLanguage(value);
  };

  return (
    <div className="relative flex items-center justify-center min-h-screen p-6 overflow-hidden">
      {/* Dynamic Background Elements */}
      <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-purple-600/20 rounded-full blur-[120px] animate-pulse" />
      <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-emerald-600/20 rounded-full blur-[120px] animate-pulse" />
      
      <GlassCard className="w-full max-w-md relative z-10">
        <div className="flex justify-between items-center mb-8">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-purple-500 flex items-center justify-center shadow-lg shadow-purple-500/30">
              <LogIn className="w-6 h-6 text-white" />
            </div>
            <h1 className="text-2xl font-bold text-app-primary tracking-tight">
              Kimyo V2
            </h1>
          </div>
          
          <GlassSelect 
            options={languages}
            value={i18n.language}
            onChange={handleLanguageChange}
            className="w-auto"
          />
        </div>

        <div className="mb-8">
          <h2 className="text-3xl font-bold mb-2">{t('auth.welcome_back')}</h2>
          <p className="text-app-muted">{t('auth.subtitle')}</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">
              {t('auth.login_field')}
            </label>
            <div className="relative">
              <AtSign className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-app-muted" />
              <input
                type="text"
                required
                value={login}
                onChange={(e) => setLogin(e.target.value)}
                className="input-glass pl-12"
                placeholder={t('auth.login_placeholder')}
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium text-app-subtle ml-1">
              {t('auth.password')}
            </label>
            <div className="relative">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-app-muted" />
              <input
                type={showPassword ? 'text' : 'password'}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="input-glass pl-12 pr-12"
                placeholder={t('auth.password_placeholder')}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-app-muted transition-colors hover:text-app-primary dark:hover:text-white"
                aria-label={showPassword ? 'Hide password' : 'Show password'}
              >
                {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
          </div>

          <button
            type="submit"
            disabled={loginMutation.isPending}
            className="btn-primary w-full flex items-center justify-center gap-2"
          >
            {loginMutation.isPending ? (
              <Loader2 className="w-5 h-5 animate-spin" />
            ) : (
              t('auth.login_button')
            )}
          </button>
        </form>
      </GlassCard>
    </div>
  );
};

export default LoginPage;

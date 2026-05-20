import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Home, AlertTriangle, Ghost, CloudOff, Lock, Clock } from 'lucide-react';

interface ErrorPageProps {
  code: '403' | '404' | '500' | '503' | '419';
}

const ErrorPage = ({ code }: ErrorPageProps) => {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const getIcon = () => {
    switch (code) {
      case '403': return <Lock className="w-20 h-20 text-red-400" />;
      case '404': return <Ghost className="w-20 h-20 text-purple-400" />;
      case '500': return <AlertTriangle className="w-20 h-20 text-orange-400" />;
      case '503': return <CloudOff className="w-20 h-20 text-emerald-400" />;
      case '419': return <Clock className="w-20 h-20 text-blue-400" />;
      default: return <AlertTriangle className="w-20 h-20 text-app-muted" />;
    }
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center p-6">
      <div className="max-w-md w-full text-center space-y-8 animate-in fade-in zoom-in duration-500">
        <div className="relative">
          {/* Animated Background Glow */}
          <div className="absolute inset-0 bg-purple-500/20 blur-[100px] rounded-full" />
          
          <div className="relative flex flex-col items-center">
            <div className="w-32 h-32 rounded-3xl glass flex items-center justify-center mb-6 shadow-2xl border border-black/5 dark:border-white/20">
              {getIcon()}
            </div>
            
            <h1 className="text-8xl font-black bg-clip-text text-transparent bg-gradient-to-b from-slate-900 to-slate-400 dark:from-white dark:to-white/30">
              {code}
            </h1>
          </div>
        </div>

        <div className="space-y-4">
          <h2 className="text-3xl font-bold text-app-primary">
            {t(`errors.${code}.title`)}
          </h2>
          <p className="text-app-muted text-lg leading-relaxed">
            {t(`errors.${code}.message`)}
          </p>
        </div>

        <div className="pt-8">
          <button
            onClick={() => navigate('/')}
            className="btn-primary w-full flex items-center justify-center gap-3 group"
          >
            <Home className="w-5 h-5 transition-transform group-hover:-translate-y-1" />
            {t('common.back_to_home')}
          </button>
        </div>

        {/* Decorative elements */}
        <div className="flex justify-center gap-2">
          <div className="w-2 h-2 rounded-full bg-black/10 dark:bg-white/10" />
          <div className="w-2 h-2 rounded-full bg-purple-500/40" />
          <div className="w-2 h-2 rounded-full bg-black/10 dark:bg-white/10" />
        </div>
      </div>
    </div>
  );
};

export default ErrorPage;

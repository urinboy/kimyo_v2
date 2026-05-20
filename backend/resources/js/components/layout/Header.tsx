import { User, Bell, Search, Sun, Moon } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { GlassSelect } from '@/components/ui/GlassSelect';
import { useAuthStore } from '@/store/useAuthStore';
import { useThemeStore } from '@/store/useThemeStore';

export const Header = () => {
  const { t, i18n } = useTranslation();
  const user = useAuthStore((state) => state.user);
  const { isDarkMode, toggleTheme } = useThemeStore();

  const languages = [
    { value: 'uz', label: t('languages.uz') },
    { value: 'ru', label: t('languages.ru') },
    { value: 'en', label: t('languages.en') },
  ];

  const handleLanguageChange = (value: string) => {
    i18n.changeLanguage(value);
  };

  return (
    <header className="h-24 flex items-center justify-between px-10 relative z-10">
      <div className="relative w-96">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-app-muted" />
        <input
          type="text"
          placeholder={t('header.search')}
          className="input-glass !py-3 pl-12 pr-4 !text-sm"
        />
      </div>

      {/* Right Side */}
      <div className="flex items-center gap-4">
        <GlassSelect 
          options={languages}
          value={i18n.language}
          onChange={handleLanguageChange}
        />

        <button
          type="button"
          onClick={toggleTheme}
          className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl glass hover:bg-black/5 dark:hover:bg-white/10 transition-all text-app-muted"
          aria-label={isDarkMode ? 'Yorug‘ rejim' : 'Qorong‘i rejim'}
        >
          {isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
        </button>

        <button
          type="button"
          className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl glass hover:bg-black/5 dark:hover:bg-white/10 transition-all relative"
          aria-label={t('header.notifications')}
        >
          <Bell className="w-5 h-5 text-app-muted" />
          <span className="absolute top-2 right-2 w-2 h-2 bg-purple-500 rounded-full border-2 border-white dark:border-slate-950" />
        </button>

        <Link
          to="/profile"
          className="flex items-center gap-4 pl-6 border-l border-black/5 dark:border-white/10 rounded-2xl py-2 pr-3 -my-1 hover:bg-black/5 dark:hover:bg-white/5 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-purple-500/50"
          aria-label={t('header.profile_link')}
        >
          <div className="text-right">
            <p className="text-sm font-bold text-app-primary">{user?.name}</p>
            <p className="text-xs text-app-muted">{t('header.role')}</p>
          </div>
          <div className="w-12 h-12 rounded-2xl glass flex items-center justify-center border-black/5 dark:border-white/20 shrink-0">
            <User className="w-6 h-6 text-purple-500 dark:text-purple-400" />
          </div>
        </Link>
      </div>
    </header>
  );
};

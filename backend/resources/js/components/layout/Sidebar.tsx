import { useEffect, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  LayoutDashboard,
  Users,
  Languages,
  Database,
  LogOut,
  Beaker,
  Shield,
  Building2,
  KeyRound,
  MapPin,
  BookOpen,
  Atom,
  Settings,
  Mountain,
  Layers,
  CloudSun,
  Flag,
  ChevronDown,
  FlaskConical,
  TestTube,
  ListChecks,
  Globe,
  Map,
  FileText,
  Lightbulb,
  FolderKanban,
  ClipboardList,
  UserCog,
  Video,
  Box,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface SidebarItemProps {
  icon: React.ElementType;
  label: string;
  to: string;
  active?: boolean;
  onClick?: () => void;
  className?: string;
  compact?: boolean;
}

const SidebarItem = ({ icon: Icon, label, to, active, onClick, className, compact }: SidebarItemProps) => (
  <Link
    to={to}
    onClick={onClick}
    className={cn(
      'flex items-center gap-3 w-full rounded-2xl transition-all duration-300 group',
      compact ? 'px-3 py-2.5 pl-3' : 'px-4 py-3',
      active
        ? 'bg-purple-500 text-white shadow-lg shadow-purple-500/30'
        : 'text-app-muted hover:bg-black/5 dark:hover:bg-white/5 hover:text-app-primary',
      className,
    )}
  >
    <Icon className={cn('w-5 h-5 shrink-0 transition-transform group-hover:scale-110', active && 'text-white')} />
    <span className="font-medium text-left">{label}</span>
  </Link>
);

function isKimyoPath(pathname: string): boolean {
  return (
    pathname.startsWith('/elements') ||
    pathname.startsWith('/mines') ||
    pathname.startsWith('/lessons') ||
    pathname.startsWith('/interesting-tasks') ||
    pathname.startsWith('/lesson-projects') ||
    pathname.startsWith('/submissions') ||
    pathname.startsWith('/formulas') ||
    pathname.startsWith('/chemical-reactions') ||
    pathname.startsWith('/lab-works') ||
    pathname.startsWith('/videos') ||
    pathname.startsWith('/3d-models')
  );
}

function isGeografiyaPath(pathname: string): boolean {
  return (
    pathname.startsWith('/geography/topics') ||
    pathname.startsWith('/geography/neighbors') ||
    pathname.startsWith('/geography/regions') ||
    pathname.startsWith('/geography/districts')
  );
}

function isAdministrationPath(pathname: string): boolean {
  return (
    pathname === '/languages' ||
    pathname === '/schools' ||
    pathname === '/users' ||
    pathname === '/roles' ||
    pathname === '/permissions'
  );
}

interface SidebarProps {
  onLogout: () => void;
}

export const Sidebar = ({ onLogout }: SidebarProps) => {
  const { t } = useTranslation();
  const location = useLocation();
  const inKimyo = isKimyoPath(location.pathname);
  const inGeografiya = isGeografiyaPath(location.pathname);
  const inAdministration = isAdministrationPath(location.pathname);
  const [kimyoOpen, setKimyoOpen] = useState(inKimyo);
  const [geografiyaOpen, setGeografiyaOpen] = useState(inGeografiya);
  const [administrationOpen, setAdministrationOpen] = useState(inAdministration);

  useEffect(() => {
    if (inKimyo) {
      setKimyoOpen(true);
    } else {
      setKimyoOpen(false);
    }
  }, [inKimyo, location.pathname]);

  useEffect(() => {
    if (inGeografiya) {
      setGeografiyaOpen(true);
    } else {
      setGeografiyaOpen(false);
    }
  }, [inGeografiya, location.pathname]);

  useEffect(() => {
    if (inAdministration) {
      setAdministrationOpen(true);
    } else {
      setAdministrationOpen(false);
    }
  }, [inAdministration, location.pathname]);

  const kimyoExpanded = inKimyo || kimyoOpen;
  const geografiyaExpanded = inGeografiya || geografiyaOpen;
  const administrationExpanded = inAdministration || administrationOpen;

  return (
    <aside className="fixed left-0 top-0 z-20 flex h-screen w-80 flex-col p-6">
      <div className="sidebar-panel flex h-full flex-col rounded-3xl p-6 backdrop-blur-xl">
        <div className="flex items-center gap-3 mb-10 px-2">
          <div className="w-10 h-10 rounded-xl bg-purple-500 flex items-center justify-center shadow-lg shadow-purple-500/30">
            <Beaker className="w-6 h-6 text-white" />
          </div>
          <h1 className="text-xl font-bold tracking-tight text-app-primary">Kimyo V2</h1>
        </div>

        <nav className="flex-1 space-y-2 overflow-y-auto pr-0.5 scrollbar-none">
          <SidebarItem
            icon={LayoutDashboard}
            label={t('sidebar.dashboard')}
            to="/"
            active={location.pathname === '/'}
          />

          <div className="space-y-1">
            <button
              type="button"
              onClick={() => setKimyoOpen((o: boolean) => !o)}
              className={cn(
                'flex w-full items-center justify-between gap-2 rounded-2xl px-4 py-3 text-left transition-all duration-300',
                inKimyo
                  ? 'bg-purple-500/15 text-purple-600 dark:text-purple-300 ring-1 ring-purple-500/30'
                  : 'text-app-muted hover:bg-black/5 dark:hover:bg-white/5 hover:text-app-primary',
              )}
            >
              <span className="flex items-center gap-3 min-w-0">
                <FlaskConical
                  className={cn(
                    'h-5 w-5 shrink-0',
                    inKimyo ? 'text-purple-500 dark:text-purple-400' : 'text-app-muted',
                  )}
                />
                <span className="font-medium">{t('sidebar.kimyo')}</span>
              </span>
              <ChevronDown
                className={cn(
                  'h-4 w-4 shrink-0 transition-transform duration-200',
                  kimyoExpanded && 'rotate-180',
                )}
                aria-hidden
              />
            </button>

            {kimyoExpanded && (
              <div className="ml-1 space-y-1 border-l-2 border-purple-500/20 pl-3 dark:border-purple-500/30">
                <SidebarItem
                  compact
                  icon={Database}
                  label={t('sidebar.elements')}
                  to="/elements"
                  active={location.pathname === '/elements'}
                />
                <SidebarItem
                  compact
                  icon={MapPin}
                  label={t('sidebar.mines')}
                  to="/mines"
                  active={location.pathname === '/mines'}
                />
                <SidebarItem
                  compact
                  icon={BookOpen}
                  label={t('sidebar.lessons')}
                  to="/lessons"
                  active={location.pathname.startsWith('/lessons')}
                />
                <SidebarItem
                  compact
                  icon={FolderKanban}
                  label={t('sidebar.lesson_projects')}
                  to="/lesson-projects"
                  active={location.pathname === '/lesson-projects'}
                />
                <SidebarItem
                  compact
                  icon={Lightbulb}
                  label={t('sidebar.interesting_tasks')}
                  to="/interesting-tasks"
                  active={location.pathname === '/interesting-tasks'}
                />
                <SidebarItem
                  compact
                  icon={ClipboardList}
                  label={t('sidebar.submissions')}
                  to="/submissions"
                  active={location.pathname === '/submissions'}
                />
                <SidebarItem
                  compact
                  icon={Atom}
                  label={t('sidebar.formulas')}
                  to="/formulas"
                  active={location.pathname === '/formulas'}
                />
                <SidebarItem
                  compact
                  icon={TestTube}
                  label={t('sidebar.chemical_reactions')}
                  to="/chemical-reactions"
                  active={location.pathname === '/chemical-reactions'}
                />
                <SidebarItem
                  compact
                  icon={FlaskConical}
                  label={t('sidebar.lab_works')}
                  to="/lab-works"
                  active={location.pathname.startsWith('/lab-works')}
                />
                <SidebarItem
                  compact
                  icon={Video}
                  label={t('sidebar.videos')}
                  to="/videos"
                  active={location.pathname.startsWith('/videos')}
                />
                <SidebarItem
                  compact
                  icon={Box}
                  label={t('sidebar.three_d_models')}
                  to="/3d-models"
                  active={location.pathname.startsWith('/3d-models')}
                />
              </div>
            )}
          </div>

          {/* Geografiya bo'limi */}
          <div className="space-y-1">
            <button
              type="button"
              onClick={() => setGeografiyaOpen((o: boolean) => !o)}
              className={cn(
                'flex w-full items-center justify-between gap-2 rounded-2xl px-4 py-3 text-left transition-all duration-300',
                inGeografiya
                  ? 'bg-emerald-500/15 text-emerald-600 dark:text-emerald-300 ring-1 ring-emerald-500/30'
                  : 'text-app-muted hover:bg-black/5 dark:hover:bg-white/5 hover:text-app-primary',
              )}
            >
              <span className="flex items-center gap-3 min-w-0">
                <Globe
                  className={cn(
                    'h-5 w-5 shrink-0',
                    inGeografiya ? 'text-emerald-500 dark:text-emerald-400' : 'text-app-muted',
                  )}
                />
                <span className="font-medium">{t('sidebar.geografiya')}</span>
              </span>
              <ChevronDown
                className={cn(
                  'h-4 w-4 shrink-0 transition-transform duration-200',
                  geografiyaExpanded && 'rotate-180',
                )}
                aria-hidden
              />
            </button>

            {geografiyaExpanded && (
              <div className="ml-1 space-y-1 border-l-2 border-emerald-500/20 pl-3 dark:border-emerald-500/30">
                <SidebarItem
                  compact
                  icon={Flag}
                  label={t('sidebar.geography_map')}
                  to="/geography/topics?category=map"
                  active={location.pathname === '/geography/topics' && new URLSearchParams(location.search).get('category') === 'map'}
                />
                <SidebarItem
                  compact
                  icon={MapPin}
                  label={t('sidebar.neighbors')}
                  to="/geography/neighbors"
                  active={location.pathname === '/geography/neighbors'}
                />
                <SidebarItem
                  compact
                  icon={Mountain}
                  label={t('sidebar.landscapes')}
                  to="/geography/topics?category=landscapes"
                  active={location.pathname === '/geography/topics' && new URLSearchParams(location.search).get('category') === 'landscapes'}
                />
                <SidebarItem
                  compact
                  icon={Layers}
                  label={t('sidebar.geology')}
                  to="/geography/topics?category=geology"
                  active={location.pathname === '/geography/topics' && new URLSearchParams(location.search).get('category') === 'geology'}
                />
                <SidebarItem
                  compact
                  icon={CloudSun}
                  label={t('sidebar.climate')}
                  to="/geography/topics?category=climate"
                  active={location.pathname === '/geography/topics' && new URLSearchParams(location.search).get('category') === 'climate'}
                />
                {/* Eski bo'limlar (kerak bo'lsa) */}
                <div className="pt-2 mt-2 border-t border-emerald-500/10">
                  <SidebarItem
                    compact
                    icon={Map}
                    label={t('sidebar.regions')}
                    to="/geography/regions"
                    active={location.pathname === '/geography/regions'}
                  />
                </div>
              </div>
            )}
          </div>

          <SidebarItem
            icon={ListChecks}
            label={t('sidebar.app_tests')}
            to="/app-tests"
            active={location.pathname.startsWith('/app-tests')}
          />
          <SidebarItem
            icon={FileText}
            label={t('sidebar.documents')}
            to="/documents"
            active={location.pathname === '/documents'}
          />

          <div className="space-y-1">
            <button
              type="button"
              onClick={() => setAdministrationOpen((o: boolean) => !o)}
              className={cn(
                'flex w-full items-center justify-between gap-2 rounded-2xl px-4 py-3 text-left transition-all duration-300',
                inAdministration
                  ? 'bg-purple-500/15 text-purple-600 dark:text-purple-300 ring-1 ring-purple-500/30'
                  : 'text-app-muted hover:bg-black/5 dark:hover:bg-white/5 hover:text-app-primary',
              )}
            >
              <span className="flex items-center gap-3 min-w-0">
                <UserCog
                  className={cn(
                    'h-5 w-5 shrink-0',
                    inAdministration ? 'text-purple-500 dark:text-purple-400' : 'text-app-muted',
                  )}
                />
                <span className="font-medium">{t('sidebar.administration')}</span>
              </span>
              <ChevronDown
                className={cn(
                  'h-4 w-4 shrink-0 transition-transform duration-200',
                  administrationExpanded && 'rotate-180',
                )}
                aria-hidden
              />
            </button>

            {administrationExpanded && (
              <div className="ml-1 space-y-1 border-l-2 border-purple-500/20 pl-3 dark:border-purple-500/30">
                <SidebarItem
                  compact
                  icon={Languages}
                  label={t('sidebar.languages')}
                  to="/languages"
                  active={location.pathname === '/languages'}
                />
                <SidebarItem
                  compact
                  icon={Building2}
                  label={t('sidebar.schools')}
                  to="/schools"
                  active={location.pathname === '/schools'}
                />
                <SidebarItem
                  compact
                  icon={Users}
                  label={t('sidebar.users')}
                  to="/users"
                  active={location.pathname === '/users'}
                />
                <SidebarItem
                  compact
                  icon={Shield}
                  label={t('sidebar.roles_management')}
                  to="/roles"
                  active={location.pathname === '/roles'}
                />
                <SidebarItem
                  compact
                  icon={KeyRound}
                  label={t('sidebar.permissions_management')}
                  to="/permissions"
                  active={location.pathname === '/permissions'}
                />
              </div>
            )}
          </div>
          <SidebarItem
            icon={Settings}
            label={t('sidebar.settings')}
            to="/settings"
            active={location.pathname === '/settings'}
          />
        </nav>

        <div className="pt-6 border-t border-black/5 dark:border-white/10">
          <Link
            to="#"
            onClick={(e) => {
              e.preventDefault();
              onLogout();
            }}
            className="flex items-center gap-3 w-full px-4 py-3 rounded-2xl text-app-muted hover:bg-black/5 dark:hover:bg-white/5 hover:text-app-primary transition-all"
          >
            <LogOut className="w-5 h-5 flex-shrink-0" />
            <span className="font-medium">{t('sidebar.logout')}</span>
          </Link>
        </div>
      </div>
    </aside>
  );
}

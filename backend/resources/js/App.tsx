import { useState, useEffect, lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider, useMutation } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { Toaster } from 'sonner';
import { toast } from 'sonner';
import { useAuthStore } from './store/useAuthStore';
import { useThemeStore } from './store/useThemeStore';
import { GlassModal } from './components/ui/GlassModal';
import { authApi } from './api/auth';
import { DashboardLayout } from './components/layout/DashboardLayout';

const LoginPage = lazy(() => import('./pages/auth/LoginPage'));
const DashboardPage = lazy(() => import('./pages/DashboardPage'));
const LanguagesPage = lazy(() => import('./pages/languages/LanguagesPage'));
const ElementsPage = lazy(() => import('./pages/elements/ElementsPage'));
const ErrorPage = lazy(() => import('./pages/errors/ErrorPage'));
const SchoolsPage = lazy(() => import('./pages/schools/SchoolsPage'));
const SchoolDetailPage = lazy(() => import('./pages/schools/SchoolDetailPage'));
const UsersPage = lazy(() => import('./pages/users/UsersPage'));
const RolesPage = lazy(() => import('./pages/users/RolesPage'));
const PermissionsPage = lazy(() => import('./pages/users/PermissionsPage'));
const MinesPage = lazy(() => import('./pages/mines/MinesPage'));
const LessonsPage = lazy(() => import('./pages/lessons/LessonsPage'));
const FormulasPage = lazy(() => import('./pages/formulas/FormulasPage'));
const ChemicalReactionsPage = lazy(() => import('./pages/chemicalReactions/ChemicalReactionsPage'));
const AppTestsPage = lazy(() => import('./pages/appTests/AppTestsPage'));
const AppQuizQuestionsPage = lazy(() => import('./pages/appTests/AppQuizQuestionsPage'));
const AppQuizAnswersPage = lazy(() => import('./pages/appTests/AppQuizAnswersPage'));
const SettingsPage = lazy(() => import('./pages/SettingsPage'));
const ProfilePage = lazy(() => import('./pages/ProfilePage'));
const QuizManagement = lazy(() => import('./pages/lessons/QuizManagement'));
const RegionsPage = lazy(() => import('./pages/geography/RegionsPage'));
const DistrictsPage = lazy(() => import('./pages/geography/DistrictsPage'));
const NeighborCountriesPage = lazy(() => import('./pages/geography/NeighborCountriesPage'));
const GeographyTopicsPage = lazy(() => import('./pages/geography/GeographyTopicsPage'));
const DocumentsPage = lazy(() => import('./pages/documents/DocumentsPage'));
const InterestingTasksPage = lazy(() => import('./pages/interestingTasks/InterestingTasksPage'));
const SubmissionsPage = lazy(() => import('./pages/interestingTasks/SubmissionsPage'));
const LabWorksPage = lazy(() => import('./pages/LabWorksPage'));

function RouteFallback() {
  return (
    <div className="min-h-screen flex items-center justify-center" style={{ background: 'var(--page-gradient, var(--page-bg))' }}>
      <div
        className="h-10 w-10 rounded-full border-2 border-purple-500/25 border-t-purple-500 animate-spin"
        role="status"
        aria-label="Loading"
      />
    </div>
  );
}

const queryClient = new QueryClient();

function MainContent() {
  const { t } = useTranslation();
  const { isAuthenticated, logout } = useAuthStore();
  const { isDarkMode } = useThemeStore();
  const [isLogoutModalOpen, setIsLogoutModalOpen] = useState(false);

  useEffect(() => {
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDarkMode]);

  const logoutMutation = useMutation({
    mutationFn: authApi.logout,
    onSuccess: () => {
      toast.success(t('toast.logout_success'));
      logout();
      setIsLogoutModalOpen(false);
    },
    onError: () => {
      logout();
      setIsLogoutModalOpen(false);
    },
  });

  if (!isAuthenticated) {
    return (
      <Suspense fallback={<RouteFallback />}>
        <LoginPage />
      </Suspense>
    );
  }

  return (
    <DashboardLayout onLogout={() => setIsLogoutModalOpen(true)}>
      <Suspense fallback={<RouteFallback />}>
        <Routes>
          <Route path="/" element={<DashboardPage />} />
          <Route path="/languages" element={<LanguagesPage />} />
          <Route path="/elements" element={<ElementsPage />} />
          <Route path="/schools" element={<SchoolsPage />} />
          <Route path="/schools/:id" element={<SchoolDetailPage />} />
          <Route path="/users" element={<UsersPage />} />
          <Route path="/roles" element={<RolesPage />} />
          <Route path="/permissions" element={<PermissionsPage />} />
          <Route path="/mines" element={<MinesPage />} />
          <Route path="/lessons" element={<LessonsPage />} />
          <Route path="/lessons/:id/quiz" element={<QuizManagement />} />
          <Route path="/app-tests" element={<AppTestsPage />} />
          <Route path="/app-tests/:id/questions" element={<AppQuizQuestionsPage />} />
          <Route path="/app-tests/:id/answers" element={<AppQuizAnswersPage />} />
          <Route path="/formulas" element={<FormulasPage />} />
          <Route path="/chemical-reactions" element={<ChemicalReactionsPage />} />
          <Route path="/documents" element={<DocumentsPage />} />
          <Route path="/settings" element={<SettingsPage />} />
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/geography/regions" element={<RegionsPage />} />
          <Route path="/geography/districts" element={<DistrictsPage />} />
          <Route path="/geography/neighbors" element={<NeighborCountriesPage />} />
          <Route path="/geography/topics" element={<GeographyTopicsPage />} />
          <Route path="/interesting-tasks" element={<InterestingTasksPage mode="interesting" />} />
          <Route path="/lesson-projects" element={<InterestingTasksPage mode="project" />} />
          <Route path="/submissions" element={<SubmissionsPage />} />
          <Route path="/lab-works" element={<LabWorksPage />} />
          <Route path="*" element={<ErrorPage code="404" />} />
        </Routes>
      </Suspense>

      <GlassModal
        isOpen={isLogoutModalOpen}
        onClose={() => setIsLogoutModalOpen(false)}
        title={t('auth.logout_confirm_title')}
      >
        <p className="mb-8 text-app-muted">
          {t('auth.logout_confirm_message')}
        </p>
        <div className="flex gap-4">
          <button
            type="button"
            onClick={() => setIsLogoutModalOpen(false)}
            className="flex-1 btn-modal-secondary"
          >
            {t('auth.cancel')}
          </button>
          <button
            type="button"
            onClick={() => logoutMutation.mutate()}
            disabled={logoutMutation.isPending}
            className="flex-1 btn-primary"
          >
            {logoutMutation.isPending ? '...' : t('auth.confirm')}
          </button>
        </div>
      </GlassModal>
    </DashboardLayout>
  );
}

function ThemedToaster() {
  const { isDarkMode } = useThemeStore();
  return <Toaster position="top-right" theme={isDarkMode ? 'dark' : 'light'} richColors closeButton />;
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <MainContent />
        <ThemedToaster />
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;

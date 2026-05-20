import { Sidebar } from './Sidebar';
import { Header } from './Header';

interface DashboardLayoutProps {
  children: React.ReactNode;
  onLogout: () => void;
}

export const DashboardLayout = ({ children, onLogout }: DashboardLayoutProps) => {
  return (
    <div className="flex min-h-screen selection:bg-purple-500/30">
      {/* Yengil: yumshoq nur; qorong‘i: chuqurroq */}
      <div
        className="fixed top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full blur-[120px] pointer-events-none bg-purple-400/20 dark:bg-purple-600/25"
        aria-hidden
      />
      <div
        className="fixed bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full blur-[120px] pointer-events-none bg-emerald-400/15 dark:bg-emerald-600/20"
        aria-hidden
      />

      <Sidebar onLogout={onLogout} />

      <main className="relative z-10 flex-1 ml-80 flex min-h-screen flex-col">
        <Header />
        <div className="flex-1 overflow-y-auto p-10 scrollbar-none">{children}</div>
      </main>
    </div>
  );
};

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { labWorksApi } from '../api/labWorks';
import type { LabWork } from '../api/labWorks';
import { GlassCard } from '../components/ui/GlassCard';
import { FlaskConical, Plus, Pencil, Trash2, ChevronRight, BookOpen, Beaker } from 'lucide-react';
import { toast } from 'sonner';
import { LabWorkModal } from '@/components/lab/LabWorkModal';

function StatusBadge({ status }: { status: 'active' | 'inactive' }) {
  return (
    <span className={`text-xs font-bold px-2 py-0.5 rounded-lg ${
      status === 'active'
        ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400'
        : 'bg-gray-500/10 text-gray-500'
    }`}>
      {status === 'active' ? 'Faol' : 'Nofaol'}
    </span>
  );
}

export default function LabWorksPage() {
  const qc = useQueryClient();
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<LabWork | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['lab-works'],
    queryFn: labWorksApi.getAll,
  });

  const deleteMutation = useMutation({
    mutationFn: labWorksApi.remove,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['lab-works'] });
      toast.success("Laboratoriya o'chirildi");
    },
    onError: () => toast.error("O'chirishda xato yuz berdi"),
  });

  const labs = data?.data.lab_works ?? [];

  const handleEdit = (lab: LabWork) => {
    setEditing(lab);
    setModalOpen(true);
  };

  const handleNew = () => {
    setEditing(null);
    setModalOpen(true);
  };

  const handleDelete = (lab: LabWork) => {
    if (!confirm(`"${lab.number}-Laboratoriya" ni o'chirmoqchimisiz?`)) return;
    deleteMutation.mutate(lab.id);
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-6 duration-700">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-4xl font-black tracking-tight text-app-primary">
            Laboratoriya Ishlari
          </h1>
          <p className="text-body-secondary mt-2 flex items-center gap-2">
            <FlaskConical className="w-4 h-4 text-purple-600 dark:text-purple-400" />
            Kimyo laboratoriya tajribalari va javoblari
          </p>
        </div>
        <button onClick={handleNew} className="btn-primary px-6 py-3 flex items-center gap-2">
          <Plus className="w-4 h-4" />
          Yangi Laboratoriya
        </button>
      </div>

      {/* Stats row */}
      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
        <GlassCard className="p-6">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-purple-500/10">
              <FlaskConical className="w-5 h-5 text-purple-600 dark:text-purple-400" />
            </div>
            <div>
              <p className="text-3xl font-black text-app-primary">{labs.length}</p>
              <p className="text-caption">Jami laboratoriya</p>
            </div>
          </div>
        </GlassCard>
        <GlassCard className="p-6">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-emerald-500/10">
              <Beaker className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
            </div>
            <div>
              <p className="text-3xl font-black text-app-primary">
                {labs.filter(l => l.status === 'active').length}
              </p>
              <p className="text-caption">Faol</p>
            </div>
          </div>
        </GlassCard>
        <GlassCard className="p-6">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-blue-500/10">
              <BookOpen className="w-5 h-5 text-blue-600 dark:text-blue-400" />
            </div>
            <div>
              <p className="text-3xl font-black text-app-primary">
                {labs.reduce((s, l) => s + (l.experiments_count ?? 0), 0)}
              </p>
              <p className="text-caption">Jami tajriba</p>
            </div>
          </div>
        </GlassCard>
      </div>

      {/* Table */}
      <GlassCard className="overflow-hidden">
        <div className="p-6 border-b border-black/5 dark:border-white/5">
          <h3 className="font-bold text-app-primary flex items-center gap-2">
            <FlaskConical className="w-4 h-4 text-purple-600 dark:text-purple-400" />
            Laboratoriyalar ro'yxati
          </h3>
        </div>

        {isLoading ? (
          <div className="p-8 space-y-3">
            {[1,2,3].map(i => (
              <div key={i} className="h-14 rounded-xl bg-black/5 dark:bg-white/5 animate-pulse" />
            ))}
          </div>
        ) : labs.length === 0 ? (
          <div className="p-16 text-center">
            <FlaskConical className="w-12 h-12 text-app-muted mx-auto mb-4 opacity-30" />
            <p className="text-body-secondary">Hali laboratoriya qo'shilmagan</p>
            <button onClick={handleNew} className="mt-4 btn-primary px-5 py-2.5 text-sm">
              Birinchisini qo'shing
            </button>
          </div>
        ) : (
          <div className="divide-y divide-black/5 dark:divide-white/5">
            {labs.map(lab => {
              const uzTitle = lab.translations.find(t =>
                (t as unknown as { language?: { code: string } }).language?.code === 'uz'
              )?.title ?? lab.translations[0]?.title ?? `${lab.number}-Laboratoriya`;

              return (
                <div key={lab.id} className="flex items-center gap-4 px-6 py-4 hover:bg-black/[0.02] dark:hover:bg-white/[0.02] transition-colors group">
                  {/* Number badge */}
                  <div className="w-11 h-11 rounded-xl bg-purple-500/10 flex items-center justify-center font-black text-purple-600 dark:text-purple-400 text-sm flex-shrink-0">
                    {lab.number}
                  </div>

                  {/* Title & meta */}
                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-sm text-app-primary truncate">{uzTitle}</p>
                    <p className="text-caption mt-0.5">
                      {lab.experiments_count ?? 0} ta tajriba
                    </p>
                  </div>

                  <StatusBadge status={lab.status} />

                  {/* Actions */}
                  <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button
                      onClick={() => handleEdit(lab)}
                      className="p-2 rounded-lg hover:bg-black/5 dark:hover:bg-white/5 text-app-muted hover:text-purple-600 dark:hover:text-purple-400 transition-colors"
                      title="Tahrirlash"
                    >
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(lab)}
                      className="p-2 rounded-lg hover:bg-red-500/10 text-app-muted hover:text-red-600 dark:hover:text-red-400 transition-colors"
                      title="O'chirish"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                    <ChevronRight className="w-4 h-4 text-app-muted" />
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </GlassCard>

      {/* Modal */}
      {modalOpen && (
        <LabWorkModal
          labWork={editing}
          onClose={() => { setModalOpen(false); setEditing(null); }}
        />
      )}
    </div>
  );
}

<?php

namespace App\Repositories\Eloquent;

use App\Models\LabWork;
use App\Models\Language;
use App\Repositories\Interfaces\LabWorkRepositoryInterface;
use Illuminate\Support\Facades\DB;

class LabWorkRepository implements LabWorkRepositoryInterface
{
    /** Ro'yxat: translations bilan (experiments yuklanmaydi — siz yuboring kerak bo'lsa) */
    public function all(): \Illuminate\Database\Eloquent\Collection
    {
        return LabWork::with([
            'translations.language:id,code',
        ])
            ->withCount('experiments')
            ->orderBy('number')
            ->get();
    }

    /** Bitta lab: to'liq nested eager load */
    public function find(int $id): ?LabWork
    {
        return LabWork::with([
            'translations.language:id,code',
            'experiments' => function ($q) { $q->orderBy('order_index'); },
            'experiments.translations.language:id,code',
            'experiments.reactions',
            'experiments.observations.translations.language:id,code',
            'experiments.products.translations.language:id,code',
        ])->find($id);
    }

    public function create(array $data): LabWork
    {
        return DB::transaction(function () use ($data) {
            $lab = LabWork::create([
                'number' => $data['number'],
                'status' => $data['status'] ?? 'active',
            ]);

            $this->syncTranslations($lab, $data['translations'] ?? []);

            if (!empty($data['experiments'])) {
                $this->syncExperiments($lab, $data['experiments']);
            }

            return $this->find($lab->id);
        });
    }

    public function update(int $id, array $data): ?LabWork
    {
        return DB::transaction(function () use ($id, $data) {
            $lab = LabWork::find($id);
            if (!$lab) return null;

            $lab->update([
                'number' => $data['number'] ?? $lab->number,
                'status' => $data['status'] ?? $lab->status,
            ]);

            if (isset($data['translations'])) {
                $this->syncTranslations($lab, $data['translations']);
            }

            if (isset($data['experiments'])) {
                $this->syncExperiments($lab, $data['experiments']);
            }

            return $this->find($lab->id);
        });
    }

    public function delete(int $id): bool
    {
        $lab = LabWork::find($id);
        if (!$lab) return false;
        return (bool) $lab->delete();
    }

    // ─── Private helpers ────────────────────────────────────────────────────

    private function syncTranslations(LabWork $lab, array $translations): void
    {
        foreach ($translations as $t) {
            $lang = Language::where('code', $t['language_code'] ?? '')->first()
                 ?? Language::find($t['language_id'] ?? 0);
            if (!$lang) continue;

            $lab->translations()->updateOrCreate(
                ['language_id' => $lang->id],
                ['title' => $t['title'], 'description' => $t['description'] ?? null]
            );
        }
    }

    private function syncExperiments(LabWork $lab, array $experiments): void
    {
        // Berilgan ID lardan tashqari eskilerini o'chirish
        $incomingIds = collect($experiments)->pluck('id')->filter()->all();
        $lab->experiments()->whereNotIn('id', $incomingIds)->delete();

        foreach ($experiments as $expData) {
            $exp = $lab->experiments()->updateOrCreate(
                ['id' => $expData['id'] ?? null],
                [
                    'type'        => $expData['type'] ?? 'probirka',
                    'order_index' => $expData['order_index'] ?? 1,
                    'status'      => $expData['status'] ?? 'active',
                ]
            );

            // Translations
            foreach ($expData['translations'] ?? [] as $t) {
                $lang = Language::where('code', $t['language_code'] ?? '')->first()
                     ?? Language::find($t['language_id'] ?? 0);
                if (!$lang) continue;
                $exp->translations()->updateOrCreate(
                    ['language_id' => $lang->id],
                    [
                        'title'                  => $t['title'],
                        'scientific_explanation' => $t['scientific_explanation'] ?? null,
                    ]
                );
            }

            // Reactions
            $exp->reactions()->delete();
            foreach ($expData['reactions'] ?? [] as $r) {
                $exp->reactions()->create([
                    'formula'     => $r['formula'],
                    'type'        => $r['type'] ?? 'molecular',
                    'order_index' => $r['order_index'] ?? 1,
                ]);
            }

            // Observations
            $exp->observations()->delete();
            foreach ($expData['observations'] ?? [] as $ob) {
                $obs = $exp->observations()->create(['order_index' => $ob['order_index'] ?? 1]);
                foreach ($ob['translations'] ?? [] as $t) {
                    $lang = Language::where('code', $t['language_code'] ?? '')->first()
                         ?? Language::find($t['language_id'] ?? 0);
                    if (!$lang) continue;
                    $obs->translations()->create(['language_id' => $lang->id, 'text' => $t['text']]);
                }
            }

            // Products
            $exp->products()->delete();
            foreach ($expData['products'] ?? [] as $pr) {
                $prod = $exp->products()->create([
                    'chemical_formula' => $pr['chemical_formula'],
                    'state'            => $pr['state'] ?? 'dissolved',
                    'order_index'      => $pr['order_index'] ?? 1,
                ]);
                foreach ($pr['translations'] ?? [] as $t) {
                    $lang = Language::where('code', $t['language_code'] ?? '')->first()
                         ?? Language::find($t['language_id'] ?? 0);
                    if (!$lang) continue;
                    $prod->translations()->create(['language_id' => $lang->id, 'name' => $t['name']]);
                }
            }
        }
    }
}

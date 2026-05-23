<?php

namespace App\Repositories\Eloquent;

use App\Models\Language;
use App\Models\ThreeDModel;
use App\Repositories\Interfaces\ThreeDModelRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ThreeDModelRepository implements ThreeDModelRepositoryInterface
{
    private function baseQuery(): \Illuminate\Database\Eloquent\Builder
    {
        return ThreeDModel::with([
            'translations.language:id,code',
            'element:id,symbol,atomic_number',
        ])->orderBy('sort_order', 'desc')->orderByDesc('id');
    }

    public function all(bool $activeOnly = false): Collection
    {
        $q = $this->baseQuery();
        if ($activeOnly) {
            $q->where('is_active', true);
        }
        return $q->get();
    }

    public function find(int $id): ?ThreeDModel
    {
        return $this->baseQuery()->find($id);
    }

    public function create(array $data): ThreeDModel
    {
        return DB::transaction(function () use ($data) {
            $model = ThreeDModel::create([
                'slug'       => $data['slug'],
                'model_path' => $data['model_path'] ?? null,
                'element_id' => $data['element_id'] ?? null,
                'sort_order' => $data['sort_order'] ?? 0,
                'is_active'  => $data['is_active'] ?? true,
            ]);

            if (! empty($data['translations'])) {
                $this->syncTranslations($model, $data['translations']);
            }

            return $this->find($model->id);
        });
    }

    public function update(int $id, array $data): ?ThreeDModel
    {
        $model = ThreeDModel::find($id);
        if (! $model) {
            return null;
        }

        return DB::transaction(function () use ($model, $data) {
            // Eski fayl o'chirish: yangi fayl yuklanganda yoki remove_model_file=true bo'lsa
            if (array_key_exists('model_path', $data)) {
                if ($model->model_path && $model->model_path !== $data['model_path']) {
                    Storage::disk('public')->delete($model->model_path);
                }
            }

            $model->update([
                'slug'       => $data['slug']       ?? $model->slug,
                'model_path' => array_key_exists('model_path', $data)  ? $data['model_path'] : $model->model_path,
                'element_id' => array_key_exists('element_id', $data)  ? $data['element_id'] : $model->element_id,
                'sort_order' => $data['sort_order'] ?? $model->sort_order,
                'is_active'  => $data['is_active']  ?? $model->is_active,
            ]);

            if (isset($data['translations'])) {
                $this->syncTranslations($model, $data['translations']);
            }

            return $this->find($model->id);
        });
    }

    public function delete(int $id): bool
    {
        $model = ThreeDModel::find($id);
        if (! $model) {
            return false;
        }

        if ($model->model_path) {
            Storage::disk('public')->delete($model->model_path);
        }

        return (bool) $model->delete();
    }

    private function syncTranslations(ThreeDModel $model, array $translations): void
    {
        foreach ($translations as $t) {
            $langId = null;

            if (! empty($t['language_id'])) {
                $langId = (int) $t['language_id'];
            } elseif (! empty($t['language_code'])) {
                $lang = Language::where('code', $t['language_code'])->first();
                $langId = $lang?->id;
            }

            if (! $langId) {
                continue;
            }

            $model->translations()->updateOrCreate(
                ['language_id' => $langId],
                [
                    'name'        => $t['name']        ?? '',
                    'description' => $t['description'] ?? null,
                ]
            );
        }
    }
}

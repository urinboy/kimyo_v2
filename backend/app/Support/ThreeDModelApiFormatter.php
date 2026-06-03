<?php

namespace App\Support;

use App\Models\ThreeDModel;
use Illuminate\Support\Facades\Storage;

class ThreeDModelApiFormatter
{
    /**
     * Mobil uchun ro'yxat elementi (bitta til).
     */
    public static function listItem(ThreeDModel $model, ?string $lang = null): array
    {
        $lang = $lang ?? 'uz';
        $translation = $model->translations->first(fn($t) => $t->language?->code === $lang)
            ?? $model->translations->first();

        return [
            'id'         => $model->id,
            'slug'       => $model->slug,
            'model_url'  => self::resolveModelUrl($model),
            'element_id' => $model->element_id,
            'element'    => $model->element
                ? ['id' => $model->element->id, 'symbol' => $model->element->symbol, 'atomic_number' => $model->element->atomic_number]
                : null,
            'sort_order' => $model->sort_order,
            'name'        => $translation?->name,
            'description' => $translation?->description,
        ];
    }

    /**
     * Admin uchun to'liq resurs (barcha tarjimalar).
     */
    public static function adminResource(ThreeDModel $model): array
    {
        $translations = $model->translations->map(fn($t) => [
            'language_id'   => $t->language_id,
            'language_code' => $t->language?->code,
            'name'          => $t->name,
            'description'   => $t->description,
        ])->values()->all();

        return [
            'id'          => $model->id,
            'slug'        => $model->slug,
            'model_path'  => $model->model_path,
            'model_url'   => self::resolveModelUrl($model),
            'element_id'  => $model->element_id,
            'element'     => $model->element
                ? ['id' => $model->element->id, 'symbol' => $model->element->symbol, 'atomic_number' => $model->element->atomic_number]
                : null,
            'sort_order'  => $model->sort_order,
            'is_active'   => $model->is_active,
            'translations' => $translations,
            'created_at'  => $model->created_at?->toISOString(),
        ];
    }

    private static function resolveModelUrl(ThreeDModel $model): ?string
    {
        if (! $model->model_path) {
            return null;
        }

        return Storage::disk('public')->exists($model->model_path)
            ? url('api/v1/public-storage/' . $model->model_path)
            : null;
    }
}

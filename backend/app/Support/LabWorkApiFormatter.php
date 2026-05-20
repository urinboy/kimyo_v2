<?php

namespace App\Support;

use App\Models\LabExperiment;
use App\Models\LabObservation;
use App\Models\LabProduct;
use App\Models\LabWork;
use Illuminate\Support\Collection;

class LabWorkApiFormatter
{
    /** @param  Collection<int, object>  $items */
    private static function pickTranslations(Collection $items, ?string $lang): Collection
    {
        if (!$lang) {
            return $items;
        }

        $code = fn ($t) => $t->language?->code ?? null;

        $match = $items->first(fn ($t) => $code($t) === $lang);
        $fallback = $items->first(fn ($t) => $code($t) === 'uz') ?? $items->first();

        return collect($match ? [$match] : ($fallback ? [$fallback] : []));
    }

    /** Mobil ro'yxat — faqat title (description yo'q), ixtiyoriy bitta til. */
    public static function listItem(LabWork $lab, ?string $lang = null): array
    {
        return [
            'id'                => $lab->id,
            'number'            => $lab->number,
            'status'            => $lab->status,
            'experiments_count' => $lab->experiments_count,
            'translations'      => self::pickTranslations($lab->translations, $lang)
                ->map(fn ($t) => [
                    'language_code' => $t->language?->code,
                    'title'         => $t->title,
                ])->values()->all(),
        ];
    }

    /** Mobil bitta lab — nested ma'lumot, til bo'yicha yengillashtirilgan. */
    public static function detail(LabWork $lab, ?string $lang = null): array
    {
        return [
            'id'           => $lab->id,
            'number'       => $lab->number,
            'status'       => $lab->status,
            'translations' => self::pickTranslations($lab->translations, $lang)
                ->map(fn ($t) => [
                    'language_code' => $t->language?->code,
                    'title'         => $t->title,
                    'description'   => $t->description,
                ])->values()->all(),
            'experiments'  => $lab->experiments->map(fn (LabExperiment $exp) => [
                'id'          => $exp->id,
                'type'        => $exp->type,
                'order_index' => $exp->order_index,
                'status'      => $exp->status,
                'translations' => self::pickTranslations($exp->translations, $lang)
                    ->map(fn ($t) => [
                        'language_code'          => $t->language?->code,
                        'title'                  => $t->title,
                        'scientific_explanation' => $t->scientific_explanation,
                    ])->values()->all(),
                'reactions'   => $exp->reactions->map(fn ($r) => [
                    'id'          => $r->id,
                    'formula'     => $r->formula,
                    'type'        => $r->type,
                    'order_index' => $r->order_index,
                ])->values()->all(),
                'observations' => $exp->observations->map(fn (LabObservation $ob) => [
                    'id'          => $ob->id,
                    'order_index' => $ob->order_index,
                    'translations' => self::pickTranslations($ob->translations, $lang)
                        ->map(fn ($t) => [
                            'language_code' => $t->language?->code,
                            'text'          => $t->text,
                        ])->values()->all(),
                ])->values()->all(),
                'products'    => $exp->products->map(fn (LabProduct $p) => [
                    'id'               => $p->id,
                    'chemical_formula' => $p->chemical_formula,
                    'state'            => $p->state,
                    'order_index'      => $p->order_index,
                    'translations'     => self::pickTranslations($p->translations, $lang)
                        ->map(fn ($t) => [
                            'language_code' => $t->language?->code,
                            'name'          => $t->name,
                        ])->values()->all(),
                ])->values()->all(),
            ])->values()->all(),
        ];
    }
}

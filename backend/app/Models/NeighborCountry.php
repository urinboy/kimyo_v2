<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NeighborCountry extends Model
{
    protected $fillable = [
        'code', 'sort_order', 'name_uz', 'name_ru', 'name_en',
        'capital_uz', 'capital_ru', 'capital_en',
        'description_uz', 'description_ru', 'description_en',
        'area_km2', 'population_mn',
        'languages_uz', 'languages_ru', 'languages_en',
        'currency_uz', 'currency_ru', 'currency_en',
        'border_with_uz_km', 'flag_emoji',
    ];

    protected function casts(): array
    {
        return [
            'population_mn' => 'float',
        ];
    }
}

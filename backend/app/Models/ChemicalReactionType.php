<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChemicalReactionType extends Model
{
    protected $fillable = [
        'name_uz',
        'name_ru',
        'name_en',
        'name_kaa',
        'formula',
        'description_uz',
        'description_ru',
        'description_en',
        'description_kaa',
        'modal_formula',
        'modal_badge_uz',
        'modal_badge_ru',
        'modal_badge_en',
        'modal_badge_kaa',
        'examples',
        'color_hex',
        'icon_color_hex',
        'order',
    ];

    protected function casts(): array
    {
        return [
            'examples' => 'array',
        ];
    }
}

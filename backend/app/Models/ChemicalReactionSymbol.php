<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChemicalReactionSymbol extends Model
{
    protected $fillable = [
        'symbol',
        'desc_uz',
        'desc_ru',
        'desc_en',
        'desc_kaa',
        'order',
    ];
}

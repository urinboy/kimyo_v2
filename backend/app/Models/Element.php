<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Element extends Model
{
    protected $fillable = [
        'atomic_number',
        'symbol',
        'mass',
        'color_hex',
        'type',
    ];

    public function translations()
    {
        return $this->hasMany(ElementTranslation::class);
    }

    public function formulas()
    {
        return $this->belongsToMany(Formula::class, 'element_formula')
            ->withPivot('amount')
            ->withTimestamps();
    }
}

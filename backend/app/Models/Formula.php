<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Formula extends Model
{
    protected $fillable = [
        'formula',
        'molar_mass',
        'category',
    ];

    /**
     * @return HasMany
     */
    public function translations(): HasMany
    {
        return $this->hasMany(FormulaTranslation::class);
    }

    /**
     * @return BelongsToMany
     */
    public function elements(): BelongsToMany
    {
        return $this->belongsToMany(Element::class, 'element_formula')
            ->withPivot('amount')
            ->withTimestamps();
    }
}

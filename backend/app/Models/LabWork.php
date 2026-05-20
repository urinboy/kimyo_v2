<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LabWork extends Model
{
    protected $fillable = [
        'number',
        'status',
    ];

    protected $casts = [
        'number' => 'integer',
    ];

    public function translations(): HasMany
    {
        return $this->hasMany(LabWorkTranslation::class);
    }

    public function experiments(): HasMany
    {
        return $this->hasMany(LabExperiment::class)->orderBy('order_index');
    }
}

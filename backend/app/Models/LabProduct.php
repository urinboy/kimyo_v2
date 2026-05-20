<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LabProduct extends Model
{
    protected $fillable = [
        'lab_experiment_id',
        'chemical_formula',
        'state',
        'order_index',
    ];

    protected $casts = [
        'order_index' => 'integer',
    ];

    public function labExperiment(): BelongsTo
    {
        return $this->belongsTo(LabExperiment::class);
    }

    public function translations(): HasMany
    {
        return $this->hasMany(LabProductTranslation::class);
    }
}

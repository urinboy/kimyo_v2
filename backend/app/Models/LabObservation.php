<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LabObservation extends Model
{
    protected $fillable = [
        'lab_experiment_id',
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
        return $this->hasMany(LabObservationTranslation::class);
    }
}

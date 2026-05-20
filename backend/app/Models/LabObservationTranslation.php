<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LabObservationTranslation extends Model
{
    protected $fillable = [
        'lab_observation_id',
        'language_id',
        'text',
    ];

    public function labObservation(): BelongsTo
    {
        return $this->belongsTo(LabObservation::class);
    }

    public function language(): BelongsTo
    {
        return $this->belongsTo(Language::class);
    }
}

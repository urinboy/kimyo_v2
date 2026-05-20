<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LabExperimentTranslation extends Model
{
    protected $fillable = [
        'lab_experiment_id',
        'language_id',
        'title',
        'scientific_explanation',
    ];

    public function labExperiment(): BelongsTo
    {
        return $this->belongsTo(LabExperiment::class);
    }

    public function language(): BelongsTo
    {
        return $this->belongsTo(Language::class);
    }
}

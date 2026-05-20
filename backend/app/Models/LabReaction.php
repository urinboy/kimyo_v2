<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LabReaction extends Model
{
    protected $fillable = [
        'lab_experiment_id',
        'formula',
        'type',
        'order_index',
    ];

    protected $casts = [
        'order_index' => 'integer',
    ];

    public function labExperiment(): BelongsTo
    {
        return $this->belongsTo(LabExperiment::class);
    }
}

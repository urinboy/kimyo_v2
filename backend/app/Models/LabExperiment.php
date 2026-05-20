<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LabExperiment extends Model
{
    protected $fillable = [
        'lab_work_id',
        'type',
        'order_index',
        'status',
    ];

    protected $casts = [
        'order_index' => 'integer',
    ];

    public function labWork(): BelongsTo
    {
        return $this->belongsTo(LabWork::class);
    }

    public function translations(): HasMany
    {
        return $this->hasMany(LabExperimentTranslation::class);
    }

    public function reactions(): HasMany
    {
        return $this->hasMany(LabReaction::class)->orderBy('order_index');
    }

    public function observations(): HasMany
    {
        return $this->hasMany(LabObservation::class)->orderBy('order_index');
    }

    public function products(): HasMany
    {
        return $this->hasMany(LabProduct::class)->orderBy('order_index');
    }
}

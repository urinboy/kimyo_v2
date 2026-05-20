<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LabWorkTranslation extends Model
{
    protected $fillable = [
        'lab_work_id',
        'language_id',
        'title',
        'description',
    ];

    public function labWork(): BelongsTo
    {
        return $this->belongsTo(LabWork::class);
    }

    public function language(): BelongsTo
    {
        return $this->belongsTo(Language::class);
    }
}

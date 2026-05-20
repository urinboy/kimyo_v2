<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LessonLabItem extends Model
{
    public const CATEGORY_EQUIPMENT = 'equipment';
    public const CATEGORY_REAGENT = 'reagent';
    public const CATEGORY_ELEMENT = 'element';
    public const CATEGORY_VESSEL = 'vessel';

    protected $fillable = [
        'lesson_id',
        'category',
        'name',
        'formula',
        'quantity',
        'unit',
        'notes',
        'sort_order',
        'is_required',
        'is_active',
    ];

    protected $casts = [
        'sort_order' => 'integer',
        'is_required' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function lesson(): BelongsTo
    {
        return $this->belongsTo(Lesson::class);
    }
}

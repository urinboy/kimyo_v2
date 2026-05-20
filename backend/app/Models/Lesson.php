<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Lesson extends Model
{
    protected $fillable = [
        'type',
        'order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function translations(): HasMany
    {
        return $this->hasMany(LessonTranslation::class);
    }

    public function labItems(): HasMany
    {
        return $this->hasMany(LessonLabItem::class)->orderBy('sort_order')->orderBy('id');
    }
}

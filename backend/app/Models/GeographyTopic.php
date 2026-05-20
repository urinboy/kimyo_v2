<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GeographyTopic extends Model
{
    protected $fillable = [
        'category',
        'parent_id',
        'icon',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'sort_order' => 'integer',
    ];

    public function translations(): HasMany
    {
        return $this->hasMany(GeographyTopicTranslation::class);
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(GeographyTopic::class, 'parent_id');
    }

    public function children(): HasMany
    {
        return $this->hasMany(GeographyTopic::class, 'parent_id');
    }
}

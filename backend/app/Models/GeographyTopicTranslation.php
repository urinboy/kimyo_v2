<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GeographyTopicTranslation extends Model
{
    protected $fillable = [
        'geography_topic_id',
        'language_id',
        'title',
        'content',
    ];

    public function geographyTopic(): BelongsTo
    {
        return $this->belongsTo(GeographyTopic::class);
    }

    public function language(): BelongsTo
    {
        return $this->belongsTo(Language::class);
    }
}

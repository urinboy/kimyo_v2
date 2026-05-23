<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Video extends Model
{
    protected $fillable = [
        'youtube_video_id',
        'youtube_url',
        'video_path',
        'channel_name',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'sort_order' => 'integer',
        'is_active'  => 'boolean',
    ];

    public function translations(): HasMany
    {
        return $this->hasMany(VideoTranslation::class);
    }
}

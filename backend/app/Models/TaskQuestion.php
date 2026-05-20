<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TaskQuestion extends Model
{
    public const TYPE_TEXT        = 'text';
    public const TYPE_IMAGE       = 'image';
    public const TYPE_MATCH       = 'match';
    public const TYPE_WORD_SEARCH = 'word_search';
    public const TYPE_MATRIX_CLASSIFICATION = 'matrix_classification';

    protected $fillable = ['task_id', 'body', 'sort_order', 'question_type', 'image_path', 'match_data'];

    protected function casts(): array
    {
        return ['match_data' => 'array'];
    }

    protected $appends = ['image_url'];

    public function getImageUrlAttribute(): ?string
    {
        if (!$this->image_path) {
            return null;
        }

        $relativePath = str_replace('\\', '/', ltrim($this->image_path, '/'));
        $suffix = '/api/v1/public-storage/'.$relativePath;

        try {
            if (app()->bound('request') && request() && ($root = request()->getSchemeAndHttpHost())) {
                return rtrim($root, '/').$suffix;
            }
        } catch (\Throwable) {
            // kontekstsiz
        }

        return rtrim((string) config('app.url'), '/').$suffix;
    }

    public function task(): BelongsTo
    {
        return $this->belongsTo(InterestingTask::class, 'task_id');
    }
}

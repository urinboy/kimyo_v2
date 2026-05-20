<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class InterestingTask extends Model
{
    public const KIND_INTERESTING = 'interesting';

    public const KIND_PROJECT = 'project';

    protected $fillable = ['title', 'description', 'is_active', 'sort_order', 'task_kind'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function questions(): HasMany
    {
        return $this->hasMany(TaskQuestion::class, 'task_id')->orderBy('sort_order');
    }

    public function submissions(): HasMany
    {
        return $this->hasMany(TaskSubmission::class, 'task_id');
    }
}

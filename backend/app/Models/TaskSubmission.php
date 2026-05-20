<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TaskSubmission extends Model
{
    protected $fillable = [
        'task_id', 'user_id', 'student_name', 'student_email',
        'status', 'result_visible', 'teacher_comment', 'total_score', 'checked_at',
    ];

    protected function casts(): array
    {
        return [
            'result_visible' => 'boolean',
            'checked_at'     => 'datetime',
        ];
    }

    public function task(): BelongsTo
    {
        return $this->belongsTo(InterestingTask::class, 'task_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function answers(): HasMany
    {
        return $this->hasMany(TaskAnswer::class, 'submission_id');
    }
}

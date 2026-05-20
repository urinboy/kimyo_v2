<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TaskAnswer extends Model
{
    protected $fillable = [
        'submission_id', 'question_id', 'answer_text',
        'is_correct', 'score', 'teacher_comment',
    ];

    protected function casts(): array
    {
        return ['is_correct' => 'boolean'];
    }

    public function question(): BelongsTo
    {
        return $this->belongsTo(TaskQuestion::class, 'question_id');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Question extends Model
{
    protected $fillable = [
        'quiz_id',
        'order',
        'points',
    ];

    public function quiz()
    {
        return $this->belongsTo(Quiz::class);
    }

    public function translations()
    {
        return $this->hasMany(QuestionTranslation::class);
    }

    public function options()
    {
        return $this->hasMany(Option::class);
    }
}

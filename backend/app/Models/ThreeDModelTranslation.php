<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ThreeDModelTranslation extends Model
{
    protected $table = 'three_d_model_translations';

    protected $fillable = [
        'three_d_model_id',
        'language_id',
        'name',
        'description',
    ];

    public function model(): BelongsTo
    {
        return $this->belongsTo(ThreeDModel::class, 'three_d_model_id');
    }

    public function language(): BelongsTo
    {
        return $this->belongsTo(Language::class);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ThreeDModel extends Model
{
    protected $table = 'three_d_models';

    protected $fillable = [
        'slug',
        'model_path',
        'element_id',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'element_id'  => 'integer',
        'sort_order'  => 'integer',
        'is_active'   => 'boolean',
    ];

    public function translations(): HasMany
    {
        return $this->hasMany(ThreeDModelTranslation::class, 'three_d_model_id');
    }

    public function element(): BelongsTo
    {
        return $this->belongsTo(Element::class);
    }
}

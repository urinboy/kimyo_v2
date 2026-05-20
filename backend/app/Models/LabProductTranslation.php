<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LabProductTranslation extends Model
{
    protected $fillable = [
        'lab_product_id',
        'language_id',
        'name',
    ];

    public function labProduct(): BelongsTo
    {
        return $this->belongsTo(LabProduct::class);
    }

    public function language(): BelongsTo
    {
        return $this->belongsTo(Language::class);
    }
}

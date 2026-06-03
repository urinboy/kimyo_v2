<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RegionTranslation extends Model
{
    protected $fillable = ['region_id', 'language_id', 'name', 'description'];

    public function region(): BelongsTo
    {
        return $this->belongsTo(Region::class);
    }

    public function language(): BelongsTo
    {
        return $this->belongsTo(Language::class);
    }
}

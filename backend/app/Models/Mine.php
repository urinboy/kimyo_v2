<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Mine extends Model
{
    protected $fillable = [
        'latitude',
        'longitude',
        'images',
        'is_active',
    ];

    protected $casts = [
        'images' => 'array',
        'is_active' => 'boolean',
    ];

    public function elements()
    {
        return $this->belongsToMany(Element::class);
    }

    public function translations()
    {
        return $this->hasMany(MineTranslation::class);
    }
}

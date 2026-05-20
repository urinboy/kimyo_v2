<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ElementTranslation extends Model
{
    protected $fillable = [
        'element_id',
        'language_id',
        'name',
        'description',
    ];

    public function element()
    {
        return $this->belongsTo(Element::class);
    }

    public function language()
    {
        return $this->belongsTo(Language::class);
    }
}

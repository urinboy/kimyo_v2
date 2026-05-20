<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OptionTranslation extends Model
{
    protected $fillable = [
        'option_id',
        'language_id',
        'text',
    ];

    public function option()
    {
        return $this->belongsTo(Option::class);
    }

    public function language()
    {
        return $this->belongsTo(Language::class);
    }
}

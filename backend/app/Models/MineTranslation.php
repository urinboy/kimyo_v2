<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MineTranslation extends Model
{
    protected $fillable = [
        'mine_id',
        'language_id',
        'name',
        'description',
    ];

    public function mine()
    {
        return $this->belongsTo(Mine::class);
    }

    public function language()
    {
        return $this->belongsTo(Language::class);
    }
}

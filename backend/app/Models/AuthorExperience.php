<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AuthorExperience extends Model
{
    protected $fillable = [
        'years',
        'description_uz',
        'description_ru',
        'description_en',
        'description_kaa',
        'order',
    ];
}

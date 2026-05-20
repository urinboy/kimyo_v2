<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AuthorAdditionalInfo extends Model
{
    protected $fillable = [
        'key_uz',
        'key_ru',
        'key_en',
        'value_uz',
        'value_ru',
        'value_en',
        'order',
    ];
}

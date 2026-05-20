<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AppSetting extends Model
{
    protected $fillable = [
        'app_version',
        'app_version_code',
        'author_name',
        'author_role',
        'author_image',
        'author_birth_date',
        'author_birth_place',
        'author_nationality',
        'author_education',
        'author_specialization',
        'author_languages',
        'author_work_position',
        'author_work_organization',
        'about_app_uz',
        'about_app_ru',
        'about_app_en',
        'privacy_policy_url',
        'terms_url',
    ];
}

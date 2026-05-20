<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Document extends Model
{
    protected $fillable = [
        'category',
        'title_uz',
        'title_ru',
        'title_en',
        'file_path',
        'original_filename',
        'mime_type',
        'file_size',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'file_size' => 'integer',
        'sort_order' => 'integer',
    ];

    protected $hidden = [
        'created_at',
        'updated_at',
    ];

    public function getFileUrlAttribute(): string
    {
        return asset('storage/'.$this->file_path);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GradeLevel extends Model
{
    /** Mobil ilova uchun ruxsat etilgan sinf qiymatlari. */
    public const ALLOWED_LABELS = ['9', '9-A', '9-B'];

    protected $fillable = [
        'label',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
        ];
    }
}

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /** @var array<string, int> */
    private array $allowed = [
        '9'   => 1,
        '9-A' => 2,
        '9-B' => 3,
    ];

    public function up(): void
    {
        if (! Schema::hasTable('grade_levels')) {
            return;
        }

        DB::table('grade_levels')->whereNotIn('label', array_keys($this->allowed))->delete();

        $now = now();
        foreach ($this->allowed as $label => $sort) {
            $exists = DB::table('grade_levels')->where('label', $label)->exists();
            if ($exists) {
                DB::table('grade_levels')->where('label', $label)->update([
                    'sort_order' => $sort,
                    'updated_at' => $now,
                ]);
            } else {
                DB::table('grade_levels')->insert([
                    'label'      => $label,
                    'sort_order' => $sort,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }
        }

        // Eski "N-sinf" va boshqa qiymatlarni yangi ro'yxatga moslash.
        DB::table('users')->where('grade', '9-sinf')->update(['grade' => '9']);

        DB::table('users')
            ->whereNotNull('grade')
            ->whereNotIn('grade', array_keys($this->allowed))
            ->update(['grade' => null]);
    }

    public function down(): void
    {
        // Ma'lumotlarni avvalgi holatga qaytarib bo'lmaydi.
    }
};

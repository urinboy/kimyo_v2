<?php

use App\Models\User;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * 19- va 21-maktablar manbada tumanisiz edi — Qanliko'l tumani bilan bog'lash.
 * Student seed uslubidagi username (oxirida _YYYY_NNN) bo'lgan o'quvchilar:
 * created_at / updated_at → o'quv yili boshlang'ich yili (1-yanvar, YY bosh yili).
 */
return new class extends Migration
{
    private const QANLIQOL = "Qanliko'l tumani";

    public function up(): void
    {
        foreach (['19-maktab', '21-maktab'] as $shortName) {
            $num = (int) $shortName;
            DB::table('schools')
                ->where('short_name', $shortName)
                ->where(function ($q) {
                    $q->whereNull('city')->orWhere('city', '');
                })
                ->update([
                    'city' => self::QANLIQOL,
                    'name' => $num . "-sonli umumta'lim maktabi",
                    'updated_at' => now(),
                ]);
        }

        $tz = config('app.timezone');

        foreach (User::query()->where('role', 'user')->whereNotNull('username')->cursor() as $user) {
            if (! preg_match('/_(\d{4})_(\d{3})$/', $user->username, $m)) {
                continue;
            }
            $yk = $m[1];
            if (strlen($yk) !== 4 || ! ctype_digit($yk)) {
                continue;
            }
            $startYear = 2000 + (int) substr($yk, 0, 2);
            $at = Carbon::create($startYear, 1, 1, 0, 0, 0, $tz);
            DB::table('users')->where('id', $user->id)->update([
                'created_at' => $at,
                'updated_at' => $at,
            ]);
        }
    }

    public function down(): void
    {
        //
    }
};

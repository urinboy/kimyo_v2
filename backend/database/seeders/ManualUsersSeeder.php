<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;

/**
 * Mobil ilova test uchun standart o‘quvchi (`POST /api/v1/mobile/auth/login`).
 *
 * Login maydoniga username yoziladi (telefon emas).
 *
 * Standart: username `test_student`, parol `TestStudent123`
 * Boshqa parol: `.env` da `MANUAL_TEST_STUDENT_PASSWORD=...`
 *
 * Eslatma: `role = admin` bo‘lgan hisoblar mobil login orqali kira olmaydi.
 */
class ManualUsersSeeder extends Seeder
{
    private const USERNAME = 'test_student';

    public function run(): void
    {
        $plainPassword = (string) env('MANUAL_TEST_STUDENT_PASSWORD', 'TestStudent123');

        $user = User::updateOrCreate(
            ['username' => self::USERNAME],
            [
                'name'      => 'Test o‘quvchi',
                'password'  => $plainPassword,
                'email'     => null,
                'role'      => 'user',
                'phone'     => null,
                'school_id' => null,
                'grade'     => '9',
            ]
        );

        $role = Role::query()
            ->where('name', 'user')
            ->where('guard_name', 'web')
            ->first();

        if ($role) {
            $user->syncRoles([$role]);
        }
    }
}

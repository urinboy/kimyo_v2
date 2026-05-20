<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;

class AdminSeeder extends Seeder
{
    /**
     * Admin panel (role=admin + Sanctum). Spatie roli: super_admin | editor
     * Parol: ADMIN_SEED_PASSWORD yoki standart (faqat dev).
     */
    public function run(): void
    {
        $plain = (string) env('ADMIN_SEED_PASSWORD', 'admin123');

        $accounts = [
            [
                'name'     => 'Asosiy administrator',
                'email'    => env('ADMIN_EMAIL_PRIMARY', 'admin@kimyo.uz'),
                'username' => env('ADMIN_USERNAME_PRIMARY', 'admin'),
                'spatie'   => 'super_admin',
            ],
            [
                'name'     => 'Tahrirchi',
                'email'    => env('ADMIN_EMAIL_EDITOR', 'tahrirchi@kimyo.uz'),
                'username' => env('ADMIN_USERNAME_EDITOR', 'tahrirchi'),
                'spatie'   => 'editor',
            ],
            [
                'name'     => 'Yordamchi administrator',
                'email'    => env('ADMIN_EMAIL_AUX', 'yordamchi@kimyo.uz'),
                'username' => env('ADMIN_USERNAME_AUX', 'yordamchi'),
                'spatie'   => 'super_admin',
            ],
        ];

        foreach ($accounts as $row) {
            $user = User::query()->updateOrCreate(
                ['email' => $row['email']],
                [
                    'name'       => $row['name'],
                    'username'   => $row['username'],
                    'password'   => $plain,
                    'role'       => 'admin',
                    'phone'      => null,
                    'school_id'  => null,
                    'grade'      => null,
                ]
            );

            $role = Role::query()->where('name', $row['spatie'])->where('guard_name', 'web')->first();
            if ($role) {
                $user->syncRoles([$role]);
            }
        }
    }
}

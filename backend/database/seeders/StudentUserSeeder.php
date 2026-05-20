<?php

namespace Database\Seeders;

use App\Models\School;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class StudentUserSeeder extends Seeder
{
    /**
     * users.txt / build_student_users_data.py chiqishi bilan mos: {tuman}_m{maktab}_{sinf}_{YYZZ}_{t/r}.
     */
    private const SEED_USERNAME_PATTERN = '/^[a-z]+_m\d+_[a-z0-9]+_\d{4}_\d{3}$/';

    public function run(): void
    {
        $plain = (string) env('STUDENT_SEED_PASSWORD', 'student123');
        /** @var list<array{username:string,name:string,district_api:?string,school_number:int,grade:string,year_key?:string}> $rows */
        $rows = require database_path('data/student_users_from_txt.php');

        DB::transaction(function () use ($plain, $rows) {
            $this->purgeSeededStudents();

            foreach ($rows as $row) {
                $schoolId = null;
                $num = (int) $row['school_number'];
                $district = $row['district_api'];

                $schoolDisplayName = $num . "-sonli umumta'lim maktabi";
                if ($district === null || $district === '') {
                    $schoolDisplayName .= " (tuman ko'rsatilmagan)";
                }

                if ($district !== null && $district !== '') {
                    $school = School::firstOrCreate(
                        ['short_name' => $num . '-maktab', 'city' => $district],
                        [
                            'name' => $schoolDisplayName,
                            'region' => "Qoraqalpog'iston Respublikasi",
                            'is_active' => true,
                        ]
                    );
                    if ($school->name !== $schoolDisplayName) {
                        $school->update(['name' => $schoolDisplayName]);
                    }
                    $schoolId = $school->id;
                } else {
                    $school = School::firstOrCreate(
                        ['short_name' => $num . '-maktab', 'city' => null],
                        [
                            'name' => $schoolDisplayName,
                            'region' => "Qoraqalpog'iston Respublikasi",
                            'is_active' => true,
                        ]
                    );
                    $schoolId = $school->id;
                }

                $user = User::create([
                    'username' => $row['username'],
                    'name' => $row['name'],
                    'email' => null,
                    'password' => $plain,
                    'role' => 'user',
                    'school_id' => $schoolId,
                    'grade' => $row['grade'],
                    'phone' => null,
                ]);

                $registeredAt = $this->registeredAtFromYearKey($row['year_key'] ?? '');
                if ($registeredAt !== null) {
                    DB::table('users')->where('id', $user->id)->update([
                        'created_at' => $registeredAt,
                        'updated_at' => $registeredAt,
                    ]);
                }

                $user->assignRole('user');
            }
        });
    }

    /**
     * Avvalgi StudentUserSeeder yozuvlari: pattern + role=user (boshqa user hisoblarga tegmaydi).
     */
    private function purgeSeededStudents(): void
    {
        $ids = User::query()
            ->where('role', 'user')
            ->whereNotNull('username')
            ->pluck('id', 'username')
            ->filter(fn (int|string $userId, string $username) => (bool) preg_match(self::SEED_USERNAME_PATTERN, $username))
            ->values()
            ->all();

        if ($ids === []) {
            return;
        }

        $morph = User::class;
        $permissionTables = config('permission.table_names');

        DB::table('personal_access_tokens')
            ->where('tokenable_type', $morph)
            ->whereIn('tokenable_id', $ids)
            ->delete();

        DB::table($permissionTables['model_has_roles'])
            ->where('model_type', $morph)
            ->whereIn(config('permission.column_names.model_morph_key', 'model_id'), $ids)
            ->delete();

        DB::table($permissionTables['model_has_permissions'])
            ->where('model_type', $morph)
            ->whereIn(config('permission.column_names.model_morph_key', 'model_id'), $ids)
            ->delete();

        User::query()->whereIn('id', $ids)->delete();
    }

    /**
     * year_key: 2223 → 2022-2023 o‘quv yili → created_at boshlanish yili 2022 (1-yanvar).
     */
    private function registeredAtFromYearKey(string $yearKey): ?Carbon
    {
        $yearKey = trim($yearKey);
        if (strlen($yearKey) !== 4 || ! ctype_digit($yearKey)) {
            return null;
        }

        $startYear = 2000 + (int) substr($yearKey, 0, 2);

        return Carbon::createFromDate($startYear, 1, 1, config('app.timezone') ?? 'UTC')->startOfDay();
    }
}
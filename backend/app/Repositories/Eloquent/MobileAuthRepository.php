<?php

namespace App\Repositories\Eloquent;

use App\Models\School;
use App\Models\User;
use App\Repositories\Interfaces\MobileAuthRepositoryInterface;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;

class MobileAuthRepository implements MobileAuthRepositoryInterface
{
    public function register(array $data): array
    {
        // Auto-find or create school by district + number
        $schoolId = null;
        if (! empty($data['district']) && ! empty($data['school_number'])) {
            $num      = (int) $data['school_number'];
            $district = trim($data['district']);

            $school = School::firstOrCreate(
                ['short_name' => $num . '-maktab', 'city' => $district],
                [
                    'name'      => $num . "-sonli umumta'lim maktabi",
                    'region'    => "Qoraqalpog'iston Respublikasi",
                    'is_active' => true,
                ]
            );
            $schoolId = $school->id;
        }

        $user = User::create([
            'name'      => $data['name'],
            'username'  => $data['username'],
            'phone'     => $data['phone'] ?? null,
            'password'  => Hash::make($data['password']),
            'role'      => 'user',
            'school_id' => $schoolId,
        ]);

        $token = $user->createToken('mobile-token')->plainTextToken;

        return ['user' => $user->loadMissing('school'), 'token' => $token];
    }

    public function login(array $credentials): ?array
    {
        $login = trim($credentials['login']);
        $loginUser = strtolower($login);

        $user = User::where('email', $login)
            ->orWhere('phone', $login)
            ->orWhere('username', $loginUser)
            ->first();

        if (!$user || !Hash::check($credentials['password'] ?? '', $user->password)) {
            return null;
        }

        $token = $user->createToken('mobile-token')->plainTextToken;

        return ['user' => $user->loadMissing('school'), 'token' => $token];
    }

    public function logout(): bool
    {
        /** @var User|null $user */
        $user = Auth::user();

        if (! $user instanceof User) {
            return false;
        }

        // TransientToken uchun delete() yo‘q — faqat DB dagi PAT ni shu yerda o‘chirish mumkin.
        $access = $user->currentAccessToken();
        if ($access instanceof PersonalAccessToken) {
            $access->delete();

            return true;
        }

        // TransientToken | null — Bearer matnidan PAT ni topish.
        $plain = request()->bearerToken();
        if ($plain !== null && $plain !== '') {
            $pat = PersonalAccessToken::findToken($plain);
            if ($pat !== null
                && (int) $pat->tokenable_id === (int) $user->getAuthIdentifier()
                && $pat->tokenable_type === $user->getMorphClass()) {
                $pat->delete();

                return true;
            }
        }

        return false;
    }

    public function getMe(): mixed
    {
        /** @var User|null $u */
        $u = Auth::user() ?? request()->user();

        return $u instanceof User ? $u->loadMissing('school') : null;
    }

    public function updateProfile(array $data): User
    {
        /** @var User $user */
        $user = Auth::user();

        foreach (['username', 'phone', 'school_name', 'grade', 'school_id'] as $key) {
            if (array_key_exists($key, $data) && $data[$key] === '') {
                $data[$key] = null;
            }
        }

        $user->fill($data);

        if (array_key_exists('school_id', $data)) {
            if ($user->school_id) {
                $school = School::find($user->school_id);
                $user->school_name = $school?->name;
            } else {
                $user->school_name = null;
            }
        }

        $user->save();

        return $user->refresh()->load('school');
    }

    public function changePassword(string $currentPassword, string $newPassword): bool
    {
        /** @var User $user */
        $user = Auth::user();

        if (! Hash::check($currentPassword, $user->getAuthPassword())) {
            return false;
        }

        $user->password = $newPassword;
        $user->save();

        return true;
    }
}

<?php

namespace App\Repositories\Eloquent;

use App\Models\User;
use App\Repositories\Interfaces\AuthRepositoryInterface;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthRepository implements AuthRepositoryInterface
{
    /**
     * Login user and create token.
     *
     * @param array $credentials
     * @return array|null
     */
    public function login(array $credentials): ?array
    {
        $login = $credentials['login'];

        $user = User::where('email', $login)
            ->orWhere('username', $login)
            ->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            return null;
        }

        if ($user->role !== 'admin') {
            return null;
        }

        $token = $user->createToken('admin-token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token
        ];
    }

    /**
     * Logout user (revoke token).
     *
     * @return bool
     */
    public function logout(): bool
    {
        /** @var User $user */
        $user = Auth::user();

        if ($user) {
            $user->currentAccessToken()->delete();
            return true;
        }

        return false;
    }

    /**
     * Get current authenticated user details.
     *
     * @return mixed
     */
    public function getMe()
    {
        return Auth::user();
    }
}

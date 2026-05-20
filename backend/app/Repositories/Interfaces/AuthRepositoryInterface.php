<?php

namespace App\Repositories\Interfaces;

interface AuthRepositoryInterface
{
    /**
     * Login user and create token.
     *
     * @param array $credentials
     * @return array|null
     */
    public function login(array $credentials): ?array;

    /**
     * Logout user (revoke token).
     *
     * @return bool
     */
    public function logout(): bool;

    /**
     * Get current authenticated user details.
     *
     * @return mixed
     */
    public function getMe();
}

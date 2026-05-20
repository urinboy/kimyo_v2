<?php

namespace App\Repositories\Interfaces;

use App\Models\User;

interface MobileAuthRepositoryInterface
{
    public function register(array $data): array;

    public function login(array $credentials): ?array;

    public function logout(): bool;

    public function getMe(): mixed;

    public function updateProfile(array $data): User;

    /**
     * @return bool false — joriy parol noto'g'ri
     */
    public function changePassword(string $currentPassword, string $newPassword): bool;
}

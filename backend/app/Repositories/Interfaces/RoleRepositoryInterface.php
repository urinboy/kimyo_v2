<?php

namespace App\Repositories\Interfaces;

use Spatie\Permission\Models\Role;
use Illuminate\Support\Collection;

interface RoleRepositoryInterface
{
    public function getAll(): Collection;
    public function getAllPermissions(): Collection;
    public function create(array $data): Role;
    public function update(int $id, array $data): ?Role;
    public function delete(int $id): bool;
    public function syncPermissions(int $roleId, array $permissions): Role;
}

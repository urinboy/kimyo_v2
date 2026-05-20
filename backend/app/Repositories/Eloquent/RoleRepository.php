<?php

namespace App\Repositories\Eloquent;

use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use App\Repositories\Interfaces\RoleRepositoryInterface;
use Illuminate\Support\Collection;

class RoleRepository implements RoleRepositoryInterface
{
    private Role $model;

    public function __construct(Role $model)
    {
        $this->model = $model;
    }

    public function getAll(): Collection
    {
        return $this->model->with('permissions')->get();
    }

    public function getAllPermissions(): Collection
    {
        return Permission::all();
    }

    public function create(array $data): Role
    {
        $role = $this->model->create(['name' => $data['name'], 'guard_name' => 'web']);
        
        if (isset($data['permissions'])) {
            $role->syncPermissions($data['permissions']);
        }
        
        return $role;
    }

    public function update(int $id, array $data): ?Role
    {
        /** @var Role|null $role */
        $role = $this->model->find($id);
        if (!$role) return null;

        $role->update(['name' => $data['name']]);

        if (isset($data['permissions'])) {
            $role->syncPermissions($data['permissions']);
        }

        return $role;
    }

    public function delete(int $id): bool
    {
        /** @var Role|null $role */
        $role = $this->model->find($id);
        return $role ? $role->delete() : false;
    }

    public function syncPermissions(int $roleId, array $permissions): Role
    {
        /** @var Role $role */
        $role = $this->model->findOrFail($roleId);
        $role->syncPermissions($permissions);
        return $role;
    }
}

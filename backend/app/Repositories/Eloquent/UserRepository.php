<?php

namespace App\Repositories\Eloquent;

use App\Models\User;
use App\Repositories\Interfaces\UserRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Hash;

class UserRepository implements UserRepositoryInterface
{
    private User $model;

    public function __construct(User $model)
    {
        $this->model = $model;
    }

    public function getAll(): Collection
    {
        return $this->model->with(['roles', 'school'])->get();
    }

    public function findById(int $id): ?User
    {
        return $this->model->with(['roles', 'school'])->find($id);
    }

    public function create(array $data): User
    {
        if (isset($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        }
        
        $user = $this->model->create($data);
        
        if (isset($data['role'])) {
            $user->assignRole($data['role']);
        }

        return $user->fresh(['roles', 'school']);
    }

    public function update(int $id, array $data): ?User
    {
        $user = $this->findById($id);
        if (!$user) return null;

        if (isset($data['password']) && $data['password'] === '') {
            unset($data['password']);
        }

        if (isset($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        }

        $user->update($data);

        if (isset($data['role'])) {
            $user->syncRoles([$data['role']]);
        }

        return $user->fresh(['roles', 'school']);
    }

    public function delete(int $id): bool
    {
        $user = $this->findById($id);
        return $user ? $user->delete() : false;
    }

    public function assignRole(int $userId, string $role): User
    {
        $user = $this->findById($userId);
        $user->syncRoles([$role]);
        return $user;
    }
}

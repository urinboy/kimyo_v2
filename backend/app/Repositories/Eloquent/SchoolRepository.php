<?php

namespace App\Repositories\Eloquent;

use App\Models\School;
use App\Repositories\Interfaces\SchoolRepositoryInterface;
use Illuminate\Support\Collection;

class SchoolRepository implements SchoolRepositoryInterface
{
    public function all(): Collection
    {
        return School::query()
            ->orderBy('name')
            ->withCount('users')
            ->get();
    }

    public function find(int $id): ?School
    {
        return School::query()->withCount('users')->find($id);
    }

    public function create(array $data): School
    {
        return School::create($data);
    }

    public function update(int $id, array $data): ?School
    {
        $school = School::find($id);
        if (! $school) {
            return null;
        }
        $school->update($data);

        return $school->fresh()->loadCount('users');
    }

    public function delete(int $id): bool
    {
        $school = School::find($id);

        return $school ? (bool) $school->delete() : false;
    }
}

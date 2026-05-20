<?php

namespace App\Repositories\Interfaces;

use App\Models\School;
use Illuminate\Support\Collection;

interface SchoolRepositoryInterface
{
    public function all(): Collection;

    public function find(int $id): ?School;

    public function create(array $data): School;

    public function update(int $id, array $data): ?School;

    public function delete(int $id): bool;
}

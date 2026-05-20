<?php

namespace App\Repositories\Interfaces;

use App\Models\Mine;
use Illuminate\Support\Collection;

interface MineRepositoryInterface
{
    public function getAll(): Collection;
    public function findById(int $id): ?Mine;
    public function create(array $data): Mine;
    public function update(int $id, array $data): ?Mine;
    public function delete(int $id): bool;
}

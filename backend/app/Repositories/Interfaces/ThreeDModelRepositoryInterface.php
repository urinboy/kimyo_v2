<?php

namespace App\Repositories\Interfaces;

use App\Models\ThreeDModel;
use Illuminate\Support\Collection;

interface ThreeDModelRepositoryInterface
{
    public function all(bool $activeOnly = false): Collection;

    public function find(int $id): ?ThreeDModel;

    public function create(array $data): ThreeDModel;

    public function update(int $id, array $data): ?ThreeDModel;

    public function delete(int $id): bool;
}

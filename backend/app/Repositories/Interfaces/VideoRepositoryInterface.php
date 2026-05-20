<?php

namespace App\Repositories\Interfaces;

use App\Models\Video;
use Illuminate\Database\Eloquent\Collection;

interface VideoRepositoryInterface
{
    public function all(bool $activeOnly = false): Collection;

    public function find(int $id): ?Video;

    public function create(array $data): Video;

    public function update(int $id, array $data): ?Video;

    public function delete(int $id): bool;
}

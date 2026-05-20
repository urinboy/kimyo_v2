<?php

namespace App\Repositories\Interfaces;

interface LabWorkRepositoryInterface
{
    public function all(): \Illuminate\Database\Eloquent\Collection;

    public function find(int $id): ?\App\Models\LabWork;

    public function create(array $data): \App\Models\LabWork;

    public function update(int $id, array $data): ?\App\Models\LabWork;

    public function delete(int $id): bool;
}

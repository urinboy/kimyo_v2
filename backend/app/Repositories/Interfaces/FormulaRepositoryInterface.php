<?php

namespace App\Repositories\Interfaces;

use App\Models\Formula;
use Illuminate\Support\Collection;

interface FormulaRepositoryInterface
{
    public function getAll(): Collection;
    public function findById(int $id): ?Formula;
    public function create(array $data): Formula;
    public function update(int $id, array $data): ?Formula;
    public function delete(int $id): bool;
}

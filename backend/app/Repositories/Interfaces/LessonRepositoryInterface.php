<?php

namespace App\Repositories\Interfaces;

use App\Models\Lesson;
use Illuminate\Support\Collection;

interface LessonRepositoryInterface
{
    /**
     * Mobil ro‘yxat: tarjimalarda faqat sarlavha (content yo‘q) — kichik JSON.
     */
    public function getAllSummary(): Collection;

    public function getAll(): Collection;
    public function findById(int $id): ?Lesson;
    public function create(array $data): Lesson;
    public function update(int $id, array $data): ?Lesson;
    public function delete(int $id): bool;
}

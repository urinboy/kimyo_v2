<?php

namespace App\Repositories\Interfaces;

use App\Models\LessonLabItem;
use Illuminate\Support\Collection;

interface LessonLabItemRepositoryInterface
{
    public function allForLesson(int $lessonId): Collection;

    /**
     * @param  array<string, mixed>  $data
     */
    public function create(int $lessonId, array $data): LessonLabItem;

    /**
     * @param  array<string, mixed>  $data
     */
    public function update(int $id, array $data): ?LessonLabItem;

    public function delete(int $id): bool;
}

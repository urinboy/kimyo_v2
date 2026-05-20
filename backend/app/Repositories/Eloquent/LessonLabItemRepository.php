<?php

namespace App\Repositories\Eloquent;

use App\Models\LessonLabItem;
use App\Repositories\Interfaces\LessonLabItemRepositoryInterface;
use Illuminate\Support\Collection;

class LessonLabItemRepository implements LessonLabItemRepositoryInterface
{
    public function allForLesson(int $lessonId): Collection
    {
        return LessonLabItem::query()
            ->where('lesson_id', $lessonId)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();
    }

    public function create(int $lessonId, array $data): LessonLabItem
    {
        return LessonLabItem::create([
            ...$data,
            'lesson_id' => $lessonId,
        ]);
    }

    public function update(int $id, array $data): ?LessonLabItem
    {
        $item = LessonLabItem::find($id);
        if (! $item) {
            return null;
        }

        $item->update($data);

        return $item->fresh();
    }

    public function delete(int $id): bool
    {
        $item = LessonLabItem::find($id);

        return $item ? (bool) $item->delete() : false;
    }
}

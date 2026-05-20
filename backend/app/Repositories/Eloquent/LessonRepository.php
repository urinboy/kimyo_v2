<?php

namespace App\Repositories\Eloquent;

use App\Models\Lesson;
use App\Repositories\Interfaces\LessonRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class LessonRepository implements LessonRepositoryInterface
{
    private Lesson $model;

    public function __construct(Lesson $model)
    {
        $this->model = $model;
    }

    /**
     * Admin panel: translations massiv — [{ "language_id": 1, "title": "...", "content": "..." }, ...].
     * Seeder / boshqa: { "1": { "title": "...", "content": "..." }, ... }.
     *
     * @param  array<int|string, mixed>  $translations
     * @return array<int, array{title: string, content: ?string}>
     */
    private function normalizeTranslations(array $translations): array
    {
        $out = [];

        foreach ($translations as $key => $row) {
            if (! is_array($row)) {
                continue;
            }

            $languageId = isset($row['language_id'])
                ? (int) $row['language_id']
                : (int) $key;

            $title = $row['title'] ?? '';
            $content = array_key_exists('content', $row) ? $row['content'] : null;
            if ($content !== null && ! is_string($content)) {
                $content = is_scalar($content) ? (string) $content : null;
            }

            $out[$languageId] = [
                'title' => is_string($title) ? $title : (string) $title,
                'content' => $content,
            ];
        }

        return $out;
    }

    public function getAllSummary(): Collection
    {
        return $this->model
            ->withCount(['labItems as lab_items_count' => fn ($q) => $q->where('is_active', true)])
            ->with([
                'translations' => static fn ($q) => $q->select([
                    'id',
                    'lesson_id',
                    'language_id',
                    'title',
                ]),
                'translations.language',
            ])
            ->orderBy('order')
            ->get();
    }

    public function getAll(): Collection
    {
        return $this->model
            ->withCount(['labItems as lab_items_count' => fn ($q) => $q->where('is_active', true)])
            ->with('translations.language')
            ->orderBy('order')
            ->get();
    }

    public function findById(int $id): ?Lesson
    {
        return $this->model->with('translations.language')->find($id);
    }

    public function create(array $data): Lesson
    {
        return DB::transaction(function () use ($data) {
            $lesson = $this->model->create([
                'type' => $data['type'],
                'order' => $data['order'] ?? 0,
                'is_active' => $data['is_active'] ?? true,
            ]);

            $normalized = $this->normalizeTranslations($data['translations']);

            foreach ($normalized as $langId => $trans) {
                $lesson->translations()->create([
                    'language_id' => $langId,
                    'title' => $trans['title'],
                    'content' => $trans['content'],
                ]);
            }

            return $lesson->fresh()->load('translations.language');
        });
    }

    public function update(int $id, array $data): ?Lesson
    {
        $lesson = $this->model->find($id);
        if (!$lesson) return null;

        return DB::transaction(function () use ($lesson, $data) {
            $lesson->update([
                'type' => $data['type'] ?? $lesson->type,
                'order' => $data['order'] ?? $lesson->order,
                'is_active' => $data['is_active'] ?? $lesson->is_active,
            ]);

            if (isset($data['translations'])) {
                $normalized = $this->normalizeTranslations($data['translations']);
                foreach ($normalized as $langId => $trans) {
                    $lesson->translations()->updateOrCreate(
                        ['language_id' => $langId],
                        ['title' => $trans['title'], 'content' => $trans['content']]
                    );
                }
            }

            return $lesson->refresh()->load('translations.language');
        });
    }

    public function delete(int $id): bool
    {
        $lesson = $this->model->find($id);
        return $lesson ? $lesson->delete() : false;
    }
}

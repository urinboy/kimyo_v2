<?php

namespace App\Repositories\Eloquent;

use App\Models\GeographyTopic;
use App\Models\GeographyTopicTranslation;
use App\Repositories\Interfaces\GeographyTopicRepositoryInterface;
use Illuminate\Support\Facades\DB;

class GeographyTopicRepository implements GeographyTopicRepositoryInterface
{
    public function all(string $category = null)
    {
        $query = GeographyTopic::with('translations.language');
        
        if ($category) {
            $query->where('category', $category);
        }
        
        return $query->orderBy('sort_order')->get();
    }

    public function find(int $id)
    {
        return GeographyTopic::with('translations.language')->find($id);
    }

    public function create(array $data)
    {
        return DB::transaction(function () use ($data) {
            $topic = GeographyTopic::create([
                'category'   => $data['category'],
                'parent_id'  => $data['parent_id'] ?? null,
                'icon'       => $data['icon'] ?? null,
                'sort_order' => $data['sort_order'] ?? 0,
                'is_active'  => $data['is_active'] ?? true,
            ]);

            if (isset($data['translations']) && is_array($data['translations'])) {
                foreach ($data['translations'] as $translation) {
                    $topic->translations()->create([
                        'language_id' => $translation['language_id'],
                        'title'       => $translation['title'],
                        'content'     => $translation['content'] ?? null,
                    ]);
                }
            }

            return $topic->load('translations.language');
        });
    }

    public function update(int $id, array $data)
    {
        return DB::transaction(function () use ($id, $data) {
            $topic = GeographyTopic::find($id);
            if (!$topic) return null;

            $topic->update([
                'category'   => $data['category'] ?? $topic->category,
                'parent_id'  => $data['parent_id'] ?? $topic->parent_id,
                'icon'       => $data['icon'] ?? $topic->icon,
                'sort_order' => $data['sort_order'] ?? $topic->sort_order,
                'is_active'  => $data['is_active'] ?? $topic->is_active,
            ]);

            if (isset($data['translations']) && is_array($data['translations'])) {
                foreach ($data['translations'] as $translation) {
                    $topic->translations()->updateOrCreate(
                        ['language_id' => $translation['language_id']],
                        [
                            'title'   => $translation['title'],
                            'content' => $translation['content'] ?? null,
                        ]
                    );
                }
            }

            return $topic->load('translations.language');
        });
    }

    public function delete(int $id)
    {
        $topic = GeographyTopic::find($id);
        if ($topic) {
            return $topic->delete();
        }
        return false;
    }
}

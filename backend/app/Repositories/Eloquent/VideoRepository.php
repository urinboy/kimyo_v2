<?php

namespace App\Repositories\Eloquent;

use App\Models\Language;
use App\Models\Video;
use App\Repositories\Interfaces\VideoRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class VideoRepository implements VideoRepositoryInterface
{
    public function all(bool $activeOnly = false): Collection
    {
        $q = Video::with(['translations.language:id,code'])
            ->orderByDesc('sort_order')
            ->orderByDesc('id');

        if ($activeOnly) {
            $q->where('is_active', true);
        }

        return $q->get();
    }

    public function find(int $id): ?Video
    {
        return Video::with(['translations.language:id,code'])->find($id);
    }

    public function create(array $data): Video
    {
        return DB::transaction(function () use ($data) {
            $video = Video::create([
                'youtube_video_id' => $data['youtube_video_id'],
                'youtube_url'      => $data['youtube_url'] ?? null,
                'channel_name'     => $data['channel_name'] ?? null,
                'sort_order'       => $data['sort_order'] ?? 0,
                'is_active'        => $data['is_active'] ?? true,
            ]);

            $this->syncTranslations($video, $data['translations'] ?? []);

            return $this->find($video->id);
        });
    }

    public function update(int $id, array $data): ?Video
    {
        return DB::transaction(function () use ($id, $data) {
            $video = Video::find($id);
            if (! $video) {
                return null;
            }

            $video->update([
                'youtube_video_id' => $data['youtube_video_id'] ?? $video->youtube_video_id,
                'youtube_url'      => $data['youtube_url'] ?? $video->youtube_url,
                'channel_name'     => $data['channel_name'] ?? $video->channel_name,
                'sort_order'       => $data['sort_order'] ?? $video->sort_order,
                'is_active'        => $data['is_active'] ?? $video->is_active,
            ]);

            if (isset($data['translations'])) {
                $this->syncTranslations($video, $data['translations']);
            }

            return $this->find($video->id);
        });
    }

    public function delete(int $id): bool
    {
        $video = Video::find($id);

        return $video ? (bool) $video->delete() : false;
    }

    private function syncTranslations(Video $video, array $translations): void
    {
        foreach ($translations as $t) {
            $lang = Language::where('code', $t['language_code'] ?? '')->first()
                ?? Language::find($t['language_id'] ?? 0);
            if (! $lang) {
                continue;
            }

            $video->translations()->updateOrCreate(
                ['language_id' => $lang->id],
                [
                    'title'       => $t['title'],
                    'description' => $t['description'] ?? null,
                ]
            );
        }
    }
}

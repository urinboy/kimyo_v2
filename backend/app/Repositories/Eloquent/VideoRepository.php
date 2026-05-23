<?php

namespace App\Repositories\Eloquent;

use App\Models\Language;
use App\Models\Video;
use App\Repositories\Interfaces\VideoRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

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
                'youtube_video_id' => $data['youtube_video_id'] ?? null,
                'youtube_url'      => $data['youtube_url'] ?? null,
                'video_path'       => $data['video_path'] ?? null,
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

            // Yangi video fayl yuklangan bo'lsa, eskisini o'chiramiz
            if (array_key_exists('video_path', $data) && $data['video_path'] !== $video->video_path) {
                if ($video->video_path) {
                    Storage::disk('public')->delete($video->video_path);
                }
            }

            $video->update([
                'youtube_video_id' => array_key_exists('youtube_video_id', $data) ? $data['youtube_video_id'] : $video->youtube_video_id,
                'youtube_url'      => array_key_exists('youtube_url', $data) ? $data['youtube_url'] : $video->youtube_url,
                'video_path'       => array_key_exists('video_path', $data) ? $data['video_path'] : $video->video_path,
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
        if (! $video) {
            return false;
        }

        // Video faylini diskdan o'chiramiz
        if ($video->video_path) {
            Storage::disk('public')->delete($video->video_path);
        }

        return (bool) $video->delete();
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

<?php

namespace App\Support;

use App\Models\Video;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;

class VideoApiFormatter
{
    /** @param  Collection<int, object>  $items */
    private static function pickTranslation(Collection $items, ?string $lang): ?object
    {
        if ($items->isEmpty()) {
            return null;
        }

        $code = fn ($t) => $t->language?->code ?? null;

        if ($lang) {
            $match = $items->first(fn ($t) => $code($t) === $lang);

            return $match ?? $items->first(fn ($t) => $code($t) === 'uz') ?? $items->first();
        }

        return $items->first();
    }

    public static function listItem(Video $video, ?string $lang = null): array
    {
        $t = self::pickTranslation($video->translations, $lang);

        return [
            'id'               => $video->id,
            'youtube_video_id' => $video->youtube_video_id,
            'youtube_url'      => $video->youtube_url
                ?? ($video->youtube_video_id ? YouTubeHelper::canonicalUrl($video->youtube_video_id) : null),
            'video_url'        => self::resolveVideoUrl($video),
            'channel_name'     => $video->channel_name,
            'title'            => $t?->title ?? '',
            'description'      => $t?->description,
            'thumbnail_url'    => $video->youtube_video_id
                ? YouTubeHelper::thumbnailUrl($video->youtube_video_id)
                : null,
            'embed_url'        => $video->youtube_video_id
                ? YouTubeHelper::embedUrl($video->youtube_video_id)
                : null,
            'sort_order'       => $video->sort_order,
            'is_active'        => $video->is_active,
            'published_at'     => $video->created_at?->toIso8601String(),
        ];
    }

    /** Server-da saqlangan video uchun to'liq URL qaytaradi */
    private static function resolveVideoUrl(Video $video): ?string
    {
        if (! $video->video_path) {
            return null;
        }

        return Storage::disk('public')->url($video->video_path);
    }

    public static function detail(Video $video, ?string $lang = null): array
    {
        return array_merge(self::listItem($video, $lang), [
            'translations' => $video->translations->map(fn ($t) => [
                'language_code' => $t->language?->code,
                'title'         => $t->title,
                'description'   => $t->description,
            ])->values()->all(),
        ]);
    }

    /** Admin panel — barcha tarjimalar */
    public static function adminResource(Video $video): array
    {
        return [
            'id'               => $video->id,
            'youtube_video_id' => $video->youtube_video_id,
            'youtube_url'      => $video->youtube_url,
            'video_path'       => $video->video_path,
            'video_url'        => self::resolveVideoUrl($video),
            'channel_name'     => $video->channel_name,
            'thumbnail_url'    => $video->youtube_video_id
                ? YouTubeHelper::thumbnailUrl($video->youtube_video_id)
                : null,
            'sort_order'       => $video->sort_order,
            'is_active'        => $video->is_active,
            'created_at'       => $video->created_at?->toIso8601String(),
            'translations'     => $video->translations->map(fn ($t) => [
                'id'            => $t->id,
                'language_id'   => $t->language_id,
                'language_code' => $t->language?->code,
                'title'         => $t->title,
                'description'   => $t->description,
            ])->values()->all(),
        ];
    }
}

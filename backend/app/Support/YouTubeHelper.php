<?php

namespace App\Support;

final class YouTubeHelper
{
    public static function extractVideoId(string $urlOrId): ?string
    {
        $input = trim($urlOrId);
        if ($input === '') {
            return null;
        }

        if (preg_match('/^[a-zA-Z0-9_-]{11}$/', $input)) {
            return $input;
        }

        $patterns = [
            '/(?:youtube\.com\/watch\?[^#]*v=|youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})/',
            '/youtu\.be\/([a-zA-Z0-9_-]{11})/',
            '/youtube\.com\/embed\/([a-zA-Z0-9_-]{11})/',
            '/youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})/',
            '/youtube\.com\/live\/([a-zA-Z0-9_-]{11})/',
        ];

        foreach ($patterns as $pattern) {
            if (preg_match($pattern, $input, $m)) {
                return $m[1];
            }
        }

        return null;
    }

    public static function canonicalUrl(string $videoId): string
    {
        return 'https://www.youtube.com/watch?v='.$videoId;
    }

    public static function thumbnailUrl(string $videoId, string $quality = 'hqdefault'): string
    {
        return 'https://img.youtube.com/vi/'.$videoId.'/'.$quality.'.jpg';
    }

    public static function embedUrl(string $videoId): string
    {
        return 'https://www.youtube.com/embed/'.$videoId;
    }
}

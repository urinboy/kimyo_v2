<?php

namespace Database\Seeders;

use App\Models\Language;
use App\Models\Video;
use App\Models\VideoTranslation;
use App\Support\YouTubeHelper;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class VideoSeeder extends Seeder
{
    public function run(): void
    {
        $lang = Language::query()->pluck('id', 'code')->all();

        DB::statement('PRAGMA foreign_keys = OFF');
        VideoTranslation::truncate();
        Video::truncate();
        DB::statement('PRAGMA foreign_keys = ON');

        foreach ($this->videosData() as $item) {
            $videoId = YouTubeHelper::extractVideoId($item['youtube_url']);
            if (! $videoId) {
                continue;
            }

            $video = Video::create([
                'youtube_video_id' => $videoId,
                'youtube_url'      => YouTubeHelper::canonicalUrl($videoId),
                'channel_name'     => $item['channel_name'] ?? null,
                'sort_order'       => $item['sort_order'] ?? 0,
                'is_active'        => $item['is_active'] ?? true,
            ]);

            foreach ($item['translations'] as $code => $tr) {
                if (empty($lang[$code])) {
                    continue;
                }
                VideoTranslation::create([
                    'video_id'    => $video->id,
                    'language_id' => $lang[$code],
                    'title'       => $tr['title'],
                    'description' => $tr['description'] ?? null,
                ]);
            }
        }
    }

    /** @return array<int, array<string, mixed>> */
    private function videosData(): array
    {
        return [
            [
                'youtube_url'  => 'https://www.youtube.com/watch?v=FJ89IqUb53A',
                'channel_name' => 'Kimyo darslari',
                'sort_order'   => 100,
                'is_active'    => true,
                'translations' => [
                    'uz' => [
                        'title'       => 'Kimyo darsi — video qo\'llanma',
                        'description' => 'Kimyo fanidan qo\'shimcha video material.',
                    ],
                    'ru' => [
                        'title'       => 'Урок химии — видеопособие',
                        'description' => 'Дополнительный видеоматериал по химии.',
                    ],
                    'en' => [
                        'title'       => 'Chemistry lesson — video guide',
                        'description' => 'Additional video material for chemistry.',
                    ],
                ],
            ],
        ];
    }
}

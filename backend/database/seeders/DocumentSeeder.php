<?php

namespace Database\Seeders;

use App\Models\Document;
use Illuminate\Database\Seeder;

class DocumentSeeder extends Seeder
{
    /**
     * PDF manbalari (tartib bo'yicha): storage/app/public/documents, keyin mobile/assets/pdf.
     */
    private const DOCS = [
        // --- Qarorlar (decisions) ---
        [
            'filename'   => 'qaror_847.pdf',
            'category'   => 'decisions',
            'title_uz'   => "Vazirlar Mahkamasi Qarori 847-son",
            'title_ru'   => "Постановление Кабинета Министров №847",
            'title_en'   => "Cabinet of Ministers Resolution No. 847",
            'sort_order' => 1,
        ],
        [
            'filename'   => 'pq_54.pdf',
            'category'   => 'decisions',
            'title_uz'   => "Prezident Qarori PQ-54",
            'title_ru'   => "Указ Президента ПК-54",
            'title_en'   => "Presidential Decree PD-54",
            'sort_order' => 2,
        ],
        [
            'filename'   => 'pq_2909.pdf',
            'category'   => 'decisions',
            'title_uz'   => "Prezident Qarori PQ-2909 (20.04.2017)",
            'title_ru'   => "Указ Президента ПК-2909 (20.04.2017)",
            'title_en'   => "Presidential Decree PD-2909 (20.04.2017)",
            'sort_order' => 3,
        ],
        [
            'filename'   => 'muallif.pdf',
            'category'   => 'decisions',
            'title_uz'   => "Muallif va nashriyot huquqlari to'g'risida",
            'title_ru'   => "Об авторских и издательских правах",
            'title_en'   => "On Author and Publishing Rights",
            'sort_order' => 4,
        ],
        [
            'filename'   => 'qiziqarli-topshiriqlar.pdf',
            'category'   => 'decisions',
            'title_uz'   => "Kimyodan qiziqarli topshiriqlar to'plami",
            'title_ru'   => "Сборник интересных заданий по химии",
            'title_en'   => "Collection of Interesting Chemistry Tasks",
            'sort_order' => 5,
        ],
        // --- Qonunlar (laws) ---
        [
            'filename'   => 'orq_637.pdf',
            'category'   => 'laws',
            'title_uz'   => "O'zbekiston Respublikasi Qonuni O'RQ-637-son",
            'title_ru'   => "Закон Республики Узбекистан ЗРУ-637",
            'title_en'   => "Law of the Republic of Uzbekistan No. 637",
            'sort_order' => 1,
        ],
        [
            'filename'   => 'orq_901.pdf',
            'category'   => 'laws',
            'title_uz'   => "O'zbekiston Respublikasi Qonuni O'RQ-901-son",
            'title_ru'   => "Закон Республики Узбекистан ЗРУ-901",
            'title_en'   => "Law of the Republic of Uzbekistan No. 901",
            'sort_order' => 2,
        ],
    ];

    public function run(): void
    {
        $mobileDir = base_path('../mobile/assets/pdf');
        $targetDir = storage_path('app/public/documents');

        if (! is_dir($targetDir)) {
            mkdir($targetDir, 0775, true);
        }

        $filenames = array_column(self::DOCS, 'filename');

        // Remove existing seeded records to avoid duplicates
        Document::whereIn('original_filename', $filenames)->delete();

        foreach (self::DOCS as $def) {
            $dest = $targetDir.DIRECTORY_SEPARATOR.$def['filename'];

            $src = null;
            foreach ([$dest, $mobileDir.DIRECTORY_SEPARATOR.$def['filename']] as $candidate) {
                if (is_file($candidate)) {
                    $src = $candidate;
                    break;
                }
            }

            $size = 0;
            if ($src !== null) {
                $srcReal = realpath($src);
                $destReal = is_file($dest) ? realpath($dest) : false;
                if ($srcReal !== $destReal) {
                    copy($src, $dest);
                }
                $size = (int) filesize($dest);
            }

            Document::create([
                'category'          => $def['category'],
                'title_uz'          => $def['title_uz'],
                'title_ru'          => $def['title_ru'],
                'title_en'          => $def['title_en'],
                'file_path'         => 'documents/'.$def['filename'],
                'original_filename' => $def['filename'],
                'mime_type'         => 'application/pdf',
                'file_size'         => $size,
                'sort_order'        => $def['sort_order'],
                'is_active'         => true,
            ]);

            if ($src !== null) {
                $this->command->info("  [ok] {$def['filename']} ({$def['category']})");
            } else {
                $this->command->warn("  [skip] PDF topilmadi (storage/app/public/documents yoki mobile/assets/pdf): {$def['filename']} — DB yozuvi file_size=0");
            }
        }

        $this->command->info('DocumentSeeder: ' . count(self::DOCS) . ' documents seeded.');
    }
}

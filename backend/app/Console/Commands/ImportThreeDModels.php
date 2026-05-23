<?php

namespace App\Console\Commands;

use App\Models\Language;
use App\Models\ThreeDModel;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ImportThreeDModels extends Command
{
    protected $signature   = 'models3d:import {--source= : GLB fayllar papkasi (default: ../3d_models)}';
    protected $description = 'Mavjud GLB fayllarni storage/app/public/3d-models/ ga ko\'chiradi va DB ga qo\'shadi';

    public function handle(): int
    {
        $sourceDir = $this->option('source') ?: base_path('../3d_models');

        if (! is_dir($sourceDir)) {
            $this->error("Papka topilmadi: {$sourceDir}");
            return self::FAILURE;
        }

        $files = glob($sourceDir . DIRECTORY_SEPARATOR . '*.{glb,gltf}', GLOB_BRACE);
        if (empty($files)) {
            $this->warn("GLB/GLTF fayl topilmadi: {$sourceDir}");
            return self::SUCCESS;
        }

        $languages = Language::all()->keyBy('code');
        $uzId = $languages['uz']?->id;
        $ruId = $languages['ru']?->id;
        $enId = $languages['en']?->id;

        if (! $uzId) {
            $this->error("'uz' tili DB da topilmadi. Avval tillarni yarating.");
            return self::FAILURE;
        }

        $this->info("Topildi: " . count($files) . " fayl.");
        $bar = $this->output->createProgressBar(count($files));
        $bar->start();

        foreach ($files as $filePath) {
            $basename  = basename($filePath);
            $slug      = pathinfo($basename, PATHINFO_FILENAME);
            $ext       = strtolower(pathinfo($basename, PATHINFO_EXTENSION));
            $destName  = $slug . '.' . $ext;
            $storagePath = '3d-models/' . $destName;

            // Faylni storage ga stream orqali ko'chirish (xotirani tejash uchun)
            $stream = fopen($filePath, 'rb');
            Storage::disk('public')->writeStream($storagePath, $stream);
            if (is_resource($stream)) {
                fclose($stream);
            }

            DB::transaction(function () use ($slug, $storagePath, $uzId, $ruId, $enId) {
                $model = ThreeDModel::updateOrCreate(
                    ['slug' => $slug],
                    [
                        'model_path' => $storagePath,
                        'is_active'  => true,
                        'sort_order' => 0,
                    ]
                );

                $defaultName = ucwords(str_replace('_', ' ', $slug));

                if ($uzId) {
                    $model->translations()->updateOrCreate(
                        ['language_id' => $uzId],
                        ['name' => $defaultName, 'description' => null]
                    );
                }
                if ($ruId) {
                    $model->translations()->updateOrCreate(
                        ['language_id' => $ruId],
                        ['name' => $defaultName, 'description' => null]
                    );
                }
                if ($enId) {
                    $model->translations()->updateOrCreate(
                        ['language_id' => $enId],
                        ['name' => $defaultName, 'description' => null]
                    );
                }
            });

            $bar->advance();
        }

        $bar->finish();
        $this->newLine();
        $this->info("Import muvaffaqiyatli yakunlandi!");

        return self::SUCCESS;
    }
}

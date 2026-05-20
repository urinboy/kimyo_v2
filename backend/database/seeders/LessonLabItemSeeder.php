<?php

namespace Database\Seeders;

use App\Models\Lesson;
use App\Models\LessonLabItem;
use Illuminate\Database\Seeder;

class LessonLabItemSeeder extends Seeder
{
    public function run(): void
    {
        $labs = Lesson::query()
            ->where('type', 'lab')
            ->orderBy('order')
            ->get();

        $kits = LaboratoryLabItemsKits::allKits();

        if ($labs->count() !== count($kits)) {
            $this->command?->warn(
                'Laboratoriya soni ('.$labs->count().') va to‘plamlar ('.count($kits).') mos kelmaydi. Birinchi '.min($labs->count(), count($kits)).' ta boyicha yuklanadi.'
            );
        }

        LessonLabItem::query()->whereIn('lesson_id', $labs->pluck('id'))->delete();

        foreach ($labs->values() as $index => $lesson) {
            if (! isset($kits[$index])) {
                break;
            }

            foreach ($kits[$index] as $item) {
                LessonLabItem::create([
                    'lesson_id' => $lesson->id,
                    'category' => $item['category'],
                    'name' => $item['name'],
                    'formula' => $item['formula'] ?? null,
                    'quantity' => $item['quantity'] ?? null,
                    'unit' => $item['unit'] ?? null,
                    'notes' => $item['notes'] ?? null,
                    'sort_order' => $item['sort_order'] ?? 0,
                    'is_required' => $item['is_required'] ?? true,
                    'is_active' => $item['is_active'] ?? true,
                ]);
            }
        }
    }
}

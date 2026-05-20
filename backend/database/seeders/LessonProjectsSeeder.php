<?php

namespace Database\Seeders;

use App\Models\InterestingTask;
use App\Models\TaskQuestion;
use App\Models\TaskSubmission;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Mavzular: Qoraqalpog‘iston tabiiy resurslari bo‘yicha «Loyihalar» (mashg‘ulot turi).
 */
class LessonProjectsSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function (): void {
            $projectIds = InterestingTask::query()
                ->where('task_kind', InterestingTask::KIND_PROJECT)
                ->pluck('id');
            if ($projectIds->isNotEmpty()) {
                TaskSubmission::whereIn('task_id', $projectIds)->delete();
                TaskQuestion::whereIn('task_id', $projectIds)->delete();
                InterestingTask::whereIn('id', $projectIds)->delete();
            }

            $defs = $this->definitions();
            foreach ($defs as $order => $def) {
                $task = InterestingTask::create([
                    'title'       => $def['title'],
                    'description' => $def['description'] ?? null,
                    'is_active'   => true,
                    'sort_order'  => $order,
                    'task_kind'   => InterestingTask::KIND_PROJECT,
                ]);
                foreach ($def['questions'] as $qOrder => $body) {
                    TaskQuestion::create([
                        'task_id'       => $task->id,
                        'body'          => $body,
                        'sort_order'    => $qOrder,
                        'question_type' => TaskQuestion::TYPE_TEXT,
                    ]);
                }
            }
        });
    }

    /** @return list<array{title: string, description?: string|null, questions: list<string>}> */
    private function definitions(): array
    {
        return [
            [
                'title' => 'Qoraqalpog‘iston tabiiy tuz va mineral resurslaridan sanoatda foydalanish texnologiyalari',
                'description' => '9-sinf: tuz-kon kimyosi, minerallardan soda, sement va boshqa mahsulotlar',
                'questions' => [
                    'Nima uchun Qoraqalpog‘iston tabiiy tuz va mineral resurslarini sanoatda qayta ishlash muhim hisoblanadi?',
                    'Qoraqalpog‘iston hududida qanday asosiy tabiiy mineral va tuz konlari mavjud va ularning kimyoviy tarkibi qanday?',
                    'Tabiiy tuz va mineral xomashyolardan sanoat mahsulotlari (soda, sement, kimyoviy tuzlar) qanday texnologik bosqichlar orqali olinadi?',
                    'Mahalliy mineral resurslardan foydalanishning iqtisodiy va ekologik afzalliklari hamda muammolari nimalardan iborat?',
                    'Siz Qoraqalpog‘iston tabiiy resurslaridan foydalanish jarayonini qanday mobil ilova modeli (3D, sxema, video yoki interaktiv xarita) ko‘rinishida ifodalaysiz?',
                ],
            ],
            [
                'title' => 'Qoraqalpog‘iston ohaktosh va gips konlaridan qurilish materiallari ishlab chiqarish texnologiyasi',
                'description' => 'Ohaktosh, gips, sement va gips plitalar ishlab chiqarish',
                'questions' => [
                    'Ohaktosh va gips nima va ularning kimyoviy tarkibi qanday?',
                    'Qoraqalpog‘istonda bu resurslar qayerlarda uchraydi?',
                    'Ohaktosh va gipsdan sement va gips plitalar qanday olinadi?',
                    'Ushbu ishlab chiqarish ekologiyaga qanday ta’sir qiladi?',
                    'Siz ushbu jarayonni qanday model (sxema/3D/video)da ko‘rsatasiz?',
                ],
            ],
            [
                'title' => 'Qoraqalpog‘iston neft va gaz resurslaridan energiya olish texnologiyasi',
                'description' => 'Neft va gaz qayta ishlashi, elektr energiyasi',
                'questions' => [
                    'Neft va gaz qanday tabiiy sharoitda hosil bo‘ladi?',
                    'Qoraqalpog‘istonda qaysi gaz konlari mavjud?',
                    'Neft va gaz qanday bosqichlarda qayta ishlanadi?',
                    'Energiya ishlab chiqarishda ularning ahamiyati nima?',
                    'Siz ushbu jarayonni qanday interaktiv modelda ko‘rsatasiz?',
                ],
            ],
            [
                'title' => 'Qoraqalpog‘iston qum va shag‘al konlaridan qurilish sanoatida foydalanish',
                'description' => 'Aggregatlar, beton uchun xomashyo',
                'questions' => [
                    'Qum va shag‘alning tarkibi va xossalari qanday?',
                    'Ular qaysi hududlardan qazib olinadi?',
                    'Beton ishlab chiqarishda ularning roli nima?',
                    'Haddan tashqari qazib olish qanday ekologik muammo keltiradi?',
                    'Ushbu jarayonni qanday vizual loyiha qilib ko‘rsatasiz?',
                ],
            ],
            [
                'title' => 'Qoraqalpog‘iston yer osti suvlari va ularning ichimlik suvi sifatida foydalanilishi',
                'description' => 'Suv resurslari, tozalash, tanqislik',
                'questions' => [
                    'Yer osti suvlari qanday hosil bo‘ladi?',
                    'Qoraqalpog‘istonda suv resurslari holati qanday?',
                    'Suvni tozalash texnologiyalari qanday ishlaydi?',
                    'Suv tanqisligi qanday muammolarni keltirib chiqaradi?',
                    'Siz suv tozalash jarayonini qanday modelda ifodalay olasiz?',
                ],
            ],
            [
                'title' => 'Qoraqalpog‘iston mineral resurslarining ekologik monitoringi va barqaror foydalanish',
                'description' => 'Monitoring, barqarorlik, ekologiya',
                'questions' => [
                    'Mineral resurslar deganda nimalar tushuniladi?',
                    'Resurslardan noto‘g‘ri foydalanish qanday oqibatlarga olib keladi?',
                    'Ekologik monitoring nima va qanday amalga oshiriladi?',
                    'Barqaror foydalanish deganda nimani tushunasiz?',
                    'Siz ekologik monitoringni mobil ilovada qanday ko‘rsatasiz?',
                ],
            ],
        ];
    }
}

<?php

namespace Database\Seeders;

use App\Models\Option;
use App\Models\Question;
use App\Models\Quiz;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;

class GeographyPhenomenaSeeder extends Seeder
{
    use SeedsTranslatableByLanguageCode;

    public function run(): void
    {
        $byCode = $this->languageIdsByCode();

        $quiz = Quiz::query()->updateOrCreate(
            [
                'category' => 'tabiiy_hodisalar',
                'type' => 'geography',
            ],
            [
                'lesson_id' => null,
                'is_active' => true,
                'title_uz' => 'Tabiiy hodisalar',
                'title_ru' => 'Природные явления',
                'title_en' => 'Natural phenomena',
                'sort_order' => 70,
            ]
        );

        $quiz->questions()->delete();

        foreach ($this->questionBank() as $index => $q) {
            $question = Question::create([
                'quiz_id' => $quiz->id,
                'order' => $index + 1,
                'points' => $q['points'] ?? 1,
            ]);
            $this->seedQuestionTranslationRows($question, $q['translations'], $byCode);
            foreach ($q['options'] as $o) {
                $option = Option::create([
                    'question_id' => $question->id,
                    'is_correct' => $o['is_correct'],
                ]);
                $this->seedOptionTranslationRows($option, $o['translations'], $byCode);
            }
        }
    }

    private function questionBank(): array
    {
        return [
            [
                'translations' => [
                    1 => ['text' => 'Zilzila nima?'],
                    2 => ['text' => 'Землетрясение —'],
                    3 => ['text' => 'An earthquake is:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Faqat shamol', 2 => 'Ветер', 3 => 'Wind only']],
                    ['is_correct' => true, 'translations' => [1 => "Yer qobig'ining seismik silkinishlari", 2 => 'Сейсмика', 3 => 'Seismic shaking of the crust']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat qurg'oq", 2 => 'Засуха', 3 => 'Drought only']],
                    ['is_correct' => false, 'translations' => [1 => "Dengiz to'lqini", 2 => 'Волна', 3 => 'Wave']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Sel oqimlari qachon?'],
                    2 => ['text' => 'Сели при'],
                    3 => ['text' => 'Mud/debris flows often after:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Faqat cho'l issiqlik", 2 => 'Только зной', 3 => 'Desert heat']],
                    ['is_correct' => true, 'translations' => [1 => "Tog' yonbag'irida yomg'ir yoki totuv", 2 => 'Осадки/таяние', 3 => 'Rain or melt on slopes']],
                    ['is_correct' => false, 'translations' => [1 => "Dengiz cho'kishi", 2 => 'Отлив', 3 => 'Tide']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat tuman', 2 => 'Туман', 3 => 'Fog only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Qong'irtov?"],
                    2 => ['text' => 'Камнепад —'],
                    3 => ['text' => 'Rockfall is:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Suvsiz daryo', 2 => 'Сухарь', 3 => 'Dry wadi']],
                    ['is_correct' => true, 'translations' => [1 => "Tog' yonbag'iridan tosh tushishi", 2 => 'Сход пород', 3 => 'Rocks on steep slope']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat qum bo'roni", 2 => 'Пыль', 3 => 'Dust only']],
                    ['is_correct' => false, 'translations' => [1 => "Dengiz to'lqini", 2 => 'Волна', 3 => 'Wave']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Qurg'oqchilik?"],
                    2 => ['text' => 'Засуха —'],
                    3 => ['text' => 'Drought:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Faqat qish sovuq', 2 => 'Холод', 3 => 'Cold only']],
                    ['is_correct' => true, 'translations' => [1 => "Uzoq yog'insizlik va suv tanqisligi", 2 => 'Недостаток осадков', 3 => 'Lack of rain and water']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat tuman', 2 => 'Туман', 3 => 'Fog']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat qor', 2 => 'Снег', 3 => 'Snow']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Shamol relyefga?'],
                    2 => ['text' => 'Ветер —'],
                    3 => ['text' => 'Winds:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Faqat dengiz sathi', 2 => 'Море', 3 => 'Sea only']],
                    ['is_correct' => true, 'translations' => [1 => 'Parchin, chang, eroziya', 2 => 'Пыль, эрозия', 3 => 'Dust, erosion']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat muz yig'ish", 2 => 'Накопление льда', 3 => 'Only ice buildup']],
                    ['is_correct' => false, 'translations' => [1 => "Tuz cho'kmasi", 2 => 'Солончак', 3 => 'Only salt pan']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Sovuq yoki issiq to'lqinlar?"],
                    2 => ['text' => 'Тепловая волна — риск для'],
                    3 => ['text' => 'Heat/cold waves threaten:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Faqat qush", 2 => 'Птицы', 3 => 'Birds']],
                    ['is_correct' => true, 'translations' => [1 => 'Salomatlik va ekinlar', 2 => 'Здоровье, урожай', 3 => 'Health, crops']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat o'rmon", 2 => 'Лес', 3 => 'Forests only']],
                    ['is_correct' => false, 'translations' => [1 => 'Dengiz transporti', 2 => 'Суда', 3 => 'Ships']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Ko'chki?"],
                    2 => ['text' => 'Оползни —'],
                    3 => ['text' => 'Landslides when:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Quruq qum", 2 => 'Сухой', 3 => 'Very dry only']],
                    ['is_correct' => true, 'translations' => [1 => 'Namlanish va moyil tuproq', 2 => 'Перенасыщение', 3 => 'Saturated, unstable soil']],
                    ['is_correct' => false, 'translations' => [1 => 'Dengiz kabi', 2 => 'Плоско', 3 => 'Like sea']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat muz', 2 => 'Лёд', 3 => 'Ice only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Muzlik erishi?'],
                    2 => ['text' => 'Таяние — меняет'],
                    3 => ['text' => 'Melting ice changes:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Faqat tuman', 2 => 'Туман', 3 => 'Fog only']],
                    ['is_correct' => true, 'translations' => [1 => "Suv oqimlari, muz hajmi", 2 => 'Сбор, сток', 3 => 'Runoff, supply']],
                    ['is_correct' => false, 'translations' => [1 => "Dengiz qumini yo'qotadi", 2 => 'Пустыни', 3 => 'Deserts vanish']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat cho'kma", 2 => 'Впадина', 3 => 'Sinking only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Tog' va suvga eng bog'liq guruh?"],
                    2 => ['text' => 'Связь с горами и стоком:'],
                    3 => ['text' => 'Group tied to mountains and flow:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Faqat qurg'oq", 2 => 'Засуха', 3 => 'Drought & waves only']],
                    ['is_correct' => true, 'translations' => [1 => "Sel, qo'ng'irtov, ko'chki", 2 => 'Сели, обвалы, оползни', 3 => 'Mudflow, rockfall, slide']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat shamol', 2 => 'Ветер', 3 => 'Winds only']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat muz', 2 => 'Снег', 3 => 'Snow only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Global isish?"],
                    2 => ['text' => 'Глобальное потепление —'],
                    3 => ['text' => 'Global warming:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Faqat lokal tuman', 2 => 'Туман', 3 => 'Local fog']],
                    ['is_correct' => true, 'translations' => [1 => "Iqlim o'zgarishi va muzlarning kichrayishi", 2 => 'Изменение климата, льды', 3 => 'Climate change, less ice']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat zilzila chastotasi', 2 => 'Сейсмика', 3 => 'Seismic only']],
                    ['is_correct' => false, 'translations' => [1 => 'Dengiz sathi tushadi', 2 => 'Океан', 3 => 'Oceans always drop']],
                ],
            ],
        ];
    }
}

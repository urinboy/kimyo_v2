<?php

namespace Database\Seeders;

use App\Models\Option;
use App\Models\Question;
use App\Models\Quiz;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;

/**
 * "Qit'alar" — geografiyaning 2-testi (10 savol), mobil skrinlar bilan mos.
 */
class GeographyContinentsSeeder extends Seeder
{
    use SeedsTranslatableByLanguageCode;

    public function run(): void
    {
        $byCode = $this->languageIdsByCode();

        $quiz = Quiz::query()->updateOrCreate(
            [
                'category' => 'qitalar',
                'type' => 'geography',
            ],
            [
                'lesson_id' => null,
                'is_active' => true,
                'title_uz' => "Qit'alar",
                'title_ru' => 'Континенты',
                'title_en' => 'Continents',
                'sort_order' => 10,
            ]
        );

        $quiz->questions()->delete();

        $bank = $this->continentsQuestionBank();

        foreach ($bank as $index => $q) {
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

    /**
     * @return list<array{points?: int, translations: array<int, array{text: string}>, options: list<array{is_correct: bool, translations: array<int, string>}>}>
     */
    private function continentsQuestionBank(): array
    {
        return [
            [
                'translations' => [
                    1 => ['text' => 'Eng katta qit\'a qaysi?'],
                    2 => ['text' => 'Какой самый большой континент?'],
                    3 => ['text' => 'Which is the largest continent?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Afrika', 2 => 'Африка', 3 => 'Africa']],
                    ['is_correct' => false, 'translations' => [1 => 'Shimoliy Amerika', 2 => 'Северная Америка', 3 => 'North America']],
                    ['is_correct' => true, 'translations' => [1 => 'Yevroosiyo', 2 => 'Евразия', 3 => 'Eurasia']],
                    ['is_correct' => false, 'translations' => [1 => 'Janubiy Amerika', 2 => 'Южная Америка', 3 => 'South America']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Eng kichik qit\'a qaysi?'],
                    2 => ['text' => 'Какой самый маленький континент?'],
                    3 => ['text' => 'Which is the smallest continent?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Antarktida', 2 => 'Антарктида', 3 => 'Antarctica']],
                    ['is_correct' => true, 'translations' => [1 => 'Avstraliya', 2 => 'Австралия', 3 => 'Australia']],
                    ['is_correct' => false, 'translations' => [1 => 'Janubiy Amerika', 2 => 'Южная Америка', 3 => 'South America']],
                    ['is_correct' => false, 'translations' => [1 => 'Yevropa', 2 => 'Европа', 3 => 'Europe']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Qaysi qit\'ada doimiy aholi yashamaydi?'],
                    2 => ['text' => 'На каком континенте нет постоянного населения?'],
                    3 => ['text' => 'Which continent has no permanent population?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Avstraliya', 2 => 'Австралия', 3 => 'Australia']],
                    ['is_correct' => true, 'translations' => [1 => 'Antarktida', 2 => 'Антарктида', 3 => 'Antarctica']],
                    ['is_correct' => false, 'translations' => [1 => 'Shimoliy Amerika', 2 => 'Северная Америка', 3 => 'North America']],
                    ['is_correct' => false, 'translations' => [1 => 'Janubiy Amerika', 2 => 'Южная Америка', 3 => 'South America']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Afrika qit\'asini Yevroosiyodan ajratib turuvchi kanal?'],
                    2 => ['text' => 'Какой канал отделяет Африку от Евразии?'],
                    3 => ['text' => 'Which canal separates Africa from Eurasia?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Panama kanali', 2 => 'Панамский канал', 3 => 'Panama Canal']],
                    ['is_correct' => true, 'translations' => [1 => 'Suvaysh kanali', 2 => 'Суэцкий канал', 3 => 'Suez Canal']],
                    ['is_correct' => false, 'translations' => [1 => 'Grand Kanal', 2 => 'Великий канал', 3 => 'Grand Canal']],
                    ['is_correct' => false, 'translations' => [1 => 'Kiel kanali', 2 => 'Кильский канал', 3 => 'Kiel Canal']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Eng baland cho\'qqi (Everest) qaysi qit\'ada joylashgan?'],
                    2 => ['text' => 'На каком континенте находится высшая вершина (Эверест)?'],
                    3 => ['text' => 'On which continent is the highest peak (Everest) located?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Afrika', 2 => 'Африка', 3 => 'Africa']],
                    ['is_correct' => true, 'translations' => [1 => 'Yevroosiyo', 2 => 'Евразия', 3 => 'Eurasia']],
                    ['is_correct' => false, 'translations' => [1 => 'Shimoliy Amerika', 2 => 'Северная Америка', 3 => 'North America']],
                    ['is_correct' => false, 'translations' => [1 => 'Janubiy Amerika', 2 => 'Южная Америка', 3 => 'South America']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Amazonka daryosi qaysi qit\'ada oqadi?'],
                    2 => ['text' => 'В каком континенте протекает река Амазонка?'],
                    3 => ['text' => 'On which continent does the Amazon River flow?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Afrika', 2 => 'Африка', 3 => 'Africa']],
                    ['is_correct' => false, 'translations' => [1 => 'Shimoliy Amerika', 2 => 'Северная Америка', 3 => 'North America']],
                    ['is_correct' => true, 'translations' => [1 => 'Janubiy Amerika', 2 => 'Южная Америка', 3 => 'South America']],
                    ['is_correct' => false, 'translations' => [1 => 'Yevroosiyo', 2 => 'Евразия', 3 => 'Eurasia']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Sahroi Kabir cho\'li qaysi qit\'ada joylashgan?'],
                    2 => ['text' => 'На каком континенте расположена пустыня Сахара?'],
                    3 => ['text' => 'On which continent is the Sahara Desert located?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Osiyo', 2 => 'Азия', 3 => 'Asia']],
                    ['is_correct' => false, 'translations' => [1 => 'Avstraliya', 2 => 'Австралия', 3 => 'Australia']],
                    ['is_correct' => true, 'translations' => [1 => 'Afrika', 2 => 'Африка', 3 => 'Africa']],
                    ['is_correct' => false, 'translations' => [1 => 'Janubiy Amerika', 2 => 'Южная Америка', 3 => 'South America']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Qaysi qit\'a «Yashil qit\'a» deb ham ataladi?'],
                    2 => ['text' => 'Какой континент также называют «зелёным континентом»?'],
                    3 => ['text' => 'Which continent is also called the "Green Continent"?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Yevropa', 2 => 'Европа', 3 => 'Europe']],
                    ['is_correct' => false, 'translations' => [1 => 'Shimoliy Amerika', 2 => 'Северная Америка', 3 => 'North America']],
                    ['is_correct' => true, 'translations' => [1 => 'Avstraliya', 2 => 'Австралия', 3 => 'Australia']],
                    ['is_correct' => false, 'translations' => [1 => 'Osiyo', 2 => 'Азия', 3 => 'Asia']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Nil daryosi qaysi qit\'ada?'],
                    2 => ['text' => 'На каком континенте река Нил?'],
                    3 => ['text' => 'On which continent is the Nile River?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Janubiy Amerika', 2 => 'Южная Америка', 3 => 'South America']],
                    ['is_correct' => true, 'translations' => [1 => 'Afrika', 2 => 'Африка', 3 => 'Africa']],
                    ['is_correct' => false, 'translations' => [1 => 'Osiyo', 2 => 'Азия', 3 => 'Asia']],
                    ['is_correct' => false, 'translations' => [1 => 'Yevropa', 2 => 'Европа', 3 => 'Europe']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Pingvinlar asosan qaysi qit\'a/hududda yashaydi?'],
                    2 => ['text' => 'В каком основном регионе обитают пингвины?'],
                    3 => ['text' => 'In which main continent/region do penguins mainly live?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Arktika', 2 => 'Арктика', 3 => 'Arctic']],
                    ['is_correct' => true, 'translations' => [1 => 'Antarktida', 2 => 'Антарктида', 3 => 'Antarctica']],
                    ['is_correct' => false, 'translations' => [1 => 'Grenlandiya', 2 => 'Гренландия', 3 => 'Greenland']],
                    ['is_correct' => false, 'translations' => [1 => 'Alyaska', 2 => 'Аляска', 3 => 'Alaska']],
                ],
            ],
        ];
    }
}

<?php

namespace Database\Seeders;

use App\Models\Option;
use App\Models\Question;
use App\Models\Quiz;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;

/**
 * "Poytaxtlar" — geografiyaning 3-testi (10 savol), mobil skrinlar bilan mos.
 */
class GeographyCapitalsSeeder extends Seeder
{
    use SeedsTranslatableByLanguageCode;

    public function run(): void
    {
        $byCode = $this->languageIdsByCode();

        $quiz = Quiz::query()->updateOrCreate(
            [
                'category' => 'poytaxtlar',
                'type' => 'geography',
            ],
            [
                'lesson_id' => null,
                'is_active' => true,
                'title_uz' => 'Poytaxtlar',
                'title_ru' => 'Столицы',
                'title_en' => 'Capitals',
                'sort_order' => 20,
            ]
        );

        $quiz->questions()->delete();

        $bank = $this->capitalsQuestionBank();

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
    private function capitalsQuestionBank(): array
    {
        return [
            [
                'translations' => [
                    1 => ['text' => 'O‘zbekiston poytaxti qaysi?'],
                    2 => ['text' => 'Какова столица Узбекистана?'],
                    3 => ['text' => 'What is the capital of Uzbekistan?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => 'Toshkent', 2 => 'Ташкент', 3 => 'Tashkent']],
                    ['is_correct' => false, 'translations' => [1 => 'Samarqand', 2 => 'Самарканд', 3 => 'Samarkand']],
                    ['is_correct' => false, 'translations' => [1 => 'Buxoro', 2 => 'Бухара', 3 => 'Bukhara']],
                    ['is_correct' => false, 'translations' => [1 => 'Andijon', 2 => 'Андижан', 3 => 'Andijan']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'AQSh poytaxti?'],
                    2 => ['text' => 'Столица США?'],
                    3 => ['text' => 'Capital of the USA?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Nyu-York', 2 => 'Нью-Йорк', 3 => 'New York']],
                    ['is_correct' => true, 'translations' => [1 => 'Vashington', 2 => 'Вашингтон', 3 => 'Washington D.C.']],
                    ['is_correct' => false, 'translations' => [1 => 'Los-Anjeles', 2 => 'Лос-Анджелес', 3 => 'Los Angeles']],
                    ['is_correct' => false, 'translations' => [1 => 'Chikago', 2 => 'Чикаго', 3 => 'Chicago']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Turkiya poytaxti?'],
                    2 => ['text' => 'Столица Турции?'],
                    3 => ['text' => 'Capital of Turkey?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Istanbul', 2 => 'Стамбул', 3 => 'Istanbul']],
                    ['is_correct' => false, 'translations' => [1 => 'Izmir', 2 => 'Измир', 3 => 'Izmir']],
                    ['is_correct' => true, 'translations' => [1 => 'Anqara', 2 => 'Анкара', 3 => 'Ankara']],
                    ['is_correct' => false, 'translations' => [1 => 'Antaliya', 2 => 'Анталья', 3 => 'Antalya']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Fransiya poytaxti?'],
                    2 => ['text' => 'Столица Франции?'],
                    3 => ['text' => 'Capital of France?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Lion', 2 => 'Лион', 3 => 'Lyon']],
                    ['is_correct' => false, 'translations' => [1 => 'Marsel', 2 => 'Марсель', 3 => 'Marseille']],
                    ['is_correct' => true, 'translations' => [1 => 'Parij', 2 => 'Париж', 3 => 'Paris']],
                    ['is_correct' => false, 'translations' => [1 => 'Nitssa', 2 => 'Ницца', 3 => 'Nice']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Yaponiya poytaxti?'],
                    2 => ['text' => 'Столица Японии?'],
                    3 => ['text' => 'Capital of Japan?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Seul', 2 => 'Сеул', 3 => 'Seoul']],
                    ['is_correct' => false, 'translations' => [1 => 'Pekin', 2 => 'Пекин', 3 => 'Beijing']],
                    ['is_correct' => true, 'translations' => [1 => 'Tokio', 2 => 'Токио', 3 => 'Tokyo']],
                    ['is_correct' => false, 'translations' => [1 => 'Osaka', 2 => 'Осака', 3 => 'Osaka']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Qozog‘iston poytaxti?'],
                    2 => ['text' => 'Столица Казахстана?'],
                    3 => ['text' => 'Capital of Kazakhstan?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Olmaota', 2 => 'Алматы', 3 => 'Almaty']],
                    ['is_correct' => true, 'translations' => [1 => 'Astana', 2 => 'Астана', 3 => 'Astana']],
                    ['is_correct' => false, 'translations' => [1 => 'Chimkent', 2 => 'Шымкент', 3 => 'Shymkent']],
                    ['is_correct' => false, 'translations' => [1 => 'Turkiston', 2 => 'Туркестан', 3 => 'Turkistan']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Germaniya poytaxti?'],
                    2 => ['text' => 'Столица Германии?'],
                    3 => ['text' => 'Capital of Germany?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Myunxen', 2 => 'Мюнхен', 3 => 'Munich']],
                    ['is_correct' => false, 'translations' => [1 => 'Gamburg', 2 => 'Гамбург', 3 => 'Hamburg']],
                    ['is_correct' => true, 'translations' => [1 => 'Berlin', 2 => 'Берлин', 3 => 'Berlin']],
                    ['is_correct' => false, 'translations' => [1 => 'Frankfurt', 2 => 'Франкфурт', 3 => 'Frankfurt']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Braziliya poytaxti?'],
                    2 => ['text' => 'Столица Бразилии?'],
                    3 => ['text' => 'Capital of Brazil?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Rio-de-Janeyro', 2 => 'Рио-де-Жанейро', 3 => 'Rio de Janeiro']],
                    ['is_correct' => false, 'translations' => [1 => 'San-Paulu', 2 => 'Сан-Паулу', 3 => 'São Paulo']],
                    ['is_correct' => true, 'translations' => [1 => 'Brazilia', 2 => 'Бразилиа', 3 => 'Brasília']],
                    ['is_correct' => false, 'translations' => [1 => 'Salvador', 2 => 'Сальвадор', 3 => 'Salvador']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Xitoy poytaxti?'],
                    2 => ['text' => 'Столица Китая?'],
                    3 => ['text' => 'Capital of China?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Shanxay', 2 => 'Шанхай', 3 => 'Shanghai']],
                    ['is_correct' => false, 'translations' => [1 => 'Gonkong', 2 => 'Гонконг', 3 => 'Hong Kong']],
                    ['is_correct' => true, 'translations' => [1 => 'Pekin', 2 => 'Пекин', 3 => 'Beijing']],
                    ['is_correct' => false, 'translations' => [1 => 'Urumchi', 2 => 'Урумчи', 3 => 'Urumqi']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Misr poytaxti?'],
                    2 => ['text' => 'Столица Египта?'],
                    3 => ['text' => 'Capital of Egypt?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Iskandariya', 2 => 'Александрия', 3 => 'Alexandria']],
                    ['is_correct' => true, 'translations' => [1 => 'Qohira', 2 => 'Каир', 3 => 'Cairo']],
                    ['is_correct' => false, 'translations' => [1 => 'Luksor', 2 => 'Луксор', 3 => 'Luxor']],
                    ['is_correct' => false, 'translations' => [1 => 'Giza', 2 => 'Гиза', 3 => 'Giza']],
                ],
            ],
        ];
    }
}

<?php

namespace Database\Seeders;

use App\Models\Option;
use App\Models\Question;
use App\Models\Quiz;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;

/**
 * Tog' jinslari (tog' tizimlari) — 10 savol, mobil dars matnlari bilan mos.
 */
class GeographyRocksSeeder extends Seeder
{
    use SeedsTranslatableByLanguageCode;

    public function run(): void
    {
        $byCode = $this->languageIdsByCode();

        $quiz = Quiz::query()->updateOrCreate(
            [
                'category' => 'tog_jinslari',
                'type' => 'geography',
            ],
            [
                'lesson_id' => null,
                'is_active' => true,
                'title_uz' => "Tog' jinslari",
                'title_ru' => 'Горные породы',
                'title_en' => 'Rocks & mountain ranges',
                'sort_order' => 40,
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

    /**
     * @return list<array{points?: int, translations: array<int, array{text: string}>, options: list<array{is_correct: bool, translations: array<int, string>}>}>
     */
    private function questionBank(): array
    {
        return [
            [
                'translations' => [
                    1 => ['text' => "O'zbekistonning qancha qismi tog'li (taxminan)?"],
                    2 => ['text' => 'Какую часть площади (прибл.) занимают горы в Узбекистане?'],
                    3 => ['text' => 'Roughly what share of Uzbekistan is mountainous?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '~5%', 2 => '~5%', 3 => '~5%']],
                    ['is_correct' => true, 'translations' => [1 => '~20%', 2 => '~20%', 3 => '~20%']],
                    ['is_correct' => false, 'translations' => [1 => '~50%', 2 => '~50%', 3 => '~50%']],
                    ['is_correct' => false, 'translations' => [1 => '~80%', 2 => '~80%', 3 => '~80%']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "O'zbekistondagi eng baland cho'qqi (Adelunga) qancha metr? (Tyan-Shan)"],
                    2 => ['text' => 'Высшая вершина (Адельунга) в м? (Тянь-Шань)'],
                    3 => ['text' => 'Adelunga peak (Tien Shan) height in meters?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '2,169 m', 2 => '2 169 м', 3 => '2,169 m']],
                    ['is_correct' => false, 'translations' => [1 => '3,769 m', 2 => '3 769 м', 3 => '3,769 m']],
                    ['is_correct' => true, 'translations' => [1 => '4,301 m', 2 => '4 301 м', 3 => '4,301 m']],
                    ['is_correct' => false, 'translations' => [1 => '1,500 m', 2 => '1 500 м', 3 => '1,500 m']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Tyan-Shan tizilidagi cho'qqilar uchun materialda qaysi balandlik keltirilgan?"],
                    2 => ['text' => 'Какая высотная величина дана по Тянь-Шаню?'],
                    3 => ['text' => 'Which max height (course) is given for the Tien Shan?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '922 m', 2 => '922 м', 3 => '922 m']],
                    ['is_correct' => false, 'translations' => [1 => '1,500 m', 2 => '1 500 м', 3 => '1,500 m']],
                    ['is_correct' => true, 'translations' => [1 => '4,301 m', 2 => '4 301 м', 3 => '4,301 m']],
                    ['is_correct' => false, 'translations' => [1 => '4,600 m', 2 => '4 600 м', 3 => '4,600 m']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Pamir-Oloy tizilari uchun qanday maksimum balandlik (material) keltirilgan?"],
                    2 => ['text' => 'Какая величина по Памиро-Алаю?'],
                    3 => ['text' => 'Which height is given for Pamir–Alay in the data?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '922 m', 2 => '922 м', 3 => '922 m']],
                    ['is_correct' => false, 'translations' => [1 => '2,169 m', 2 => '2 169 м', 3 => '2,169 m']],
                    ['is_correct' => false, 'translations' => [1 => '3,769 m', 2 => '3 769 м', 3 => '3,769 m']],
                    ['is_correct' => true, 'translations' => [1 => '4,600 m', 2 => '4 600 м', 3 => '4,600 m']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Nurota tog'larining maksimal balandligi (material) necha m?"],
                    2 => ['text' => 'Макс. высота Нуратинских гор (м)?'],
                    3 => ['text' => 'Max height of Nurata in meters?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '922 m', 2 => '922 м', 3 => '922 m']],
                    ['is_correct' => false, 'translations' => [1 => '1,500 m', 2 => '1 500 м', 3 => '1,500 m']],
                    ['is_correct' => true, 'translations' => [1 => '2,169 m', 2 => '2 169 м', 3 => '2,169 m']],
                    ['is_correct' => false, 'translations' => [1 => '3,769 m', 2 => '3 769 м', 3 => '3,769 m']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Kopetdog' tog'larining maksimal balandligi (material) necha m?"],
                    2 => ['text' => 'Высотный ориентир Копетдага (м)?'],
                    3 => ['text' => 'Approx. max height of Kopet Dag (m)?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '922 m', 2 => '922 м', 3 => '922 m']],
                    ['is_correct' => true, 'translations' => [1 => '1,500 m', 2 => '1 500 м', 3 => '1,500 m']],
                    ['is_correct' => false, 'translations' => [1 => '2,169 m', 2 => '2 169 м', 3 => '2,169 m']],
                    ['is_correct' => false, 'translations' => [1 => '4,301 m', 2 => '4 301 м', 3 => '4,301 m']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Qoratov tog'larining maksimal balandligi necha m?"],
                    2 => ['text' => 'Макс. высота Каратау (м)?'],
                    3 => ['text' => 'Max height of Karatau in meters?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => '922 m', 2 => '922 м', 3 => '922 m']],
                    ['is_correct' => false, 'translations' => [1 => '1,500 m', 2 => '1 500 м', 3 => '1,500 m']],
                    ['is_correct' => false, 'translations' => [1 => '2,169 m', 2 => '2 169 м', 3 => '2,169 m']],
                    ['is_correct' => false, 'translations' => [1 => '3,769 m', 2 => '3 769 м', 3 => '3,769 m']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Qurama tog'larining maksimal balandligi (material) necha m?"],
                    2 => ['text' => 'Ориентир высоты Курама (м)?'],
                    3 => ['text' => 'Approx. max height of Kurama in meters?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '2,169 m', 2 => '2 169 м', 3 => '2,169 m']],
                    ['is_correct' => true, 'translations' => [1 => '3,769 m', 2 => '3 769 м', 3 => '3,769 m']],
                    ['is_correct' => false, 'translations' => [1 => '4,300 m', 2 => '4 300 м', 3 => '4,300 m']],
                    ['is_correct' => false, 'translations' => [1 => '4,600 m', 2 => '4 600 м', 3 => '4,600 m']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Materiallar bo'yicha O'zbekistondagi asosiy tog' tizimlarini belgilang."],
                    2 => ['text' => 'Основные горные системы (по материалу).'],
                    3 => ['text' => 'The two main systems in the data are:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Nurota va Qoratov', 2 => 'Нурата и Каратау', 3 => 'Nurata and Karatau']],
                    ['is_correct' => true, 'translations' => [1 => "Tyan-Shan va Pamir-Oloy", 2 => 'Тянь-Шань и Памиро-Алай', 3 => 'Tien Shan and Pamir–Alay']],
                    ['is_correct' => false, 'translations' => [1 => "Farg'ona va Ustyurt", 2 => 'Фергана и Устюрт', 3 => 'Fergana and Ustyurt']],
                    ['is_correct' => false, 'translations' => [1 => "Hind tog'lari", 2 => 'Гималаи', 3 => 'Himalayas']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "O'zbekistondagi muzliklarning yig'indiy maydoni (taxmin) necha km²?"],
                    2 => ['text' => 'Совокупная площадь ледников (прибл., км²)?'],
                    3 => ['text' => 'Total glacier area in Uzbekistan (approx., km²)?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '50 km²', 2 => '50 км²', 3 => '50 km²']],
                    ['is_correct' => false, 'translations' => [1 => '~200 km²', 2 => '~200 км²', 3 => '~200 km²']],
                    ['is_correct' => true, 'translations' => [1 => '~650 km²', 2 => '~650 км²', 3 => '~650 km²']],
                    ['is_correct' => false, 'translations' => [1 => '5,000 km²', 2 => '5 000 км²', 3 => '5,000 km²']],
                ],
            ],
        ];
    }
}

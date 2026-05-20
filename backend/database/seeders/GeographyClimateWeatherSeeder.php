<?php

namespace Database\Seeders;

use App\Models\Option;
use App\Models\Question;
use App\Models\Quiz;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;

/**
 * "Iqlim va ob-havo" — geografiya testi (10 savol), mobil statistika va mavzular bilan mos.
 */
class GeographyClimateWeatherSeeder extends Seeder
{
    use SeedsTranslatableByLanguageCode;

    public function run(): void
    {
        $byCode = $this->languageIdsByCode();

        $quiz = Quiz::query()->updateOrCreate(
            [
                'category' => 'iqlim_obhavo',
                'type' => 'geography',
            ],
            [
                'lesson_id' => null,
                'is_active' => true,
                'title_uz' => 'Iqlim va ob-havo',
                'title_ru' => 'Климат и погода',
                'title_en' => 'Climate and weather',
                'sort_order' => 30,
            ]
        );

        $quiz->questions()->delete();

        $bank = $this->questionBank();

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
    private function questionBank(): array
    {
        return [
            [
                'translations' => [
                    1 => ['text' => 'O‘zbekistondagi o‘rtacha yillik harorat qanday hisoblanadi?'],
                    2 => ['text' => 'Какой среднегодовой температуры в Узбекистане?'],
                    3 => ['text' => 'What is the approximate average annual temperature in Uzbekistan?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '+8°C', 2 => '+8°C', 3 => '+8°C']],
                    ['is_correct' => true, 'translations' => [1 => '+14°C', 2 => '+14°C', 3 => '+14°C']],
                    ['is_correct' => false, 'translations' => [1 => '+22°C', 2 => '+22°C', 3 => '+22°C']],
                    ['is_correct' => false, 'translations' => [1 => '0°C', 2 => '0°C', 3 => '0°C']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Eng yuqori harorat +45°C qaysi shahar yon-atrofida kuzatilgan?'],
                    2 => ['text' => 'Где зафиксирован максимум +45°C?'],
                    3 => ['text' => 'Where was the record high of +45°C registered?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Samarqand', 2 => 'Самарканд', 3 => 'Samarkand']],
                    ['is_correct' => true, 'translations' => [1 => 'Termiz', 2 => 'Термез', 3 => 'Termez']],
                    ['is_correct' => false, 'translations' => [1 => 'Nukus', 2 => 'Нукус', 3 => 'Nukus']],
                    ['is_correct' => false, 'translations' => [1 => 'Toshkent', 2 => 'Ташкент', 3 => 'Tashkent']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Eng sovuq harorat -30°C qayerda kuzatiladi (statistikada)?'],
                    2 => ['text' => 'Где в статистике минимум около -30°C?'],
                    3 => ['text' => 'Where is about -30°C (statistics) most typical?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Vodiy o‘lkanlarida', 2 => 'В долинах', 3 => 'In lowlands']],
                    ['is_correct' => true, 'translations' => [1 => 'Tog‘larda', 2 => 'В горах', 3 => 'In the mountains']],
                    ['is_correct' => false, 'translations' => [1 => 'Cho‘llarda', 2 => 'В пустыне', 3 => 'In deserts']],
                    ['is_correct' => false, 'translations' => [1 => 'Orol bo‘yida', 2 => 'У Арала', 3 => 'Near the Aral']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Yiliga o‘rtacha yog‘in miqdori (mm) qaysi oraliqda keltiriladi?'],
                    2 => ['text' => 'Среднегодовые осадки (мм) в каком диапазоне?'],
                    3 => ['text' => 'Annual precipitation (mm) falls in which range?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '20–50 mm/yil', 2 => '20–50 мм/год', 3 => '20–50 mm/year']],
                    ['is_correct' => true, 'translations' => [1 => '100–500 mm/yil', 2 => '100–500 мм/год', 3 => '100–500 mm/year']],
                    ['is_correct' => false, 'translations' => [1 => '2000+ mm/yil', 2 => '2000+ мм/год', 3 => '2000+ mm/year']],
                    ['is_correct' => false, 'translations' => [1 => '0 mm', 2 => '0 мм', 3 => '0 mm']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Yilda taxminan necha kun quyoshli (statistikadagi oraliq)?'],
                    2 => ['text' => 'Сколько солнечных дней в год (в диапазоне)?'],
                    3 => ['text' => 'How many sunny days per year (range)?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '50–80 kun', 2 => '50–80 дн.', 3 => '50–80 days']],
                    ['is_correct' => false, 'translations' => [1 => '100–150 kun', 2 => '100–150 дн.', 3 => '100–150 days']],
                    ['is_correct' => true, 'translations' => [1 => '260–300 kun', 2 => '260–300 дн.', 3 => '260–300 days']],
                    ['is_correct' => false, 'translations' => [1 => '400+ kun', 2 => '400+ дн.', 3 => '400+ days']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Iqlim zonalari bo‘yicha issiq, mo‘tadil, sovuq bo‘linish nimaga asoslanadi?'],
                    2 => ['text' => 'На чём строятся тёплые, умеренные, холодные пояса?'],
                    3 => ['text' => 'What are warm/temperate/cold climate belts mainly based on?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Faqat dengiz sathiga', 2 => 'Только на высоте уровня моря', 3 => 'Only sea level']],
                    ['is_correct' => true, 'translations' => [1 => 'Ekvatordan qutblarga masofa va kenglik', 2 => 'Расстояние от экватора (широта)', 3 => 'Latitude / distance from the equator']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat shamol', 2 => 'Только ветер', 3 => 'Wind only']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat vegetatsiya', 2 => 'Только растительность', 3 => 'Vegetation only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Global isish (global warming) qaysi muammoga bevosita bog‘liq?'],
                    2 => ['text' => 'С чем связано глобальное потепление?'],
                    3 => ['text' => 'Global warming is most directly linked to…'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => 'Gaz etuvchi qatlamlarning oshishi', 2 => 'Парниковых газов', 3 => 'Increased greenhouse gases']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat oy fazasi', 2 => 'Только фаза Луны', 3 => 'Moon phase only']],
                    ['is_correct' => false, 'translations' => [1 => 'Dengiz chuqurligi', 2 => 'Глубина моря', 3 => 'Ocean depth']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat yer silkinishi', 2 => 'Только землетрясения', 3 => 'Earthquakes only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Tornado va kuchli bo‘ron qanday sifatga kiradi?'],
                    2 => ['text' => 'Торнадо и сильный шторм — это…'],
                    3 => ['text' => 'A tornado and severe storm are best described as…'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Iqlim zonasi turi', 2 => 'Тип климатической зоны', 3 => 'A climate zone type']],
                    ['is_correct' => true, 'translations' => [1 => 'Xavfli ob-havo hodisasi', 2 => 'Опасное явление погоды', 3 => 'Dangerous weather events']],
                    ['is_correct' => false, 'translations' => [1 => 'Dengiz o‘qimi turi', 2 => 'Тип течения', 3 => 'Ocean current type']],
                    ['is_correct' => false, 'translations' => [1 => 'Mineral', 2 => 'Минерал', 3 => 'A mineral']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Ob-havoni uzoq muddatli prognoz (hafta va undan yuqori) qanday yondashuv bilan ishlanadi?'],
                    2 => ['text' => 'Как делают долгосрочный прогноз погоды?'],
                    3 => ['text' => 'How are medium/long-range weather forecasts made?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Faqat telefon kamerasi', 2 => 'Только камерой', 3 => 'Phone camera only']],
                    ['is_correct' => true, 'translations' => [1 => 'Meteorologik modellar va stansiyalar', 2 => 'Модели и метеостанции', 3 => 'Models and weather stations']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat barometr uyda', 2 => 'Дом. барометр', 3 => 'Home barometer only']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat qo‘lda', 2 => 'Вручную', 3 => 'By hand only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Shahar markazida harorat odatda atrof-muhitga nisbatan yuqorimi?'],
                    2 => ['text' => 'В центре города температура обычно выше, чем вокруг?'],
                    3 => ['text' => 'Is a city center usually warmer than the surroundings?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => 'Ha (issiq orol effekti)', 2 => 'Да (остров тепла)', 3 => 'Yes (heat island)']],
                    ['is_correct' => false, 'translations' => [1 => 'Yo‘q, har doim sovuqroq', 2 => 'Всегда холоднее', 3 => 'No, always colder']],
                    ['is_correct' => false, 'translations' => [1 => 'Harorat farqi bo‘lmaydi', 2 => 'Нет разницы', 3 => 'No difference']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat qishda yuqoriroq', 2 => 'Только зимой выше', 3 => 'Only higher in winter']],
                ],
            ],
        ];
    }
}

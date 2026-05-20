<?php

namespace Database\Seeders;

use App\Models\Option;
use App\Models\Question;
use App\Models\Quiz;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;

/**
 * "Siyosiy xarita" (geografiya) — 10 ta test savoli, mobililova skrinlari bilan mos.
 */
class GeographyPoliticalMapSeeder extends Seeder
{
    use SeedsTranslatableByLanguageCode;

    public function run(): void
    {
        $byCode = $this->languageIdsByCode();

        $quiz = Quiz::query()->updateOrCreate(
            [
                'category' => 'siyosiy_xarita',
                'type' => 'geography',
            ],
            [
                'lesson_id' => null,
                'is_active' => true,
                'title_uz' => 'Siyosiy xarita',
                'title_ru' => 'Политическая карта',
                'title_en' => 'Political map',
                'sort_order' => 0,
            ]
        );

        $quiz->questions()->delete();

        $bank = $this->politicalMapQuestionBank();

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
     * Massivda 1, 2, 3 — uz, ru, en slotlari (SeedsTranslatableByLanguageCode).
     *
     * @return list<array{points?: int, translations: array<int, array{text: string}>, options: list<array{is_correct: bool, translations: array<int, string>}>}>
     */
    private function politicalMapQuestionBank(): array
    {
        return [
            [
                'translations' => [
                    1 => ['text' => 'O‘zbekiston qaysi davlatlar bilan chegaradosh?'],
                    2 => ['text' => 'С какими государствами граничит Узбекистан?'],
                    3 => ['text' => 'Which countries border Uzbekistan?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [
                        1 => 'Qozog‘iston, Qirg‘iziston, Tojikiston, Turkmaniston, Afg‘oniston',
                        2 => 'Казахстан, Кыргызстан, Таджикистан, Туркменистан, Афганистан',
                        3 => 'Kazakhstan, Kyrgyzstan, Tajikistan, Turkmenistan, Afghanistan',
                    ]],
                    ['is_correct' => false, 'translations' => [
                        1 => 'Rossiya, Xitoy, Qozog‘iston',
                        2 => 'Россия, Китай, Казахстан',
                        3 => 'Russia, China, Kazakhstan',
                    ]],
                    ['is_correct' => false, 'translations' => [
                        1 => 'Eron, Pokiston, Turkmaniston',
                        2 => 'Иран, Пакистан, Туркменистан',
                        3 => 'Iran, Pakistan, Turkmenistan',
                    ]],
                    ['is_correct' => false, 'translations' => [
                        1 => 'Tojikiston, Qirg‘iziston, Xitoy',
                        2 => 'Таджикистан, Кыргызстан, Китай',
                        3 => 'Tajikistan, Kyrgyzstan, China',
                    ]],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Dunyo okeaniga chiqa olmaydigan, lekin dunyo okeaniga chiqish uchun kamida ikkita davlat chegarasini kesib o‘tishi kerak bo‘lgan davlatlar (double landlocked) qaysi?'],
                    2 => ['text' => 'Какие страны — двойственно «сухопутные» (до Мирового океана минимум через две границы)?'],
                    3 => ['text' => 'Which are the two doubly landlocked countries (no ocean access, must cross at least two borders to reach the ocean)?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [
                        1 => 'O‘zbekiston va Lixtenshteyn',
                        2 => 'Узбекистан и Лихтенштейн',
                        3 => 'Uzbekistan and Liechtenstein',
                    ]],
                    ['is_correct' => false, 'translations' => [
                        1 => 'Shveytsariya va Avstriya',
                        2 => 'Швейцария и Австрия',
                        3 => 'Switzerland and Austria',
                    ]],
                    ['is_correct' => false, 'translations' => [
                        1 => 'Qozog‘iston va Mongoliya',
                        2 => 'Казахстан и Монголия',
                        3 => 'Kazakhstan and Mongolia',
                    ]],
                    ['is_correct' => false, 'translations' => [
                        1 => 'Boliviya va Paragvay',
                        2 => 'Боливия и Парагвай',
                        3 => 'Bolivia and Paraguay',
                    ]],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Eng katta maydonga ega davlat qaysi?'],
                    2 => ['text' => 'Какая страна имеет наибольшую площадь?'],
                    3 => ['text' => 'Which country has the largest area?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Xitoy', 2 => 'Китай', 3 => 'China']],
                    ['is_correct' => false, 'translations' => [1 => 'AQSh', 2 => 'США', 3 => 'USA']],
                    ['is_correct' => false, 'translations' => [1 => 'Kanada', 2 => 'Канада', 3 => 'Canada']],
                    ['is_correct' => true, 'translations' => [1 => 'Rossiya', 2 => 'Россия', 3 => 'Russia']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Yevropa va Osiyo qit‘asida joylashgan davlatlar qaysilar?'],
                    2 => ['text' => 'Какие из стран расположены и в Европе, и в Азии?'],
                    3 => ['text' => 'Which countries lie in both Europe and Asia?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [
                        1 => 'Turkiya, Rossiya, Qozog‘iston',
                        2 => 'Турция, Россия, Казахстан',
                        3 => 'Turkey, Russia, Kazakhstan',
                    ]],
                    ['is_correct' => false, 'translations' => [1 => 'Misr, Saudiya Arabistoni', 2 => 'Египет, Саудовская Аравия', 3 => 'Egypt, Saudi Arabia']],
                    ['is_correct' => false, 'translations' => [1 => 'Germaniya, Fransiya', 2 => 'Германия, Франция', 3 => 'Germany, France']],
                    ['is_correct' => false, 'translations' => [1 => 'Xitoy, Hindiston', 2 => 'Китай, Индия', 3 => 'China, India']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'O‘zbekiston maydoni qancha?'],
                    2 => ['text' => 'Какова площадь Узбекистана?'],
                    3 => ['text' => 'What is the area of Uzbekistan?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => '448,9 ming km²', 2 => '448,9 тыс. км²', 3 => '448.9 thousand km²']],
                    ['is_correct' => false, 'translations' => [1 => '447,4 ming km²', 2 => '447,4 тыс. км²', 3 => '447.4 thousand km²']],
                    ['is_correct' => false, 'translations' => [1 => '500 ming km²', 2 => '500 тыс. км²', 3 => '500 thousand km²']],
                    ['is_correct' => false, 'translations' => [1 => '200 ming km²', 2 => '200 тыс. км²', 3 => '200 thousand km²']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Qaysi davlat «Quyosh chiqar mamlakat» deb ataladi?'],
                    2 => ['text' => 'Какая страна называется «страной восходящего солнца»?'],
                    3 => ['text' => 'Which country is called the “land of the rising sun”?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Xitoy', 2 => 'Китай', 3 => 'China']],
                    ['is_correct' => false, 'translations' => [1 => 'Koreya', 2 => 'Корея', 3 => 'Korea']],
                    ['is_correct' => true, 'translations' => [1 => 'Yaponiya', 2 => 'Япония', 3 => 'Japan']],
                    ['is_correct' => false, 'translations' => [1 => 'Vyetnam', 2 => 'Вьетнам', 3 => 'Vietnam']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Janubiy Amerikadagi eng katta davlat qaysi?'],
                    2 => ['text' => 'Какая самая большая страна в Южной Америке?'],
                    3 => ['text' => 'Which is the largest country in South America?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Argentina', 2 => 'Аргентина', 3 => 'Argentina']],
                    ['is_correct' => true, 'translations' => [1 => 'Braziliya', 2 => 'Бразилия', 3 => 'Brazil']],
                    ['is_correct' => false, 'translations' => [1 => 'Peru', 2 => 'Перу', 3 => 'Peru']],
                    ['is_correct' => false, 'translations' => [1 => 'Kolumbiya', 2 => 'Колумбия', 3 => 'Colombia']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Afrikadagi eng ko‘p aholiga ega qaysi davlat?'],
                    2 => ['text' => 'Какая страна в Африке самая населённая?'],
                    3 => ['text' => 'Which African country has the largest population?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Misr', 2 => 'Египет', 3 => 'Egypt']],
                    ['is_correct' => false, 'translations' => [1 => 'JAR', 2 => 'ЮАР', 3 => 'South Africa']],
                    ['is_correct' => true, 'translations' => [1 => 'Nigeriya', 2 => 'Нигерия', 3 => 'Nigeria']],
                    ['is_correct' => false, 'translations' => [1 => 'Efiopiya', 2 => 'Эфиопия', 3 => 'Ethiopia']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Qaysi davlat eng uzun qirg‘oq chizig‘iga ega?'],
                    2 => ['text' => 'У какой страны самая длинная береговая линия?'],
                    3 => ['text' => 'Which country has the longest coastline?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Rossiya', 2 => 'Россия', 3 => 'Russia']],
                    ['is_correct' => false, 'translations' => [1 => 'Avstraliya', 2 => 'Австралия', 3 => 'Australia']],
                    ['is_correct' => true, 'translations' => [1 => 'Kanada', 2 => 'Канада', 3 => 'Canada']],
                    ['is_correct' => false, 'translations' => [1 => 'Indoneziya', 2 => 'Индонезия', 3 => 'Indonesia']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Vatikan qaysi shahar ichida joylashgan?'],
                    2 => ['text' => 'В каком городе расположен Ватикан?'],
                    3 => ['text' => 'In which city is the Vatican located?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Neapol', 2 => 'Неаполь', 3 => 'Naples']],
                    ['is_correct' => true, 'translations' => [1 => 'Rim', 2 => 'Рим', 3 => 'Rome']],
                    ['is_correct' => false, 'translations' => [1 => 'Milan', 2 => 'Милан', 3 => 'Milan']],
                    ['is_correct' => false, 'translations' => [1 => 'Florensiya', 2 => 'Флоренция', 3 => 'Florence']],
                ],
            ],
        ];
    }
}

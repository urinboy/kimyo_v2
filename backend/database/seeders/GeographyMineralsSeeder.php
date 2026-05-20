<?php

namespace Database\Seeders;

use App\Models\Option;
use App\Models\Question;
use App\Models\Quiz;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;

class GeographyMineralsSeeder extends Seeder
{
    use SeedsTranslatableByLanguageCode;

    public function run(): void
    {
        $byCode = $this->languageIdsByCode();

        $quiz = Quiz::query()->updateOrCreate(
            [
                'category' => 'foydali_qazilmalar',
                'type' => 'geography',
            ],
            [
                'lesson_id' => null,
                'is_active' => true,
                'title_uz' => 'Foydali qazilmalar',
                'title_ru' => 'Полезные ископаемые',
                'title_en' => 'Mineral resources',
                'sort_order' => 50,
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
                    1 => ['text' => "Materiallar bo'yicha O'zbekistonda nechta turdagi foydali qazilma o'rganilgan (taxmin son)?"],
                    2 => ['text' => 'Сколько видов полезных ископаемых (порядок) по курсу?'],
                    3 => ['text' => 'Order of registered mineral types in Uzbekistan (approx.)?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "10 dan ortiq", 2 => '10+', 3 => '10+']],
                    ['is_correct' => true, 'translations' => [1 => '100+ tur', 2 => '100+ видов', 3 => '100+ types']],
                    ['is_correct' => false, 'translations' => [1 => '15 ta aniq', 2 => '15', 3 => 'Exactly 15']],
                    ['is_correct' => false, 'translations' => [1 => "5 ta guruh", 2 => '5 групп', 3 => '5 groups']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Mamlakatda (material) taxminan nechta kon va konchilik maydonlari ro'yxatga olingan?"],
                    2 => ['text' => 'Сколько рудных полей/месторождений (по курсу)?'],
                    3 => ['text' => 'Approx. how many mining sites in the data?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '100+', 2 => '100+', 3 => '100+']],
                    ['is_correct' => true, 'translations' => [1 => '2,000+', 2 => '2 000+', 3 => '2,000+']],
                    ['is_correct' => false, 'translations' => [1 => '10,000+', 2 => '10 000+', 3 => '10,000+']],
                    ['is_correct' => false, 'translations' => [1 => '200 ta', 2 => '200', 3 => '200']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Jahon bo'yicha oltin qazib olish hajmida O'zbekiston taxminan nechanchi o'rinda (material)?"],
                    2 => ['text' => 'Место по добыче золота (как в курсе)?'],
                    3 => ['text' => "Uzbekistan's world rank in gold output?"],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "1-o'rin", 2 => '1-е', 3 => '1st']],
                    ['is_correct' => true, 'translations' => [1 => "4-o'rin", 2 => '4-е', 3 => '4th']],
                    ['is_correct' => false, 'translations' => [1 => "7-o'rin", 2 => '7-е', 3 => '7th']],
                    ['is_correct' => false, 'translations' => [1 => "10-o'rin", 2 => '10-е', 3 => '10th']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Jahon bo'yicha uran resurslariga ko'ra O'zbekiston taxminan nechanchi o'rinda (material)?"],
                    2 => ['text' => 'Место по урану (как в курсе)?'],
                    3 => ['text' => "Uzbekistan's world rank in uranium?"],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "4-o'rin", 2 => '4-е', 3 => '4th']],
                    ['is_correct' => false, 'translations' => [1 => "5-o'rin", 2 => '5-е', 3 => '5th']],
                    ['is_correct' => true, 'translations' => [1 => "7-o'rin", 2 => '7-е', 3 => '7th']],
                    ['is_correct' => false, 'translations' => [1 => "1-o'rin", 2 => '1-е', 3 => '1st']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Mis qanday tasnif bo'yicha keltirilgan (material)?"],
                    2 => ['text' => 'Как в материале классифицируется медь?'],
                    3 => ['text' => 'How is copper classified in the data?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Energiya resursi', 2 => 'Энергоресурс', 3 => 'Energy resource']],
                    ['is_correct' => true, 'translations' => [1 => 'Rangli metall', 2 => 'Цветной металл', 3 => 'Non-ferrous metal']],
                    ['is_correct' => false, 'translations' => [1 => "Qimmatbaho metall", 2 => 'Драгмет', 3 => 'Precious metal']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat qurilish', 2 => 'Нерудка', 3 => 'Non-metallics only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Tabiiy gaz va neft dars matnida qanday sifatda ko'rsatilgan?"],
                    2 => ['text' => 'Как в материале называют газ и нефть?'],
                    3 => ['text' => 'How are natural gas and oil described in the text?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Rangli metall', 2 => 'Цветной', 3 => 'Non-ferrous']],
                    ['is_correct' => true, 'translations' => [1 => 'Energiya resursi', 2 => 'Энергетический ресурс', 3 => 'Energy resource']],
                    ['is_correct' => false, 'translations' => [1 => 'Radioaktiv', 2 => 'Радиоактивный', 3 => 'Radioactive']],
                    ['is_correct' => false, 'translations' => [1 => 'Qurilish', 2 => 'Нерудка', 3 => 'Non-metallics']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Ko'mir matnda qanday tasnif?"],
                    2 => ['text' => 'Как классифицируется уголь?'],
                    3 => ['text' => 'Coal is classified in the data as:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Energiya resursi', 2 => 'Энергоресурс', 3 => 'Energy']],
                    ['is_correct' => true, 'translations' => [1 => "Qattiq yoqilg'i", 2 => 'Твёрдое топливо', 3 => 'Solid fuel']],
                    ['is_correct' => false, 'translations' => [1 => 'Rangli metall', 2 => 'Цветной', 3 => 'Non-ferrous']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat tuz", 2 => 'Только соль', 3 => 'Salt only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Uran (material) qanday?'],
                    2 => ['text' => 'Как в материале уран?'],
                    3 => ['text' => 'Uranium in the list is:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Energiya resursi', 2 => 'Энергоресурс', 3 => 'Energy']],
                    ['is_correct' => true, 'translations' => [1 => 'Radioaktiv metall', 2 => 'Радиоактивный металл', 3 => 'Radioactive metal']],
                    ['is_correct' => false, 'translations' => [1 => 'Nometall', 2 => 'Неруд', 3 => 'Non-metallics']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat qimmatbaho", 2 => 'Драгмет', 3 => 'Precious only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Statistika qatorida keltirilgan asosiy eksportlarni belgilang."],
                    2 => ['text' => 'Какие основные экспорты в статистике?'],
                    3 => ['text' => 'Key exports in the stat box:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Faqat neft", 2 => 'Только нефть', 3 => 'Oil only']],
                    ['is_correct' => true, 'translations' => [1 => "Oltin, mis, gaz", 2 => 'Золото, медь, газ', 3 => 'Gold, copper, gas']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat ko'mir", 2 => 'Только уголь', 3 => 'Coal only']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat uran', 2 => 'Только уран', 3 => 'Uranium only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Qurilish materiallari dars matnida qanday tasnif?"],
                    2 => ['text' => 'Как в тексте к стройматериалам?'],
                    3 => ['text' => 'Construction materials category in the text:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Energiya resursi', 2 => 'Энергоресурс', 3 => 'Energy']],
                    ['is_correct' => true, 'translations' => [1 => "Nometallar (nometal)", 2 => 'Неметаллы (неруд)', 3 => 'Non-metallics (nonmetals)']],
                    ['is_correct' => false, 'translations' => [1 => "Qimmatbaho metall", 2 => 'Драгмет', 3 => 'Precious']],
                    ['is_correct' => false, 'translations' => [1 => 'Radioaktiv', 2 => 'Радиоактивный', 3 => 'Radioactive']],
                ],
            ],
        ];
    }
}

<?php

namespace Database\Seeders;

use App\Models\Option;
use App\Models\Question;
use App\Models\Quiz;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;

class GeographyReliefSeeder extends Seeder
{
    use SeedsTranslatableByLanguageCode;

    public function run(): void
    {
        $byCode = $this->languageIdsByCode();

        $quiz = Quiz::query()->updateOrCreate(
            [
                'category' => 'relyef_turlari',
                'type' => 'geography',
            ],
            [
                'lesson_id' => null,
                'is_active' => true,
                'title_uz' => "Relyef turlari",
                'title_ru' => 'Виды рельефа',
                'title_en' => 'Relief types',
                'sort_order' => 60,
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
                    1 => ['text' => "Statistikaga ko'ra, O'zbekistondagi eng baland nuqta?"],
                    2 => ['text' => 'Самая высокая точка?'],
                    3 => ['text' => 'The highest point in the stats:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Kopetdog' (1,500 m)", 2 => 'Копетдаг (1 500 м)', 3 => 'Kopet Dag (1,500 m)']],
                    ['is_correct' => true, 'translations' => [1 => 'Adelunga (4,301 m)', 2 => 'Адельунга (4 301 м)', 3 => 'Adelunga (4,301 m)']],
                    ['is_correct' => false, 'translations' => [1 => 'Nurota (2,169 m)', 2 => 'Нурата (2 169 м)', 3 => 'Nurata (2,169 m)']],
                    ['is_correct' => false, 'translations' => [1 => 'Orol (0 m)', 2 => 'Аральское (0 м)', 3 => 'Aral (0 m)']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Eng past nuqta (Orol dengizi sathiga nisbatan)?"],
                    2 => ['text' => 'Самая низкая отметка?'],
                    3 => ['text' => 'The lowest point is about:'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => '-28 m', 2 => '−28 м', 3 => '−28 m']],
                    ['is_correct' => false, 'translations' => [1 => '0 m', 2 => '0 м', 3 => '0 m']],
                    ['is_correct' => false, 'translations' => [1 => '-100 m', 2 => '−100 м', 3 => '−100 m']],
                    ['is_correct' => false, 'translations' => [1 => '+200 m', 2 => '+200 м', 3 => '+200 m']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "O'rtacha mamlakat bo'yicha balandlik?"],
                    2 => ['text' => 'Средняя высота?'],
                    3 => ['text' => 'Mean elevation:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '~200 m', 2 => '~200 м', 3 => '~200 m']],
                    ['is_correct' => true, 'translations' => [1 => '~600 m', 2 => '~600 м', 3 => '~600 m']],
                    ['is_correct' => false, 'translations' => [1 => '~1,200 m', 2 => '~1 200 м', 3 => '~1,200 m']],
                    ['is_correct' => false, 'translations' => [1 => '~2,000 m', 2 => '~2 000 м', 3 => '~2,000 m']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Tog'li hududlar mamlakatning taxminan qancha qismini oladi?"],
                    2 => ['text' => 'Долью занимают горы?'],
                    3 => ['text' => 'Mountains cover roughly:'],
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
                    1 => ['text' => "Tekisliklar mamlakatning taxminan necha foizini egallaydi?"],
                    2 => ['text' => 'Доля равнин?'],
                    3 => ['text' => 'Plains cover roughly:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '~20%', 2 => '~20%', 3 => '~20%']],
                    ['is_correct' => false, 'translations' => [1 => '~50%', 2 => '~50%', 3 => '~50%']],
                    ['is_correct' => true, 'translations' => [1 => '~80%', 2 => '~80%', 3 => '~80%']],
                    ['is_correct' => false, 'translations' => [1 => '~100%', 2 => '~100%', 3 => '~100%']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Farg'ona vodiysi qaysi relyef?"],
                    2 => ['text' => 'Тип — Ферганская долина?'],
                    3 => ['text' => 'Fergana Valley is mainly:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Cho'l (qum)", 2 => 'Песчаная пустыня', 3 => 'Desert dune']],
                    ['is_correct' => true, 'translations' => [1 => "Berk tog' oralig'idagi vodiy", 2 => 'Междугорная долина', 3 => 'Intramontane valley']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat plato', 2 => 'Только плоскогорье', 3 => 'Only plateau']],
                    ['is_correct' => false, 'translations' => [1 => 'Orol tubi', 2 => 'Дно Арала', 3 => 'Aral floor']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "Qizilqum qaysi relyef?"],
                    2 => ['text' => 'Кызылкум — рельеф?'],
                    3 => ['text' => 'Kyzylkum is:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Faqat tog' yonbag'ri", 2 => 'Склоны', 3 => 'Slopes only']],
                    ['is_correct' => true, 'translations' => [1 => "Cho'l relyefi", 2 => 'Пустыня', 3 => 'Desert relief']],
                    ['is_correct' => false, 'translations' => [1 => 'Muzlik', 2 => 'Ледник', 3 => 'Glacier']],
                    ['is_correct' => false, 'translations' => [1 => 'Daryo vodiysi (tor)', 2 => 'Пойма', 3 => 'Narrow river valley']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Ustyurt qanday relyef?'],
                    2 => ['text' => 'Устюрт — это?'],
                    3 => ['text' => 'Ustyurt is usually:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Cho'l vodiysi", 2 => 'Пустынная низменность', 3 => 'Desert lowland']],
                    ['is_correct' => true, 'translations' => [1 => 'Keng yassik (plato)', 2 => 'Плато', 3 => 'High plain / plateau']],
                    ['is_correct' => false, 'translations' => [1 => 'Dengiz tubi', 2 => 'Дно', 3 => 'Ocean floor']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat cho'kma", 2 => 'Впадина', 3 => 'Depression only']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => 'Amudaryo va Sirdaryo poymalar qaysi bandga kiritiladi?'],
                    2 => ['text' => 'Пойма Амударьи и Сырдарьи — в категорию:'],
                    3 => ['text' => 'Floodplains in Amu/Syr belong to:'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => "Daryo vodiysidagi relyef", 2 => 'Рельеф речных долин', 3 => 'Relief in river valleys']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat muzlik', 2 => 'Ледники', 3 => 'Glaciers']],
                    ['is_correct' => false, 'translations' => [1 => "Faqat cho'l", 2 => 'Пустыня', 3 => 'Desert only']],
                    ['is_correct' => false, 'translations' => [1 => "Dengiz cho'kmasi", 2 => 'Морское дно', 3 => 'Abyssal ocean']],
                ],
            ],
            [
                'translations' => [
                    1 => ['text' => "O'zbekiston relyefi (material) qanday?"],
                    2 => ['text' => 'Как в материале описывается рельеф?'],
                    3 => ['text' => 'The material stresses:'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => "Mamlakatda faqat tog' bor", 2 => 'Только горы', 3 => 'Only mountains']],
                    ['is_correct' => true, 'translations' => [1 => "Relyef xilma-xil, cho'l va tekisliklar uyg'un", 2 => 'Разнообразен', 3 => 'Diverse: plains and deserts']],
                    ['is_correct' => false, 'translations' => [1 => 'Faqat muz', 2 => 'Только лёд', 3 => 'Only ice']],
                    ['is_correct' => false, 'translations' => [1 => "Dengiz qirg'og'i", 2 => 'Морской бераг', 3 => 'Sea coast only']],
                ],
            ],
        ];
    }
}

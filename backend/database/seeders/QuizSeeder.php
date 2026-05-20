<?php

namespace Database\Seeders;

use App\Models\Quiz;
use App\Models\Question;
use App\Models\Option;
use App\Models\QuestionTranslation;
use App\Models\OptionTranslation;
use Database\Seeders\Concerns\ForeignKeyGuard;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class QuizSeeder extends Seeder
{
    use ForeignKeyGuard;
    use SeedsTranslatableByLanguageCode;

    private const SLUGS = ['elements', 'periodic_table'];

    public function run(): void
    {
        $this->withoutForeignKeys(function () {
            $quizIds = DB::table('quizzes')->whereIn('category', self::SLUGS)->pluck('id');
            if ($quizIds->isNotEmpty()) {
                $qIds      = DB::table('questions')->whereIn('quiz_id', $quizIds)->pluck('id');
                $optionIds = $qIds->isNotEmpty()
                    ? DB::table('options')->whereIn('question_id', $qIds)->pluck('id')
                    : collect();

                if ($optionIds->isNotEmpty()) {
                    DB::table('option_translations')->whereIn('option_id', $optionIds->toArray())->delete();
                    DB::table('options')->whereIn('question_id', $qIds->toArray())->delete();
                }
                if ($qIds->isNotEmpty()) {
                    DB::table('question_translations')->whereIn('question_id', $qIds->toArray())->delete();
                    DB::table('questions')->whereIn('quiz_id', $quizIds->toArray())->delete();
                }
                DB::table('quizzes')->whereIn('category', self::SLUGS)->delete();
            }
        });

        $byCode = $this->languageIdsByCode();

        $elementsQuiz = Quiz::create([
            'category'   => 'elements',
            'type'       => 'chemistry',
            'title_uz'   => 'Kimyoviy elementlar',
            'title_ru'   => 'Химические элементы',
            'title_en'   => 'Chemical elements',
            'sort_order' => 0,
            'is_active'  => true,
        ]);

        $periodicQuiz = Quiz::create([
            'category'   => 'periodic_table',
            'type'       => 'chemistry',
            'title_uz'   => 'Davriy jadval',
            'title_ru'   => 'Периодическая таблица',
            'title_en'   => 'Periodic table',
            'sort_order' => 10,
            'is_active'  => true,
        ]);

        $elementQuestions = [
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Vodorodning kimyoviy belgisi qaysi?'],
                    2 => ['text' => 'Каков химический символ водорода?'],
                    3 => ['text' => 'What is the chemical symbol for hydrogen?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => 'H', 2 => 'H', 3 => 'H']],
                    ['is_correct' => false, 'translations' => [1 => 'He', 2 => 'He', 3 => 'He']],
                    ['is_correct' => false, 'translations' => [1 => 'O', 2 => 'O', 3 => 'O']],
                    ['is_correct' => false, 'translations' => [1 => 'N', 2 => 'N', 3 => 'N']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Qaysi element \'O\' harfi bilan belgilanadi?'],
                    2 => ['text' => 'Какой элемент обозначается буквой «О»?'],
                    3 => ['text' => 'Which element is denoted by the letter \'O\'?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Oltin', 2 => 'Золото', 3 => 'Gold']],
                    ['is_correct' => false, 'translations' => [1 => 'Oltingugurt', 2 => 'Сера', 3 => 'Sulfur']],
                    ['is_correct' => true, 'translations' => [1 => 'Kislorod', 2 => 'Кислород', 3 => 'Oxygen']],
                    ['is_correct' => false, 'translations' => [1 => 'Osmiy', 2 => 'Осмий', 3 => 'Osmium']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Eng yengil element qaysi?'],
                    2 => ['text' => 'Какой самый легкий элемент?'],
                    3 => ['text' => 'Which is the lightest element?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Litiy', 2 => 'Литий', 3 => 'Lithium']],
                    ['is_correct' => false, 'translations' => [1 => 'Geliy', 2 => 'Гелий', 3 => 'Helium']],
                    ['is_correct' => true, 'translations' => [1 => 'Vodorod', 2 => 'Водород', 3 => 'Hydrogen']],
                    ['is_correct' => false, 'translations' => [1 => 'Bor', 2 => 'Бор', 3 => 'Boron']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Oltinning kimyoviy belgisi nima?'],
                    2 => ['text' => 'Каков химический символ золота?'],
                    3 => ['text' => 'What is the chemical symbol for gold?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Ag', 2 => 'Ag', 3 => 'Ag']],
                    ['is_correct' => true, 'translations' => [1 => 'Au', 2 => 'Au', 3 => 'Au']],
                    ['is_correct' => false, 'translations' => [1 => 'Al', 2 => 'Al', 3 => 'Al']],
                    ['is_correct' => false, 'translations' => [1 => 'Ar', 2 => 'Ar', 3 => 'Ar']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Temirning lotincha nomi nima?'],
                    2 => ['text' => 'Как называется железо по-латыни?'],
                    3 => ['text' => 'What is the Latin name for iron?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => 'Ferrum', 2 => 'Ferrum', 3 => 'Ferrum']],
                    ['is_correct' => false, 'translations' => [1 => 'Cuprum', 2 => 'Cuprum', 3 => 'Cuprum']],
                    ['is_correct' => false, 'translations' => [1 => 'Argentum', 2 => 'Argentum', 3 => 'Argentum']],
                    ['is_correct' => false, 'translations' => [1 => 'Aurum', 2 => 'Aurum', 3 => 'Aurum']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Suyuq holatdagi metal qaysi?'],
                    2 => ['text' => 'Какой металл находится в жидком состоянии?'],
                    3 => ['text' => 'Which metal is in a liquid state?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Temir', 2 => 'Железо', 3 => 'Iron']],
                    ['is_correct' => true, 'translations' => [1 => 'Simob', 2 => 'Ртуть', 3 => 'Mercury']],
                    ['is_correct' => false, 'translations' => [1 => 'Natriy', 2 => 'Натрий', 3 => 'Sodium']],
                    ['is_correct' => false, 'translations' => [1 => 'Galliy', 2 => 'Галлий', 3 => 'Gallium']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Azotning belgisi qaysi?'],
                    2 => ['text' => 'Каков символ азота?'],
                    3 => ['text' => 'What is the symbol for nitrogen?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'A', 2 => 'A', 3 => 'A']],
                    ['is_correct' => false, 'translations' => [1 => 'Az', 2 => 'Az', 3 => 'Az']],
                    ['is_correct' => true, 'translations' => [1 => 'N', 2 => 'N', 3 => 'N']],
                    ['is_correct' => false, 'translations' => [1 => 'Ni', 2 => 'Ni', 3 => 'Ni']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Kaliying belgisi nima?'],
                    2 => ['text' => 'Каков символ калия?'],
                    3 => ['text' => 'What is the symbol for potassium?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Ka', 2 => 'Ka', 3 => 'Ka']],
                    ['is_correct' => false, 'translations' => [1 => 'Cl', 2 => 'Cl', 3 => 'Cl']],
                    ['is_correct' => true, 'translations' => [1 => 'K', 2 => 'K', 3 => 'K']],
                    ['is_correct' => false, 'translations' => [1 => 'Ca', 2 => 'Ca', 3 => 'Ca']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Natriy qaysi guruhga kiradi?'],
                    2 => ['text' => 'К какой группе относится натрий?'],
                    3 => ['text' => 'Which group does sodium belong to?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Inert gaz', 2 => 'Инертный газ', 3 => 'Noble gas']],
                    ['is_correct' => true, 'translations' => [1 => 'Ishqoriy metall', 2 => 'Щелочной металл', 3 => 'Alkali metal']],
                    ['is_correct' => false, 'translations' => [1 => 'Galogen', 2 => 'Галоген', 3 => 'Halogen']],
                    ['is_correct' => false, 'translations' => [1 => 'Nometall', 2 => 'Неметалл', 3 => 'Non-metal']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Olmos qaysi elementdan tashkil topgan?'],
                    2 => ['text' => 'Из какого элемента состоит алмаз?'],
                    3 => ['text' => 'Which element is diamond made of?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Kremniy', 2 => 'Кремний', 3 => 'Silicon']],
                    ['is_correct' => true, 'translations' => [1 => 'Uglerod', 2 => 'Углерод', 3 => 'Carbon']],
                    ['is_correct' => false, 'translations' => [1 => 'Bor', 2 => 'Бор', 3 => 'Boron']],
                    ['is_correct' => false, 'translations' => [1 => 'Ftor', 2 => 'Фтор', 3 => 'Fluorine']],
                ]
            ],
        ];

        $periodicQuestions = [
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Davriy jadvalda nechta guruh bor?'],
                    2 => ['text' => 'Сколько групп в периодической таблице?'],
                    3 => ['text' => 'How many groups are there in the periodic table?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => '8', 2 => '8', 3 => '8']],
                    ['is_correct' => false, 'translations' => [1 => '18', 2 => '18', 3 => '18']],
                    ['is_correct' => false, 'translations' => [1 => '10', 2 => '10', 3 => '10']],
                    ['is_correct' => false, 'translations' => [1 => '7', 2 => '7', 3 => '7']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Davriy jadval asoschisi kim?'],
                    2 => ['text' => 'Кто основатель периодической таблицы?'],
                    3 => ['text' => 'Who is the founder of the periodic table?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Nyuton', 2 => 'Ньютон', 3 => 'Newton']],
                    ['is_correct' => false, 'translations' => [1 => 'Eynshteyn', 2 => 'Эйнштейн', 3 => 'Einstein']],
                    ['is_correct' => true, 'translations' => [1 => 'Mendeleyev', 2 => 'Менделеев', 3 => 'Mendeleev']],
                    ['is_correct' => false, 'translations' => [1 => 'Bor', 2 => 'Бор', 3 => 'Bohr']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Eng faol nometall qaysi?'],
                    2 => ['text' => 'Какой самый активный неметалл?'],
                    3 => ['text' => 'Which is the most active non-metal?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Kislorod', 2 => 'Кислород', 3 => 'Oxygen']],
                    ['is_correct' => true, 'translations' => [1 => 'Ftor', 2 => 'Фтор', 3 => 'Fluorine']],
                    ['is_correct' => false, 'translations' => [1 => 'Xlor', 2 => 'Хлор', 3 => 'Chlorine']],
                    ['is_correct' => false, 'translations' => [1 => 'Azot', 2 => 'Азот', 3 => 'Nitrogen']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Inert gazlar qaysi guruhda joylashgan?'],
                    2 => ['text' => 'В какой группе находятся инертные газы?'],
                    3 => ['text' => 'In which group are noble gases located?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '1-guruh', 2 => '1-я группа', 3 => 'Group 1']],
                    ['is_correct' => false, 'translations' => [1 => '17-guruh', 2 => '17-я группа', 3 => 'Group 17']],
                    ['is_correct' => false, 'translations' => [1 => '18-guruh', 2 => '18-я группа', 3 => 'Group 18']],
                    ['is_correct' => true, 'translations' => [1 => '8-guruh', 2 => '8-я группа', 3 => 'Group 8']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Ishqoriy metallar qaysi guruhda?'],
                    2 => ['text' => 'В какой группе находятся щелочные металлы?'],
                    3 => ['text' => 'In which group are alkali metals?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => '1-guruh', 2 => '1-я группа', 3 => 'Group 1']],
                    ['is_correct' => false, 'translations' => [1 => '2-guruh', 2 => '2-я группа', 3 => 'Group 2']],
                    ['is_correct' => false, 'translations' => [1 => '3-guruh', 2 => '3-я группа', 3 => 'Group 3']],
                    ['is_correct' => false, 'translations' => [1 => '18-guruh', 2 => '18-я группа', 3 => 'Group 18']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Lantanidlar qayerda joylashgan?'],
                    2 => ['text' => 'Где находятся лантаноиды?'],
                    3 => ['text' => 'Where are lanthanides located?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Jadval tepasida', 2 => 'Вверху таблицы', 3 => 'At the top of the table']],
                    ['is_correct' => false, 'translations' => [1 => 'Jadval o\'rtasida', 2 => 'В середине таблицы', 3 => 'In the middle of the table']],
                    ['is_correct' => true, 'translations' => [1 => 'Jadval pastida', 2 => 'Внизу таблицы', 3 => 'At the bottom of the table']],
                    ['is_correct' => false, 'translations' => [1 => 'Jadval o\'ngida', 2 => 'Справа в таблице', 3 => 'On the right in the table']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => '3-davr elementlari nechta?'],
                    2 => ['text' => 'Сколько элементов в 3-м периоде?'],
                    3 => ['text' => 'How many elements are in the 3rd period?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => '2', 2 => '2', 3 => '2']],
                    ['is_correct' => false, 'translations' => [1 => '8', 2 => '8', 3 => '8']],
                    ['is_correct' => true, 'translations' => [1 => '18', 2 => '18', 3 => '18']],
                    ['is_correct' => false, 'translations' => [1 => '32', 2 => '32', 3 => '32']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Galogenlar qaysi elementlar?'],
                    2 => ['text' => 'Какие элементы являются галогенами?'],
                    3 => ['text' => 'Which elements are halogens?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => 'F, Cl, Br, I', 2 => 'F, Cl, Br, I', 3 => 'F, Cl, Br, I']],
                    ['is_correct' => false, 'translations' => [1 => 'Li, Na, K, Rb', 2 => 'Li, Na, K, Rb', 3 => 'Li, Na, K, Rb']],
                    ['is_correct' => false, 'translations' => [1 => 'He, Ne, Ar, Kr', 2 => 'He, Ne, Ar, Kr', 3 => 'He, Ne, Ar, Kr']],
                    ['is_correct' => false, 'translations' => [1 => 'B, C, N, O', 2 => 'B, C, N, O', 3 => 'B, C, N, O']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Atom raqami 1 bo\'lgan element?'],
                    2 => ['text' => 'Элемент с атомным номером 1?'],
                    3 => ['text' => 'Element with atomic number 1?'],
                ],
                'options' => [
                    ['is_correct' => false, 'translations' => [1 => 'Geliy', 2 => 'Гелий', 3 => 'Helium']],
                    ['is_correct' => true, 'translations' => [1 => 'Vodorod', 2 => 'Водород', 3 => 'Hydrogen']],
                    ['is_correct' => false, 'translations' => [1 => 'Litiy', 2 => 'Литий', 3 => 'Lithium']],
                    ['is_correct' => false, 'translations' => [1 => 'Berilliy', 2 => 'Бериллий', 3 => 'Beryllium']],
                ]
            ],
            [
                'points' => 1,
                'translations' => [
                    1 => ['text' => 'Atom massasi eng katta tabiiy element?'],
                    2 => ['text' => 'Какой природный элемент имеет наибольшую атомную массу?'],
                    3 => ['text' => 'Which natural element has the largest atomic mass?'],
                ],
                'options' => [
                    ['is_correct' => true, 'translations' => [1 => 'Uran', 2 => 'Уран', 3 => 'Uranium']],
                    ['is_correct' => false, 'translations' => [1 => 'Osmiy', 2 => 'Осмий', 3 => 'Osmium']],
                    ['is_correct' => false, 'translations' => [1 => 'Qo\'rg\'oshin', 2 => 'Свинец', 3 => 'Lead']],
                    ['is_correct' => false, 'translations' => [1 => 'Oltin', 2 => 'Золото', 3 => 'Gold']],
                ]
            ],
        ];

        // Seed Element Questions
        foreach ($elementQuestions as $qIndex => $q) {
            $question = Question::create([
                'quiz_id' => $elementsQuiz->id,
                'order' => $qIndex + 1,
                'points' => $q['points'],
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

        // Seed Periodic Table Questions
        foreach ($periodicQuestions as $qIndex => $q) {
            $question = Question::create([
                'quiz_id' => $periodicQuiz->id,
                'order' => $qIndex + 1,
                'points' => $q['points'],
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
}

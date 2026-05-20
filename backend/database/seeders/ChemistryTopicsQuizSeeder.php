<?php

namespace Database\Seeders;

use App\Models\Quiz;
use App\Models\Question;
use App\Models\Option;
use Database\Seeders\Concerns\ForeignKeyGuard;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * 6 ta kimyo mavzusi bo'yicha testlar:
 *  1. Soda ishlab chiqarish          (7 savol)
 *  2. Natriy va kaliy birikmalari    (7 savol)
 *  3. Ishqoriy metallar              (8 savol)
 *  4. Kalsiy va magniy               (8 savol)
 *  5. Temir                          (6 savol)
 *  6. Suvning qattiqligi             (8 savol)
 *
 * Har safar ishga tushirilganda faqat shu 6 ta kategoriya uchun
 * mavjud quizlar o'chirib, yangilari yaratiladi.
 */
class ChemistryTopicsQuizSeeder extends Seeder
{
    use ForeignKeyGuard;
    use SeedsTranslatableByLanguageCode;

    private const SLUGS = [
        'soda_production',
        'sodium_potassium',
        'alkali_metals',
        'calcium_magnesium',
        'iron',
        'water_hardness',
    ];

    public function run(): void
    {
        $this->withoutForeignKeys(function () {
            // Remove only quizzes belonging to these categories
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
        $now    = now();

        foreach ($this->quizData() as $i => $quizDef) {
            // --- Quiz ---
            $quizId = DB::table('quizzes')->insertGetId([
                'category'   => $quizDef['category'],
                'type'       => 'chemistry',
                'title_uz'   => $quizDef['title_uz'],
                'title_ru'   => $quizDef['title_ru'],
                'title_en'   => $quizDef['title_en'],
                'is_active'  => true,
                'sort_order' => ($i + 3) * 10,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            $qTransRows = [];
            $oTransRows = [];

            foreach ($quizDef['questions'] as $qIdx => $q) {
                // --- Question ---
                $questionId = DB::table('questions')->insertGetId([
                    'quiz_id'    => $quizId,
                    'order'      => $qIdx + 1,
                    'points'     => $q['points'] ?? 1,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);

                // Question translations (uz, ru, en, kaa)
                $slotMap = [1 => 'uz', 2 => 'ru', 3 => 'en'];
                foreach ($slotMap as $slot => $code) {
                    if (isset($q['translations'][$slot], $byCode[$code])) {
                        $qTransRows[] = [
                            'question_id' => $questionId,
                            'language_id' => $byCode[$code],
                            'text'        => $q['translations'][$slot]['text'],
                            'created_at'  => $now,
                            'updated_at'  => $now,
                        ];
                    }
                }
                // kaa = copy of uz
                if (isset($byCode['kaa'], $q['translations'][1])) {
                    $qTransRows[] = [
                        'question_id' => $questionId,
                        'language_id' => $byCode['kaa'],
                        'text'        => $q['translations'][1]['text'],
                        'created_at'  => $now,
                        'updated_at'  => $now,
                    ];
                }

                foreach ($q['options'] as $o) {
                    $optionId = DB::table('options')->insertGetId([
                        'question_id' => $questionId,
                        'is_correct'  => $o['is_correct'] ? 1 : 0,
                        'created_at'  => $now,
                        'updated_at'  => $now,
                    ]);

                    foreach ($slotMap as $slot => $code) {
                        if (isset($o['translations'][$slot], $byCode[$code])) {
                            $oTransRows[] = [
                                'option_id'   => $optionId,
                                'language_id' => $byCode[$code],
                                'text'        => (string) $o['translations'][$slot],
                                'created_at'  => $now,
                                'updated_at'  => $now,
                            ];
                        }
                    }
                    if (isset($byCode['kaa'], $o['translations'][1])) {
                        $oTransRows[] = [
                            'option_id'   => $optionId,
                            'language_id' => $byCode['kaa'],
                            'text'        => (string) $o['translations'][1],
                            'created_at'  => $now,
                            'updated_at'  => $now,
                        ];
                    }
                }
            }

            // Bulk insert translations
            if ($qTransRows) {
                DB::table('question_translations')->insert($qTransRows);
            }
            if ($oTransRows) {
                DB::table('option_translations')->insert($oTransRows);
            }
        }
    }

    // -------------------------------------------------------------------------
    // All quiz + question + option data
    // -------------------------------------------------------------------------

    private function quizData(): array
    {
        return [

            // =================================================================
            // 1. SODA ISHLAB CHIQARISH
            // =================================================================
            [
                'category' => 'soda_production',
                'title_uz' => 'Soda ishlab chiqarish',
                'title_ru' => 'Производство соды',
                'title_en' => 'Soda production',
                'questions' => [
                    [
                        'translations' => [
                            1 => ['text' => 'Soda kimyoviy jihatdan qanday modda?'],
                            2 => ['text' => 'Что такое сода с химической точки зрения?'],
                            3 => ['text' => 'What is soda from a chemical point of view?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'NaCl',     2 => 'NaCl',     3 => 'NaCl']],
                            ['is_correct' => false, 'translations' => [1 => 'Na₂SO₄',   2 => 'Na₂SO₄',   3 => 'Na₂SO₄']],
                            ['is_correct' => true,  'translations' => [1 => 'Na₂CO₃',   2 => 'Na₂CO₃',   3 => 'Na₂CO₃']],
                            ['is_correct' => false, 'translations' => [1 => 'NaHCO₃',   2 => 'NaHCO₃',   3 => 'NaHCO₃']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Soda ishlab chiqarishda asosan qaysi xomashyo ishlatiladi?'],
                            2 => ['text' => 'Какое сырьё в основном используется при производстве соды?'],
                            3 => ['text' => 'What raw material is mainly used in soda production?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Kaliy xlorid',          2 => 'Хлорид калия',            3 => 'Potassium chloride']],
                            ['is_correct' => true,  'translations' => [1 => 'Ohaktosh va osh tuzi',   2 => 'Известняк и поваренная соль', 3 => 'Limestone and table salt']],
                            ['is_correct' => false, 'translations' => [1 => 'Temir ruda',             2 => 'Железная руда',           3 => 'Iron ore']],
                            ['is_correct' => false, 'translations' => [1 => "Ko'mir va mis",          2 => 'Уголь и медь',            3 => 'Coal and copper']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Qo'ng'irot soda zavodida soda ishlab chiqarish usuli bu —"],
                            2 => ['text' => 'Метод производства соды на Кунградском содовом заводе —'],
                            3 => ['text' => 'The soda production method at the Kungrad Soda Plant is —'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Solvay usuli',      2 => 'Метод Сольве',       3 => 'Solvay process']],
                            ['is_correct' => false, 'translations' => [1 => 'Elektroliz usuli',  2 => 'Электролиз',         3 => 'Electrolysis']],
                            ['is_correct' => false, 'translations' => [1 => 'Distillatsiya',     2 => 'Дистилляция',        3 => 'Distillation']],
                            ['is_correct' => false, 'translations' => [1 => 'Fraksiyalash',      2 => 'Фракционирование',   3 => 'Fractional distillation']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Solvay usulida soda olish uchun qanday gaz ishlatiladi?'],
                            2 => ['text' => 'Какой газ используется для получения соды методом Сольве?'],
                            3 => ['text' => 'What gas is used to obtain soda by the Solvay process?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Vodorod',           2 => 'Водород',            3 => 'Hydrogen']],
                            ['is_correct' => false, 'translations' => [1 => 'Azot',               2 => 'Азот',               3 => 'Nitrogen']],
                            ['is_correct' => true,  'translations' => [1 => 'Karbonat angidrid',  2 => 'Углекислый газ (CO₂)', 3 => 'Carbon dioxide (CO₂)']],
                            ['is_correct' => false, 'translations' => [1 => "Kislota bug'i",      2 => 'Пары кислоты',       3 => 'Acid vapour']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Soda ishlab chiqarishdagi asosiy reaksiya natijasida qanday mahsulotlar hosil bo'ladi?"],
                            2 => ['text' => 'Какие продукты получаются в результате основной реакции при производстве соды?'],
                            3 => ['text' => 'What products are formed in the main reaction of soda production?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'NaCl va H₂O',       2 => 'NaCl и H₂O',         3 => 'NaCl and H₂O']],
                            ['is_correct' => true,  'translations' => [1 => 'Na₂CO₃ va CaCl₂',   2 => 'Na₂CO₃ и CaCl₂',    3 => 'Na₂CO₃ and CaCl₂']],
                            ['is_correct' => false, 'translations' => [1 => 'HCl va NaOH',        2 => 'HCl и NaOH',         3 => 'HCl and NaOH']],
                            ['is_correct' => false, 'translations' => [1 => 'Na₂SO₄ va CO₂',      2 => 'Na₂SO₄ и CO₂',      3 => 'Na₂SO₄ and CO₂']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Quyidagilardan qaysi biri soda (Na₂CO₃)ning qo'llanilish sohasi emas?"],
                            2 => ['text' => 'Что из следующего НЕ является областью применения соды (Na₂CO₃)?'],
                            3 => ['text' => 'Which of the following is NOT an application of soda (Na₂CO₃)?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Shisha ishlab chiqarish',  2 => 'Производство стекла',      3 => 'Glass production']],
                            ['is_correct' => false, 'translations' => [1 => "Qog'oz sanoati",           2 => 'Бумажная промышленность',  3 => 'Paper industry']],
                            ['is_correct' => false, 'translations' => [1 => 'Tozalash vositalari',      2 => 'Чистящие средства',        3 => 'Cleaning agents']],
                            ['is_correct' => true,  'translations' => [1 => "O'g'it sifatida dalalarda", 2 => 'В качестве удобрения в полях', 3 => 'As fertilizer in fields']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Soda ishlab chiqarishda hosil bo'ladigan yon mahsulot bu —"],
                            2 => ['text' => 'Побочный продукт при производстве соды —'],
                            3 => ['text' => 'The by-product in soda production is —'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Kaliy nitrat',             2 => 'Нитрат калия',            3 => 'Potassium nitrate']],
                            ['is_correct' => true,  'translations' => [1 => 'Kaltsiy xlorid (CaCl₂)',   2 => 'Хлорид кальция (CaCl₂)', 3 => 'Calcium chloride (CaCl₂)']],
                            ['is_correct' => false, 'translations' => [1 => 'Suyuq ammiak',             2 => 'Жидкий аммиак',           3 => 'Liquid ammonia']],
                            ['is_correct' => false, 'translations' => [1 => 'Temir oksidi',             2 => 'Оксид железа',            3 => 'Iron oxide']],
                        ],
                    ],
                ],
            ],

            // =================================================================
            // 2. NATRIY VA KALIYNING XOSSALARI VA ENG MUHIM BIRIKMALARI
            // =================================================================
            [
                'category' => 'sodium_potassium',
                'title_uz' => 'Natriy va kaliyning xossalari va eng muhim birikmalari',
                'title_ru' => 'Свойства натрия и калия и их важнейшие соединения',
                'title_en' => 'Properties of sodium and potassium and their key compounds',
                'questions' => [
                    [
                        'translations' => [
                            1 => ['text' => 'NaHCO₃ qanday nomlanadi?'],
                            2 => ['text' => 'Как называется NaHCO₃?'],
                            3 => ['text' => 'What is NaHCO₃ called?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Natriy karbonat',                    2 => 'Карбонат натрия',              3 => 'Sodium carbonate']],
                            ['is_correct' => true,  'translations' => [1 => 'Natriy bikarbonat (osh sodasi)',      2 => 'Бикарбонат натрия (питьевая сода)', 3 => 'Sodium bicarbonate (baking soda)']],
                            ['is_correct' => false, 'translations' => [1 => 'Natriy sulfat',                      2 => 'Сульфат натрия',               3 => 'Sodium sulfate']],
                            ['is_correct' => false, 'translations' => [1 => 'Natriy fosfat',                      2 => 'Фосфат натрия',                3 => 'Sodium phosphate']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Qoraqalpog'istonda Qo'ng'irot soda zavodidan asosan qanday mahsulot olinadi?"],
                            2 => ['text' => 'Какой основной продукт получают на Кунградском содовом заводе в Каракалпакстане?'],
                            3 => ['text' => 'What is the main product of the Kungrad Soda Plant in Karakalpakstan?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Natriy karbonat',               2 => 'Карбонат натрия',              3 => 'Sodium carbonate']],
                            ['is_correct' => false, 'translations' => [1 => 'Natriy bikarbonat (osh sodasi)', 2 => 'Бикарбонат натрия (питьевая сода)', 3 => 'Sodium bicarbonate (baking soda)']],
                            ['is_correct' => false, 'translations' => [1 => 'Natriy sulfat',                  2 => 'Сульфат натрия',               3 => 'Sodium sulfate']],
                            ['is_correct' => false, 'translations' => [1 => 'Natriy fosfat',                  2 => 'Фосфат натрия',                3 => 'Sodium phosphate']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Quyidagi moddalarning qaysi biri ishqoriy metallarning oksidlari hisoblanadi?'],
                            2 => ['text' => 'Какое из следующих веществ является оксидом щелочного металла?'],
                            3 => ['text' => 'Which of the following substances is an oxide of an alkali metal?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Na₂O',    2 => 'Na₂O',    3 => 'Na₂O']],
                            ['is_correct' => false, 'translations' => [1 => 'NaCl',    2 => 'NaCl',    3 => 'NaCl']],
                            ['is_correct' => false, 'translations' => [1 => 'NaOH',    2 => 'NaOH',    3 => 'NaOH']],
                            ['is_correct' => false, 'translations' => [1 => 'Na₂SO₄',  2 => 'Na₂SO₄',  3 => 'Na₂SO₄']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Natriy metali kislorod bilan reaktsiyasi natijasida hosil bo'ladigan mahsulot?"],
                            2 => ['text' => 'Продукт реакции металлического натрия с кислородом?'],
                            3 => ['text' => 'What is the product of the reaction of sodium metal with oxygen?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Na₂O',    2 => 'Na₂O',    3 => 'Na₂O']],
                            ['is_correct' => false, 'translations' => [1 => 'NaOH',    2 => 'NaOH',    3 => 'NaOH']],
                            ['is_correct' => false, 'translations' => [1 => 'NaCl',    2 => 'NaCl',    3 => 'NaCl']],
                            ['is_correct' => false, 'translations' => [1 => 'Na₂CO₃',  2 => 'Na₂CO₃',  3 => 'Na₂CO₃']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Kaliy metalining suv bilan reaktsiyasi natijasida qanday gaz hosil bo'ladi?"],
                            2 => ['text' => 'Какой газ выделяется при реакции металлического калия с водой?'],
                            3 => ['text' => 'What gas is produced when potassium metal reacts with water?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Karbonat angidrid',  2 => 'Углекислый газ',  3 => 'Carbon dioxide']],
                            ['is_correct' => false, 'translations' => [1 => 'Kislorod',            2 => 'Кислород',        3 => 'Oxygen']],
                            ['is_correct' => false, 'translations' => [1 => 'Azot',                2 => 'Азот',            3 => 'Nitrogen']],
                            ['is_correct' => true,  'translations' => [1 => 'Vodorod',             2 => 'Водород',         3 => 'Hydrogen']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Aralbo'yi hududida sho'rlanish kuchayishi qaysi metall tuzlari miqdorining ortishiga olib keladi?"],
                            2 => ['text' => 'К увеличению каких металлических солей приводит засоление территории Приаралья?'],
                            3 => ['text' => 'Salinization in the Aral Sea region leads to an increase in which metal salts?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Temir tuzlari',  2 => 'Соли железа',   3 => 'Iron salts']],
                            ['is_correct' => true,  'translations' => [1 => 'Natriy tuzlari', 2 => 'Соли натрия',   3 => 'Sodium salts']],
                            ['is_correct' => false, 'translations' => [1 => 'Mis tuzlari',    2 => 'Соли меди',     3 => 'Copper salts']],
                            ['is_correct' => false, 'translations' => [1 => 'Rux tuzlari',    2 => 'Соли цинка',    3 => 'Zinc salts']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Qoraqalpog'istonda topiladigan qum (SiO₂)dan olinadigan shisha ishlab chiqarishda qaysi metall birikmasi \"oqim beruvchi\" sifatida qo'shiladi?"],
                            2 => ['text' => 'Какое металлическое соединение добавляется как «флюс» при производстве стекла из песка (SiO₂) Каракалпакстана?'],
                            3 => ['text' => 'Which metal compound is added as a "flux" in glass production from sand (SiO₂) found in Karakalpakstan?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Na₂CO₃ (soda)', 2 => 'Na₂CO₃ (сода)', 3 => 'Na₂CO₃ (soda)']],
                            ['is_correct' => false, 'translations' => [1 => 'FeSO₄',          2 => 'FeSO₄',          3 => 'FeSO₄']],
                            ['is_correct' => false, 'translations' => [1 => 'CuO',             2 => 'CuO',             3 => 'CuO']],
                            ['is_correct' => false, 'translations' => [1 => 'Al₂O₃',           2 => 'Al₂O₃',           3 => 'Al₂O₃']],
                        ],
                    ],
                ],
            ],

            // =================================================================
            // 3. ISHQORIY METALLAR
            // =================================================================
            [
                'category' => 'alkali_metals',
                'title_uz' => 'Ishqoriy metallar',
                'title_ru' => 'Щелочные металлы',
                'title_en' => 'Alkali metals',
                'questions' => [
                    [
                        'translations' => [
                            1 => ['text' => "Kaliy tuzlarining dunyodagi eng kata zaxiralari qayerda joylashgan?"],
                            2 => ['text' => 'Где находятся крупнейшие в мире запасы солей калия?'],
                            3 => ['text' => "Where are the world's largest reserves of potassium salts located?"],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Uralda',       2 => 'На Урале',    3 => 'In the Urals']],
                            ['is_correct' => true,  'translations' => [1 => 'Belarussiyada', 2 => 'В Беларуси',  3 => 'In Belarus']],
                            ['is_correct' => false, 'translations' => [1 => 'Misrda',        2 => 'В Египте',    3 => 'In Egypt']],
                            ['is_correct' => false, 'translations' => [1 => 'Rossiyada',     2 => 'В России',    3 => 'In Russia']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Natriy metali yer qobig'ida tarqalishi bo'yicha nechinchi o'rinda turadi?"],
                            2 => ['text' => 'Какое место занимает натрий по распространённости в земной коре?'],
                            3 => ['text' => 'What rank does sodium hold in terms of abundance in the Earth\'s crust?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => '6', 2 => '6', 3 => '6']],
                            ['is_correct' => false, 'translations' => [1 => '5', 2 => '5', 3 => '5']],
                            ['is_correct' => false, 'translations' => [1 => '4', 2 => '4', 3 => '4']],
                            ['is_correct' => false, 'translations' => [1 => '3', 2 => '3', 3 => '3']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Suyuq sabin olishda va asosli akkumlyator tayyorlashda quyidagilarning qaysi biridan foydalaniladi?"],
                            2 => ['text' => 'Что используется при получении жидкого мыла и приготовлении щелочных аккумуляторов?'],
                            3 => ['text' => 'Which of the following is used in making liquid soap and preparing alkaline batteries?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Kaliy',    2 => 'Калий',    3 => 'Potassium']],
                            ['is_correct' => false, 'translations' => [1 => 'Natriy',   2 => 'Натрий',   3 => 'Sodium']],
                            ['is_correct' => false, 'translations' => [1 => 'Litiy',    2 => 'Литий',    3 => 'Lithium']],
                            ['is_correct' => false, 'translations' => [1 => 'Rubidiy',  2 => 'Рубидий',  3 => 'Rubidium']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Kaustik sodaning formulasi qanday?'],
                            2 => ['text' => 'Какова формула каустической соды?'],
                            3 => ['text' => 'What is the formula for caustic soda?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'NaOH',     2 => 'NaOH',     3 => 'NaOH']],
                            ['is_correct' => false, 'translations' => [1 => 'KOH',      2 => 'KOH',      3 => 'KOH']],
                            ['is_correct' => false, 'translations' => [1 => 'LiOH',     2 => 'LiOH',     3 => 'LiOH']],
                            ['is_correct' => false, 'translations' => [1 => 'Be(OH)₂',  2 => 'Be(OH)₂',  3 => 'Be(OH)₂']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Qoraqalpog'istonda uchraydigan osh tuzi (NaCl) qaysi metallning sanoati uchun muhim manba bo'la oladi?"],
                            2 => ['text' => 'Поваренная соль (NaCl) Каракалпакстана является важным источником для промышленности какого металла?'],
                            3 => ['text' => 'Table salt (NaCl) found in Karakalpakstan can be an important source for which metal\'s industry?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Kaliy',      2 => 'Калий',      3 => 'Potassium']],
                            ['is_correct' => true,  'translations' => [1 => 'Natriy',     2 => 'Натрий',     3 => 'Sodium']],
                            ['is_correct' => false, 'translations' => [1 => 'Kalsiy',     2 => 'Кальций',    3 => 'Calcium']],
                            ['is_correct' => false, 'translations' => [1 => 'Alyuminiy',  2 => 'Алюминий',   3 => 'Aluminium']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Osh tuzidan elektroliz orqali qaysi metall olinadi?'],
                            2 => ['text' => 'Какой металл получают из поваренной соли методом электролиза?'],
                            3 => ['text' => 'Which metal is obtained from table salt by electrolysis?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Kaliy',   2 => 'Калий',    3 => 'Potassium']],
                            ['is_correct' => false, 'translations' => [1 => 'Litiy',   2 => 'Литий',    3 => 'Lithium']],
                            ['is_correct' => true,  'translations' => [1 => 'Natriy',  2 => 'Натрий',   3 => 'Sodium']],
                            ['is_correct' => false, 'translations' => [1 => 'Magniy',  2 => 'Магний',   3 => 'Magnesium']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Aralbo'yi hududidagi sho'r tuproqlarda ko'p uchraydigan tuzlar qaysi metall ionlariga boy?"],
                            2 => ['text' => 'Какими ионами металлов богаты соли, часто встречающиеся в засолённых почвах Приаралья?'],
                            3 => ['text' => 'The salts commonly found in saline soils of the Aral Sea region are rich in which metal ions?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Na⁺ va K⁺',   2 => 'Na⁺ и K⁺',    3 => 'Na⁺ and K⁺']],
                            ['is_correct' => false, 'translations' => [1 => 'Fe²⁺ va Cu²⁺', 2 => 'Fe²⁺ и Cu²⁺', 3 => 'Fe²⁺ and Cu²⁺']],
                            ['is_correct' => false, 'translations' => [1 => 'Al³⁺ va Zn²⁺', 2 => 'Al³⁺ и Zn²⁺', 3 => 'Al³⁺ and Zn²⁺']],
                            ['is_correct' => false, 'translations' => [1 => 'Ag⁺ va Au³⁺',  2 => 'Ag⁺ и Au³⁺',  3 => 'Ag⁺ and Au³⁺']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Maishiy shisha (oyna) tarkibida odatda qaysi metall oksidi bo\'ladi?'],
                            2 => ['text' => 'Какие оксиды металлов обычно входят в состав оконного стекла?'],
                            3 => ['text' => 'Which metal oxides are usually present in household (window) glass?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'CaO',          2 => 'CaO',           3 => 'CaO']],
                            ['is_correct' => false, 'translations' => [1 => 'Na₂O',         2 => 'Na₂O',          3 => 'Na₂O']],
                            ['is_correct' => true,  'translations' => [1 => 'CaO va Na₂O',  2 => 'CaO и Na₂O',   3 => 'CaO and Na₂O']],
                            ['is_correct' => false, 'translations' => [1 => 'BeO',           2 => 'BeO',           3 => 'BeO']],
                        ],
                    ],
                ],
            ],

            // =================================================================
            // 4. KALSIY VA MAGNIY
            // =================================================================
            [
                'category' => 'calcium_magnesium',
                'title_uz' => 'Kalsiy va magniy',
                'title_ru' => 'Кальций и магний',
                'title_en' => 'Calcium and magnesium',
                'questions' => [
                    [
                        'translations' => [
                            1 => ['text' => "Qoraqalpog'istonda qurilish g'ishtlari ishlab chiqarishda rang beruvchi qo'shimcha sifatida ko'pincha qaysi metall birikmalari ta'sir ko'rsatadi?"],
                            2 => ['text' => 'Какие соединения металлов обычно выступают красящими добавками при производстве строительного кирпича в Каракалпакстане?'],
                            3 => ['text' => 'Which metal compounds usually act as colouring additives in construction brick production in Karakalpakstan?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Temir oksidlari',   2 => 'Оксиды железа',   3 => 'Iron oxides']],
                            ['is_correct' => false, 'translations' => [1 => 'Kumush oksidlari',  2 => 'Оксиды серебра',  3 => 'Silver oxides']],
                            ['is_correct' => false, 'translations' => [1 => 'Oltin oksidlari',   2 => 'Оксиды золота',   3 => 'Gold oxides']],
                            ['is_correct' => false, 'translations' => [1 => 'Natriy xlorid',     2 => 'Хлорид натрия',   3 => 'Sodium chloride']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Qoraqalpog'istondagi tabiiy ohaktoshdan olingan CaO suv bilan reaksiyaga kirishsa qaysi mahsulot hosil bo'ladi?"],
                            2 => ['text' => 'Какой продукт получается, если CaO из природного известняка Каракалпакстана вступает в реакцию с водой?'],
                            3 => ['text' => 'What product is formed when CaO obtained from natural limestone of Karakalpakstan reacts with water?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'CaCl₂',    2 => 'CaCl₂',    3 => 'CaCl₂']],
                            ['is_correct' => true,  'translations' => [1 => 'Ca(OH)₂',  2 => 'Ca(OH)₂',  3 => 'Ca(OH)₂']],
                            ['is_correct' => false, 'translations' => [1 => 'CaSO₄',    2 => 'CaSO₄',    3 => 'CaSO₄']],
                            ['is_correct' => false, 'translations' => [1 => 'CaCO₃',    2 => 'CaCO₃',    3 => 'CaCO₃']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Qoraqalpog'istonda qurilishda keng ishlatiladigan ohaktosh qaysi metall birikmasiga kiradi?"],
                            2 => ['text' => 'Известняк, широко используемый в строительстве Каракалпакстана, является соединением какого металла?'],
                            3 => ['text' => 'Limestone widely used in construction in Karakalpakstan belongs to which metal compound?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Natriy birikmasi',  2 => 'Соединение натрия',   3 => 'Sodium compound']],
                            ['is_correct' => true,  'translations' => [1 => 'Kalsiy birikmasi',  2 => 'Соединение кальция',  3 => 'Calcium compound']],
                            ['is_correct' => false, 'translations' => [1 => 'Kaliy birikmasi',   2 => 'Соединение калия',    3 => 'Potassium compound']],
                            ['is_correct' => false, 'translations' => [1 => 'Magniy birikmasi',  2 => 'Соединение магния',   3 => 'Magnesium compound']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Ohaktoshdan ohak (CaO) olishda qaysi jarayon amalga oshadi?'],
                            2 => ['text' => 'Какой процесс происходит при получении извести (CaO) из известняка?'],
                            3 => ['text' => 'What process occurs when lime (CaO) is produced from limestone?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Eritish',              2 => 'Растворение',             3 => 'Dissolution']],
                            ['is_correct' => false, 'translations' => [1 => 'Oksidlanish',          2 => 'Окисление',               3 => 'Oxidation']],
                            ['is_correct' => true,  'translations' => [1 => 'Termik parchalanish',  2 => 'Термическое разложение',  3 => 'Thermal decomposition']],
                            ['is_correct' => false, 'translations' => [1 => 'Neytrallanish',        2 => 'Нейтрализация',           3 => 'Neutralisation']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Ohak bilan suvoq qilingan devor vaqt o'tib yana mustahkamlanadi. Sababi:"],
                            2 => ['text' => 'Стена, оштукатуренная известью, со временем снова укрепляется. Причина:'],
                            3 => ['text' => 'A wall plastered with lime hardens again over time. The reason is:'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Ca(OH)₂ havodagi CO₂ bilan CaCO₃ ga aylanadi', 2 => 'Ca(OH)₂ превращается в CaCO₃ под действием CO₂ воздуха', 3 => 'Ca(OH)₂ reacts with CO₂ in air to form CaCO₃']],
                            ['is_correct' => false, 'translations' => [1 => 'Fe₂O₃ hosil bo\'ladi',  2 => 'Образуется Fe₂O₃',    3 => 'Fe₂O₃ is formed']],
                            ['is_correct' => false, 'translations' => [1 => 'Suv bug\'lanadi',        2 => 'Вода испаряется',      3 => 'Water evaporates']],
                            ['is_correct' => false, 'translations' => [1 => 'NaCl to\'planadi',       2 => 'Накапливается NaCl',   3 => 'NaCl accumulates']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Choynak devorida oq \"qotma\" (nakip) tez paydo bo'lsa, suvda qaysi ionlar ko'p?"],
                            2 => ['text' => 'Если на стенках чайника быстро появляется белый «налёт» (накипь), каких ионов много в воде?'],
                            3 => ['text' => 'If white scale forms quickly on kettle walls, which ions are abundant in the water?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Na⁺',            2 => 'Na⁺',             3 => 'Na⁺']],
                            ['is_correct' => true,  'translations' => [1 => 'Ca²⁺ va Mg²⁺',   2 => 'Ca²⁺ и Mg²⁺',    3 => 'Ca²⁺ and Mg²⁺']],
                            ['is_correct' => false, 'translations' => [1 => 'Fe³⁺',            2 => 'Fe³⁺',            3 => 'Fe³⁺']],
                            ['is_correct' => false, 'translations' => [1 => 'Cl⁻',             2 => 'Cl⁻',             3 => 'Cl⁻']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Aralbo'yi hududida sho'rlangan suvda sovun yomon ko'piklanadi. Bunga asosiy sabab?"],
                            2 => ['text' => 'В солёной воде Приаралья мыло плохо пенится. Основная причина?'],
                            3 => ['text' => 'Soap lathers poorly in the saline water of the Aral Sea region. The main reason?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Na⁺ ionlari',          2 => 'Ионы Na⁺',            3 => 'Na⁺ ions']],
                            ['is_correct' => true,  'translations' => [1 => 'Ca²⁺ va Mg²⁺ ko\'pligi', 2 => 'Избыток Ca²⁺ и Mg²⁺', 3 => 'Excess Ca²⁺ and Mg²⁺']],
                            ['is_correct' => false, 'translations' => [1 => 'Harorat pastligi',      2 => 'Низкая температура',   3 => 'Low temperature']],
                            ['is_correct' => false, 'translations' => [1 => 'CO₂ ko\'pligi',          2 => 'Избыток CO₂',          3 => 'Excess CO₂']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Ca va Mg organizm uchun foydali, ammo qattiq suv nimasi bilan noqulay?'],
                            2 => ['text' => 'Ca и Mg полезны для организма, но чем неудобна жёсткая вода?'],
                            3 => ['text' => 'Ca and Mg are beneficial for the body, but what is the inconvenience of hard water?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => "Ta'mi yomonlashadi va maishiy texnika tez ishdan chiqadi", 2 => 'Ухудшается вкус и бытовая техника быстрее выходит из строя', 3 => 'Taste worsens and household appliances break down faster']],
                            ['is_correct' => false, 'translations' => [1 => "Suv rangli bo'lib qoladi",  2 => 'Вода становится цветной',   3 => 'Water becomes coloured']],
                            ['is_correct' => false, 'translations' => [1 => "Suv zaharli bo'lib qoladi", 2 => 'Вода становится ядовитой',  3 => 'Water becomes toxic']],
                            ['is_correct' => false, 'translations' => [1 => "Suv muzlamaydi",            2 => 'Вода не замерзает',          3 => "Water doesn't freeze"]],
                        ],
                    ],
                ],
            ],

            // =================================================================
            // 5. TEMIR
            // =================================================================
            [
                'category' => 'iron',
                'title_uz' => 'Temir',
                'title_ru' => 'Железо',
                'title_en' => 'Iron',
                'questions' => [
                    [
                        'translations' => [
                            1 => ['text' => 'Temir zanglashi (korroziya) tezlashishiga qaysi omil kuchliroq ta\'sir qiladi?'],
                            2 => ['text' => 'Какой фактор сильнее ускоряет ржавление (коррозию) железа?'],
                            3 => ['text' => 'Which factor has a stronger effect on accelerating iron corrosion?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Quruq havo',           2 => 'Сухой воздух',             3 => 'Dry air']],
                            ['is_correct' => true,  'translations' => [1 => 'Namlik va tuzli muhit', 2 => 'Влажность и солёная среда', 3 => 'Humidity and salty environment']],
                            ['is_correct' => false, 'translations' => [1 => 'Past harorat',          2 => 'Низкая температура',        3 => 'Low temperature']],
                            ['is_correct' => false, 'translations' => [1 => "Qorong'ulik",           2 => 'Темнота',                   3 => 'Darkness']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Qaysi metall oziq-ovqat qadoqlashda (folga) ko\'p ishlatiladi va yengil qotishmalar hosil qiladi?'],
                            2 => ['text' => 'Какой металл широко применяется в пищевой упаковке (фольга) и образует лёгкие сплавы?'],
                            3 => ['text' => 'Which metal is widely used in food packaging (foil) and forms lightweight alloys?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Mis',       2 => 'Медь',       3 => 'Copper']],
                            ['is_correct' => false, 'translations' => [1 => 'Temir',     2 => 'Железо',     3 => 'Iron']],
                            ['is_correct' => true,  'translations' => [1 => 'Alyuminiy', 2 => 'Алюминий',  3 => 'Aluminium']],
                            ['is_correct' => false, 'translations' => [1 => 'Rux',       2 => 'Цинк',       3 => 'Zinc']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Tebinbuloq koni Qoraqalpog'istonda qaysi metall rudasi bilan mashhur?"],
                            2 => ['text' => 'Каким рудным металлом известно месторождение Тебинбулак в Каракалпакстане?'],
                            3 => ['text' => 'The Tebinbulaq deposit in Karakalpakstan is known for the ore of which metal?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Mis (Cu)',       2 => 'Медь (Cu)',       3 => 'Copper (Cu)']],
                            ['is_correct' => true,  'translations' => [1 => 'Temir (Fe)',      2 => 'Железо (Fe)',     3 => 'Iron (Fe)']],
                            ['is_correct' => false, 'translations' => [1 => 'Oltin (Au)',      2 => 'Золото (Au)',     3 => 'Gold (Au)']],
                            ['is_correct' => false, 'translations' => [1 => 'Alyuminiy (Al)',  2 => 'Алюминий (Al)',  3 => 'Aluminium (Al)']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Tebinbuloq konidagi temir rudasining asosiy kimyoviy turi ko\'pincha qaysi oksidga to\'g\'ri keladi?'],
                            2 => ['text' => 'Какому оксиду соответствует основной химический тип железной руды месторождения Тебинбулак?'],
                            3 => ['text' => 'Which oxide corresponds to the main chemical type of iron ore at the Tebinbulaq deposit?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Fe₂O₃ (gematit)',  2 => 'Fe₂O₃ (гематит)',  3 => 'Fe₂O₃ (haematite)']],
                            ['is_correct' => false, 'translations' => [1 => 'FeS (pirit)',       2 => 'FeS (пирит)',       3 => 'FeS (pyrite)']],
                            ['is_correct' => false, 'translations' => [1 => 'FeCO₃ (siderit)',   2 => 'FeCO₃ (сидерит)',   3 => 'FeCO₃ (siderite)']],
                            ['is_correct' => false, 'translations' => [1 => 'FeCl₃',             2 => 'FeCl₃',             3 => 'FeCl₃']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Qaysi modda temirni zanglashdan eng samarali himoya qiladi?'],
                            2 => ['text' => 'Какое вещество наиболее эффективно защищает железо от ржавления?'],
                            3 => ['text' => 'What substance most effectively protects iron from rusting?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Tuz eritmasi',              2 => 'Солевой раствор',              3 => 'Salt solution']],
                            ['is_correct' => false, 'translations' => [1 => 'Suv',                       2 => 'Вода',                         3 => 'Water']],
                            ['is_correct' => true,  'translations' => [1 => "Bo'yoq/yog' bilan qoplash", 2 => 'Покрытие краской или маслом',  3 => 'Coating with paint or oil']],
                            ['is_correct' => false, 'translations' => [1 => 'Kislota',                   2 => 'Кислота',                      3 => 'Acid']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => 'Tebinbuloq temir rudasini qayta ishlash mantiqan qaysi iqtisodiy natijani beradi?'],
                            2 => ['text' => 'Какой экономический результат логически даёт переработка железной руды Тебинбулак?'],
                            3 => ['text' => 'What economic result does processing the Tebinbulaq iron ore logically yield?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Qurilish materiallari arzonlashadi',  2 => 'Строительные материалы дешевеют',     3 => 'Construction materials become cheaper']],
                            ['is_correct' => false, 'translations' => [1 => 'Zang tezlashadi',                    2 => 'Ржавление ускоряется',                3 => 'Rusting accelerates']],
                            ['is_correct' => false, 'translations' => [1 => 'Tuz miqdori oshadi',                 2 => 'Количество соли увеличивается',       3 => 'Salt content increases']],
                            ['is_correct' => false, 'translations' => [1 => "Suv sho'rlanishi kuchayadi",          2 => 'Засоление воды усиливается',          3 => 'Water salinization increases']],
                        ],
                    ],
                ],
            ],

            // =================================================================
            // 6. SUVNING QATTIQLIGI VA UNI YUMSHATISH USULLARI
            // =================================================================
            [
                'category' => 'water_hardness',
                'title_uz' => "Suvning qattiqligi va uni yumshatish usullari",
                'title_ru' => 'Жёсткость воды и методы её смягчения',
                'title_en' => 'Water hardness and softening methods',
                'questions' => [
                    [
                        'translations' => [
                            1 => ['text' => "Sho'r suvdan ichimlik suvini tozalashda metall idishlarning tez korroziyaga uchrashi qaysi xususiyat bilan bog'liq?"],
                            2 => ['text' => 'С какой свойством связана быстрая коррозия металлических сосудов при очистке питьевой воды из солёной воды?'],
                            3 => ['text' => 'What property is rapid corrosion of metal vessels associated with when purifying drinking water from salty water?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => "Tuzlarning elektr o'tkazuvchanligi", 2 => 'Электропроводность солей',  3 => 'Electrical conductivity of salts']],
                            ['is_correct' => false, 'translations' => [1 => 'Suvning rangsizligi',                2 => 'Бесцветность воды',         3 => 'Colourlessness of water']],
                            ['is_correct' => false, 'translations' => [1 => 'Havo bosimi',                        2 => 'Атмосферное давление',      3 => 'Atmospheric pressure']],
                            ['is_correct' => false, 'translations' => [1 => 'Quyosh nuri',                        2 => 'Солнечный свет',            3 => 'Sunlight']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Sulton Uvays tog'i atrofida uchraydigan ohaktosh qaysi modda?"],
                            2 => ['text' => 'Что представляет собой известняк, встречающийся вокруг горы Султан Увайс?'],
                            3 => ['text' => 'What substance is the limestone found around Sultan Uvays mountain?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Na₂CO₃', 2 => 'Na₂CO₃', 3 => 'Na₂CO₃']],
                            ['is_correct' => true,  'translations' => [1 => 'CaCO₃',  2 => 'CaCO₃',  3 => 'CaCO₃']],
                            ['is_correct' => false, 'translations' => [1 => 'CaSO₄',  2 => 'CaSO₄',  3 => 'CaSO₄']],
                            ['is_correct' => false, 'translations' => [1 => 'MgO',    2 => 'MgO',    3 => 'MgO']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Qattiq suvda sovun kam ko'piklanishining sababi nima?"],
                            2 => ['text' => 'Почему мыло плохо пенится в жёсткой воде?'],
                            3 => ['text' => 'Why does soap lather poorly in hard water?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => "Sovun bug'lanib ketishi",                                    2 => 'Испарение мыла',                                        3 => 'Soap evaporates']],
                            ['is_correct' => true,  'translations' => [1 => "Ca²⁺ va Mg²⁺ sovun bilan erimaydigan tuzlar hosil qiladi",   2 => 'Ca²⁺ и Mg²⁺ образуют нерастворимые соли с мылом',      3 => 'Ca²⁺ and Mg²⁺ form insoluble salts with soap']],
                            ['is_correct' => false, 'translations' => [1 => "Suv sovuq bo'lishi",                                         2 => 'Вода холодная',                                         3 => 'Water is cold']],
                            ['is_correct' => false, 'translations' => [1 => "Sovun sifatsiz bo'lishi",                                    2 => 'Мыло низкого качества',                                 3 => 'Poor-quality soap']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Qaynatilganda qattiqlik kamayishining kimyoviy sababi qaysi tenglama bilan ifodalanadi?"],
                            2 => ['text' => 'Каким уравнением описывается химическая причина снижения жёсткости при кипячении?'],
                            3 => ['text' => 'Which equation describes the chemical reason for reducing water hardness when boiling?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Ca(HCO₃)₂ → CaCO₃↓ + CO₂↑ + H₂O',  2 => 'Ca(HCO₃)₂ → CaCO₃↓ + CO₂↑ + H₂O',  3 => 'Ca(HCO₃)₂ → CaCO₃↓ + CO₂↑ + H₂O']],
                            ['is_correct' => false, 'translations' => [1 => 'NaCl → Na⁺ + Cl⁻',                  2 => 'NaCl → Na⁺ + Cl⁻',                  3 => 'NaCl → Na⁺ + Cl⁻']],
                            ['is_correct' => false, 'translations' => [1 => 'MgSO₄ → Mg²⁺ + SO₄²⁻',              2 => 'MgSO₄ → Mg²⁺ + SO₄²⁻',              3 => 'MgSO₄ → Mg²⁺ + SO₄²⁻']],
                            ['is_correct' => false, 'translations' => [1 => 'Fe₂O₃ + H₂O → zang',               2 => 'Fe₂O₃ + H₂O → ржавчина',            3 => 'Fe₂O₃ + H₂O → rust']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Qaysi manbadan kelgan suv odatda qattiqroq bo'ladi?"],
                            2 => ['text' => 'Вода из какого источника обычно более жёсткая?'],
                            3 => ['text' => 'Water from which source is usually harder?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => "Tog'li ohaktoshli hududdan oqib kelgan suv",  2 => 'Вода из горного известнякового района',  3 => 'Water flowing from a mountainous limestone area']],
                            ['is_correct' => false, 'translations' => [1 => "Yomg'ir suvi",                                2 => 'Дождевая вода',                           3 => 'Rainwater']],
                            ['is_correct' => false, 'translations' => [1 => 'Qor suvi',                                   2 => 'Талая вода',                              3 => 'Meltwater']],
                            ['is_correct' => false, 'translations' => [1 => 'Distillangan suv',                            2 => 'Дистиллированная вода',                   3 => 'Distilled water']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Ikki choynak bor: A – tog' etagidagi quduq suvi, B – yomg'ir suvi bilan to'ldirilgan. Qaysi birida tezroq nakip hosil bo'ladi?"],
                            2 => ['text' => 'Есть два чайника: А – наполнен колодезной водой у подножия горы, В – дождевой водой. В каком быстрее образуется накипь?'],
                            3 => ['text' => 'Two kettles: A – filled with well water from a mountain foot, B – with rainwater. In which does scale form faster?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'A choynak',                            2 => 'Чайник А',                              3 => 'Kettle A']],
                            ['is_correct' => false, 'translations' => [1 => 'B choynak',                            2 => 'Чайник В',                              3 => 'Kettle B']],
                            ['is_correct' => false, 'translations' => [1 => 'Ikkalasi bir xil',                     2 => 'Одинаково',                             3 => 'Both the same']],
                            ['is_correct' => false, 'translations' => [1 => "Hech qaysisida nakip hosil bo'lmaydi", 2 => 'Ни в одном накипь не образуется',       3 => 'No scale forms in either']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Doimiy qattiqlikni kamaytirishning maishiy usuli qaysi?"],
                            2 => ['text' => 'Какой бытовой метод снижения постоянной жёсткости воды?'],
                            3 => ['text' => 'What is the household method for reducing permanent water hardness?'],
                        ],
                        'options' => [
                            ['is_correct' => false, 'translations' => [1 => 'Qaynatish',                  2 => 'Кипячение',              3 => 'Boiling']],
                            ['is_correct' => false, 'translations' => [1 => 'Sovitish',                   2 => 'Охлаждение',             3 => 'Cooling']],
                            ['is_correct' => true,  'translations' => [1 => 'Soda (Na₂CO₃) qo\'shish',   2 => 'Добавление соды (Na₂CO₃)', 3 => 'Adding soda (Na₂CO₃)']],
                            ['is_correct' => false, 'translations' => [1 => 'Aralashtirish',              2 => 'Перемешивание',          3 => 'Stirring']],
                        ],
                    ],
                    [
                        'translations' => [
                            1 => ['text' => "Choynakda nakip ko'payishi qaysi metall asboblarning tezroq ishdan chiqishiga olib keladi?"],
                            2 => ['text' => 'Накопление накипи в чайнике приводит к более быстрому выходу из строя каких металлических приборов?'],
                            3 => ['text' => 'Accumulation of scale in a kettle leads to faster breakdown of which metal appliances?'],
                        ],
                        'options' => [
                            ['is_correct' => true,  'translations' => [1 => 'Alyuminiy va temir',  2 => 'Алюминий и железо',  3 => 'Aluminium and iron']],
                            ['is_correct' => false, 'translations' => [1 => 'Oltin',               2 => 'Золото',             3 => 'Gold']],
                            ['is_correct' => false, 'translations' => [1 => 'Kumush',              2 => 'Серебро',            3 => 'Silver']],
                            ['is_correct' => false, 'translations' => [1 => 'Plastmassa',          2 => 'Пластмасса',         3 => 'Plastic']],
                        ],
                    ],
                ],
            ],

        ];
    }
}

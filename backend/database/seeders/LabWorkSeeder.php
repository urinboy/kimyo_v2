<?php

namespace Database\Seeders;

use App\Models\Language;
use App\Models\LabWork;
use App\Models\LabWorkTranslation;
use App\Models\LabExperiment;
use App\Models\LabExperimentTranslation;
use App\Models\LabReaction;
use App\Models\LabObservation;
use App\Models\LabObservationTranslation;
use App\Models\LabProduct;
use App\Models\LabProductTranslation;
use Database\Seeders\Concerns\ForeignKeyGuard;
use Illuminate\Database\Seeder;

class LabWorkSeeder extends Seeder
{
    use ForeignKeyGuard;

    /** @var array<string,int> */
    private array $lang;

    public function run(): void
    {
        // Avvalgi ma'lumotlarni tozalash (reverse order FK)
        $this->withoutForeignKeys(function (): void {
            LabProductTranslation::truncate();
            LabProduct::truncate();
            LabObservationTranslation::truncate();
            LabObservation::truncate();
            LabReaction::truncate();
            LabExperimentTranslation::truncate();
            LabExperiment::truncate();
            LabWorkTranslation::truncate();
            LabWork::truncate();
        });

        $this->lang = Language::query()->pluck('id', 'code')->all();

        foreach ($this->labWorksData() as $data) {
            $this->seedLabWork($data);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  Asosiy ma'lumotlar
    // ─────────────────────────────────────────────────────────────────────────

    private function labWorksData(): array
    {
        return [
            // ─── Lab 6 ───────────────────────────────────────────────────────
            [
                'number' => 6,
                'status' => 'active',
                'translations' => [
                    'uz' => ['title' => 'Metallar faollik qatori', 'description' => 'Metallarning kimyoviy faolligi qatorini o\'rganish'],
                    'ru' => ['title' => 'Ряд активности металлов', 'description' => 'Изучение ряда химической активности металлов'],
                    'en' => ['title' => 'Metal Activity Series', 'description' => 'Study of the chemical activity series of metals'],
                ],
                'experiments' => [
                    [
                        'type' => 'tajriba',
                        'order_index' => 1,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Mis (II) sulfat eritmasi va temir',
                                'scientific_explanation' => 'Temir mis ionlarini siqib chiqaradi, chunki temir faollik qatorida misdan faolroq joylashgan. Mis cho\'kma sifatida hosil bo\'ladi.',
                            ],
                            'ru' => [
                                'title' => 'Раствор сульфата меди (II) и железо',
                                'scientific_explanation' => 'Железо вытесняет ионы меди, поскольку в ряду активности находится правее меди. Медь осаждается.',
                            ],
                            'en' => [
                                'title' => 'Copper(II) sulfate solution and iron',
                                'scientific_explanation' => 'Iron displaces copper ions because iron is more active in the activity series. Copper precipitates.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'CuSO₄ + Fe → FeSO₄ + Cu↓', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Cu²⁺ + Fe → Fe²⁺ + Cu↓', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Temir plastinasi yuzasida qizil-jigarrang mis cho\'kmasi hosil bo\'ladi', 'ru' => 'На поверхности железной пластины образуется красно-коричневый осадок меди', 'en' => 'A reddish-brown copper deposit forms on the iron surface'],
                            ['uz' => 'Ko\'k rangli mis sulfat eritmasi rangi asta-sekin so\'nadi', 'ru' => 'Голубой раствор сульфата меди постепенно обесцвечивается', 'en' => 'The blue copper sulfate solution gradually becomes colourless'],
                        ],
                        'products' => [
                            ['formula' => 'Cu', 'state' => 'solid', 'uz' => 'Mis', 'ru' => 'Медь', 'en' => 'Copper'],
                            ['formula' => 'FeSO₄', 'state' => 'dissolved', 'uz' => 'Temir (II) sulfat', 'ru' => 'Сульфат железа (II)', 'en' => 'Iron(II) sulfate'],
                        ],
                    ],
                    [
                        'type' => 'tajriba',
                        'order_index' => 2,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Mis va kumush nitrat eritmasi',
                                'scientific_explanation' => 'Mis faollik qatorida kumushdan faolroq, shuning uchun kumush ionlarini siqib chiqaradi. Kumush cho\'kmaga tushadi.',
                            ],
                            'ru' => [
                                'title' => 'Медь и раствор нитрата серебра',
                                'scientific_explanation' => 'Медь в ряду активности стоит выше серебра, поэтому вытесняет ионы серебра. Серебро осаждается.',
                            ],
                            'en' => [
                                'title' => 'Copper and silver nitrate solution',
                                'scientific_explanation' => 'Copper is above silver in the activity series, so it displaces silver ions. Silver precipitates.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'Cu + 2AgNO₃ → Cu(NO₃)₂ + 2Ag↓', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Cu + 2Ag⁺ → Cu²⁺ + 2Ag↓', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Mis plastinasida kumush kristallari hosil bo\'ladi', 'ru' => 'На медной пластине образуются кристаллы серебра', 'en' => 'Silver crystals form on the copper surface'],
                            ['uz' => 'Rangsiz kumush nitrat eritmasi ko\'k rangga kiradi', 'ru' => 'Бесцветный раствор нитрата серебра приобретает голубой цвет', 'en' => 'The colourless silver nitrate solution turns blue'],
                        ],
                        'products' => [
                            ['formula' => 'Ag', 'state' => 'solid', 'uz' => 'Kumush', 'ru' => 'Серебро', 'en' => 'Silver'],
                            ['formula' => 'Cu(NO₃)₂', 'state' => 'dissolved', 'uz' => 'Mis (II) nitrat', 'ru' => 'Нитрат меди (II)', 'en' => 'Copper(II) nitrate'],
                        ],
                    ],
                ],
            ],

            // ─── Lab 8 ───────────────────────────────────────────────────────
            [
                'number' => 8,
                'status' => 'active',
                'translations' => [
                    'uz' => ['title' => 'Alyuminiyning kislota va ishqor bilan reaksiyasi', 'description' => 'Alyuminiyning amfoterligi — kislota va ishqor bilan reaksiyalarini o\'rganish'],
                    'ru' => ['title' => 'Реакция алюминия с кислотой и щёлочью', 'description' => 'Изучение амфотерности алюминия — реакции с кислотой и щёлочью'],
                    'en' => ['title' => 'Reaction of aluminium with acid and alkali', 'description' => 'Study of aluminium amphotericity — reactions with acid and alkali'],
                ],
                'experiments' => [
                    [
                        'type' => 'probirka',
                        'order_index' => 1,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Alyuminiy + xlorid kislota',
                                'scientific_explanation' => 'Alyuminiy faol metallar qatoriga kiradi va kislotalar bilan reaksiyaga kirishib, tuz va vodorod gazi hosil qiladi.',
                            ],
                            'ru' => [
                                'title' => 'Алюминий + соляная кислота',
                                'scientific_explanation' => 'Алюминий является активным металлом и реагирует с кислотами, образуя соль и водород.',
                            ],
                            'en' => [
                                'title' => 'Aluminium + hydrochloric acid',
                                'scientific_explanation' => 'Aluminium is an active metal that reacts with acids to form a salt and hydrogen gas.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => '2Al + 6HCl → 2AlCl₃ + 3H₂↑', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => '2Al + 6H⁺ → 2Al³⁺ + 3H₂↑', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Shiddatli gaz ajralib chiqadi (vodorod)', 'ru' => 'Интенсивное выделение газа (водорода)', 'en' => 'Vigorous gas evolution (hydrogen)'],
                            ['uz' => 'Alyuminiy parchalanadi va eritmada yo\'qoladi', 'ru' => 'Алюминий растворяется и исчезает в растворе', 'en' => 'Aluminium dissolves and disappears in the solution'],
                        ],
                        'products' => [
                            ['formula' => 'AlCl₃', 'state' => 'dissolved', 'uz' => 'Alyuminiy xlorid', 'ru' => 'Хлорид алюминия', 'en' => 'Aluminium chloride'],
                            ['formula' => 'H₂', 'state' => 'gas', 'uz' => 'Vodorod gazi', 'ru' => 'Водород', 'en' => 'Hydrogen gas'],
                        ],
                    ],
                    [
                        'type' => 'probirka',
                        'order_index' => 2,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Alyuminiy + natriy gidroksid eritmasi',
                                'scientific_explanation' => 'Alyuminiy amfoter metal bo\'lib, kislotalargina emas, ishqor bilan ham reaksiyaga kirishadi. Bu xususiyat alyuminiy oksidi (Al₂O₃) va gidroksidiga (Al(OH)₃) ham xos.',
                            ],
                            'ru' => [
                                'title' => 'Алюминий + раствор гидроксида натрия',
                                'scientific_explanation' => 'Алюминий — амфотерный металл, реагирует не только с кислотами, но и со щёлочами. Это свойство характерно и для оксида, и для гидроксида алюминия.',
                            ],
                            'en' => [
                                'title' => 'Aluminium + sodium hydroxide solution',
                                'scientific_explanation' => 'Aluminium is an amphoteric metal, reacting not only with acids but also with alkalis. This property is also characteristic of aluminium oxide and hydroxide.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => '2Al + 2NaOH + 2H₂O → 2NaAlO₂ + 3H₂↑', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => '2Al + 2OH⁻ + 2H₂O → 2AlO₂⁻ + 3H₂↑', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Gaz ajralib chiqadi (vodorod)', 'ru' => 'Выделяется газ (водород)', 'en' => 'Gas evolves (hydrogen)'],
                            ['uz' => 'Alyuminiy asta-sekin erib ketadi', 'ru' => 'Алюминий постепенно растворяется', 'en' => 'Aluminium gradually dissolves'],
                        ],
                        'products' => [
                            ['formula' => 'NaAlO₂', 'state' => 'dissolved', 'uz' => 'Natriy aluminat', 'ru' => 'Алюминат натрия', 'en' => 'Sodium aluminate'],
                            ['formula' => 'H₂', 'state' => 'gas', 'uz' => 'Vodorod gazi', 'ru' => 'Водород', 'en' => 'Hydrogen gas'],
                        ],
                    ],
                ],
            ],

            // ─── Lab 10 ──────────────────────────────────────────────────────
            [
                'number' => 10,
                'status' => 'active',
                'translations' => [
                    'uz' => ['title' => 'Alyuminiy gidroksid olish va uning xossalari', 'description' => 'Al(OH)₃ ni olish va uning amfoter xossalarini ko\'rsatish'],
                    'ru' => ['title' => 'Получение гидроксида алюминия и его свойства', 'description' => 'Получение Al(OH)₃ и демонстрация его амфотерных свойств'],
                    'en' => ['title' => 'Preparation of aluminium hydroxide and its properties', 'description' => 'Preparation of Al(OH)₃ and demonstration of its amphoteric properties'],
                ],
                'experiments' => [
                    [
                        'type' => 'bosqich',
                        'order_index' => 1,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Alyuminiy gidroksid olish',
                                'scientific_explanation' => 'Alyuminiy tuziga oz miqdorda ishqor ta\'sir ettirilganda alyuminiy gidroksid cho\'kmasi hosil bo\'ladi.',
                            ],
                            'ru' => [
                                'title' => 'Получение гидроксида алюминия',
                                'scientific_explanation' => 'При действии небольшого количества щёлочи на соль алюминия образуется осадок гидроксида алюминия.',
                            ],
                            'en' => [
                                'title' => 'Preparation of aluminium hydroxide',
                                'scientific_explanation' => 'When a small amount of alkali is added to an aluminium salt, an aluminium hydroxide precipitate forms.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'AlCl₃ + 3NaOH → Al(OH)₃↓ + 3NaCl', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Al³⁺ + 3OH⁻ → Al(OH)₃↓', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Oq rangli jele ko\'rinishidagi cho\'kma hosil bo\'ladi', 'ru' => 'Образуется белый студенистый осадок', 'en' => 'A white gelatinous precipitate forms'],
                        ],
                        'products' => [
                            ['formula' => 'Al(OH)₃', 'state' => 'precipitate', 'uz' => 'Alyuminiy gidroksid', 'ru' => 'Гидроксид алюминия', 'en' => 'Aluminium hydroxide'],
                        ],
                    ],
                    [
                        'type' => 'bosqich',
                        'order_index' => 2,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Al(OH)₃ ni kislotada eritish',
                                'scientific_explanation' => 'Al(OH)₃ amfoter oksid xossasiga ega bo\'lib, kislotalar bilan reaksiyaga kirishib, tuz hosil qiladi.',
                            ],
                            'ru' => [
                                'title' => 'Растворение Al(OH)₃ в кислоте',
                                'scientific_explanation' => 'Al(OH)₃ обладает амфотерными свойствами и реагирует с кислотами, образуя соль.',
                            ],
                            'en' => [
                                'title' => 'Dissolving Al(OH)₃ in acid',
                                'scientific_explanation' => 'Al(OH)₃ has amphoteric properties and reacts with acids to form a salt.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'Al(OH)₃ + 3HCl → AlCl₃ + 3H₂O', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Al(OH)₃ + 3H⁺ → Al³⁺ + 3H₂O', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Oq cho\'kma erib ketadi, eritma tiniq bo\'ladi', 'ru' => 'Белый осадок растворяется, раствор становится прозрачным', 'en' => 'The white precipitate dissolves, the solution becomes clear'],
                        ],
                        'products' => [
                            ['formula' => 'AlCl₃', 'state' => 'dissolved', 'uz' => 'Alyuminiy xlorid', 'ru' => 'Хлорид алюминия', 'en' => 'Aluminium chloride'],
                        ],
                    ],
                    [
                        'type' => 'bosqich',
                        'order_index' => 3,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Al(OH)₃ ni ishqorda eritish',
                                'scientific_explanation' => 'Al(OH)₃ kislota bilan ham, ishqor bilan ham reaksiyaga kirishadi. Ishqorda aluminat tuzi hosil bo\'ladi — bu amfoterlikning asosiy belgisi.',
                            ],
                            'ru' => [
                                'title' => 'Растворение Al(OH)₃ в щёлочи',
                                'scientific_explanation' => 'Al(OH)₃ реагирует как с кислотами, так и со щёлочами. В щёлочи образуется алюминат — главный признак амфотерности.',
                            ],
                            'en' => [
                                'title' => 'Dissolving Al(OH)₃ in alkali',
                                'scientific_explanation' => 'Al(OH)₃ reacts with both acids and alkalis. In alkali, an aluminate salt forms — the main sign of amphotericity.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'Al(OH)₃ + NaOH → NaAlO₂ + 2H₂O', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Al(OH)₃ + OH⁻ → AlO₂⁻ + 2H₂O', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Oq cho\'kma ishqor ta\'sirida erib ketadi', 'ru' => 'Белый осадок растворяется под действием щёлочи', 'en' => 'The white precipitate dissolves in alkali'],
                        ],
                        'products' => [
                            ['formula' => 'NaAlO₂', 'state' => 'dissolved', 'uz' => 'Natriy aluminat', 'ru' => 'Алюминат натрия', 'en' => 'Sodium aluminate'],
                        ],
                    ],
                ],
            ],

            // ─── Lab 11 ──────────────────────────────────────────────────────
            [
                'number' => 11,
                'status' => 'active',
                'translations' => [
                    'uz' => ['title' => 'AlCl₃ ning gidrolizi va indikatorlar', 'description' => 'Alyuminiy xloridning gidrolizini indikatorlar yordamida o\'rganish'],
                    'ru' => ['title' => 'Гидролиз AlCl₃ и индикаторы', 'description' => 'Изучение гидролиза хлорида алюминия с помощью индикаторов'],
                    'en' => ['title' => 'Hydrolysis of AlCl₃ and indicators', 'description' => 'Study of aluminium chloride hydrolysis using indicators'],
                ],
                'experiments' => [
                    [
                        'type' => 'tajriba',
                        'order_index' => 1,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'AlCl₃ ning suv bilan gidrolizi',
                                'scientific_explanation' => 'Zaif asosning kuchli kislota bilan hosil bo\'lgan tuzi (AlCl₃) suvda gidrolizlanadi va eritma kislotali muhit ko\'rsatadi. Bu kation gidrolizi.',
                            ],
                            'ru' => [
                                'title' => 'Гидролиз AlCl₃ с водой',
                                'scientific_explanation' => 'Соль слабого основания и сильной кислоты (AlCl₃) гидролизуется в воде, давая кислую реакцию среды. Это катионный гидролиз.',
                            ],
                            'en' => [
                                'title' => 'Hydrolysis of AlCl₃ with water',
                                'scientific_explanation' => 'The salt of a weak base and strong acid (AlCl₃) hydrolyses in water, giving an acidic medium. This is cation hydrolysis.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'AlCl₃ + 3H₂O ⇌ Al(OH)₃ + 3HCl', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Al³⁺ + 3H₂O ⇌ Al(OH)₃ + 3H⁺', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Litmus qog\'ozi qizil rangga bo\'yaladi — kislotali muhit', 'ru' => 'Лакмусовая бумага краснеет — кислая среда', 'en' => 'Litmus paper turns red — acidic medium'],
                            ['uz' => 'Fenolftalein rangsiz qoladi', 'ru' => 'Фенолфталеин остаётся бесцветным', 'en' => 'Phenolphthalein remains colourless'],
                        ],
                        'products' => [
                            ['formula' => 'H⁺', 'state' => 'dissolved', 'uz' => 'Vodorod ionlari (kislotali muhit)', 'ru' => 'Ионы водорода (кислая среда)', 'en' => 'Hydrogen ions (acidic medium)'],
                        ],
                    ],
                ],
            ],

            // ─── Lab 12 ──────────────────────────────────────────────────────
            [
                'number' => 12,
                'status' => 'active',
                'translations' => [
                    'uz' => ['title' => 'Mis (II) gidroksid olish va xossalari', 'description' => 'CuSO₄ va NaOH dan Cu(OH)₂ olish hamda uni qizdirish'],
                    'ru' => ['title' => 'Получение гидроксида меди (II) и его свойства', 'description' => 'Получение Cu(OH)₂ из CuSO₄ и NaOH, а также его нагрев'],
                    'en' => ['title' => 'Preparation of copper(II) hydroxide and its properties', 'description' => 'Preparation of Cu(OH)₂ from CuSO₄ and NaOH and its heating'],
                ],
                'experiments' => [
                    [
                        'type' => 'probirka',
                        'order_index' => 1,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Mis (II) gidroksid cho\'kmasi olish',
                                'scientific_explanation' => 'Mis sulfat va natriy gidroksid reaksiyasida ko\'k rangli mis (II) gidroksid cho\'kmasi hosil bo\'ladi.',
                            ],
                            'ru' => [
                                'title' => 'Осаждение гидроксида меди (II)',
                                'scientific_explanation' => 'При реакции сульфата меди и гидроксида натрия образуется голубой осадок гидроксида меди (II).',
                            ],
                            'en' => [
                                'title' => 'Precipitation of copper(II) hydroxide',
                                'scientific_explanation' => 'Reaction of copper sulfate and sodium hydroxide produces a blue copper(II) hydroxide precipitate.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'CuSO₄ + 2NaOH → Cu(OH)₂↓ + Na₂SO₄', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Cu²⁺ + 2OH⁻ → Cu(OH)₂↓', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Ko\'k rangli cho\'kma hosil bo\'ladi', 'ru' => 'Образуется голубой осадок', 'en' => 'A blue precipitate forms'],
                        ],
                        'products' => [
                            ['formula' => 'Cu(OH)₂', 'state' => 'precipitate', 'uz' => 'Mis (II) gidroksid', 'ru' => 'Гидроксид меди (II)', 'en' => 'Copper(II) hydroxide'],
                        ],
                    ],
                    [
                        'type' => 'probirka',
                        'order_index' => 2,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Cu(OH)₂ ni qizdirish',
                                'scientific_explanation' => 'Qizdirilganda mis gidroksid parchalanadi: mis oksidi (qora) va suv hosil bo\'ladi. Bu parchalanish reaksiyasidir.',
                            ],
                            'ru' => [
                                'title' => 'Нагрев Cu(OH)₂',
                                'scientific_explanation' => 'При нагревании гидроксид меди разлагается с образованием оксида меди (чёрного) и воды. Это реакция разложения.',
                            ],
                            'en' => [
                                'title' => 'Heating Cu(OH)₂',
                                'scientific_explanation' => 'When heated, copper hydroxide decomposes to form copper oxide (black) and water. This is a decomposition reaction.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'Cu(OH)₂ → CuO + H₂O', 'type' => 'molecular', 'order_index' => 1],
                        ],
                        'observations' => [
                            ['uz' => 'Ko\'k cho\'kma qora rangga aylanadi (CuO)', 'ru' => 'Голубой осадок чернеет (CuO)', 'en' => 'The blue precipitate turns black (CuO)'],
                            ['uz' => 'Probirka devorlari buglanib ho\'l bo\'ladi (H₂O)', 'ru' => 'Стенки пробирки запотевают (H₂O)', 'en' => 'The test tube walls mist up (H₂O)'],
                        ],
                        'products' => [
                            ['formula' => 'CuO', 'state' => 'solid', 'uz' => 'Mis (II) oksid', 'ru' => 'Оксид меди (II)', 'en' => 'Copper(II) oxide'],
                            ['formula' => 'H₂O', 'state' => 'gas', 'uz' => 'Suv bug\'i', 'ru' => 'Пар воды', 'en' => 'Water vapour'],
                        ],
                    ],
                ],
            ],

            // ─── Lab 13 ──────────────────────────────────────────────────────
            [
                'number' => 13,
                'status' => 'active',
                'translations' => [
                    'uz' => ['title' => 'Rux gidroksidning amfoterligi', 'description' => 'Zn(OH)₂ ning kislota va ishqor bilan reaksiyalarini o\'rganish'],
                    'ru' => ['title' => 'Амфотерность гидроксида цинка', 'description' => 'Изучение реакций Zn(OH)₂ с кислотой и щёлочью'],
                    'en' => ['title' => 'Amphotericity of zinc hydroxide', 'description' => 'Study of Zn(OH)₂ reactions with acid and alkali'],
                ],
                'experiments' => [
                    [
                        'type' => 'probirka',
                        'order_index' => 1,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Rux gidroksid cho\'kmasi olish',
                                'scientific_explanation' => 'Rux sulfat eritmasiga NaOH qo\'shilganda oq rangli Zn(OH)₂ cho\'kmasi hosil bo\'ladi.',
                            ],
                            'ru' => [
                                'title' => 'Осаждение гидроксида цинка',
                                'scientific_explanation' => 'При добавлении NaOH к раствору сульфата цинка образуется белый осадок Zn(OH)₂.',
                            ],
                            'en' => [
                                'title' => 'Precipitation of zinc hydroxide',
                                'scientific_explanation' => 'Adding NaOH to zinc sulfate solution produces a white Zn(OH)₂ precipitate.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'ZnSO₄ + 2NaOH → Zn(OH)₂↓ + Na₂SO₄', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Zn²⁺ + 2OH⁻ → Zn(OH)₂↓', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Oq rangli cho\'kma hosil bo\'ladi', 'ru' => 'Образуется белый осадок', 'en' => 'A white precipitate forms'],
                        ],
                        'products' => [
                            ['formula' => 'Zn(OH)₂', 'state' => 'precipitate', 'uz' => 'Rux gidroksid', 'ru' => 'Гидроксид цинка', 'en' => 'Zinc hydroxide'],
                        ],
                    ],
                    [
                        'type' => 'probirka',
                        'order_index' => 2,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Zn(OH)₂ ning kislota bilan reaksiyasi',
                                'scientific_explanation' => 'Rux gidroksid amfoter xossa namoyish qilib, kislota bilan reaksiyaga kirishadi va tuz hosil qiladi.',
                            ],
                            'ru' => [
                                'title' => 'Реакция Zn(OH)₂ с кислотой',
                                'scientific_explanation' => 'Гидроксид цинка проявляет амфотерные свойства, реагируя с кислотой с образованием соли.',
                            ],
                            'en' => [
                                'title' => 'Reaction of Zn(OH)₂ with acid',
                                'scientific_explanation' => 'Zinc hydroxide displays amphoteric properties, reacting with acid to form a salt.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'Zn(OH)₂ + H₂SO₄ → ZnSO₄ + 2H₂O', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Zn(OH)₂ + 2H⁺ → Zn²⁺ + 2H₂O', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Oq cho\'kma kislotada erib ketadi, eritma tiniq bo\'ladi', 'ru' => 'Белый осадок растворяется в кислоте, раствор становится прозрачным', 'en' => 'White precipitate dissolves in acid, solution becomes clear'],
                        ],
                        'products' => [
                            ['formula' => 'ZnSO₄', 'state' => 'dissolved', 'uz' => 'Rux sulfat', 'ru' => 'Сульфат цинка', 'en' => 'Zinc sulfate'],
                        ],
                    ],
                    [
                        'type' => 'probirka',
                        'order_index' => 3,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Zn(OH)₂ ning ishqor bilan reaksiyasi',
                                'scientific_explanation' => 'Rux gidroksid ishqor bilan ham reaksiyaga kirishib, sinkat tuzi hosil qiladi. Bu amfoterlikning ikkinchi tomonidir.',
                            ],
                            'ru' => [
                                'title' => 'Реакция Zn(OH)₂ со щёлочью',
                                'scientific_explanation' => 'Гидроксид цинка реагирует и со щёлочью, образуя цинкат. Это вторая сторона амфотерности.',
                            ],
                            'en' => [
                                'title' => 'Reaction of Zn(OH)₂ with alkali',
                                'scientific_explanation' => 'Zinc hydroxide also reacts with alkali to form a zincate. This is the second aspect of amphotericity.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'Zn(OH)₂ + 2NaOH → Na₂ZnO₂ + 2H₂O', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Zn(OH)₂ + 2OH⁻ → ZnO₂²⁻ + 2H₂O', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Oq cho\'kma ishqorda ham erib ketadi', 'ru' => 'Белый осадок растворяется и в щёлочи', 'en' => 'The white precipitate dissolves in alkali too'],
                        ],
                        'products' => [
                            ['formula' => 'Na₂ZnO₂', 'state' => 'dissolved', 'uz' => 'Natriy sinkat', 'ru' => 'Цинкат натрия', 'en' => 'Sodium zincate'],
                        ],
                    ],
                ],
            ],

            // ─── Lab 14 ──────────────────────────────────────────────────────
            [
                'number' => 14,
                'status' => 'active',
                'translations' => [
                    'uz' => ['title' => 'Xrom birikmalari', 'description' => 'Cr(OH)₃ ning amfoter xossalarini o\'rganish'],
                    'ru' => ['title' => 'Соединения хрома', 'description' => 'Изучение амфотерных свойств Cr(OH)₃'],
                    'en' => ['title' => 'Chromium compounds', 'description' => 'Study of amphoteric properties of Cr(OH)₃'],
                ],
                'experiments' => [
                    [
                        'type' => 'tajriba',
                        'order_index' => 1,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Xrom (III) gidroksid olish',
                                'scientific_explanation' => 'Xrom (III) sulfat eritmasiga ishqor qo\'shilganda yashil-kulrang Cr(OH)₃ cho\'kmasi hosil bo\'ladi.',
                            ],
                            'ru' => [
                                'title' => 'Получение гидроксида хрома (III)',
                                'scientific_explanation' => 'При добавлении щёлочи к раствору сульфата хрома (III) образуется зелёно-серый осадок Cr(OH)₃.',
                            ],
                            'en' => [
                                'title' => 'Preparation of chromium(III) hydroxide',
                                'scientific_explanation' => 'Adding alkali to chromium(III) sulfate solution produces a grey-green Cr(OH)₃ precipitate.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'Cr₂(SO₄)₃ + 6NaOH → 2Cr(OH)₃↓ + 3Na₂SO₄', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Cr³⁺ + 3OH⁻ → Cr(OH)₃↓', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Yashil-kulrang cho\'kma hosil bo\'ladi', 'ru' => 'Образуется зелёно-серый осадок', 'en' => 'A grey-green precipitate forms'],
                        ],
                        'products' => [
                            ['formula' => 'Cr(OH)₃', 'state' => 'precipitate', 'uz' => 'Xrom (III) gidroksid', 'ru' => 'Гидроксид хрома (III)', 'en' => 'Chromium(III) hydroxide'],
                        ],
                    ],
                    [
                        'type' => 'tajriba',
                        'order_index' => 2,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Cr(OH)₃ ning kislotada erishi',
                                'scientific_explanation' => 'Xrom gidroksid amfoter bo\'lib, kislotalar bilan reaksiyaga kirishib xrom tuzlarini hosil qiladi.',
                            ],
                            'ru' => [
                                'title' => 'Растворение Cr(OH)₃ в кислоте',
                                'scientific_explanation' => 'Гидроксид хрома — амфотерный, реагирует с кислотами, образуя соли хрома.',
                            ],
                            'en' => [
                                'title' => 'Dissolving Cr(OH)₃ in acid',
                                'scientific_explanation' => 'Chromium hydroxide is amphoteric and reacts with acids to form chromium salts.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'Cr(OH)₃ + 3HCl → CrCl₃ + 3H₂O', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Cr(OH)₃ + 3H⁺ → Cr³⁺ + 3H₂O', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Cho\'kma erib ketadi, yashilimtir eritma hosil bo\'ladi', 'ru' => 'Осадок растворяется, образуется зеленоватый раствор', 'en' => 'The precipitate dissolves, forming a greenish solution'],
                        ],
                        'products' => [
                            ['formula' => 'CrCl₃', 'state' => 'dissolved', 'uz' => 'Xrom (III) xlorid', 'ru' => 'Хлорид хрома (III)', 'en' => 'Chromium(III) chloride'],
                        ],
                    ],
                    [
                        'type' => 'tajriba',
                        'order_index' => 3,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Cr(OH)₃ ning ishqorda erishi',
                                'scientific_explanation' => 'Xrom gidroksid ortiqcha ishqorda erishi mumkin, xromat (III) tuzi hosil bo\'ladi — amfoterlikning ikkinchi tomoni.',
                            ],
                            'ru' => [
                                'title' => 'Растворение Cr(OH)₃ в щёлочи',
                                'scientific_explanation' => 'Гидроксид хрома может растворяться в избытке щёлочи, образуя хромат(III) — вторая сторона амфотерности.',
                            ],
                            'en' => [
                                'title' => 'Dissolving Cr(OH)₃ in alkali',
                                'scientific_explanation' => 'Chromium hydroxide can dissolve in excess alkali, forming chromate(III) — the second aspect of amphotericity.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'Cr(OH)₃ + 3NaOH → Na₃[Cr(OH)₆]', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Cr(OH)₃ + 3OH⁻ → [Cr(OH)₆]³⁻', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Cho\'kma ortiqcha ishqorda erib, yashil eritma hosil bo\'ladi', 'ru' => 'Осадок растворяется в избытке щёлочи, образуется зелёный раствор', 'en' => 'Precipitate dissolves in excess alkali forming a green solution'],
                        ],
                        'products' => [
                            ['formula' => 'Na₃[Cr(OH)₆]', 'state' => 'dissolved', 'uz' => 'Natriy geksagidroksoixromat', 'ru' => 'Гексагидроксохромат натрия', 'en' => 'Sodium hexahydroxochromate'],
                        ],
                    ],
                ],
            ],

            // ─── Lab 15 ──────────────────────────────────────────────────────
            [
                'number' => 15,
                'status' => 'active',
                'translations' => [
                    'uz' => ['title' => 'Temir (II) va temir (III) gidroksidlari', 'description' => 'Fe(OH)₂ va Fe(OH)₃ ni olish va ularning xossalarini o\'rganish'],
                    'ru' => ['title' => 'Гидроксиды железа (II) и (III)', 'description' => 'Получение Fe(OH)₂ и Fe(OH)₃ и изучение их свойств'],
                    'en' => ['title' => 'Iron(II) and iron(III) hydroxides', 'description' => 'Preparation of Fe(OH)₂ and Fe(OH)₃ and study of their properties'],
                ],
                'experiments' => [
                    [
                        'type' => 'probirka',
                        'order_index' => 1,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Temir (II) gidroksid olish',
                                'scientific_explanation' => 'Temir (II) sulfatga NaOH ta\'sir ettirilganda oq-yashilimtir Fe(OH)₂ cho\'kmasi hosil bo\'ladi.',
                            ],
                            'ru' => [
                                'title' => 'Получение гидроксида железа (II)',
                                'scientific_explanation' => 'При действии NaOH на сульфат железа (II) образуется белый зеленоватый осадок Fe(OH)₂.',
                            ],
                            'en' => [
                                'title' => 'Preparation of iron(II) hydroxide',
                                'scientific_explanation' => 'NaOH acting on iron(II) sulfate produces a white-greenish Fe(OH)₂ precipitate.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'FeSO₄ + 2NaOH → Fe(OH)₂↓ + Na₂SO₄', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Fe²⁺ + 2OH⁻ → Fe(OH)₂↓', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Oq-yashilimtir cho\'kma hosil bo\'ladi', 'ru' => 'Образуется белый зеленоватый осадок', 'en' => 'A white-greenish precipitate forms'],
                        ],
                        'products' => [
                            ['formula' => 'Fe(OH)₂', 'state' => 'precipitate', 'uz' => 'Temir (II) gidroksid', 'ru' => 'Гидроксид железа (II)', 'en' => 'Iron(II) hydroxide'],
                        ],
                    ],
                    [
                        'type' => 'probirka',
                        'order_index' => 2,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Fe(OH)₂ oksidlanishi',
                                'scientific_explanation' => 'Fe(OH)₂ havo kislorodi ta\'sirida oksidlanib, jigarrang Fe(OH)₃ ga aylanadi. Bu Fe²⁺ → Fe³⁺ o\'tishi — oksidlanish-qaytarilish reaksiyasi.',
                            ],
                            'ru' => [
                                'title' => 'Окисление Fe(OH)₂',
                                'scientific_explanation' => 'Fe(OH)₂ окисляется кислородом воздуха, превращаясь в бурый Fe(OH)₃. Это переход Fe²⁺ → Fe³⁺ — окислительно-восстановительная реакция.',
                            ],
                            'en' => [
                                'title' => 'Oxidation of Fe(OH)₂',
                                'scientific_explanation' => 'Fe(OH)₂ is oxidised by atmospheric oxygen, converting to brown Fe(OH)₃. This is the Fe²⁺ → Fe³⁺ transition — a redox reaction.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => '4Fe(OH)₂ + O₂ + 2H₂O → 4Fe(OH)₃', 'type' => 'molecular', 'order_index' => 1],
                        ],
                        'observations' => [
                            ['uz' => 'Oq-yashil cho\'kma asta-sekin jigarrang rangga o\'tadi', 'ru' => 'Белый зеленоватый осадок постепенно буреет', 'en' => 'The white-green precipitate gradually turns brown'],
                        ],
                        'products' => [
                            ['formula' => 'Fe(OH)₃', 'state' => 'precipitate', 'uz' => 'Temir (III) gidroksid', 'ru' => 'Гидроксид железа (III)', 'en' => 'Iron(III) hydroxide'],
                        ],
                    ],
                    [
                        'type' => 'probirka',
                        'order_index' => 3,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Temir (III) gidroksid olish',
                                'scientific_explanation' => 'Temir (III) xlorid eritmasiga NaOH qo\'shilganda jigarrang Fe(OH)₃ cho\'kmasi to\'g\'ridan-to\'g\'ri hosil bo\'ladi.',
                            ],
                            'ru' => [
                                'title' => 'Получение гидроксида железа (III)',
                                'scientific_explanation' => 'При добавлении NaOH к раствору хлорида железа (III) непосредственно образуется бурый осадок Fe(OH)₃.',
                            ],
                            'en' => [
                                'title' => 'Direct preparation of iron(III) hydroxide',
                                'scientific_explanation' => 'Adding NaOH to iron(III) chloride solution directly produces a brown Fe(OH)₃ precipitate.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'FeCl₃ + 3NaOH → Fe(OH)₃↓ + 3NaCl', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Fe³⁺ + 3OH⁻ → Fe(OH)₃↓', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Jigarrang cho\'kma hosil bo\'ladi', 'ru' => 'Образуется бурый осадок', 'en' => 'A brown precipitate forms'],
                        ],
                        'products' => [
                            ['formula' => 'Fe(OH)₃', 'state' => 'precipitate', 'uz' => 'Temir (III) gidroksid', 'ru' => 'Гидроксид железа (III)', 'en' => 'Iron(III) hydroxide'],
                        ],
                    ],
                ],
            ],

            // ─── Lab 16 ──────────────────────────────────────────────────────
            [
                'number' => 16,
                'status' => 'active',
                'translations' => [
                    'uz' => ['title' => 'Temir ionlarini sifat jihatdan aniqlash', 'description' => 'Fe²⁺ va Fe³⁺ ionlarini sifat reaksiyalari yordamida aniqlash'],
                    'ru' => ['title' => 'Качественное обнаружение ионов железа', 'description' => 'Обнаружение ионов Fe²⁺ и Fe³⁺ с помощью качественных реакций'],
                    'en' => ['title' => 'Qualitative detection of iron ions', 'description' => 'Detection of Fe²⁺ and Fe³⁺ ions using qualitative reactions'],
                ],
                'experiments' => [
                    [
                        'type' => 'tajriba',
                        'order_index' => 1,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Fe²⁺ ionini aniqlash — kaliy geksasianoferrat (III)',
                                'scientific_explanation' => 'Fe²⁺ ioni K₃[Fe(CN)₆] bilan o\'ziga xos ko\'k cho\'kma hosil qiladi (Turnbull ko\'ki). Bu Fe²⁺ ioniga sifat reaksiyasi.',
                            ],
                            'ru' => [
                                'title' => 'Обнаружение Fe²⁺ — гексацианоферрат (III) калия',
                                'scientific_explanation' => 'Ион Fe²⁺ с K₃[Fe(CN)₆] даёт характерный синий осадок (синь Тернбуля). Это качественная реакция на Fe²⁺.',
                            ],
                            'en' => [
                                'title' => 'Detection of Fe²⁺ — potassium hexacyanoferrate(III)',
                                'scientific_explanation' => 'Fe²⁺ ion with K₃[Fe(CN)₆] forms a characteristic blue precipitate (Turnbull\'s blue). This is the qualitative test for Fe²⁺.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => '3FeSO₄ + 2K₃[Fe(CN)₆] → Fe₃[Fe(CN)₆]₂↓ + 3K₂SO₄', 'type' => 'molecular', 'order_index' => 1],
                        ],
                        'observations' => [
                            ['uz' => 'Ko\'k rangli cho\'kma (Turnbull ko\'ki) hosil bo\'ladi — Fe²⁺ mavjudligini ko\'rsatadi', 'ru' => 'Образуется синий осадок (синь Тернбуля) — свидетельствует о наличии Fe²⁺', 'en' => 'A blue precipitate (Turnbull\'s blue) forms — indicates presence of Fe²⁺'],
                        ],
                        'products' => [
                            ['formula' => 'Fe₃[Fe(CN)₆]₂', 'state' => 'precipitate', 'uz' => 'Turnbull ko\'ki', 'ru' => 'Синь Тернбуля', 'en' => 'Turnbull\'s blue'],
                        ],
                    ],
                    [
                        'type' => 'tajriba',
                        'order_index' => 2,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Fe³⁺ ionini aniqlash — kaliy geksasianoferrat (II)',
                                'scientific_explanation' => 'Fe³⁺ ioni K₄[Fe(CN)₆] bilan to\'q ko\'k cho\'kma hosil qiladi (Berlin ko\'ki). Bu Fe³⁺ ioniga sifat reaksiyasi.',
                            ],
                            'ru' => [
                                'title' => 'Обнаружение Fe³⁺ — гексацианоферрат (II) калия',
                                'scientific_explanation' => 'Ион Fe³⁺ с K₄[Fe(CN)₆] даёт тёмно-синий осадок (берлинская лазурь). Это качественная реакция на Fe³⁺.',
                            ],
                            'en' => [
                                'title' => 'Detection of Fe³⁺ — potassium hexacyanoferrate(II)',
                                'scientific_explanation' => 'Fe³⁺ ion with K₄[Fe(CN)₆] forms a dark blue precipitate (Prussian blue). This is the qualitative test for Fe³⁺.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => '4FeCl₃ + 3K₄[Fe(CN)₆] → Fe₄[Fe(CN)₆]₃↓ + 12KCl', 'type' => 'molecular', 'order_index' => 1],
                        ],
                        'observations' => [
                            ['uz' => 'To\'q ko\'k rangli cho\'kma (Berlin ko\'ki) hosil bo\'ladi — Fe³⁺ mavjudligini ko\'rsatadi', 'ru' => 'Образуется тёмно-синий осадок (берлинская лазурь) — свидетельствует о наличии Fe³⁺', 'en' => 'A dark blue precipitate (Prussian blue) forms — indicates presence of Fe³⁺'],
                        ],
                        'products' => [
                            ['formula' => 'Fe₄[Fe(CN)₆]₃', 'state' => 'precipitate', 'uz' => 'Berlin ko\'ki (Prussian ko\'ki)', 'ru' => 'Берлинская лазурь', 'en' => 'Prussian blue'],
                        ],
                    ],
                    [
                        'type' => 'tajriba',
                        'order_index' => 3,
                        'status' => 'active',
                        'translations' => [
                            'uz' => [
                                'title' => 'Fe³⁺ ionini aniqlash — kaliy tiosiyanat',
                                'scientific_explanation' => 'Fe³⁺ ioni KSCN bilan qon-qizil rangli kompleks hosil qiladi. Bu Fe³⁺ ioniga eng sezgir sifat reaksiyasi.',
                            ],
                            'ru' => [
                                'title' => 'Обнаружение Fe³⁺ — тиоцианат калия',
                                'scientific_explanation' => 'Ион Fe³⁺ с KSCN образует кроваво-красный комплекс. Это наиболее чувствительная качественная реакция на Fe³⁺.',
                            ],
                            'en' => [
                                'title' => 'Detection of Fe³⁺ — potassium thiocyanate',
                                'scientific_explanation' => 'Fe³⁺ ion with KSCN forms a blood-red complex. This is the most sensitive qualitative test for Fe³⁺.',
                            ],
                        ],
                        'reactions' => [
                            ['formula' => 'FeCl₃ + 3KSCN → Fe(SCN)₃ + 3KCl', 'type' => 'molecular', 'order_index' => 1],
                            ['formula' => 'Fe³⁺ + 3SCN⁻ → Fe(SCN)₃', 'type' => 'short_ionic', 'order_index' => 2],
                        ],
                        'observations' => [
                            ['uz' => 'Qon-qizil rangli eritma hosil bo\'ladi — Fe³⁺ mavjudligining eng aniq belgisi', 'ru' => 'Образуется кроваво-красный раствор — наиболее чёткий признак присутствия Fe³⁺', 'en' => 'A blood-red solution forms — the clearest indicator of Fe³⁺ presence'],
                        ],
                        'products' => [
                            ['formula' => 'Fe(SCN)₃', 'state' => 'dissolved', 'uz' => 'Temir (III) tiosiyanat (qizil)', 'ru' => 'Тиоцианат железа (III) (красный)', 'en' => 'Iron(III) thiocyanate (blood red)'],
                        ],
                    ],
                ],
            ],
        ];
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  Yordamchi metodlar
    // ─────────────────────────────────────────────────────────────────────────

    private function seedLabWork(array $data): void
    {
        $labWork = LabWork::create([
            'number' => $data['number'],
            'status' => $data['status'],
        ]);

        foreach ($data['translations'] as $code => $t) {
            if (empty($this->lang[$code])) {
                continue;
            }
            LabWorkTranslation::create([
                'lab_work_id' => $labWork->id,
                'language_id' => $this->lang[$code],
                'title' => $t['title'],
                'description' => $t['description'] ?? null,
            ]);
        }

        foreach ($data['experiments'] as $expData) {
            $this->seedExperiment($labWork->id, $expData);
        }
    }

    private function seedExperiment(int $labWorkId, array $data): void
    {
        $exp = LabExperiment::create([
            'lab_work_id' => $labWorkId,
            'type' => $data['type'],
            'order_index' => $data['order_index'],
            'status' => $data['status'],
        ]);

        foreach ($data['translations'] as $code => $t) {
            if (empty($this->lang[$code])) {
                continue;
            }
            LabExperimentTranslation::create([
                'lab_experiment_id' => $exp->id,
                'language_id' => $this->lang[$code],
                'title' => $t['title'],
                'scientific_explanation' => $t['scientific_explanation'] ?? null,
            ]);
        }

        foreach ($data['reactions'] ?? [] as $r) {
            LabReaction::create([
                'lab_experiment_id' => $exp->id,
                'formula' => $r['formula'],
                'type' => $r['type'],
                'order_index' => $r['order_index'],
            ]);
        }

        foreach ($data['observations'] ?? [] as $idx => $obs) {
            $observation = LabObservation::create([
                'lab_experiment_id' => $exp->id,
                'order_index' => $idx + 1,
            ]);

            foreach (['uz', 'ru', 'en'] as $code) {
                if (empty($this->lang[$code]) || empty($obs[$code])) {
                    continue;
                }
                LabObservationTranslation::create([
                    'lab_observation_id' => $observation->id,
                    'language_id' => $this->lang[$code],
                    'text' => $obs[$code],
                ]);
            }
        }

        foreach ($data['products'] ?? [] as $idx => $prod) {
            $product = LabProduct::create([
                'lab_experiment_id' => $exp->id,
                'chemical_formula' => $prod['formula'],
                'state' => $prod['state'],
                'order_index' => $idx + 1,
            ]);

            foreach (['uz', 'ru', 'en'] as $code) {
                if (empty($this->lang[$code]) || empty($prod[$code])) {
                    continue;
                }
                LabProductTranslation::create([
                    'lab_product_id' => $product->id,
                    'language_id' => $this->lang[$code],
                    'name' => $prod[$code],
                ]);
            }
        }
    }
}

<?php

namespace Database\Seeders;

use App\Models\Lesson;
use App\Models\LessonLabItem;
use App\Models\LessonTranslation;
use Database\Seeders\Concerns\ForeignKeyGuard;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;

class LessonSeeder extends Seeder
{
    use ForeignKeyGuard;
    use SeedsTranslatableByLanguageCode;

    public function run(): void
    {
        $this->withoutForeignKeys(function () {
            LessonLabItem::truncate();
            Lesson::truncate();
            LessonTranslation::truncate();
        });

        $byCode = $this->languageIdsByCode();

        $lessons = [
            [
                'type' => 'theory',
                'order' => 1,
                'translations' => [
                    1 => ['title' => 'Atom tuzilishi', 'content' => '# Atom tuzilishi\n\nAtom — kimyoviy elementning barcha xossalarini oʻzida saqlab qoluvchi eng kichik zarrachasidir.'],
                    2 => ['title' => 'Строение атома', 'content' => '# Строение атома\n\nАтом — наименьшая частица химического элемента, сохраняющая все его химические свойства.'],
                    3 => ['title' => 'Atomic structure', 'content' => '# Atomic structure\n\nAn atom is the smallest unit of ordinary matter that forms a chemical element.'],
                ]
            ],
            [
                'type' => 'theory',
                'order' => 2,
                'translations' => [
                    1 => ['title' => 'Kimyoviy bog\'lanish', 'content' => '# Kimyoviy bog\'lanish\n\nKimyoviy bogʻlanish — atomlarning oʻzaro taʼsiri natijasida turgʻun koʻp atomli tizimlar (molekulalar, kristallar va boshqalar) hosil boʻlishi.'],
                    2 => ['title' => 'Химическая связь', 'content' => '# Химическая связь\n\nХимическая связь — это взаимодействие атомов, обуславливающее образование молекул или кристаллов.'],
                    3 => ['title' => 'Chemical bonding', 'content' => '# Chemical bonding\n\nA chemical bond is a lasting attraction between atoms, ions or molecules that enables the formation of chemical compounds.'],
                ]
            ],
            [
                'type' => 'theory',
                'order' => 3,
                'translations' => [
                    1 => ['title' => 'Valentlik', 'content' => '# Valentlik\n\nValentlik — kimyoviy element atomlarining boshqa element atomlarining maʼlum sonini oʻziga biriktirib olish xossasi.'],
                    2 => ['title' => 'Валентность', 'content' => '# Валентность\n\nВалентность — способность атомов химических элементов образовывать определённое число химических связей.'],
                    3 => ['title' => 'Valence', 'content' => '# Valence\n\nIn chemistry, the valence of an element is a measure of its combining capacity with other atoms when it forms chemical compounds.'],
                ]
            ],
            [
                'type' => 'theory',
                'order' => 4,
                'translations' => [
                    1 => ['title' => 'Oksidlanish darajasi', 'content' => '# Oksidlanish darajasi\n\nOksidlanish darajasi — birikmadagi atomning shartli zaryadi.'],
                    2 => ['title' => 'Степень окисления', 'content' => '# Степень окисления\n\nСтепень окисления — вспомогательная величина для учёта распределения электронов в молекуле.'],
                    3 => ['title' => 'Oxidation state', 'content' => '# Oxidation state\n\nThe oxidation state, sometimes referred to as oxidation number, describes the degree of oxidation of an atom.'],
                ]
            ],
            [
                'type' => 'theory',
                'order' => 5,
                'translations' => [
                    1 => ['title' => 'Kislotalar', 'content' => '# Kislotalar\n\nKislotalar — tarkibida metall atomlariga almashina oladigan vodorod atomlari va kislota qoldigʻidan iborat murakkab moddalar.'],
                    2 => ['title' => 'Кислоты', 'content' => '# Кислоты\n\nКислоты — сложные вещества, в состав которых входят атомы водорода и кислотный остаток.'],
                    3 => ['title' => 'Acids', 'content' => "# Acids\n\nAn acid is a molecule or ion capable of donating a proton."],
                ]
            ],
            [
                'type' => 'theory',
                'order' => 6,
                'translations' => [
                    1 => ['title' => 'Asoslar', 'content' => '# Asoslar\n\nAsoslar — tarkibida metall atomi va bitta yoki bir nechta gidroksil (OH) guruhlari boʻlgan murakkab moddalar.'],
                    2 => ['title' => 'Основания', 'content' => '# Основания\n\nОснования — сложные вещества, состоящие из ионов металлов и связанных с ними одной или нескольких гидроксильных групп.'],
                    3 => ['title' => 'Bases', 'content' => '# Bases\n\nIn chemistry, there are three definitions in common use of the word base: Arrhenius bases, Brønsted bases, and Lewis bases.'],
                ]
            ],
            [
                'type' => 'theory',
                'order' => 7,
                'translations' => [
                    1 => ['title' => 'Tuzlar', 'content' => '# Tuzlar\n\nTuzlar — tarkibi metall atomlari va kislota qoldiqlaridan iborat boʻlgan murakkab moddalar.'],
                    2 => ['title' => 'Соли', 'content' => '# Соли\n\nСоли — сложные вещества, которые состоят из катионов металлов и анионов кислотных остатков.'],
                    3 => ['title' => 'Salts', 'content' => '# Salts\n\nIn chemistry, a salt is a chemical compound consisting of an ionic assembly of a positive ion and a negative ion.'],
                ]
            ],
            [
                'type' => 'theory',
                'order' => 8,
                'translations' => [
                    1 => ['title' => 'Oksidlar', 'content' => '# Oksidlar\n\nOksidlar — ikki elementdan tashkil topgan, biri kislorod boʻlgan murakkab moddalar.'],
                    2 => ['title' => 'Оксиды', 'content' => '# Оксиды\n\nОксиды — бинарные соединения химического элемента с кислородом в степени окисления −2.'],
                    3 => ['title' => 'Oxides', 'content' => '# Oxides\n\nAn oxide is a chemical compound that contains at least one oxygen atom and one other element in its chemical formula.'],
                ]
            ],
            [
                'type' => 'theory',
                'order' => 9,
                'translations' => [
                    1 => ['title' => 'Elektrolitik dissotsiatsiya', 'content' => '# Elektrolitik dissotsiatsiya\n\nElektrolitik dissotsiatsiya — eritmada yoki suyuqlanmada moddalarning ionlarga parchalanish jarayoni.'],
                    2 => ['title' => 'Электролитическая диссоциация', 'content' => '# Электролитическая диссоциация\n\nЭлектролитическая диссоциация — процесс распада электролита на ионы при его растворении или плавлении.'],
                    3 => ['title' => 'Electrolytic dissociation', 'content' => '# Electrolytic dissociation\n\nElectrolytic dissociation is the separation of a compound into its ions in the solution.'],
                ]
            ],
            // Laboratoriya: darslik 6–16 (to‘liq matn — LaboratoryLessons6Through16Data)
            ...LaboratoryLessons6Through16Data::entries(),
        ];

        foreach ($lessons as $l) {
            $lesson = Lesson::create([
                'type' => $l['type'],
                'order' => $l['order'],
                'is_active' => true,
            ]);

            $this->seedLessonTranslationRows($lesson, $l['translations'], $byCode);
        }
    }
}

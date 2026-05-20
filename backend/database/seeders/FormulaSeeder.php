<?php

namespace Database\Seeders;

use App\Models\Element;
use App\Models\Formula;
use App\Models\FormulaTranslation;
use Database\Seeders\Concerns\ForeignKeyGuard;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class FormulaSeeder extends Seeder
{
    use ForeignKeyGuard;
    use SeedsTranslatableByLanguageCode;

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->withoutForeignKeys(function () {
            Formula::truncate();
            FormulaTranslation::truncate();
            DB::table('element_formula')->truncate();
        });

        $byCode = $this->languageIdsByCode();

        $elements = Element::all()->keyBy('symbol');

        $formulas = [
            // Popular Formulas
            [
                'formula' => 'H2O',
                'molar_mass' => 18.015,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Suv'],
                    2 => ['name' => 'Вода'],
                    3 => ['name' => 'Water'],
                    4 => ['name' => 'Suw'],
                ],
                'elements' => [
                    'H' => 2,
                    'O' => 1,
                ]
            ],
            [
                'formula' => 'NaCl',
                'molar_mass' => 58.443,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Osh tuzi'],
                    2 => ['name' => 'Поваренная соль'],
                    3 => ['name' => 'Table salt'],
                    4 => ['name' => 'As tuzi'],
                ],
                'elements' => [
                    'Na' => 1,
                    'Cl' => 1,
                ]
            ],
            [
                'formula' => 'CO2',
                'molar_mass' => 44.01,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Karbonat angidrid'],
                    2 => ['name' => 'Углекислый газ'],
                    3 => ['name' => 'Carbon dioxide'],
                    4 => ['name' => 'Komir kishkıl gazı'],
                ],
                'elements' => [
                    'C' => 1,
                    'O' => 2,
                ]
            ],
            [
                'formula' => 'H2SO4',
                'molar_mass' => 98.079,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Sulfat kislota'],
                    2 => ['name' => 'Серная кислота'],
                    3 => ['name' => 'Sulfuric acid'],
                    4 => ['name' => 'Sulfat kislotası'],
                ],
                'elements' => [
                    'H' => 2,
                    'S' => 1,
                    'O' => 4,
                ]
            ],
            [
                'formula' => 'CaCO3',
                'molar_mass' => 100.086,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Kalsiy karbonat'],
                    2 => ['name' => 'Карбонат кальция'],
                    3 => ['name' => 'Calcium carbonate'],
                    4 => ['name' => 'Kalsiy karbonat'],
                ],
                'elements' => [
                    'Ca' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'NH3',
                'molar_mass' => 17.031,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Ammiak'],
                    2 => ['name' => 'Аммиак'],
                    3 => ['name' => 'Ammonia'],
                    4 => ['name' => 'Ammiak'],
                ],
                'elements' => [
                    'N' => 1,
                    'H' => 3,
                ]
            ],
            [
                'formula' => 'CH4',
                'molar_mass' => 16.043,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Metan'],
                    2 => ['name' => 'Метан'],
                    3 => ['name' => 'Methane'],
                    4 => ['name' => 'Metan'],
                ],
                'elements' => [
                    'C' => 1,
                    'H' => 4,
                ]
            ],
            [
                'formula' => 'C6H12O6',
                'molar_mass' => 180.156,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Glyukoza'],
                    2 => ['name' => 'Глюкоза'],
                    3 => ['name' => 'Glucose'],
                    4 => ['name' => 'Glyukoza'],
                ],
                'elements' => [
                    'C' => 6,
                    'H' => 12,
                    'O' => 6,
                ]
            ],
            [
                'formula' => 'HCl',
                'molar_mass' => 36.461,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Xlorid kislota'],
                    2 => ['name' => 'Хлороводородная кислота'],
                    3 => ['name' => 'Hydrochloric acid'],
                    4 => ['name' => 'Xlorid kislotası'],
                ],
                'elements' => [
                    'H' => 1,
                    'Cl' => 1,
                ]
            ],
            [
                'formula' => 'Ca(OH)2',
                'molar_mass' => 74.093,
                'category' => 'popular',
                'translations' => [
                    1 => ['name' => 'Kalsiy gidroksid (so\'ndirilgan ohak)'],
                    2 => ['name' => 'Гидроксид кальция (гашеная известь)'],
                    3 => ['name' => 'Calcium hydroxide (slaked lime)'],
                    4 => ['name' => 'Kalsiy gidroksid (jaǧılmış ohak)'],
                ],
                'elements' => [
                    'Ca' => 1,
                    'O' => 2,
                    'H' => 2,
                ]
            ],

            // Carbonates
            [
                'formula' => 'Na2CO3',
                'molar_mass' => 105.99,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Natriy karbonat'],
                    2 => ['name' => 'Карбонат натрия'],
                    3 => ['name' => 'Sodium carbonate'],
                    4 => ['name' => 'Natriy karbonat'],
                ],
                'elements' => [
                    'Na' => 2,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'K2CO3',
                'molar_mass' => 138.21,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Kaliy karbonat'],
                    2 => ['name' => 'Карбонат калия'],
                    3 => ['name' => 'Potassium carbonate'],
                    4 => ['name' => 'Kaliy karbonat'],
                ],
                'elements' => [
                    'K' => 2,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'Li2CO3',
                'molar_mass' => 73.89,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Litiy karbonat'],
                    2 => ['name' => 'Карбонат лития'],
                    3 => ['name' => 'Lithium carbonate'],
                    4 => ['name' => 'Litiy karbonat'],
                ],
                'elements' => [
                    'Li' => 2,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'MgCO3',
                'molar_mass' => 84.31,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Magniy karbonat'],
                    2 => ['name' => 'Карбонат магния'],
                    3 => ['name' => 'Magnesium carbonate'],
                    4 => ['name' => 'Magniy karbonat'],
                ],
                'elements' => [
                    'Mg' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'BaCO3',
                'molar_mass' => 197.34,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Bariy karbonat'],
                    2 => ['name' => 'Карбонат бария'],
                    3 => ['name' => 'Barium carbonate'],
                    4 => ['name' => 'Bariy karbonat'],
                ],
                'elements' => [
                    'Ba' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'SrCO3',
                'molar_mass' => 147.63,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Stronsiy karbonat'],
                    2 => ['name' => 'Карбонат стронция'],
                    3 => ['name' => 'Strontium carbonate'],
                    4 => ['name' => 'Stronsiy karbonat'],
                ],
                'elements' => [
                    'Sr' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'CuCO3',
                'molar_mass' => 123.55,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Mis karbonat'],
                    2 => ['name' => 'Карбонат меди'],
                    3 => ['name' => 'Copper carbonate'],
                    4 => ['name' => 'Mis karbonat'],
                ],
                'elements' => [
                    'Cu' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'ZnCO3',
                'molar_mass' => 125.39,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Rux karbonat'],
                    2 => ['name' => 'Карбонат цинка'],
                    3 => ['name' => 'Zinc carbonate'],
                    4 => ['name' => 'Rux karbonat'],
                ],
                'elements' => [
                    'Zn' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'FeCO3',
                'molar_mass' => 115.86,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Temir (II) karbonat'],
                    2 => ['name' => 'Карбонат железа (II)'],
                    3 => ['name' => 'Iron(II) carbonate'],
                    4 => ['name' => 'Temir (II) karbonat'],
                ],
                'elements' => [
                    'Fe' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'MnCO3',
                'molar_mass' => 114.95,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Marganes karbonat'],
                    2 => ['name' => 'Карбонат марганца'],
                    3 => ['name' => 'Manganese carbonate'],
                    4 => ['name' => 'Marganes karbonat'],
                ],
                'elements' => [
                    'Mn' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'PbCO3',
                'molar_mass' => 267.21,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Qo\'rg\'oshin karbonat'],
                    2 => ['name' => 'Карбонат свинца'],
                    3 => ['name' => 'Lead(II) carbonate'],
                    4 => ['name' => 'Qorgasın karbonat'],
                ],
                'elements' => [
                    'Pb' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => '(NH4)2CO3',
                'molar_mass' => 96.09,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Ammoniy karbonat'],
                    2 => ['name' => 'Карбонат аммония'],
                    3 => ['name' => 'Ammonium carbonate'],
                    4 => ['name' => 'Ammoniy karbonat'],
                ],
                'elements' => [
                    'N' => 2,
                    'H' => 8,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'NH4HCO3',
                'molar_mass' => 79.06,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Ammoniy gidrokarbonat'],
                    2 => ['name' => 'Гидрокарбонат аммония'],
                    3 => ['name' => 'Ammonium bicarbonate'],
                    4 => ['name' => 'Ammoniy gidrokarbonat'],
                ],
                'elements' => [
                    'N' => 1,
                    'H' => 5,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'NaHCO3',
                'molar_mass' => 84.01,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Natriy gidrokarbonat'],
                    2 => ['name' => 'Гидрокарбонат натрия'],
                    3 => ['name' => 'Sodium bicarbonate'],
                    4 => ['name' => 'Natriy gidrokarbonat'],
                ],
                'elements' => [
                    'Na' => 1,
                    'H' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'KHCO3',
                'molar_mass' => 100.12,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Kaliy gidrokarbonat'],
                    2 => ['name' => 'Гидрокарбонат калия'],
                    3 => ['name' => 'Potassium bicarbonate'],
                    4 => ['name' => 'Kaliy gidrokarbonat'],
                ],
                'elements' => [
                    'K' => 1,
                    'H' => 1,
                    'C' => 1,
                    'O' => 3,
                ]
            ],
            [
                'formula' => 'Ca(HCO3)2',
                'molar_mass' => 162.11,
                'category' => 'carbonate',
                'translations' => [
                    1 => ['name' => 'Kalsiy gidrokarbonat'],
                    2 => ['name' => 'Гидрокарбонат кальция'],
                    3 => ['name' => 'Calcium bicarbonate'],
                    4 => ['name' => 'Kalsiy gidrokarbonat'],
                ],
                'elements' => [
                    'Ca' => 1,
                    'H' => 2,
                    'C' => 2,
                    'O' => 6,
                ]
            ],
        ];

        foreach ($formulas as $f) {
            $formula = Formula::create([
                'formula' => $f['formula'],
                'molar_mass' => $f['molar_mass'],
                'category' => $f['category'],
            ]);

            $this->seedFormulaTranslationRows($formula, $f['translations'], $byCode);

            foreach ($f['elements'] as $symbol => $amount) {
                if (isset($elements[$symbol])) {
                    $formula->elements()->attach($elements[$symbol]->id, ['amount' => $amount]);
                }
            }
        }
    }
}

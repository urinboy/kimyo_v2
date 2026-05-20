<?php

namespace Database\Seeders;

use App\Models\ChemicalReactionSymbol;
use App\Models\ChemicalReactionType;
use Illuminate\Database\Seeder;

class ChemicalReactionSeeder extends Seeder
{
    public function run(): void
    {
        ChemicalReactionType::query()->delete();
        ChemicalReactionSymbol::query()->delete();

        foreach ($this->reactionTypes() as $row) {
            ChemicalReactionType::query()->create($row);
        }

        foreach ($this->reactionSymbols() as $row) {
            ChemicalReactionSymbol::query()->create($row);
        }
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function reactionTypes(): array
    {
        return [
            [
                'name_uz' => 'Birikish reaksiyasi',
                'name_ru' => 'Реакция соединения',
                'name_en' => 'Combination reaction',
                'name_kaa' => 'Birigesiw reakciyası',
                'formula' => 'A + B → AB',
                'description_uz' => 'Ikki yoki undan ko\'p modda birikib, bitta mahsulot(lar) hosil qiladi.',
                'description_ru' => 'Два или более веществ соединяются, образуя один (или несколько) продуктов.',
                'description_en' => 'Two or more substances combine to form one product (or products).',
                'description_kaa' => 'Eki yamasa onnan artıq zat birigesip, bir payda(nlar) hasıl qıládı.',
                'modal_formula' => 'A + B → AB',
                'modal_badge_uz' => null,
                'modal_badge_ru' => null,
                'modal_badge_en' => null,
                'modal_badge_kaa' => null,
                'examples' => [
                    '2Na + S → Na2S',
                    '2K + S → K2S',
                    '2Na + O2 → Na2O2',
                    '2Na + Cl2 → 2NaCl',
                    'Na2SO3 + S → Na2S2O3',
                ],
                'color_hex' => 'E8F5E9',
                'icon_color_hex' => '4CAF50',
                'order' => 1,
            ],
            [
                'name_uz' => 'Parchalanish reaksiyasi',
                'name_ru' => 'Реакция разложения',
                'name_en' => 'Decomposition reaction',
                'name_kaa' => 'Páshalanıw reakciyası',
                'formula' => 'AB → A + B',
                'description_uz' => 'Murakkab modda oddiyroq moddalarga parchalanadi.',
                'description_ru' => 'Сложное вещество распадается на более простые.',
                'description_en' => 'A complex substance decomposes into simpler substances.',
                'description_kaa' => 'Murakkap zat áddiirek zatlarga páshalanadı.',
                'modal_formula' => 'AB → A + B',
                'modal_badge_uz' => null,
                'modal_badge_ru' => null,
                'modal_badge_en' => null,
                'modal_badge_kaa' => null,
                'examples' => [
                    'NaHCO3 → Na2CO3 + CO2 + H2O',
                    'KNO3 → KNO2 + O2',
                    '2CaSO4 · 2H2O → (CaSO4)2 · H2O + 3H2O',
                ],
                'color_hex' => 'FFEBEE',
                'icon_color_hex' => 'E57373',
                'order' => 2,
            ],
            [
                'name_uz' => 'O\'rin olish reaksiyasi',
                'name_ru' => 'Реакция замещения',
                'name_en' => 'Substitution reaction',
                'name_kaa' => 'Orın alma reakciyası',
                'formula' => 'AB + C → AC + B',
                'description_uz' => 'Faol modda birikmadagi boshqa komponentni siqib chiqaradi (ko\'pincha redoks bilan birga bo\'ladi).',
                'description_ru' => 'Более активное вещество вытесняет менее активный компонент из соединения (часто сопровождается редокс-процессом).',
                'description_en' => 'A more active substance displaces another component in the compound (often together with redox).',
                'description_kaa' => 'Áktiv zat birikmedegi báshqa komponentti sıqıp shıǵaradı (ádsı Redoks menen birge).',
                'modal_formula' => 'AB + C → AC + B',
                'modal_badge_uz' => null,
                'modal_badge_ru' => null,
                'modal_badge_en' => null,
                'modal_badge_kaa' => null,
                'examples' => [
                    'CCl4 + 4Na → 4NaCl + C',
                    '2H2O + Na → NaOH + H2',
                    '2K + 2HCl → 2KCl + H2',
                    '2Na + C2H5OH → C2H5ONa + H2',
                    '2K + C2H5OH → C2H5OK + H2',
                    'KF + CaC2 → K + C + CaF2',
                ],
                'color_hex' => 'FFF3E0',
                'icon_color_hex' => 'FFA726',
                'order' => 3,
            ],
            [
                'name_uz' => 'Almashinish reaksiyasi',
                'name_ru' => 'Реакция обмена',
                'name_en' => 'Double displacement',
                'name_kaa' => 'Almásınıw reakciyası',
                'formula' => 'AB + CD → AD + CB',
                'description_uz' => 'Ikki birikma orasida ionlar (yoki guruhlar) o\'rin almashadi.',
                'description_ru' => 'Между двумя соединениями обмениваются ионы (или группы).',
                'description_en' => 'Ions (or groups) are exchanged between two compounds.',
                'description_kaa' => 'Eki birikme arasında ionlar (yamasa toparlar) orın almasadı.',
                'modal_formula' => 'AB + CD → AD + CB',
                'modal_badge_uz' => null,
                'modal_badge_ru' => null,
                'modal_badge_en' => null,
                'modal_badge_kaa' => null,
                'examples' => [
                    '2NaCl + H2SO4 → Na2SO4 + 2HCl',
                    'NaCl + H2SO4 → NaHSO4 + HCl',
                    'NH4HCO3 + NaCl → NaHCO3 + NH4Cl',
                    'Na2CO3 + Ca(OH)2 → CaCO3 + NaOH',
                    'NaNO3 + KOH → NaOH + KNO3',
                    'KCl + NaNO3 → KNO3 + NaCl',
                    'KOH + HNO3 → KNO3 + H2O',
                    '2KNO3 + H2SO4 → K2SO4 + 2HNO3',
                    'KCl + MgSO4 → K2SO4 + MgCl2',
                    'FeCl3 + KOH → Fe(OH)3 + KCl',
                ],
                'color_hex' => 'E3F2FD',
                'icon_color_hex' => '42A5F5',
                'order' => 4,
            ],
            [
                'name_uz' => 'Oksidlanish-kaytarilish (Redoks)',
                'name_ru' => 'Окислительно-восстановительная (редокс)',
                'name_en' => 'Redox reaction',
                'name_kaa' => 'Oksidlanıw-kaytarılıw (Redoks)',
                'formula' => 'Elektron almashinuvi',
                'description_uz' => 'Elektronlar bir modda(lar)dan boshqasiga o\'tadi (oksidlanish va qaytarilish birga ketadi).',
                'description_ru' => 'Электроны переходят от одних веществ к другим (окисление и восстановление протекают совместно).',
                'description_en' => 'Electrons move from one substance to another (oxidation and reduction occur together).',
                'description_kaa' => 'Elektronlar bir zat(tlar)dan basqasına ótedi (oksidlanıw hám kaytarılıw birge ketedi).',
                'modal_formula' => null,
                'modal_badge_uz' => 'Elektron almashinuvi',
                'modal_badge_ru' => 'Обмен электронами',
                'modal_badge_en' => 'Electron transfer',
                'modal_badge_kaa' => 'Elektron almásınıwı',
                'examples' => [
                    '2NaCl + 2H2O → 2NaOH + H2 + Cl2',
                    'Na2O2 + 2H2O → 2NaOH + H2O2',
                    'Na2S2O3 + Cl2 + H2O → Na2SO4 + H2SO4 + HCl',
                    'KMnO4 + NaNO3 + H2O → MnO2 + NaNO3 + KOH',
                    '2KMnO4 + 16HCl → 2KCl + 2MnCl2 + 5Cl2 + 8H2O',
                    'Cu + 2H2SO4(kons) → CuSO4 + SO2 + 2H2O',
                ],
                'color_hex' => 'F3E5F5',
                'icon_color_hex' => 'AB47BC',
                'order' => 5,
            ],
            [
                'name_uz' => 'Yonish reaksiyasi',
                'name_ru' => 'Реакция горения',
                'name_en' => 'Combustion reaction',
                'name_kaa' => 'Yanğıw reakciyası',
                'formula' => 'Modda + O2 → ... + Issiqlik',
                'description_uz' => 'Moddaning kislorod bilan reaksiyasi; issiqlik (va ba\'zan yorug\'lik) ajraladi.',
                'description_ru' => 'Реакция вещества с кислородом; выделяется тепло (и иногда свет).',
                'description_en' => 'Reaction of a substance with oxygen; heat (and sometimes light) is released.',
                'description_kaa' => 'Zattıń kislorod menen reakciyası; issıqlıq (hám bazan yarıqlıq) ajraladı.',
                'modal_formula' => 'Modda + O2 → ... + Issiqlik',
                'modal_badge_uz' => null,
                'modal_badge_ru' => null,
                'modal_badge_en' => null,
                'modal_badge_kaa' => null,
                'examples' => [
                    'HCOOK + O2 → K2CO3 + CO2 + H2O',
                    'CH4 + 2O2 → CO2 + 2H2O',
                    'C2H5OH + 3O2 → 2CO2 + 3H2O',
                ],
                'color_hex' => 'FFEBE0',
                'icon_color_hex' => 'FF7043',
                'order' => 6,
            ],
        ];
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function reactionSymbols(): array
    {
        return [
            [
                'symbol' => '→',
                'desc_uz' => 'Reaksiya yo\'nalishi',
                'desc_ru' => 'Направление реакции',
                'desc_en' => 'Reaction direction',
                'desc_kaa' => 'Reakciya yónelis',
                'order' => 1,
            ],
            [
                'symbol' => '⇄',
                'desc_uz' => 'Qaytimli reaksiya',
                'desc_ru' => 'Обратимая реакция',
                'desc_en' => 'Reversible reaction',
                'desc_kaa' => 'Qaytıwlı reakciya',
                'order' => 2,
            ],
            [
                'symbol' => '↑',
                'desc_uz' => 'Gaz ajralib chiqadi',
                'desc_ru' => 'Выделение газа',
                'desc_en' => 'Gas evolution',
                'desc_kaa' => 'Gaz ajralıb shıgadı',
                'order' => 3,
            ],
            [
                'symbol' => '↓',
                'desc_uz' => 'Cho\'kma hosil bo\'ladi',
                'desc_ru' => 'Образование осадка',
                'desc_en' => 'Precipitation',
                'desc_kaa' => 'Túyin payda boladı',
                'order' => 4,
            ],
            [
                'symbol' => 'Δ',
                'desc_uz' => 'Isitish zarur',
                'desc_ru' => 'Нагревание',
                'desc_en' => 'Heating required',
                'desc_kaa' => 'Qızıw kerek',
                'order' => 5,
            ],
            [
                'symbol' => '+',
                'desc_uz' => 'Moddalar qo\'shiladi',
                'desc_ru' => 'Сложение веществ',
                'desc_en' => 'Addition of substances',
                'desc_kaa' => 'Zatlar qosiladı',
                'order' => 6,
            ],
            [
                'symbol' => '(k)',
                'desc_uz' => 'Katalizator',
                'desc_ru' => 'Катализатор',
                'desc_en' => 'Catalyst',
                'desc_kaa' => 'Katalizator',
                'order' => 7,
            ],
        ];
    }
}

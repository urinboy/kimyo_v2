<?php

namespace Database\Seeders;

use App\Models\Lesson;
use Database\Seeders\Concerns\ForeignKeyGuard;
use Database\Seeders\Concerns\SeedsTranslatableByLanguageCode;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * 4 ta kimyo mavzusi uchun nazariy darslar (order 10–13):
 *  10. Ishqoriy metallar
 *  11. Soda ishlab chiqarish
 *  12. Kalsiy va magniy
 *  13. Temir
 */
class ChemistryTopicsTheorySeeder extends Seeder
{
    use ForeignKeyGuard;
    use SeedsTranslatableByLanguageCode;

    private const ORDERS = [10, 11, 12, 13];

    public function run(): void
    {
        $byCode = $this->languageIdsByCode();

        $this->withoutForeignKeys(function () {
            // Faqat shu 4 ta darsni yangilash
            $ids = DB::table('lessons')
                ->where('type', 'theory')
                ->whereIn('order', self::ORDERS)
                ->pluck('id');
            if ($ids->isNotEmpty()) {
                DB::table('lesson_translations')->whereIn('lesson_id', $ids)->delete();
                DB::table('lessons')->whereIn('id', $ids)->delete();
            }
        });

        foreach ($this->lessons() as $l) {
            $lesson = Lesson::create([
                'type'      => 'theory',
                'order'     => $l['order'],
                'is_active' => true,
            ]);
            $this->seedLessonTranslationRows($lesson, $l['translations'], $byCode);
        }
    }

    // -------------------------------------------------------------------------

    private function lessons(): array
    {
        return [
            // ================================================================
            // 10. ISHQORIY METALLAR
            // ================================================================
            [
                'order' => 10,
                'translations' => [
                    1 => [
                        'title'   => 'Ishqoriy metallar',
                        'content' => <<<'MD'
# Ishqoriy metallar

Litiy (Li), natriy (Na), kaliy (K), rubidiy (Rb), seziy (Cs) va fransiy (Fr) elementlari **ishqoriy metallar** deb ataladi. Ular davriy sistemaning **I guruh** bosh guruhchasini tashkil etadi.

"Ishqoriy metallar" atamasi ularning gidroksidlari kuchli ishqoriy (o'yuvchi) xossalarga ega ekanligi bilan bog'liq.

---

## Muhim birikmalari

| Birikma | Formula | Qoraqalpog'istondagi tarqalishi |
|---|---|---|
| Tosh tuzi | NaCl | Qarawimbet, Borsakelmas, Oqtuba, Sariqko'l, Orol dengizi havzasi |
| Glauber tuzi | Na₂SO₄·10H₂O | Orol dengizining qurib qolgan qismi, Qorao'zak tumani ko'llari |
| Chili selitrasi | NaNO₃ | Chirchiq, Navoiy, Farg'ona zavodlarida ishlab chiqariladi |
| Silvinit | KCl·NaCl | Qarawimbet, Borsakelmas, Tubokat, Boybichakon, Oqqal'a konlari |
| Hind selitrasi | KNO₃ | — |
| Karnallit | KCl·MgCl₂·6H₂O | Surxondaryo, Tyubegatan koni |

---

## Kimyoviy reaksiyalar

$$2\text{NaCl} + \text{H}_2\text{SO}_4 \rightarrow \text{Na}_2\text{SO}_4 + 2\text{HCl}$$

$$\text{Na}_2\text{SO}_4 + 2\text{C} \rightarrow \text{Na}_2\text{S} + 2\text{CO}_2$$

$$\text{Na}_2\text{S} + \text{CaCO}_3 \rightarrow \text{Na}_2\text{CO}_3 + \text{CaS}$$
MD,
                    ],
                    2 => [
                        'title'   => 'Щелочные металлы',
                        'content' => <<<'MD'
# Щелочные металлы

Литий (Li), натрий (Na), калий (K), рубидий (Rb), цезий (Cs) и франций (Fr) называются **щелочными металлами**. Они образуют **I группу** главной подгруппы периодической системы.

Название "щелочные металлы" связано с тем, что их гидроксиды обладают сильными щелочными (едкими) свойствами.

---

## Важные соединения

| Соединение | Формула | Месторождения |
|---|---|---|
| Поваренная соль | NaCl | Каравимбет, Барсакельмес, Актуба, Сарыкуль, бассейн Аральского моря |
| Глауберова соль | Na₂SO₄·10H₂O | Высохшая часть Арала, озёра Каракалпакстана |
| Чилийская селитра | NaNO₃ | Производится на заводах Чирчика, Навои, Ферганы |
| Сильвинит | KCl·NaCl | Каравимбет, Барсакельмес, Тубекат, Байбичакон, Аккала |
| Индийская селитра | KNO₃ | — |
| Карналлит | KCl·MgCl₂·6H₂O | Сурхандарья, месторождение Тюбегатан |

---

## Химические реакции

$$2\text{NaCl} + \text{H}_2\text{SO}_4 \rightarrow \text{Na}_2\text{SO}_4 + 2\text{HCl}$$

$$\text{Na}_2\text{SO}_4 + 2\text{C} \rightarrow \text{Na}_2\text{S} + 2\text{CO}_2$$

$$\text{Na}_2\text{S} + \text{CaCO}_3 \rightarrow \text{Na}_2\text{CO}_3 + \text{CaS}$$
MD,
                    ],
                    3 => [
                        'title'   => 'Alkali metals',
                        'content' => <<<'MD'
# Alkali metals

Lithium (Li), sodium (Na), potassium (K), rubidium (Rb), cesium (Cs) and francium (Fr) are called **alkali metals**. They form the **Group I** main subgroup of the periodic table.

The name "alkali metals" is related to the fact that their hydroxides have strong alkaline (caustic) properties.

---

## Key compounds

| Compound | Formula | Occurrence in Karakalpakstan |
|---|---|---|
| Rock salt | NaCl | Karavimbet, Barsakelmes, Aktuba, Sarykol, Aral Sea basin |
| Glauber's salt | Na₂SO₄·10H₂O | Dried Aral Sea, lakes of Karakalpakstan |
| Chilean saltpetre | NaNO₃ | Produced at Chirchiq, Navoi, Fergana plants |
| Sylvinite | KCl·NaCl | Karavimbet, Barsakelmes, Tubekat, Baybichakon, Oqqala |
| Indian saltpetre | KNO₃ | — |
| Carnallite | KCl·MgCl₂·6H₂O | Surkhandarya, Tyubegatan deposit |

---

## Chemical reactions

$$2\text{NaCl} + \text{H}_2\text{SO}_4 \rightarrow \text{Na}_2\text{SO}_4 + 2\text{HCl}$$

$$\text{Na}_2\text{SO}_4 + 2\text{C} \rightarrow \text{Na}_2\text{S} + 2\text{CO}_2$$

$$\text{Na}_2\text{S} + \text{CaCO}_3 \rightarrow \text{Na}_2\text{CO}_3 + \text{CaS}$$
MD,
                    ],
                ],
            ],

            // ================================================================
            // 11. SODA ISHLAB CHIQARISH
            // ================================================================
            [
                'order' => 11,
                'translations' => [
                    1 => [
                        'title'   => 'Soda ishlab chiqarish',
                        'content' => <<<'MD'
# Soda ishlab chiqarish

**Soda (Na₂CO₃)** ishlab chiqarishda eng keng tarqalgan usul — **Solvay (ammiakli) usuli**.

---

## Asosiy xomashyolar

- Osh tuzi **(NaCl)**
- Ohaktosh **(CaCO₃)**
- Ammiak **(NH₃)**
- Suv **(H₂O)**
- Karbonat angidrid **(CO₂)**

> Asosiy xomashyolar Qoraqalpog'iston Respublikasidagi **Barsakelmes tuz koni** va **Jamansoy ohaktosh konidan** olinadi.
> **Qo'ng'irot soda zavodi**da soda ishlab chiqarish ammiakli (Solvay) usul asosida amalga oshiriladi.

---

## Jarayon reaksiyalari

$$2\text{NH}_4\text{Cl} + \text{Ca(OH)}_2 \rightarrow 2\text{NH}_3 + \text{CaCl}_2 + 2\text{H}_2\text{O}$$

$$\text{NH}_3 + \text{CO}_2 + \text{H}_2\text{O} \rightarrow \text{NH}_4\text{HCO}_3$$

$$\text{NH}_4\text{HCO}_3 + \text{NaCl} \rightarrow \text{NaHCO}_3 + \text{NH}_4\text{Cl}$$

$$2\text{NaHCO}_3 \xrightarrow{\Delta} \text{Na}_2\text{CO}_3 + \text{CO}_2 + \text{H}_2\text{O}$$
MD,
                    ],
                    2 => [
                        'title'   => 'Производство соды',
                        'content' => <<<'MD'
# Производство соды

При производстве **соды (Na₂CO₃)** наиболее широко применяется **аммиачный (Сольвеевский) способ**.

---

## Основное сырьё

- Поваренная соль **(NaCl)**
- Известняк **(CaCO₃)**
- Аммиак **(NH₃)**
- Вода **(H₂O)**
- Углекислый газ **(CO₂)**

> Основное сырьё добывается на **Барсакельмесском соляном месторождении** и **Жамансайском известняковом месторождении** в Каракалпакстане.
> На **Кунградском содовом заводе** производство соды осуществляется аммиачным (Сольвеевским) методом.

---

## Реакции процесса

$$2\text{NH}_4\text{Cl} + \text{Ca(OH)}_2 \rightarrow 2\text{NH}_3 + \text{CaCl}_2 + 2\text{H}_2\text{O}$$

$$\text{NH}_3 + \text{CO}_2 + \text{H}_2\text{O} \rightarrow \text{NH}_4\text{HCO}_3$$

$$\text{NH}_4\text{HCO}_3 + \text{NaCl} \rightarrow \text{NaHCO}_3 + \text{NH}_4\text{Cl}$$

$$2\text{NaHCO}_3 \xrightarrow{\Delta} \text{Na}_2\text{CO}_3 + \text{CO}_2 + \text{H}_2\text{O}$$
MD,
                    ],
                    3 => [
                        'title'   => 'Soda production',
                        'content' => <<<'MD'
# Soda production

The most widely used method for producing **soda (Na₂CO₃)** is the **Solvay (ammonia-soda) process**.

---

## Main raw materials

- Table salt **(NaCl)**
- Limestone **(CaCO₃)**
- Ammonia **(NH₃)**
- Water **(H₂O)**
- Carbon dioxide **(CO₂)**

> The main raw materials are sourced from the **Barsakelmes salt deposit** and **Jamansoy limestone deposit** in Karakalpakstan.
> The **Kungrad Soda Plant** produces soda using the Solvay (ammonia) method.

---

## Process reactions

$$2\text{NH}_4\text{Cl} + \text{Ca(OH)}_2 \rightarrow 2\text{NH}_3 + \text{CaCl}_2 + 2\text{H}_2\text{O}$$

$$\text{NH}_3 + \text{CO}_2 + \text{H}_2\text{O} \rightarrow \text{NH}_4\text{HCO}_3$$

$$\text{NH}_4\text{HCO}_3 + \text{NaCl} \rightarrow \text{NaHCO}_3 + \text{NH}_4\text{Cl}$$

$$2\text{NaHCO}_3 \xrightarrow{\Delta} \text{Na}_2\text{CO}_3 + \text{CO}_2 + \text{H}_2\text{O}$$
MD,
                    ],
                ],
            ],

            // ================================================================
            // 12. KALSIY VA MAGNIY
            // ================================================================
            [
                'order' => 12,
                'translations' => [
                    1 => [
                        'title'   => 'Kalsiy va magniy',
                        'content' => <<<'MD'
# Kalsiy va magniy

**Kalsiy (Ca)** va **magniy (Mg)** — davriy sistemaning II guruhiga mansub ishqoriy yer metallari.

---

## Muhim birikmalari va konlari

### Ohaktosh, bo'r, marmar — CaCO₃
Qoraqalpog'istonda bu qurilish materiallari asosan **Ustyurt platosi** va **Sulton Uvays tog'lari** hududlarida tarqalgan. Eng yirik marmar konlaridan biri — **Qaxralisoy** (yillik qazib olish ~1 ming m³).

### Gips va alabaster — CaSO₄·nH₂O
- Gips: **CaSO₄·2H₂O**
- Alabaster: **CaSO₄·0,5H₂O**

Konlari suvi qurigan ko'l va dengiz havzalarida sulfat tuzlarning cho'kishi natijasida hosil bo'ladi.

### Apatit va ftorapatit
- Apatit: **Ca₃(PO₄)₂**
- Ftorapatit: **Ca₅(PO₄)₃F**

Asosan Qozog'istonning **Qoratog' hududi**da joylashgan.

### Dolomit — CaMg(CO₃)₂

| Ko'rsatkich | Qiymat |
|---|---|
| Kalsiy (Ca) | ~30,4% |
| Magniy (Mg) | ~21,7% |
| Aralashmalar | Temir, marganets |

Qoraqalpog'istonda **Jamansoy konidan** qazib olinadi. Soda va sement ishlab chiqarish uchun muhim xomashyo.
MD,
                    ],
                    2 => [
                        'title'   => 'Кальций и магний',
                        'content' => <<<'MD'
# Кальций и магний

**Кальций (Ca)** и **магний (Mg)** — щёлочноземельные металлы, входящие во II группу периодической системы.

---

## Важные соединения и месторождения

### Известняк, мел, мрамор — CaCO₃
В Каракалпакстане эти строительные материалы распространены в районе **плато Устюрт** и **гор Султан Увайс**. Одно из крупнейших месторождений мрамора — **Кахралисой** (~1 тыс. м³/год).

### Гипс и алебастр — CaSO₄·nH₂O
- Гипс: **CaSO₄·2H₂O**
- Алебастр: **CaSO₄·0,5H₂O**

Месторождения образуются при осаждении сульфатных солей в высохших озёрных и морских бассейнах.

### Апатит и фторапатит
- Апатит: **Ca₃(PO₄)₂**
- Фторапатит: **Ca₅(PO₄)₃F**

Расположены преимущественно в районе **Каратау** в Казахстане.

### Доломит — CaMg(CO₃)₂

| Показатель | Значение |
|---|---|
| Кальций (Ca) | ~30,4% |
| Магний (Mg) | ~21,7% |
| Примеси | железо, марганец |

В Каракалпакстане добывается на **Жамансайском месторождении**. Важное сырьё для производства соды и цемента.
MD,
                    ],
                    3 => [
                        'title'   => 'Calcium and magnesium',
                        'content' => <<<'MD'
# Calcium and magnesium

**Calcium (Ca)** and **magnesium (Mg)** are alkaline earth metals belonging to Group II of the periodic table.

---

## Key compounds and deposits

### Limestone, chalk, marble — CaCO₃
In Karakalpakstan, these construction materials are mainly found in the **Ustyurt Plateau** and **Sultan Uvays Mountains** areas. One of the largest marble deposits is **Qahralisoy** (~1,000 m³/year output).

### Gypsum and alabaster — CaSO₄·nH₂O
- Gypsum: **CaSO₄·2H₂O**
- Alabaster: **CaSO₄·0.5H₂O**

Deposits form by precipitation of sulfate salts in dried-up lake and sea basins.

### Apatite and fluorapatite
- Apatite: **Ca₃(PO₄)₂**
- Fluorapatite: **Ca₅(PO₄)₃F**

Located mainly in the **Karatau region** of Kazakhstan.

### Dolomite — CaMg(CO₃)₂

| Indicator | Value |
|---|---|
| Calcium (Ca) | ~30.4% |
| Magnesium (Mg) | ~21.7% |
| Impurities | iron, manganese |

In Karakalpakstan, it is mined at the **Jamansoy deposit** — an important raw material for soda and cement production.
MD,
                    ],
                ],
            ],

            // ================================================================
            // 13. TEMIR
            // ================================================================
            [
                'order' => 13,
                'translations' => [
                    1 => [
                        'title'   => 'Temir',
                        'content' => <<<'MD'
# Temir

**Temir (Fe)** — davriy sistemaning VIII guruhiga mansub o'tish metall. Yer qobig'ida tarqalish bo'yicha metallar orasida ikkinchi o'rinni egallaydi.

---

## Tebinbuloq koni

**Tebinbuloq** — Qoraqalpog'istondagi eng yirik **titanomagnetitli temir rudasi koni**.

| Ko'rsatkich | Ma'lumot |
|---|---|
| Joylashuvi | Qorao'zak tumani, Sulton Uvays tog'lari |
| Ruda turi | Titanomagnetit |
| Asosiy minerallar | Magnetit, ilmenit |
| Temir (Fe) miqdori | ≈ 12–16% |
| Titan oksidi (TiO₂) | ≈ 2% |
| Vanadiy oksidi (V₂O₅) | ≈ 0,15% |
| Umumiy zaxira | 1–2 milliard tonna va undan ortiq |

> Tebinbuloq — O'zbekistondagi **eng yirik temir konlaridan biri**.
> Ushbu kon asosida **kon-metallurgiya kompleksi** qurilmoqda.

---

## Muhim xossalari

- Sof holda kumushsimon-oq metall
- Magnit xossalariga ega
- Namlik va kislorod ta'sirida **zanglanadi** (Fe₂O₃·nH₂O)
- Qotishmalar: **po'lat** (C < 2%) va **cho'yan** (C > 2%)

---

## Reaksiyalar

$$3\text{Fe} + 4\text{H}_2\text{O} \xrightarrow{t°} \text{Fe}_3\text{O}_4 + 4\text{H}_2$$

$$\text{Fe} + \text{CuSO}_4 \rightarrow \text{FeSO}_4 + \text{Cu}$$

$$2\text{Fe}_2\text{O}_3 + 3\text{C} \xrightarrow{t°} 4\text{Fe} + 3\text{CO}_2$$
MD,
                    ],
                    2 => [
                        'title'   => 'Железо',
                        'content' => <<<'MD'
# Железо

**Железо (Fe)** — переходный металл VIII группы периодической системы. По распространённости среди металлов в земной коре занимает второе место.

---

## Месторождение Тебинбулак

**Тебинбулак** — крупнейшее **титаномагнетитовое месторождение железной руды** в Каракалпакстане.

| Показатель | Данные |
|---|---|
| Расположение | Каракалпакстан, Каратегин, горы Султан Увайс |
| Тип руды | Титаномагнетит |
| Основные минералы | Магнетит, ильменит |
| Содержание Fe | ≈ 12–16% |
| TiO₂ | ≈ 2% |
| V₂O₅ | ≈ 0,15% |
| Общие запасы | 1–2 млрд тонн и более |

> Тебинбулак — одно из **крупнейших железорудных месторождений Узбекистана**.
> На базе месторождения строится **горно-металлургический комплекс**.

---

## Важные свойства

- В чистом виде — серебристо-белый металл
- Обладает магнитными свойствами
- Ржавеет при воздействии влаги и кислорода (Fe₂O₃·nH₂O)
- Сплавы: **сталь** (C < 2%) и **чугун** (C > 2%)

---

## Реакции

$$3\text{Fe} + 4\text{H}_2\text{O} \xrightarrow{t°} \text{Fe}_3\text{O}_4 + 4\text{H}_2$$

$$\text{Fe} + \text{CuSO}_4 \rightarrow \text{FeSO}_4 + \text{Cu}$$

$$2\text{Fe}_2\text{O}_3 + 3\text{C} \xrightarrow{t°} 4\text{Fe} + 3\text{CO}_2$$
MD,
                    ],
                    3 => [
                        'title'   => 'Iron',
                        'content' => <<<'MD'
# Iron

**Iron (Fe)** is a transition metal in Group VIII of the periodic table. It ranks second among metals in terms of abundance in the Earth's crust.

---

## Tebinbulaq deposit

**Tebinbulaq** is the largest **titanomagnetite iron ore deposit** in Karakalpakstan.

| Indicator | Data |
|---|---|
| Location | Karakalpakstan, Qarauzyak district, Sultan Uvays Mountains |
| Ore type | Titanomagnetite |
| Main minerals | Magnetite, ilmenite |
| Iron (Fe) content | ≈ 12–16% |
| Titanium dioxide (TiO₂) | ≈ 2% |
| Vanadium pentoxide (V₂O₅) | ≈ 0.15% |
| Total reserves | 1–2 billion tonnes and more |

> Tebinbulaq is one of the **largest iron ore deposits in Uzbekistan**.
> A **mining and metallurgical complex** is being built based on this deposit.

---

## Key properties

- Pure form: silvery-white metal
- Has magnetic properties
- Rusts in the presence of moisture and oxygen (Fe₂O₃·nH₂O)
- Alloys: **steel** (C < 2%) and **cast iron** (C > 2%)

---

## Reactions

$$3\text{Fe} + 4\text{H}_2\text{O} \xrightarrow{t°} \text{Fe}_3\text{O}_4 + 4\text{H}_2$$

$$\text{Fe} + \text{CuSO}_4 \rightarrow \text{FeSO}_4 + \text{Cu}$$

$$2\text{Fe}_2\text{O}_3 + 3\text{C} \xrightarrow{t°} 4\text{Fe} + 3\text{CO}_2$$
MD,
                    ],
                ],
            ],
        ];
    }
}

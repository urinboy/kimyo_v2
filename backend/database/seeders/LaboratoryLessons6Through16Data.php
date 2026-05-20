<?php

namespace Database\Seeders;

/**
 * Darslik bo‘yicha 6–16-laboratoriya ishlari — mobil ilova uchun to‘liq matn (Markdown).
 */
final class LaboratoryLessons6Through16Data
{
    /**
     * @return list<array{type: string, order: int, translations: array<int, array{title: string, content: string}>}>
     */
    public static function entries(): array
    {
        return [
            self::lab6(),
            self::lab7(),
            self::lab8(),
            self::lab9(),
            self::lab10(),
            self::lab11(),
            self::lab12(),
            self::lab13(),
            self::lab14(),
            self::lab15(),
            self::lab16(),
        ];
    }

    private static function lab6(): array
    {
        return [
            'type' => 'lab',
            'order' => 1,
            'translations' => [
                1 => [
                    'title' => '6. Tuzlar eritmalari bilan metallarning o‘zaro ta’siri',
                    'content' => <<<'UZ'
# 6-laboratoriya ishi

## Tuzlar eritmalari bilan metallarning o‘zaro ta’siri

### Tajriba

1. Birinchi probirkaga kumush (I)-nitrat, ikkinchi probirkaga mis (II)-sulfat, uchinchisiga qoʻrgʻoshin (II)-nitrat eritmasidan 2–3 ml quying. Birinchi probirkaga mis simi, ikkinchisiga temir kukunlari, uchinchisiga mis kukunlaridan soling.

2. Har bir probirkada qanday moddalar hosil boʻldi? Tegishli reaksiyalarning molekular, toʻliq va qisqa ionli tenglamalarini yozing.

**Eslatma:** `AgNO₃`, `CuSO₄`, `Pb(NO₃)₂` eritmalari va `Cu` simi/kukuni, `Fe` kukuni ishlatiladi.
UZ,
                ],
                2 => [
                    'title' => '6. Взаимодействие металлов с растворами солей',
                    'content' => <<<'RU'
# Лабораторная работа 6

## Взаимодействие металлов с растворами солей

### Ход работы

1. В первую пробирку налейте 2–3 мл нитрата серебра(I), во вторую — сульфата меди(II), в третью — нитрата свинца(II). В первую поместите медную проволоку, во вторую — порошок железа, в третью — порошок меди.

2. Какие вещества образуются в каждой пробирке? Запишите молекулярные, полные и сокращённые ионные уравнения реакций.

**Реагенты:** растворы `AgNO₃`, `CuSO₄`, `Pb(NO₃)₂`; медная проволока и порошок, порошок железа.
RU,
                ],
                3 => [
                    'title' => '6. Metals and salt solutions',
                    'content' => <<<'EN'
# Laboratory work 6

## Interaction of metals with salt solutions

### Procedure

1. Pour 2–3 ml of silver(I) nitrate into the first test tube, copper(II) sulfate into the second, and lead(II) nitrate into the third. Add copper wire to the first, iron powder to the second, and copper powder to the third.

2. What substances form in each tube? Write molecular, full ionic, and net ionic equations.

**Reagents:** `AgNO₃`, `CuSO₄`, `Pb(NO₃)₂` solutions; Cu wire/powder, Fe powder.
EN,
                ],
            ],
        ];
    }

    private static function lab7(): array
    {
        return [
            'type' => 'lab',
            'order' => 2,
            'translations' => [
                1 => [
                    'title' => '7. Mis (II)-xlorid va kaliy yodid eritmalarining elektrolizi',
                    'content' => <<<'UZ'
# 7-laboratoriya ishi

## Mis (II)-xlorid va kaliy yodid eritmalarining elektrolizi

### 1. Mis (II)-xlorid eritmasining elektrolizi

U-simon nayning ¾ hajmigacha mis (II)-xlorid eritmasidan quying. Elektrolizyorning bir tomoniga mis, ikkinchi tomoniga grafit elektrod tushiring. Grafit elektrod (katod)ni manfiy ishorali, mis elektrod (anod)ni esa o‘zgarmas tokning musbat ishorali manbasiga ulang.

Katodda sof mis ajralayotganligini kuzating. Shu sharoitda anodda nima hosil bo‘lishi mumkin? Qanday gaz ajraladi? Elektrodlarning qutblarini o‘zgartirib, yana tok manbasiga ulang. Anoddagi mis qanday o‘zgarishga uchraydi? Katodda qanday modda ajraladi?

### 2. Kaliy yodid eritmasining elektrolizi

Elektrolizyorga 2 M li kaliy yodid eritmasidan quying. Nay ichiga grafit elektrodlarni tushiring va ularni o‘zgarmas tok manbasiga ulang.

Katodda vodorod pufakchalari hosil bo‘lishini, anodda esa yod ajralishini kuzating. Tok oqimini to‘xtatib, elektrodlarni chiqarib oling. So‘ngra U-simon nayning yod ajralgan tomoniga 1–2 tomchi yangi tayyorlangan kraxmal eritmasidan tomizing. Nima kuzatiladi?

### Mustaqil xulosa uchun topshiriq

1. Katod va anoddagi jarayonlarning tenglamasini yozing.
2. Elektrodlar atrofida elektrolit rangining o‘zgarishiga izoh bering.
UZ,
                ],
                2 => [
                    'title' => '7. Электролиз растворов хлорида меди(II) и йодида калия',
                    'content' => <<<'RU'
# Лабораторная работа 7

## Электролиз растворов хлорида меди(II) и йодида калия

### 1. Электролиз раствора хлорида меди(II)

Заполните U‑образную трубку раствором хлорида меди(II) до ¾ объёма. Поместите с одной стороны медный электрод, с другой — графитовый. Графитовый катод подключите к отрицательному полюсу, медный анод — к положительному выпрямленного источника тока.

Наблюдайте выделение чистой меди на катоде. Что возможно на аноде? Какой газ выделяется? Поменяйте полярность и снова подключите источник. Как изменится медный анод? Что выделяется на катоде?

### 2. Электролиз раствора йодида калия (2 М)

Налейте раствор KI, вставьте графитовые электроды, подключите к источнику постоянного тока.

На катоде — пузырьки водорода, на аноде — выделение йода. Остановите ток, извлеките электроды. На сторону с йодом капните 1–2 капли свежего крахмала. Что наблюдается?

### Задание для самостоятельного вывода

1. Запишите уравнения процессов на катоде и аноде.
2. Объясните изменение окраски электролита у электродов.
RU,
                ],
                3 => [
                    'title' => '7. Electrolysis of CuCl₂ and KI solutions',
                    'content' => <<<'EN'
# Laboratory work 7

## Electrolysis of copper(II) chloride and potassium iodide solutions

### 1. Electrolysis of CuCl₂ solution

Fill a U‑tube ~¾ with CuCl₂ solution. Insert a copper electrode on one side and graphite on the other. Connect graphite (cathode) to the negative terminal and copper (anode) to the positive DC supply.

Observe copper depositing on the cathode. What may happen at the anode? Which gas forms? Reverse the electrodes and reconnect. How does the copper anode change? What deposits or evolves at the cathode?

### 2. Electrolysis of 2 M KI solution

Pour 2 M KI into the electrolyzer, insert graphite electrodes, connect to DC.

Observe H₂ bubbles at the cathode and iodine at the anode. Stop current, remove electrodes, add 1–2 drops of fresh starch solution to the iodine side. What do you see?

### Follow‑up

1. Write equations for cathode and anode processes.
2. Explain electrolyte color changes near the electrodes.
EN,
                ],
            ],
        ];
    }

    private static function lab8(): array
    {
        return [
            'type' => 'lab',
            'order' => 3,
            'translations' => [
                1 => [
                    'title' => '8. Alyuminiyning kislota va asos eritmalari bilan o‘zaro ta’siri',
                    'content' => <<<'UZ'
# 8-laboratoriya ishi

## Alyuminiyning kislota va asos eritmalari bilan o‘zaro ta’siri

### Tajriba

1. Ikkita probirkaga alyuminiy boʻlakchalaridan soling.
2. Birinchi probirkaga xlorid kislota eritmasidan quying.
3. Ikkinchi probirkaga o‘yuvchi natriy eritmasidan quying.

### Mustaqil xulosa uchun topshiriq

Sodir boʻlgan jarayonlarni kuzating va reaksiya tenglamalarini yozing.
UZ,
                ],
                2 => [
                    'title' => '8. Взаимодействие алюминия с кислотой и щёлочью',
                    'content' => <<<'RU'
# Лабораторная работа 8

## Взаимодействие алюминия с растворами кислоты и основания

1. Положите кусочки алюминия в две пробирки.
2. В первую добавьте раствор соляной кислоты.
3. Во вторую — раствор едкого натрия.

### Задание

Наблюдайте за процессами и запишите уравнения реакций.
RU,
                ],
                3 => [
                    'title' => '8. Aluminum with acid and base',
                    'content' => <<<'EN'
# Laboratory work 8

## Reaction of aluminum with acid and alkali

1. Place aluminum pieces in two test tubes.
2. Add hydrochloric acid to the first.
3. Add sodium hydroxide solution to the second.

### Task

Observe and write the reaction equations.
EN,
                ],
            ],
        ];
    }

    private static function lab9(): array
    {
        return [
            'type' => 'lab',
            'order' => 4,
            'translations' => [
                1 => [
                    'title' => '9. Alyuminiy va uning qotishmalari namunalari bilan tanishish',
                    'content' => <<<'UZ'
# 9-laboratoriya ishi

## Alyuminiy va uning qotishmalari namunalari bilan tanishish

Alyuminiy va alyuminiy qotishmalaridan tayyorlangan buyumlar toʻplami bilan tanishing va xossalari hamda ishlatilish sohalari yuzasidan oʻz fikrlaringizni bayon eting.
UZ,
                ],
                2 => [
                    'title' => '9. Знакомство с образцами алюминия и сплавов',
                    'content' => <<<'RU'
# Лабораторная работа 9

## Знакомство с образцами алюминия и его сплавов

Ознакомьтесь с коллекцией изделий из алюминия и алюминиевых сплавов; сформулируйте выводы об их свойствах и областях применения.
RU,
                ],
                3 => [
                    'title' => '9. Aluminum and alloy samples',
                    'content' => <<<'EN'
# Laboratory work 9

## Getting acquainted with aluminum and its alloys

Review a set of objects made of aluminum and aluminum alloys; summarize their properties and typical uses.
EN,
                ],
            ],
        ];
    }

    private static function lab10(): array
    {
        return [
            'type' => 'lab',
            'order' => 5,
            'translations' => [
                1 => [
                    'title' => '10. Alyuminiy gidroksid: olish va kislota/ishqor bilan ta’sir',
                    'content' => <<<'UZ'
# 10-laboratoriya ishi

## Alyuminiy gidroksidni olish, uning kislota va ishqorlar bilan o‘zaro ta’sirlashuvini o‘rganish

Ikkita probirkaning biriga aluminiy nitratning 0,5 M eritmasidan 3 tomchi va ikkinchisiga o‘yuvchi natriyning 1 M eritmasidan 3 tomchi quying. So‘ng ularni o‘zaro aralashtiring. Aluminiy gidroksid cho‘kmasi hosil bo‘ladi. Uni ikkita probirkaga bo‘lib, biriga xlorid kislotaning 1 M eritmasidan 6 tomchi, ikkinchisiga esa o‘yuvchi natriyning 1 M eritmasidan shuncha hajmda quying. Cho‘kmaning erishini kuzating.

### Mustaqil xulosa uchun topshiriq

Hosil bo‘lgan mahsulotlarning reaksiya tenglamalarini molekular, ionli va qisqartirilgan ionli ko‘rinishda yozing.
UZ,
                ],
                2 => [
                    'title' => '10. Гидроксид алюминия: получение и реакции',
                    'content' => <<<'RU'
# Лабораторная работа 10

## Получение гидроксида алюминия и изучение его взаимодействия с кислотой и щёлочью

В одну пробирку — 3 капли 0,5 М раствора нитрата алюминия, в другую — 3 капли 1 М едкого натрия; смешайте. Выпадет осадок гидроксида алюминия. Разделите осадок: в одну пробирку 6 капель 1 М HCl, в другую — 6 капель 1 М NaOH. Наблюдайте растворение осадка.

### Задание

Запишите уравнения в молекулярном, ионном и сокращённом ионном виде.
RU,
                ],
                3 => [
                    'title' => '10. Aluminum hydroxide preparation and reactions',
                    'content' => <<<'EN'
# Laboratory work 10

## Prepare Al(OH)₃ and study reactions with acid and alkali

Mix 3 drops of 0.5 M Al(NO₃)₃ with 3 drops of 1 M NaOH. Divide the precipitate: add 6 drops of 1 M HCl to one portion and 6 drops of 1 M NaOH to the other. Observe dissolution.

### Task

Write equations in molecular, ionic, and net ionic forms.
EN,
                ],
            ],
        ];
    }

    private static function lab11(): array
    {
        return [
            'type' => 'lab',
            'order' => 6,
            'translations' => [
                1 => [
                    'title' => '11. Alyuminiy tuzlari eritmalarining indikatorlarga ta’siri',
                    'content' => <<<'UZ'
# 11-laboratoriya ishi

## Alyuminiy tuzlari eritmalarining indikatorlarga ta’sirini o‘rganish

1. Alyuminiy xlorid eritmasidan probirkaga 3–4 ml quying, ustiga 2–3 tomchi ko‘k rangli lakmus eritmasidan tomizing:
   - a) eritmani 2 ta probirkaga bo‘lib, birinchi probirkaga ozroq distillangan suv quying;
   - b) ikkinchi probirkani biroz qizdiring.

### Mustaqil xulosa uchun topshiriq

1. Sodir bo‘lgan hodisalarni kuzating va tushuntiring.
2. Alyuminiy xlorid eritmasini gidrolizlash tenglamasini bosqichli ko‘rinishda yozing.
UZ,
                ],
                2 => [
                    'title' => '11. Действие растворов солей алюминия на индикаторы',
                    'content' => <<<'RU'
# Лабораторная работа 11

## Влияние растворов солей алюминия на индикаторы

1. Налейте 3–4 мл раствора хлорида алюминия, добавьте 2–3 капли синего лакмуса:
   - a) разделите на две пробирки, в первую добавьте немного дистиллированной воды;
   - b) вторую слегка нагрейте.

### Задания

1. Объясните наблюдаемые явления.
2. Запишите по стадиям уравнение гидролиза хлорида алюминия.
RU,
                ],
                3 => [
                    'title' => '11. Aluminum salts and indicators',
                    'content' => <<<'EN'
# Laboratory work 11

## Effect of aluminum salt solutions on indicators

1. Add 3–4 ml AlCl₃ solution to a test tube, then 2–3 drops of blue litmus:
   - a) split into two tubes; add a little distilled water to the first;
   - b) gently heat the second.

### Tasks

1. Explain what you observe.
2. Write stepwise hydrolysis of aluminum chloride in solution.
EN,
                ],
            ],
        ];
    }

    private static function lab12(): array
    {
        return [
            'type' => 'lab',
            'order' => 7,
            'translations' => [
                1 => [
                    'title' => '12. Mis (II)-gidroksidni olish va tajribalar',
                    'content' => <<<'UZ'
# 12-laboratoriya ishi

## Misning ikki valentli tuzlaridan mis (II)-gidroksidi olish va u bilan tajribalar o‘tkazish

1. Probirkaga 2 ml mis (II)-sulfat eritmasidan quying va unga sekin-asta 1–2 ml natriy gidroksid eritmasidan quying.

2. Hosil bo‘lgan hodisani kuzating. Cho‘kmani filtrlang. Yuving. Sodir bo‘lgan kimyoviy reaksiya tenglamasini yozing.

3. Cho‘kma mis (II)-gidroksid ekanligini isbotlovchi tajribalarni bajaring:
   - **a)** xlorid kislota ta’sir ettiring;
   - **b)** cho‘kmaning bir qismini chinni tigelga solib, sekin-asta qizdiring.

### Mustaqil xulosa uchun topshiriq

1. Yuqoridagi tajribalarda sodir bo‘lgan hodisalarni izohlang.
2. 20 % li 4 g mis (II)-sulfat eritmasi bilan qoldiqsiz reaksiyaga kirishish uchun qancha hajm 20 % li (ρ = 1,22 g/ml) natriy gidroksid eritmasi qo‘shish kerak?
3. Mis (II)-gidroksidni qanday usullar bilan olish mumkin?
UZ,
                ],
                2 => [
                    'title' => '12. Гидроксид меди(II): получение и опыты',
                    'content' => <<<'RU'
# Лабораторная работа 12

## Получение гидроксида меди(II) из двухвалентных солей меди

1. К 2 мл раствора сульфата меди(II) медленно добавьте 1–2 мл NaOH.

2. Наблюдайте явление. Осадок отфильтруйте, промойте. Запишите уравнение реакции.

3. Докажите, что осадок — гидроксид меди(II):
   - **a)** действие соляной кислоты;
   - **b)** нагревание части осадка в фарфоровом тигле.

### Задания

1. Объясните наблюдения.
2. Рассчитайте объём 20%-ного раствора NaOH (ρ = 1,22 г/мл), нужный для полного взаимодействия с 4 г 20%-ного раствора CuSO₄.
3. Какими способами можно получить Cu(OH)₂?
RU,
                ],
                3 => [
                    'title' => '12. Copper(II) hydroxide',
                    'content' => <<<'EN'
# Laboratory work 12

## Cu(OH)₂ from divalent copper salts

1. To 2 ml CuSO₄ solution slowly add 1–2 ml NaOH.

2. Observe, filter and wash the precipitate. Write the equation.

3. Prove the precipitate is Cu(OH)₂:
   - **a)** treat with HCl;
   - **b)** heat a portion in a porcelain crucible.

### Tasks

1. Explain observations.
2. What volume of 20% NaOH (ρ = 1.22 g/ml) reacts completely with 4 g of 20% CuSO₄ solution?
3. How else can Cu(OH)₂ be obtained?
EN,
                ],
            ],
        ];
    }

    private static function lab13(): array
    {
        return [
            'type' => 'lab',
            'order' => 8,
            'translations' => [
                1 => [
                    'title' => '13. Rux gidroksid va uning amfoterligi',
                    'content' => <<<'UZ'
# 13-laboratoriya ishi

## Ruxning suvda eriydigan tuzlaridan rux gidroksid olish va uni amfoter xossasini isbotlash

1. Rux sulfat tuzining 20 % li eritmasidan 5 ml oling va unga natriy gidroksidning 10 % li eritmasidan 5 ml quying. Hosil bo‘lgan cho‘kmani 2 ta probirkaga bo‘ling.

2. Probirkalarning biriga sulfat kislota eritmasidan, ikkinchisiga esa natriy gidroksid eritmasidan quying.

### Mustaqil xulosa uchun topshiriq

1. Rux sulfat tuzi eritmasiga natriy gidroksid quyilganda sodir bo‘ladigan kimyoviy hodisani izohlang va sodir bo‘lgan kimyoviy reaksiya tenglamasini yozing.
2. Qanday moddalar amfoter moddalar deb ataladi? Rux gidroksidni amfoter modda ekanligini qanday isbotlash mumkin?
3. Yuqorida bajarilgan tajribalarni tushuntiring.
4. Rux sulfat eritmasiga o‘yuvchi natriy eritmasidan ortiqcha miqdor qo‘shilganda cho‘kma hosil bo‘ladimi? Nima uchun? Javobingizni izohlang.
UZ,
                ],
                2 => [
                    'title' => '13. Гидроксид цинка и амфотерность',
                    'content' => <<<'RU'
# Лабораторная работа 13

## Получение гидроксида цинка и доказательство его амфотерности

1. Смешайте 5 мл 20%-ного раствора сульфата цинка и 5 мл 10%-ного NaOH. Осадок разделите по двум пробиркам.

2. В одну добавьте раствор серной кислоты, в другую — раствор NaOH.

### Вопросы

1. Опишите явление при смешивании ZnSO₄ с NaOH; уравнение реакции.
2. Что такое амфотерные вещества? Как доказать амфотерность Zn(OH)₂?
3. Объясните опыты.
4. Образуется ли осадок при избытке NaOH к ZnSO₄? Почему?
RU,
                ],
                3 => [
                    'title' => '13. Zinc hydroxide and amphoterism',
                    'content' => <<<'EN'
# Laboratory work 13

## Zn(OH)₂ from soluble zinc salts; amphoteric behavior

1. Mix 5 ml 20% ZnSO₄ with 5 ml 10% NaOH. Divide the precipitate into two tubes.

2. Add H₂SO₄ to one tube and NaOH to the other.

### Questions

1. Explain precipitation; write the equation.
2. Define amphoteric substances; how Zn(OH)₂ shows this.
3. Explain the experiments.
4. Is there still precipitate with excess NaOH? Why?
EN,
                ],
            ],
        ];
    }

    private static function lab14(): array
    {
        return [
            'type' => 'lab',
            'order' => 9,
            'translations' => [
                1 => [
                    'title' => '14. Xromning II, III va VI valentli birikmalari',
                    'content' => <<<'UZ'
# 14-laboratoriya ishi

## Xromning ikki, uch va olti valentli birikmalari

1. Xrom (II)-xlorid (ko‘k rangli eritma) eritmasidan 2–3 ml probirkaga quying va unga shuncha miqdorda o‘yuvchi natriy eritmasidan qo‘shing. Hosil bo‘lgan sariq rangli cho‘kmaga e‘tibor bering. Cho‘kma ustiga sulfat kislota eritmasidan quying. Sodir bo‘lgan o‘zgarishlarni kuzating. Reaksiya tenglamalarini yozing.

2. Xrom (III)-oksid yashil rangli modda. Taxminan 0,5 g olib, probirkaga soling va sulfat kislota eritmasidan quying (oksid erib ketguncha). Hosil bo‘lgan eritma rangiga e‘tibor bering. Uch valentli xrom tuzi eritmasi ustiga o‘yuvchi natriy eritmasidan oz-ozdan quying. O‘zgarishlarni kuzating. Reaksiya tenglamalarini yozing. Izohlang.

3. Kaliy bixromatning to‘q sariq rangli eritmasiga ozroq sulfat kislota qo‘shing va bu aralashmaga natriy sulfit (Na₂SO₃) eritmasidan quying. Rang o‘zgarishi va sababini izohlang. Reaksiya tenglamalarini yozing.
UZ,
                ],
                2 => [
                    'title' => '14. Соединения хрома (II), (III) и (VI)',
                    'content' => <<<'RU'
# Лабораторная работа 14

## Двух-, трёх- и шестивалентные соединения хрома

1. 2–3 мл синего раствора хлорида хрома(II) + равный объём NaOH — жёлтый осадок; сверху добавьте H₂SO₄. Наблюдайте, запишите уравнения.

2. ~0,5 г зелёного Cr₂O₃ в пробирку, растворите в H₂SO₄. К полученному раствору соли Cr(III) постепенно добавляйте NaOH. Наблюдайте, уравнения, пояснение.

3. К тёмно-жёлтому раствору K₂Cr₂O₇ добавьте немного H₂SO₄, затем Na₂SO₃. Объясните смену окраски; уравнения.
RU,
                ],
                3 => [
                    'title' => '14. Chromium in +2, +3, +6 oxidation states',
                    'content' => <<<'EN'
# Laboratory work 14

## Divalent, trivalent, and hexavalent chromium compounds

1. Mix 2–3 ml blue CrCl₂ solution with equal NaOH — yellow precipitate; add H₂SO₄ on top. Observe and write equations.

2. Dissolve ~0.5 g green Cr₂O₃ in H₂SO₄. Gradually add NaOH to the Cr(III) salt solution. Observe; write and explain equations.

3. To dark-yellow K₂Cr₂O₇ solution add a little H₂SO₄, then Na₂SO₃ solution. Explain the color change; write equations.
EN,
                ],
            ],
        ];
    }

    private static function lab15(): array
    {
        return [
            'type' => 'lab',
            'order' => 10,
            'translations' => [
                1 => [
                    'title' => '15. Temir (II)- va (III)-gidroksidlarini olish',
                    'content' => <<<'UZ'
# 15-laboratoriya ishi

## Temirning (II)- va (III)-gidroksidlarini olish

1. Probirkaga 2–3 ml temir (II)-sulfat tuzi eritmasidan quying. Unga oz miqdorda o‘yuvchi natriy qo‘shing. Hosil bo‘lgan cho‘kmaga oz-ozdan xlorid kislota eritmasi qo‘shing.

2. Probirkaga 2–3 ml temir (III)-xlorid eritmasidan quying. Unga oz miqdorda o‘yuvchi natriy qo‘shing. Hosil bo‘lgan cho‘kmaga sulfat kislota eritmasidan oz-ozdan quying.

### Mustaqil xulosa uchun topshiriq

1. Yuqorida sodir bo‘lgan kimyoviy reaksiyalarning tenglamalarini yozing.
2. Har bir tajribada sodir bo‘lgan ranglar o‘zgarishiga e‘tibor bering va bu o‘zgarishlar sababini tushuntiring.
3. Fe(OH)₂ va Fe(OH)₃ gidroksidlarni qanday olish mumkin?
4. Temirning ikki va uch valentli birikmalarining ranglarini o‘zaro taqqoslang.
UZ,
                ],
                2 => [
                    'title' => '15. Гидроксиды железа (II) и (III)',
                    'content' => <<<'RU'
# Лабораторная работа 15

## Получение гидроксидов железа (II) и (III)

1. К 2–3 мл раствора сульфата железа(II) добавьте немного NaOH. К осадку каплями добавляйте HCl.

2. К 2–3 мл раствора хлорида железа(III) добавьте немного NaOH. К осадку каплями добавляйте H₂SO₄.

### Задания

1. Уравнения реакций.
2. Объясните изменение окраски.
3. Как получают Fe(OH)₂ и Fe(OH)₃?
4. Сравните цвета соединений Fe(II) и Fe(III).
RU,
                ],
                3 => [
                    'title' => '15. Iron(II) and iron(III) hydroxides',
                    'content' => <<<'EN'
# Laboratory work 15

## Preparing Fe(OH)₂ and Fe(OH)₃

1. To 2–3 ml FeSO₄ solution add a little NaOH. Add HCl dropwise to the precipitate.

2. To 2–3 ml FeCl₃ solution add a little NaOH. Add H₂SO₄ dropwise to the precipitate.

### Tasks

1. Write reaction equations.
2. Explain color changes.
3. How can Fe(OH)₂ and Fe(OH)₃ be obtained?
4. Compare typical colors of Fe(II) vs Fe(III) compounds.
EN,
                ],
            ],
        ];
    }

    private static function lab16(): array
    {
        return [
            'type' => 'lab',
            'order' => 11,
            'translations' => [
                1 => [
                    'title' => '16. Ikki va uch valentli temir tuzlarini bilib olish',
                    'content' => <<<'UZ'
# 16-laboratoriya ishi

## Ikki va uch valentli temir tuzlarini bilib olish

### Fe²⁺ ionini aniqlash

Yangi tayyorlangan temir (II)-sulfat eritmasidan 3–5 tomchi probirkaga quying va unga bir necha tomchi kaliy geksatsianferrat (III) («qon tuprogʻi» tuzining qizili, K₃[Fe(CN)₆]) eritmasini qo‘shing. Turunbuf zangori cho‘kma — Fe₃[Fe(CN)₆]₂. Reaksiya tenglamasini yozing.

### Fe³⁺ ionini aniqlash (usul A)

2–3 tomcha temir (III)-xlorid eritmasiga bir tomcha kaliy geksatsianferroat (II) («qon tuprogʻi» tuzining sariqi, K₄[Fe(CN)₆]) qo‘shing. Berlin lazuri cho‘kma — Fe₄[Fe(CN)₆]₃. Reaksiyani molekular va ionli ko‘rinishda yozing.

### Fe³⁺ ionini aniqlash (usul B)

FeCl₃ eritmasi bilan probirkaga 5–6 tomcha 0,01 M kaliy yoki ammoniy rodanidi eritmasini qo‘shing. Eritma to‘q qizil rangga kiradi — Fe(SCN)₃. Reaksiyani molekular va ionli ko‘rinishda yozing.

### Mustaqil xulosa uchun topshiriq

1. Sodir bo‘lgan hodisalarni izohlang.
2. Tegishli reaksiya tenglamalarini yozing.
UZ,
                ],
                2 => [
                    'title' => '16. Различие солей железа (II) и (III)',
                    'content' => <<<'RU'
# Лабораторная работа 16

## Определение двух- и трёхвалентных солей железа

### Ион Fe²⁺

3–5 капель свежего FeSO₄ + несколько капель K₃[Fe(CN)₆] (красная кровяная соль) → осадок голубого цвета (Turnbull’s blue). Запишите уравнение.

### Ион Fe³⁺ (способ А)

2–3 капли FeCl₃ + 1 капля K₄[Fe(CN)₆] (жёлтая кровяная соль) → осадок берлинской лазури. Молекулярное и ионное уравнения.

### Ион Fe³⁺ (способ Б)

5–6 капель 0,01 М KCNS или NH₄CNS к FeCl₃ → тёмно-красная окраска от Fe(SCN)₃. Уравнения.

### Задание

1. Объясните наблюдения.
2. Запишите уравнения реакций.
RU,
                ],
                3 => [
                    'title' => '16. Identifying Fe²⁺ and Fe³⁺ salts',
                    'content' => <<<'EN'
# Laboratory work 16

## Qualitative tests for iron(II) and iron(III)

### Fe²⁺

3–5 drops fresh FeSO₄ + a few drops of K₃[Fe(CN)₆] (red prussiate) → Turnbull’s blue precipitate Fe₃[Fe(CN)₆]₂. Write the equation.

### Fe³⁺ (method A)

2–3 drops FeCl₃ + 1 drop K₄[Fe(CN)₆] (yellow prussiate) → Prussian blue Fe₄[Fe(CN)₆]₃. Molecular and ionic equations.

### Fe³⁺ (method B)

5–6 drops 0.01 M KSCN or NH₄SCN to FeCl₃ → dark red color from Fe(SCN)₃. Equations.

### Follow‑up

1. Explain observations.
2. Write reaction equations.
EN,
                ],
            ],
        ];
    }
}

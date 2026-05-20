<?php

namespace Database\Seeders;

use App\Models\NeighborCountry;
use Illuminate\Database\Seeder;

/** @see NeighborData / kNeighborCountries in mobile — ma'lumotlar mos. */

class NeighborCountrySeeder extends Seeder
{
    public function run(): void
    {
        $rows = [
            [
                'code' => 'kz',
                'sort_order' => 1,
                'name_uz' => "Qozog'iston",
                'name_ru' => 'Казахстан',
                'name_en' => 'Kazakhstan',
                'capital_uz' => 'Ostana',
                'capital_ru' => 'Астана',
                'capital_en' => 'Astana',
                'description_uz' => "Qozog'iston — Markaziy Osiyodagi eng yirik davlat. Shimolda Rossiya, sharqda Xitoy, janubda Qirg'iziston, O'zbekiston va Turkmaniston bilan chegaradosh. Hududi bo'yicha dunyoda 9-o'rinda turadi.",
                'description_ru' => 'Казахстан — крупнейшая страна в Центральной Азии, граничит с Россией, Китаем, Киргизией, Узбекистаном и Туркменистаном. По площади — 9-е место в мире.',
                'description_en' => 'Kazakhstan is the largest country in Central Asia, bordering Russia, China, Kyrgyzstan, Uzbekistan, and Turkmenistan. 9th in the world by area.',
                'area_km2' => 2_724_900,
                'population_mn' => 19.6,
                'languages_uz' => "Qozoq, Rus",
                'languages_ru' => 'Казахский, русский',
                'languages_en' => 'Kazakh, Russian',
                'currency_uz' => 'Tenge',
                'currency_ru' => 'Тенге',
                'currency_en' => 'Tenge',
                'border_with_uz_km' => 2356,
                'flag_emoji' => '🇰🇿',
            ],
            [
                'code' => 'kg',
                'sort_order' => 2,
                'name_uz' => "Qirg'iziston",
                'name_ru' => 'Кыргызстан',
                'name_en' => 'Kyrgyzstan',
                'capital_uz' => 'Bishkek',
                'capital_ru' => 'Бишкек',
                'capital_en' => 'Bishkek',
                'description_uz' => "Qirg'iziston — tog'li mamlakat bo'lib, hududining katta qismi Tyanshan tog' tizmasida joylashgan. Issiqko'l ko'li mamlakatning eng mashhur tabiat mo'jizalaridan biridir. Iqtisodiyoti asosan qishloq xo'jaligi va konchilikka asoslangan.",
                'description_ru' => 'Киргизия — горная страна, большая часть — Тянь-Шань. Озеро Иссык-Кул — визитная карточка. Экономика: сельское хозяйство и добыча.',
                'description_en' => 'Kyrgyzstan is mountainous, mostly in the Tien Shan. Issyk-Kul is a famous natural landmark. Economy: agriculture and mining.',
                'area_km2' => 199_951,
                'population_mn' => 6.7,
                'languages_uz' => "Qirg'iz, Rus",
                'languages_ru' => 'Киргизский, русский',
                'languages_en' => 'Kyrgyz, Russian',
                'currency_uz' => 'Som',
                'currency_ru' => 'Сом',
                'currency_en' => 'Som',
                'border_with_uz_km' => 1472,
                'flag_emoji' => '🇰🇬',
            ],
            [
                'code' => 'tj',
                'sort_order' => 3,
                'name_uz' => 'Tojikiston',
                'name_ru' => 'Таджикистан',
                'name_en' => 'Tajikistan',
                'capital_uz' => 'Dushanbe',
                'capital_ru' => 'Душанбе',
                'capital_en' => 'Dushanbe',
                'description_uz' => "Tojikiston — Markaziy Osiyodagi eng kichik davlatlardan biri bo'lib, hududining 93% ini tog'lar egallagan. Pomir tog'lari 'Dunyo tomi' deb ataladi. Suv resurslariga juda boy mamlakat.",
                'description_ru' => 'Таджикистан — одна из самых маленьких стран в ЦА; 93% территории — горы, Памир — «Крыша мира», богат водными ресурсами.',
                'description_en' => 'Tajikistan is one of the smallest CA states; 93% mountains, Pamir as the "Roof of the World", rich in water resources.',
                'area_km2' => 143_100,
                'population_mn' => 10.0,
                'languages_uz' => 'Tojik',
                'languages_ru' => 'Таджикский',
                'languages_en' => 'Tajik',
                'currency_uz' => 'Somoni',
                'currency_ru' => 'Сомони',
                'currency_en' => 'Somoni',
                'border_with_uz_km' => 1312,
                'flag_emoji' => '🇹🇯',
            ],
            [
                'code' => 'tm',
                'sort_order' => 4,
                'name_uz' => 'Turkmaniston',
                'name_ru' => 'Туркменистан',
                'name_en' => 'Turkmenistan',
                'capital_uz' => 'Ashxobod',
                'capital_ru' => 'Ашхабад',
                'capital_en' => 'Ashgabat',
                'description_uz' => "Turkmaniston — asosan cho'l landshaftiga ega (Qoraqum cho'li). Tabiiy gaz zaxiralari bo'yicha dunyoda yetakchi o'rinlardan birida turadi. Ashxobod shahri oq marmar binolari bilan mashhur.",
                'description_ru' => 'Туркменистан — пустынный (Каракум) регион, один из крупных экспортёров газа. Ашхабад известен белыми мраморными зданиями.',
                'description_en' => 'Turkmenistan is largely desert (Karakum), a top natural gas player. Ashgabat is known for white marble buildings.',
                'area_km2' => 491_210,
                'population_mn' => 6.4,
                'languages_uz' => 'Turkman',
                'languages_ru' => 'Туркменский',
                'languages_en' => 'Turkmen',
                'currency_uz' => 'Manat',
                'currency_ru' => 'Манат',
                'currency_en' => 'Manat',
                'border_with_uz_km' => 1831,
                'flag_emoji' => '🇹🇲',
            ],
            [
                'code' => 'af',
                'sort_order' => 5,
                'name_uz' => "Afg'oniston",
                'name_ru' => 'Афганистан',
                'name_en' => 'Afghanistan',
                'capital_uz' => 'Kobul',
                'capital_ru' => 'Кабул',
                'capital_en' => 'Kabul',
                'description_uz' => "Afg'oniston — janubda joylashgan tog'li davlat. O'zbekiston bilan Amudaryo orqali chegaradosh. Tarixiy Ipak yo'lining muhim chorrahasida joylashgan. Amu-Buxoro kanallari shu daryodan suv oladi.",
                'description_ru' => 'Афганистан — гористая южная страна, с Узбекистаном граница по Амударье. Важен на Историческом шёлковом пути. Каналы (Аму-Бухарский комплекс) используют воду Амударьи.',
                'description_en' => 'Afghanistan lies to the south, mountainous; borders Uzbekistan along the Amu Darya, key on the old Silk Road. Canals use water from the river.',
                'area_km2' => 652_860,
                'population_mn' => 40.0,
                'languages_uz' => 'Pashtu, Dari',
                'languages_ru' => 'Пушту, дари',
                'languages_en' => 'Pashto, Dari',
                'currency_uz' => 'Afghani',
                'currency_ru' => 'Афгани',
                'currency_en' => 'Afghani',
                'border_with_uz_km' => 144,
                'flag_emoji' => '🇦🇫',
            ],
        ];

        foreach ($rows as $r) {
            NeighborCountry::query()->updateOrCreate(
                ['code' => $r['code']],
                $r
            );
        }
    }
}

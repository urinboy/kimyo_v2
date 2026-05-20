import 'package:flutter/material.dart' show BuildContext;
import 'package:intl/intl.dart';
import '../../core/localization/app_localizations.dart';

/// [NeighborCountrySeeder] (Laravel) bilan ma'lumotlar mos.
class NeighborData {
  const NeighborData({
    required this.code,
    required this.flagEmoji,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.capitalUz,
    required this.capitalRu,
    required this.capitalEn,
    required this.descriptionUz,
    required this.descriptionRu,
    required this.descriptionEn,
    required this.areaKm2,
    required this.populationMn,
    required this.languagesUz,
    required this.languagesRu,
    required this.languagesEn,
    required this.currencyUz,
    required this.currencyRu,
    required this.currencyEn,
    required this.borderWithUzKm,
  });

  final String code;
  final String flagEmoji;
  final String nameUz;
  final String nameRu;
  final String nameEn;
  final String capitalUz;
  final String capitalRu;
  final String capitalEn;
  final String descriptionUz;
  final String descriptionRu;
  final String descriptionEn;
  final int areaKm2;
  final double populationMn;
  final String languagesUz;
  final String languagesRu;
  final String languagesEn;
  final String currencyUz;
  final String currencyRu;
  final String currencyEn;
  final int borderWithUzKm;

  String name(BuildContext context) {
    final c = context.locale.languageCode;
    return c == 'ru' ? nameRu : (c == 'en' ? nameEn : nameUz);
  }

  String capital(BuildContext context) {
    final c = context.locale.languageCode;
    return c == 'ru' ? capitalRu : (c == 'en' ? capitalEn : capitalUz);
  }

  String description(BuildContext context) {
    final c = context.locale.languageCode;
    return c == 'ru' ? descriptionRu : (c == 'en' ? descriptionEn : descriptionUz);
  }

  String languages(BuildContext context) {
    final c = context.locale.languageCode;
    return c == 'ru' ? languagesRu : (c == 'en' ? languagesEn : languagesUz);
  }

  String currency(BuildContext context) {
    final c = context.locale.languageCode;
    return c == 'ru' ? currencyRu : (c == 'en' ? currencyEn : currencyUz);
  }

  String areaFormatted() {
    return '${NumberFormat('#,###', 'en').format(areaKm2)} km²';
  }
}

const List<NeighborData> kNeighborCountries = [
  NeighborData(
    code: 'kz',
    flagEmoji: '🇰🇿',
    nameUz: "Qozog'iston",
    nameRu: 'Казахстан',
    nameEn: 'Kazakhstan',
    capitalUz: 'Ostana',
    capitalRu: 'Астана',
    capitalEn: 'Astana',
    descriptionUz:
        "Qozog'iston — Markaziy Osiyodagi eng yirik davlat. Shimolda Rossiya, sharqda Xitoy, janubda Qirg'iziston, O'zbekiston va Turkmaniston bilan chegaradosh. Hududi bo'yicha dunyoda 9-o'rinda turadi.",
    descriptionRu:
        'Казахстан — крупнейшая страна в Центральной Азии, граничит с Россией, Китаем, Киргизией, Узбекистаном и Туркменистаном. По площади — 9-е место в мире.',
    descriptionEn:
        'Kazakhstan is the largest country in Central Asia, bordering Russia, China, Kyrgyzstan, Uzbekistan, and Turkmenistan. 9th in the world by area.',
    areaKm2: 2724900,
    populationMn: 19.6,
    languagesUz: "Qozoq, Rus",
    languagesRu: 'Казахский, русский',
    languagesEn: 'Kazakh, Russian',
    currencyUz: 'Tenge',
    currencyRu: 'Тенге',
    currencyEn: 'Tenge',
    borderWithUzKm: 2356,
  ),
  NeighborData(
    code: 'kg',
    flagEmoji: '🇰🇬',
    nameUz: "Qirg'iziston",
    nameRu: 'Кыргызстан',
    nameEn: 'Kyrgyzstan',
    capitalUz: 'Bishkek',
    capitalRu: 'Бишкек',
    capitalEn: 'Bishkek',
    descriptionUz:
        "Qirg'iziston — tog'li mamlakat bo'lib, hududining katta qismi Tyanshan tog' tizmasida joylashgan. Issiqko'l ko'li mamlakatning eng mashhur tabiat mo'jizalaridan biridir. Iqtisodiyoti asosan qishloq xo'jaligi va konchilikka asoslangan.",
    descriptionRu:
        'Киргизия — горная страна, основная часть в Тянь-Шане. Озеро Иссык-Кул — визитная природная достопримечательность. Экономика: сельское хозяйство и добыча.',
    descriptionEn:
        'Kyrgyzstan is mountainous, mostly in the Tien Shan. Issyk-Kul is a famous natural wonder. Economy: agriculture and mining.',
    areaKm2: 199951,
    populationMn: 6.7,
    languagesUz: "Qirg'iz, Rus",
    languagesRu: 'Киргизский, русский',
    languagesEn: 'Kyrgyz, Russian',
    currencyUz: 'Som',
    currencyRu: 'Сом',
    currencyEn: 'Som',
    borderWithUzKm: 1472,
  ),
  NeighborData(
    code: 'tj',
    flagEmoji: '🇹🇯',
    nameUz: 'Tojikiston',
    nameRu: 'Таджикистан',
    nameEn: 'Tajikistan',
    capitalUz: 'Dushanbe',
    capitalRu: 'Душанбе',
    capitalEn: 'Dushanbe',
    descriptionUz:
        "Tojikiston — Markaziy Osiyodagi eng kichik davlatlardan biri bo'lib, hududining 93% ini tog'lar egallagan. Pomir tog'lari 'Dunyo tomi' deb ataladi. Suv resurslariga juda boy mamlakat.",
    descriptionRu:
        'Таджикистан — одна из меньших стран ЦА; 93% — горы, Памир — «Крыша мира», страна богата водой.',
    descriptionEn:
        'Tajikistan is one of the smaller CA states; 93% is mountains, Pamir as the “Roof of the World,” rich in water resources.',
    areaKm2: 143100,
    populationMn: 10.0,
    languagesUz: 'Tojik',
    languagesRu: 'Таджикский',
    languagesEn: 'Tajik',
    currencyUz: 'Somoni',
    currencyRu: 'Сомони',
    currencyEn: 'Somoni',
    borderWithUzKm: 1312,
  ),
  NeighborData(
    code: 'tm',
    flagEmoji: '🇹🇲',
    nameUz: 'Turkmaniston',
    nameRu: 'Туркменистан',
    nameEn: 'Turkmenistan',
    capitalUz: 'Ashxobod',
    capitalRu: 'Ашхабад',
    capitalEn: 'Ashgabat',
    descriptionUz:
        "Turkmaniston — asosan cho'l landshaftiga ega (Qoraqum cho'li). Tabiiy gaz zaxiralari bo'yicha dunyoda yetakchi o'rinlardan birida turadi. Ashxobod shahri oq marmar binolari bilan mashhur.",
    descriptionRu:
        'Туркменистан — преимущественно пустыня (Каракум), выдающиеся залежи газа. Ашхабад славится белыми мраморными зданиями.',
    descriptionEn:
        'Turkmenistan is largely desert (Karakum), a top natural-gas power. Ashgabat is famous for white marble buildings.',
    areaKm2: 491210,
    populationMn: 6.4,
    languagesUz: 'Turkman',
    languagesRu: 'Туркменский',
    languagesEn: 'Turkmen',
    currencyUz: 'Manat',
    currencyRu: 'Манат',
    currencyEn: 'Manat',
    borderWithUzKm: 1831,
  ),
  NeighborData(
    code: 'af',
    flagEmoji: '🇦🇫',
    nameUz: "Afg'oniston",
    nameRu: 'Афганистан',
    nameEn: 'Afghanistan',
    capitalUz: 'Kobul',
    capitalRu: 'Кабул',
    capitalEn: 'Kabul',
    descriptionUz:
        "Afg'oniston — janubda joylashgan tog'li davlat. O'zbekiston bilan Amudaryo orqali chegaradosh. Tarixiy Ipak yo'lining muhim chorrahasida joylashgan. Amu-Buxoro kanallari shu daryodan suv oladi.",
    descriptionRu:
        'Афганистан — гористая южная страна, с Узбекистаном граница по Амударье. Важен на Историческом шёлковом пути. Каналы (Аму-Бухарский комплекс) используют воду Амударьи.',
    descriptionEn:
        'Afghanistan is a mountainous country to the south, bordering Uzbekistan along the Amu Darya, key on the old Silk Road. Canals use water from the Amu Darya.',
    areaKm2: 652860,
    populationMn: 40.0,
    languagesUz: 'Pashtu, Dari',
    languagesRu: 'Пушту, дари',
    languagesEn: 'Pashto, Dari',
    currencyUz: 'Afghani',
    currencyRu: 'Афгани',
    currencyEn: 'Afghani',
    borderWithUzKm: 144,
  ),
];

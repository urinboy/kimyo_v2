import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  // Manual map for now to avoid async loading issues during initial setup
  static final Map<String, Map<String, String>> _translations = {
    'uz': {
      'app_title': 'Kimyo V2',
      'tab_kimyo': 'Kimyo',
      'tab_geografiya': 'Geografiya',
      'tab_hujjatlar': 'Hujjatlar',
      'tab_sozlamalar': 'Sozlamalar',
      'tab_profil': 'Profil',
      'menu_elements': 'Kimyoviy elementlar',
      'menu_elements_sub': 'Element ma\'lumotlari',
      'menu_alkali_metals': 'Ishqoriy metallar guruhlar',
      'alkali_page_title': 'Metallar guruhlar',
      'alkali_search_hint': 'Element nomi yoki belgisi...',
      'menu_periodic_table': 'Davriy jadval',
      'menu_periodic_table_sub': 'Jadvalni ko\'rish',
      'menu_formulas': 'Kimyoviy formulalar',
      'menu_formulas_sub': 'Kimyoviy reaksiyalar',
      'menu_lessons': 'Mashg\'ulotlar',
      'menu_lessons_sub': 'Darslarni boshlash',
      'menu_quiz': 'Test ishlash',
      'menu_lab_works': 'Laboratoriya ishlari',
      'tests_title': 'Testlar',
      'tests_tab_chemistry': 'Kimyo',
      'tests_tab_geography': 'Geografiya',
      'tests_no_items': 'Hozircha testlar yo\'q',
      'geo_map': 'Dunyo siyosiy xaritasi',
      'geo_map_sub': 'Interaktiv xarita',
      'geo_landscapes': 'Tabiiy landshaftlar',
      'geo_geology': 'Geologik tuzilish',
      'geo_climate': 'Iqlim va ob-havo',
      'geo_climate_sub1': 'Hududlar iqlimi',
      'geo_climate_sub2': 'Ob-havo ma\'lumotlari',
      'geo_climate_regional_title': 'Iqlim, ob-havo hududiy taqsimlash',
      'geo_topic_continental': 'Kontinental iqlim',
      'geo_topic_continental_desc':
          'O\'zbekiston kontinental iqlim mintaqasida joylashgan.\n\n'
          'Asosiy xususiyatlari:\n'
          '• Issiq va quruq yoz\n'
          '• Sovuq qish\n'
          '• Kam yog\'ingarchilik\n'
          '• Kun va tun harorati farqi katta\n'
          '• Fasllar farqi keskin\n\n'
          'Sabablari:\n'
          '• Dengizdan uzoqlik\n'
          '• Markaziy Osiyoda joylashuvi\n'
          '• Tog\'lar bilan o\'ralgan\n'
          '• Geografik joylashuv\n\n'
          'Harorat amplitudasi:\n'
          '• Yillik: 40-50°C farq\n'
          '• Kunlik: 15-20°C farq\n'
          '• Eng issiq: +45°C (Termiz)\n'
          '• Eng sovuq: -30°C (tog\'lar)\n\n'
          'Yog\'ingarchilik:\n'
          '• O\'rtacha: 100-500 mm/yil\n'
          '• Eng ko\'p: tog\' hududlari (500-700 mm)\n'
          '• Eng kam: cho\'llar (100-150 mm)\n'
          '• Asosan bahor va kuz',
      'geo_topic_climate_zones': 'Iqlim zonalari',
      'geo_topic_climate_zones_desc':
          'O\'zbekiston 4 ta asosiy iqlim zonasiga bo\'linadi.\n\n'
          '1. Cho\'l iqlimi\n\n'
          'Hududlar:\n'
          '• Qizilqum cho\'li\n'
          '• Qoraqalpog\'iston\n'
          '• Ustyurt platosi\n'
          '• Navoiy viloyati cho\'l qismi\n\n'
          'Xususiyatlari:\n'
          '• Juda issiq yoz (+40...+45°C)\n'
          '• Sovuq qish (0...-15°C)\n'
          '• Juda kam yog\'in (100-150 mm)\n'
          '• Kuchli shamollar\n'
          '• Katta harorat farqi\n\n'
          '2. Yarim cho\'l (step) iqlimi\n\n'
          'Hududlar:\n'
          '• Mirzacho\'l\n'
          '• Jizzax viloyati\n'
          '• Samarqand atrofi\n'
          '• Buxoro viloyati qismi\n\n'
          'Xususiyatlari:\n'
          '• Issiq yoz (+35...+40°C)\n'
          '• Iliq qish (0...-10°C)\n'
          '• O\'rtacha yog\'in (200-300 mm)\n'
          '• Step o\'simliklari\n\n'
          '3. Subtropik iqlim\n\n'
          'Hududlar:\n'
          '• Surxondaryo vodiysida\n'
          '• Qashqadaryo janubi\n'
          '• Sherabad vodiysida\n\n'
          'Xususiyatlari:\n'
          '• Juda issiq yoz (+40...+45°C)\n'
          '• Iliq qish (+5...0°C)\n'
          '• Yog\'in: 200-400 mm\n'
          '• Subtropik o\'simliklar o\'sadi\n'
          '• Paxta, meva yetishadi\n\n'
          '4. Tog\' iqlimi\n\n'
          'Hududlar:\n'
          '• Tyan-Shan tog\'lari\n'
          '• Pamir-Oloy tog\'lari\n'
          '• Fan tog\'lari\n'
          '• Hisor tizmasi\n\n'
          'Xususiyatlari:\n'
          '• Salqin yoz (+15...+25°C)\n'
          '• Sovuq qish (-10...-30°C)\n'
          '• Ko\'p yog\'in (500-800 mm)\n'
          '• Qorli cho\'qqilar\n'
          '• Muzliklar',
      'geo_topic_seasons': 'Fasllar xususiyatlari',
      'geo_topic_seasons_desc':
          'Har bir faslining o\'ziga xos xususiyatlari bor.\n\n'
          'BAHOR (mart-may)\n\n'
          'Harorat:\n'
          '• Mart: +5...+15°C\n'
          '• Aprel: +15...+25°C\n'
          '• May: +20...+30°C\n\n'
          'Xususiyatlari:\n'
          '• Tez isinish\n'
          '• Eng ko\'p yog\'in\n'
          '• O\'simliklar gullaydi\n'
          '• Meva daraxtlari gullaydi\n'
          '• Ekinlarni ekish mavsumi\n'
          '• Ba\'zan sel xavfi\n\n'
          'YOZ (iyun-avgust)\n\n'
          'Harorat:\n'
          '• Iyun: +30...+38°C\n'
          '• Iyul: +35...+42°C\n'
          '• Avgust: +30...+40°C\n\n'
          'Xususiyatlari:\n'
          '• Juda issiq\n'
          '• Quruq havo\n'
          '• Kam yog\'in\n'
          '• Kun uzun\n'
          '• Hosil pishadi\n'
          '• Issiqlik to\'lqinlari\n\n'
          'KUZ (sentyabr-noyabr)\n\n'
          'Harorat:\n'
          '• Sentyabr: +25...+30°C\n'
          '• Oktyabr: +15...+20°C\n'
          '• Noyabr: +5...+10°C\n\n'
          'Xususiyatlari:\n'
          '• Sekin soviydi\n'
          '• Quruq havo\n'
          '• Hosil yig\'ish\n'
          '• Paxta terish\n'
          '• Tomorqa ishlari\n'
          '• «Oltin kuz»\n\n'
          'QISH (dekabr-fevral)\n\n'
          'Harorat:\n'
          '• Dekabr: 0...-10°C\n'
          '• Yanvar: -5...-15°C\n'
          '• Fevral: 0...-10°C\n\n'
          'Xususiyatlari:\n'
          '• Sovuq\n'
          '• Ba\'zan qor yog\'adi\n'
          '• Sovuq to\'lqinlar\n'
          '• Qisqa kunlar\n'
          '• Dam olish\n'
          '• Qish sporti (tog\'larda)',
      'geo_topic_regional_diff': 'Hududiy farqlar',
      'geo_topic_regional_diff_desc':
          'Viloyatlar bo\'yicha iqlim farqlari.\n\n'
          'SHIMOL (Toshkent, Sirdaryo)\n'
          '• O\'rtacha harorat: +13...+15°C\n'
          '• Yog\'in: 300–400 mm\n'
          '• Qish sovuqroq\n'
          '• Yoz issiqroq\n\n'
          'SHARQ (Farg\'ona, Andijon, Namangan)\n'
          '• O\'rtacha: +13...+14°C\n'
          '• Yog\'in: 200–300 mm\n'
          '• Yopiq vodiy\n'
          '• Qish salqinroq\n\n'
          'MARKAZIY (Samarqand, Jizzax, Navoiy)\n'
          '• O\'rtacha: +14...+15°C\n'
          '• Yog\'in: 300–400 mm\n'
          '• Step va tog\' aralashmasi\n'
          '• Mo\'tadil\n\n'
          'JANUB (Surxondaryo, Qashqadaryo)\n'
          '• O\'rtacha: +15...+17°C\n'
          '• Yog\'in: 200–400 mm\n'
          '• Eng issiq hudud\n'
          '• Subtropik o\'simliklar\n\n'
          'G\'ARB (Buxoro, Xorazm, Qoraqalpog\'iston)\n'
          '• O\'rtacha: +12...+14°C\n'
          '• Yog\'in: 100–200 mm\n'
          '• Cho\'l iqlimi\n'
          '• Qish sovuq, yoz issiq\n\n'
          'TOG\'LAR (Chimyon, Beldarsoy)\n'
          '• O\'rtacha: +5...+10°C\n'
          '• Yog\'in: 500–800 mm\n'
          '• Salqin yoz\n'
          '• Qorli qish\n'
          '• Muzliklar',
      'geo_topic_climate_change': 'Iqlim o\'zgarishi',
      'geo_topic_climate_change_desc':
          'Global iqlim o\'zgarishi O\'zbekistonga ta\'sir qilmoqda.\n\n'
          '1. Kuzatilayotgan o\'zgarishlar:\n'
          '• Haroratning oshishi\n'
          '  • Oxirgi 50 yilda +1.5°C\n'
          '  • Kelajakda yanada oshishi kutilmoqda\n'
          '• Muzliklar erishi\n'
          '  • Yiliga 0.5–1% kamaymoqda\n'
          '  • Suv resurslari kamayadi\n'
          '• Yog\'ingarchilik o\'zgarishi\n'
          '  • Noaniq yog\'in\n'
          '  • Ba\'zi joylarda ko\'paydi\n'
          '  • Ba\'zi joylarda kamaydi\n'
          '• Haddan tashqari hodisalar\n'
          '  • Ko\'proq issiqlik to\'lqinlari\n'
          '  • Qurg\'oqchilik tez-tez\n'
          '  • Kuchli shamollar\n\n'
          '2. Oqibatlari:\n'
          '• Qishloq xo\'jaligi uchun qiyin\n'
          '• Suv tanqisligi\n'
          '• Cho\'llanish kuchayadi\n'
          '• Ekologik muammolar\n'
          '• Sog\'liq muammolari\n\n'
          '3. Choralar:\n'
          '• Suv tejash\n'
          '• Yangi texnologiyalar\n'
          '• O\'rmon ekish\n'
          '• Yashil energiya\n'
          '• Xalqaro hamkorlik\n\n'
          '4. Prognozlar:\n'
          '• 2050-yilga qadar +2–3°C oshishi\n'
          '• Suv resurslari 10–15% kamayishi\n'
          '• Cho\'llanish kuchayishi\n'
          '• Yangi choralar zarur',
      'geo_topic_special_climate': 'Maxsus iqlim zonalari',
      'geo_topic_special_climate_desc':
          'Ba\'zi hududlarda o\'ziga xos mikroiqlim mavjud.\n\n'
          'SHAHAR IQLIMI\n'
          '• Toshkent\n'
          '  • Shahar «issiqlik oroli»\n'
          '  • 2–3°C issiqroq\n'
          '  • Kam yog\'in\n\n'
          'VODIY IQLIMI\n'
          '• Farg\'ona vodiysida\n'
          '  • Yopiq hudud\n'
          '  • Issiq yoz\n'
          '  • Salqinroq qish\n'
          '  • O\'ziga xos shamollar\n\n'
          'CHO\'L IQLIMI\n'
          '• Qizilqum\n'
          '  • Eng issiq\n'
          '  • Eng quruq\n'
          '  • Katta harorat farqi\n'
          '  • Kuchli shamollar\n\n'
          'TOG\' IQLIMI\n'
          '• Chimyon, Beldarsoy\n'
          '  • Salqin yoz\n'
          '  • Qorli qish\n'
          '  • Ko\'p yog\'in\n'
          '  • Toza havo\n\n'
          'OROL DENGIZI MINTAQASI\n'
          '• Qoraqalpog\'iston\n'
          '  • Dengiz quruvi ta\'siri\n'
          '  • Tuz bo\'ronlari\n'
          '  • Ekologik muammo\n'
          '  • Keskin iqlim\n\n'
          'TOG\' DOVONLARI\n'
          '• Qamchiq dovoni\n'
          '  • O\'zgaruvchan ob-havo\n'
          '  • Tez-tez tuman\n'
          '  • Shamollar kuchli\n'
          '  • Qish qiyinroq\n\n'
          'HAR BIR ZONA O\'ZIGA XOS:\n'
          '• Flora va fauna\n'
          '• Qishloq xo\'jaligi\n'
          '• Hayot tarzi\n'
          '• Turizm imkoniyatlari',
      'climate_stat_title': 'Iqlim statistikasi',
      'climate_stat_avg': 'O\'rtacha harorat: +14°C',
      'climate_stat_hot': 'Eng issiq: +45°C (Termiz)',
      'climate_stat_cold': 'Eng sovuq: -30°C (tog\'lar)',
      'climate_stat_rain': 'Yog\'in (o\'rtacha): 100–500 mm/yil',
      'climate_stat_sunny': 'Quyoshli kunlar: 260–300 kun/yil',
      'weather_page_title': 'Ob-havo',
      'weather_topic_elements': 'Ob-havo elementlari',
      'weather_topic_elements_desc':
          'Ob-havoni belgilovchi asosiy elementlar:\n\n'
          '1. Harorat\n'
          '• Termometr bilan o\'lchanadi\n'
          '• °C (Selsiy) yoki °F (Farengeyt)\n'
          '• Kun va tun farqi\n'
          '• Fasllar bo\'yicha o\'zgaradi\n\n'
          '2. Bosim\n'
          '• Barometr bilan o\'lchanadi\n'
          '• Millimetr simob ustuni (mm Hg)\n'
          '• Yoki gektopaskal (hPa)\n'
          '• Normal: 760 mm Hg\n\n'
          '3. Shamol\n'
          '• Anemometr bilan o\'lchanadi\n'
          '• Tezligi: m/s yoki km/soat\n'
          '• Yo\'nalishi: 8 tomon\n'
          '• Kuchiga qarab darajalanadi\n\n'
          '4. Namlik\n'
          '• Gigrometr bilan o\'lchanadi\n'
          '• Foizda (%)\n'
          '• Nisbiy va mutlaq namlik\n'
          '• Quruq va nam havo\n\n'
          '5. Yog\'ingarchilik\n'
          '• Yomg\'ir o\'lchagich\n'
          '• Millimetrda (mm)\n'
          '• Turli shakllarda (yomg\'ir, qor, do\'l)\n\n'
          '6. Bulutlilik\n'
          '• Ko\'z bilan baholanadi\n'
          '• 0–10 ball\n'
          '• Turli xil bulutlar\n'
          '• Ob-havoga ta\'siri',
      'weather_topic_types': 'Ob-havo turlari',
      'weather_topic_types_desc':
          'O\'zbekistonda turli ob-havo turlari kuzatiladi:\n\n'
          'OCHIQ (YAXSHI) OB-HAVO\n'
          '• Bulutsiz osmon\n'
          '• Issiq yoz kunlari\n'
          '• Sovuq qish kunlari\n'
          '• Yaxshi ko\'rinish\n\n'
          'BULUTLI OB-HAVO\n'
          '• Osmon bulutlar bilan qoplangan\n'
          '• Iliq\n'
          '• Yog\'in ehtimoli\n'
          '• Quyosh ko\'rinmaydi\n\n'
          'YOMG\'IRLI OB-HAVO\n'
          '• Yog\'ingarchilik\n'
          '• Bulutli\n'
          '• Salqinroq\n'
          '• Nam havo\n'
          '• Bahor va kuzda ko\'p\n\n'
          'QORLI OB-HAVO\n'
          '• Qish faslida\n'
          '• Sovuq\n'
          '• Oq qoplam\n'
          '• Asosan tog\'larda\n\n'
          'SHAMOLLAR OB-HAVOSI\n'
          '• Kuchli shamol\n'
          '• Chang ko\'tariladi\n'
          '• Bahor va kuzda\n'
          '• Transport qiyinlashadi\n\n'
          'DO\'LLI OB-HAVO\n'
          '• Yozgi bo\'ronlar\n'
          '• Muz parchalari yog\'adi\n'
          '• Ekinlarga zarar\n'
          '• Qisqa davom etadi\n\n'
          'TUMANLI OB-HAVO\n'
          '• Ko\'rinish yomon\n'
          '• Ayniqsa ertalab\n'
          '• Kuz va bahorda\n'
          '• Namlik yuqori',
      'weather_topic_forecast': 'Ob-havoni prognoz qilish',
      'weather_topic_forecast_desc':
          'Zamonaviy usullar yordamida ob-havo prognozi.\n\n'
          'KUZATUV USULLARI:\n\n'
          '1. Meteorologik stantsiyalar\n'
          '• O\'zbekistonda 100+ stantsiya\n'
          '• Soat sari ma\'lumot\n'
          '• Harorat, bosim, shamol\n'
          '• Yog\'ingarchilik\n\n'
          '2. Sun\'iy yo\'ldoshlar\n'
          '• Kosmosdan kuzatish\n'
          '• Bulutlarni monitoring\n'
          '• Harorat xaritalari\n'
          '• 24/7 monitoring\n\n'
          '3. Radar tizimlari\n'
          '• Yog\'in zonalarini aniqlash\n'
          '• Bo\'ron bashorati\n'
          '• Tezkor ma\'lumot\n\n'
          '4. Kompyuter modellari\n'
          '• Matematik hisoblash\n'
          '• Algoritmlar\n'
          '• Dunyo ma\'lumotlari\n'
          '• Aniq prognoz\n\n'
          'PROGNOZ TURLARI:\n\n'
          'Qisqa muddatli (1–3 kun)\n'
          '• Aniqlik yuqori: 85–90%\n'
          '• Tezkor o\'zgarishlar\n'
          '• Har kungi rejalar uchun\n\n'
          'O\'rta muddatli (3–10 kun)\n'
          '• Aniqlik o\'rtacha: 70–80%\n'
          '• Umumiy tendensiya\n'
          '• Haftalik rejalar\n\n'
          'Uzoq muddatli (oylar)\n'
          '• Aniqlik past: 60–70%\n'
          '• Umumiy prognoz\n'
          '• Fasliy rejalar\n\n'
          'GIDROMETSLUJBA:\n'
          '• O\'zbekiston Gidrometslujbasi\n'
          '• Prognoz e\'lon qiladi\n'
          '• Ogohlantirishlar beradi\n'
          '• Ilmiy tadqiqotlar',
      'weather_topic_dangerous': 'Xavfli ob-havo hodisalari',
      'weather_topic_dangerous_desc':
          'Tabiatning xavfli hodisalari va himoyalanish.\n\n'
          '1. ISSIQLIK TO\'LQINI\n'
          'Xususiyatlari:\n'
          '• +40°C dan yuqori\n'
          '• Yozda tez-tez\n'
          '• 5–10 kun davom etadi\n'
          'Xavflari:\n'
          '• Issiqlik urishi\n'
          '• Dehidratsiya\n'
          '• Yurak-qon tomir kasalliklari\n'
          '• Energiya tanqisligi\n'
          'Himoya:\n'
          '• Ko\'p suv ichish\n'
          '• Soyada bo\'lish\n'
          '• Engil kiyim\n'
          '• Quyoshdan himoya\n\n'
          '2. SOVUQ TO\'LQINI\n'
          'Xususiyatlari:\n'
          '• -20°C dan past\n'
          '• Qishda\n'
          '• Shimoldan keladi\n'
          'Xavflari:\n'
          '• Muzlab qolish\n'
          '• Yo\'llar muzlashi\n'
          '• Quvurlar yorilib ketishi\n'
          '• Energiya iste\'moli oshishi\n'
          'Himoya:\n'
          '• Issiq kiyinish\n'
          '• Uyda qolish\n'
          '• Isitish\n'
          '• Hayvonlarni himoya\n\n'
          '3. BO\'RON VA DO\'L\n'
          'Xususiyatlari:\n'
          '• Bahor va yoz\n'
          '• Kuchli shamol\n'
          '• Do\'l yog\'adi\n'
          'Xavflari:\n'
          '• Ekinlarga zarar\n'
          '• Uylar shikastlanishi\n'
          '• Elektr uzilishi\n'
          '• Daraxtlar yiqilishi\n'
          'Himoya:\n'
          '• Bino ichida bo\'lish\n'
          '• Avtomobilni to\'xtatish\n'
          '• Daraxtlardan uzoqroq\n'
          '• Elektr asboblarni o\'chirish\n\n'
          '4. TUMAN\n'
          'Xususiyatlari:\n'
          '• Ko\'rinish 50 m dan kam\n'
          '• Ertalab\n'
          '• Kuz va bahor\n'
          'Xavflari:\n'
          '• Transport hodisalari\n'
          '• Yo\'l ko\'rinmaydi\n'
          '• Uchish qiyin\n'
          'Himoya:\n'
          '• Sekin haydash\n'
          '• Chiroqlarni yoqish\n'
          '• Ehtiyot bo\'lish\n\n'
          '5. CHANG BO\'RONI\n'
          'Xususiyatlari:\n'
          '• Cho\'l hududlarida\n'
          '• Kuchli shamol\n'
          '• Bahor va yoz\n'
          'Xavflari:\n'
          '• Nafas olish qiyin\n'
          '• Ko\'z tirnalishi\n'
          '• Ko\'rinish yomon\n'
          '• Allergiya\n'
          'Himoya:\n'
          '• Uyda qolish\n'
          '• Respirator taqish\n'
          '• Ko\'zni himoya qilish\n'
          '• Derazalarni yopish',
      'weather_topic_local': 'Mahalliy ob-havo xususiyatlari',
      'weather_topic_local_desc':
          'Har bir viloyatning o\'ziga xos ob-havosi bor.\n\n'
          'TOSHKENT\n'
          '• O\'rtacha harorat: +14°C\n'
          '• Yoz: +35...+40°C\n'
          '• Qish: -5...-10°C\n'
          '• Yog\'in: 400–450 mm\n'
          '• Shahar issiqlik oroli\n\n'
          'FARG\'ONA VODIY SIDA\n'
          '• Yopiq vodiy\n'
          '• Issiq yoz\n'
          '• Salqinroq qish\n'
          '• O\'ziga xos mikroiqlim\n'
          '• Shamol kam\n\n'
          'SAMARQAND\n'
          '• Mo\'tadil\n'
          '• Yoz: +30...+38°C\n'
          '• Qish: 0...-8°C\n'
          '• Yog\'in: 350–400 mm\n'
          '• Quruqroq\n\n'
          'TERMIZ\n'
          '• Eng issiq hudud\n'
          '• Yoz: +40...+45°C\n'
          '• Qish: +5...0°C\n'
          '• Yog\'in: 150–200 mm\n'
          '• Subtropik\n\n'
          'CHIMYON (tog\'lar)\n'
          '• Salqin\n'
          '• Yoz: +20...+25°C\n'
          '• Qish: -10...-20°C\n'
          '• Ko\'p qor\n'
          '• Toza havo\n\n'
          'QORAQALPOG\'ISTON\n'
          '• Cho\'l iqlimi\n'
          '• Issiq yoz\n'
          '• Sovuq qish\n'
          '• Juda kam yog\'in\n'
          '• Orol ta\'siri',
      'weather_topic_activity': 'Ob-havo va faoliyat',
      'weather_topic_activity_desc':
          'Ob-havo har xil faoliyatga ta\'sir qiladi.\n\n'
          'QISHLOQ XO\'JALIGI\n'
          '• Ekin ekish vaqti\n'
          '• Sug\'orish rejasi\n'
          '• Hosil yig\'ish\n'
          '• Yog\'in va harorat muhim\n\n'
          'TRANSPORT\n'
          '• Yo\'l holati\n'
          '• Uchish sharoitlari\n'
          '• Dengiz transporti\n'
          '• Xavfsizlik choralari\n\n'
          'QURILISH\n'
          '• Beton quyish\n'
          '• Asfalt yotqizish\n'
          '• Bo\'yash ishlari\n'
          '• Ob-havo sharoitiga bog\'liq\n\n'
          'TURIZM\n'
          '• Dam olish vaqti\n'
          '• Tog\' turizmi\n'
          '• Ekskursiyalar\n'
          '• Faslga qarab\n\n'
          'SPORT\n'
          '• Ochiq havo sporti\n'
          '• Qish sporti\n'
          '• Yoz sporti\n'
          '• Ob-havo muhim\n\n'
          'SALOMATLIK\n'
          '• Bosim o\'zgarishi\n'
          '• Allergiya\n'
          '• Issiq/sovuq ta\'siri\n'
          '• Profilaktika\n\n'
          'ENERGETIKA\n'
          '• Isitish mavsumi\n'
          '• Sovutish mavsumi\n'
          '• Energiya iste\'moli\n'
          '• Tarif o\'zgarishi\n\n'
          'KUN TARTIBI\n'
          '• Kiyim tanlash\n'
          '• Reja tuzish\n'
          '• Sayohat\n'
          '• Ish rejimi',
      'weather_tips_title': 'Foydali maslahatlar',
      'weather_tip_1': 'Ob-havo ilovalaridan foydalaning',
      'weather_tip_2': 'Televidenie prognozlarini kuzating',
      'weather_tip_3': 'Haroratni tekshiring',
      'weather_tip_4': 'Yomg\'ir ehtimolini biling',
      'weather_tip_5': 'Ob-havoga mos kiyining',
      'weather_tip_6': 'Ogohlantirishlarga e\'tibor bering',
      'geo_geology_sub1': 'Tog\' jinslari',
      'geo_geology_sub2': 'Foydali qazilmalar',
      'geo_rocks_title': 'Tog\' jinslari',
      'geo_mtn_tyan': 'Tyan-Shan tog\'lari',
      'geo_mtn_tyan_m': '4,301 m',
      'geo_mtn_tyan_desc':
          'Tyan-Shan — «Osmon tog\'lari» deb nomlanadi.\n\n'
          'Joylashuvi:\n'
          '• O\'zbekiston shimoli-sharqida\n'
          '• Toshkent, Andijon, Namangan viloyatlari\n'
          '• Qirg\'iziston va Qozog\'iston bilan chegarada\n\n'
          'Asosiy tizmalar:\n'
          '• Chimyon tog\'lari (3,309 m)\n'
          '• Pskem tog\'lari (4,299 m)\n'
          '• Qorjontov tog\'lari (2,200 m)\n'
          '• Ugom-Chatqol milliy bog\'i\n\n'
          'Eng baland cho\'qqilar:\n'
          '• Adelunga tepasi — 4,301 m (eng baland)\n'
          '• Beshtor — 4,299 m\n'
          '• Pskem tepasi — 4,200 m\n'
          '• Chimyon tepasi — 3,309 m\n\n'
          'Xususiyatlari:\n'
          '• Qorli cho\'qqilar\n'
          '• Muzliklar mavjud\n'
          '• Alpinizm markazi\n'
          '• Turizm joyi\n\n'
          'Daryolar:\n'
          '• Chirchiq daryosi manbai\n'
          '• Pskem daryosi\n'
          '• Oqsu daryosi\n'
          '• Ko\'p irmoqlar\n\n'
          'Flora va fauna:\n'
          '• Archa o\'rmonlari\n'
          '• Yovvoyi hayvonlar (qo\'ng\'iz, tuya qush)\n'
          '• Tog\' echkilari\n'
          '• Yirtqich hayvonlar\n\n'
          'Dam olish maskanlari:\n'
          '• Chimyon (qishki kurort)\n'
          '• Beldarsoy\n'
          '• Pskem vodiysida\n'
          '• Alpinizm lagerlari\n\n'
          'Ahamiyati:\n'
          '• Suv manbalari\n'
          '• Turizm\n'
          '• Ekologik tizim\n'
          '• Iqlimga ta\'sir',
      'geo_mtn_pamir': 'Pamir-Oloy tog\'lari',
      'geo_mtn_pamir_m': '4,600 m',
      'geo_mtn_pamir_desc':
          'Pamir-Oloy — O\'zbekiston sharqidagi tog\' tizimi.\n\n'
          'Asosiy tizmalar:\n\n'
          'Oloy tizmasi:\n'
          '• Farg\'ona vodiysining janubida\n'
          '• Balandligi: 4,000-5,000 m\n'
          '• Qirg\'iziston bilan chegarada\n\n'
          'Turkiston tizmasi:\n'
          '• Qashqadaryo viloyatida\n'
          '• Balandligi: 4,000-5,000 m\n'
          '• Tojikiston chegarasida\n\n'
          'Zarafshon tizmasi:\n'
          '• Samarqand viloyatida\n'
          '• Balandligi: 5,489 m gacha (Fan tog\'lari)\n'
          '• Zarafshon daryosi manbai\n\n'
          'Hisor tizmasi:\n'
          '• Surxondaryo viloyatida\n'
          '• Balandligi: 4,000-4,500 m\n'
          '• Tojikiston bilan chegarada\n\n'
          'Fan tog\'lari:\n'
          '• Chimtarqa tepasi — 5,489 m\n'
          '• Turist va alpinistlar uchun mashhur\n'
          '• Ko\'llar juda ko\'p (70 dan ortiq)\n'
          '• Alouddin ko\'llari\n\n'
          'Muzliklar:\n'
          '• Zarafshon muzligi\n'
          '• Fan tog\'lari muzliklari\n'
          '• Hisor muzliklari\n'
          '• Suv manbai\n\n'
          'Daryolar manbasi:\n'
          '• Zarafshon daryosi\n'
          '• Qashqadaryo\n'
          '• Surxondaryo\n'
          '• Ko\'plab irmoqlar\n\n'
          'Aholi va qishloqlar:\n'
          '• Yaylovlar\n'
          '• Tog\' qishloqlari\n'
          '• Chorvachilik\n'
          '• Meva va yong\'oq\n\n'
          'Turizm:\n'
          '• Alpinizm\n'
          '• Piyoda sayohat\n'
          '• Tabiat turizmi\n'
          '• Madaniy turizm\n\n'
          'Foydali qazilmalar:\n'
          '• Oltin\n'
          '• Mis\n'
          '• Marmar\n'
          '• Boshqa metallar',
      'geo_mtn_nurota': 'Nurota tog\'lari',
      'geo_mtn_nurota_m': '2,169 m',
      'geo_mtn_nurota_desc':
          'Nur bilan to\'lgan tog\'lar.\n\n'
          'Joylashuvi:\n'
          '• Navoiy, Samarqand, Jizzax viloyatlarida\n'
          '• Kichik Qizilqum cho\'li yonida\n'
          '• Uzunligi: ~170 km\n\n'
          'Balandligi:\n'
          '• Eng baland: Haydarxon cho\'qqisi — 2,169 m\n'
          '• O\'rtacha: 1,000-1,500 m\n'
          '• Nisbatan past tog\'lar\n\n'
          'Xususiyatlari:\n'
          '• Petrogliflar (taxta rasmlari)\n'
          '• Qadimiy ibodatxonalar\n'
          '• Muqaddas joy\n'
          '• Turli tarixiy yodgorliklar\n\n'
          'Mashhur joylar:\n'
          '• Haydarxon cho\'qqisi\n'
          '• Hazrat Daud makoni (ziyoratgoh)\n'
          '• Nurota shahridagi muqaddas baliq\n'
          '• ~40,000 tasvir — petrogliflar xazinasi\n\n'
          'Suv resurslari:\n'
          '• Tabiiy buloq va buloqlar\n'
          '• Sug\'orish uchun suv\n'
          '• Baliq xo\'jaliklarida qo\'llaniladi\n'
          '• Ichimlik suvi manbai\n\n'
          'O\'simlik va hayvonot:\n'
          '• Yovvoyi yong\'oq va pista o\'rmonlari\n'
          '• Tog\' echkilari va yirtqich qushlar\n\n'
          'Chorvachilik:\n'
          '• Qo\'y va echki boqiladi\n'
          '• Yaylov erlari\n'
          '• Mahalliy aholi mashg\'uloti\n\n'
          'Tarixiy ahamiyat:\n'
          '• Qadimiy karvon yo\'llari\n'
          '• Tarixiy ziyoratgohlar\n'
          '• Arxeologik topilmalar\n'
          '• Madaniy meros\n\n'
          'Turizm:\n'
          '• Tarixiy turizm\n'
          '• Ziyorat turizmi\n'
          '• Tabiat turizmi\n'
          '• Arxeologik turizm\n\n'
          'Ahamiyati:\n'
          '• Ekologik tizim\n'
          '• Tarixiy meros\n'
          '• Turizm potentsiali\n'
          '• Mahalliy aholining tirikchilik manbai',
      'geo_mtn_kopet': 'Kopetdog\' tog\'lari',
      'geo_mtn_kopet_m': '1,500 m',
      'geo_mtn_kopet_desc':
          'Kopetdog\' — O\'zbekiston g\'arbidagi tog\'lar.\n\n'
          'Joylashuvi:\n'
          '• Buxoro viloyati janubi\n'
          '• Turkmaniston bilan chegarada\n'
          '• Uzunligi: ~650 km (umumiy)\n'
          '• O\'zbekistonda: ~100 km\n\n'
          'Balandligi:\n'
          '• O\'zbekistonda: 800-1,500 m\n'
          '• Nisbatan past tog\'lar\n'
          '• Tekislikdan keskin ko\'tariladi\n\n'
          'Xususiyatlari:\n'
          '• Quruq iqlim\n'
          '• Kam o\'simlik\n'
          '• Tosh va qoyalar\n'
          '• Erosiya jarayoni\n\n'
          'O\'simlik dunyosi:\n'
          '• Yovvoyi alma daraxtlari\n'
          '• Butalar\n'
          '• Saksovul\n'
          '• Yovvoyi o\'tlar\n\n'
          'Hayvonot dunyosi:\n'
          '• Tog\' echkilari\n'
          '• Tulkilar\n'
          '• Ilonlar\n'
          '• Qushlar\n\n'
          'Iqlim:\n'
          '• Issiq va quruq\n'
          '• Yozda +40°C\n'
          '• Qishda 0°C...+10°C\n'
          '• Kam yog\'ingarchilik\n\n'
          'Aholi:\n'
          '• Kam aholi\n'
          '• Chorvachilik\n'
          '• Asosan qo\'y va echki\n\n'
          'Foydali qazilmalar:\n'
          '• Qurilish materiallari\n'
          '• Ohaktosh\n'
          '• Gips\n'
          '• Shag\'al\n\n'
          'Ahamiyati:\n'
          '• Tabiiy chegara\n'
          '• Ekologik tizim\n'
          '• Chorvachilik yaylovlari\n'
          '• Foydali qazilmalar',
      'geo_mtn_qoratov': 'Qoratov tog\'lari',
      'geo_mtn_qoratov_m': '922 m',
      'geo_mtn_qoratov_desc':
          'Qoratov — «Qora tog\'lar».\n\n'
          'Joylashuvi:\n'
          '• Navoiy viloyati\n'
          '• Qizilqum cho\'li o\'rtasida\n'
          '• Uzunligi: ~50 km\n'
          '• Kengligi: ~20 km\n\n'
          'Balandligi:\n'
          '• Eng baland: 922 m\n'
          '• Past tog\'lar\n'
          '• Cho\'l o\'rtasida\n\n'
          'Xususiyatlari:\n'
          '• Qora rangli jinslar (shuning uchun nom)\n'
          '• Foydali qazilmalarga boy\n'
          '• Qadimiy jinslar\n\n'
          'Foydali qazilmalar:\n'
          '• Oltin (Muruntov koni)\n'
          '• Mis\n'
          '• Molibden\n'
          '• Volfram\n'
          '• Uran\n\n'
          'Muruntov koni:\n'
          '• Markaziy Osiyoning eng yirik oltin koni\n'
          '• Ochiq usulda qazib olinadi\n'
          '• Zarafshon shahri qurilgan\n'
          '• Ming kishiga ish beradi\n\n'
          'O\'simlik va hayvonot:\n'
          '• Cho\'l o\'simliklari, saksovul\n'
          '• Cho\'l hayvonlari, kaltakesaklar\n\n'
          'Iqlim:\n'
          '• Kontinental cho\'l iqlimi\n'
          '• Yozda juda issiq (+45°C)\n'
          '• Qishda sovuq (-15°C)\n'
          '• Juda kam yog\'ingarchilik\n\n'
          'Aholi:\n'
          '• Kon ishchilari\n'
          '• Zarafshon shahri\n'
          '• Uchquduq shahri\n'
          '• Navbahor shaharchasi\n\n'
          'Ahamiyati:\n'
          '• Iqtisodiy ahamiyat (oltin)\n'
          '• Ish o\'rinlari\n'
          '• Eksport mahsuloti\n'
          '• Davlat byudjeti',
      'geo_mtn_qurama': 'Qurama tog\'lari',
      'geo_mtn_qurama_m': '3,769 m',
      'geo_mtn_qurama_desc':
          'Qurama — Tyan-Shan tizimining qismi.\n\n'
          'Joylashuvi:\n'
          '• Toshkent va Namangan viloyatlari\n'
          '• Farg\'ona vodiysining shimoli-g\'arbida\n'
          '• Uzunligi: ~170 km\n\n'
          'Balandligi:\n'
          '• Boysuntov tepasi — 3,769 m\n'
          '• O\'rtacha: 2,000-3,000 m\n'
          '• Tosh va qoyali tog\'lar\n\n'
          'Xususiyatlari:\n'
          '• Farg\'ona vodiysi va Mirzacho\'lni ajratadi\n'
          '• Tabiiy to\'siq\n'
          '• Transport yo\'llari qiyin\n\n'
          'Dovonlar:\n'
          '• Qamchiq dovoni (Toshkent-Andijon)\n'
          '• Balandligi: 2,267 m\n'
          '• Yil bo\'yi ochiq\n'
          '• Yo\'l tunnel orqali\n'
          '• Qo\'ytepa dovoni\n'
          '• Boshqa kichik dovonlar\n\n'
          'Daryolar:\n'
          '• Chirchiq daryosi\n'
          '• Angren daryosi\n'
          '• Qorasuu daryosi\n\n'
          'O\'simliklar:\n'
          '• Archa o\'rmonlari\n'
          '• Yong\'oq daraxtlari\n'
          '• Alplararo o\'tlar\n'
          '• Manzarali o\'simliklar\n\n'
          'Hayvonlar:\n'
          '• Tog\' echkilari\n'
          '• Yovvoyi cho\'chqalar\n'
          '• Qushlar\n'
          '• Yirtqichlar\n\n'
          'Turizm:\n'
          '• Tog\' turizmi\n'
          '• Qish sporti\n'
          '• Tabiat turizmi\n'
          '• Piyoda sayohatlar\n\n'
          'Ahamiyati:\n'
          '• Transport yo\'li (Qamchiq tunnel)\n'
          '• Suv manbalari\n'
          '• Turizm\n'
          '• Ekologik tizim\n\n'
          'Tarix:\n'
          '• Qadimiy karvon yo\'llari\n'
          '• Ipak yo\'li orqali\n'
          '• Tarixiy dovonlar',
      'geo_mount_info_title': 'Tog\'lar haqida umumiy ma\'lumot',
      'geo_mount_info_share': 'Tog\'lar ulushi: ~20% (hudud)',
      'geo_mount_info_peak': 'Eng baland: Adelunga (4,301 m) — Tyan-Shan',
      'geo_mount_info_systems': 'Asosiy tizimlar: Tyan-Shan, Pamir-Oloy',
      'geo_mount_info_glaciers': 'Muzliklar: ~650 km²',
      'geo_mount_info_value': 'Ahamiyati: suv, turizm, foydali qazilmalar',
      'geo_mins_title': 'Foydali qazilmalar',
      'geo_mins_head': 'O\'zbekiston foydali qazilmalarga boy',
      'geo_mins_lead': 'O\'zbekistonda 100 dan ortiq foydali qazilmalar va 2,000 dan ortiq kon va konchiliklar mavjud.',
      'geo_min_gold': 'Oltin',
      'geo_min_gold_sub': 'Qimmatbaho metall',
      'geo_min_gold_desc':
          'O\'zbekiston dunyoda oltin bo\'yicha 4-o\'rinda turadi.\n\n'
          'Asosiy konlar:\n\n'
          'Muruntov koni (Navoiy viloyati):\n'
          '• Markaziy Osiyoning eng yirik koni\n'
          '• Ochiq usulda qazib olinadi\n'
          '• Yiliga 60-70 tonna\n\n'
          '• Qizilqum koni (Navoiy viloyati)\n'
          '• Amantaytoy koni (Jizzax viloyati)\n'
          '• Charmitan koni (Navoiy viloyati)\n'
          '• Marjonbuloq (Jizzax viloyati)\n\n'
          'Zahiralar:\n'
          '• Aniqlangan zahiralar: 3,000 tonna\n'
          '• Yillik qazib olish: 100 tonna\n'
          '• Jahon ishlab chiqarishida: 3.3%\n\n'
          'Qo\'llanilishi:\n'
          '• Tilla zargarlik buyumlari\n'
          '• Investitsiya\n'
          '• Valyuta zahirasi\n'
          '• Elektronika sanoati\n'
          '• Tibbiyotda\n\n'
          'Eksport:\n'
          '• Jahon bozoriga chiqariladi\n'
          '• Asosiy eksport mahsulotlaridan\n'
          '• Valyuta kirim manbai\n\n'
          'Tarix:\n'
          '• Qadimdan qazib olinadi\n'
          '• Ipak yo\'li davri\n'
          '• Sovet davri kengaydi\n'
          '• Mustaqillikdan keyin rivojlandi\n\n'
          'Ishlab chiqarish:\n'
          '• «Navoi Kon-Metallurgiya Kombinati»\n'
          '• Zamonaviy texnologiyalar\n'
          '• Ekologik standartlarga rioya',
      'geo_min_copper': 'Mis',
      'geo_min_copper_sub': 'Rangli metall',
      'geo_min_copper_desc':
          'O\'zbekistonda yirik mis konlari mavjud.\n\n'
          'Asosiy konlar:\n\n'
          'Olmaliq konlar kombinati (Toshkent viloyati):\n'
          '• Eng yirik mis ishlab chiqaruvchi\n'
          '• Molibden ham qazib olinadi\n'
          '• 1951-yildan beri ishlaydi\n\n'
          '• Qalmoqir koni\n'
          '• Handiza koni\n'
          '• Kalmakir koni\n\n'
          'Ishlab chiqarish:\n'
          '• Yillik: ~100,000 tonna\n'
          '• Markaziy Osiyoda yetakchi\n'
          '• Jahon bozorida ishtirok etadi\n\n'
          'Qo\'llanilishi:\n'
          '• Elektr simlari\n'
          '• Qurilish materiallari\n'
          '• Mashinasozlik\n'
          '• Transport\n'
          '• Elektronika\n\n'
          'Hamroh metallar:\n'
          '• Molibden\n'
          '• Oltingugurt\n'
          '• Rux\n'
          '• Kumush\n\n'
          '«Almaliq KMK»:\n'
          '• 1951-yilda tashkil etilgan\n'
          '• 10,000+ ishchilar\n'
          '• Eksport orientatsiyalangan\n'
          '• Zamonaviy texnologiyalar\n\n'
          'Ekologiya:\n'
          '• Tozalash inshootlari\n'
          '• Chiqindilarni qayta ishlash\n'
          '• Atrof-muhitni muhofaza qilish',
      'geo_min_gas': 'Tabiiy gaz',
      'geo_min_gas_sub': 'Energiya resursi',
      'geo_min_gas_desc':
          'O\'zbekiston Markaziy Osiyoda eng yirik gaz ishlab chiqaruvchi.\n\n'
          'Asosiy konlar:\n\n'
          'Gazli koni (Buxoro viloyati):\n'
          '• Eng yirik koni\n'
          '• 1956-yilda ochilgan\n'
          '• O\'zbekiston gazining ~30%\n\n'
          '• Shurtan koni (Qashqadaryo)\n'
          '• Qorako\'l koni (Buxoro)\n'
          '• Ustyurt koni (Qoraqalpog\'iston)\n'
          '• Dengizko\'l koni\n\n'
          'Zahiralar:\n'
          '• Aniqlangan: 1.8 trillion m³\n'
          '• Jahon zahiralarining: 0.6%\n'
          '• 30-40 yil yetishi baholanadi\n\n'
          'Ishlab chiqarish:\n'
          '• Yillik: 60-65 mlrd m³\n'
          '• Ichki iste\'mol: ~50 mlrd m³\n'
          '• Eksport: ~10-15 mlrd m³\n\n'
          'Qo\'llanilishi:\n'
          '• Elektr energiya ishlab chiqarish\n'
          '• Sanoat\n'
          '• Aholi uy-joy ehtiyojlari\n'
          '• Kimyo sanoati\n'
          '• Transport (gaz yoqilg\'i)\n\n'
          'Eksport:\n'
          '• Rossiya\n'
          '• Xitoy\n'
          '• Qozog\'iston\n\n'
          'Quvur yo\'llari:\n'
          '• Markaziy Osiyo-Xitoy\n'
          '• Shimoliy yo\'nalish\n'
          '• Ichki tarmoqlar\n\n'
          'Kelajak:\n'
          '• Yangi konlarni ochish\n'
          '• Gazni qayta ishlash\n'
          '• Kimyo mahsulotlari',
      'geo_min_oil': 'Neft',
      'geo_min_oil_sub': 'Energiya resursi',
      'geo_min_oil_desc':
          'O\'zbekistonda neft konlari mavjud.\n\n'
          'Asosiy konlar:\n\n'
          'Mingbuloq koni (Namangan viloyati):\n'
          '• Eng qadimiy (1992)\n'
          '• Yillik: 1+ million tonna\n\n'
          '• Kokdumalak koni (Qashqadaryo)\n'
          '• Alamberdi koni (Qashqadaryo)\n'
          '• Surgil koni (Surxondaryo)\n'
          '• Qorako\'l koni (Buxoro)\n\n'
          'Zahiralar:\n'
          '• Taxminan 600 million tonna\n'
          '• Yangi konlar ochilmoqda\n\n'
          'Ishlab chiqarish:\n'
          '• Yillik: ~3-4 million tonna\n'
          '• Ichki ehtiyojni qoplaydi\n'
          '• Import qisman kerak\n\n'
          'Qo\'llanilishi:\n'
          '• Transport yoqilg\'i (benzin, dizel)\n'
          '• Neftni qayta ishlash\n'
          '• Kimyo sanoati\n'
          '• Isitish uchun mazut\n\n'
          'Neft qayta ishlash:\n'
          '• Farg\'ona neft zavodi\n'
          '• Buxoro neft zavodi\n'
          '• Shahrisabz zavodlari\n\n'
          'Mahsulotlar:\n'
          '• Benzin (A-80, A-91, A-95)\n'
          '• Dizel\n'
          '• Aviakerosen\n'
          '• Mazut\n'
          '• Moylar\n\n'
          'Rivojlanish:\n'
          '• Yangi konlarni qidirish\n'
          '• Zavodlarni modernizatsiya qilish\n'
          '• Ekologik texnologiyalar',
      'geo_min_coal': 'Ko\'mir',
      'geo_min_coal_sub': 'Qattiq yoqilg\'i',
      'geo_min_coal_desc':
          'O\'zbekistonda ko\'mir konlari mavjud.\n\n'
          'Asosiy konlar:\n\n'
          'Angren koni (Toshkent viloyati):\n'
          '• Eng yirik\n'
          '• Qo\'ng\'ir ko\'mir\n'
          '• Ochiq usulda\n\n'
          '• Sharg\'un koni (Surxondaryo)\n'
          '• Boysun koni (Surxondaryo)\n\n'
          'Zahiralar:\n'
          '• ~1.8 mlrd tonna\n'
          '• Asosan qo\'ng\'ir ko\'mir\n\n'
          'Ishlab chiqarish:\n'
          '• Yillik: 3-4 million tonna\n'
          '• Asosan Angren konida\n\n'
          'Qo\'llanilishi:\n'
          '• Issiqlik elektr stantsiyalari\n'
          '• Angren IES\n'
          '• Sanoat korxonalari\n'
          '• Mahalliy isitish\n\n'
          '«Angrenko\'mir»:\n'
          '• 1940-yildan beri\n'
          '• Yer osti va ochiq konlar\n'
          '• Modernizatsiya qilinmoqda\n\n'
          'Ekologiya:\n'
          '• Tutun tozalash\n'
          '• Rekultivatsiya\n'
          '• Zamonaviy texnologiyalar\n\n'
          'Kelajak:\n'
          '• Yashil energetikaga o\'tish\n'
          '• Ekologik talablar\n'
          '• Zavodlarni rekonstruksiya',
      'geo_min_uranium': 'Uran',
      'geo_min_uranium_sub': 'Radioaktiv metall',
      'geo_min_uranium_desc':
          'O\'zbekiston uranga boy davlatlardan biri.\n\n'
          'Asosiy konlar:\n'
          '• Uchquduq koni (Navoiy viloyati)\n'
          '• Zarafshon koni (Navoiy)\n'
          '• Nurabod koni\n\n'
          'Zahiralar:\n'
          '• Jahon zahiralarining 2%\n'
          '• Aniq raqamlar maxfiy\n\n'
          'Ishlab chiqarish:\n'
          '• Yillik: 2,400-3,000 tonna\n'
          '• Jahonda 7-o\'rinda\n\n'
          'Qo\'llanilishi:\n'
          '• Atom elektr stantsiyalari yoqilg\'isi\n'
          '• Tibbiyotda\n'
          '• Ilmiy tadqiqotlar\n'
          '• Harbiy maqsadlar (boshqa mamlakatlarda)\n\n'
          '«Navoiy KMK»:\n'
          '• Uran qazib olish va qayta ishlash\n'
          '• Xavfsizlik choralari yuqori\n'
          '• Xalqaro nazorat ostida\n\n'
          'Eksport:\n'
          '• Rossiya\n'
          '• Xitoy\n'
          '• Janubiy Koreya\n'
          '• Yevropaning ba\'zi mamlakatlari\n\n'
          'Xavfsizlik:\n'
          '• Maxfiy ob\'ekt\n'
          '• Radiatsiya nazorati\n'
          '• Ekologik standartlar\n'
          '• Xalqaro talablar\n\n'
          'Ahamiyati:\n'
          '• Strategik resurs\n'
          '• Energetika uchun\n'
          '• Eksport mahsuloti',
      'geo_min_build': 'Qurilish materiallari',
      'geo_min_build_sub': 'Nometallar',
      'geo_min_build_desc':
          'O\'zbekistonda ko\'plab qurilish materiallari qazib olinadi.\n\n'
          'Ohaktosh va gips:\n'
          '• Samarqand, Qashqadaryo, Jizzax viloyatlari\n'
          '• Qurilishda ishlatiladi\n\n'
          'Granit va marmar:\n'
          '• Jizzax (marmar), Samarqand, Toshkent viloyatlari\n'
          '• Bezak toshi\n\n'
          'Ohaktosh (kaltsiy karbonat, tsement uchun):\n'
          '• Samarqand, Surxondaryo\n'
          '• Tsement ishlab chiqarish\n\n'
          'Gips:\n'
          '• Ko\'plab viloyatlarda\n'
          '• Qurilish materiallari\n\n'
          'Qum va shag\'al:\n'
          '• Amudaryo, Sirdaryo vodiylari\n'
          '• Beton uchun\n\n'
          'Gil:\n'
          '• Ko\'plab hududlarda\n'
          '• G\'isht ishlab chiqarish, keramika\n\n'
          'Tsement zavodlari:\n'
          '• Quvasoy (Farg\'ona)\n'
          '• Bekobod (Toshkent)\n'
          '• Ohangaron (Toshkent)\n'
          '• Sherobod (Surxondaryo)\n\n'
          'Ishlab chiqarish:\n'
          '• Yillik tsement: 8-10 million tonna\n'
          '• G\'isht: millionlab dona\n'
          '• Marmar eksport qilinadi\n\n'
          'Ahamiyati:\n'
          '• Qurilish sanoati uchun\n'
          '• Ichki ehtiyojni qoplaydi\n'
          '• Ba\'zilari eksport qilinadi',
      'geo_min_salt': 'Tuz va boshqa minerallar',
      'geo_min_salt_sub': 'Kimyoviy xom ashyo',
      'geo_min_salt_desc':
          'Turli kimyoviy xom ashyo manbalari mavjud.\n\n'
          'Tuz:\n'
          '• Orol dengizi atrofida\n'
          '• Qoraqalpog\'istonda\n'
          '• Tabiiy tuz ko\'llari\n\n'
          'Fosforitlar:\n'
          '• Qashqadaryo viloyati\n'
          '• Surxondaryo viloyati\n'
          '• O\'g\'it ishlab chiqarish\n\n'
          'Oltingugurt:\n'
          '• Surxondaryo viloyati\n'
          '• Farg\'ona viloyati\n'
          '• Gazni qayta ishlashda\n\n'
          'Kaolin:\n'
          '• Angren (Toshkent)\n'
          '• Keramika sanoati\n'
          '• Chinni va kulolchilik\n\n'
          'Qo\'rg\'oshin va rux:\n'
          '• Olmaliq KMK\n'
          '• Olmaliq konlarida\n'
          '• Mis bilan birga\n\n'
          'Volfram va molibden:\n'
          '• Olmaliq KMK\n'
          '• Qoratov tog\'larida\n'
          '• Po\'lat sanoati uchun\n\n'
          'Qimmatbaho toshlar:\n'
          '• Turquaz (firoza)\n'
          '• Lazurit\n'
          '• Granat\n'
          '• Zargarlik uchun\n\n'
          'Ahamiyati:\n'
          '• Kimyo sanoati\n'
          '• Qishloq xo\'jaligi (o\'g\'itlar)\n'
          '• Sanoat',
      'geo_mins_stat_title': 'Foydali qazilmalar statistikasi',
      'geo_mins_stat_types': 'Umumiy turlar soni: 100+ tur',
      'geo_mins_stat_mines': 'Kon va konchilik joylari: 2,000+',
      'geo_mins_stat_gold': 'Oltin (jahonda): 4-o\'rin',
      'geo_mins_stat_uran': 'Uran (jahonda): 7-o\'rin',
      'geo_mins_stat_export': 'Asosiy eksport: oltin, mis, gaz',
      'geo_land_sub1': 'Relyef turlari',
      'geo_land_sub2': 'Tabiiy hodisalar',
      'geo_relief_title': 'Relyef turlari',
      'geo_relief_uz_relyefi': 'O\'zbekiston relyefi',
      'geo_relief_lead': 'O\'zbekiston relyefi juda xilma-xil: tekisliklar, tog\'lar, vodiylar va cho\'llar mavjud.',
      'geo_rel_tog': 'Tog\'lar',
      'geo_rel_tog_desc':
          'O\'zbekiston hududining sharqiy va janubi-sharqiy qismida joylashgan.\n\n'
          'Asosiy tog\' tizimlari:\n\n'
          '1. Tyan-Shan tog\'lari (Shimoli-sharq)\n'
          '• Eng baland: Adelunga tepasi (4,301 m)\n'
          '• Chimyon tog\'lari\n'
          '• Pskem tog\'lari\n'
          '• Qorjontov tog\'lari\n\n'
          '2. Pamir-Oloy tog\'lari (Sharq)\n'
          '• Oloy tizmasi\n'
          '• Turkiston tizmasi\n'
          '• Zarafshon tizmasi\n'
          '• Hisor tizmasi\n\n'
          '3. Kopetdog\' tog\'lari (G\'arb)\n'
          '• Turkmaniston bilan chegarada\n'
          '• Past tog\'lar (1,000-1,500 m)\n\n'
          'Xususiyatlari:\n'
          '• Balandligi: 1,000-4,300 m\n'
          '• Qorli cho\'qqilar\n'
          '• Muzliklar\n'
          '• Daryolar manbalari\n'
          '• Mineralli suvlar\n\n'
          'Ahamiyati:\n'
          '• Suv resurslari\n'
          '• Turizm va alpinizm\n'
          '• Foydali qazilmalar\n'
          '• Yaylov erlari',
      'geo_rel_tekis': 'Tekisliklar',
      'geo_rel_tekis_desc':
          'O\'zbekiston hududining katta qismini egallaydi.\n\n'
          'Asosiy tekisliklar:\n\n'
          '1. Turon pastligi\n'
          '• Eng katta tekislik\n'
          '• Balandligi: 200-500 m\n'
          '• Qizilqum cho\'li joylashgan\n\n'
          '2. Mirzacho\'l (Golodnya step)\n'
          '• Sirdaryo havzasida\n'
          '• Suv ta\'minoti yaxshi\n'
          '• Qishloq xo\'jaligi\n\n'
          '3. Zarafshon vodiysidagi tekisliklar\n'
          '• Samarqand va Buxoro atrofi\n'
          '• Unumdor yerlar\n'
          '• Sug\'oriladigan qishloq xo\'jaligi\n\n'
          '4. Sherabad vodiysidagi tekisliklar\n'
          '• Surxondaryo viloyati\n'
          '• Issiq iqlim\n'
          '• Paxta yetishtirish\n\n'
          'Xususiyatlari:\n'
          '• Yassi sirt\n'
          '• Sug\'oriladigan yerlar\n'
          '• Qishloq xo\'jaligi uchun qulay\n'
          '• Transport rivojlangan\n\n'
          'Foydalanish:\n'
          '• Qishloq xo\'jaligi\n'
          '• Shahar qurilishi\n'
          '• Sanoat joylashtirilgan',
      'geo_rel_cho': 'Cho\'llar',
      'geo_rel_cho_desc':
          'O\'zbekistonda ikki yirik cho\'l mavjud.\n\n'
          '1. Qizilqum cho\'li (Kyzylkum)\n'
          '• Maydoni: ~300,000 km²\n'
          '• O\'zbekiston va Qozog\'iston\n'
          '• Qum tepaliklardan iborat\n'
          '• Kam yog\'ingarchilik\n\n'
          'Xususiyatlari:\n'
          '• Qizil rangli qumlar\n'
          '• Saksovul o\'rmonlari\n'
          '• Hayvonot dunyosi kam\n'
          '• Yoz +45°C, qish -25°C\n\n'
          '2. Qoraqum cho\'li (Karakum)\n'
          '• Qoraqalpog\'istonda\n'
          '• Amudaryo yaqinida\n'
          '• Qora rangli qumlar\n\n'
          'Xususiyatlari:\n'
          '• Qora loy qumlar\n'
          '• Sho\'r tuproqlar\n'
          '• Orol dengizi ta\'siri\n'
          '• Ekologik muammolar\n\n'
          'Cho\'llarda:\n'
          '• Gaz va neft konlari\n'
          '• Chorvachilik (qarakul qo\'ylari)\n'
          '• Saksovul yog\'ochi\n'
          '• Transport yo\'llari\n\n'
          'Muammolar:\n'
          '• Suv tanqisligi\n'
          '• Cho\'llanish jarayoni\n'
          '• Orol dengizi quruvi ta\'siri',
      'geo_rel_vod': 'Vodiylar',
      'geo_rel_vod_desc':
          'Tog\'lar orasidagi past hududlar, daryolar oqadi.\n\n'
          'Asosiy vodiylar:\n\n'
          '1. Farg\'ona vodiysi (Fergana)\n'
          '• Maydoni: ~22,000 km²\n'
          '• Eng qadimiy madaniyat markazi\n'
          '• Zich aholi\n\n'
          'Xususiyatlari:\n'
          '• Tog\'lar bilan o\'ralgan\n'
          '• Unumdor tuproq\n'
          '• Sug\'oriladigan qishloq xo\'jaligi\n'
          '• Meva va paxta\n\n'
          'Viloyatlar:\n'
          '• Andijon\n'
          '• Namangan\n'
          '• Farg\'ona\n\n'
          '2. Zarafshon vodiysida\n'
          '• Samarqand va Buxoro\n'
          '• Tarixiy shaharlar\n'
          '• Zarafshon daryosi\n\n'
          '3. Surxondaryo vodiysida\n'
          '• Janubiy viloyat\n'
          '• Issiq iqlim\n'
          '• Paxta va sabzavotlar\n\n'
          '4. Qashqadaryo vodiysida\n'
          '• Qarshi shahri\n'
          '• Qishloq xo\'jaligi\n'
          '• Tabiiy gaz\n\n'
          'Ahamiyati:\n'
          '• Qishloq xo\'jaligi markazi\n'
          '• Aholi zich joylashgan\n'
          '• Sanoat rivojlangan\n'
          '• Tarixiy shaharlar',
      'geo_rel_plat': 'Platolar',
      'geo_rel_plat_desc':
          'Baland tekis yuzalar.\n\n'
          'Asosiy platolar:\n\n'
          '1. Ustyurt platosi\n'
          '• Qoraqalpog\'istonda\n'
          '• Balandligi: 200 m\n'
          '• Yassi sirt\n'
          '• Cho\'l iqlimi\n\n'
          'Xususiyatlari:\n'
          '• Qattiq jinslar\n'
          '• Kam o\'simlik\n'
          '• Qarakul qo\'ylari\n'
          '• Foydali qazilmalar\n\n'
          '2. Qoratov tog\'lari\n'
          '• Navoiy viloyati\n'
          '• Past tog\'lar\n'
          '• Foydali qazilmalar\n\n'
          '3. Nurota tog\'lari\n'
          '• Zarafshon va Samarqand viloyatlari\n'
          '• Balandligi: 2,000 m gacha\n'
          '• Yaylovlar\n\n'
          'Foydali qazilmalar:\n'
          '• Oltin konlari\n'
          '• Mis konlari\n'
          '• Uran\n'
          '• Fosforitlar\n\n'
          'Chorvachilik:\n'
          '• Yaylov erlari\n'
          '• Qo\'y va echki\n'
          '• Mol-qo\'y',
      'geo_rel_river': 'Daryolar vodiysidagi relyef',
      'geo_rel_river_desc':
          'Daryolar atrofidagi past hududlar.\n\n'
          'Asosiy daryolar:\n\n'
          '1. Amudaryo\n'
          '• Uzunligi: 1,415 km (O\'zbekistonda)\n'
          '• Manba: Pamir muzliklari\n'
          '• Orol dengiziga quyiladi\n\n'
          'Vodiysidagi relyef:\n'
          '• Tekis ovaliklar\n'
          '• Deltalik hududlar\n'
          '• Unumdor tuproq\n'
          '• Sug\'orish tizimi\n\n'
          '2. Sirdaryo\n'
          '• Uzunligi: 2,212 km\n'
          '• Manba: Tyan-Shan muzliklari\n'
          '• Orol dengiziga quyiladi\n\n'
          'Vodiysidagi relyef:\n'
          '• Mirzacho\'l tekisligi\n'
          '• Farg\'ona vodiysidan o\'tadi\n'
          '• Sug\'oriladigan yerlar\n\n'
          '3. Zarafshon\n'
          '• Uzunligi: 877 km\n'
          '• Samarqand va Buxoro orqali\n'
          '• Cho\'lda yo\'qoladi\n\n'
          'Vodiysidagi relyef:\n'
          '• Tarixiy shaharlar joylashgan\n'
          '• Qadimiy madaniyat\n'
          '• Unumdor tuproq\n\n'
          'Xususiyatlari:\n'
          '• Allyuvial tuproqlar\n'
          '• Yuqori unumdorlik\n'
          '• Suv ta\'minoti yaxshi',
      'geo_relief_stat_title': 'Relyef bo\'yicha statistika',
      'geo_relief_stat_high': 'Eng baland nuqta: Adelunga (4,301 m)',
      'geo_relief_stat_low': 'Eng past nuqta: Orol dengizi (-28 m)',
      'geo_relief_stat_avg': 'O\'rtacha balandlik: ~600 m',
      'geo_relief_stat_mtn': 'Tog\'lar ulushi: ~20%',
      'geo_relief_stat_plain': 'Tekisliklar ulushi: ~80%',
      'geo_phenomena_title': 'Tabiiy hodisalar',
      'geo_ph_quake': 'Zilzilalar',
      'geo_ph_quake_desc':
          'O\'zbekiston zilzila xavfi yuqori hududlarda joylashgan.\n\n'
          'Zilzila zonalari:\n'
          '• Toshkent - 1966-yil kuchli zilzila (8-9 ball)\n'
          '• Farg\'ona vodiysida - 7-8 ball\n'
          '• Andijon - 1902-yil (6-7 ball)\n'
          '• Namangan - tarixiy zilzilalar\n\n'
          'Sabablar:\n'
          '• Hindiston plitasining harakati\n'
          '• Tog\' qurilish jarayoni davom etadi\n'
          '• Yer qobig\'i kuchlanishi\n'
          '• Geologik zonalar tutashuvida\n\n'
          'Oqibatlari:\n'
          '• Binolarning vayron bo\'lishi\n'
          '• Insonlar qurboni\n'
          '• Iqtisodiy zarar\n'
          '• Infrastruktura buzilishi\n\n'
          'Himoya choralari:\n'
          '• Zilzilabardoshlik qoidalariga rioya\n'
          '• Binolarni mustahkamlash\n'
          '• Aholi orasida targ\'ibot\n'
          '• Favqulodda vaziyatlarga tayyorgarlik\n'
          '• Monitoring tizimi\n\n'
          'Tarix:\n'
          '• 1966-yil Toshkent zilzilasi - eng yirik\n'
          '• Shahar qayta qurildi\n'
          '• Butun SSSR yordami\n'
          '• Zamonaviy shahar paydo bo\'ldi',
      'geo_ph_sel': 'Sel oqimlari',
      'geo_ph_sel_desc':
          'Bahorgi muzlik erishi va kuchli yog\'ingarchiliklardan kelib chiqadi.\n\n'
          'Xavfli hududlar:\n'
          '• Tog\'li viloyatlar\n'
          '• Farg\'ona vodiysida\n'
          '• Surxondaryo viloyati\n'
          '• Qashqadaryo viloyati\n'
          '• Samarqand viloyati\n\n'
          'Sabablari:\n'
          '• Tog\'larda qor va muzlik erishi\n'
          '• Kuchli yomg\'irlar\n'
          '• O\'rmonlarning kesilishi\n'
          '• Tuproq eroziyasi\n'
          '• Daryolar to\'lib-toshishi\n\n'
          'Oqibatlari:\n'
          '• Yo\'llarning yuvilib ketishi\n'
          '• Uylarning buzilishi\n'
          '• Qishloq xo\'jaligi mahsulotlariga zarar\n'
          '• Transport yo\'llarining uzilishi\n'
          '• Odamlar qurboni\n\n'
          'Oldini olish:\n'
          '• To\'g\'onlar qurish\n'
          '• Daryolarni tozalash\n'
          '• O\'rmon ekish\n'
          '• Monitoring tizimi\n'
          '• Aholini ogohlantirish\n\n'
          'Eng xavfli davrlar:\n'
          '• Mart-aprel (bahor)\n'
          '• May-iyun (muzlik erishi)\n'
          '• Sentyabr (kuzgi yomg\'irlar)',
      'geo_ph_qong': 'Qo\'ng\'irtovlar',
      'geo_ph_qong_desc':
          'Qishloq xo\'jaligiga katta zarar yetkazadigan hasharotlar.\n\n'
          'Turlari:\n'
          '• Italyan (Marokash) qo\'ng\'irtovi\n'
          '• O\'rmon qo\'ng\'irtovi\n'
          '• Osiyo qo\'ng\'irtovi\n\n'
          'Xavfli hududlar:\n'
          '• Jizzax viloyati\n'
          '• Navoiy viloyati\n'
          '• Samarqand viloyati\n'
          '• Qashqadaryo viloyati\n\n'
          'Hayot aylanishi:\n'
          '• Tuxum - kuzda\n'
          '• Lichinka - bahorda\n'
          '• Voyaga yetgan - yozda\n'
          '• Uchish - may-iyun\n'
          '• Tuxum qo\'yish - iyul-avgust\n\n'
          'Zarari:\n'
          '• O\'simliklarni yeb qo\'yadi\n'
          '• Hosil yo\'qoladi\n'
          '• Yaylovlarga zarar\n'
          '• Iqtisodiy yo\'qotish katta\n\n'
          'Kurashish usullari:\n'
          '• Kimyoviy preparatlar\n'
          '• Biologik usul (dushman hasharotlar)\n'
          '• Tuxumlarni yo\'q qilish\n'
          '• Monitoring va bashorat\n'
          '• Aholi ishtirokida kurash\n\n'
          'Tarix:\n'
          '• 2019-2020-yillar - keng tarqaldi\n'
          '• Davlat dasturi ishlab chiqildi\n'
          '• Xalqaro hamkorlik',
      'geo_ph_drought': 'Qurg\'oqchilik',
      'geo_ph_drought_desc':
          'Uzoq muddat yog\'ingarchilik yo\'qligi yoki kam bo\'lishi.\n\n'
          'Sabablari:\n'
          '• Iqlim o\'zgarishi\n'
          '• Kontinental iqlim\n'
          '• Dengizdan uzoqlik\n'
          '• Atmosfera jarayonlari\n\n'
          'Oqibatlari:\n'
          '• Hosil pasayishi\n'
          '• Chorvador mollariga yem yetishmaydi\n'
          '• Suv tanqisligi\n'
          '• Cho\'llanish jarayoni\n'
          '• Iqtisodiy zarar\n\n'
          'Xavfli hududlar:\n'
          '• Qoraqalpog\'iston\n'
          '• Buxoro viloyati\n'
          '• Navoiy viloyati\n'
          '• Qizilqum cho\'li atrofi\n\n'
          'Ta\'sir:\n'
          '• Qishloq xo\'jaligi zarari\n'
          '• Aholi suv ta\'minoti\n'
          '• Sanoat ishlab chiqarishi\n'
          '• Ekologiya buzilishi\n\n'
          'Oldini olish:\n'
          '• Sug\'orish tizimini yaxshilash\n'
          '• Suv tejovchi texnologiyalar\n'
          '• Quruq yog\'inlarga chidamli navlar\n'
          '• O\'rmon ekish\n'
          '• Suv omborlarini qurish\n\n'
          'Davrlar:\n'
          '• 3-5 yilda bir marta\n'
          '• 10-15 yilda kuchli qurg\'oqchilik\n'
          '• Yoz oylarida eng qattiq',
      'geo_ph_wind': 'Shamollar',
      'geo_ph_wind_desc':
          'O\'zbekistonda turli yo\'nalishdagi shamollar mavjud.\n\n'
          'Shamol turlari:\n\n'
          '1. Afgon (janubdan)\n'
          '• Issiq va quruq\n'
          '• Yozda tez-tez\n'
          '• Haroratni oshiradi\n'
          '• Chang ko\'taradi\n\n'
          '2. Bo\'ron shamoli\n'
          '• Bahorgi kuchli shamol\n'
          '• Tezligi: 20-30 m/s\n'
          '• Binolarga zarar\n'
          '• Daraxtlarni sindiradi\n\n'
          '3. Fon (tog\'dan tushadigan)\n'
          '• Issiq va quruq\n'
          '• Tog\' viloyatlarida\n'
          '• Qor eritadi\n\n'
          '4. Bryz (yerli shamol)\n'
          '• Tog\' va vodiy o\'rtasida\n'
          '• Kunduzi va kechasi farq qiladi\n'
          '• Iqlimga ta\'siri\n\n'
          'Oqibatlari:\n'
          '• Erosiya (tuproq uchib ketishi)\n'
          '• O\'simliklarning shikastlanishi\n'
          '• Binolarga zarar\n'
          '• Transport qiyinlashadi\n'
          '• Chang bo\'ronlari\n\n'
          'Foydasi:\n'
          '• Shamol energetikasi\n'
          '• Iqlimni yumshatadi\n'
          '• Havoni tashish\n'
          '• Changlatish (o\'simliklar)\n\n'
          'Eng shamol zonalar:\n'
          '• Ustyurt platosi\n'
          '• Qizilqum cho\'li\n'
          '• Tog\' dovonlari',
      'geo_ph_wave': 'Sovuq va issiq to\'lqinlar',
      'geo_ph_wave_desc':
          'Haroratning keskin o\'zgarishi.\n\n'
          'Sovuq to\'lqinlar:\n'
          '• Qishda -20°C dan past\n'
          '• Shimoldan keladi\n'
          '• 3-7 kun davom etadi\n'
          '• Qishloq xo\'jaligiga zarar\n\n'
          'Ta\'sir:\n'
          '• O\'simliklar muzlab qoladi\n'
          '• Sug\'orish tizimlari muzlab ketadi\n'
          '• Hayvonlar uchun qiyin\n'
          '• Energiya iste\'moli ortadi\n'
          '• Transport muammolari\n\n'
          'Himoya:\n'
          '• Issiqxonalar\n'
          '• O\'simliklarni qoplash\n'
          '• Hayvonlarni bino ichiga olish\n'
          '• Quvurlarni issiqlik bilan ta\'minlash\n\n'
          'Issiq to\'lqinlar:\n'
          '• Yozda +40°C dan yuqori\n'
          '• Janubdan keladi\n'
          '• 5-10 kun davom etadi\n'
          '• Aholi sog\'ligiga ta\'sir\n\n'
          'Oqibatlari:\n'
          '• Suv tanqisligi\n'
          '• Hosil zarar ko\'radi\n'
          '• Yong\'in xavfi\n'
          '• Sog\'liq muammolari\n'
          '• Elektr iste\'moli ortadi\n\n'
          'Tavsiyalar:\n'
          '• Ko\'proq suv ichish\n'
          '• Quyosh ostida kam bo\'lish\n'
          '• Konditsioner ishlatish\n'
          '• Yorug\' kiyim kiyish\n\n'
          'Davrlar:\n'
          '• Qishda: dekabr-yanvar\n'
          '• Yozda: iyun-iyul-avgust',
      'geo_ph_koch': 'Ko\'chkilar',
      'geo_ph_koch_desc':
          'Tog\' yonbag\'irlarida tuproq va toshlarning sirpanib tushishi.\n\n'
          'Sabablari:\n'
          '• Tog\' jinslari parchalanishi\n'
          '• Kuchli yomg\'irlar\n'
          '• Zilzilalar\n'
          '• Suv oqimi\n'
          '• Inson faoliyati\n\n'
          'Xavfli hududlar:\n'
          '• Toshkent viloyati tog\'lari\n'
          '• Farg\'ona vodiysidagi tog\'lar\n'
          '• Surxondaryo tog\'li hududlari\n'
          '• Qashqadaryo tog\'lari\n\n'
          'Turlari:\n\n'
          '1. Tuproq ko\'chkisi\n'
          '• Yumshoq tuproq sirpanadi\n'
          '• Nam joyda\n\n'
          '2. Tosh ko\'chkisi\n'
          '• Toshlar dumalab tushadi\n'
          '• Juda xavfli\n\n'
          '3. Aralash ko\'chki\n'
          '• Tuproq va tosh aralashmasi\n\n'
          'Oqibatlari:\n'
          '• Yo\'llar berkitiladi\n'
          '• Uylar zarar ko\'radi\n'
          '• Odamlar qurboni\n'
          '• Qishloq xo\'jaligi yerlari yo\'qoladi\n'
          '• Sug\'orish kanallari berkitiladi\n\n'
          'Himoya choralari:\n'
          '• Himoya inshootlari qurish\n'
          '• To\'siqlar o\'rnatish\n'
          '• O\'rmon ekish\n'
          '• Suvni boshqarish\n'
          '• Monitoring\n'
          '• Xavfli joylardan ko\'chish\n\n'
          'Bashorat:\n'
          '• Geologik tekshirish\n'
          '• Yomg\'ir kuzatish\n'
          '• Zilzila monitoring',
      'geo_ph_melt': 'Muzlik erishi',
      'geo_ph_melt_desc':
          'Tog\' muzliklarining asta-sekin erishi.\n\n'
          'O\'zbekistondagi muzliklar:\n'
          '• Farg\'ona viloyati tog\'larida\n'
          '• Toshkent viloyati tog\'larida\n'
          '• Jami: ~650 km² maydon\n'
          '• Yillik erish: 0.5-1%\n\n'
          'Sabablari:\n'
          '• Global iqlim isishi\n'
          '• Harorat oshishi\n'
          '• Yog\'ingarchilik o\'zgarishi\n'
          '• Inson ta\'siri\n\n'
          'Ahamiyati:\n'
          '• Daryolar manbai\n'
          '• Suv resurslari\n'
          '• Iqlimga ta\'sir\n'
          '• Ekotizim uchun muhim\n\n'
          'Oqibatlari:\n\n'
          'Qisqa muddatda:\n'
          '• Suvning ko\'payishi\n'
          '• Sel xavfi\n'
          '• Ko\'llarning to\'lib-toshishi\n\n'
          'Uzoq muddatda:\n'
          '• Muzliklar yo\'qolishi\n'
          '• Daryolarda suv kamayishi\n'
          '• Sug\'orishga suv yetishmaydi\n'
          '• Ekologik muammo\n\n'
          'Daryolarga ta\'sir:\n'
          '• Zarafshon - muzliklardan\n'
          '• Qashqadaryo - muzliklardan\n'
          '• Surxondaryo - qisman\n'
          '• Chirchiq - muzliklardan\n\n'
          'Monitoring:\n'
          '• Sun\'iy yo\'ldosh kuzatuvi\n'
          '• Meteorologik stantsiyalar\n'
          '• Suv oqimi o\'lchash\n'
          '• Xalqaro hamkorlik\n\n'
          'Himoya choralari:\n'
          '• Suvdan oqilona foydalanish\n'
          '• Suv tejash texnologiyalari\n'
          '• Ekologik dasturlar\n'
          '• Xalqaro hamkorlik',
      'geo_map_sub1': 'Respublikamiz ma\'lumotlari',
      'geo_map_sub_karakalpak': 'Qoraqalpog\'iston Respublikasi',
      'geo_map_sub2': 'Chegaradosh davlatlar ma\'lumotlari',
      'geo_karakalpak_title': 'Qoraqalpog\'iston Respublikasi',
      'geo_karakalpak_capital': 'Poytaxti: Nukus',
      'geo_karakalpak_intro': 'Qoraqalpog\'iston — O\'zbekiston Respublikasining shimoli-g\'arbiy qismida joylashgan. Hudud asosan cho\'l va yarim cho\'l landshaftlari (Qoraqum, Orolbo\'yi zonasi) bilan tavsiflanadi. Tabiiy zaxiralarga boy bo\'lib, ayniqsa tuz, gaz, ohaktosh va boshqa foydali qazilmalar bilan ajralib turadi.',
      'geo_karakalpak_section_title': 'Asosiy ko\'rsatkichlar',
      'geo_karakalpak_border_label': 'Chegara uzunligi (taxminan)',
      'geo_karakalpak_v_area': '166 600 km²',
      'geo_karakalpak_v_pop': '~2,04 mln kishi (2024)',
      'geo_karakalpak_v_lang': 'Qoraqalpoq va o\'zbek tillari',
      'geo_karakalpak_v_currency': 'O\'zbekiston so\'mi (so\'m)',
      'geo_karakalpak_v_border': '≈ 1 700 – 1 800 km',
      'geo_republic_title': 'O\'zbekiston Respublikasi',
      'geo_republic_capital': 'Poytaxti: Toshkent',
      'geo_republic_lead': 'O\'zbekiston — Markaziy Osiyoda joylashgan mustaqil davlat. Poytaxti Toshkent iqtisodiy, ilmiy va madaniy markaz hisoblanadi; davlat tuzumi — Respublika. Iqtisodiyot sanoat, qishloq xo\'jaligi va xizmat ko\'rsatish bilan rivojlanmoqda.',
      'geo_republic_v_area': '448 978 km²',
      'geo_republic_v_pop': '36 mln nafardan ziyod',
      'geo_republic_v_lang': 'O\'zbek (davlat tili), rus tili keng qo\'llaniladi',
      'geo_republic_v_currency': 'O\'zbekiston so\'mi (UZS)',
      'geo_republic_admin_label': 'Ma\'muriy tuzilma',
      'geo_republic_v_admin': '12 ta viloyat va Qoraqalpog\'iston Respublikasi',
      'geo_republic_btn_map': 'Dunyo siyosiy xaritasini ko\'rish',
      'geo_borders_title': 'Chegaralar',
      'geo_neighbors_section': 'Qo\'shni davlatlar',
      'geo_capital_prefix': 'Poytaxti: ',
      'geo_million_short': 'mln',
      'geo_stat_area': 'Maydoni',
      'geo_stat_pop': 'Aholisi',
      'geo_stat_languages': 'Rasmiy tillari',
      'geo_stat_currency': 'Valyutasi',
      'geo_stat_border_uz': 'Chegara uzunligi (O\'zbekiston bilan)',
      'doc_decisions': 'Qarorlar',
      'doc_laws': 'Qonunlar',
      'doc_all': 'Barchasi',
      'doc_empty': 'Hujjatlar topilmadi',
      'doc_offline_mode': 'Oflayn rejim — eski ma\'lumotlar',
      'doc_refresh': 'Yangilash',
      'doc_built_in': 'Ilova ichida',
      'doc_downloaded': 'Yuklab olingan',
      'doc_offline_ready': 'Manbadan yuklab olingan — oflayn ochiladi',
      'doc_download': 'Yuklab olish',
      'doc_download_update': 'Yangi versiyani yuklab olish',
      'doc_delete_local': 'Lokal nusxani o\'chirish',
      'doc_need_download': 'Oflayn o\'qish uchun avval yuklab oling',
      'doc_download_failed': 'Yuklash muvaffaqiyatsiz. Internet va serverni tekshiring',
      'doc_delete_confirm_title': 'Lokal nusxani o\'chirish?',
      'doc_delete_confirm_body': 'Faqat qurilmangizdagi yuklangan fayl o\'chiriladi. Server va admin bazasidagi hujjat o\'zgarmaydi.',
      'doc_delete_confirm_action': 'O\'chirish',
      'doc_file_not_on_device': 'PDF fayl topilmadi. Qayta yuklab oling.',
      'chem_rx_section_types': 'Reaksiya turlari',
      'chem_rx_symbols_title': 'Reaksiya belgilari:',
      'chem_rx_examples': 'Misollar:',
      'chem_rx_close': 'Yopish',
      'chem_rx_retry': 'Qayta urinish',
      'chem_rx_error': 'Ma\'lumot yuklanmadi',
      'settings_general': 'Umumiy sozlamalar',
      'settings_language': 'Til',
      'settings_dark_mode': 'Qorong\'i tema',
      'settings_about': 'Ilova haqida',
      'settings_about_sub': 'Ma\'lumot va litsenziya',
      'about_title': 'Kimyo va Geografiya',
      'about_desc': 'Bu ilova O\'zbekiston maktab o\'quvchilari uchun kimyo va geografiya fanlarini o\'rganishda yordam berish maqsadida yaratilgan.',
      'about_features': 'Xususiyatlari:',
      'about_feature_1': '• Kimyoviy elementlar ma\'lumotlari',
      'about_feature_2': '• Davriy jadval',
      'about_feature_3': '• Kimyoviy reaksiyalar',
      'about_feature_4': '• O\'zbekiston geografiyasi',
      'about_feature_5': '• Iqlim va ob-havo',
      'about_feature_6': '• Interaktiv o\'rganish',
      'about_copyright': '© 2026 Barcha huquqlar himoyalangan',
      'close': 'Yopish',
      'settings_author': 'Muallif haqida',
      'author_name': 'Bekimbetova Gulnaz Nabatovna',
      'author_role': 'Kimyo fani o\'qituvchisi',
      'author_main_info': 'Asosiy ma\'lumotlar',
      'author_birth_date': 'Tug\'ilgan sana',
      'author_birth_place': 'Tug\'ilgan joyi',
      'author_nationality': 'Millati',
      'author_education': 'Ma\'lumoti',
      'author_specialty': 'Mutaxassisligi',
      'author_languages': 'Chet tillari',
      'author_current_job': 'Hozirgi ish joyi',
      'author_position': 'Lavozimi',
      'author_org': 'Tashkilot',
      'author_dept': 'Kafedra',
      'author_start_date': 'Boshlagan vaqti',
      'author_experience': 'Mehnat faoliyati',
      'author_additional': 'Qo\'shimcha ma\'lumotlar',
      'author_degree': 'Ilmiy daraja',
      'author_title': 'Ilmiy unvon',
      'author_awards': 'Davlat mukofotlari',
      'author_deputy': 'Deputatlik',
      'author_none': 'Yo\'q',
      'author_uzb': 'O\'zbek',
      'author_qoraqalpoq': 'Qoraqalpoq',
      'author_higher': 'Oliy',
      'author_chemistry': 'Kimyo',
      'author_lang_list': 'Rus tili, Turk tili',
      'author_senior_teacher': 'Katta o\'qituvchi',
      'author_uni': 'Nukus davlat texnika universiteti',
      'author_dept_name': 'Kimyo muhandisligi va atrof-muhitni muhofaza qilish',
      'author_start_val': '1 aprel 2025 yildan',
      'author_present': 'hozir',
      'rate_title': 'Ilovani baholang',
      'rate_subtitle': 'Fikringiz biz uchun muhim!',
      'rate_submit': 'Yuborish',
      'rate_thanks': 'Rahmat! Siz {} yulduz berdingiz.',
      'rate_error_network': 'Tarmoq xatosi. Qayta urinib ko\'ring.',
      'rate_already_submitted': 'Siz allaqachon ilovani baholagansiz.',
      'rate_submit_failed': 'Yuborib bo\'lmadi. Keyinroq urinib ko\'ring.',
      'rate_readonly_subtitle': 'Siz {} yulduz bergansiz. Rahmat!',
      'rate_done_close': 'Yopish',
      'settings_rate': 'Ilovani baholang',
      'settings_rate_sub': 'Fikringizni bildiring',
      'settings_rate_submitted': 'Baholingiz: {} yulduz',
      'doc_in_app': 'Ilova ichida',
      'doc_pdf_error': 'PDF fayl topilmadi',
      'doc_loading': 'PDF yuklanmoqda...',
      'settings_version': 'Versiya',
      'profile_time': 'Vaqt',
      'profile_activity_time_empty': 'Hali yozilmagan',
      'time_unit_hour': 'soat',
      'time_unit_minute': 'daqiqa',
      'time_unit_second': 'soniya',
      'profile_personal': 'Shaxsiy ma\'lumotlar',
      'profile_edu': 'Ta\'lim ma\'lumotlari',
      'profile_activity': 'Faoliyat',
      'profile_logout': 'Chiqish',
      'profile_edit': 'Profilni tahrirlash',
      'profile_name': 'Ism',
      'profile_email': 'Email',
      'profile_phone': 'Telefon',
      'profile_school': 'Maktab',
      'profile_class': 'Sinf',
      'profile_save': 'Saqlash',
      'profile_password_section': 'Parolni o\'zgartirish',
      'profile_password_hint':
          'Parolni almashtirmoqchi bo\'lmasangiz, quyidagi uchala maydonni bo\'sh qoldiring.',
      'profile_current_password': 'Joriy parol',
      'profile_new_password': 'Yangi parol',
      'profile_confirm_password': 'Parolni tasdiqlash',
      'profile_password_fill_all':
          'Parolni almashtirish uchun joriy parol, yangi parol va tasdiqlash maydonlarini to\'ldiring.',
      'profile_password_too_short': 'Yangi parol kamida 6 belgidan iborat bo\'lishi kerak.',
      'profile_password_mismatch': 'Yangi parol va tasdiqlash mos kelmayapti.',
      'profile_updated': 'Profil yangilandi',
      'profile_school_pick': 'Maktabni tanlang',
      'profile_grade_pick': 'Sinfni tanlang',
      'profile_reference_load_failed': 'Maktab va sinf ro\'yxatini yuklab bo\'lmadi.',
      'profile_retry': 'Qayta urinish',
      'profile_add_school': 'Yangi maktab',
      'profile_add_grade': 'Yangi sinf',
      'profile_new_school_name': 'Maktab nomi',
      'profile_new_school_city': 'Hudud / tuman (ixtiyoriy)',
      'profile_new_grade_label': 'Sinf (masalan: 9-sinf)',
      'profile_user_info': 'Foydalanuvchi ma\'lumotlari',
      'profile_not_set': 'Kiritilmagan',
      'profile_update_error': 'Saqlab bo\'lmadi. Qayta urinib ko\'ring.',
      'profile_student_suffix': 'sinf o\'quvchisi',
      'profile_activity_history': 'Faoliyat tarixi',
      'profile_achievements': 'Yutuqlar',
      'profile_logout_confirm': 'Rostdan ham akkauntdan chiqmoqchimisiz?',
      'profile_logout_yes': 'Ha, chiqish',
      'profile_logout_no': 'Yo\'q',
      'profile_logged_out': 'Akkauntdan chiqdingiz',
      'profile_total_lessons': 'Jami darslar:',
      'profile_study_time': 'O\'rganish vaqti:',
      'profile_achievement_1': 'Birinchi dars',
      'profile_achievement_1_desc': 'Birinchi darsni tugatdingiz',
      'profile_achievement_2': 'Kimyo ustasi',
      'profile_achievement_2_desc': '10 ta kimyo darsini tugatdingiz',
      'profile_achievement_3': 'Geografiya bilimdoni',
      'profile_achievement_3_desc': '10 ta geografiya darsini tugatdingiz',
      'profile_achievement_4': 'O\'quvchi',
      'profile_achievement_4_desc': '50 ta darsni tugatdingiz',
      'profile_achievement_5': 'Champion',
      'profile_achievement_5_desc': '100 ta darsni tugatdingiz',
      'profile_achievements_subtitle': 'Mukofotlar va sertifikatlar',
      'profile_lessons_total_pattern': '{n} ta dars tugatilgan',
      'activity_when_today': 'Bugun',
      'activity_when_yesterday': 'Kecha',
      'activity_days_ago_suffix': 'kun oldin',
      'activity_history_empty': 'Hali yozuvlar yo\'q — kimyo darsini oxirigacha o\'qing yoki geografiya bo\'limida «Bu bo\'limni tugatdim» tugmasini bosing.',
      'activity_subject_chemistry': 'Kimyo',
      'activity_subject_geography': 'Geografiya',
      'geo_mark_section_complete': 'Bu bo\'limni tugatdim',
      'geo_topic_marked_complete': 'Bu bo\'lim yakunlangan',
      'study_marked_done_snackbar': 'Yozib olindi',
      'search_hint': 'Element, tuz yoki formulani kiriting...',
      'prop_formula': 'Formula',
      'prop_molar_mass': 'Molyar massa',
      'prop_color': 'Rangi',
      'prop_solubility': 'Eruvchanligi',
      'prop_melt_temp': 'Eritish harorati',
      'prop_boil_temp': 'Qaynash harorati',
      'prop_density': 'Zichligi',
      'prop_electrons': 'Elektronlar soni',
      'prop_valence': 'Valentligi',
      'unknown': 'Noma\'lum',
      'lang_select': 'Tilni tanlang',
      'cancel': 'Bekor qilish',
      'toast_lang_changed': 'Til o\'zgartirildi',
      'toast_theme_dark': 'Qorong\'i tema yoqildi',
      'toast_theme_light': 'Yorug\' tema yoqildi',
      'formula_calc_title': 'Formulalarni hisoblash',
      'formula_input_hint': 'Kimyoviy formulani kiriting',
      'formula_example': 'Masalan: H2O, NaCl, Ca(OH)2',
      'formula_calculate': 'Hisoblash',
      'formula_popular': 'Mashhur formulalar',
      'formula_result_title': '{} molekulyar massasi:',
      'formula_total': 'Jami',
      'formula_copy': 'Nusxa olindi',
      'formula_invalid': 'Noto\'g\'ri formula',
      'formula_clear': 'Tozalash',
      'formula_backspace': 'O\'chirish',
      'periodic_interaktiv': 'Interaktiv jadval',
      'menu_natural_resources_map': 'Tabiiy zaxiralar xaritasi',
      'natural_resources_map_pinch_hint':
          'Ikki barmoq bilan kattalashtiring, bitta barmoq bilan siljiting. + / − yoki yuqoridagi tugma — ekranga moslashtirish.',
      'natural_resources_map_fit_tooltip': 'Ekranga moslashtirish',
      'natural_resources_map_zoom_in': 'Kattalashtirish',
      'natural_resources_map_zoom_out': 'Kichiklashtirish',
      'natural_resources_map_load_error': 'Xarita rasmi yuklanmadi. Ilovani qayta ishga tushiring.',
      'menu_regional_minerals': 'Qoraqalpog\'iston minerallari',
      'regional_minerals_map_hint': 'Xaritada belgilarni ko\'rish uchun ro\'yxatdan mineralni tanlang (ko\'z ikonkasi).',
      'regional_minerals_quantity_label': 'Zaxira / ko\'rsatkich',
      'regional_minerals_reference_title': 'Manba',
      'regional_minerals_no_reference': 'Manba keltirilmagan.',
      'regional_minerals_show_on_map': 'Xaritada ko\'rsatish',
      'regional_minerals_hide_on_map': 'Tanlangan (xaritada)',
      'periodic_qiziqarli': 'Qiziqarli topshiriqlar',
      'menu_projects': 'Loyihalar',
      'empty_interesting_tasks': 'Topshiriqlar hali yo\'q',
      'empty_projects_tasks': 'Loyiha topshiriqlari hali yo\'q',
      'periodic_all': 'Barchasi',
      'periodic_alkali': 'Ishqoriy metall',
      'periodic_alkaline': 'Ishqoriy-yer metall',
      'periodic_transition': 'O\'tish metalli',
      'periodic_metal': 'Metall',
      'periodic_metalloid': 'Metalloid',
      'periodic_nonmetal': 'Nometall',
      'periodic_halogen': 'Galogen',
      'periodic_noble': 'Inert gaz',
      'periodic_atom_num': 'Atom raqami',
      'periodic_symbol': 'Belgi',
      'periodic_mass': 'Massa',
      'periodic_category': 'Kategoriya',
      'periodic_lanthanide': 'Lantanoid',
      'periodic_actinide': 'Aktinoid',
      'properties': 'Xususiyatlari',
      'no_results': 'Natija topilmadi',
      'elements_offline_banner': 'Internet yo\'q — oxirgi yuklangan elementlar qurilmada saqlangan nusxadan ko\'rsatilmoqda.',
      'menu_theory': 'Nazariy',
      'menu_lab': 'Laboratoriya',
      'splash_loading': 'Yuklanmoqda...',
      'splash_tagline': 'Kimyo va geografiya — o\'qish va o\'rganish bir joyda',
      'auth_hero_welcome': 'Qaytganingizdan xursandmiz',
      'onboarding_badge': 'Birinchi qadam',
      'onboarding_lang_title': 'Tilni tanlang',
      'onboarding_lang_subtitle': 'Ilova tili keyinroq sozlamalarda o\'zgartirilishi mumkin',
      'onboarding_lang_continue': 'Davom etish',
      'auth_login_title': 'Kirish',
      'auth_login_subtitle': 'Hisobingizga kiring',
      'auth_register_title': 'Ro\'yxatdan o\'tish',
      'auth_register_subtitle': 'Yangi hisob yaratish',
      'auth_login_field': 'Login (username, email yoki telefon)',
      'auth_username': 'Username (kirish uchun)',
      'auth_username_hint': 'Masalan: ellikkala_m2_9a_001',
      'auth_error_username': 'Username kiriting',
      'auth_error_username_len': 'Username kamida 3 belgi',
      'auth_error_username_chars': "Faqat lotin harflari, raqam, . _ -",
      'auth_phone': 'Telefon raqam',
      'auth_phone_hint': '+998 90 123 45 67',
      'auth_error_phone': 'Telefon raqamini kiriting',
      'auth_region': 'Viloyat / Respublika',
      'auth_district': 'Tuman / Shahar',
      'auth_district_hint': 'Tumaningizni tanlang',
      'auth_error_district': 'Tumanni tanlang',
      'auth_school_number': 'Maktab raqami',
      'auth_school_number_hint': 'Maktab raqamini tanlang (1–58)',
      'auth_error_school': 'Maktab raqamini tanlang',
      'auth_password': 'Parol',
      'auth_password_confirm': 'Parolni tasdiqlang',
      'auth_name': 'F.I.O.',
      'auth_login_action': 'Kirish',
      'auth_register_action': 'Ro\'yxatdan o\'tish',
      'auth_no_account_register': 'Hisob yo\'qmi? Ro\'yxatdan o\'tish',
      'auth_has_account_login': 'Akkountingiz bormi? Kirish',
      'auth_success_login': 'Muvaffaqiyatli kirdingiz',
      'auth_success_register': 'Muvaffaqiyatli ro\'yxatdan o\'tdingiz',
      'auth_error_login': 'Telefon raqam yoki usernameni kiriting',
      'auth_error_password': 'Parolni kiriting',
      'auth_error_password_len': 'Parol kamida 6 belgi',
      'auth_error_password_mismatch': 'Parollar mos emas',
      'auth_error_name': 'Ismni kiriting',
      'auth_error_generic': 'Xatolik yuz berdi. Qayta urinib ko\'ring',
      'my_submissions_title': 'Mening javoblarim',
      'my_submissions_empty': 'Hali javob topshirmadingiz',
      'task_submit_appbar': 'Topshiriq',
      'task_submit_success_title': 'Tabriklaymiz!',
      'task_submit_success_body': 'Topshirig\'ingiz muvaffaqiyatli yuborildi. O\'qituvchi javoblaringizni tekshirib natijangizni belgilaydi.',
      'task_submit_id_label': 'ID raqam',
      'task_submit_status_label': 'Holat',
      'task_submit_result_label': 'Natija',
      'task_submit_status_pending': 'Tekshirilmoqda',
      'task_submit_status_checked': 'Tekshirildi',
      'task_submit_result_hidden': 'O\'qituvchi ruxsat bergach ko\'rinadi',
      'task_submit_result_points': '{{score}} ball',
      'task_submit_home': 'Bosh sahifaga qaytish',
      'virtual_lab_title': 'Virtual Laboratoriya',
      'virtual_lab_start_btn': 'Virtual Laboratoriyani boshlash',
      'virtual_lab_reaction_zone': 'Tajriba maydoni',
      'virtual_lab_hint': 'Quyidan 2 ta material tanlang (asbob + element yoki 2 ta modda)',
      'virtual_lab_pick_second': 'Endi ikkinchi material tanlang...',
      'virtual_lab_clear': 'Tozalash',
      'virtual_lab_items_title': 'Laboratoriya materiallari',
      'virtual_lab_required': 'Majburiy',
      'virtual_lab_no_reaction': 'Bu moddalar o\'rtasida reaksiya kuzatilmadi.',
      'virtual_lab_load_error': 'Materiallarni yuklashda xato yuz berdi',
      'virtual_lab_empty_category': 'Bu kategoriyada material yo\'q',
      'virtual_lab_tab_all': 'Barchasi',
      'virtual_lab_tab_equipment': 'Uskuna',
      'virtual_lab_tab_vessel': 'Idish',
      'virtual_lab_tab_element': 'Element',
      'virtual_lab_tab_reagent': 'Reaktiv',
      'virtual_lab_checklist_title': 'Kerakli narsalar',
      'virtual_lab_procedure_title': 'Amaliyot tartibi',
      'virtual_lab_template_footer': 'Darslik va laboratoriya virtual shabloniga mos checklist va tartib.',
      'virtual_lab_optional': 'ixtiyoriy',
      'retry': 'Qayta urinish',
    },
    'ru': {
      'app_title': 'Химия V2',
      'tab_kimyo': 'Химия',
      'tab_geografiya': 'География',
      'tab_hujjatlar': 'Документы',
      'tab_sozlamalar': 'Настройки',
      'tab_profil': 'Профиль',
      'menu_elements': 'Химические элементы',
      'menu_elements_sub': 'Информация об элементах',
      'menu_alkali_metals': 'Группы металлов',
      'alkali_page_title': 'Группы металлов',
      'alkali_search_hint': 'Название или символ элемента...',
      'menu_periodic_table': 'Периодическая таблица',
      'menu_periodic_table_sub': 'Просмотр таблицы',
      'menu_formulas': 'Химические формулы',
      'menu_formulas_sub': 'Химические реакции',
      'menu_lessons': 'Занятия',
      'menu_lessons_sub': 'Начать уроки',
      'menu_quiz': 'Пройти тест',
      'menu_lab_works': 'Лабораторные работы',
      'tests_title': 'Тесты',
      'tests_tab_chemistry': 'Химия',
      'tests_tab_geography': 'География',
      'tests_no_items': 'Пока нет тестов',
      'geo_map': 'Политическая карта мира',
      'geo_map_sub': 'Интерактивная карта',
      'geo_landscapes': 'Природные ландшафты',
      'geo_geology': 'Геологическое строение',
      'geo_climate': 'Климат и погода',
      'geo_climate_sub1': 'Региональный климат',
      'geo_climate_sub2': 'Информация о погоде',
      'geo_climate_regional_title': 'Климат и региональное распределение погоды',
      'geo_topic_continental': 'Континентальный климат',
      'geo_topic_continental_desc':
          'Узбекистан находится в зоне континентального климата.\n\n'
          'Основные черты:\n'
          '• Жаркое сухое лето\n'
          '• Холодная зима\n'
          '• Мало осадков\n'
          '• Большой перепад днём и ночью\n'
          '• Резкая смена времён года\n\n'
          'Причины:\n'
          '• Удалённость от моря\n'
          '• Положение в Центральной Азии\n'
          '• Горы по периметру\n'
          '• Географическое положение\n\n'
          'Амплитуда температур:\n'
          '• За год: 40–50 °C\n'
          '• За сутки: 15–20 °C\n'
          '• Максимум: +45 °C (Термез)\n'
          '• Минимум: −30 °C (в горах)\n\n'
          'Осадки:\n'
          '• В среднем: 100–500 мм/год\n'
          '• Больше всего в горах (500–700 мм)\n'
          '• Меньше всего в пустынях (100–150 мм)\n'
          '• Преимущественно весной и осенью',
      'geo_topic_climate_zones': 'Климатические зоны',
      'geo_topic_climate_zones_desc':
          'Узбекистан делится на 4 основные климатические зоны.\n\n'
          '1. Пустынный климат\n\n'
          'Районы:\n'
          '• Кызылкум\n'
          '• Каракалпакстан\n'
          '• Плато Устюрт\n'
          '• Пустынная часть Навоийской области\n\n'
          'Особенности:\n'
          '• Очень жаркое лето (+40…+45 °C)\n'
          '• Холодная зима (0…−15 °C)\n'
          '• Очень мало осадков (100–150 мм)\n'
          '• Сильные ветры\n'
          '• Большие колебания температуры\n\n'
          '2. Полупустынный (степной) климат\n\n'
          'Районы:\n'
          '• Мирзачуль\n'
          '• Джиззакская область\n'
          '• Окрестности Самарканда\n'
          '• Часть Бухарской области\n\n'
          'Особенности:\n'
          '• Жаркое лето (+35…+40 °C)\n'
          '• Относительно мягкая зима (0…−10 °C)\n'
          '• Осадки 200–300 мм\n'
          '• Степная растительность\n\n'
          '3. Субтропический климат\n\n'
          'Районы:\n'
          '• Долина Сурхандарьи\n'
          '• Юг Кашкадарьи\n'
          '• Долина Шерабада\n\n'
          'Особенности:\n'
          '• Очень жаркое лето (+40…+45 °C)\n'
          '• Тёплая зима (+5…0 °C)\n'
          '• Осадки 200–400 мм\n'
          '• Субтропическая растительность\n'
          '• Хлопок и фрукты\n\n'
          '4. Горный климат\n\n'
          'Районы:\n'
          '• Тянь-Шань\n'
          '• Памиро-Алай\n'
          '• Фанские горы\n'
          '• Гиссарский хребет\n\n'
          'Особенности:\n'
          '• Прохладное лето (+15…+25 °C)\n'
          '• Холодная зима (−10…−30 °C)\n'
          '• Много осадков (500–800 мм)\n'
          '• Снежные вершины\n'
          '• Ледники',
      'geo_topic_seasons': 'Особенности времён года',
      'geo_topic_seasons_desc':
          'У каждого времени года свои особенности.\n\n'
          'ВЕСНА (март–май)\n\n'
          'Температура:\n'
          '• Март: +5…+15 °C\n'
          '• Апрель: +15…+25 °C\n'
          '• Май: +20…+30 °C\n\n'
          'Особенности:\n'
          '• Быстрое потепление\n'
          '• Больше всего осадков\n'
          '• Цветение растений\n'
          '• Цветение плодовых деревьев\n'
          '• Сев сельхозкультур\n'
          '• Иногда риск селей\n\n'
          'ЛЕТО (июнь–август)\n\n'
          'Температура:\n'
          '• Июнь: +30…+38 °C\n'
          '• Июль: +35…+42 °C\n'
          '• Август: +30…+40 °C\n\n'
          'Особенности:\n'
          '• Очень жарко\n'
          '• Сухой воздух\n'
          '• Мало осадков\n'
          '• Длинный световой день\n'
          '• Созревание урожая\n'
          '• Жаркие волны\n\n'
          'ОСЕНЬ (сентябрь–ноябрь)\n\n'
          'Температура:\n'
          '• Сентябрь: +25…+30 °C\n'
          '• Октябрь: +15…+20 °C\n'
          '• Ноябрь: +5…+10 °C\n\n'
          'Особенности:\n'
          '• Постепенное похолодание\n'
          '• Сухой воздух\n'
          '• Уборка урожая\n'
          '• Сбор хлопка\n'
          '• Работы на огороде\n'
          '• «Золотая осень»\n\n'
          'ЗИМА (декабрь–февраль)\n\n'
          'Температура:\n'
          '• Декабрь: 0…−10 °C\n'
          '• Январь: −5…−15 °C\n'
          '• Февраль: 0…−10 °C\n\n'
          'Особенности:\n'
          '• Холодно\n'
          '• Иногда снег\n'
          '• Холодные волны\n'
          '• Короткий день\n'
          '• Отдых\n'
          '• Зимний спорт (в горах)',
      'geo_topic_regional_diff': 'Региональные различия',
      'geo_topic_regional_diff_desc':
          'Климатические различия по областям.\n\n'
          'СЕВЕР (Ташкент, Сырдарья)\n'
          '• Средняя температура: +13…+15 °C\n'
          '• Осадки: 300–400 мм\n'
          '• Зима холоднее\n'
          '• Лето жарче\n\n'
          'ВОСТОК (Фергана, Андижан, Наманган)\n'
          '• Средняя: +13…+14 °C\n'
          '• Осадки: 200–300 мм\n'
          '• Замкнутая долина\n'
          '• Зима теплее\n\n'
          'ЦЕНТР (Самарканд, Джизак, Навои)\n'
          '• Средняя: +14…+15 °C\n'
          '• Осадки: 300–400 мм\n'
          '• Степь и горы\n'
          '• Умеренный климат\n\n'
          'ЮГ (Сурхандарья, Кашкадарья)\n'
          '• Средняя: +15…+17 °C\n'
          '• Осадки: 200–400 мм\n'
          '• Самый жаркий район\n'
          '• Субтропические растения\n\n'
          'ЗАПАД (Бухара, Хорезм, Каракалпакстан)\n'
          '• Средняя: +12…+14 °C\n'
          '• Осадки: 100–200 мм\n'
          '• Пустынный климат\n'
          '• Зима холодная, лето жаркое\n\n'
          'ГОРЫ (Чимган, Бельдерсай)\n'
          '• Средняя: +5…+10 °C\n'
          '• Осадки: 500–800 мм\n'
          '• Прохладное лето\n'
          '• Снежная зима\n'
          '• Ледники',
      'geo_topic_climate_change': 'Изменение климата',
      'geo_topic_climate_change_desc':
          'Глобальное изменение климата влияет на Узбекистан.\n\n'
          '1. Наблюдаемые изменения:\n'
          '• Рост температуры\n'
          '  • За последние 50 лет +1,5 °C\n'
          '  • В будущем ожидается дальнейший рост\n'
          '• Таяние ледников\n'
          '  • Сокращение на 0,5–1% в год\n'
          '  • Снижение водных ресурсов\n'
          '• Изменение осадков\n'
          '  • Непредсказуемые осадки\n'
          '  • В одних районах больше\n'
          '  • В других меньше\n'
          '• Экстремальные явления\n'
          '  • Чаще жаркие волны\n'
          '  • Частые засухи\n'
          '  • Сильные ветры\n\n'
          '2. Последствия:\n'
          '• Трудности для сельского хозяйства\n'
          '• Дефицит воды\n'
          '• Усиление опустынивания\n'
          '• Экологические проблемы\n'
          '• Проблемы со здоровьем\n\n'
          '3. Меры:\n'
          '• Экономия воды\n'
          '• Новые технологии\n'
          '• Лесонасаждения\n'
          '• Зелёная энергетика\n'
          '• Международное сотрудничество\n\n'
          '4. Прогнозы:\n'
          '• К 2050 году рост на +2–3 °C\n'
          '• Водные ресурсы сократятся на 10–15%\n'
          '• Усиление опустынивания\n'
          '• Нужны новые меры',
      'geo_topic_special_climate': 'Особые климатические зоны',
      'geo_topic_special_climate_desc':
          'На отдельных территориях формируется свой микроклимат.\n\n'
          'ГОРОДСКОЙ КЛИМАТ\n'
          '• Ташкент\n'
          '  • «Остров тепла»\n'
          '  • На 2–3 °C теплее\n'
          '  • Меньше осадков\n\n'
          'ДОЛИННЫЙ КЛИМАТ\n'
          '• Ферганская долина\n'
          '  • Замкнутая территория\n'
          '  • Жаркое лето\n'
          '  • Более прохладная зима\n'
          '  • Особые ветры\n\n'
          'ПУСТЫННЫЙ КЛИМАТ\n'
          '• Кызылкум\n'
          '  • Самый жаркий\n'
          '  • Самый сухой\n'
          '  • Большой перепад температур\n'
          '  • Сильные ветры\n\n'
          'ГОРНЫЙ КЛИМАТ\n'
          '• Чимган, Бельдерсай\n'
          '  • Прохладное лето\n'
          '  • Снежная зима\n'
          '  • Много осадков\n'
          '  • Чистый воздух\n\n'
          'РЕГИОН АРАЛЬСКОГО МОРЯ\n'
          '• Каракалпакстан\n'
          '  • Последствия высыхания моря\n'
          '  • Соляные бури\n'
          '  • Экологическая проблема\n'
          '  • Резкий климат\n\n'
          'ГОРНЫЕ ПЕРЕВАЛЫ\n'
          '• Перевал Камчик\n'
          '  • Переменчивая погода\n'
          '  • Частый туман\n'
          '  • Сильные ветры\n'
          '  • Зима суровее\n\n'
          'КАЖДАЯ ЗОНА УНИКАЛЬНА:\n'
          '• Флора и фауна\n'
          '• Сельское хозяйство\n'
          '• Образ жизни\n'
          '• Туристические возможности',
      'climate_stat_title': 'Статистика климата',
      'climate_stat_avg': 'Средняя температура: +14°C',
      'climate_stat_hot': 'Максимум: +45°C (Термез)',
      'climate_stat_cold': 'Минимум: -30°C (горы)',
      'climate_stat_rain': 'Осадки (средние): 100–500 мм/год',
      'climate_stat_sunny': 'Солнечных дней: 260–300 дн./год',
      'weather_page_title': 'Погода',
      'weather_topic_elements': 'Элементы погоды',
      'weather_topic_elements_desc':
          'Основные элементы, определяющие погоду:\n\n'
          '1. Температура\n'
          '• Измеряется термометром\n'
          '• °C (Цельсий) или °F (Фаренгейт)\n'
          '• Разница день–ночь\n'
          '• Меняется по сезонам\n\n'
          '2. Давление\n'
          '• Измеряется барометром\n'
          '• Миллиметры ртутного столба (мм рт. ст.)\n'
          '• Или гектопаскаль (гПа)\n'
          '• Норма: 760 мм рт. ст.\n\n'
          '3. Ветер\n'
          '• Измеряется анемометром\n'
          '• Скорость: м/с или км/ч\n'
          '• Направление: 8 румбов\n'
          '• Классифицируется по силе\n\n'
          '4. Влажность\n'
          '• Измеряется гигрометром\n'
          '• В процентах (%)\n'
          '• Относительная и абсолютная влажность\n'
          '• Сухой и влажный воздух\n\n'
          '5. Осадки\n'
          '• Осадкомер\n'
          '• В миллиметрах (мм)\n'
          '• Разные формы (дождь, снег, град)\n\n'
          '6. Облачность\n'
          '• Оценивается на глаз\n'
          '• По шкале 0–10 баллов\n'
          '• Разные типы облаков\n'
          '• Влияние на погоду',
      'weather_topic_types': 'Виды погоды',
      'weather_topic_types_desc':
          'В Узбекистане встречаются разные типы погоды:\n\n'
          'ЯСНАЯ (ХОРОШАЯ) ПОГОДА\n'
          '• Безоблачное небо\n'
          '• Жаркие летние дни\n'
          '• Холодные зимние дни\n'
          '• Хорошая видимость\n\n'
          'ОБЛАЧНАЯ ПОГОДА\n'
          '• Небо затянуто облаками\n'
          '• Тепло\n'
          '• Возможны осадки\n'
          '• Солнце не видно\n\n'
          'ДОЖДЛИВАЯ ПОГОДА\n'
          '• Осадки\n'
          '• Облачно\n'
          '• Прохладнее\n'
          '• Влажный воздух\n'
          '• Часто весной и осенью\n\n'
          'СНЕЖНАЯ ПОГОДА\n'
          '• Зимой\n'
          '• Холодно\n'
          '• Белый снежный покров\n'
          '• В основном в горах\n\n'
          'ВЕТРЕНАЯ ПОГОДА\n'
          '• Сильный ветер\n'
          '• Поднимается пыль\n'
          '• Весной и осенью\n'
          '• Сложнее передвижение\n\n'
          'ГРАДОВАЯ ПОГОДА\n'
          '• Летние грозы\n'
          '• Выпадает град\n'
          '• Вред посевам\n'
          '• Недолго держится\n\n'
          'ТУМАННАЯ ПОГОДА\n'
          '• Плохая видимость\n'
          '• Особенно утром\n'
          '• Осенью и весной\n'
          '• Высокая влажность',
      'weather_topic_forecast': 'Прогноз погоды',
      'weather_topic_forecast_desc':
          'Современные методы прогноза погоды.\n\n'
          'МЕТОДЫ НАБЛЮДЕНИЯ:\n\n'
          '1. Метеостанции\n'
          '• В Узбекистане 100+ станций\n'
          '• Данные по часам\n'
          '• Температура, давление, ветер\n'
          '• Осадки\n\n'
          '2. Спутники\n'
          '• Наблюдение из космоса\n'
          '• Мониторинг облаков\n'
          '• Карты температур\n'
          '• Круглосуточный мониторинг\n\n'
          '3. Радиолокационные системы\n'
          '• Зоны осадков\n'
          '• Прогноз гроз и штормов\n'
          '• Оперативные данные\n\n'
          '4. Компьютерные модели\n'
          '• Математический расчёт\n'
          '• Алгоритмы\n'
          '• Глобальные данные\n'
          '• Точный прогноз\n\n'
          'ТИПЫ ПРОГНОЗОВ:\n\n'
          'Краткосрочный (1–3 дня)\n'
          '• Высокая точность: 85–90%\n'
          '• Быстрые изменения\n'
          '• Для повседневных планов\n\n'
          'Среднесрочный (3–10 дней)\n'
          '• Средняя точность: 70–80%\n'
          '• Общая тенденция\n'
          '• Планы на неделю\n\n'
          'Долгосрочный (месяцы)\n'
          '• Низкая точность: 60–70%\n'
          '• Общий прогноз\n'
          '• Сезонное планирование\n\n'
          'ГИДРОМЕТСЛУЖБА:\n'
          '• Гидрометеослужба Узбекистана\n'
          '• Публикует прогнозы\n'
          '• Выдаёт предупреждения\n'
          '• Научные исследования',
      'weather_topic_dangerous': 'Опасные явления',
      'weather_topic_dangerous_desc':
          'Опасные природные явления и защита от них.\n\n'
          '1. ВОЛНА ЖАРЫ\n'
          'Особенности:\n'
          '• Выше +40 °C\n'
          '• Часто летом\n'
          '• Длится 5–10 дней\n'
          'Опасности:\n'
          '• Тепловой удар\n'
          '• Обезвоживание\n'
          '• Сердечно-сосудистые заболевания\n'
          '• Дефицит энергии\n'
          'Защита:\n'
          '• Пить больше воды\n'
          '• Находиться в тени\n'
          '• Лёгкая одежда\n'
          '• Защита от солнца\n\n'
          '2. ВОЛНА ХОЛОДА\n'
          'Особенности:\n'
          '• Ниже −20 °C\n'
          '• Зимой\n'
          '• Приходит с севера\n'
          'Опасности:\n'
          '• Обморожение\n'
          '• Обледенение дорог\n'
          '• Прорыв труб\n'
          '• Рост расхода энергии\n'
          'Защита:\n'
          '• Тепло одеваться\n'
          '• Оставаться дома\n'
          '• Отопление\n'
          '• Защита животных\n\n'
          '3. ГРОЗА И ГРАД\n'
          'Особенности:\n'
          '• Весна и лето\n'
          '• Сильный ветер\n'
          '• Выпадает град\n'
          'Опасности:\n'
          '• Вред посевам\n'
          '• Повреждение домов\n'
          '• Отключение электричества\n'
          '• Падение деревьев\n'
          'Защита:\n'
          '• Укрыться в здании\n'
          '• Остановить автомобиль\n'
          '• Держаться подальше от деревьев\n'
          '• Выключить электроприборы\n\n'
          '4. ТУМАН\n'
          'Особенности:\n'
          '• Видимость менее 50 м\n'
          '• Чаще утром\n'
          '• Осень и весна\n'
          'Опасности:\n'
          '• ДТП\n'
          '• Плохо видна дорога\n'
          '• Сложности для авиации\n'
          'Защита:\n'
          '• Ехать медленно\n'
          '• Включить фары\n'
          '• Быть осторожным\n\n'
          '5. ПЫЛЬНАЯ БУРЯ\n'
          'Особенности:\n'
          '• В пустынных районах\n'
          '• Сильный ветер\n'
          '• Весна и лето\n'
          'Опасности:\n'
          '• Трудно дышать\n'
          '• Раздражение глаз\n'
          '• Плохая видимость\n'
          '• Аллергия\n'
          'Защита:\n'
          '• Оставаться дома\n'
          '• Надеть респиратор/маску\n'
          '• Защитить глаза\n'
          '• Закрыть окна',
      'weather_topic_local': 'Местные особенности',
      'weather_topic_local_desc':
          'У каждого региона свой характер погоды.\n\n'
          'ТАШКЕНТ\n'
          '• Средняя температура: +14 °C\n'
          '• Лето: +35…+40 °C\n'
          '• Зима: −5…−10 °C\n'
          '• Осадки: 400–450 мм\n'
          '• Городской остров тепла\n\n'
          'ФЕРГАНСКАЯ ДОЛИНА\n'
          '• Замкнутая долина\n'
          '• Жаркое лето\n'
          '• Более прохладная зима\n'
          '• Свой микроклимат\n'
          '• Мало ветра\n\n'
          'САМАРКАНД\n'
          '• Умеренный климат\n'
          '• Лето: +30…+38 °C\n'
          '• Зима: 0…−8 °C\n'
          '• Осадки: 350–400 мм\n'
          '• Суше\n\n'
          'ТЕРМЕЗ\n'
          '• Самый жаркий район\n'
          '• Лето: +40…+45 °C\n'
          '• Зима: +5…0 °C\n'
          '• Осадки: 150–200 мм\n'
          '• Субтропики\n\n'
          'ЧИМГАН (горы)\n'
          '• Прохладно\n'
          '• Лето: +20…+25 °C\n'
          '• Зима: −10…−20 °C\n'
          '• Много снега\n'
          '• Чистый воздух\n\n'
          'КАРАКАЛПАКСТАН\n'
          '• Пустынный климат\n'
          '• Жаркое лето\n'
          '• Холодная зима\n'
          '• Очень мало осадков\n'
          '• Влияние Арала',
      'weather_topic_activity': 'Погода и деятельность',
      'weather_topic_activity_desc':
          'Погода влияет на разные виды деятельности.\n\n'
          'СЕЛЬСКОЕ ХОЗЯЙСТВО\n'
          '• Время посева\n'
          '• План орошения\n'
          '• Уборка урожая\n'
          '• Важны осадки и температура\n\n'
          'ТРАНСПОРТ\n'
          '• Состояние дорог\n'
          '• Условия полётов\n'
          '• Морской транспорт\n'
          '• Меры безопасности\n\n'
          'СТРОИТЕЛЬСТВО\n'
          '• Заливка бетона\n'
          '• Укладка асфальта\n'
          '• Малярные работы\n'
          '• Зависит от погоды\n\n'
          'ТУРИЗМ\n'
          '• Время отдыха\n'
          '• Горный туризм\n'
          '• Экскурсии\n'
          '• По сезону\n\n'
          'СПОРТ\n'
          '• Спорт на открытом воздухе\n'
          '• Зимние виды спорта\n'
          '• Летние виды спорта\n'
          '• Погода важна\n\n'
          'ЗДОРОВЬЕ\n'
          '• Колебания давления\n'
          '• Аллергия\n'
          '• Влияние жары и холода\n'
          '• Профилактика\n\n'
          'ЭНЕРГЕТИКА\n'
          '• Отопительный сезон\n'
          '• Сезон охлаждения\n'
          '• Потребление энергии\n'
          '• Изменение тарифов\n\n'
          'РЕЖИМ ДНЯ\n'
          '• Выбор одежды\n'
          '• Планирование\n'
          '• Поездки\n'
          '• Рабочий график',
      'weather_tips_title': 'Полезные советы',
      'weather_tip_1': 'Пользуйтесь приложениями погоды',
      'weather_tip_2': 'Смотрите прогнозы по ТВ',
      'weather_tip_3': 'Проверяйте температуру',
      'weather_tip_4': 'Смотрите вероятность дождя',
      'weather_tip_5': 'Одевайтесь по погоде',
      'weather_tip_6': 'Следите за предупреждениями',
      'geo_geology_sub1': 'Породы гор (горные породы)',
      'geo_geology_sub2': 'Полезные ископаемые',
      'geo_rocks_title': 'Горные породы',
      'geo_mtn_tyan': 'Тянь-Шань',
      'geo_mtn_tyan_m': '4 301 м',
      'geo_mtn_tyan_desc':
          'Тянь-Шань называют «Горами Неба».\n\n'
          'Расположение:\n'
          '• Северо-восток Узбекистана\n'
          '• Ташкентская, Андижанская, Наманганская области\n'
          '• Граница с Кыргызстаном и Казахстаном\n\n'
          'Основные хребты:\n'
          '• Чимганские горы (3 309 м)\n'
          '• Пскемский хребет (4 299 м)\n'
          '• Коржантау (2 200 м)\n'
          '• Национальный парк Угам–Чаткал\n\n'
          'Высочайшие вершины:\n'
          '• Пик Адельунга — 4 301 м (высшая)\n'
          '• Бештор — 4 299 м\n'
          '• Пик Пскем — 4 200 м\n'
          '• Чимган — 3 309 м\n\n'
          'Особенности:\n'
          '• Снежные вершины\n'
          '• Ледники\n'
          '• Центр альпинизма\n'
          '• Туризм\n\n'
          'Реки:\n'
          '• Исток Чирчика\n'
          '• Река Пскем\n'
          '• Река Аксу\n'
          '• Много притоков\n\n'
          'Флора и фауна:\n'
          '• Арчовые леса\n'
          '• Дикие животные (медведь, редкие птицы)\n'
          '• Горные козлы\n'
          '• Хищники\n\n'
          'Курорты:\n'
          '• Чимган (зимний курорт)\n'
          '• Белдерсай\n'
          '• Долина Пскема\n'
          '• Альпинистские лагеря\n\n'
          'Значение:\n'
          '• Водные ресурсы\n'
          '• Туризм\n'
          '• Экологическая система\n'
          '• Влияние на климат',
      'geo_mtn_pamir': 'Памиро-Алай',
      'geo_mtn_pamir_m': '4 600 м',
      'geo_mtn_pamir_desc':
          'Памиро-Алай — горная система на востоке Узбекистана.\n\n'
          'Основные хребты:\n\n'
          'Алайский хребет:\n'
          '• Юг Ферганской долины\n'
          '• Высота: 4 000–5 000 м\n'
          '• Граница с Кыргызстаном\n\n'
          'Туркестанский хребет:\n'
          '• Кашкадарьинская область\n'
          '• Высота: 4 000–5 000 м\n'
          '• Граница с Таджикистаном\n\n'
          'Зеравшанский хребет:\n'
          '• Самаркандская область\n'
          '• До 5 489 м (горы Фана)\n'
          '• Исток Зеравшана\n\n'
          'Гиссарский хребет:\n'
          '• Сурхандарьинская область\n'
          '• Высота: 4 000–4 500 м\n'
          '• Граница с Таджикистаном\n\n'
          'Горы Фана:\n'
          '• Вершина Чимтарга — 5 489 м\n'
          '• Популярны у туристов и альпинистов\n'
          '• Более 70 озёр\n'
          '• Озёра Алаудина\n\n'
          'Ледники:\n'
          '• Ледники Зеравшана\n'
          '• Ледники Фанских гор\n'
          '• Гиссарские ледники\n'
          '• Источник воды\n\n'
          'Истоки рек:\n'
          '• Зеравшан\n'
          '• Кашкадарья\n'
          '• Сурхандарья\n'
          '• Много притоков\n\n'
          'Население и сёла:\n'
          '• Пастбища\n'
          '• Горные сёла\n'
          '• Животноводство\n'
          '• Фрукты и орехи\n\n'
          'Туризм:\n'
          '• Альпинизм\n'
          '• Пеший туризм\n'
          '• Природный туризм\n'
          '• Культурный туризм\n\n'
          'Полезные ископаемые:\n'
          '• Золото\n'
          '• Медь\n'
          '• Мрамор\n'
          '• Другие металлы',
      'geo_mtn_nurota': 'Нуратинские горы',
      'geo_mtn_nurota_m': '2 169 м',
      'geo_mtn_nurota_desc':
          '«Горы, полные света».\n\n'
          'Расположение:\n'
          '• Области Навои, Самарканда и Джиззака\n'
          '• У Малого Кызылкума\n'
          '• Протяжённость ~170 км\n\n'
          'Высота:\n'
          '• Высшая точка — пик Хайдаркан — 2 169 м\n'
          '• Средняя: 1 000–1 500 м\n'
          '• Относительно невысокие горы\n\n'
          'Особенности:\n'
          '• Наскальные рисунки (петроглифы)\n'
          '• Древние святилища\n'
          '• Священное место\n'
          '• Исторические памятники\n\n'
          'Известные места:\n'
          '• Пик Хайдаркан\n'
          '• Святыня (пещера) Хазрати Давуда\n'
          '• «Священная рыба» в городе Нурата\n'
          '• Около 40 000 наскальных изображений\n\n'
          'Водные ресурсы:\n'
          '• Родники и ключи\n'
          '• Вода для орошения\n'
          '• Рыбные хозяйства\n'
          '• Питьевое водоснабжение\n\n'
          'Флора и фауна:\n'
          '• Заросли грецкого ореха и фисташки\n'
          '• Горные козлы и хищные птицы\n\n'
          'Животноводство:\n'
          '• Разведение овец и коз\n'
          '• Пастбища\n'
          '• Основное занятие местного населения\n\n'
          'Историческое значение:\n'
          '• Древние караванные пути\n'
          '• Исторические святыни\n'
          '• Археологические находки\n'
          '• Культурное наследие\n\n'
          'Туризм:\n'
          '• Исторический туризм\n'
          '• Паломнический туризм\n'
          '• Природный туризм\n'
          '• Археологический туризм\n\n'
          'Значение:\n'
          '• Экосистема\n'
          '• Историческое наследие\n'
          '• Туристический потенциал\n'
          '• Основа быта местного населения',
      'geo_mtn_kopet': 'Копетдаг',
      'geo_mtn_kopet_m': '1 500 м',
      'geo_mtn_kopet_desc':
          'Копетдаг — горы на западе Узбекистана.\n\n'
          'Расположение:\n'
          '• Юг Бухарской области\n'
          '• Граница с Туркменистаном\n'
          '• Общая длина хребта ~650 км\n'
          '• На территории Узбекистана ~100 км\n\n'
          'Высота:\n'
          '• В Узбекистане: 800–1 500 м\n'
          '• Относительно низкие горы\n'
          '• Крутой подъём от равнины\n\n'
          'Особенности:\n'
          '• Сухой климат\n'
          '• Редкая растительность\n'
          '• Скалы и утёсы\n'
          '• Эрозия\n\n'
          'Растительность:\n'
          '• Дикие яблони\n'
          '• Кустарники\n'
          '• Саксаул\n'
          '• Степные травы\n\n'
          'Животный мир:\n'
          '• Горные козлы\n'
          '• Лисы\n'
          '• Змеи\n'
          '• Птицы\n\n'
          'Климат:\n'
          '• Жаркий и сухой\n'
          '• Летом до +40 °C\n'
          '• Зимой 0…+10 °C\n'
          '• Мало осадков\n\n'
          'Население:\n'
          '• Низкая плотность\n'
          '• Животноводство\n'
          '• В основном овцы и козы\n\n'
          'Полезные ископаемые:\n'
          '• Строительное сырьё\n'
          '• Известняк\n'
          '• Гипс\n'
          '• Щебень\n\n'
          'Значение:\n'
          '• Естественная граница\n'
          '• Экосистема\n'
          '• Пастбища\n'
          '• Минеральные ресурсы',
      'geo_mtn_qoratov': 'Каратау',
      'geo_mtn_qoratov_m': '922 м',
      'geo_mtn_qoratov_desc':
          'Каратау — «Чёрные горы».\n\n'
          'Расположение:\n'
          '• Навоийская область\n'
          '• Среди пустыни Кызылкум\n'
          '• Длина ~50 км\n'
          '• Ширина ~20 км\n\n'
          'Высота:\n'
          '• Максимум 922 м\n'
          '• Низкие горы\n'
          '• Среди пустыни\n\n'
          'Особенности:\n'
          '• Тёмные породы (отсюда название)\n'
          '• Богаты полезными ископаемыми\n'
          '• Древние породы\n\n'
          'Полезные ископаемые:\n'
          '• Золото (Мурунтау)\n'
          '• Медь\n'
          '• Молибден\n'
          '• Вольфрам\n'
          '• Уран\n\n'
          'Месторождение Мурунтау:\n'
          '• Крупнейший золотой рудник Центральной Азии\n'
          '• Открытая разработка\n'
          '• Город Зарафшан вырос при руднике\n'
          '• Тысячи рабочих мест\n\n'
          'Флора и фауна:\n'
          '• Пустынная растительность, саксаул\n'
          '• Пустынные животные, ящерицы\n\n'
          'Климат:\n'
          '• Континентальный пустынный\n'
          '• Летом очень жарко (+45 °C)\n'
          '• Зимой холодно (до −15 °C)\n'
          '• Очень мало осадков\n\n'
          'Население:\n'
          '• Шахтёры и горняки\n'
          '• Зарафшан\n'
          '• Учкудук\n'
          '• Посёлок Навбахор\n\n'
          'Значение:\n'
          '• Экономика (золото)\n'
          '• Рабочие места\n'
          '• Экспорт\n'
          '• Государственный бюджет',
      'geo_mtn_qurama': 'Курминские (Курдаминские) горы (Курама)',
      'geo_mtn_qurama_m': '3 769 м',
      'geo_mtn_qurama_desc':
          'Курама — часть системы Тянь-Шаня.\n\n'
          'Расположение:\n'
          '• Ташкентская и Наманганская области\n'
          '• Северо-запад Ферганской долины\n'
          '• Протяжённость ~170 км\n\n'
          'Высота:\n'
          '• Пик Байсунтау — 3 769 м\n'
          '• Средняя: 2 000–3 000 м\n'
          '• Каменистые горы\n\n'
          'Особенности:\n'
          '• Отделяет Ферганскую долину от Мирзачуля\n'
          '• Естественный барьер\n'
          '• Сложные транспортные пути\n\n'
          'Перевалы:\n'
          '• Перевал Камчик (Ташкент–Андижан)\n'
          '• Высота 2 267 м\n'
          '• Доступен круглый год\n'
          '• Дорога через туннель\n'
          '• Перевал Койтепа\n'
          '• Другие малые перевалы\n\n'
          'Реки:\n'
          '• Чирчик\n'
          '• Ангрен\n'
          '• Карасуу\n\n'
          'Растительность:\n'
          '• Арчовые леса\n'
          '• Ореховые насаждения\n'
          '• Альпийские луга\n'
          '• Декоративные виды\n\n'
          'Животные:\n'
          '• Горные козлы\n'
          '• Дикие кабаны\n'
          '• Птицы\n'
          '• Хищники\n\n'
          'Туризм:\n'
          '• Горный туризм\n'
          '• Зимние виды спорта\n'
          '• Природный туризм\n'
          '• Пешие маршруты\n\n'
          'Значение:\n'
          '• Транспорт (туннель Камчик)\n'
          '• Водные ресурсы\n'
          '• Туризм\n'
          '• Экосистема\n\n'
          'История:\n'
          '• Древние караванные пути\n'
          '• Великий шёлковый путь\n'
          '• Исторические перевалы',
      'geo_mount_info_title': 'Сводно о горах',
      'geo_mount_info_share': 'Доля горной территории: ~20% (прибл.)',
      'geo_mount_info_peak': 'Высшая точка: Адельунга (4 301 м) — Тянь-Шань',
      'geo_mount_info_systems': 'Основные системы: Тянь-Шань, Памиро-Алай',
      'geo_mount_info_glaciers': 'Ледники: ~650 км²',
      'geo_mount_info_value': 'Значение: вода, туризм, полезные ископаемые',
      'geo_mins_title': 'Полезные ископаемые',
      'geo_mins_head': 'Узбекистан богат полезными ископаемыми',
      'geo_mins_lead': 'Свыше 100 видов сырья и 2000+ рудных полей и месторождений.',
      'geo_min_gold': 'Золото',
      'geo_min_gold_sub': 'Драгоценный металл',
      'geo_min_gold_desc':
          'Узбекистан занимает 4-е место в мире по добыче золота.\n\n'
          'Основные месторождения:\n\n'
          'Мурунтау (Навоийская область):\n'
          '• Крупнейший рудник Центральной Азии\n'
          '• Открытая разработка\n'
          '• Около 60–70 т в год\n\n'
          '• Кызылкум (Навоийская область)\n'
          '• Амантаутау (Джизакская область)\n'
          '• Чармитан (Навоийская область)\n'
          '• Маржонбулок (Джизакская область)\n\n'
          'Запасы:\n'
          '• Разведанные запасы: 3 000 т\n'
          '• Годовая добыча: 100 т\n'
          '• Доля в мировой добыче: 3,3%\n\n'
          'Применение:\n'
          '• Ювелирные изделия\n'
          '• Инвестиции\n'
          '• Золотовалютные резервы\n'
          '• Электронная промышленность\n'
          '• Медицина\n\n'
          'Экспорт:\n'
          '• Поставки на мировой рынок\n'
          '• Среди главных экспортных товаров\n'
          '• Источник валютной выручки\n\n'
          'История:\n'
          '• Добыча с древности\n'
          '• Эпоха Шёлкового пути\n'
          '• Расширение в советский период\n'
          '• Развитие после независимости\n\n'
          'Производство:\n'
          '• НГМК «Навои»\n'
          '• Современные технологии\n'
          '• Соблюдение экологических стандартов',
      'geo_min_copper': 'Медь',
      'geo_min_copper_sub': 'Цветной металл',
      'geo_min_copper_desc':
          'В Узбекистане есть крупные медные месторождения.\n\n'
          'Основные объекты:\n\n'
          'ГМК «Алмалык» (Ташкентская область):\n'
          '• Крупнейший производитель меди в стране\n'
          '• Также добывают молибден\n'
          '• Работает с 1951 года\n\n'
          '• Рудник Кальмыкыр\n'
          '• Рудник Хандиза\n'
          '• Рудник Калмакир\n\n'
          'Производство:\n'
          '• Около 100 000 т в год\n'
          '• Лидер в Центральной Азии\n'
          '• Продукция на мировом рынке\n\n'
          'Применение:\n'
          '• Электропровода\n'
          '• Строительные материалы\n'
          '• Машиностроение\n'
          '• Транспорт\n'
          '• Электроника\n\n'
          'Спутники медной руды:\n'
          '• Молибден\n'
          '• Сера\n'
          '• Цинк\n'
          '• Серебро\n\n'
          'АГМК (ранее Алмалыкский комбинат):\n'
          '• Основан в 1951 году\n'
          '• Более 10 000 сотрудников\n'
          '• Экспортная ориентация\n'
          '• Современные технологии\n\n'
          'Экология:\n'
          '• Очистные сооружения\n'
          '• Переработка отходов\n'
          '• Охрана окружающей среды',
      'geo_min_gas': 'Природный газ',
      'geo_min_gas_sub': 'Энергетика',
      'geo_min_gas_desc':
          'Узбекистан — крупнейший производитель природного газа в Центральной Азии.\n\n'
          'Основные месторождения:\n\n'
          'Газли (Бухарская область):\n'
          '• Крупнейшее месторождение\n'
          '• Открыто в 1956 году\n'
          '• Около 30% газа страны\n\n'
          '• Шуртан (Кашкадарья)\n'
          '• Каракуль (Бухара)\n'
          '• Устюрт (Каракалпакстан)\n'
          '• Денизкуль\n\n'
          'Запасы:\n'
          '• Разведанные: 1,8 трлн м³\n'
          '• Доля в мировых запасах: 0,6%\n'
          '• Оценочный срок — 30–40 лет\n\n'
          'Добыча:\n'
          '• 60–65 млрд м³ в год\n'
          '• Внутреннее потребление ~50 млрд м³\n'
          '• Экспорт ~10–15 млрд м³\n\n'
          'Применение:\n'
          '• Выработка электроэнергии\n'
          '• Промышленность\n'
          '• Бытовые нужды населения\n'
          '• Химическая промышленность\n'
          '• Транспорт (газовое топливо)\n\n'
          'Экспорт:\n'
          '• Россия\n'
          '• Китай\n'
          '• Казахстан\n\n'
          'Трубопроводы:\n'
          '• Центральная Азия — Китай\n'
          '• Северное направление\n'
          '• Внутренние сети\n\n'
          'Перспективы:\n'
          '• Освоение новых месторождений\n'
          '• Переработка газа\n'
          '• Химическая переработка',
      'geo_min_oil': 'Нефть',
      'geo_min_oil_sub': 'Энергетика',
      'geo_min_oil_desc':
          'В Узбекистане разрабатываются нефтяные месторождения.\n\n'
          'Основные месторождения:\n\n'
          'Мингбулак (Наманганская область):\n'
          '• Одно из старейших (с 1992 г.)\n'
          '• Более 1 млн т в год\n\n'
          '• Кокдумалак (Кашкадарья)\n'
          '• Аламберды (Кашкадарья)\n'
          '• Сургил (Сурхандарья)\n'
          '• Каракуль (Бухара)\n\n'
          'Запасы:\n'
          '• Около 600 млн т\n'
          '• Осваиваются новые месторождения\n\n'
          'Добыча:\n'
          '• Около 3–4 млн т в год\n'
          '• Закрывает часть внутреннего спроса\n'
          '• Частично нужен импорт\n\n'
          'Применение:\n'
          '• Автотопливо (бензин, ДТ)\n'
          '• Нефтепереработка\n'
          '• Химическая промышленность\n'
          '• Мазут для отопления\n\n'
          'Переработка:\n'
          '• Ферганский НПЗ\n'
          '• Бухарский НПЗ\n'
          '• Заводы в Шахрисабзе\n\n'
          'Продукция:\n'
          '• Бензин (А-80, А-91, А-95)\n'
          '• Дизельное топливо\n'
          '• Авиационный керосин\n'
          '• Мазут\n'
          '• Смазочные масла\n\n'
          'Развитие:\n'
          '• Поиск новых месторождений\n'
          '• Модернизация заводов\n'
          '• Экологические технологии',
      'geo_min_coal': 'Уголь',
      'geo_min_coal_sub': 'Твёрдое топливо',
      'geo_min_coal_desc':
          'В Узбекистане разрабатываются угольные месторождения.\n\n'
          'Основные:\n\n'
          'Ангрен (Ташкентская область):\n'
          '• Крупнейший\n'
          '• Бурый уголь\n'
          '• Открытый способ добычи\n\n'
          '• Шаргун (Сурхандарья)\n'
          '• Байсун (Сурхандарья)\n\n'
          'Запасы:\n'
          '• ~1,8 млрд т\n'
          '• Преимущественно бурый уголь\n\n'
          'Добыча:\n'
          '• 3–4 млн т в год\n'
          '• В основном Ангренское месторождение\n\n'
          'Применение:\n'
          '• Тепловые электростанции\n'
          '• Ангренская ТЭС\n'
          '• Промышленные предприятия\n'
          '• Коммунальное теплоснабжение\n\n'
          '«Ангренуголь»:\n'
          '• С 1940 года\n'
          '• Подземная и открытая добыча\n'
          '• Идёт модернизация\n\n'
          'Экология:\n'
          '• Очистка дымовых газов\n'
          '• Рекультивация земель\n'
          '• Современные технологии\n\n'
          'Перспективы:\n'
          '• Переход к зелёной энергетике\n'
          '• Экологические требования\n'
          '• Реконструкция предприятий',
      'geo_min_uranium': 'Уран',
      'geo_min_uranium_sub': 'Радиоактивный металл',
      'geo_min_uranium_desc':
          'Узбекистан — одна из стран, богатых ураном.\n\n'
          'Основные месторождения:\n'
          '• Учкудук (Навоийская область)\n'
          '• Зарафшан (Навои)\n'
          '• Нурабад\n\n'
          'Запасы:\n'
          '• Около 2% мировых запасов\n'
          '• Точные данные не разглашаются\n\n'
          'Добыча:\n'
          '• 2 400–3 000 т в год\n'
          '• 7-е место в мире\n\n'
          'Применение:\n'
          '• Топливо для АЭС\n'
          '• Медицина\n'
          '• Научные исследования\n'
          '• Военное применение (в других странах)\n\n'
          '«НГМК Навои»:\n'
          '• Добыча и переработка урана\n'
          '• Высокий уровень безопасности\n'
          '• Международный контроль\n\n'
          'Экспорт:\n'
          '• Россия\n'
          '• Китай\n'
          '• Республика Корея\n'
          '• Отдельные страны Европы\n\n'
          'Безопасность:\n'
          '• Режимные объекты\n'
          '• Радиационный контроль\n'
          '• Экологические стандарты\n'
          '• Международные требования\n\n'
          'Значение:\n'
          '• Стратегический ресурс\n'
          '• Энергетика\n'
          '• Экспортная продукция',
      'geo_min_build': 'Строительные материалы',
      'geo_min_build_sub': 'Нерудные',
      'geo_min_build_desc':
          'В Узбекистане добывают многие строительные материалы.\n\n'
          'Известняк и гипс:\n'
          '• Самарканд, Кашкадарья, Джиззак\n'
          '• Строительство\n\n'
          'Гранит и мрамор:\n'
          '• Джиззак (мрамор), Самарканд, Ташкентская область\n'
          '• Облицовочный камень\n\n'
          'Известняк (CaCO₃) для цемента:\n'
          '• Самарканд, Сурхандарья\n'
          '• Производство цемента\n\n'
          'Гипс:\n'
          '• Во многих областях\n'
          '• Строительные материалы\n\n'
          'Песок и щебень:\n'
          '• Долины Амударьи и Сырдарьи\n'
          '• Для бетона\n\n'
          'Глина:\n'
          '• Многие районы\n'
          '• Кирпич, керамика\n\n'
          'Цементные заводы:\n'
          '• Кувасай (Фергана)\n'
          '• Бекабад (Ташкентская обл.)\n'
          '• Ахангаран (Ташкентская обл.)\n'
          '• Шерабад (Сурхандарья)\n\n'
          'Производство:\n'
          '• Цемент: 8–10 млн т в год\n'
          '• Кирпич: миллионы штук\n'
          '• Мрамор экспортируется\n\n'
          'Значение:\n'
          '• Для строительной отрасли\n'
          '• Закрывает внутренний спрос\n'
          '• Часть продукции экспортируется',
      'geo_min_salt': 'Соль и прочие минералы',
      'geo_min_salt_sub': 'Сырьё для химии',
      'geo_min_salt_desc':
          'Имеются разнообразные источники химического сырья.\n\n'
          'Соль:\n'
          '• Вокруг Аральского моря\n'
          '• Каракалпакстан\n'
          '• Природные солёные озёра\n\n'
          'Фосфориты:\n'
          '• Кашкадарья\n'
          '• Сурхандарья\n'
          '• Производство удобрений\n\n'
          'Сера:\n'
          '• Сурхандарья\n'
          '• Ферганская область\n'
          '• При переработке газа\n\n'
          'Каолин:\n'
          '• Ангрен (Ташкентская область)\n'
          '• Керамическая промышленность\n'
          '• Фарфор и гончарное производство\n\n'
          'Свинец и цинк:\n'
          '• АГМК «Алмалык»\n'
          '• Алмалыкские рудники\n'
          '• Совместно с медью\n\n'
          'Вольфрам и молибден:\n'
          '• Алмалыкский комбинат\n'
          '• Каратау\n'
          '• Для металлургии\n\n'
          'Драгоценные камни:\n'
          '• Бирюза\n'
          '• Лазурит\n'
          '• Гранат\n'
          '• Для ювелирной промышленности\n\n'
          'Значение:\n'
          '• Химическая промышленность\n'
          '• Сельское хозяйство (удобрения)\n'
          '• Промышленность',
      'geo_mins_stat_title': 'Статистика',
      'geo_mins_stat_types': 'Видов: 100+',
      'geo_mins_stat_mines': 'Рудников и полей: 2 000+',
      'geo_mins_stat_gold': 'Золото (мировой рейтинг): 4-е место',
      'geo_mins_stat_uran': 'Уран (мировой рейтинг): 7-е место',
      'geo_mins_stat_export': 'Ключевой экспорт: золото, медь, газ',
      'geo_land_sub1': 'Виды рельефа',
      'geo_land_sub2': 'Природные явления',
      'geo_relief_title': 'Виды рельефа',
      'geo_relief_uz_relyefi': 'Рельеф Узбекистана',
      'geo_relief_lead': 'Рельеф очень разнообразен: равнины, горы, долины и пустыни.',
      'geo_rel_tog': 'Горы',
      'geo_rel_tog_desc':
          'Горы расположены в восточной и юго-восточной части территории Узбекистана.\n\n'
          'Основные горные системы:\n\n'
          '1. Тянь-Шань (Северо-восток)\n'
          '• Высшая точка: пик Адельунга (4 301 м)\n'
          '• горы Чимган\n'
          '• Пскемский хребет\n'
          '• Коржантау\n\n'
          '2. Памиро-Алай (Восток)\n'
          '• Алайский хребет\n'
          '• Туркестанский хребет\n'
          '• Зеравшанский хребет\n'
          '• Гиссарский хребет\n\n'
          '3. Копетдаг (Запад)\n'
          '• На границе с Туркменистаном\n'
          '• Невысокие горы (1 000–1 500 м)\n\n'
          'Особенности:\n'
          '• Высоты: 1 000–4 300 м\n'
          '• Снежные вершины\n'
          '• Ледники\n'
          '• Истоки рек\n'
          '• Минеральные воды\n\n'
          'Значение:\n'
          '• Водные ресурсы\n'
          '• Туризм и альпинизм\n'
          '• Полезные ископаемые\n'
          '• Горные пастбища',
      'geo_rel_tekis': 'Равнины',
      'geo_rel_tekis_desc':
          'Занимают большую часть территории Узбекистана.\n\n'
          'Основные равнины:\n\n'
          '1. Туранская низменность\n'
          '• Крупнейшая равнина\n'
          '• Высота: 200–500 м\n'
          '• Здесь расположена пустыня Кызылкум\n\n'
          '2. Мирзачуль (Голодная степь)\n'
          '• В бассейне Сырдарьи\n'
          '• Хорошее водоснабжение\n'
          '• Сельское хозяйство\n\n'
          '3. Равнины в долине Зеравшана\n'
          '• Окрестности Самарканда и Бухары\n'
          '• Плодородные земли\n'
          '• Оросительное земледелие\n\n'
          '4. Равнины в долине Шерабада\n'
          '• Сурхандарьинская область\n'
          '• Жаркий климат\n'
          '• Выращивание хлопка\n\n'
          'Особенности:\n'
          '• Ровная поверхность\n'
          '• Оросительные земли\n'
          '• Удобны для сельского хозяйства\n'
          '• Развит транспорт\n\n'
          'Использование:\n'
          '• Сельское хозяйство\n'
          '• Городское строительство\n'
          '• Размещение промышленности',
      'geo_rel_cho': 'Пустыни',
      'geo_rel_cho_desc':
          'В Узбекистане две крупные пустыни.\n\n'
          '1. Кызылкум\n'
          '• Площадь: ~300 000 км²\n'
          '• Узбекистан и Казахстан\n'
          '• Песчаные барханы и возвышенности\n'
          '• Мало осадков\n\n'
          'Особенности:\n'
          '• Красные пески\n'
          '• Саксаульные заросли\n'
          '• Бедная фауна\n'
          '• Летом до +45 °C, зимой до −25 °C\n\n'
          '2. Каракум\n'
          '• На территории Каракалпакстана\n'
          '• Вблизи Амударьи\n'
          '• Тёмные пески\n\n'
          'Особенности:\n'
          '• Тёмные илистые пески\n'
          '• Солончаковые почвы\n'
          '• Влияние Аральского моря\n'
          '• Экологические проблемы\n\n'
          'В пустынях:\n'
          '• Газовые и нефтяные месторождения\n'
          '• Животноводство (каракульские овцы)\n'
          '• Древесина саксаула\n'
          '• Транспортные магистрали\n\n'
          'Проблемы:\n'
          '• Нехватка воды\n'
          '• Опустынивание\n'
          '• Последствия высыхания Аральского моря',
      'geo_rel_vod': 'Долины',
      'geo_rel_vod_desc':
          'Низины между горами, по которым текут реки.\n\n'
          'Основные долины:\n\n'
          '1. Ферганская долина\n'
          '• Площадь: ~22 000 км²\n'
          '• Один из древнейших культурных центров\n'
          '• Плотное заселение\n\n'
          'Особенности:\n'
          '• Окружена горами\n'
          '• Плодородные почвы\n'
          '• Оросительное земледелие\n'
          '• Фрукты и хлопок\n\n'
          'Области:\n'
          '• Андижан\n'
          '• Наманган\n'
          '• Фергана\n\n'
          '2. Долина Зеравшана\n'
          '• Самарканд и Бухара\n'
          '• Исторические города\n'
          '• Река Зеравшан\n\n'
          '3. Сурхандарьинская долина\n'
          '• Южный регион\n'
          '• Жаркий климат\n'
          '• Хлопок и овощи\n\n'
          '4. Кашкадарьинская долина\n'
          '• Город Карши\n'
          '• Сельское хозяйство\n'
          '• Природный газ\n\n'
          'Значение:\n'
          '• Центр сельского хозяйства\n'
          '• Плотное заселение\n'
          '• Развитая промышленность\n'
          '• Исторические города',
      'geo_rel_plat': 'Плато',
      'geo_rel_plat_desc':
          'Высокие ровные поверхности.\n\n'
          'Основные плато:\n\n'
          '1. Плато Устюрт\n'
          '• На территории Каракалпакстана\n'
          '• Высота: около 200 м\n'
          '• Ровная поверхность\n'
          '• Пустынный климат\n\n'
          'Особенности:\n'
          '• Твёрдые породы\n'
          '• Редкая растительность\n'
          '• Каракульские овцы\n'
          '• Полезные ископаемые\n\n'
          '2. Хребет Каратау\n'
          '• Навоийская область\n'
          '• Низкие горы\n'
          '• Полезные ископаемые\n\n'
          '3. Нуратау\n'
          '• Зеравшанская и Самаркандская области\n'
          '• Высота до 2 000 м\n'
          '• Горные пастбища\n\n'
          'Полезные ископаемые:\n'
          '• Золотые рудники\n'
          '• Медные рудники\n'
          '• Уран\n'
          '• Фосфориты\n\n'
          'Животноводство:\n'
          '• Пастбища\n'
          '• Овцы и козы\n'
          '• Крупный и мелкий скот',
      'geo_rel_river': 'Рельеф в долинах рек',
      'geo_rel_river_desc':
          'Низины вокруг рек.\n\n'
          'Основные реки:\n\n'
          '1. Амударья\n'
          '• Длина: 1 415 км (на территории Узбекистана)\n'
          '• Исток: ледники Памира\n'
          '• Впадает в Аральское море\n\n'
          'Рельеф долины:\n'
          '• Ровные равнины\n'
          '• Дельтовые участки\n'
          '• Плодородные почвы\n'
          '• Ирригационная сеть\n\n'
          '2. Сырдарья\n'
          '• Длина: 2 212 км\n'
          '• Исток: ледники Тянь-Шаня\n'
          '• Впадает в Аральское море\n\n'
          'Рельеф долины:\n'
          '• Мирзачульская равнина\n'
          '• Проходит через Ферганскую долину\n'
          '• Оросительные земли\n\n'
          '3. Зеравшан\n'
          '• Длина: 877 км\n'
          '• Через Самарканд и Бухару\n'
          '• Теряется в пустыне\n\n'
          'Рельеф долины:\n'
          '• Исторические города\n'
          '• Древняя культура\n'
          '• Плодородные почвы\n\n'
          'Особенности:\n'
          '• Аллювиальные почвы\n'
          '• Высокая продуктивность\n'
          '• Хорошее водоснабжение',
      'geo_relief_stat_title': 'Статистика рельефа',
      'geo_relief_stat_high': 'Макс. высота: Адельунга (4 301 м)',
      'geo_relief_stat_low': 'Мин.: Аральское море (−28 м)',
      'geo_relief_stat_avg': 'Средняя высота: ~600 м',
      'geo_relief_stat_mtn': 'Доля гор: ~20%',
      'geo_relief_stat_plain': 'Доля равнин: ~80%',
      'geo_phenomena_title': 'Природные явления',
      'geo_ph_quake': 'Землетрясения',
      'geo_ph_quake_desc':
          'Узбекистан расположен в зонах высокого сейсмического риска.\n\n'
          'Сейсмические зоны:\n'
          '• Ташкент — сильное землетрясение 1966 года (8–9 баллов)\n'
          '• Ферганская долина — 7–8 баллов\n'
          '• Андижан — 1902 год (6–7 баллов)\n'
          '• Наманган — исторические землетрясения\n\n'
          'Причины:\n'
          '• Движение Индийской литосферной плиты\n'
          '• Продолжается горообразование\n'
          '• Напряжённость земной коры\n'
          '• Стык геологических зон\n\n'
          'Последствия:\n'
          '• Разрушение зданий\n'
          '• Жертвы среди населения\n'
          '• Экономический ущерб\n'
          '• Повреждение инфраструктуры\n\n'
          'Меры защиты:\n'
          '• Соблюдение норм сейсмостойкости\n'
          '• Усиление и укрепление зданий\n'
          '• Просвещение населения\n'
          '• Готовность к ЧС\n'
          '• Система мониторинга\n\n'
          'История:\n'
          '• Землетрясение в Ташкенте 1966 года — крупнейшее\n'
          '• Город восстановлен\n'
          '• Помощь со всего СССР\n'
          '• Выстроен современный город',
      'geo_ph_sel': 'Сели',
      'geo_ph_sel_desc':
          'Возникают из-за весеннего таяния ледников и сильных осадков.\n\n'
          'Опасные районы:\n'
          '• Горные области\n'
          '• Ферганская долина\n'
          '• Сурхандарьинская область\n'
          '• Кашкадарьинская область\n'
          '• Самаркандская область\n\n'
          'Причины:\n'
          '• Таяние снега и ледников в горах\n'
          '• Сильные дожди\n'
          '• Вырубка лесов\n'
          '• Эрозия почв\n'
          '• Выход рек из берегов\n\n'
          'Последствия:\n'
          '• Размыв дорог\n'
          '• Разрушение домов\n'
          '• Ущерб сельскохозяйственным культурам\n'
          '• Разрыв транспортных путей\n'
          '• Жертвы среди населения\n\n'
          'Профилактика:\n'
          '• Строительство дамб и противоселевых сооружений\n'
          '• Очистка русел рек\n'
          '• Лесонасаждения\n'
          '• Система мониторинга\n'
          '• Оповещение населения\n\n'
          'Наиболее опасные периоды:\n'
          '• Март–апрель (весна)\n'
          '• Май–июнь (таяние ледников)\n'
          '• Сентябрь (осенние дожди)',
      'geo_ph_qong': 'Саранча',
      'geo_ph_qong_desc':
          'Насекомые, наносящие большой ущерб сельскому хозяйству.\n\n'
          'Виды:\n'
          '• Итальянская (марокканская) саранча\n'
          '• Лесная саранча\n'
          '• Азиатская саранча\n\n'
          'Опасные районы:\n'
          '• Джизакская область\n'
          '• Навоийская область\n'
          '• Самаркандская область\n'
          '• Кашкадарьинская область\n\n'
          'Жизненный цикл:\n'
          '• Яйцо — осенью\n'
          '• Личинка — весной\n'
          '• Взрослая особь — летом\n'
          '• Лёт — май–июнь\n'
          '• Откладка яиц — июль–август\n\n'
          'Вред:\n'
          '• Поедают растения\n'
          '• Потеря урожая\n'
          '• Ущерб пастбищам\n'
          '• Большие экономические потери\n\n'
          'Меры борьбы:\n'
          '• Химические препараты\n'
          '• Биологический метод (энтомофаги)\n'
          '• Уничтожение яиц\n'
          '• Мониторинг и прогноз\n'
          '• Участие населения\n\n'
          'История:\n'
          '• 2019–2020 — массовое распространение\n'
          '• Разработана государственная программа\n'
          '• Международное сотрудничество',
      'geo_ph_drought': 'Засуха',
      'geo_ph_drought_desc':
          'Длительное отсутствие или малое количество осадков.\n\n'
          'Причины:\n'
          '• Изменение климата\n'
          '• Континентальный климат\n'
          '• Удалённость от моря\n'
          '• Атмосферные процессы\n\n'
          'Последствия:\n'
          '• Снижение урожая\n'
          '• Нехватка корма для скота\n'
          '• Дефицит воды\n'
          '• Опустынивание\n'
          '• Экономический ущерб\n\n'
          'Опасные районы:\n'
          '• Каракалпакстан\n'
          '• Бухарская область\n'
          '• Навоийская область\n'
          '• Окрестности пустыни Кызылкум\n\n'
          'Воздействие:\n'
          '• Ущерб сельскому хозяйству\n'
          '• Водоснабжение населения\n'
          '• Промышленное производство\n'
          '• Экологические нарушения\n\n'
          'Профилактика:\n'
          '• Совершенствование оросительных систем\n'
          '• Водосберегающие технологии\n'
          '• Засухоустойчивые сорта\n'
          '• Лесонасаждения\n'
          '• Строительство водохранилищ\n\n'
          'Периодичность:\n'
          '• Примерно раз в 3–5 лет\n'
          '• Сильная засуха раз в 10–15 лет\n'
          '• Наиболее тяжело летом',
      'geo_ph_wind': 'Ветры',
      'geo_ph_wind_desc':
          'В Узбекистане дуют ветры разных направлений.\n\n'
          'Типы ветров:\n\n'
          '1. Афганский (с юга)\n'
          '• Жаркий и сухой\n'
          '• Часто летом\n'
          '• Повышает температуру\n'
          '• Поднимает пыль\n\n'
          '2. Штормовой ветер\n'
          '• Сильный весенний ветер\n'
          '• Скорость: 20–30 м/с\n'
          '• Повреждает здания\n'
          '• Ломает деревья\n\n'
          '3. Фён (нисходящий с гор)\n'
          '• Жаркий и сухой\n'
          '• В горных областях\n'
          '• Таяние снега\n\n'
          '4. Бриз (местный ветер)\n'
          '• Между горами и долиной\n'
          '• Отличается днём и ночью\n'
          '• Влияние на климат\n\n'
          'Последствия:\n'
          '• Эрозия (снос почвы)\n'
          '• Повреждение растений\n'
          '• Повреждение зданий\n'
          '• Затруднение транспорта\n'
          '• Пыльные бури\n\n'
          'Польза:\n'
          '• Ветроэнергетика\n'
          '• Смягчает климат\n'
          '• Циркуляция воздуха\n'
          '• Опыление растений\n\n'
          'Наиболее ветреные зоны:\n'
          '• Плато Устюрт\n'
          '• Пустыня Кызылкум\n'
          '• Горные перевалы',
      'geo_ph_wave': 'Холодные и жаркие волны',
      'geo_ph_wave_desc':
          'Резкое изменение температуры.\n\n'
          'Холодные волны:\n'
          '• Зимой ниже −20 °C\n'
          '• Приходят с севера\n'
          '• Длятся 3–7 дней\n'
          '• Вред сельскому хозяйству\n\n'
          'Воздействие:\n'
          '• Подмерзание растений\n'
          '• Замерзание оросительных систем\n'
          '• Трудности для животных\n'
          '• Рост потребления энергии\n'
          '• Проблемы транспорта\n\n'
          'Защита:\n'
          '• Теплицы\n'
          '• Укрытие растений\n'
          '• Содержание животных в помещениях\n'
          '• Подогрев трубопроводов\n\n'
          'Жаркие волны:\n'
          '• Летом выше +40 °C\n'
          '• Приходят с юга\n'
          '• Длятся 5–10 дней\n'
          '• Влияние на здоровье населения\n\n'
          'Последствия:\n'
          '• Нехватка воды\n'
          '• Страдает урожай\n'
          '• Риск пожаров\n'
          '• Проблемы со здоровьем\n'
          '• Рост потребления электроэнергии\n\n'
          'Рекомендации:\n'
          '• Пить больше воды\n'
          '• Меньше находиться на солнце\n'
          '• Использовать кондиционер\n'
          '• Носить светлую одежду\n\n'
          'Периоды:\n'
          '• Зима: декабрь–январь\n'
          '• Лето: июнь–июль–август',
      'geo_ph_koch': 'Оползни',
      'geo_ph_koch_desc':
          'Соскальзывание почвы и камней на горных склонах.\n\n'
          'Причины:\n'
          '• Разрушение горных пород\n'
          '• Сильные дожди\n'
          '• Землетрясения\n'
          '• Сток воды\n'
          '• Антропогенное воздействие\n\n'
          'Опасные районы:\n'
          '• Горы Ташкентской области\n'
          '• Горы Ферганской долины\n'
          '• Горные районы Сурхандарьи\n'
          '• Горы Кашкадарьинской области\n\n'
          'Виды:\n\n'
          '1. Почвенный оползень\n'
          '• Скольжение рыхлого грунта\n'
          '• На переувлажнённых склонах\n\n'
          '2. Каменный оползень / обвал\n'
          '• Обрушение и катение камней\n'
          '• Очень опасно\n\n'
          '3. Смешанный оползень\n'
          '• Смесь почвы и камней\n\n'
          'Последствия:\n'
          '• Перекрытие дорог\n'
          '• Повреждение домов\n'
          '• Жертвы среди населения\n'
          '• Утрата сельхозугодий\n'
          '• Перекрытие оросительных каналов\n\n'
          'Меры защиты:\n'
          '• Инженерные защитные сооружения\n'
          '• Установка барьеров\n'
          '• Лесонасаждения\n'
          '• Регулирование стока воды\n'
          '• Мониторинг\n'
          '• Переселение из опасных зон\n\n'
          'Прогнозирование:\n'
          '• Геологические изыскания\n'
          '• Наблюдение за осадками\n'
          '• Сейсмический мониторинг',
      'geo_ph_melt': 'Таяние ледников',
      'geo_ph_melt_desc':
          'Постепенное таяние горных ледников.\n\n'
          'Ледники в Узбекистане:\n'
          '• В горах Ферганской области\n'
          '• В горах Ташкентской области\n'
          '• Общая площадь: ~650 км²\n'
          '• Годовое сокращение: 0,5–1%\n\n'
          'Причины:\n'
          '• Глобальное потепление\n'
          '• Рост температуры\n'
          '• Изменение осадков\n'
          '• Антропогенное влияние\n\n'
          'Значение:\n'
          '• Истоки рек\n'
          '• Водные ресурсы\n'
          '• Влияние на климат\n'
          '• Важны для экосистемы\n\n'
          'Последствия:\n\n'
          'Краткосрочно:\n'
          '• Рост стока воды\n'
          '• Риск селей и паводков\n'
          '• Переполнение озёр\n\n'
          'Долгосрочно:\n'
          '• Исчезновение ледников\n'
          '• Снижение расхода рек\n'
          '• Дефицит воды для орошения\n'
          '• Экологические проблемы\n\n'
          'Влияние на реки:\n'
          '• Зеравшан — ледниковое питание\n'
          '• Кашкадарья — ледниковое питание\n'
          '• Сурхандарья — частично\n'
          '• Чирчик — ледниковое питание\n\n'
          'Мониторинг:\n'
          '• Спутниковые наблюдения\n'
          '• Метеостанции\n'
          '• Измерение расхода воды\n'
          '• Международное сотрудничество\n\n'
          'Меры защиты:\n'
          '• Рациональное использование воды\n'
          '• Водосберегающие технологии\n'
          '• Экологические программы\n'
          '• Международное сотрудничество',
      'geo_map_sub1': 'Сведения о нашей республике',
      'geo_map_sub_karakalpak': 'Республика Каракалпакстан',
      'geo_map_sub2': 'Сведения о соседних странах',
      'geo_karakalpak_title': 'Республика Каракалпакстан',
      'geo_karakalpak_capital': 'Столица: Нукус',
      'geo_karakalpak_intro': 'Каракалпакстан — автономная республика на северо-западе Узбекистана. Территория в основном пустынная и полупустынная (Каракумы, зона Приаралья). Богат природными ресурсами: соль, газ, известняк и другие полезные ископаемые.',
      'geo_karakalpak_section_title': 'Основные показатели',
      'geo_karakalpak_border_label': 'Длина границ (прибл.)',
      'geo_karakalpak_v_area': '166 600 км²',
      'geo_karakalpak_v_pop': '~2,04 млн чел. (2024)',
      'geo_karakalpak_v_lang': 'Каракалпакский и узбекский языки',
      'geo_karakalpak_v_currency': 'Узбекский сум (som)',
      'geo_karakalpak_v_border': '≈ 1 700 – 1 800 км',
      'geo_republic_title': 'Республика Узбекистан',
      'geo_republic_capital': 'Столица: Ташкент',
      'geo_republic_lead': 'Узбекистан — независимое государство в Центральной Азии. Столица Ташкент — крупный экономический и культурный центр; форма правления — республика. Экономика развивается за счёт промышленности, сельского хозяйства и сферы услуг.',
      'geo_republic_v_area': '448 978 км²',
      'geo_republic_v_pop': 'свыше 36 млн чел.',
      'geo_republic_v_lang': 'узбекский (гос.), русский широко используется',
      'geo_republic_v_currency': 'узбекский сум (UZS)',
      'geo_republic_admin_label': 'Административное деление',
      'geo_republic_v_admin': '12 вилоятов и Республика Каракалпакстан',
      'geo_republic_btn_map': 'Политическая карта мира',
      'geo_borders_title': 'Границы',
      'geo_neighbors_section': 'Соседние страны',
      'geo_capital_prefix': 'Столица: ',
      'geo_million_short': 'млн',
      'geo_stat_area': 'Площадь',
      'geo_stat_pop': 'Население',
      'geo_stat_languages': 'Офиц. языки',
      'geo_stat_currency': 'Валюта',
      'geo_stat_border_uz': 'Длина границы с Узбекистаном',
      'doc_decisions': 'Постановления',
      'doc_laws': 'Законы',
      'doc_all': 'Все',
      'doc_empty': 'Документы не найдены',
      'doc_offline_mode': 'Офлайн режим',
      'doc_refresh': 'Обновить',
      'doc_built_in': 'Встроенный',
      'doc_downloaded': 'Загружен',
      'doc_offline_ready': 'Скачано с сервера — доступно офлайн',
      'doc_download': 'Загрузить',
      'doc_download_update': 'Загрузить обновление',
      'doc_delete_local': 'Удалить локальную копию',
      'doc_need_download': 'Для офлайн чтения сначала загрузите файл',
      'doc_download_failed': 'Не удалось загрузить. Проверьте интернет и сервер',
      'doc_delete_confirm_title': 'Удалить локальную копию?',
      'doc_delete_confirm_body': 'Будет удалён только файл на устройстве. Документ на сервере и в админке не изменится.',
      'doc_delete_confirm_action': 'Удалить',
      'doc_file_not_on_device': 'PDF не найден. Загрузите файл снова.',
      'chem_rx_section_types': 'Типы реакций',
      'chem_rx_symbols_title': 'Знаки реакции:',
      'chem_rx_examples': 'Примеры:',
      'chem_rx_close': 'Закрыть',
      'chem_rx_retry': 'Повторить',
      'chem_rx_error': 'Не удалось загрузить данные',
      'settings_general': 'Общие настройки',
      'settings_language': 'Язык',
      'settings_dark_mode': 'Темная тема',
      'settings_about': 'О приложении',
      'settings_about_sub': 'Информация и лицензия',
      'about_title': 'Химия и География',
      'about_desc': 'Это приложение создано для помощи школьникам Узбекистана в изучении химии и географии.',
      'about_features': 'Особенности:',
      'about_feature_1': '• Информация о химических элементах',
      'about_feature_2': '• Периодическая таблица',
      'about_feature_3': '• Химические реакции',
      'about_feature_4': '• География Узбекистана',
      'about_feature_5': '• Климат и погода',
      'about_feature_6': '• Интерактивное обучение',
      'about_copyright': '© 2026 Все права защищены',
      'close': 'Закрыть',
      'settings_author': 'Об авторе',
      'author_name': 'Бекимбетова Гульназ Набатовна',
      'author_role': 'Преподаватель химии',
      'author_main_info': 'Основная информация',
      'author_birth_date': 'Дата рождения',
      'author_birth_place': 'Место рождения',
      'author_nationality': 'Национальность',
      'author_education': 'Образование',
      'author_specialty': 'Специальность',
      'author_languages': 'Иностранные языки',
      'author_current_job': 'Текущее место работы',
      'author_position': 'Должность',
      'author_org': 'Организация',
      'author_dept': 'Кафедра',
      'author_start_date': 'Дата начала',
      'author_experience': 'Трудовая деятельность',
      'author_additional': 'Дополнительная информация',
      'author_degree': 'Ученая степень',
      'author_title': 'Ученое звание',
      'author_awards': 'Государственные награды',
      'author_deputy': 'Депутатство',
      'author_none': 'Нет',
      'author_uzb': 'Узбек',
      'author_qoraqalpoq': 'Каракалпак',
      'author_higher': 'Высшее',
      'author_chemistry': 'Химия',
      'author_lang_list': 'Русский язык, Турецкий язык',
      'author_senior_teacher': 'Старший преподаватель',
      'author_uni': 'Нукусский государственный технический университет',
      'author_dept_name': 'Химическая инженерия и охрана окружающей среды',
      'author_start_val': 'с 1 апреля 2025 года',
      'author_present': 'настоящее время',
      'rate_title': 'Оцените приложение',
      'rate_subtitle': 'Ваше мнение важно для нас!',
      'rate_submit': 'Отправить',
      'rate_thanks': 'Спасибо! Вы поставили {} звезд.',
      'rate_error_network': 'Ошибка сети. Попробуйте ещё раз.',
      'rate_already_submitted': 'Вы уже оценили приложение.',
      'rate_submit_failed': 'Не удалось отправить. Попробуйте позже.',
      'rate_readonly_subtitle': 'Вы поставили {} звёзд. Спасибо!',
      'rate_done_close': 'Закрыть',
      'settings_rate': 'Оцените приложение',
      'settings_rate_sub': 'Оставьте свой отзыв',
      'settings_rate_submitted': 'Ваша оценка: {} зв.',
      'doc_in_app': 'Внутри приложения',
      'doc_pdf_error': 'PDF файл не найден',
      'doc_loading': 'Загрузка PDF...',
      'settings_version': 'Версия',
      'profile_time': 'Время',
      'profile_activity_time_empty': 'Пока не засчитано',
      'time_unit_hour': 'ч',
      'time_unit_minute': 'мин',
      'time_unit_second': 'с',
      'profile_personal': 'Личные данные',
      'profile_edu': 'Информация об обучении',
      'profile_activity': 'Активность',
      'profile_logout': 'Выход',
      'profile_edit': 'Редактировать профиль',
      'profile_name': 'Имя',
      'profile_email': 'Email',
      'profile_phone': 'Телефон',
      'profile_school': 'Школа',
      'profile_class': 'Класс',
      'profile_save': 'Сохранить',
      'profile_password_section': 'Сменить пароль',
      'profile_password_hint':
          'Если не хотите менять пароль, оставьте три поля ниже пустыми.',
      'profile_current_password': 'Текущий пароль',
      'profile_new_password': 'Новый пароль',
      'profile_confirm_password': 'Подтверждение пароля',
      'profile_password_fill_all':
          'Заполните текущий пароль, новый пароль и подтверждение.',
      'profile_password_too_short': 'Новый пароль — не менее 6 символов.',
      'profile_password_mismatch': 'Новый пароль и подтверждение не совпадают.',
      'profile_updated': 'Профиль обновлен',
      'profile_school_pick': 'Выберите школу',
      'profile_grade_pick': 'Выберите класс',
      'profile_reference_load_failed': 'Не удалось загрузить список школ и классов.',
      'profile_retry': 'Повторить',
      'profile_add_school': 'Новая школа',
      'profile_add_grade': 'Новый класс',
      'profile_new_school_name': 'Название школы',
      'profile_new_school_city': 'Район / город (необязательно)',
      'profile_new_grade_label': 'Класс (например: 9-sinf)',
      'profile_user_info': 'Данные пользователя',
      'profile_not_set': 'Не указано',
      'profile_update_error': 'Не удалось сохранить. Попробуйте снова.',
      'profile_student_suffix': 'ученик',
      'profile_activity_history': 'История активности',
      'profile_achievements': 'Достижения',
      'profile_logout_confirm': 'Вы действительно хотите выйти из аккаунта?',
      'profile_logout_yes': 'Да, выйти',
      'profile_logout_no': 'Нет',
      'profile_logged_out': 'Вы вышли из аккаунта',
      'profile_total_lessons': 'Всего уроков:',
      'profile_study_time': 'Время обучения:',
      'profile_achievement_1': 'Первый урок',
      'profile_achievement_1_desc': 'Вы завершили первый урок',
      'profile_achievement_2': 'Мастер химии',
      'profile_achievement_2_desc': 'Вы завершили 10 уроков химии',
      'profile_achievement_3': 'Знаток географии',
      'profile_achievement_3_desc': 'Вы завершили 10 уроков географии',
      'profile_achievement_4': 'Ученик',
      'profile_achievement_4_desc': 'Вы завершили 50 уроков',
      'profile_achievement_5': 'Чемпион',
      'profile_achievement_5_desc': 'Вы завершили 100 уроков',
      'profile_achievements_subtitle': 'Награды и сертификаты',
      'profile_lessons_total_pattern': '{n} уроков завершено',
      'activity_when_today': 'Сегодня',
      'activity_when_yesterday': 'Вчера',
      'activity_days_ago_suffix': 'дн. назад',
      'activity_history_empty': 'Пока нет записей — дочитайте урок химии до конца или нажмите «Завершить раздел» в географии.',
      'activity_subject_chemistry': 'Химия',
      'activity_subject_geography': 'География',
      'geo_mark_section_complete': 'Раздел изучен',
      'geo_topic_marked_complete': 'Раздел завершён',
      'study_marked_done_snackbar': 'Сохранено',
      'search_hint': 'Введите элемент, соль или формулу...',
      'prop_formula': 'Формула',
      'prop_molar_mass': 'Молярная масса',
      'prop_color': 'Цвет',
      'prop_solubility': 'Растворимость',
      'prop_melt_temp': 'Температура плавления',
      'prop_boil_temp': 'Температура кипения',
      'prop_density': 'Плотность',
      'prop_electrons': 'Количество электронов',
      'prop_valence': 'Валентность',
      'unknown': 'Неизвестно',
      'lang_select': 'Выберите язык',
      'cancel': 'Отмена',
      'toast_lang_changed': 'Язык изменен',
      'toast_theme_dark': 'Темная тема включена',
      'toast_theme_light': 'Светлая тема включена',
      'formula_calc_title': 'Расчет формул',
      'formula_input_hint': 'Введите химическую формулу',
      'formula_example': 'Например: H2O, NaCl, Ca(OH)2',
      'formula_calculate': 'Рассчитать',
      'formula_popular': 'Популярные формулы',
      'formula_result_title': 'Молекулярная масса {}:',
      'formula_total': 'Итого',
      'formula_copy': 'Скопировано',
      'formula_invalid': 'Неверная формула',
      'formula_clear': 'Очистить',
      'formula_backspace': 'Удалить',
      'periodic_interaktiv': 'Интерактивная таблица',
      'menu_natural_resources_map': 'Карта природных ресурсов',
      'natural_resources_map_pinch_hint':
          'Масштаб двумя пальцами, перемещение одним. + / − или кнопка сверху — вписать в экран.',
      'natural_resources_map_fit_tooltip': 'Вписать в экран',
      'natural_resources_map_zoom_in': 'Увеличить',
      'natural_resources_map_zoom_out': 'Уменьшить',
      'natural_resources_map_load_error': 'Не удалось загрузить карту. Перезапустите приложение.',
      'menu_regional_minerals': 'Минералы Каракалпакстана',
      'regional_minerals_map_hint': 'Чтобы увидеть метки на карте, выберите минерал в списке (иконка «глаз»).',
      'regional_minerals_quantity_label': 'Запасы / показатель',
      'regional_minerals_reference_title': 'Источник',
      'regional_minerals_no_reference': 'Источник не указан.',
      'regional_minerals_show_on_map': 'Показать на карте',
      'regional_minerals_hide_on_map': 'Выбрано (на карте)',
      'periodic_qiziqarli': 'Интересные задания',
      'menu_projects': 'Проекты',
      'empty_interesting_tasks': 'Пока нет заданий',
      'empty_projects_tasks': 'Пока нет проектных заданий',
      'periodic_all': 'Все',
      'periodic_alkali': 'Щелочной металл',
      'periodic_alkaline': 'Щелочноземельный металл',
      'periodic_transition': 'Переходный металл',
      'periodic_metal': 'Металл',
      'periodic_metalloid': 'Металлоид',
      'periodic_nonmetal': 'Неметалл',
      'periodic_halogen': 'Галоген',
      'periodic_noble': 'Инертный газ',
      'periodic_atom_num': 'Атомный номер',
      'periodic_symbol': 'Символ',
      'periodic_mass': 'Масса',
      'periodic_category': 'Категория',
      'periodic_lanthanide': 'Лантаноид',
      'periodic_actinide': 'Актиноид',
      'properties': 'Свойства',
      'no_results': 'Результатов не найдено',
      'elements_offline_banner': 'Нет сети — показана последняя сохранённая копия элементов на устройстве.',
      'menu_theory': 'Теория',
      'menu_lab': 'Лаборатория',
      'splash_loading': 'Загрузка...',
      'splash_tagline': 'Химия и география — обучение в одном приложении',
      'auth_hero_welcome': 'Рады вас видеть',
      'onboarding_badge': 'Первый шаг',
      'onboarding_lang_title': 'Выберите язык',
      'onboarding_lang_subtitle': 'Язык можно сменить позже в настройках',
      'onboarding_lang_continue': 'Продолжить',
      'auth_login_title': 'Вход',
      'auth_login_subtitle': 'Войдите в аккаунт',
      'auth_register_title': 'Регистрация',
      'auth_register_subtitle': 'Создать новый аккаунт',
      'auth_login_field': 'Логин (username, email или телефон)',
      'auth_username': 'Имя пользователя (для входа)',
      'auth_username_hint': 'Например: ellikkala_m2_9a_001',
      'auth_error_username': 'Введите username',
      'auth_error_username_len': 'Username не короче 3 символов',
      'auth_error_username_chars': 'Только латиница, цифры, . _ -',
      'auth_phone': 'Номер телефона',
      'auth_phone_hint': '+998 90 123 45 67',
      'auth_error_phone': 'Введите номер телефона',
      'auth_region': 'Область / Республика',
      'auth_district': 'Район / Город',
      'auth_district_hint': 'Выберите район',
      'auth_error_district': 'Выберите район',
      'auth_school_number': 'Номер школы',
      'auth_school_number_hint': 'Выберите номер школы (1–58)',
      'auth_error_school': 'Выберите номер школы',
      'auth_password': 'Пароль',
      'auth_password_confirm': 'Подтвердите пароль',
      'auth_name': 'Ф.И.О.',
      'auth_login_action': 'Войти',
      'auth_register_action': 'Зарегистрироваться',
      'auth_no_account_register': 'Нет аккаунта? Регистрация',
      'auth_has_account_login': 'Уже есть аккаунт? Войти',
      'auth_success_login': 'Вход выполнен',
      'auth_success_register': 'Регистрация прошла успешно',
      'auth_error_login': 'Введите телефон или имя пользователя',
      'auth_error_password': 'Введите пароль',
      'auth_error_password_len': 'Пароль не менее 6 символов',
      'auth_error_password_mismatch': 'Пароли не совпадают',
      'auth_error_name': 'Введите имя',
      'auth_error_generic': 'Произошла ошибка. Попробуйте снова',
      'my_submissions_title': 'Мои ответы',
      'my_submissions_empty': 'Вы ещё не отправляли ответы',
      'task_submit_appbar': 'Задание',
      'task_submit_success_title': 'Поздравляем!',
      'task_submit_success_body': 'Задание успешно отправлено. Учитель проверит ответы и выставит результат.',
      'task_submit_id_label': 'Номер ID',
      'task_submit_status_label': 'Статус',
      'task_submit_result_label': 'Результат',
      'task_submit_status_pending': 'На проверке',
      'task_submit_status_checked': 'Проверено',
      'task_submit_result_hidden': 'Будет виден после разрешения учителя',
      'task_submit_result_points': '{{score}} балл.',
      'task_submit_home': 'На главную',
      'virtual_lab_title': 'Виртуальная лаборатория',
      'virtual_lab_start_btn': 'Открыть виртуальную лабораторию',
      'virtual_lab_reaction_zone': 'Зона опыта',
      'virtual_lab_hint': 'Выберите 2 материала (прибор + элемент или 2 вещества)',
      'virtual_lab_pick_second': 'Теперь выберите второй материал...',
      'virtual_lab_clear': 'Сбросить',
      'virtual_lab_items_title': 'Материалы лаборатории',
      'virtual_lab_required': 'Обязат.',
      'virtual_lab_no_reaction': 'Реакция между этими веществами не наблюдается.',
      'virtual_lab_load_error': 'Ошибка при загрузке материалов',
      'virtual_lab_empty_category': 'В этой категории нет материалов',
      'virtual_lab_tab_all': 'Все',
      'virtual_lab_tab_equipment': 'Оборуд.',
      'virtual_lab_tab_vessel': 'Посуда',
      'virtual_lab_tab_element': 'Элемент',
      'virtual_lab_tab_reagent': 'Реагент',
      'virtual_lab_checklist_title': 'Необходимые материалы',
      'virtual_lab_procedure_title': 'Ход работы',
      'virtual_lab_template_footer': 'Чеклист и порядок по методичке и шаблону виртуальной лаборатории.',
      'virtual_lab_optional': 'необяз.',
      'retry': 'Повторить',
    },
    'en': {
      'app_title': 'Chemistry V2',
      'tab_kimyo': 'Chemistry',
      'tab_geografiya': 'Geography',
      'tab_hujjatlar': 'Documents',
      'tab_sozlamalar': 'Settings',
      'tab_profil': 'Profile',
      'menu_elements': 'Chemical Elements',
      'menu_elements_sub': 'Element Information',
      'menu_alkali_metals': 'Metal Groups',
      'alkali_page_title': 'Metal Groups',
      'alkali_search_hint': 'Element name or symbol...',
      'menu_periodic_table': 'Periodic Table',
      'menu_periodic_table_sub': 'View Table',
      'menu_formulas': 'Chemical Formulas',
      'menu_formulas_sub': 'Chemical Reactions',
      'menu_lessons': 'Lessons',
      'menu_lessons_sub': 'Start Lessons',
      'menu_quiz': 'Take Quiz',
      'menu_lab_works': 'Laboratory Works',
      'tests_title': 'Tests',
      'tests_tab_chemistry': 'Chemistry',
      'tests_tab_geography': 'Geography',
      'tests_no_items': 'No tests yet',
      'geo_map': 'World Political Map',
      'geo_map_sub': 'Interactive Map',
      'geo_landscapes': 'Natural Landscapes',
      'geo_geology': 'Geological Structure',
      'geo_climate': 'Climate and Weather',
      'geo_climate_sub1': 'Regional climate',
      'geo_climate_sub2': 'Weather information',
      'geo_climate_regional_title': 'Climate and regional weather distribution',
      'geo_topic_continental': 'Continental climate',
      'geo_topic_continental_desc':
          'Uzbekistan lies in a continental climate zone.\n\n'
          'Main features:\n'
          '• Hot, dry summer\n'
          '• Cold winter\n'
          '• Low precipitation\n'
          '• Large day–night temperature difference\n'
          '• Sharp contrast between seasons\n\n'
          'Causes:\n'
          '• Distance from the sea\n'
          '• Location in Central Asia\n'
          '• Surrounded by mountains\n'
          '• Geographic setting\n\n'
          'Temperature range:\n'
          '• Annual swing about 40–50 °C\n'
          '• Daily swing about 15–20 °C\n'
          '• Hottest about +45 °C (Termez)\n'
          '• Coldest about −30 °C (mountains)\n\n'
          'Precipitation:\n'
          '• Average 100–500 mm/year\n'
          '• Highest in mountains (500–700 mm)\n'
          '• Lowest in deserts (100–150 mm)\n'
          '• Mostly in spring and autumn',
      'geo_topic_climate_zones': 'Climate zones',
      'geo_topic_climate_zones_desc':
          'Uzbekistan has four main climate zones.\n\n'
          '1. Desert climate\n\n'
          'Areas:\n'
          '• Kyzylkum Desert\n'
          '• Karakalpakstan\n'
          '• Ustyurt Plateau\n'
          '• Desert areas of Navoiy region\n\n'
          'Features:\n'
          '• Very hot summers (+40 to +45 °C)\n'
          '• Cold winters (0 to −15 °C)\n'
          '• Very low rainfall (100–150 mm)\n'
          '• Strong winds\n'
          '• Large temperature swings\n\n'
          '2. Semi-desert / steppe climate\n\n'
          'Areas:\n'
          '• Mirzachul\n'
          '• Jizzakh region\n'
          '• Around Samarkand\n'
          '• Parts of Bukhara region\n\n'
          'Features:\n'
          '• Hot summers (+35 to +40 °C)\n'
          '• Milder winters (0 to −10 °C)\n'
          '• Moderate rain (200–300 mm)\n'
          '• Steppe vegetation\n\n'
          '3. Subtropical climate\n\n'
          'Areas:\n'
          '• Surkhandarya valley\n'
          '• Southern Kashkadarya\n'
          '• Sherabad valley\n\n'
          'Features:\n'
          '• Very hot summers (+40 to +45 °C)\n'
          '• Mild winters (+5 to 0 °C)\n'
          '• Rainfall 200–400 mm\n'
          '• Subtropical plants\n'
          '• Cotton and fruit crops\n\n'
          '4. Mountain climate\n\n'
          'Areas:\n'
          '• Tian Shan\n'
          '• Pamir–Alay\n'
          '• Fann Mountains\n'
          '• Hissar Range\n\n'
          'Features:\n'
          '• Cool summers (+15 to +25 °C)\n'
          '• Cold winters (−10 to −30 °C)\n'
          '• High precipitation (500–800 mm)\n'
          '• Snow-capped peaks\n'
          '• Glaciers',
      'geo_topic_seasons': 'Seasonal characteristics',
      'geo_topic_seasons_desc':
          'Each season has its own traits.\n\n'
          'SPRING (March–May)\n\n'
          'Temperature:\n'
          '• March: +5 to +15 °C\n'
          '• April: +15 to +25 °C\n'
          '• May: +20 to +30 °C\n\n'
          'Features:\n'
          '• Rapid warming\n'
          '• Most rainfall\n'
          '• Plants bloom\n'
          '• Fruit trees flower\n'
          '• Sowing season\n'
          '• Occasional mudflow risk\n\n'
          'SUMMER (June–August)\n\n'
          'Temperature:\n'
          '• June: +30 to +38 °C\n'
          '• July: +35 to +42 °C\n'
          '• August: +30 to +40 °C\n\n'
          'Features:\n'
          '• Very hot\n'
          '• Dry air\n'
          '• Little rain\n'
          '• Long days\n'
          '• Crops ripen\n'
          '• Heat waves\n\n'
          'AUTUMN (September–November)\n\n'
          'Temperature:\n'
          '• September: +25 to +30 °C\n'
          '• October: +15 to +20 °C\n'
          '• November: +5 to +10 °C\n\n'
          'Features:\n'
          '• Gradual cooling\n'
          '• Dry air\n'
          '• Harvest\n'
          '• Cotton picking\n'
          '• Garden work\n'
          '• “Golden autumn”\n\n'
          'WINTER (December–February)\n\n'
          'Temperature:\n'
          '• December: 0 to −10 °C\n'
          '• January: −5 to −15 °C\n'
          '• February: 0 to −10 °C\n\n'
          'Features:\n'
          '• Cold\n'
          '• Snow at times\n'
          '• Cold spells\n'
          '• Short days\n'
          '• Holiday rest\n'
          '• Winter sports (mountains)',
      'geo_topic_regional_diff': 'Regional differences',
      'geo_topic_regional_diff_desc':
          'How climate differs across regions.\n\n'
          'NORTH (Tashkent, Syrdarya)\n'
          '• Average temperature: +13 to +15 °C\n'
          '• Precipitation: 300–400 mm\n'
          '• Colder winters\n'
          '• Hotter summers\n\n'
          'EAST (Fergana, Andijan, Namangan)\n'
          '• Average: +13 to +14 °C\n'
          '• Precipitation: 200–300 mm\n'
          '• Enclosed valley\n'
          '• Milder winters\n\n'
          'CENTER (Samarkand, Jizzakh, Navoi)\n'
          '• Average: +14 to +15 °C\n'
          '• Precipitation: 300–400 mm\n'
          '• Steppe and mountains mixed\n'
          '• Moderate\n\n'
          'SOUTH (Surkhandarya, Kashkadarya)\n'
          '• Average: +15 to +17 °C\n'
          '• Precipitation: 200–400 mm\n'
          '• Hottest area\n'
          '• Subtropical plants\n\n'
          'WEST (Bukhara, Khorezm, Karakalpakstan)\n'
          '• Average: +12 to +14 °C\n'
          '• Precipitation: 100–200 mm\n'
          '• Desert climate\n'
          '• Cold winters, hot summers\n\n'
          'MOUNTAINS (Chimgan, Beldersay)\n'
          '• Average: +5 to +10 °C\n'
          '• Precipitation: 500–800 mm\n'
          '• Cool summers\n'
          '• Snowy winters\n'
          '• Glaciers',
      'geo_topic_climate_change': 'Climate change',
      'geo_topic_climate_change_desc':
          'Global climate change affects Uzbekistan.\n\n'
          '1. Observed changes:\n'
          '• Rising temperatures\n'
          '  • About +1.5 °C over the last 50 years\n'
          '  • Further warming expected\n'
          '• Glacier melt\n'
          '  • Shrinking by about 0.5–1% per year\n'
          '  • Less water availability\n'
          '• Changing precipitation\n'
          '  • Unpredictable rainfall\n'
          '  • Increases in some places\n'
          '  • Decreases in others\n'
          '• Extreme events\n'
          '  • More heat waves\n'
          '  • Frequent droughts\n'
          '  • Strong winds\n\n'
          '2. Consequences:\n'
          '• Harder conditions for farming\n'
          '• Water scarcity\n'
          '• Worsening desertification\n'
          '• Environmental damage\n'
          '• Health impacts\n\n'
          '3. Responses:\n'
          '• Save water\n'
          '• New technology\n'
          '• Reforestation\n'
          '• Clean energy\n'
          '• International cooperation\n\n'
          '4. Outlook:\n'
          '• +2–3 °C more warming possible by 2050\n'
          '• Water resources may drop 10–15%\n'
          '• Desertification may intensify\n'
          '• Further action will be needed',
      'geo_topic_special_climate': 'Special climate zones',
      'geo_topic_special_climate_desc':
          'Some places develop their own microclimate.\n\n'
          'URBAN CLIMATE\n'
          '• Tashkent\n'
          '  • Urban heat island\n'
          '  • About 2–3 °C warmer\n'
          '  • Less rainfall\n\n'
          'VALLEY CLIMATE\n'
          '• Fergana Valley\n'
          '  • Enclosed basin\n'
          '  • Hot summers\n'
          '  • Cooler winters\n'
          '  • Distinct local winds\n\n'
          'DESERT CLIMATE\n'
          '• Kyzylkum\n'
          '  • Very hot\n'
          '  • Very dry\n'
          '  • Large day–night temperature swings\n'
          '  • Strong winds\n\n'
          'MOUNTAIN CLIMATE\n'
          '• Chimgan, Beldersay\n'
          '  • Cool summers\n'
          '  • Snowy winters\n'
          '  • High precipitation\n'
          '  • Clean air\n\n'
          'ARAL SEA REGION\n'
          '• Karakalpakstan\n'
          '  • Effects of the shrinking sea\n'
          '  • Salt storms\n'
          '  • Serious ecological stress\n'
          '  • Harsh climate\n\n'
          'MOUNTAIN PASSES\n'
          '• Kamchik Pass\n'
          '  • Changeable weather\n'
          '  • Frequent fog\n'
          '  • Strong winds\n'
          '  • Harder winters\n\n'
          'EACH ZONE IS UNIQUE:\n'
          '• Flora and fauna\n'
          '• Farming\n'
          '• Lifestyle\n'
          '• Tourism potential',
      'climate_stat_title': 'Climate statistics',
      'climate_stat_avg': 'Average temperature: +14°C',
      'climate_stat_hot': 'Hottest: +45°C (Termiz)',
      'climate_stat_cold': 'Coldest: -30°C (mountains)',
      'climate_stat_rain': 'Precipitation (avg.): 100–500 mm/year',
      'climate_stat_sunny': 'Sunny days: 260–300 per year',
      'weather_page_title': 'Weather',
      'weather_topic_elements': 'Weather elements',
      'weather_topic_elements_desc':
          'Main elements that describe the weather:\n\n'
          '1. Temperature\n'
          '• Measured with a thermometer\n'
          '• °C (Celsius) or °F (Fahrenheit)\n'
          '• Day vs night difference\n'
          '• Varies by season\n\n'
          '2. Pressure\n'
          '• Measured with a barometer\n'
          '• Millimeters of mercury (mm Hg)\n'
          '• Or hectopascal (hPa)\n'
          '• Typical: about 760 mm Hg\n\n'
          '3. Wind\n'
          '• Measured with an anemometer\n'
          '• Speed: m/s or km/h\n'
          '• Direction: eight compass points\n'
          '• Classified by strength\n\n'
          '4. Humidity\n'
          '• Measured with a hygrometer\n'
          '• As a percentage (%)\n'
          '• Relative and absolute humidity\n'
          '• Dry vs humid air\n\n'
          '5. Precipitation\n'
          '• Rain gauge\n'
          '• In millimeters (mm)\n'
          '• Different forms (rain, snow, hail)\n\n'
          '6. Cloud cover\n'
          '• Estimated visually\n'
          '• 0–10 scale (points)\n'
          '• Different cloud types\n'
          '• Effects on the weather',
      'weather_topic_types': 'Weather types',
      'weather_topic_types_desc':
          'Uzbekistan sees many different weather conditions:\n\n'
          'CLEAR (FAIR) WEATHER\n'
          '• Cloudless sky\n'
          '• Hot summer days\n'
          '• Cold winter days\n'
          '• Good visibility\n\n'
          'CLOUDY WEATHER\n'
          '• Sky covered with clouds\n'
          '• Mild warmth\n'
          '• Chance of rain\n'
          '• Sun hidden\n\n'
          'RAINY WEATHER\n'
          '• Precipitation\n'
          '• Cloudy\n'
          '• Cooler\n'
          '• Humid air\n'
          '• Common in spring and autumn\n\n'
          'SNOWY WEATHER\n'
          '• In winter\n'
          '• Cold\n'
          '• White snow cover\n'
          '• Mostly in the mountains\n\n'
          'WINDY WEATHER\n'
          '• Strong wind\n'
          '• Dust blows up\n'
          '• Spring and autumn\n'
          '• Harder for transport\n\n'
          'HAIL WEATHER\n'
          '• Summer thunderstorms\n'
          '• Hailstones fall\n'
          '• Damage to crops\n'
          '• Short-lived\n\n'
          'FOGGY WEATHER\n'
          '• Poor visibility\n'
          '• Especially mornings\n'
          '• Autumn and spring\n'
          '• High humidity',
      'weather_topic_forecast': 'Weather forecasting',
      'weather_topic_forecast_desc':
          'Weather forecasting with modern tools.\n\n'
          'OBSERVATION METHODS:\n\n'
          '1. Weather stations\n'
          '• 100+ stations across Uzbekistan\n'
          '• Hourly readings\n'
          '• Temperature, pressure, wind\n'
          '• Precipitation\n\n'
          '2. Satellites\n'
          '• Observations from space\n'
          '• Cloud monitoring\n'
          '• Temperature maps\n'
          '• 24/7 monitoring\n\n'
          '3. Radar systems\n'
          '• Precipitation zones\n'
          '• Storm forecasting\n'
          '• Near-real-time data\n\n'
          '4. Computer models\n'
          '• Mathematical computation\n'
          '• Algorithms\n'
          '• Global input data\n'
          '• Detailed forecasts\n\n'
          'FORECAST TYPES:\n\n'
          'Short-term (1–3 days)\n'
          '• High accuracy: about 85–90%\n'
          '• Rapid changes\n'
          '• For day-to-day plans\n\n'
          'Medium-term (3–10 days)\n'
          '• Moderate accuracy: 70–80%\n'
          '• General trend\n'
          '• Weekly planning\n\n'
          'Long-term (months)\n'
          '• Lower accuracy: 60–70%\n'
          '• Broad outlook\n'
          '• Seasonal planning\n\n'
          'HYDROMET SERVICE:\n'
          '• Uzbekistan Hydrometeorological Service\n'
          '• Publishes forecasts\n'
          '• Issues warnings and alerts\n'
          '• Scientific research',
      'weather_topic_dangerous': 'Dangerous phenomena',
      'weather_topic_dangerous_desc':
          'Dangerous natural phenomena and how to stay safe.\n\n'
          '1. HEAT WAVE\n'
          'Traits:\n'
          '• Above +40 °C\n'
          '• Common in summer\n'
          '• Often lasts 5–10 days\n'
          'Risks:\n'
          '• Heatstroke\n'
          '• Dehydration\n'
          '• Heart and blood vessel strain\n'
          '• Power shortages\n'
          'Protection:\n'
          '• Drink plenty of water\n'
          '• Stay in the shade\n'
          '• Light clothing\n'
          '• Sun protection\n\n'
          '2. COLD WAVE\n'
          'Traits:\n'
          '• Below −20 °C\n'
          '• In winter\n'
          '• Often arrives from the north\n'
          'Risks:\n'
          '• Frostbite\n'
          '• Icy roads\n'
          '• Burst pipes\n'
          '• Higher energy use\n'
          'Protection:\n'
          '• Dress warmly\n'
          '• Stay indoors when possible\n'
          '• Keep heating on\n'
          '• Shelter livestock\n\n'
          '3. STORM AND HAIL\n'
          'Traits:\n'
          '• Spring and summer\n'
          '• Strong wind\n'
          '• Hail\n'
          'Risks:\n'
          '• Crop damage\n'
          '• Building damage\n'
          '• Power outages\n'
          '• Falling trees\n'
          'Protection:\n'
          '• Go inside a sturdy building\n'
          '• Pull over if driving\n'
          '• Stay away from trees\n'
          '• Turn off sensitive electronics\n\n'
          '4. FOG\n'
          'Traits:\n'
          '• Visibility under 50 m\n'
          '• Often in the morning\n'
          '• Autumn and spring\n'
          'Risks:\n'
          '• Traffic crashes\n'
          '• Hard to see the road\n'
          '• Difficult flying conditions\n'
          'Protection:\n'
          '• Drive slowly\n'
          '• Use lights\n'
          '• Stay alert\n\n'
          '5. DUST STORM\n'
          'Traits:\n'
          '• Desert regions\n'
          '• Strong wind\n'
          '• Spring and summer\n'
          'Risks:\n'
          '• Hard to breathe\n'
          '• Eye irritation\n'
          '• Poor visibility\n'
          '• Allergy flare-ups\n'
          'Protection:\n'
          '• Stay home\n'
          '• Wear a mask or respirator\n'
          '• Protect your eyes\n'
          '• Close windows',
      'weather_topic_local': 'Local weather traits',
      'weather_topic_local_desc':
          'Each region has its own distinctive weather.\n\n'
          'TASHKENT\n'
          '• Average temperature: +14 °C\n'
          '• Summer: +35 to +40 °C\n'
          '• Winter: −5 to −10 °C\n'
          '• Precipitation: 400–450 mm\n'
          '• Urban heat island\n\n'
          'FERGANA VALLEY\n'
          '• Enclosed basin\n'
          '• Hot summers\n'
          '• Cooler winters\n'
          '• Distinct microclimate\n'
          '• Little wind\n\n'
          'SAMARKAND\n'
          '• Moderate climate\n'
          '• Summer: +30 to +38 °C\n'
          '• Winter: 0 to −8 °C\n'
          '• Precipitation: 350–400 mm\n'
          '• Drier\n\n'
          'TERMIZ\n'
          '• Hottest area\n'
          '• Summer: +40 to +45 °C\n'
          '• Winter: +5 to 0 °C\n'
          '• Precipitation: 150–200 mm\n'
          '• Subtropical\n\n'
          'CHIMGAN (mountains)\n'
          '• Cool\n'
          '• Summer: +20 to +25 °C\n'
          '• Winter: −10 to −20 °C\n'
          '• Heavy snowfall\n'
          '• Clean air\n\n'
          'KARAKALPAKSTAN\n'
          '• Desert climate\n'
          '• Hot summers\n'
          '• Cold winters\n'
          '• Very little rain\n'
          '• Aral Sea influence',
      'weather_topic_activity': 'Weather and activity',
      'weather_topic_activity_desc':
          'Weather affects many kinds of activity.\n\n'
          'AGRICULTURE\n'
          '• Sowing time\n'
          '• Irrigation schedule\n'
          '• Harvest\n'
          '• Rain and temperature matter\n\n'
          'TRANSPORT\n'
          '• Road conditions\n'
          '• Flight conditions\n'
          '• Sea transport\n'
          '• Safety measures\n\n'
          'CONSTRUCTION\n'
          '• Pouring concrete\n'
          '• Laying asphalt\n'
          '• Painting work\n'
          '• Depends on the weather\n\n'
          'TOURISM\n'
          '• Holiday timing\n'
          '• Mountain tourism\n'
          '• Excursions\n'
          '• Varies by season\n\n'
          'SPORT\n'
          '• Outdoor sports\n'
          '• Winter sports\n'
          '• Summer sports\n'
          '• Weather matters\n\n'
          'HEALTH\n'
          '• Pressure changes\n'
          '• Allergy\n'
          '• Heat and cold effects\n'
          '• Prevention\n\n'
          'ENERGY\n'
          '• Heating season\n'
          '• Cooling season\n'
          '• Energy use\n'
          '• Tariff changes\n\n'
          'DAILY ROUTINE\n'
          '• Choosing clothes\n'
          '• Planning\n'
          '• Travel\n'
          '• Work schedule',
      'weather_tips_title': 'Useful tips',
      'weather_tip_1': 'Use weather mobile apps',
      'weather_tip_2': 'Watch TV forecasts',
      'weather_tip_3': 'Check the temperature',
      'weather_tip_4': 'Know the chance of rain',
      'weather_tip_5': 'Dress for the conditions',
      'weather_tip_6': 'Heed official warnings',
      'geo_geology_sub1': 'Rocks (mountain rocks)',
      'geo_geology_sub2': 'Mineral resources',
      'geo_rocks_title': 'Rocks and ranges',
      'geo_mtn_tyan': 'Tien Shan ranges',
      'geo_mtn_tyan_m': '4,301 m',
      'geo_mtn_tyan_desc':
          'The Tien Shan is called the “Mountains of Heaven”.\n\n'
          'Location:\n'
          '• North-east of Uzbekistan\n'
          '• Tashkent, Andijan, Namangan regions\n'
          '• Border with Kyrgyzstan and Kazakhstan\n\n'
          'Main ranges:\n'
          '• Chimgan mountains (3,309 m)\n'
          '• Pskem range (4,299 m)\n'
          '• Korzhantau (2,200 m)\n'
          '• Ugam–Chatkal National Park\n\n'
          'Highest peaks:\n'
          '• Adelunga Peak — 4,301 m (highest)\n'
          '• Beshtor — 4,299 m\n'
          '• Pskem Peak — 4,200 m\n'
          '• Chimgan Peak — 3,309 m\n\n'
          'Features:\n'
          '• Snow-capped peaks\n'
          '• Glaciers\n'
          '• Mountaineering centre\n'
          '• Tourism\n\n'
          'Rivers:\n'
          '• Source of the Chirchik\n'
          '• Pskem River\n'
          '• Aksu River\n'
          '• Many tributaries\n\n'
          'Flora and fauna:\n'
          '• Juniper forests\n'
          '• Wildlife (bear, rare birds)\n'
          '• Mountain goats\n'
          '• Predators\n\n'
          'Resorts:\n'
          '• Chimgan (winter resort)\n'
          '• Beldersay\n'
          '• Pskem valley\n'
          '• Mountaineering camps\n\n'
          'Importance:\n'
          '• Water sources\n'
          '• Tourism\n'
          '• Ecological system\n'
          '• Climate influence',
      'geo_mtn_pamir': 'Pamir–Alay ranges',
      'geo_mtn_pamir_m': '4,600 m',
      'geo_mtn_pamir_desc':
          'The Pamir–Alay is a mountain system in eastern Uzbekistan.\n\n'
          'Main ranges:\n\n'
          'Alay Range:\n'
          '• South of the Fergana Valley\n'
          '• Elevation: 4,000–5,000 m\n'
          '• Border with Kyrgyzstan\n\n'
          'Turkestan Range:\n'
          '• Kashkadarya region\n'
          '• Elevation: 4,000–5,000 m\n'
          '• Border with Tajikistan\n\n'
          'Zeravshan Range:\n'
          '• Samarkand region\n'
          '• Up to 5,489 m (Fann Mountains)\n'
          '• Headwaters of the Zeravshan River\n\n'
          'Hissar Range:\n'
          '• Surkhandarya region\n'
          '• Elevation: 4,000–4,500 m\n'
          '• Border with Tajikistan\n\n'
          'Fann Mountains:\n'
          '• Chimtarga Peak — 5,489 m\n'
          '• Popular with tourists and climbers\n'
          '• More than 70 lakes\n'
          '• Alauddin Lakes\n\n'
          'Glaciers:\n'
          '• Zeravshan glaciers\n'
          '• Fann glaciers\n'
          '• Hissar glaciers\n'
          '• Major water source\n\n'
          'River sources:\n'
          '• Zeravshan River\n'
          '• Kashkadarya\n'
          '• Surkhandarya\n'
          '• Many tributaries\n\n'
          'Population and villages:\n'
          '• Alpine pastures\n'
          '• Mountain villages\n'
          '• Livestock farming\n'
          '• Fruit and nuts\n\n'
          'Tourism:\n'
          '• Mountaineering\n'
          '• Hiking\n'
          '• Nature tourism\n'
          '• Cultural tourism\n\n'
          'Mineral resources:\n'
          '• Gold\n'
          '• Copper\n'
          '• Marble\n'
          '• Other metals',
      'geo_mtn_nurota': 'Nurata ranges',
      'geo_mtn_nurota_m': '2,169 m',
      'geo_mtn_nurota_desc':
          'Mountains “filled with light”.\n\n'
          'Location:\n'
          '• Navoiy, Samarkand, and Jizzakh regions\n'
          '• Beside the Small Kyzylkum Desert\n'
          '• Length about 170 km\n\n'
          'Elevation:\n'
          '• Highest: Haydarkan Peak — 2,169 m\n'
          '• Average: 1,000–1,500 m\n'
          '• Relatively low mountains\n\n'
          'Features:\n'
          '• Petroglyphs\n'
          '• Ancient shrines\n'
          '• Sacred site\n'
          '• Various historical monuments\n\n'
          'Notable places:\n'
          '• Haydarkan Peak\n'
          '• Hazrat Dawood shrine/cave (pilgrimage)\n'
          '• Sacred fish in Nurata town\n'
          '• About 40,000 petroglyph images\n\n'
          'Water resources:\n'
          '• Natural springs\n'
          '• Irrigation water\n'
          '• Fish farms\n'
          '• Drinking water supply\n\n'
          'Flora and fauna:\n'
          '• Wild walnut and pistachio groves\n'
          '• Mountain goats and birds of prey\n\n'
          'Livestock:\n'
          '• Sheep and goat herding\n'
          '• Pasture lands\n'
          '• Main occupation of local people\n\n'
          'Historical significance:\n'
          '• Ancient caravan routes\n'
          '• Historic pilgrimage sites\n'
          '• Archaeological finds\n'
          '• Cultural heritage\n\n'
          'Tourism:\n'
          '• Historical tourism\n'
          '• Pilgrimage tourism\n'
          '• Nature tourism\n'
          '• Archaeological tourism\n\n'
          'Importance:\n'
          '• Ecological system\n'
          '• Historical heritage\n'
          '• Tourism potential\n'
          '• Livelihood for local communities',
      'geo_mtn_kopet': 'Kopet Dag',
      'geo_mtn_kopet_m': '1,500 m',
      'geo_mtn_kopet_desc':
          'The Kopet Dag — mountains in western Uzbekistan.\n\n'
          'Location:\n'
          '• South of Bukhara region\n'
          '• Border with Turkmenistan\n'
          '• Total range length ~650 km\n'
          '• Within Uzbekistan ~100 km\n\n'
          'Elevation:\n'
          '• In Uzbekistan: 800–1,500 m\n'
          '• Relatively low mountains\n'
          '• Sharp rise from the plain\n\n'
          'Features:\n'
          '• Arid climate\n'
          '• Sparse vegetation\n'
          '• Rocks and cliffs\n'
          '• Erosion\n\n'
          'Flora:\n'
          '• Wild apple trees\n'
          '• Shrubs\n'
          '• Saxaul\n'
          '• Wild grasses\n\n'
          'Fauna:\n'
          '• Mountain goats\n'
          '• Foxes\n'
          '• Snakes\n'
          '• Birds\n\n'
          'Climate:\n'
          '• Hot and dry\n'
          '• Summer up to +40 °C\n'
          '• Winter about 0 to +10 °C\n'
          '• Low rainfall\n\n'
          'Population:\n'
          '• Sparse\n'
          '• Livestock farming\n'
          '• Mainly sheep and goats\n\n'
          'Mineral resources:\n'
          '• Construction materials\n'
          '• Limestone\n'
          '• Gypsum\n'
          '• Gravel\n\n'
          'Importance:\n'
          '• Natural border\n'
          '• Ecological system\n'
          '• Livestock pastures\n'
          '• Mineral resources',
      'geo_mtn_qoratov': 'Karatou ranges',
      'geo_mtn_qoratov_m': '922 m',
      'geo_mtn_qoratov_desc':
          'Karatau — “Black mountains”.\n\n'
          'Location:\n'
          '• Navoiy region\n'
          '• Amid the Kyzylkum Desert\n'
          '• Length ~50 km\n'
          '• Width ~20 km\n\n'
          'Elevation:\n'
          '• Highest point 922 m\n'
          '• Low mountains\n'
          '• Desert setting\n\n'
          'Features:\n'
          '• Dark rock (origin of the name)\n'
          '• Rich in minerals\n'
          '• Ancient geology\n\n'
          'Minerals:\n'
          '• Gold (Muruntau mine)\n'
          '• Copper\n'
          '• Molybdenum\n'
          '• Tungsten\n'
          '• Uranium\n\n'
          'Muruntau mine:\n'
          '• Central Asia’s largest gold mine\n'
          '• Open-pit extraction\n'
          '• Zarafshan developed with the mine\n'
          '• Thousands of jobs\n\n'
          'Flora and fauna:\n'
          '• Desert plants, saxaul\n'
          '• Desert wildlife, lizards\n\n'
          'Climate:\n'
          '• Continental desert climate\n'
          '• Very hot summers (+45 °C)\n'
          '• Cold winters (down to −15 °C)\n'
          '• Very low rainfall\n\n'
          'Population:\n'
          '• Mine workers\n'
          '• Zarafshan city\n'
          '• Uchkuduk city\n'
          '• Navbahor settlement\n\n'
          'Importance:\n'
          '• Economic role (gold)\n'
          '• Employment\n'
          '• Export earnings\n'
          '• State budget',
      'geo_mtn_qurama': 'Kurama (Kuramin) ranges',
      'geo_mtn_qurama_m': '3,769 m',
      'geo_mtn_qurama_desc':
          'The Kurama range — part of the Tien Shan system.\n\n'
          'Location:\n'
          '• Tashkent and Namangan regions\n'
          '• North-west of the Fergana Valley\n'
          '• Length about 170 km\n\n'
          'Elevation:\n'
          '• Boysuntau Peak — 3,769 m\n'
          '• Average 2,000–3,000 m\n'
          '• Rocky mountains\n\n'
          'Features:\n'
          '• Divides the Fergana Valley from Mirzachul\n'
          '• Natural barrier\n'
          '• Difficult transport routes\n\n'
          'Passes:\n'
          '• Kamchik Pass (Tashkent–Andijan)\n'
          '• At 2,267 m\n'
          '• Open year-round\n'
          '• Road through the tunnel\n'
          '• Koytepa Pass\n'
          '• Other minor passes\n\n'
          'Rivers:\n'
          '• Chirchik River\n'
          '• Angren River\n'
          '• Karasu River\n\n'
          'Plants:\n'
          '• Juniper forests\n'
          '• Walnut trees\n'
          '• Alpine grasses\n'
          '• Ornamental plants\n\n'
          'Wildlife:\n'
          '• Mountain goats\n'
          '• Wild boar\n'
          '• Birds\n'
          '• Predators\n\n'
          'Tourism:\n'
          '• Mountain tourism\n'
          '• Winter sports\n'
          '• Nature tourism\n'
          '• Hiking\n\n'
          'Importance:\n'
          '• Transport (Kamchik tunnel)\n'
          '• Water sources\n'
          '• Tourism\n'
          '• Ecological system\n\n'
          'History:\n'
          '• Ancient caravan routes\n'
          '• Along the Silk Road\n'
          '• Historic passes',
      'geo_mount_info_title': 'Mountains in brief',
      'geo_mount_info_share': 'Mountain share of the country: ~20% (approx.)',
      'geo_mount_info_peak': 'Highest: Adelunga (4,301 m) — Tien Shan',
      'geo_mount_info_systems': 'Main systems: Tien Shan, Pamir–Alay',
      'geo_mount_info_glaciers': 'Glacier area: ~650 km²',
      'geo_mount_info_value': 'Value: water, tourism, mineral wealth',
      'geo_mins_title': 'Mineral resources',
      'geo_mins_head': 'Uzbekistan is rich in resources',
      'geo_mins_lead': 'Over 100 types of materials and 2,000+ deposits and fields.',
      'geo_min_gold': 'Gold',
      'geo_min_gold_sub': 'Precious metal',
      'geo_min_gold_desc':
          'Uzbekistan ranks 4th in the world in gold production.\n\n'
          'Main deposits:\n\n'
          'Muruntau (Navoiy region):\n'
          '• Central Asia’s largest mine\n'
          '• Open-pit extraction\n'
          '• About 60–70 tonnes per year\n\n'
          '• Kyzylkum mine (Navoiy region)\n'
          '• Amantaytau mine (Jizzakh region)\n'
          '• Charmitan mine (Navoiy region)\n'
          '• Marjonbuloq (Jizzakh region)\n\n'
          'Reserves:\n'
          '• Proven reserves: 3,000 tonnes\n'
          '• Annual extraction: 100 tonnes\n'
          '• Share of world production: 3.3%\n\n'
          'Uses:\n'
          '• Gold jewellery\n'
          '• Investment\n'
          '• Currency reserves\n'
          '• Electronics industry\n'
          '• Medicine\n\n'
          'Export:\n'
          '• Sold on world markets\n'
          '• Among top export products\n'
          '• Foreign-exchange revenue\n\n'
          'History:\n'
          '• Mined since antiquity\n'
          '• Silk Road era\n'
          '• Expansion in the Soviet period\n'
          '• Growth after independence\n\n'
          'Production:\n'
          '• Navoi Mining and Metallurgy Combinat (NMMC)\n'
          '• Modern technology\n'
          '• Compliance with environmental standards',
      'geo_min_copper': 'Copper',
      'geo_min_copper_sub': 'Non-ferrous metal',
      'geo_min_copper_desc':
          'Uzbekistan has major copper deposits.\n\n'
          'Main operations:\n\n'
          'Almalyk Mining and Metallurgical Complex (Tashkent region):\n'
          '• The country’s largest copper producer\n'
          '• Molybdenum is also mined\n'
          '• Operating since 1951\n\n'
          '• Qalmoqir mine\n'
          '• Khandiza mine\n'
          '• Kalmakir mine\n\n'
          'Production:\n'
          '• About 100,000 tonnes per year\n'
          '• Leading producer in Central Asia\n'
          '• Supplies world markets\n\n'
          'Uses:\n'
          '• Electrical wiring\n'
          '• Construction materials\n'
          '• Mechanical engineering\n'
          '• Transport\n'
          '• Electronics\n\n'
          'Associated metals:\n'
          '• Molybdenum\n'
          '• Sulphur\n'
          '• Zinc\n'
          '• Silver\n\n'
          'AMMC:\n'
          '• Established in 1951\n'
          '• 10,000+ workers\n'
          '• Export-oriented\n'
          '• Modern technology\n\n'
          'Environment:\n'
          '• Treatment facilities\n'
          '• Waste recycling\n'
          '• Environmental protection',
      'geo_min_gas': 'Natural gas',
      'geo_min_gas_sub': 'Energy resource',
      'geo_min_gas_desc':
          'Uzbekistan is the largest natural gas producer in Central Asia.\n\n'
          'Main fields:\n\n'
          'Gazli field (Bukhara region):\n'
          '• Largest field\n'
          '• Discovered in 1956\n'
          '• About 30% of Uzbekistan’s gas\n\n'
          '• Shurtan (Kashkadarya)\n'
          '• Karakul (Bukhara)\n'
          '• Ustyurt (Karakalpakstan)\n'
          '• Dengizkul field\n\n'
          'Reserves:\n'
          '• Proven: 1.8 trillion m³\n'
          '• Share of world reserves: 0.6%\n'
          '• Roughly 30–40 years at current rates\n\n'
          'Production:\n'
          '• Annual: 60–65 billion m³\n'
          '• Domestic consumption ~50 billion m³\n'
          '• Exports ~10–15 billion m³\n\n'
          'Uses:\n'
          '• Electricity generation\n'
          '• Industry\n'
          '• Household demand\n'
          '• Chemical industry\n'
          '• Transport (gas fuel)\n\n'
          'Export markets:\n'
          '• Russia\n'
          '• China\n'
          '• Kazakhstan\n\n'
          'Pipelines:\n'
          '• Central Asia–China line\n'
          '• Northern corridor\n'
          '• Domestic networks\n\n'
          'Outlook:\n'
          '• Developing new fields\n'
          '• Gas processing\n'
          '• Chemical products',
      'geo_min_oil': 'Petroleum',
      'geo_min_oil_sub': 'Energy resource',
      'geo_min_oil_desc':
          'Uzbekistan produces oil from several fields.\n\n'
          'Main fields:\n\n'
          'Mingbulak field (Namangan region):\n'
          '• Among the oldest (since 1992)\n'
          '• Output 1+ million tonnes/year\n\n'
          '• Kokdumalak (Kashkadarya)\n'
          '• Alamberdy (Kashkadarya)\n'
          '• Surgil (Surkhandarya)\n'
          '• Karakul (Bukhara)\n\n'
          'Reserves:\n'
          '• About 600 million tonnes\n'
          '• New fields coming on stream\n\n'
          'Production:\n'
          '• Roughly 3–4 million tonnes/year\n'
          '• Covers much domestic demand\n'
          '• Imports still partly needed\n\n'
          'Uses:\n'
          '• Road fuels (petrol, diesel)\n'
          '• Oil refining\n'
          '• Chemical industry\n'
          '• Heating fuel (fuel oil)\n\n'
          'Refining:\n'
          '• Fergana oil refinery\n'
          '• Bukhara oil refinery\n'
          '• Shahrisabz plants\n\n'
          'Products:\n'
          '• Petrol (AI-80, AI-91, AI-95)\n'
          '• Diesel\n'
          '• Aviation kerosene\n'
          '• Fuel oil\n'
          '• Lubricants\n\n'
          'Outlook:\n'
          '• Exploring for new fields\n'
          '• Refinery modernisation\n'
          '• Cleaner technologies',
      'geo_min_coal': 'Coal',
      'geo_min_coal_sub': 'Solid fuel',
      'geo_min_coal_desc':
          'Coal is mined in Uzbekistan.\n\n'
          'Main deposits:\n\n'
          'Angren field (Tashkent region):\n'
          '• Largest\n'
          '• Brown coal\n'
          '• Open-pit extraction\n\n'
          '• Shargun (Surkhandarya)\n'
          '• Boysun (Surkhandarya)\n\n'
          'Reserves:\n'
          '• About 1.8 billion tonnes\n'
          '• Mostly brown coal\n\n'
          'Production:\n'
          '• 3–4 million tonnes/year\n'
          '• Chiefly from Angren\n\n'
          'Uses:\n'
          '• Thermal power stations\n'
          '• Angren TPP\n'
          '• Industrial plants\n'
          '• District heating\n\n'
          'Angren Coal:\n'
          '• Operating since 1940\n'
          '• Underground and open-pit mines\n'
          '• Being modernised\n\n'
          'Environment:\n'
          '• Flue-gas cleaning\n'
          '• Land reclamation\n'
          '• Modern technology\n\n'
          'Outlook:\n'
          '• Moving toward greener energy\n'
          '• Environmental requirements\n'
          '• Plant reconstruction',
      'geo_min_uranium': 'Uranium',
      'geo_min_uranium_sub': 'Radioactive metal',
      'geo_min_uranium_desc':
          'Uzbekistan is one of the world’s uranium-rich countries.\n\n'
          'Main deposits:\n'
          '• Uchkuduk (Navoiy region)\n'
          '• Zarafshan (Navoiy)\n'
          '• Nurabad\n\n'
          'Reserves:\n'
          '• About 2% of world reserves\n'
          '• Exact figures are confidential\n\n'
          'Production:\n'
          '• 2,400–3,000 tonnes/year\n'
          '• About 7th in the world\n\n'
          'Uses:\n'
          '• Nuclear power plant fuel\n'
          '• Medicine\n'
          '• Scientific research\n'
          '• Military uses (in other countries)\n\n'
          'Navoi MMC:\n'
          '• Uranium mining and processing\n'
          '• Strict security measures\n'
          '• Under international oversight\n\n'
          'Exports:\n'
          '• Russia\n'
          '• China\n'
          '• South Korea\n'
          '• Several European countries\n\n'
          'Safety:\n'
          '• Restricted facilities\n'
          '• Radiation monitoring\n'
          '• Environmental standards\n'
          '• International requirements\n\n'
          'Importance:\n'
          '• Strategic resource\n'
          '• Energy sector\n'
          '• Export commodity',
      'geo_min_build': 'Construction materials',
      'geo_min_build_sub': 'Non-metallics',
      'geo_min_build_desc':
          'Many construction materials are mined in Uzbekistan.\n\n'
          'Limestone and gypsum:\n'
          '• Samarkand, Kashkadarya, Jizzakh regions\n'
          '• General construction use\n\n'
          'Granite and marble:\n'
          '• Jizzakh (marble), Samarkand, Tashkent regions\n'
          '• Decorative facing stone\n\n'
          'Limestone (calcium carbonate) for cement:\n'
          '• Samarkand, Surkhandarya\n'
          '• Cement plants feedstock\n\n'
          'Gypsum:\n'
          '• Widely across regions\n'
          '• Building materials\n\n'
          'Sand and gravel:\n'
          '• Amu Darya and Syr Darya valleys\n'
          '• For concrete\n\n'
          'Clay:\n'
          '• Many districts\n'
          '• Brick and ceramics\n\n'
          'Cement plants:\n'
          '• Quvasoy (Fergana)\n'
          '• Bekabad (Tashkent region)\n'
          '• Ohangaron (Tashkent region)\n'
          '• Sherabad (Surkhandarya)\n\n'
          'Production:\n'
          '• Cement: 8–10 million tonnes/year\n'
          '• Bricks: millions of units\n'
          '• Marble is exported\n\n'
          'Importance:\n'
          '• Supplies the construction sector\n'
          '• Meets domestic demand\n'
          '• Some output is exported',
      'geo_min_salt': 'Salt and other minerals',
      'geo_min_salt_sub': 'Chemical feedstock',
      'geo_min_salt_desc':
          'The country has many chemical raw-material sources.\n\n'
          'Salt:\n'
          '• Around the Aral Sea\n'
          '• Karakalpakstan\n'
          '• Natural salt lakes\n\n'
          'Phosphorites:\n'
          '• Kashkadarya region\n'
          '• Surkhandarya region\n'
          '• Fertiliser production\n\n'
          'Sulphur:\n'
          '• Surkhandarya region\n'
          '• Fergana region\n'
          '• Gas processing\n\n'
          'Kaolin:\n'
          '• Angren (Tashkent region)\n'
          '• Ceramics industry\n'
          '• Porcelain and pottery\n\n'
          'Lead and zinc:\n'
          '• Almalyk MMC\n'
          '• Almalyk ore fields\n'
          '• Together with copper\n\n'
          'Tungsten and molybdenum:\n'
          '• Almalyk MMC\n'
          '• Karatau ranges\n'
          '• For the steel industry\n\n'
          'Gemstones:\n'
          '• Turquoise\n'
          '• Lapis lazuli\n'
          '• Garnet\n'
          '• For jewellery\n\n'
          'Importance:\n'
          '• Chemical industry\n'
          '• Agriculture (fertilisers)\n'
          '• Industry',
      'geo_mins_stat_title': 'Resource statistics',
      'geo_mins_stat_types': 'Number of material types: 100+',
      'geo_mins_stat_mines': 'Deposits and sites: 2,000+',
      'geo_mins_stat_gold': 'Gold (world): 4th place',
      'geo_mins_stat_uran': 'Uranium (world): 7th place',
      'geo_mins_stat_export': 'Key exports: gold, copper, gas',
      'geo_land_sub1': 'Relief types',
      'geo_land_sub2': 'Natural phenomena',
      'geo_relief_title': 'Relief types',
      'geo_relief_uz_relyefi': 'Relief of Uzbekistan',
      'geo_relief_lead': 'The relief is diverse: plains, mountains, valleys and deserts.',
      'geo_rel_tog': 'Mountains',
      'geo_rel_tog_desc':
          'Located in the eastern and south-eastern parts of Uzbekistan.\n\n'
          'Main mountain systems:\n\n'
          '1. Tian Shan (North-east)\n'
          '• Highest: Adelunga Peak (4,301 m)\n'
          '• Chimgan Mountains\n'
          '• Pskem Mountains\n'
          '• Korzhantau Mountains\n\n'
          '2. Pamir-Alay (East)\n'
          '• Alay Range\n'
          '• Turkestan Range\n'
          '• Zeravshan Range\n'
          '• Hissar Range\n\n'
          '3. Kopet Dag (West)\n'
          '• On the border with Turkmenistan\n'
          '• Low mountains (1,000–1,500 m)\n\n'
          'Features:\n'
          '• Elevation: 1,000–4,300 m\n'
          '• Snow-capped peaks\n'
          '• Glaciers\n'
          '• River sources\n'
          '• Mineral springs\n\n'
          'Importance:\n'
          '• Water resources\n'
          '• Tourism and mountaineering\n'
          '• Mineral resources\n'
          '• Alpine pastures',
      'geo_rel_tekis': 'Plains',
      'geo_rel_tekis_desc':
          'Cover a large part of Uzbekistan.\n\n'
          'Main plains:\n\n'
          '1. Turan Lowland\n'
          '• The largest plain\n'
          '• Elevation: 200–500 m\n'
          '• The Kyzylkum desert lies here\n\n'
          '2. Mirzachul (Hungry Steppe)\n'
          '• In the Syr Darya basin\n'
          '• Good water supply\n'
          '• Agriculture\n\n'
          '3. Plains in the Zeravshan valley\n'
          '• Around Samarkand and Bukhara\n'
          '• Fertile lands\n'
          '• Irrigated farming\n\n'
          '4. Plains in the Sherabad valley\n'
          '• Surkhandarya region\n'
          '• Hot climate\n'
          '• Cotton growing\n\n'
          'Features:\n'
          '• Flat surface\n'
          '• Irrigated lands\n'
          '• Suited to farming\n'
          '• Developed transport\n\n'
          'Use:\n'
          '• Agriculture\n'
          '• Urban construction\n'
          '• Industry',
      'geo_rel_cho': 'Deserts',
      'geo_rel_cho_desc':
          'There are two major deserts in Uzbekistan.\n\n'
          '1. Kyzylkum Desert\n'
          '• Area: ~300,000 km²\n'
          '• Uzbekistan and Kazakhstan\n'
          '• Sandy ridges and dunes\n'
          '• Low rainfall\n\n'
          'Features:\n'
          '• Red sands\n'
          '• Saxaul groves\n'
          '• Sparse wildlife\n'
          '• Summer up to +45 °C, winter down to −25 °C\n\n'
          '2. Karakum Desert\n'
          '• In Karakalpakstan\n'
          '• Near the Amu Darya\n'
          '• Dark sands\n\n'
          'Features:\n'
          '• Dark clay-rich sands\n'
          '• Saline soils\n'
          '• Impact of the Aral Sea\n'
          '• Environmental problems\n\n'
          'In the deserts:\n'
          '• Gas and oil fields\n'
          '• Livestock (karakul sheep)\n'
          '• Saxaul wood\n'
          '• Transport routes\n\n'
          'Problems:\n'
          '• Water scarcity\n'
          '• Desertification\n'
          '• Effects of the Aral Sea drying up',
      'geo_rel_vod': 'Valleys',
      'geo_rel_vod_desc':
          'Low-lying areas between mountains where rivers flow.\n\n'
          'Main valleys:\n\n'
          '1. Fergana Valley\n'
          '• Area: ~22,000 km²\n'
          '• One of the oldest cultural centres\n'
          '• Densely populated\n\n'
          'Features:\n'
          '• Ringed by mountains\n'
          '• Fertile soil\n'
          '• Irrigated farming\n'
          '• Fruit and cotton\n\n'
          'Regions:\n'
          '• Andijan\n'
          '• Namangan\n'
          '• Fergana\n\n'
          '2. Zeravshan valley\n'
          '• Samarkand and Bukhara\n'
          '• Historic cities\n'
          '• Zeravshan River\n\n'
          '3. Surkhandarya valley\n'
          '• Southern region\n'
          '• Hot climate\n'
          '• Cotton and vegetables\n\n'
          '4. Kashkadarya valley\n'
          '• Karshi city\n'
          '• Agriculture\n'
          '• Natural gas\n\n'
          'Importance:\n'
          '• Agricultural hub\n'
          '• Dense population\n'
          '• Developed industry\n'
          '• Historic cities',
      'geo_rel_plat': 'Plateaus',
      'geo_rel_plat_desc':
          'High, flat surfaces.\n\n'
          'Main plateaus:\n\n'
          '1. Ustyurt Plateau\n'
          '• In Karakalpakstan\n'
          '• Elevation: about 200 m\n'
          '• Flat surface\n'
          '• Desert climate\n\n'
          'Features:\n'
          '• Hard rock\n'
          '• Sparse vegetation\n'
          '• Karakul sheep\n'
          '• Mineral resources\n\n'
          '2. Karatau range\n'
          '• Navoiy region\n'
          '• Low mountains\n'
          '• Mineral resources\n\n'
          '3. Nuratau mountains\n'
          '• Zarafshan and Samarkand regions\n'
          '• Elevation up to 2,000 m\n'
          '• Alpine pastures\n\n'
          'Mineral resources:\n'
          '• Gold mines\n'
          '• Copper mines\n'
          '• Uranium\n'
          '• Phosphorites\n\n'
          'Livestock:\n'
          '• Pasture lands\n'
          '• Sheep and goats\n'
          '• Cattle and small stock',
      'geo_rel_river': 'Relief in river valleys',
      'geo_rel_river_desc':
          'Low-lying areas around rivers.\n\n'
          'Main rivers:\n\n'
          '1. Amu Darya\n'
          '• Length: 1,415 km (in Uzbekistan)\n'
          '• Source: Pamir glaciers\n'
          '• Flows into the Aral Sea\n\n'
          'Valley relief:\n'
          '• Flat plains\n'
          '• Delta areas\n'
          '• Fertile soil\n'
          '• Irrigation network\n\n'
          '2. Syr Darya\n'
          '• Length: 2,212 km\n'
          '• Source: Tian Shan glaciers\n'
          '• Flows into the Aral Sea\n\n'
          'Valley relief:\n'
          '• Mirzachul plain\n'
          '• Passes through the Fergana Valley\n'
          '• Irrigated lands\n\n'
          '3. Zeravshan\n'
          '• Length: 877 km\n'
          '• Through Samarkand and Bukhara\n'
          '• Disappears in the desert\n\n'
          'Valley relief:\n'
          '• Historic cities\n'
          '• Ancient culture\n'
          '• Fertile soil\n\n'
          'Features:\n'
          '• Alluvial soils\n'
          '• High productivity\n'
          '• Good water supply',
      'geo_relief_stat_title': 'Relief statistics',
      'geo_relief_stat_high': 'Highest point: Adelunga (4,301 m)',
      'geo_relief_stat_low': 'Lowest: Aral Sea level (about −28 m)',
      'geo_relief_stat_avg': 'Mean elevation: ~600 m',
      'geo_relief_stat_mtn': 'Mountain share: ~20%',
      'geo_relief_stat_plain': 'Plain share: ~80%',
      'geo_phenomena_title': 'Natural phenomena',
      'geo_ph_quake': 'Earthquakes',
      'geo_ph_quake_desc':
          'Uzbekistan lies in areas of high earthquake risk.\n\n'
          'Earthquake zones:\n'
          '• Tashkent — strong 1966 earthquake (8–9 magnitude)\n'
          '• Fergana Valley — 7–8 magnitude\n'
          '• Andijan — 1902 (6–7 magnitude)\n'
          '• Namangan — historical earthquakes\n\n'
          'Causes:\n'
          '• Movement of the Indian Plate\n'
          '• Ongoing mountain building\n'
          '• Stress in the Earth\'s crust\n'
          '• Junction of geological zones\n\n'
          'Consequences:\n'
          '• Building collapse\n'
          '• Human casualties\n'
          '• Economic damage\n'
          '• Infrastructure failure\n\n'
          'Protection measures:\n'
          '• Earthquake-resistant building codes\n'
          '• Strengthening buildings\n'
          '• Public awareness\n'
          '• Emergency preparedness\n'
          '• Monitoring systems\n\n'
          'History:\n'
          '• 1966 Tashkent earthquake — the largest\n'
          '• The city was rebuilt\n'
          '• Aid from across the USSR\n'
          '• A modern city emerged',
      'geo_ph_sel': 'Mudflows / debris flows',
      'geo_ph_sel_desc':
          'Caused by spring glacier melt and heavy rainfall.\n\n'
          'Dangerous areas:\n'
          '• Mountain regions\n'
          '• Fergana Valley\n'
          '• Surkhandarya region\n'
          '• Kashkadarya region\n'
          '• Samarkand region\n\n'
          'Causes:\n'
          '• Snow and glacier melt in the mountains\n'
          '• Heavy rains\n'
          '• Deforestation\n'
          '• Soil erosion\n'
          '• Rivers overflowing\n\n'
          'Consequences:\n'
          '• Roads washed away\n'
          '• Houses destroyed\n'
          '• Damage to farm crops\n'
          '• Transport routes cut off\n'
          '• Human casualties\n\n'
          'Prevention:\n'
          '• Building dams and debris barriers\n'
          '• Clearing river channels\n'
          '• Afforestation\n'
          '• Monitoring systems\n'
          '• Public warnings\n\n'
          'Most dangerous periods:\n'
          '• March–April (spring)\n'
          '• May–June (glacier melt)\n'
          '• September (autumn rains)',
      'geo_ph_qong': 'Locusts',
      'geo_ph_qong_desc':
          'Insects that cause severe damage to agriculture.\n\n'
          'Types:\n'
          '• Italian (Moroccan) locust\n'
          '• Forest locust\n'
          '• Asian locust\n\n'
          'Dangerous areas:\n'
          '• Jizzakh region\n'
          '• Navoiy region\n'
          '• Samarkand region\n'
          '• Kashkadarya region\n\n'
          'Life cycle:\n'
          '• Egg — autumn\n'
          '• Larva — spring\n'
          '• Adult — summer\n'
          '• Swarming flight — May–June\n'
          '• Egg laying — July–August\n\n'
          'Damage:\n'
          '• Consumes vegetation\n'
          '• Crop loss\n'
          '• Damage to pastures\n'
          '• Major economic losses\n\n'
          'Control methods:\n'
          '• Chemical pesticides\n'
          '• Biological control (natural enemies)\n'
          '• Destroying egg beds\n'
          '• Monitoring and forecasting\n'
          '• Community participation\n\n'
          'History:\n'
          '• 2019–2020 — widespread outbreak\n'
          '• National programme adopted\n'
          '• International cooperation',
      'geo_ph_drought': 'Drought',
      'geo_ph_drought_desc':
          'A long period with little or no precipitation.\n\n'
          'Causes:\n'
          '• Climate change\n'
          '• Continental climate\n'
          '• Distance from the sea\n'
          '• Atmospheric processes\n\n'
          'Consequences:\n'
          '• Lower crop yields\n'
          '• Shortage of fodder for livestock\n'
          '• Water scarcity\n'
          '• Desertification\n'
          '• Economic losses\n\n'
          'At-risk areas:\n'
          '• Karakalpakstan\n'
          '• Bukhara region\n'
          '• Navoiy region\n'
          '• Around the Kyzylkum Desert\n\n'
          'Impacts:\n'
          '• Damage to agriculture\n'
          '• Public water supply\n'
          '• Industrial production\n'
          '• Ecological disruption\n\n'
          'Prevention:\n'
          '• Improving irrigation systems\n'
          '• Water-saving technologies\n'
          '• Drought-resistant crop varieties\n'
          '• Afforestation\n'
          '• Building reservoirs\n\n'
          'Timing:\n'
          '• About once every 3–5 years\n'
          '• Severe drought about every 10–15 years\n'
          '• Worst in summer months',
      'geo_ph_wind': 'Winds',
      'geo_ph_wind_desc':
          'Winds from several directions blow across Uzbekistan.\n\n'
          'Types of winds:\n\n'
          '1. Afghan wind (from the south)\n'
          '• Hot and dry\n'
          '• Frequent in summer\n'
          '• Raises temperatures\n'
          '• Lifts dust\n\n'
          '2. Storm winds\n'
          '• Strong spring winds\n'
          '• Speed: 20–30 m/s\n'
          '• Damage to buildings\n'
          '• Breaks trees\n\n'
          '3. Foehn (descending from mountains)\n'
          '• Hot and dry\n'
          '• In mountain regions\n'
          '• Melts snow\n\n'
          '4. Breeze (local wind)\n'
          '• Between mountains and valley\n'
          '• Differs between day and night\n'
          '• Effect on climate\n\n'
          'Consequences:\n'
          '• Erosion (soil blown away)\n'
          '• Damage to plants\n'
          '• Damage to buildings\n'
          '• Difficult transport\n'
          '• Dust storms\n\n'
          'Benefits:\n'
          '• Wind power\n'
          '• Moderates climate\n'
          '• Air circulation\n'
          '• Plant pollination\n\n'
          'Windiest zones:\n'
          '• Ustyurt Plateau\n'
          '• Kyzylkum Desert\n'
          '• Mountain passes',
      'geo_ph_wave': 'Cold and heat waves',
      'geo_ph_wave_desc':
          'Sharp swings in temperature.\n\n'
          'Cold waves:\n'
          '• Winter below −20 °C\n'
          '• Arrive from the north\n'
          '• Last 3–7 days\n'
          '• Harm agriculture\n\n'
          'Impacts:\n'
          '• Plants freeze\n'
          '• Irrigation systems freeze\n'
          '• Hard on livestock\n'
          '• Higher energy use\n'
          '• Transport disruption\n\n'
          'Protection:\n'
          '• Greenhouses\n'
          '• Covering crops\n'
          '• Housing animals indoors\n'
          '• Heating pipes\n\n'
          'Heat waves:\n'
          '• Summer above +40 °C\n'
          '• Arrive from the south\n'
          '• Last 5–10 days\n'
          '• Affects public health\n\n'
          'Consequences:\n'
          '• Water shortage\n'
          '• Crop damage\n'
          '• Fire risk\n'
          '• Health issues\n'
          '• Higher electricity use\n\n'
          'Advice:\n'
          '• Drink more water\n'
          '• Limit time in the sun\n'
          '• Use air conditioning\n'
          '• Wear light-coloured clothing\n\n'
          'Typical timing:\n'
          '• Winter: December–January\n'
          '• Summer: June–July–August',
      'geo_ph_koch': 'Landslides',
      'geo_ph_koch_desc':
          'Sliding of soil and rocks on mountain slopes.\n\n'
          'Causes:\n'
          '• Break-up of mountain rock\n'
          '• Heavy rains\n'
          '• Earthquakes\n'
          '• Water runoff\n'
          '• Human activity\n\n'
          'At-risk areas:\n'
          '• Mountains of Tashkent region\n'
          '• Mountains of the Fergana Valley\n'
          '• Mountainous Surkhandarya\n'
          '• Mountains of Kashkadarya region\n\n'
          'Types:\n\n'
          '1. Soil landslide\n'
          '• Soft soil slips\n'
          '• On wet ground\n\n'
          '2. Rock landslide\n'
          '• Rocks roll downslope\n'
          '• Very dangerous\n\n'
          '3. Mixed landslide\n'
          '• Soil and rock mixed\n\n'
          'Consequences:\n'
          '• Roads blocked\n'
          '• Houses damaged\n'
          '• Human casualties\n'
          '• Loss of farmland\n'
          '• Irrigation canals blocked\n\n'
          'Protection measures:\n'
          '• Building protective structures\n'
          '• Installing barriers\n'
          '• Afforestation\n'
          '• Managing water flow\n'
          '• Monitoring\n'
          '• Relocating from hazardous sites\n\n'
          'Forecasting:\n'
          '• Geological surveys\n'
          '• Rainfall monitoring\n'
          '• Earthquake monitoring',
      'geo_ph_melt': 'Glacier melting',
      'geo_ph_melt_desc':
          'Gradual melting of mountain glaciers.\n\n'
          'Glaciers in Uzbekistan:\n'
          '• In Fergana region mountains\n'
          '• In Tashkent region mountains\n'
          '• Total area: ~650 km²\n'
          '• Annual shrinkage: about 0.5–1%\n\n'
          'Causes:\n'
          '• Global warming\n'
          '• Rising temperatures\n'
          '• Changing precipitation\n'
          '• Human influence\n\n'
          'Importance:\n'
          '• River sources\n'
          '• Water resources\n'
          '• Climate effects\n'
          '• Vital for ecosystems\n\n'
          'Consequences:\n\n'
          'Short term:\n'
          '• Higher water volumes\n'
          '• Mudflow / flood risk\n'
          '• Lakes filling or overflowing\n\n'
          'Long term:\n'
          '• Glacier disappearance\n'
          '• Lower river flows\n'
          '• Irrigation water shortages\n'
          '• Ecological damage\n\n'
          'Impact on rivers:\n'
          '• Zeravshan — glacier-fed\n'
          '• Kashkadarya — glacier-fed\n'
          '• Surkhandarya — partly\n'
          '• Chirchik — glacier-fed\n\n'
          'Monitoring:\n'
          '• Satellite observation\n'
          '• Meteorological stations\n'
          '• Measuring water flow\n'
          '• International cooperation\n\n'
          'Protection measures:\n'
          '• Rational water use\n'
          '• Water-saving technologies\n'
          '• Environmental programmes\n'
          '• International cooperation',
      'geo_map_sub1': 'Our republic (facts)',
      'geo_map_sub_karakalpak': 'Republic of Karakalpakstan',
      'geo_map_sub2': 'Neighboring countries',
      'geo_karakalpak_title': 'Republic of Karakalpakstan',
      'geo_karakalpak_capital': 'Capital: Nukus',
      'geo_karakalpak_intro': 'Karakalpakstan is an autonomous republic in the northwest of Uzbekistan. The terrain is mostly desert and semi-desert (Karakum, Aral Sea region). It is rich in natural resources, especially salt, gas, limestone, and other minerals.',
      'geo_karakalpak_section_title': 'Key facts',
      'geo_karakalpak_border_label': 'Approx. border length',
      'geo_karakalpak_v_area': '166,600 km²',
      'geo_karakalpak_v_pop': '~2.04 million (2024)',
      'geo_karakalpak_v_lang': 'Karakalpak and Uzbek',
      'geo_karakalpak_v_currency': 'Uzbekistan soʻm (UZS)',
      'geo_karakalpak_v_border': '≈ 1,700 – 1,800 km',
      'geo_republic_title': 'Republic of Uzbekistan',
      'geo_republic_capital': 'Capital: Tashkent',
      'geo_republic_lead': 'Uzbekistan is an independent country in Central Asia. Tashkent is the economic and cultural capital; the state is a republic. The economy combines industry, agriculture, and services.',
      'geo_republic_v_area': '448,978 km²',
      'geo_republic_v_pop': 'Over 36 million',
      'geo_republic_v_lang': 'Uzbek (state language); Russian widely used',
      'geo_republic_v_currency': 'Uzbekistani soʻm (UZS)',
      'geo_republic_admin_label': 'Administrative divisions',
      'geo_republic_v_admin': '12 regions and the Republic of Karakalpakstan',
      'geo_republic_btn_map': 'Open world political map',
      'geo_borders_title': 'Borders',
      'geo_neighbors_section': 'Neighboring countries',
      'geo_capital_prefix': 'Capital: ',
      'geo_million_short': 'm',
      'geo_stat_area': 'Area',
      'geo_stat_pop': 'Population',
      'geo_stat_languages': 'Official languages',
      'geo_stat_currency': 'Currency',
      'geo_stat_border_uz': 'Border with Uzbekistan',
      'doc_decisions': 'Decisions',
      'doc_laws': 'Laws',
      'doc_all': 'All',
      'doc_empty': 'No documents found',
      'doc_offline_mode': 'Offline mode — cached data',
      'doc_refresh': 'Refresh',
      'doc_built_in': 'Built-in',
      'doc_downloaded': 'Downloaded',
      'doc_offline_ready': 'Saved from server — available offline',
      'doc_download': 'Download',
      'doc_download_update': 'Download update',
      'doc_delete_local': 'Delete local copy',
      'doc_need_download': 'Download first to read offline',
      'doc_download_failed': 'Download failed. Check internet and server',
      'doc_delete_confirm_title': 'Delete local copy?',
      'doc_delete_confirm_body': 'Only the file on this device will be removed. The document on the server and in the admin panel stays unchanged.',
      'doc_delete_confirm_action': 'Delete',
      'doc_file_not_on_device': 'PDF file not found. Please download again.',
      'chem_rx_section_types': 'Reaction types',
      'chem_rx_symbols_title': 'Reaction symbols:',
      'chem_rx_examples': 'Examples:',
      'chem_rx_close': 'Close',
      'chem_rx_retry': 'Retry',
      'chem_rx_error': 'Could not load data',
      'settings_general': 'General Settings',
      'settings_language': 'Language',
      'settings_dark_mode': 'Dark Mode',
      'settings_about': 'About App',
      'settings_about_sub': 'Info and License',
      'about_title': 'Chemistry and Geography',
      'about_desc': 'This app is designed to help school students in Uzbekistan learn chemistry and geography.',
      'about_features': 'Features:',
      'about_feature_1': '• Chemical elements information',
      'about_feature_2': '• Periodic table',
      'about_feature_3': '• Chemical reactions',
      'about_feature_4': '• Geography of Uzbekistan',
      'about_feature_5': '• Climate and weather',
      'about_feature_6': '• Interactive learning',
      'about_copyright': '© 2026 All rights reserved',
      'close': 'Close',
      'settings_author': 'About Author',
      'author_name': 'Bekimbetova Gulnaz Nabatovna',
      'author_role': 'Chemistry Teacher',
      'author_main_info': 'Main Information',
      'author_birth_date': 'Date of Birth',
      'author_birth_place': 'Place of Birth',
      'author_nationality': 'Nationality',
      'author_education': 'Education',
      'author_specialty': 'Specialty',
      'author_languages': 'Foreign Languages',
      'author_current_job': 'Current Workplace',
      'author_position': 'Position',
      'author_org': 'Organization',
      'author_dept': 'Department',
      'author_start_date': 'Start Date',
      'author_experience': 'Work Experience',
      'author_additional': 'Additional Information',
      'author_degree': 'Academic Degree',
      'author_title': 'Academic Title',
      'author_awards': 'State Awards',
      'author_deputy': 'Deputyship',
      'author_none': 'None',
      'author_uzb': 'Uzbek',
      'author_qoraqalpoq': 'Karakalpak',
      'author_higher': 'Higher',
      'author_chemistry': 'Chemistry',
      'author_lang_list': 'Russian, Turkish',
      'author_senior_teacher': 'Senior Teacher',
      'author_uni': 'Nukus State Technical University',
      'author_dept_name': 'Chemical Engineering and Environmental Protection',
      'author_start_val': 'from April 1, 2025',
      'author_present': 'present',
      'rate_title': 'Rate the App',
      'rate_subtitle': 'Your opinion matters to us!',
      'rate_submit': 'Submit',
      'rate_thanks': 'Thanks! You gave {} stars.',
      'rate_error_network': 'Network error. Please try again.',
      'rate_already_submitted': 'You have already rated the app.',
      'rate_submit_failed': 'Could not submit. Please try again later.',
      'rate_readonly_subtitle': 'You rated {} stars. Thank you!',
      'rate_done_close': 'Close',
      'settings_rate': 'Rate App',
      'settings_rate_sub': 'Give your feedback',
      'settings_rate_submitted': 'Your rating: {} stars',
      'doc_in_app': 'In-app',
      'doc_pdf_error': 'PDF file not found',
      'doc_loading': 'Loading PDF...',
      'settings_version': 'Version',
      'profile_time': 'Time',
      'profile_activity_time_empty': 'Not recorded yet',
      'time_unit_hour': 'h',
      'time_unit_minute': 'min',
      'time_unit_second': 's',
      'profile_personal': 'Personal Info',
      'profile_edu': 'Educational Info',
      'profile_activity': 'Activity',
      'profile_logout': 'Logout',
      'profile_edit': 'Edit Profile',
      'profile_name': 'Name',
      'profile_email': 'Email',
      'profile_phone': 'Phone',
      'profile_school': 'School',
      'profile_class': 'Class',
      'profile_save': 'Save',
      'profile_password_section': 'Change password',
      'profile_password_hint':
          'Leave all three fields below empty if you do not want to change your password.',
      'profile_current_password': 'Current password',
      'profile_new_password': 'New password',
      'profile_confirm_password': 'Confirm password',
      'profile_password_fill_all':
          'To change your password, fill in current, new, and confirmation.',
      'profile_password_too_short': 'New password must be at least 6 characters.',
      'profile_password_mismatch': 'New password and confirmation do not match.',
      'profile_updated': 'Profile updated',
      'profile_school_pick': 'Select school',
      'profile_grade_pick': 'Select class',
      'profile_reference_load_failed': 'Could not load schools and grades.',
      'profile_retry': 'Retry',
      'profile_add_school': 'New school',
      'profile_add_grade': 'New class',
      'profile_new_school_name': 'School name',
      'profile_new_school_city': 'District / city (optional)',
      'profile_new_grade_label': 'Grade (e.g. 9-sinf)',
      'profile_user_info': 'Account details',
      'profile_not_set': 'Not set',
      'profile_update_error': 'Could not save. Please try again.',
      'profile_student_suffix': 'student',
      'profile_activity_history': 'Activity History',
      'profile_achievements': 'Achievements',
      'profile_logout_confirm': 'Are you sure you want to logout?',
      'profile_logout_yes': 'Yes, logout',
      'profile_logout_no': 'No',
      'profile_logged_out': 'Logged out successfully',
      'profile_total_lessons': 'Total lessons:',
      'profile_study_time': 'Study time:',
      'profile_achievement_1': 'First Lesson',
      'profile_achievement_1_desc': 'You completed your first lesson',
      'profile_achievement_2': 'Chemistry Master',
      'profile_achievement_2_desc': 'You completed 10 chemistry lessons',
      'profile_achievement_3': 'Geography Expert',
      'profile_achievement_3_desc': 'You completed 10 geography lessons',
      'profile_achievement_4': 'Student',
      'profile_achievement_4_desc': 'You completed 50 lessons',
      'profile_achievement_5': 'Champion',
      'profile_achievement_5_desc': 'You completed 100 lessons',
      'profile_achievements_subtitle': 'Awards and certificates',
      'profile_lessons_total_pattern': '{n} lessons completed',
      'activity_when_today': 'Today',
      'activity_when_yesterday': 'Yesterday',
      'activity_days_ago_suffix': 'days ago',
      'activity_history_empty': 'No activity yet — scroll a chemistry lesson to the end or tap “Mark section complete” in geography.',
      'activity_subject_chemistry': 'Chemistry',
      'activity_subject_geography': 'Geography',
      'geo_mark_section_complete': 'I finished this section',
      'geo_topic_marked_complete': 'Section completed',
      'study_marked_done_snackbar': 'Saved',
      'search_hint': 'Enter element, salt or formula...',
      'prop_formula': 'Formula',
      'prop_molar_mass': 'Molar mass',
      'prop_color': 'Color',
      'prop_solubility': 'Solubility',
      'prop_melt_temp': 'Melting temperature',
      'prop_boil_temp': 'Boiling temperature',
      'prop_density': 'Density',
      'prop_electrons': 'Number of electrons',
      'prop_valence': 'Valence',
      'unknown': 'Unknown',
      'lang_select': 'Select Language',
      'cancel': 'Cancel',
      'toast_lang_changed': 'Language changed',
      'toast_theme_dark': 'Dark mode enabled',
      'toast_theme_light': 'Light mode enabled',
      'formula_calc_title': 'Calculate Formulas',
      'formula_input_hint': 'Enter chemical formula',
      'formula_example': 'Example: H2O, NaCl, Ca(OH)2',
      'formula_calculate': 'Calculate',
      'formula_popular': 'Popular Formulas',
      'formula_result_title': 'Molecular mass of {}:',
      'formula_total': 'Total',
      'formula_copy': 'Copied',
      'formula_invalid': 'Invalid formula',
      'formula_clear': 'Clear',
      'formula_backspace': 'Delete',
      'periodic_interaktiv': 'Interactive Table',
      'menu_natural_resources_map': 'Natural resources map',
      'natural_resources_map_pinch_hint':
          'Pinch to zoom, drag to pan. Use + / − or the top button to fit the image on screen.',
      'natural_resources_map_fit_tooltip': 'Fit to screen',
      'natural_resources_map_zoom_in': 'Zoom in',
      'natural_resources_map_zoom_out': 'Zoom out',
      'natural_resources_map_load_error': 'Could not load the map image. Please restart the app.',
      'menu_regional_minerals': 'Karakalpakstan minerals',
      'regional_minerals_map_hint': 'Pick a mineral in the list (eye icon) to show markers on the map.',
      'regional_minerals_quantity_label': 'Reserves / indicator',
      'regional_minerals_reference_title': 'Reference',
      'regional_minerals_no_reference': 'No reference cited.',
      'regional_minerals_show_on_map': 'Show on map',
      'regional_minerals_hide_on_map': 'Selected on map',
      'periodic_qiziqarli': 'Interesting Tasks',
      'menu_projects': 'Projects',
      'empty_interesting_tasks': 'No tasks yet',
      'empty_projects_tasks': 'No project tasks yet',
      'periodic_all': 'All',
      'periodic_alkali': 'Alkali Metal',
      'periodic_alkaline': 'Alkaline Earth Metal',
      'periodic_transition': 'Transition Metal',
      'periodic_metal': 'Metal',
      'periodic_metalloid': 'Metalloid',
      'periodic_nonmetal': 'Nonmetal',
      'periodic_halogen': 'Halogen',
      'periodic_noble': 'Noble Gas',
      'periodic_atom_num': 'Atomic Number',
      'periodic_symbol': 'Symbol',
      'periodic_mass': 'Mass',
      'periodic_category': 'Category',
      'periodic_lanthanide': 'Lanthanide',
      'periodic_actinide': 'Actinide',
      'properties': 'Properties',
      'no_results': 'No results found',
      'elements_offline_banner': 'Offline — showing the last saved elements from this device.',
      'menu_theory': 'Theory',
      'menu_lab': 'Laboratory',
      'splash_loading': 'Loading...',
      'splash_tagline': 'Chemistry and geography — learn in one place',
      'auth_hero_welcome': 'Great to have you back',
      'onboarding_badge': 'First step',
      'onboarding_lang_title': 'Choose language',
      'onboarding_lang_subtitle': 'You can change the language later in settings',
      'onboarding_lang_continue': 'Continue',
      'auth_login_title': 'Sign in',
      'auth_login_subtitle': 'Log in to your account',
      'auth_register_title': 'Sign up',
      'auth_register_subtitle': 'Create a new account',
      'auth_login_field': 'Login (username, email or phone)',
      'auth_username': 'Username (for sign-in)',
      'auth_username_hint': 'e.g. ellikkala_m2_9a_001',
      'auth_error_username': 'Enter username',
      'auth_error_username_len': 'Username must be at least 3 characters',
      'auth_error_username_chars': 'Latin letters, digits, . _ - only',
      'auth_phone': 'Phone number',
      'auth_phone_hint': '+998 90 123 45 67',
      'auth_error_phone': 'Enter your phone number',
      'auth_region': 'Region / Republic',
      'auth_district': 'District / City',
      'auth_district_hint': 'Select your district',
      'auth_error_district': 'Select a district',
      'auth_school_number': 'School number',
      'auth_school_number_hint': 'Select school number (1–58)',
      'auth_error_school': 'Select a school number',
      'auth_password': 'Password',
      'auth_password_confirm': 'Confirm password',
      'auth_name': 'Full name',
      'auth_login_action': 'Sign in',
      'auth_register_action': 'Sign up',
      'auth_no_account_register': 'No account? Register',
      'auth_has_account_login': 'Already have an account? Sign in',
      'auth_success_login': 'Signed in successfully',
      'auth_success_register': 'Registration successful',
      'auth_error_login': 'Enter your phone or username',
      'auth_error_password': 'Enter password',
      'auth_error_password_len': 'Password must be at least 6 characters',
      'auth_error_password_mismatch': 'Passwords do not match',
      'auth_error_name': 'Enter your name',
      'auth_error_generic': 'Something went wrong. Please try again',
      'my_submissions_title': 'My submissions',
      'my_submissions_empty': 'You have not submitted any answers yet',
      'task_submit_appbar': 'Assignment',
      'task_submit_success_title': 'Congratulations!',
      'task_submit_success_body': 'Your assignment was submitted successfully. Your teacher will review your answers and set your result.',
      'task_submit_id_label': 'ID',
      'task_submit_status_label': 'Status',
      'task_submit_result_label': 'Result',
      'task_submit_status_pending': 'Under review',
      'task_submit_status_checked': 'Reviewed',
      'task_submit_result_hidden': 'Visible after your teacher allows it',
      'task_submit_result_points': '{{score}} pts',
      'task_submit_home': 'Back to home',
      'virtual_lab_title': 'Virtual Laboratory',
      'virtual_lab_start_btn': 'Open Virtual Laboratory',
      'virtual_lab_reaction_zone': 'Experiment Zone',
      'virtual_lab_hint': 'Select 2 materials (tool + element or 2 substances)',
      'virtual_lab_pick_second': 'Now select the second material...',
      'virtual_lab_clear': 'Clear',
      'virtual_lab_items_title': 'Laboratory Materials',
      'virtual_lab_required': 'Required',
      'virtual_lab_no_reaction': 'No reaction observed between these substances.',
      'virtual_lab_load_error': 'Failed to load materials',
      'virtual_lab_empty_category': 'No materials in this category',
      'virtual_lab_tab_all': 'All',
      'virtual_lab_tab_equipment': 'Equipment',
      'virtual_lab_tab_vessel': 'Vessel',
      'virtual_lab_tab_element': 'Element',
      'virtual_lab_tab_reagent': 'Reagent',
      'virtual_lab_checklist_title': 'Required materials',
      'virtual_lab_procedure_title': 'Procedure',
      'virtual_lab_template_footer': 'Checklist and steps aligned with the course lab template.',
      'virtual_lab_optional': 'optional',
      'retry': 'Retry',
    }
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['uz', 'ru', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
  Locale get locale => Localizations.localeOf(this);
}

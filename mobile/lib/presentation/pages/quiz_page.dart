import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';

bool _isGeographyCategory(String category) {
  return category == 'siyosiy_xarita' ||
      category == 'qitalar' ||
      category == 'poytaxtlar' ||
      category == 'iqlim_obhavo' ||
      category == 'tog_jinslari' ||
      category == 'foydali_qazilmalar' ||
      category == 'relyef_turlari' ||
      category == 'tabiiy_hodisalar';
}

class QuizPage extends StatefulWidget {
  final String title;
  final String category;

  const QuizPage({super.key, required this.title, required this.category});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  // Local data for now as requested
  final List<Map<String, dynamic>> _elementsQuestions = [
    {
      'question': {
        'uz': 'Vodorodning kimyoviy belgisi qaysi?',
        'ru': 'Каков химический символ водорода?',
        'en': 'What is the chemical symbol for hydrogen?'
      },
      'options': [
        {'uz': 'H', 'ru': 'H', 'en': 'H', 'isCorrect': true},
        {'uz': 'He', 'ru': 'He', 'en': 'He', 'isCorrect': false},
        {'uz': 'O', 'ru': 'O', 'en': 'O', 'isCorrect': false},
        {'uz': 'N', 'ru': 'N', 'en': 'N', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Qaysi element \'O\' harfi bilan belgilanadi?',
        'ru': 'Какой элемент обозначается буквой «О»?',
        'en': 'Which element is denoted by the letter \'O\'?'
      },
      'options': [
        {'uz': 'Oltin', 'ru': 'Золото', 'en': 'Gold', 'isCorrect': false},
        {'uz': 'Oltingugurt', 'ru': 'Сера', 'en': 'Sulfur', 'isCorrect': false},
        {'uz': 'Kislorod', 'ru': 'Кислород', 'en': 'Oxygen', 'isCorrect': true},
        {'uz': 'Osmiy', 'ru': 'Осмий', 'en': 'Osmium', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Eng yengil element qaysi?',
        'ru': 'Какой самый легкий элемент?',
        'en': 'Which is the lightest element?'
      },
      'options': [
        {'uz': 'Litiy', 'ru': 'Литий', 'en': 'Lithium', 'isCorrect': false},
        {'uz': 'Geliy', 'ru': 'Гелий', 'en': 'Helium', 'isCorrect': false},
        {'uz': 'Vodorod', 'ru': 'Водород', 'en': 'Hydrogen', 'isCorrect': true},
        {'uz': 'Bor', 'ru': 'Бор', 'en': 'Boron', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Oltinning kimyoviy belgisi nima?',
        'ru': 'Каков химический символ золота?',
        'en': 'What is the chemical symbol for gold?'
      },
      'options': [
        {'uz': 'Ag', 'ru': 'Ag', 'en': 'Ag', 'isCorrect': false},
        {'uz': 'Au', 'ru': 'Au', 'en': 'Au', 'isCorrect': true},
        {'uz': 'Al', 'ru': 'Al', 'en': 'Al', 'isCorrect': false},
        {'uz': 'Ar', 'ru': 'Ar', 'en': 'Ar', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Temirning lotincha nomi nima?',
        'ru': 'Как называется железо по-латыни?',
        'en': 'What is the Latin name for iron?'
      },
      'options': [
        {'uz': 'Ferrum', 'ru': 'Ferrum', 'en': 'Ferrum', 'isCorrect': true},
        {'uz': 'Cuprum', 'ru': 'Cuprum', 'en': 'Cuprum', 'isCorrect': false},
        {'uz': 'Argentum', 'ru': 'Argentum', 'en': 'Argentum', 'isCorrect': false},
        {'uz': 'Aurum', 'ru': 'Aurum', 'en': 'Aurum', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Suyuq holatdagi metal qaysi?',
        'ru': 'Какой металл находится в жидком состоянии?',
        'en': 'Which metal is in a liquid state?'
      },
      'options': [
        {'uz': 'Temir', 'ru': 'Железо', 'en': 'Iron', 'isCorrect': false},
        {'uz': 'Simob', 'ru': 'Ртуть', 'en': 'Mercury', 'isCorrect': true},
        {'uz': 'Natriy', 'ru': 'Натрий', 'en': 'Sodium', 'isCorrect': false},
        {'uz': 'Galliy', 'ru': 'Галлий', 'en': 'Gallium', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Azotning belgisi qaysi?',
        'ru': 'Каков символ азота?',
        'en': 'What is the symbol for nitrogen?'
      },
      'options': [
        {'uz': 'A', 'ru': 'A', 'en': 'A', 'isCorrect': false},
        {'uz': 'Az', 'ru': 'Az', 'en': 'Az', 'isCorrect': false},
        {'uz': 'N', 'ru': 'N', 'en': 'N', 'isCorrect': true},
        {'uz': 'Ni', 'ru': 'Ni', 'en': 'Ni', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Kaliying belgisi nima?',
        'ru': 'Каков символ калия?',
        'en': 'What is the symbol for potassium?'
      },
      'options': [
        {'uz': 'Ka', 'ru': 'Ka', 'en': 'Ka', 'isCorrect': false},
        {'uz': 'Cl', 'ru': 'Cl', 'en': 'Cl', 'isCorrect': false},
        {'uz': 'K', 'ru': 'K', 'en': 'K', 'isCorrect': true},
        {'uz': 'Ca', 'ru': 'Ca', 'en': 'Ca', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Natriy qaysi guruhga kiradi?',
        'ru': 'К какой группе относится натрий?',
        'en': 'Which group does sodium belong to?'
      },
      'options': [
        {'uz': 'Inert gaz', 'ru': 'Инертный газ', 'en': 'Noble gas', 'isCorrect': false},
        {'uz': 'Ishqoriy metall', 'ru': 'Щелочной металл', 'en': 'Alkali metal', 'isCorrect': true},
        {'uz': 'Galogen', 'ru': 'Галоген', 'en': 'Halogen', 'isCorrect': false},
        {'uz': 'Nometall', 'ru': 'Неметалл', 'en': 'Non-metal', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Olmos qaysi elementdan tashkil topgan?',
        'ru': 'Из какого элемента состоит алмаз?',
        'en': 'Which element is diamond made of?'
      },
      'options': [
        {'uz': 'Kremniy', 'ru': 'Кремний', 'en': 'Silicon', 'isCorrect': false},
        {'uz': 'Uglerod', 'ru': 'Углерод', 'en': 'Carbon', 'isCorrect': true},
        {'uz': 'Bor', 'ru': 'Бор', 'en': 'Boron', 'isCorrect': false},
        {'uz': 'Ftor', 'ru': 'Фтор', 'en': 'Fluorine', 'isCorrect': false},
      ]
    },
  ];

  final List<Map<String, dynamic>> _periodicQuestions = [
    {
      'question': {
        'uz': 'Davriy jadvalda nechta guruh bor?',
        'ru': 'Сколько групп в периодической таблице?',
        'en': 'How many groups are there in the periodic table?'
      },
      'options': [
        {'uz': '8', 'ru': '8', 'en': '8', 'isCorrect': false},
        {'uz': '18', 'ru': '18', 'en': '18', 'isCorrect': true},
        {'uz': '10', 'ru': '10', 'en': '10', 'isCorrect': false},
        {'uz': '7', 'ru': '7', 'en': '7', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Davriy jadval asoschisi kim?',
        'ru': 'Кто основатель периодической таблицы?',
        'en': 'Who is the founder of the periodic table?'
      },
      'options': [
        {'uz': 'Nyuton', 'ru': 'Ньютон', 'en': 'Newton', 'isCorrect': false},
        {'uz': 'Eynshteyn', 'ru': 'Эйнштейн', 'en': 'Einstein', 'isCorrect': false},
        {'uz': 'Mendeleyev', 'ru': 'Менделеев', 'en': 'Mendeleev', 'isCorrect': true},
        {'uz': 'Bor', 'ru': 'Бор', 'en': 'Bohr', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Eng faol nometall qaysi?',
        'ru': 'Какой самый активный неметалл?',
        'en': 'Which is the most active non-metal?'
      },
      'options': [
        {'uz': 'Kislorod', 'ru': 'Кислород', 'en': 'Oxygen', 'isCorrect': false},
        {'uz': 'Ftor', 'ru': 'Фтор', 'en': 'Fluorine', 'isCorrect': true},
        {'uz': 'Xlor', 'ru': 'Хлор', 'en': 'Chlorine', 'isCorrect': false},
        {'uz': 'Azot', 'ru': 'Азот', 'en': 'Nitrogen', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Inert gazlar qaysi guruhda joylashgan?',
        'ru': 'В какой группе находятся инертные газы?',
        'en': 'In which group are noble gases located?'
      },
      'options': [
        {'uz': '1-guruh', 'ru': '1-я группа', 'en': 'Group 1', 'isCorrect': false},
        {'uz': '17-guruh', 'ru': '17-я группа', 'en': 'Group 17', 'isCorrect': false},
        {'uz': '18-guruh', 'ru': '18-я группа', 'en': 'Group 18', 'isCorrect': true},
        {'uz': '8-guruh', 'ru': '8-я группа', 'en': 'Group 8', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Ishqoriy metallar qaysi guruhda?',
        'ru': 'В какой группе находятся щелочные металлы?',
        'en': 'In which group are alkali metals?'
      },
      'options': [
        {'uz': '1-guruh', 'ru': '1-я группа', 'en': 'Group 1', 'isCorrect': true},
        {'uz': '2-guruh', 'ru': '2-я группа', 'en': 'Group 2', 'isCorrect': false},
        {'uz': '3-guruh', 'ru': '3-я группа', 'en': 'Group 3', 'isCorrect': false},
        {'uz': '18-guruh', 'ru': '18-я группа', 'en': 'Group 18', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Lantanidlar qayerda joylashgan?',
        'ru': 'Где находятся лантаноиды?',
        'en': 'Where are lanthanides located?'
      },
      'options': [
        {'uz': 'Jadval tepasida', 'ru': 'Вверху таблицы', 'en': 'At the top of the table', 'isCorrect': false},
        {'uz': 'Jadval o\'rtasida', 'ru': 'В середине таблицы', 'en': 'In the middle of the table', 'isCorrect': false},
        {'uz': 'Jadval pastida', 'ru': 'Внизу таблицы', 'en': 'At the bottom of the table', 'isCorrect': true},
        {'uz': 'Jadval o\'ngida', 'ru': 'Справа в таблице', 'en': 'On the right in the table', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': '3-davr elementlari nechta?',
        'ru': 'Сколько элементов в 3-м периоде?',
        'en': 'How many elements are in the 3rd period?'
      },
      'options': [
        {'uz': '2', 'ru': '2', 'en': '2', 'isCorrect': false},
        {'uz': '8', 'ru': '8', 'en': '8', 'isCorrect': true},
        {'uz': '18', 'ru': '18', 'en': '18', 'isCorrect': false},
        {'uz': '32', 'ru': '32', 'en': '32', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Galogenlar qaysi elementlar?',
        'ru': 'Какие элементы являются галогенами?',
        'en': 'Which elements are halogens?'
      },
      'options': [
        {'uz': 'F, Cl, Br, I', 'ru': 'F, Cl, Br, I', 'en': 'F, Cl, Br, I', 'isCorrect': true},
        {'uz': 'Li, Na, K, Rb', 'ru': 'Li, Na, K, Rb', 'en': 'Li, Na, K, Rb', 'isCorrect': false},
        {'uz': 'He, Ne, Ar, Kr', 'ru': 'He, Ne, Ar, Kr', 'en': 'He, Ne, Ar, Kr', 'isCorrect': false},
        {'uz': 'B, C, N, O', 'ru': 'B, C, N, O', 'en': 'B, C, N, O', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Atom raqami 1 bo\'lgan element?',
        'ru': 'Элемент с атомным номером 1?',
        'en': 'Element with atomic number 1?'
      },
      'options': [
        {'uz': 'Geliy', 'ru': 'Гелий', 'en': 'Helium', 'isCorrect': false},
        {'uz': 'Vodorod', 'ru': 'Водород', 'en': 'Hydrogen', 'isCorrect': true},
        {'uz': 'Litiy', 'ru': 'Литий', 'en': 'Lithium', 'isCorrect': false},
        {'uz': 'Berilliy', 'ru': 'Бериллий', 'en': 'Beryllium', 'isCorrect': false},
      ]
    },
    {
      'question': {
        'uz': 'Atom massasi eng katta tabiiy element?',
        'ru': 'Какой природный элемент имеет наибольшую атомную массу?',
        'en': 'Which natural element has the largest atomic mass?'
      },
      'options': [
        {'uz': 'Uran', 'ru': 'Уран', 'en': 'Uranium', 'isCorrect': true},
        {'uz': 'Osmiy', 'ru': 'Осмий', 'en': 'Osmium', 'isCorrect': false},
        {'uz': 'Qo\'rg\'oshin', 'ru': 'Свинец', 'en': 'Lead', 'isCorrect': false},
        {'uz': 'Oltin', 'ru': 'Золото', 'en': 'Gold', 'isCorrect': false},
      ]
    },
  ];

  final List<Map<String, dynamic>> _siyosiyXaritaQuestions = [
    {
      'question': {
        'uz': 'Oʻzbekiston qaysi davlatlar bilan chegaradosh?',
        'ru': 'С какими государствами граничит Узбекистан?',
        'en': 'Which countries border Uzbekistan?',
      },
      'options': [
        {
          'uz': 'Qozogʻiston, Qirgʻiziston, Tojikiston, Turkmaniston, Afgʻoniston',
          'ru': 'Казахстан, Кыргызстан, Таджикистан, Туркменистан, Афганистан',
          'en': 'Kazakhstan, Kyrgyzstan, Tajikistan, Turkmenistan, Afghanistan',
          'isCorrect': true,
        },
        {
          'uz': 'Rossiya, Xitoy, Qozogʻiston',
          'ru': 'Россия, Китай, Казахстан',
          'en': 'Russia, China, Kazakhstan',
          'isCorrect': false,
        },
        {
          'uz': 'Eron, Pokiston, Turkmaniston',
          'ru': 'Иран, Пакистан, Туркменистан',
          'en': 'Iran, Pakistan, Turkmenistan',
          'isCorrect': false,
        },
        {
          'uz': 'Tojikiston, Qirgʻiziston, Xitoy',
          'ru': 'Таджикистан, Кыргызстан, Китай',
          'en': 'Tajikistan, Kyrgyzstan, China',
          'isCorrect': false,
        },
      ],
    },
    {
      'question': {
        'uz':
            'Dunyo okeaniga chiqa olmaydigan, lekin dunyo okeaniga chiqish uchun kamida ikkita davlat chegarasini kesib oʻtishi kerak boʻlgan davlatlar (double landlocked) qaysi?',
        'ru': 'Какие страны — двойственно «сухопутные» (до Мирового океана минимум через две границы)?',
        'en':
            'Which are the two doubly landlocked countries (no ocean access, must cross at least two borders to reach the ocean)?',
      },
      'options': [
        {
          'uz': 'Oʻzbekiston va Lixtenshteyn',
          'ru': 'Узбекистан и Лихтенштейн',
          'en': 'Uzbekistan and Liechtenstein',
          'isCorrect': true,
        },
        {
          'uz': 'Shveytsariya va Avstriya',
          'ru': 'Швейцария и Австрия',
          'en': 'Switzerland and Austria',
          'isCorrect': false,
        },
        {
          'uz': 'Qozogʻiston va Mongoliya',
          'ru': 'Казахстан и Монголия',
          'en': 'Kazakhstan and Mongolia',
          'isCorrect': false,
        },
        {
          'uz': 'Boliviya va Paragvay',
          'ru': 'Боливия и Парагвай',
          'en': 'Bolivia and Paraguay',
          'isCorrect': false,
        },
      ],
    },
    {
      'question': {
        'uz': 'Eng katta maydonga ega davlat qaysi?',
        'ru': 'Какая страна имеет наибольшую площадь?',
        'en': 'Which country has the largest area?',
      },
      'options': [
        {'uz': 'Xitoy', 'ru': 'Китай', 'en': 'China', 'isCorrect': false},
        {'uz': 'AQSh', 'ru': 'США', 'en': 'USA', 'isCorrect': false},
        {'uz': 'Kanada', 'ru': 'Канада', 'en': 'Canada', 'isCorrect': false},
        {'uz': 'Rossiya', 'ru': 'Россия', 'en': 'Russia', 'isCorrect': true},
      ],
    },
    {
      'question': {
        'uz': 'Yevropa va Osiyo qitʻasida joylashgan davlatlar qaysilar?',
        'ru': 'Какие из стран расположены и в Европе, и в Азии?',
        'en': 'Which countries lie in both Europe and Asia?',
      },
      'options': [
        {
          'uz': 'Turkiya, Rossiya, Qozogʻiston',
          'ru': 'Турция, Россия, Казахстан',
          'en': 'Turkey, Russia, Kazakhstan',
          'isCorrect': true,
        },
        {
          'uz': 'Misr, Saudiya Arabistoni',
          'ru': 'Египет, Саудовская Аравия',
          'en': 'Egypt, Saudi Arabia',
          'isCorrect': false,
        },
        {
          'uz': 'Germaniya, Fransiya',
          'ru': 'Германия, Франция',
          'en': 'Germany, France',
          'isCorrect': false,
        },
        {
          'uz': 'Xitoy, Hindiston',
          'ru': 'Китай, Индия',
          'en': 'China, India',
          'isCorrect': false,
        },
      ],
    },
    {
      'question': {
        'uz': 'Oʻzbekiston maydoni qancha?',
        'ru': 'Какова площадь Узбекистана?',
        'en': 'What is the area of Uzbekistan?',
      },
      'options': [
        {
          'uz': '448,9 ming km²',
          'ru': '448,9 тыс. км²',
          'en': '448.9 thousand km²',
          'isCorrect': true,
        },
        {
          'uz': '447,4 ming km²',
          'ru': '447,4 тыс. км²',
          'en': '447.4 thousand km²',
          'isCorrect': false,
        },
        {
          'uz': '500 ming km²',
          'ru': '500 тыс. км²',
          'en': '500 thousand km²',
          'isCorrect': false,
        },
        {
          'uz': '200 ming km²',
          'ru': '200 тыс. км²',
          'en': '200 thousand km²',
          'isCorrect': false,
        },
      ],
    },
    {
      'question': {
        'uz': "Qaysi davlat «Kunchiqar mamlakat» deb ataladi?",
        'ru': 'Какая страна называется «страной восходящего солнца»?',
        'en': 'Which country is called the “land of the rising sun”?',
      },
      'options': [
        {'uz': 'Xitoy', 'ru': 'Китай', 'en': 'China', 'isCorrect': false},
        {'uz': 'Koreya', 'ru': 'Корея', 'en': 'Korea', 'isCorrect': false},
        {'uz': 'Yaponiya', 'ru': 'Япония', 'en': 'Japan', 'isCorrect': true},
        {'uz': 'Vyetnam', 'ru': 'Вьетнам', 'en': 'Vietnam', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Janubiy Amerikadagi eng katta davlat qaysi?',
        'ru': 'Какая самая большая страна в Южной Америке?',
        'en': 'Which is the largest country in South America?',
      },
      'options': [
        {'uz': 'Argentina', 'ru': 'Аргентина', 'en': 'Argentina', 'isCorrect': false},
        {'uz': 'Braziliya', 'ru': 'Бразилия', 'en': 'Brazil', 'isCorrect': true},
        {'uz': 'Peru', 'ru': 'Перу', 'en': 'Peru', 'isCorrect': false},
        {'uz': 'Kolumbiya', 'ru': 'Колумбия', 'en': 'Colombia', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Afrikadagi eng koʻp aholiga ega qaysi davlat?',
        'ru': 'Какая страна в Африке самая населённая?',
        'en': 'Which African country has the largest population?',
      },
      'options': [
        {'uz': 'Misr', 'ru': 'Египет', 'en': 'Egypt', 'isCorrect': false},
        {'uz': 'JAR', 'ru': 'ЮАР', 'en': 'South Africa', 'isCorrect': false},
        {'uz': 'Nigeriya', 'ru': 'Нигерия', 'en': 'Nigeria', 'isCorrect': true},
        {'uz': 'Efiopiya', 'ru': 'Эфиопия', 'en': 'Ethiopia', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Qaysi davlat eng uzun qirgʻoq chizigʻiga ega?',
        'ru': 'У какой страны самая длинная береговая линия?',
        'en': 'Which country has the longest coastline?',
      },
      'options': [
        {'uz': 'Rossiya', 'ru': 'Россия', 'en': 'Russia', 'isCorrect': false},
        {'uz': 'Avstraliya', 'ru': 'Австралия', 'en': 'Australia', 'isCorrect': false},
        {'uz': 'Kanada', 'ru': 'Канада', 'en': 'Canada', 'isCorrect': true},
        {'uz': 'Indoneziya', 'ru': 'Индонезия', 'en': 'Indonesia', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Vatikan qaysi shahar ichida joylashgan?',
        'ru': 'В каком городе расположен Ватикан?',
        'en': 'In which city is the Vatican located?',
      },
      'options': [
        {'uz': 'Neapol', 'ru': 'Неаполь', 'en': 'Naples', 'isCorrect': false},
        {'uz': 'Rim', 'ru': 'Рим', 'en': 'Rome', 'isCorrect': true},
        {'uz': 'Milan', 'ru': 'Милан', 'en': 'Milan', 'isCorrect': false},
        {'uz': 'Florensiya', 'ru': 'Флоренция', 'en': 'Florence', 'isCorrect': false},
      ],
    },
  ];

  final List<Map<String, dynamic>> _qitalarQuestions = [
    {
      'question': {
        'uz': "Eng katta qit'a qaysi?",
        'ru': 'Какой самый большой континент?',
        'en': 'Which is the largest continent?',
      },
      'options': [
        {'uz': 'Afrika', 'ru': 'Африка', 'en': 'Africa', 'isCorrect': false},
        {'uz': 'Shimoliy Amerika', 'ru': 'Северная Америка', 'en': 'North America', 'isCorrect': false},
        {'uz': 'Yevroosiyo', 'ru': 'Евразия', 'en': 'Eurasia', 'isCorrect': true},
        {'uz': 'Janubiy Amerika', 'ru': 'Южная Америка', 'en': 'South America', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Eng kichik qit'a qaysi?",
        'ru': 'Какой самый маленький континент?',
        'en': 'Which is the smallest continent?',
      },
      'options': [
        {'uz': 'Antarktida', 'ru': 'Антарктида', 'en': 'Antarctica', 'isCorrect': false},
        {'uz': 'Avstraliya', 'ru': 'Австралия', 'en': 'Australia', 'isCorrect': true},
        {'uz': 'Janubiy Amerika', 'ru': 'Южная Америка', 'en': 'South America', 'isCorrect': false},
        {'uz': 'Yevropa', 'ru': 'Европа', 'en': 'Europe', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Qaysi qit'ada doimiy aholi yashamaydi?",
        'ru': 'На каком континенте нет постоянного населения?',
        'en': 'Which continent has no permanent population?',
      },
      'options': [
        {'uz': 'Avstraliya', 'ru': 'Австралия', 'en': 'Australia', 'isCorrect': false},
        {'uz': 'Antarktida', 'ru': 'Антарктида', 'en': 'Antarctica', 'isCorrect': true},
        {'uz': 'Shimoliy Amerika', 'ru': 'Северная Америка', 'en': 'North America', 'isCorrect': false},
        {'uz': 'Janubiy Amerika', 'ru': 'Южная Америка', 'en': 'South America', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Afrika qit'asini Yevroosiyodan ajratib turuvchi kanal?",
        'ru': 'Какой канал отделяет Африку от Евразии?',
        'en': 'Which canal separates Africa from Eurasia?',
      },
      'options': [
        {'uz': 'Panama kanali', 'ru': 'Панамский канал', 'en': 'Panama Canal', 'isCorrect': false},
        {'uz': 'Suvaysh kanali', 'ru': 'Суэцкий канал', 'en': 'Suez Canal', 'isCorrect': true},
        {'uz': 'Grand Kanal', 'ru': 'Великий канал', 'en': 'Grand Canal', 'isCorrect': false},
        {'uz': 'Kiel kanali', 'ru': 'Кильский канал', 'en': 'Kiel Canal', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Eng baland cho'qqi (Everest) qaysi qit'ada joylashgan?",
        'ru': 'На каком континенте находится высшая вершина (Эверест)?',
        'en': 'On which continent is the highest peak (Everest) located?',
      },
      'options': [
        {'uz': 'Afrika', 'ru': 'Африка', 'en': 'Africa', 'isCorrect': false},
        {'uz': 'Yevroosiyo', 'ru': 'Евразия', 'en': 'Eurasia', 'isCorrect': true},
        {'uz': 'Shimoliy Amerika', 'ru': 'Северная Америка', 'en': 'North America', 'isCorrect': false},
        {'uz': 'Janubiy Amerika', 'ru': 'Южная Америка', 'en': 'South America', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Amazonka daryosi qaysi qit'ada oqadi?",
        'ru': 'В каком континенте протекает река Амазонка?',
        'en': 'On which continent does the Amazon River flow?',
      },
      'options': [
        {'uz': 'Afrika', 'ru': 'Африка', 'en': 'Africa', 'isCorrect': false},
        {'uz': 'Shimoliy Amerika', 'ru': 'Северная Америка', 'en': 'North America', 'isCorrect': false},
        {'uz': 'Janubiy Amerika', 'ru': 'Южная Америка', 'en': 'South America', 'isCorrect': true},
        {'uz': 'Yevroosiyo', 'ru': 'Евразия', 'en': 'Eurasia', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Sahroi Kabir cho'li qaysi qit'ada joylashgan?",
        'ru': 'На каком континенте расположена пустыня Сахара?',
        'en': 'On which continent is the Sahara Desert located?',
      },
      'options': [
        {'uz': 'Osiyo', 'ru': 'Азия', 'en': 'Asia', 'isCorrect': false},
        {'uz': 'Avstraliya', 'ru': 'Австралия', 'en': 'Australia', 'isCorrect': false},
        {'uz': 'Afrika', 'ru': 'Африка', 'en': 'Africa', 'isCorrect': true},
        {'uz': 'Janubiy Amerika', 'ru': 'Южная Америка', 'en': 'South America', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Qaysi qit'a «Yashil qit'a» deb ham ataladi?",
        'ru': 'Какой континент также называют «зелёным континентом»?',
        'en': 'Which continent is also called the "Green Continent"?',
      },
      'options': [
        {'uz': 'Yevropa', 'ru': 'Европа', 'en': 'Europe', 'isCorrect': false},
        {'uz': 'Shimoliy Amerika', 'ru': 'Северная Америка', 'en': 'North America', 'isCorrect': false},
        {'uz': 'Avstraliya', 'ru': 'Австралия', 'en': 'Australia', 'isCorrect': true},
        {'uz': 'Osiyo', 'ru': 'Азия', 'en': 'Asia', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Nil daryosi qaysi qit'ada?",
        'ru': 'На каком континенте река Нил?',
        'en': 'On which continent is the Nile River?',
      },
      'options': [
        {'uz': 'Janubiy Amerika', 'ru': 'Южная Америка', 'en': 'South America', 'isCorrect': false},
        {'uz': 'Afrika', 'ru': 'Африка', 'en': 'Africa', 'isCorrect': true},
        {'uz': 'Osiyo', 'ru': 'Азия', 'en': 'Asia', 'isCorrect': false},
        {'uz': 'Yevropa', 'ru': 'Европа', 'en': 'Europe', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Pingvinlar asosan qaysi qit'a/hududda yashaydi?",
        'ru': 'В каком основном регионе обитают пингвины?',
        'en': 'In which main continent/region do penguins mainly live?',
      },
      'options': [
        {'uz': 'Arktika', 'ru': 'Арктика', 'en': 'Arctic', 'isCorrect': false},
        {'uz': 'Antarktida', 'ru': 'Антарктида', 'en': 'Antarctica', 'isCorrect': true},
        {'uz': 'Grenlandiya', 'ru': 'Гренландия', 'en': 'Greenland', 'isCorrect': false},
        {'uz': 'Alyaska', 'ru': 'Аляска', 'en': 'Alaska', 'isCorrect': false},
      ],
    },
  ];

  final List<Map<String, dynamic>> _poytaxtlarQuestions = [
    {
      'question': {
        'uz': "O'zbekiston poytaxti qaysi?",
        'ru': 'Какова столица Узбекистана?',
        'en': 'What is the capital of Uzbekistan?',
      },
      'options': [
        {'uz': 'Toshkent', 'ru': 'Ташкент', 'en': 'Tashkent', 'isCorrect': true},
        {'uz': 'Samarqand', 'ru': 'Самарканд', 'en': 'Samarkand', 'isCorrect': false},
        {'uz': 'Buxoro', 'ru': 'Бухара', 'en': 'Bukhara', 'isCorrect': false},
        {'uz': 'Andijon', 'ru': 'Андижан', 'en': 'Andijan', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'AQSh poytaxti?',
        'ru': 'Столица США?',
        'en': 'Capital of the USA?',
      },
      'options': [
        {'uz': 'Nyu-York', 'ru': 'Нью-Йорк', 'en': 'New York', 'isCorrect': false},
        {'uz': 'Vashington', 'ru': 'Вашингтон', 'en': 'Washington D.C.', 'isCorrect': true},
        {'uz': 'Los-Anjeles', 'ru': 'Лос-Анджелес', 'en': 'Los Angeles', 'isCorrect': false},
        {'uz': 'Chikago', 'ru': 'Чикаго', 'en': 'Chicago', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Turkiya poytaxti?',
        'ru': 'Столица Турции?',
        'en': 'Capital of Turkey?',
      },
      'options': [
        {'uz': 'Istanbul', 'ru': 'Стамбул', 'en': 'Istanbul', 'isCorrect': false},
        {'uz': 'Izmir', 'ru': 'Измир', 'en': 'Izmir', 'isCorrect': false},
        {'uz': 'Anqara', 'ru': 'Анкара', 'en': 'Ankara', 'isCorrect': true},
        {'uz': 'Antaliya', 'ru': 'Анталья', 'en': 'Antalya', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Fransiya poytaxti?',
        'ru': 'Столица Франции?',
        'en': 'Capital of France?',
      },
      'options': [
        {'uz': 'Lion', 'ru': 'Лион', 'en': 'Lyon', 'isCorrect': false},
        {'uz': 'Marsel', 'ru': 'Марсель', 'en': 'Marseille', 'isCorrect': false},
        {'uz': 'Parij', 'ru': 'Париж', 'en': 'Paris', 'isCorrect': true},
        {'uz': 'Nitssa', 'ru': 'Ницца', 'en': 'Nice', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Yaponiya poytaxti?',
        'ru': 'Столица Японии?',
        'en': 'Capital of Japan?',
      },
      'options': [
        {'uz': 'Seul', 'ru': 'Сеул', 'en': 'Seoul', 'isCorrect': false},
        {'uz': 'Pekin', 'ru': 'Пекин', 'en': 'Beijing', 'isCorrect': false},
        {'uz': 'Tokio', 'ru': 'Токио', 'en': 'Tokyo', 'isCorrect': true},
        {'uz': 'Osaka', 'ru': 'Осака', 'en': 'Osaka', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': "Qozog'iston poytaxti?",
        'ru': 'Столица Казахстана?',
        'en': 'Capital of Kazakhstan?',
      },
      'options': [
        {'uz': 'Olmaota', 'ru': 'Алматы', 'en': 'Almaty', 'isCorrect': false},
        {'uz': 'Astana', 'ru': 'Астана', 'en': 'Astana', 'isCorrect': true},
        {'uz': 'Chimkent', 'ru': 'Шымкент', 'en': 'Shymkent', 'isCorrect': false},
        {'uz': 'Turkiston', 'ru': 'Туркестан', 'en': 'Turkistan', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Germaniya poytaxti?',
        'ru': 'Столица Германии?',
        'en': 'Capital of Germany?',
      },
      'options': [
        {'uz': 'Myunxen', 'ru': 'Мюнхен', 'en': 'Munich', 'isCorrect': false},
        {'uz': 'Gamburg', 'ru': 'Гамбург', 'en': 'Hamburg', 'isCorrect': false},
        {'uz': 'Berlin', 'ru': 'Берлин', 'en': 'Berlin', 'isCorrect': true},
        {'uz': 'Frankfurt', 'ru': 'Франкфурт', 'en': 'Frankfurt', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Braziliya poytaxti?',
        'ru': 'Столица Бразилии?',
        'en': 'Capital of Brazil?',
      },
      'options': [
        {'uz': 'Rio-de-Janeyro', 'ru': 'Рио-де-Жанейро', 'en': 'Rio de Janeiro', 'isCorrect': false},
        {'uz': 'San-Paulu', 'ru': 'Сан-Паулу', 'en': 'São Paulo', 'isCorrect': false},
        {'uz': 'Brazilia', 'ru': 'Бразилиа', 'en': 'Brasília', 'isCorrect': true},
        {'uz': 'Salvador', 'ru': 'Сальвадор', 'en': 'Salvador', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Xitoy poytaxti?',
        'ru': 'Столица Китая?',
        'en': 'Capital of China?',
      },
      'options': [
        {'uz': 'Shanxay', 'ru': 'Шанхай', 'en': 'Shanghai', 'isCorrect': false},
        {'uz': 'Gonkong', 'ru': 'Гонконг', 'en': 'Hong Kong', 'isCorrect': false},
        {'uz': 'Pekin', 'ru': 'Пекин', 'en': 'Beijing', 'isCorrect': true},
        {'uz': 'Urumchi', 'ru': 'Урумчи', 'en': 'Urumqi', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Misr poytaxti?',
        'ru': 'Столица Египта?',
        'en': 'Capital of Egypt?',
      },
      'options': [
        {'uz': 'Iskandariya', 'ru': 'Александрия', 'en': 'Alexandria', 'isCorrect': false},
        {'uz': 'Qohira', 'ru': 'Каир', 'en': 'Cairo', 'isCorrect': true},
        {'uz': 'Luksor', 'ru': 'Луксор', 'en': 'Luxor', 'isCorrect': false},
        {'uz': 'Giza', 'ru': 'Гиза', 'en': 'Giza', 'isCorrect': false},
      ],
    },
  ];

  final List<Map<String, dynamic>> _iqlimObhavoQuestions = [
    {
      'question': {
        'uz': 'O\'zbekistondagi o\'rtacha yillik harorat qanday hisoblanadi?',
        'ru': 'Какой среднегодовой температуры в Узбекистане?',
        'en': 'What is the average annual temperature in Uzbekistan (approx.)?',
      },
      'options': [
        {'uz': '+8°C', 'ru': '+8°C', 'en': '+8°C', 'isCorrect': false},
        {'uz': '+14°C', 'ru': '+14°C', 'en': '+14°C', 'isCorrect': true},
        {'uz': '+22°C', 'ru': '+22°C', 'en': '+22°C', 'isCorrect': false},
        {'uz': '0°C', 'ru': '0°C', 'en': '0°C', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Eng yuqori harorat +45°C qaysi shahar yon-atrofida kuzatilgan?',
        'ru': 'Где зафиксирован максимум +45°C?',
        'en': 'Where was the record high of +45°C registered?',
      },
      'options': [
        {'uz': 'Samarqand', 'ru': 'Самарканд', 'en': 'Samarkand', 'isCorrect': false},
        {'uz': 'Termiz', 'ru': 'Термез', 'en': 'Termez', 'isCorrect': true},
        {'uz': 'Nukus', 'ru': 'Нукус', 'en': 'Nukus', 'isCorrect': false},
        {'uz': 'Toshkent', 'ru': 'Ташкент', 'en': 'Tashkent', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Eng sovuq harorat -30°C qayerda kuzatiladi (statistikada)?',
        'ru': 'Где в статистике минимум около -30°C?',
        'en': 'Where is about -30°C (statistics) most typical?',
      },
      'options': [
        {'uz': 'Vodiy o\'lkanlarida', 'ru': 'В долинах', 'en': 'In lowlands', 'isCorrect': false},
        {'uz': 'Tog\'larda', 'ru': 'В горах', 'en': 'In the mountains', 'isCorrect': true},
        {'uz': 'Cho\'llarda', 'ru': 'В пустыне', 'en': 'In deserts', 'isCorrect': false},
        {'uz': "Orol bo'yida", 'ru': 'У Арала', 'en': 'Near the Aral', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Yiliga o\'rtacha yog\'in miqdori (mm) qaysi oraliqda keltiriladi?',
        'ru': 'Среднегодовые осадки (мм) в каком диапазоне?',
        'en': 'Annual precipitation (mm) falls in which range?',
      },
      'options': [
        {'uz': '20–50 mm/yil', 'ru': '20–50 мм/год', 'en': '20–50 mm/year', 'isCorrect': false},
        {'uz': '100–500 mm/yil', 'ru': '100–500 мм/год', 'en': '100–500 mm/year', 'isCorrect': true},
        {'uz': '2000+ mm/yil', 'ru': '2000+ мм/год', 'en': '2000+ mm/year', 'isCorrect': false},
        {'uz': '0 mm', 'ru': '0 мм', 'en': '0 mm', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Yilda taxminan necha kun quyoshli (statistikadagi oraliq)?',
        'ru': 'Сколько солнечных дней в год (в диапазоне)?',
        'en': 'How many sunny days per year (range)?',
      },
      'options': [
        {'uz': '50–80 kun', 'ru': '50–80 дн.', 'en': '50–80 days', 'isCorrect': false},
        {'uz': '100–150 kun', 'ru': '100–150 дн.', 'en': '100–150 days', 'isCorrect': false},
        {'uz': '260–300 kun', 'ru': '260–300 дн.', 'en': '260–300 days', 'isCorrect': true},
        {'uz': '400+ kun', 'ru': '400+ дн.', 'en': '400+ days', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Iqlim zonalari bo\'yicha issiq, mo\'tadil, sovuq bo\'linish nimaga asoslanadi?',
        'ru': 'На чём строятся теплый, умеренный, холодный пояса?',
        'en': 'What are warm/temperate/cold climate belts mainly based on?',
      },
      'options': [
        {'uz': 'Faqat dengiz sathiga', 'ru': 'Только на высоте уровня моря', 'en': 'Only sea level', 'isCorrect': false},
        {
          'uz': 'Ekvatordan qutblarga masofa va kenglik',
          'ru': 'Расстояние от экватора',
          'en': 'Latitude / distance from the equator',
          'isCorrect': true
        },
        {'uz': 'Faqat shamol', 'ru': 'Только ветер', 'en': 'Wind only', 'isCorrect': false},
        {'uz': 'Faqat vegetatsiya', 'ru': 'Только растительность', 'en': 'Vegetation only', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Global isish (global warming) qaysi muammoga bevosita bog\'liq?',
        'ru': 'Глобальное потепление связано с…',
        'en': 'Global warming is most directly linked to…',
      },
      'options': [
        {
          'uz': 'Gaz etuvchi qatlamlarning oshishi',
          'ru': 'Парниковых газов',
          'en': 'Increased greenhouse gases',
          'isCorrect': true
        },
        {'uz': 'Faqat oy fazasi', 'ru': 'Только фазой Луны', 'en': 'Moon phase only', 'isCorrect': false},
        {'uz': 'Dengiz chuqurligi', 'ru': 'Глубиной моря', 'en': 'Ocean depth', 'isCorrect': false},
        {'uz': 'Faqat yer silkinishi', 'ru': 'Только землетрясениями', 'en': 'Earthquakes only', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Tornado va kuchli bo\'ron qanday sifatga kiradi?',
        'ru': 'Торнадо и сильные бури — это…',
        'en': 'A tornado and severe storm are best described as…',
      },
      'options': [
        {
          'uz': 'Iqlim zonasi turi',
          'ru': 'Тип клим. зоны',
          'en': 'A climate zone type',
          'isCorrect': false
        },
        {
          'uz': 'Xavfli ob-havo hodisasi',
          'ru': 'Опасные явления',
          'en': 'Dangerous weather events',
          'isCorrect': true
        },
        {
          'uz': 'Dengiz o\'qimi turi',
          'ru': 'Тип течения',
          'en': 'Ocean current type',
          'isCorrect': false
        },
        {'uz': 'Mineral', 'ru': 'Минерал', 'en': 'A mineral', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Ob-havoni uzoq muddatli prognoz (hafta va undan yuqori) qaysi yondashuv bilan ishlanadi?',
        'ru': 'Как делают долгий прогноз погоды?',
        'en': 'How are medium/long-range weather forecasts made?',
      },
      'options': [
        {
          'uz': 'Faqat telefon kamerasi',
          'ru': 'Только камерой',
          'en': 'Phone camera only',
          'isCorrect': false
        },
        {
          'uz': 'Meteorologik modellar va stansiyalar',
          'ru': 'Модели и станции',
          'en': 'Models and weather stations',
          'isCorrect': true
        },
        {
          'uz': 'Faqat barometr uyda',
          'ru': 'Дом. барометр',
          'en': 'Home barometer only',
          'isCorrect': false
        },
        {
          'uz': 'Faqat qo\'l bilan',
          'ru': 'Вручную',
          'en': 'By hand only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Shahar markazida harorat odatda atrof-muhitga nisbatan yuqorimi?',
        'ru': 'В центре города температура обычно выше?',
        'en': 'Is a city center usually warmer than the surroundings?',
      },
      'options': [
        {'uz': 'Ha (issiq orol effekti)', 'ru': 'Да (остров тепла)', 'en': 'Yes (heat island)', 'isCorrect': true},
        {'uz': 'Yo\'q, har doim sovuqroq', 'ru': 'Всегда холоднее', 'en': 'No, always colder', 'isCorrect': false},
        {'uz': "Harorat bo'yicha farq bo'lmaydi", 'ru': 'Нет разницы', 'en': 'No difference', 'isCorrect': false},
        {
          'uz': 'Faqat qishda yuqoriroq',
          'ru': 'Только зимой выше',
          'en': 'Only higher in winter',
          'isCorrect': false
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _togJinslariQuestions = [
    {
      'question': {
        'uz': 'O\'zbekistonning qancha qismi tog\'li (taxminan)?',
        'ru': 'Какую часть площади (прибл.) занимают горы в Узбекистане?',
        'en': 'Roughly what share of Uzbekistan is mountainous?',
      },
      'options': [
        {'uz': '~5%', 'ru': '~5%', 'en': '~5%', 'isCorrect': false},
        {'uz': '~20%', 'ru': '~20%', 'en': '~20%', 'isCorrect': true},
        {'uz': '~50%', 'ru': '~50%', 'en': '~50%', 'isCorrect': false},
        {'uz': '~80%', 'ru': '~80%', 'en': '~80%', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'O\'zbekistondagi eng baland cho\'qqi (Adelunga) qancha metr? (Tyan-Shan)',
        'ru': 'Высшая вершина (Адельунга) в м (Тянь-Шань)?',
        'en': 'Adelunga peak (Tien Shan) height in meters?',
      },
      'options': [
        {'uz': '2,169 m', 'ru': '2 169 м', 'en': '2,169 m', 'isCorrect': false},
        {'uz': '3,769 m', 'ru': '3 769 м', 'en': '3,769 m', 'isCorrect': false},
        {'uz': '4,301 m', 'ru': '4 301 м', 'en': '4,301 m', 'isCorrect': true},
        {'uz': '1,500 m', 'ru': '1 500 м', 'en': '1,500 m', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Tyan-Shan tizilidagi cho\'qqilar uchun berilgan maksimal balandlik (skrin) qaysi?',
        'ru': 'Какой макс. ориентир для Тянь-Шаня (по данным курса)?',
        'en': 'Which max height (course data) is given for the Tien Shan here?',
      },
      'options': [
        {'uz': '922 m', 'ru': '922 м', 'en': '922 m', 'isCorrect': false},
        {'uz': '1,500 m', 'ru': '1 500 м', 'en': '1,500 m', 'isCorrect': false},
        {'uz': '4,301 m', 'ru': '4 301 м', 'en': '4,301 m', 'isCorrect': true},
        {'uz': '4,600 m', 'ru': '4 600 м', 'en': '4,600 m', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Pamir-Oloy tizilari uchun qaysi cho\'qqi balandligi berilgan?',
        'ru': 'Какой показатель высоты для Памиро-Алая в материалах?',
        'en': 'Which peak height is given for Pamir–Alay in this material?',
      },
      'options': [
        {'uz': '922 m', 'ru': '922 м', 'en': '922 m', 'isCorrect': false},
        {'uz': '2,169 m', 'ru': '2 169 м', 'en': '2,169 m', 'isCorrect': false},
        {'uz': '3,769 m', 'ru': '3 769 м', 'en': '3,769 m', 'isCorrect': false},
        {'uz': '4,600 m', 'ru': '4 600 м', 'en': '4,600 m', 'isCorrect': true},
      ],
    },
    {
      'question': {
        'uz': 'Nurota tog\'lari maksimal balandligi necha metr?',
        'ru': 'Максимальная высота Нуратинских гор (м)?',
        'en': 'Max height of Nurata ranges in meters?',
      },
      'options': [
        {'uz': '922 m', 'ru': '922 м', 'en': '922 m', 'isCorrect': false},
        {'uz': '1,500 m', 'ru': '1 500 м', 'en': '1,500 m', 'isCorrect': false},
        {'uz': '2,169 m', 'ru': '2 169 м', 'en': '2,169 m', 'isCorrect': true},
        {'uz': '3,769 m', 'ru': '3 769 м', 'en': '3,769 m', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Kopetdog\' tog\'lari maksimal balandligi (taxmin) necha metr?',
        'ru': 'Высотный ориентир Копетдага (м)?',
        'en': 'Approximate max height of Kopet Dag (m)?',
      },
      'options': [
        {'uz': '922 m', 'ru': '922 м', 'en': '922 m', 'isCorrect': false},
        {'uz': '1,500 m', 'ru': '1 500 м', 'en': '1,500 m', 'isCorrect': true},
        {'uz': '2,169 m', 'ru': '2 169 м', 'en': '2,169 m', 'isCorrect': false},
        {'uz': '4,301 m', 'ru': '4 301 м', 'en': '4,301 m', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Qoratov tog\'larining maksimal balandligi necha m?',
        'ru': 'Макс. высота Каратау (м)?',
        'en': 'Max height of Karatau ranges (m)?',
      },
      'options': [
        {'uz': '922 m', 'ru': '922 м', 'en': '922 m', 'isCorrect': true},
        {'uz': '1,500 m', 'ru': '1 500 м', 'en': '1,500 m', 'isCorrect': false},
        {'uz': '2,169 m', 'ru': '2 169 м', 'en': '2,169 m', 'isCorrect': false},
        {'uz': '3,769 m', 'ru': '3 769 м', 'en': '3,769 m', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Qurama tog\'larining maksimal balandligi (taxmin) necha m?',
        'ru': 'Ориентир высоты Курама (м)?',
        'en': 'Approx. max height of Kurama (m)?',
      },
      'options': [
        {'uz': '2,169 m', 'ru': '2 169 м', 'en': '2,169 m', 'isCorrect': false},
        {'uz': '3,769 m', 'ru': '3 769 м', 'en': '3,769 m', 'isCorrect': true},
        {'uz': '4,300 m', 'ru': '4 300 м', 'en': '4,300 m', 'isCorrect': false},
        {'uz': '4,600 m', 'ru': '4 600 м', 'en': '4,600 m', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Materiallar bo\'yicha O\'zbekistondagi asosiy tog\' tizimlarini belgilang.',
        'ru': 'Укажите основные горные системы (по материалу).',
        'en': 'Which are the two main systems named in the material?',
      },
      'options': [
        {'uz': 'Nurota va Qoratov', 'ru': 'Нурата и Каратау', 'en': 'Nurata and Karatau', 'isCorrect': false},
        {'uz': 'Tyan-Shan va Pamir-Oloy', 'ru': 'Тянь-Шань и Памиро-Алай', 'en': 'Tien Shan and Pamir–Alay', 'isCorrect': true},
        {'uz': 'Farg\'ona va Ustyurt', 'ru': 'Фергана и Устюрт', 'en': 'Fergana and Ustyurt', 'isCorrect': false},
        {'uz': 'Hind va Atlant', 'ru': 'Гималаи', 'en': 'Himalayas', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'O\'zbekistondagi muzliklarning yig\'indiy maydoni (taxmin) necha km²?',
        'ru': 'Совокупная площадь ледников (прибл., км²)?',
        'en': 'Total glacier area in Uzbekistan (approx., km²)?',
      },
      'options': [
        {'uz': '50 km²', 'ru': '50 км²', 'en': '50 km²', 'isCorrect': false},
        {'uz': '~200 km²', 'ru': '~200 км²', 'en': '~200 km²', 'isCorrect': false},
        {'uz': '~650 km²', 'ru': '~650 км²', 'en': '~650 km²', 'isCorrect': true},
        {'uz': '5,000 km²', 'ru': '5 000 км²', 'en': '5,000 km²', 'isCorrect': false},
      ],
    },
  ];

  final List<Map<String, dynamic>> _foydaliQazilmalarQuestions = [
    {
      'question': {
        'uz': 'Materiallar bo\'yicha O\'zbekistonda nechta turdagi foydali qazilma o\'rganilgan (taxmin son)?',
        'ru': 'Сколько видов полезных ископаемых (порядок)?',
        'en': 'Order of registered mineral types in Uzbekistan (approx.)?',
      },
      'options': [
        {'uz': '10 dan ortiq', 'ru': '10+', 'en': '10+', 'isCorrect': false},
        {'uz': '100+ tur', 'ru': '100+ видов', 'en': '100+ types', 'isCorrect': true},
        {'uz': '15 ta aniq', 'ru': 'Ровно 15', 'en': 'Exactly 15', 'isCorrect': false},
        {'uz': '5 ta guruh', 'ru': '5 групп', 'en': '5 groups', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Mamlakatda (material bo\'yicha) taxminan nechta kon va konchilik maydonlari ro\'yxatga olingan?',
        'ru': 'Сколько рудников/месторождений (порядок) по материалу?',
        'en': 'Approx. how many mining sites in the data?',
      },
      'options': [
        {'uz': '100+', 'ru': '100+', 'en': '100+', 'isCorrect': false},
        {'uz': '2,000+', 'ru': '2 000+', 'en': '2,000+', 'isCorrect': true},
        {'uz': '10,000+', 'ru': '10 000+', 'en': '10,000+', 'isCorrect': false},
        {'uz': '200 ta', 'ru': '200', 'en': '200', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Jahon bo\'yicha oltin qazib olish hajmida O\'zbekiston taxminan nechanchi o\'rinda (material)?',
        'ru': 'Место Узбекистана по добыче золота (по курсу)?',
        'en': 'Uzbekistan’s world rank in gold output (as given)?',
      },
      'options': [
        {'uz': '1-o\'rin', 'ru': '1-е', 'en': '1st', 'isCorrect': false},
        {'uz': '4-o\'rin', 'ru': '4-е', 'en': '4th', 'isCorrect': true},
        {'uz': '7-o\'rin', 'ru': '7-е', 'en': '7th', 'isCorrect': false},
        {'uz': '10-o\'rin', 'ru': '10-е', 'en': '10th', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Jahon bo\'yicha uran resurslariga ko\'ra O\'zbekiston taxminan nechanchi o\'rinda (material)?',
        'ru': 'Место по урану (как в курсе)?',
        'en': 'Uzbekistan’s world rank in uranium (as in the data)?',
      },
      'options': [
        {'uz': '4-o\'rin', 'ru': '4-е', 'en': '4th', 'isCorrect': false},
        {'uz': '5-o\'rin', 'ru': '5-е', 'en': '5th', 'isCorrect': false},
        {'uz': '7-o\'rin', 'ru': '7-е', 'en': '7th', 'isCorrect': true},
        {'uz': '1-o\'rin', 'ru': '1-е', 'en': '1st', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Mis qaysi turdagi foydali qazilma sifatida tasniflanadi (material bo\'yicha)?',
        'ru': 'Как классифицируется медь (по слайду)?',
        'en': 'Copper is classified in the material as…',
      },
      'options': [
        {
          'uz': 'Energiya resursi',
          'ru': 'Энергоресурс',
          'en': 'Energy resource',
          'isCorrect': false
        },
        {
          'uz': 'Rangli metall',
          'ru': 'Цветной металл',
          'en': 'Non-ferrous metal',
          'isCorrect': true
        },
        {'uz': 'Qimmatbaho metall', 'ru': 'Драгмет', 'en': 'Precious metal', 'isCorrect': false},
        {
          'uz': 'Faqat qurilish',
          'ru': 'Только нерудка',
          'en': 'Non-metallics only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Tabiiy gaz va neft dars matnida qanday sifatda ko\'rsatilgan?',
        'ru': 'Как в тексте называют газ и нефть?',
        'en': 'Gas and oil are called what in the sheet?',
      },
      'options': [
        {'uz': 'Rangli metall', 'ru': 'Цветной металл', 'en': 'Non-ferrous', 'isCorrect': false},
        {
          'uz': 'Energiya resursi',
          'ru': 'Энергетический ресурс',
          'en': 'Energy resource',
          'isCorrect': true
        },
        {'uz': 'Radioaktiv', 'ru': 'Радиоактивный', 'en': 'Radioactive', 'isCorrect': false},
        {'uz': 'Qurilish', 'ru': 'Нерудка', 'en': 'Non-metallics', 'isCorrect': false},
      ],
    },
    {
      'question': {
        'uz': 'Ko\'mir qanday sifatda keltirilgan?',
        'ru': 'Как в материале классифицируется уголь?',
        'en': 'Coal is given as which type in the data?',
      },
      'options': [
        {
          'uz': 'Energiya resursi',
          'ru': 'Энергоресурс',
          'en': 'Energy',
          'isCorrect': false
        },
        {
          'uz': 'Qattiq yoqilg\'i',
          'ru': 'Твёрдое топливо',
          'en': 'Solid fuel',
          'isCorrect': true
        },
        {'uz': 'Rangli metall', 'ru': 'Цветной металл', 'en': 'Non-ferrous', 'isCorrect': false},
        {
          'uz': 'Faqat tuz',
          'ru': 'Только соль',
          'en': 'Salt only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Uranning sinfini belgilang (material).',
        'ru': 'Каким типом в материале является уран?',
        'en': 'Uranium is which material type in the list?',
      },
      'options': [
        {
          'uz': 'Energiya resursi',
          'ru': 'Энергоресурс',
          'en': 'Energy',
          'isCorrect': false
        },
        {
          'uz': 'Radioaktiv metall',
          'ru': 'Радиоактивный металл',
          'en': 'Radioactive metal',
          'isCorrect': true
        },
        {
          'uz': 'Nometall',
          'ru': 'Неруд',
          'en': 'Non-metallics',
          'isCorrect': false
        },
        {
          'uz': 'Faqat qimmatbaho',
          'ru': 'Драгмет',
          'en': 'Precious only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Statistika qatorida keltirilgan asosiy eksport tovarlari qaysilar?',
        'ru': 'Какие ключевые экспорты (по слайду)?',
        'en': 'Key exports in the stat box (per the material)?',
      },
      'options': [
        {
          'uz': 'Faqat neft va shisha',
          'ru': 'Только нефть и стекло',
          'en': 'Oil and glass only',
          'isCorrect': false
        },
        {
          'uz': 'Oltin, mis, gaz',
          'ru': 'Золото, медь, газ',
          'en': 'Gold, copper, gas',
          'isCorrect': true
        },
        {
          'uz': 'Faqat ko\'mir',
          'ru': 'Только уголь',
          'en': 'Coal only',
          'isCorrect': false
        },
        {
          'uz': 'Faqat uran',
          'ru': 'Только уран',
          'en': 'Uranium only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Qurilish materiallari dars matnida qanday sifatda ko\'rsatilgan?',
        'ru': 'Как в тексте называют стройматериалы (по курсу)?',
        'en': 'Construction materials are which category in the text?',
      },
      'options': [
        {
          'uz': 'Energiya resursi',
          'ru': 'Энергоресурс',
          'en': 'Energy',
          'isCorrect': false
        },
        {
          'uz': 'Nometallar (nometal)',
          'ru': 'Неруд (неметаллы)',
          'en': 'Non-metallics (nonmetals)',
          'isCorrect': true
        },
        {
          'uz': 'Qimmatbaho metall',
          'ru': 'Драгмет',
          'en': 'Precious',
          'isCorrect': false
        },
        {
          'uz': 'Radioaktiv',
          'ru': 'Радиоактивный',
          'en': 'Radioactive',
          'isCorrect': false
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _relyefTurlariQuestions = [
    {
      'question': {
        'uz': 'Statistikaga ko\'ra, O\'zbekistonning eng baland nuqtasi (nom va balandlik)?',
        'ru': 'Самая высокая точка (название и высота)?',
        'en': 'The highest point (name and elevation) in the stats is:',
      },
      'options': [
        {
          'uz': 'Kopetdog\' (1,500 m)',
          'ru': 'Копетдаг (1 500 м)',
          'en': 'Kopet Dag (1,500 m)',
          'isCorrect': false
        },
        {
          'uz': 'Adelunga (4,301 m)',
          'ru': 'Адельунга (4 301 м)',
          'en': 'Adelunga (4,301 m)',
          'isCorrect': true
        },
        {
          'uz': 'Nurota (2,169 m)',
          'ru': 'Нуратa (2 169 м)',
          'en': 'Nurata (2,169 m)',
          'isCorrect': false
        },
        {
          'uz': 'Orol (0 m)',
          'ru': 'Аральское море (0 м)',
          'en': 'Aral (0 m)',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Mamlakatdagi eng past nuqta (Orol dengizi sathiga nisbatan) qanday? (material).',
        'ru': 'Самая низкая отметка (по курсу)?',
        'en': 'The lowest elevation given is about:',
      },
      'options': [
        {
          'uz': '-28 m',
          'ru': '−28 м',
          'en': '−28 m',
          'isCorrect': true
        },
        {'uz': '0 m', 'ru': '0 м', 'en': '0 m', 'isCorrect': false},
        {
          'uz': '-100 m',
          'ru': '−100 м',
          'en': '−100 m',
          'isCorrect': false
        },
        {
          'uz': '+200 m',
          'ru': '+200 м',
          'en': '+200 m',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'O\'rtacha mamlakat bo\'yicha balandlik (taxmin) qanday? (material).',
        'ru': 'Средняя высота страны (прибл.)?',
        'en': 'Mean elevation (approx.)?',
      },
      'options': [
        {
          'uz': '~200 m',
          'ru': '~200 м',
          'en': '~200 m',
          'isCorrect': false
        },
        {
          'uz': '~600 m',
          'ru': '~600 м',
          'en': '~600 m',
          'isCorrect': true
        },
        {
          'uz': '~1,200 m',
          'ru': '~1 200 м',
          'en': '~1,200 m',
          'isCorrect': false
        },
        {
          'uz': '~2,000 m',
          'ru': '~2 000 м',
          'en': '~2,000 m',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Tog\'li hududlar mamlakatning taxminan qancha qismini oladi? (material).',
        'ru': 'Какой доле территории (прибл.) занимают горы?',
        'en': 'Mountains cover roughly what share of the country?',
      },
      'options': [
        {
          'uz': '~5%',
          'ru': '~5%',
          'en': '~5%',
          'isCorrect': false
        },
        {
          'uz': '~20%',
          'ru': '~20%',
          'en': '~20%',
          'isCorrect': true
        },
        {
          'uz': '~50%',
          'ru': '~50%',
          'en': '~50%',
          'isCorrect': false
        },
        {
          'uz': '~80%',
          'ru': '~80%',
          'en': '~80%',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Tekisliklar mamlakatning taxminan necha foizini egallaydi? (material).',
        'ru': 'Какой доле (прибл.) — равнины?',
        'en': 'Plains cover roughly what share of the country?',
      },
      'options': [
        {
          'uz': '~20%',
          'ru': '~20%',
          'en': '~20%',
          'isCorrect': false
        },
        {
          'uz': '~50%',
          'ru': '~50%',
          'en': '~50%',
          'isCorrect': false
        },
        {
          'uz': '~80%',
          'ru': '~80%',
          'en': '~80%',
          'isCorrect': true
        },
        {
          'uz': '~100%',
          'ru': '~100%',
          'en': '~100%',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Farg\'ona vodiysi qaysi relyef shaklidan dalolat beradi?',
        'ru': 'Какой тип рельефа — Ферганская долина?',
        'en': 'The Fergana Valley is mainly an example of:',
      },
      'options': [
        {
          'uz': 'Cho\'l (qum)',
          'ru': 'Пустыня (песок)',
          'en': 'Desert dune',
          'isCorrect': false
        },
        {
          'uz': 'Berk/tor tog\' oralig\'idagi vodiy',
          'ru': 'Впадина между хребтами (долина)',
          'en': 'Intramontane valley',
          'isCorrect': true
        },
        {
          'uz': 'Faqat platо',
          'ru': 'Только плоскогорье',
          'en': 'Only plateau',
          'isCorrect': false
        },
        {
          'uz': 'Orol tubi',
          'ru': 'Окно дна Арала',
          'en': 'Aral depression only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'O\'zbekistondagi katta qumli cho\'l qaysi relyef turi bilan bog\'liq? (Qizilqum).',
        'ru': 'Ассоциируется с Кызылкумом тип рельефа?',
        'en': 'Kyzylkum is most associated with which relief class?',
      },
      'options': [
        {
          'uz': 'Faqat tog\' yonbag\'ri',
          'ru': 'Только горные склоны',
          'en': 'Slopes only',
          'isCorrect': false
        },
        {
          'uz': 'Cho\'l relyefi',
          'ru': 'Пустынный рельеф',
          'en': 'Desert relief',
          'isCorrect': true
        },
        {
          'uz': 'Muzlik',
          'ru': 'Ледники',
          'en': 'Glaciers',
          'isCorrect': false
        },
        {
          'uz': 'Daryo vodiysi (tor)',
          'ru': 'Низкая пойма',
          'en': 'River valley only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Ustyurt ko\'p hollarda qanday relyef sifatida ta\'riflanadi? (dars mantiqi).',
        'ru': 'Устюрт чаще всего — это',
        'en': 'Ustyurt is usually described as:',
      },
      'options': [
        {
          'uz': 'Cho\'l vodiysi',
          'ru': 'Пустынная долина',
          'en': 'Desert valley',
          'isCorrect': false
        },
        {
          'uz': 'Keng yassik (platо)',
          'ru': 'Плато, возвышенная равнина',
          'en': 'High plain / plateau',
          'isCorrect': true
        },
        {
          'uz': 'Dengiz tubi',
          'ru': 'Океаническое дно',
          'en': 'Ocean floor',
          'isCorrect': false
        },
        {
          'uz': 'Faqat cho\'kma',
          'ru': 'Только впадина',
          'en': 'Depression only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Amudaryo va Sirdaryo vodiysidagi alluvial relyef nima? (material mantiqi).',
        'ru': 'К чему относят пойменные наносы в долинах Амурдарьи и Сырдарьи?',
        'en': 'Floodplains and alluvial deposits in Amu and Syr Darya valleys are part of:',
      },
      'options': [
        {
          'uz': 'Daryo vodiysidagi relyef',
          'ru': 'Рельеф речных долин',
          'en': 'Relief in river valleys',
          'isCorrect': true
        },
        {
          'uz': 'Faqat muzlik',
          'ru': 'Только ледник',
          'en': 'Glaciers only',
          'isCorrect': false
        },
        {
          'uz': 'Faqat cho\'kma',
          'ru': 'Только пустыня',
          'en': 'Desert only',
          'isCorrect': false
        },
        {
          'uz': 'Dengiz cho\'kmasi',
          'ru': 'Океаническое дно',
          'en': 'Oceanic abyssal',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Relyefning asosiy turlaridan biri sifatida matnda qayd etilgan, lekin bitta bandda emas, qum va pasttekis aralashmasi? (cho\'l + tekislik mantiqi).',
        'ru': 'Как в материале подчёркивают сочетание пустынь и низин?',
        'en': 'The material stresses that plains and deserts together are typical. Which is correct?',
      },
      'options': [
        {
          'uz': 'Mamlakatda faqat tog\' bor',
          'ru': 'В стране только горы',
          'en': 'Only mountains',
          'isCorrect': false
        },
        {
          'uz': 'Relyef xilma-xil, cho\'l va tekisliklar uyg\'un',
          'ru': 'Рельеф разнообразен, равнины и пустыни сочетаются',
          'en': 'Diverse: plains and deserts together',
          'isCorrect': true
        },
        {
          'uz': 'Faqat muz',
          'ru': 'Только лёд',
          'en': 'Only ice',
          'isCorrect': false
        },
        {
          'uz': 'Dengiz qirg\'oqi',
          'ru': 'Морской берег',
          'en': 'Sea coast only',
          'isCorrect': false
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _tabiiyHodisalarQuestions = [
    {
      'question': {
        'uz': 'Zilzila nima? (dars mantiqi).',
        'ru': 'Землетрясение — это',
        'en': 'An earthquake is primarily:',
      },
      'options': [
        {
          'uz': 'Faqat shamol kuchayishi',
          'ru': 'Только ветер',
          'en': 'Wind only',
          'isCorrect': false
        },
        {
          'uz': 'Yer qobig\'ining seismik silkinishlari',
          'ru': 'Сейсмические колебания земной коры',
          'en': 'Seismic shaking of the crust',
          'isCorrect': true
        },
        {
          'uz': 'Faqat qurg\'oq',
          'ru': 'Только засуха',
          'en': 'Drought only',
          'isCorrect': false
        },
        {
          'uz': 'Dengiz to\'lqini',
          'ru': 'Морская волна',
          'en': 'Ocean wave',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Sel oqimlari odatda qanday vaziyatlarda yuzaga keladi? (dars).',
        'ru': 'Сели — это при прежде всего',
        'en': 'Mud/debris flows often follow:',
      },
      'options': [
        {
          'uz': 'Faqat cho\'l issig\'i',
          'ru': 'Только пустынная жара',
          'en': 'Desert heat only',
          'isCorrect': false
        },
        {
          'uz': 'Tog\' yonbag\'irlarida kuchli yomg\'ir yoki tez totuv',
          'ru': 'Сильные осадки/таяние снега на склонах',
          'en': 'Heavy rain or melt on slopes',
          'isCorrect': true
        },
        {
          'uz': 'Dengiz cho\'kishi',
          'ru': 'Отлив',
          'en': 'Tide only',
          'isCorrect': false
        },
        {
          'uz': 'Faqat tuman',
          'ru': 'Туман',
          'en': 'Fog only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Qo\'ng\'irtovlar nimaga eng ko\'p zarar yetkazadi? (dars).',
        'ru': 'Саранча в основном наносит ущерб:',
        'en': 'Locusts mainly damage:',
      },
      'options': [
        {
          'uz': 'Faqat transport yo\'llariga',
          'ru': 'Только дорогам',
          'en': 'Roads only',
          'isCorrect': false
        },
        {
          'uz': 'Qishloq xo\'jaligi va o\'simliklarga',
          'ru': 'Сельскому хозяйству и растениям',
          'en': 'Farming and vegetation',
          'isCorrect': true
        },
        {
          'uz': 'Faqat ichki suv havzalariga',
          'ru': 'Только внутренним водоёмам',
          'en': 'Inland waters only',
          'isCorrect': false
        },
        {
          'uz': 'Faqat muzliklarga',
          'ru': 'Только ледникам',
          'en': 'Glaciers only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Qurg\'oqchilik odatda nimani anglatadi? (dars).',
        'ru': 'Засуха — это',
        'en': 'Drought is mainly:',
      },
      'options': [
        {
          'uz': 'Faqat qish sovuq',
          'ru': 'Только холод',
          'en': 'Cold only',
          'isCorrect': false
        },
        {
          'uz': 'Uzoq vaqt yog\'insizlik va suv tanqisligi',
          'ru': 'Нехватка осадков и воды',
          'en': 'Long lack of rain and water',
          'isCorrect': true
        },
        {
          'uz': 'Faqat tuman',
          'ru': 'Туман',
          'en': 'Fog only',
          'isCorrect': false
        },
        {
          'uz': 'Faqat qor',
          'ru': 'Снег',
          'en': 'Snow only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Shamollar relyefga qanday ta\'sir qiladi? (dars mantiqi).',
        'ru': 'Ветер в материале — это',
        'en': 'Winds in the material mainly:',
      },
      'options': [
        {
          'uz': 'Faqat dengiz sathi',
          'ru': 'Только поверхность моря',
          'en': 'Sea surface only',
          'isCorrect': false
        },
        {
          'uz': 'Parchin, chang va eroziya',
          'ru': 'Пыль, эрозия',
          'en': 'Dust, erosion',
          'isCorrect': true
        },
        {
          'uz': 'Faqat muz yig\'ishi',
          'ru': 'Накопление льда',
          'en': 'Only ice',
          'isCorrect': false
        },
        {
          'uz': 'Tuz cho\'kmasi',
          'ru': 'Осадок соли',
          'en': 'Only salt',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Sovuq yoki issiq to\'lqinlar insonlarga nima tufayli xavf? (dars mantiqi).',
        'ru': 'Температурные волны — риск для',
        'en': 'Heat/cold waves mainly threaten:',
      },
      'options': [
        {
          'uz': 'Faqat qushlar',
          'ru': 'Только птиц',
          'en': 'Birds only',
          'isCorrect': false
        },
        {
          'uz': 'Salomatlik va ekinlar',
          'ru': 'Здоровье и урожай',
          'en': 'Health and crops',
          'isCorrect': true
        },
        {
          'uz': 'Faqat o\'rmon',
          'ru': 'Только лес',
          'en': 'Forests only',
          'isCorrect': false
        },
        {
          'uz': 'Dengiz transporti',
          'ru': 'Суда',
          'en': 'Ships only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Ko\'chki odatda qanday moyillik tufayli kuchayadi? (dars mantiqi).',
        'ru': 'Оползни чаще при',
        'en': 'Landslides are worse when slopes are:',
      },
      'options': [
        {
          'uz': 'Quruq qum',
          'ru': 'Сухом песке',
          'en': 'Very dry only',
          'isCorrect': false
        },
        {
          'uz': 'Namlanish va moyil tuproq',
          'ru': 'Насыщении водой',
          'en': 'Saturated and unstable',
          'isCorrect': true
        },
        {
          'uz': 'Dengiz kabi tekis',
          'ru': 'Плоскости',
          'en': 'Flat like sea',
          'isCorrect': false
        },
        {
          'uz': 'Faqat muz',
          'ru': 'Только лёд',
          'en': 'Ice only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Muzlik erishi iqlim o\'zgarishiga nima qo\'shadi? (dars mantiqi).',
        'ru': 'Таяние ледников меняет',
        'en': 'Melting ice mainly alters:',
      },
      'options': [
        {
          'uz': 'Faqat tuman hosil',
          'ru': 'Только туман',
          'en': 'Only fog',
          'isCorrect': false
        },
        {
          'uz': 'Suv oqimlari, muz hajmi',
          'ru': 'Сбор рек, объёмы льда',
          'en': 'Runoff and water supply',
          'isCorrect': true
        },
        {
          'uz': 'Dengiz qumini yo\'qotadi',
          'ru': 'Исчезают пустыни',
          'en': 'Deserts vanish only',
          'isCorrect': false
        },
        {
          'uz': 'Faqat cho\'kma',
          'ru': 'Только понижение',
          'en': 'Sinking only',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Darsdagi 8 xavfli va tabiiy hodisalar to\'g\'risida, qanday guruh eng ko\'p tog\' va suv bilan bog\'liq? (mantiq: sel, qo\'ng\'irtov, ko\'chki).',
        'ru': 'Связь с горами и стоком характерна для',
        'en': 'Which set is most tied to mountains and water flows?',
      },
      'options': [
        {
          'uz': 'Faqat qurg\'oq va isitma',
          'ru': 'Только жара и волны',
          'en': 'Drought and waves only',
          'isCorrect': false
        },
        {
          'uz': 'Sel, qo\'ng\'irtov, ko\'chki',
          'ru': 'Сели, обвалы, оползни',
          'en': 'Mudflow, rockfall, landslide',
          'isCorrect': true
        },
        {
          'uz': 'Faqat shamol',
          'ru': 'Только ветер',
          'en': 'Winds only',
          'isCorrect': false
        },
        {
          'uz': 'Faqat muz',
          'ru': 'Только снег',
          'en': 'Only snow',
          'isCorrect': false
        },
      ],
    },
    {
      'question': {
        'uz': 'Global isish nima? (muz erishi matni bilan uyg\'un).',
        'ru': 'Глобальное потепление относится к',
        'en': '“Global warming” in the text links to:',
      },
      'options': [
        {
          'uz': 'Faqat lokal tuman',
          'ru': 'Только туман',
          'en': 'Local fog only',
          'isCorrect': false
        },
        {
          'uz': 'Iqlim o\'zgarishi va muzlarning kichrayishi',
          'ru': 'Изменению климата и таянию',
          'en': 'Climate change and less ice',
          'isCorrect': true
        },
        {
          'uz': 'Faqat zilzila chastotasi',
          'ru': 'Только сейсмике',
          'en': 'Seismic only',
          'isCorrect': false
        },
        {
          'uz': 'Dengiz sathi har doim tushadi',
          'ru': 'Вечное понижение океанов',
          'en': 'Oceans always drop',
          'isCorrect': false
        },
      ],
    },
  ];

  late List<Map<String, dynamic>> _questions;

  Color get _accent => _isGeographyCategory(widget.category) ? AppColors.primaryCyan : AppColors.primaryPurple;

  @override
  void initState() {
    super.initState();
    final Map<String, List<Map<String, dynamic>>> categoryMap = {
      'periodic_table': _periodicQuestions,
      'siyosiy_xarita': _siyosiyXaritaQuestions,
      'qitalar': _qitalarQuestions,
      'poytaxtlar': _poytaxtlarQuestions,
      'iqlim_obhavo': _iqlimObhavoQuestions,
      'tog_jinslari': _togJinslariQuestions,
      'foydali_qazilmalar': _foydaliQazilmalarQuestions,
      'relyef_turlari': _relyefTurlariQuestions,
      'tabiiy_hodisalar': _tabiiyHodisalarQuestions,
    };
    final sourceQuestions = categoryMap[widget.category] ?? _elementsQuestions;
    if (_isGeographyCategory(widget.category)) {
      _questions = List.from(sourceQuestions);
    } else {
      _questions = List.from(sourceQuestions)..shuffle();
    }
    for (var q in _questions) {
      (q['options'] as List).shuffle();
    }
  }

  void _handleOptionSelect(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (_questions[_currentQuestionIndex]['options'][index]['isCorrect']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultPage(
          score: _score,
          total: _questions.length,
          title: widget.title,
          category: widget.category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang == 'uz' ? 'Savol ${_currentQuestionIndex + 1}/${_questions.length}' : (lang == 'ru' ? 'Вопрос ${_currentQuestionIndex + 1}/${_questions.length}' : 'Question ${_currentQuestionIndex + 1}/${_questions.length}'),
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                Text(
                  lang == 'uz' ? 'Ball: $_score' : (lang == 'ru' ? 'Балл: $_score' : 'Score: $_score'),
                  style: TextStyle(color: _accent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_accent),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              currentQuestion['question'][lang] ?? currentQuestion['question']['uz'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: (currentQuestion['options'] as List).length,
                itemBuilder: (context, index) {
                  final option = currentQuestion['options'][index];
                  final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
                  
                  Color cardColor = isDark ? AppColors.cardDark : Colors.white;
                  Color borderColor = isDark ? Colors.white10 : Colors.grey[200]!;
                  Color textColor = isDark ? Colors.white : AppColors.textPrimary;
                  Widget? trailing;

                  if (_isAnswered) {
                    if (option['isCorrect']) {
                      cardColor = Colors.green.withOpacity(isDark ? 0.2 : 0.1);
                      borderColor = Colors.green.withOpacity(0.5);
                      trailing = const Icon(Icons.check_circle, color: Colors.green);
                    } else if (_selectedOptionIndex == index) {
                      cardColor = Colors.red.withOpacity(isDark ? 0.2 : 0.1);
                      borderColor = Colors.red.withOpacity(0.5);
                      trailing = const Icon(Icons.cancel, color: Colors.red);
                    }
                  }

                  return GestureDetector(
                    onTap: () => _handleOptionSelect(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: [
                          if (!_isAnswered)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                optionLetter,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option[lang] ?? option['uz'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (trailing != null) trailing,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isAnswered ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _accent.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  _currentQuestionIndex == _questions.length - 1
                      ? (lang == 'uz' ? 'Tugatish' : (lang == 'ru' ? 'Завершить' : 'Finish'))
                      : (lang == 'uz' ? 'Keyingi' : (lang == 'ru' ? 'Следующий' : 'Next')),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizResultPage extends StatelessWidget {
  final int score;
  final int total;
  final String title;
  final String category;

  const QuizResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (score / total * 100).toInt();
    final lang = context.locale.languageCode;
    final accent = _isGeographyCategory(category) ? AppColors.primaryCyan : AppColors.primaryPurple;

    String feedback = '';
    Color feedbackColor = Colors.orange;
    if (percent >= 90) {
      feedback = lang == 'uz' ? 'Ajoyib!' : (lang == 'ru' ? 'Отлично!' : 'Excellent!');
      feedbackColor = Colors.green;
    } else if (percent >= 70) {
      feedback = lang == 'uz' ? 'Yaxshi' : (lang == 'ru' ? 'Хорошо' : 'Good');
      feedbackColor = Colors.orange;
    } else {
      feedback = lang == 'uz' ? 'Yana harakat qiling' : (lang == 'ru' ? 'Попробуйте еще раз' : 'Try again');
      feedbackColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isGeographyCategory(category) && lang == 'uz'
              ? 'Natijalar'
              : (lang == 'uz' ? 'Natija' : (lang == 'ru' ? 'Результат' : 'Result')),
        ),
        centerTitle: true,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.sentiment_satisfied_alt_rounded,
              size: 120,
              color: feedbackColor,
            ),
            const SizedBox(height: 24),
            Text(
              lang == 'uz' ? 'Sizning natijangiz' : (lang == 'ru' ? 'Ваш результат' : 'Your result'),
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              '$score / $total',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: accent),
            ),
            Text(
              '$percent%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: feedbackColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: feedbackColor.withOpacity(0.3)),
              ),
              child: Text(
                feedback,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: feedbackColor),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(title: title, category: category),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(lang == 'uz' ? 'Testni qayta ishlash' : (lang == 'ru' ? 'Пересдать тест' : 'Retake quiz')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home_rounded),
                label: Text(lang == 'uz' ? 'Bosh sahifaga qaytish' : (lang == 'ru' ? 'На главную' : 'Back to home')),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accent),
                  foregroundColor: accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

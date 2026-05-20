/// Qoraqalpogʻiston hududidagi minerallar (lokal maʼlumot).
class RegionalMineral {
  final String name;
  final String description;
  final String modelPath;
  final String quantity;
  final List<Map<String, double>> locations;
  final String referenceData;

  const RegionalMineral({
    required this.name,
    required this.description,
    required this.modelPath,
    required this.quantity,
    required this.locations,
    required this.referenceData,
  });
}

final List<RegionalMineral> regionalMinerals = [
  RegionalMineral(
    name: 'Galit',
    description: """Galit (yunoncha "als" — tuz) osh tuzi, natriy xloridning (NaCl) kristall formasi. Mineralning kristallokimyoviy tuzilishida oltita natriy kationi xlor anionini o'rab oladi. "Galit" atamasi yunoncha "galve" so'zidan kelib chiqqan bo'lib, "tuz" degan ma'noni anglatadi. Tosh tuzi, galit, osh tuzi — kimyoviy tarkibiga ko'ra NaCl (Na— 39,34%, Cl— 60,66%).

Xususiyatlari:

Galit kubik kristallar shaklida payda bo'ladi, toza holatda rangsiz va tiniq, lekin ko'pincha gil, organik moddalar, temir oksidlari bilan aralashmasi kulrang, qo'ng'ir, qizil, och va to'q ko'k, sariq va och qizil ranggacha bo'lishi mumkin. Rangi uning ifloslanganligi bilan bog'liq, shuning uchun qizg'ish rang ba'zi o'lik bakteriyalar va o'lik o'simliklarning aralashmalari, shuningdek tarkibida har qanday noorganik moddalar borligidan kelib chiqishi mumkin. Shishasimon yaltiroqlikka ega. Qattiqligi 2—2,5; zichligi 2,1—2,3 g/sm³. Suvda oson eriydi.

Qo'llanilishi:

O'rta Osiyoda yirik konlari bor. Tozalangan tuz xalq xo'jaligida keng qo'llaniladi. Tozalangan osh tuzi oziq-ovqat sifatida, konservalashda, muzlatish ishlarida, kimyo sanoatida soda, xlor, xlorid kislota va natriyning bir qator tuzlarini olishda, anilin va lak bo'yoq, to'qimachilik, farmatsevtika, metallurgiya, teri, neft sanoatlarida, plastmassalar ishlab chiqarishda, yirik tiniq kristallari optik asboblar tayyorlashda qo'llaniladi.

Joylashuvi:

Tosh tuzi (natriy xlorid) Qojaykon, Tubokat, Boybishekon, Oqqala va Qoraqalpog'istonning Barsakelmas konlaridan qazib olinadi. Qoraqalpog'istondagi “Qo'ng'irot soda zavodi” U.K.da har xil sodalar ishlab chiqarilmoqda.""",
    modelPath: 'assets/regional_minerals/minerals/galit.png',
    referenceData:
        "9-sinf kimyo, I.R. Asqarov, K. G'opirov, N.X. Toxtabayev, Toshkent \"O'zbekiston\" 2019-yil",
    quantity: "10",
    locations: [
      {"latitude": 43.68373549141366, "longitude": 59.51683861522241},
      {"latitude": 43.67720808517104, "longitude": 59.51731006015463},
      {"latitude": 43.168218, "longitude": 59.043206},
    ],
  ),
  RegionalMineral(
    name: 'Titanomagnetit',
    description:
        """Murakkab oksidlar klasiga kiruvchi mineral — tarkibida ko'p miqdorda TiO2 ning qattiq eritmasi bo'lgan magnetit turi. Fe, Ti va V larning kompleks rudasi.

Tarkibida:
Fe 50—55%; Ti 8—12%; V—0,5% gacha bo'ladi. Tabiatda ilmenitli komponentlari ko'p (37% gacha) bo'lgan magnetitlar — titanomagnetitlar juda ko'p tarqalgan. Oktaedrik kristallar, donador agregatlar, qora rangli massalar shaklida bo'ladi. Qattiqligi 5—5,5; zichligi 4,8—5,3 g/sm3.

Titanomagnetit konlari, asosan magmatik bo'lib, juda asosli jinslar, asosli va ishqorli tog' jinslari bilan bog'liq. Titanomagnetitning yirik konlari Qoraqalpog'iston Respublikasi Qorao'zak tumanida joylashgan Tebinbuloq koni hisoblanadi. Ruda tarkibida temir miqdori 67% dan yuqori ekanligi aniqlandi. Titanomagnetitdan temir, titan, vanadiy olinadi.""",
    modelPath: 'assets/regional_minerals/minerals/titanomagnetite.png',
    referenceData: "O'zbekiston mineral-xomashyo resurslari, «Fan» nashriyoti, O'zbekiston SSR, Toshkent-1976",
    quantity: "67% temir",
    locations: [
      {"latitude": 43.38345070065487, "longitude": 59.334551713174},
    ],
  ),
  RegionalMineral(
    name: "Kaolin",
    description:
        """Kaolinit mineralidan tashkil topgan oq loy. U granitlar, gneyslar va dala shpatlari (birlamchi kaolinlar) bo'lgan boshqa jinslardan payda bo'ladi. Kimyoviy tarkibi: SiO2 46%, Al2O3 36%, Fe2O3 0,4%, TiO2 0,3%, К2О+Na2O 0,8%, CaO 0,1% dan iborat.

Foydali xususiyatlari:
U kimyoviy va fizikaviy foydali xususiyatlarga ega: gidrofillik, disperslik, yonishga chidamlilik, yetarli miqdorda alyuminiy oksidi borligi, plastiklik, kuyishdan keyin yaxshi dielektrik xususiyatga ega.

Geografik joylashuvi: Xurshid koni Qoraqalpog'iston Respublikasi Amudaryo sohilidan 3-4 km, Qipchoq shahridan 4 km uzoqlikda joylashgan.""",
    modelPath: 'assets/regional_minerals/minerals/kaolin.png',
    referenceData: "Qoratov ekspeditsiyasi (2015) ma'lumotlariga ko'ra, zaxiralari B-4000 toifalarida minglab tonnalarda tasdiqlangan",
    quantity: "1000 tonna",
    locations: [
      {"latitude": 42.327993, "longitude": 60.128489},
    ],
  ),
  RegionalMineral(
    name: "Talk",
    description:
        """(Magniy tetrasilikat tarkibli) - qatlamli silikatlarning quyi klassi bo'lgan silikatlar klassidan mineral. Talkning shpati uning oqligi bilan belgilanadi. Sanoatda maydalangan talk, mikrotalk va boshqalar qo'llaniladi. Kimyoviy formulasi: Mg3Si4O10(OH)2.

Foydali xususiyatlari:
Bu kosmetik upaning tarkibiy qismi. Kauchuk, qog'oz, bo'yoq va lak, farmatsevtika, parfyumeriya va kosmetika hamda boshqa sohalarda to'ldiruvchi sifatida qo'llaniladi.

Ishlab chiqarishda:
Bolalar kukunlari, kauchuk, qog'oz, bo'yoq va lak ishlab chiqarish, farmatsevtika (tabletka asosi), parfyumeriya va kosmetikada qo'llaniladi.

Geografik joylashuvi: Geologik qidiruv ishlari natijasida Qorao'zak hududida konlar aniqlangan. A+B+C1 toifalarida 27 000 tonna ruda mavjud.""",
    modelPath: 'assets/regional_minerals/minerals/talk.png',
    referenceData: "Geologiya va mineral resurslar bo'yicha hisobotlar",
    quantity: "27000 tonna",
    locations: [
      {"latitude": 43.086098, "longitude": 60.006346},
      {"latitude": 42.103314, "longitude": 60.329037},
    ],
  ),
  RegionalMineral(
    name: "Tabiiy gips",
    description:
        """Sulfat klassiga tegishli mineral. Kimyoviy tarkibi kalsiy sulfat digidrat bo'lib, formulasi: CaSO4 * 2H2O.

Foydali xususiyatlari:
Gips ishlab chiqarishda gips materialidan foydalaniladi. Azotli o'g'itlar (ammiakli sulfat) ishlab chiqarishda, sho'rlangan tuproqlarni gipslashda (paxta o'simliklari va boshqalar uchun), rangli metallurgiyada nikel eritishda, qog'oz ishlab chiqarishda qo'llaniladi.

Ishlab chiqarishda:
Gips bog'lovchi moddalar va azotli o'g'itlar ishlab chiqarishda qo'llaniladi.

Geografik joylashuvi: Xo'jakul koni - Qoraqalpog'iston Respublikasi Nukus shahridan 45 km uzoqlikda joylashgan. Qoratovda gips qalinligi 2-14.4 metrgacha cho'zilgan linza shaklida bo'ladi. Ekspeditsiya ma'lumotlariga ko'ra B-1520 toifalarida zaxira qori 7 000 tonnani tashkil etadi.""",
    modelPath: 'assets/regional_minerals/minerals/gypsum.png',
    quantity: "7 000 tonna",
    locations: [
      {"latitude": 42.103314, "longitude": 60.329037},
    ],
    referenceData: "O'zbekiston Respublikasi geologiya hisoboti",
  ),
  RegionalMineral(
    name: "Vermikulit",
    description:
        """(Lotincha "vermiculus" — qurt) qatlamli tuzilishga ega bo'lgan gidromikalar guruhidagi mineral. To'q rangli slyuda — biotitning ikkilamchi o'zgargan mahsuloti. Kimyoviy tarkibi: (Mg+2,Fe+3)3,[Al,Si)4O10]*(OH)*4H2O.

Foydali xususiyatlari:
Vermikulit qizdirilganda kengayish xususiyatiga ega.

Ishlab chiqarishda:
Issiqlik izolyatsiyalovchi material sifatida va qurilish obyektlarida izolyatsiya qilish, energiya va kriogen texnologiyalarida foydalaniladi.

Geografik joylashuvi:
Geologik qidiruv ishlari natijasida Qoraqalpog'iston Respublikasi Qorao'zak tumanida, Tebinbuloqning shimoli-g'arbiy qismida 18 km masofada, Qoratovda konlar aniqlangan. A+B+C1 toifasida 881,7 ming tonna ruda, C2 toifasida 642,6 ming tonna ruda mavjud.""",
    modelPath: "assets/regional_minerals/minerals/vermiculite.png",
    referenceData: "Tebinbuloq koni geologik xaritasi",
    quantity: "7 000 tonna ruda",
    locations: [
      {"latitude": 43.104995, "longitude": 59.935912},
    ],
  ),
  RegionalMineral(
    name: "Yonuvchi slanets",
    description:
        """Yonuvchi slanets - qattiq kaustobiolitlar guruhiga kiruvchi mineral bo'lib, quruq distillash vaqtida tarkibida neftga (kerogen yoki slanets moyi) o'xshash katta miqdordagi qatronlar paydo qiladi.

Kimyoviy tarkibi:
Kalsit, dolomit, gidromika, montmorillonit, kaolinit, kvars, pirit.

Foydali xususiyatlari:
Yoqilg'i va smolalar issiqlik elektr stansiyalari uchun yoqilg'i sifatida qo'llanilishi bilan bir qatorda, plastmassa, gerbitsidlar va boshqalar uchun qimmatbaho kimyoviy xomashyo hisoblanadi. Yonuvchi slanets kuli qurilish sanoati uchun bo'yoq va qurilish materiallarini (uy bloklarini birlashtirish uchun) ishlab chiqarishda qo'llaniladi. Zaxirasi — oz miqdorda.

Ishlab chiqarishda:
Qurilish sanoati va bog'lovchi qurilish materiallari ishlab chiqarishda foydalaniladi.""",
    modelPath: "assets/regional_minerals/minerals/goruchiy_slanec.png",
    referenceData: "Energetika resurslari ma'lumotnomasi",
    quantity: "oz miqdorda",
    locations: [
      {"latitude": 42.093752, "longitude": 60.258461},
    ],
  ),
  RegionalMineral(
    name: "Bazalt",
    description:
        """Bazalt - magmatik tog' jinsi (yunon tilidan olingan — "asos"). Bazalt olivin, piroksen va dala shpatidan iborat. Kimyoviy tarkibi: SiO2 45-52%, Al2O3 15-18%, Fe3O4 8-15%, CaO 6-12%, MgO 5-7%.

Zaxira xazinası:
Hozirgi vaqtda rezervlar hajmi O'zbekiston Respublikasi Davlat geologiya qo'mitasi tomonidan belgilanadi.

Foydali xususiyatlari:
Past issiqlik o'tkazuvchanligi, yaxshi issiqlik va tovush izolyatsiyasi xususiyatlariga ega.

Ishlab chiqarishda:
Qurilish materiallari ishlab chiqarish hamda uy va imoratlar qurilishida qo'llaniladi.""",
    modelPath: "assets/regional_minerals/minerals/basalt.png",
    referenceData: "O'zbekiston geologik fondi",
    quantity: "oz miqdorda",
    locations: [
      {"latitude": 42.079190479227336, "longitude": 60.577899695264335},
    ],
  ),
  RegionalMineral(
    name: "Kvars qumi",
    description:
        """Kvars qumi - tabiiy ravishda hosil bo'lgan qumni qazib olish va tasniflash yoki tarkibida kremniy bo'lgan tog' jinslarini maydalash orqali olinadigan material.

Kimyoviy tarkibi:
SiO2 98,25%, Al2O3 0,48%, Fe2O3 0,098%.

Zaxira zaxiralari:
Qora Toy ekspeditsiyasi ma'lumotlari bo'yicha (2015-yil), B-5000 toifalari bo'yicha rezervlar ming tonna bilan tasdiqlangan.

Foydali xususiyatlari:
Bu material monomineral, ya'ni faqat bir mineraldan — kvarsdan iborat. Bu xususiyati uni qimmatbaho sanoat xomashyosiga aylantiradi.

Ishlab chiqarishda qo'llanilishi:
Dekorativ materiallar ishlab chiqarishda, fasad va interyer plitalarida, landshaft dizaynida qo'llaniladi.""",
    modelPath: "assets/regional_minerals/minerals/quartz_sand.png",
    referenceData: "Qora Toy ekspeditsiyasi hisoboti, 2015",
    quantity: "ming tonna",
    locations: [
      {"latitude": 42.079190479227336, "longitude": 60.577899695264335},
    ],
  ),
  RegionalMineral(
    name: "Piroksenit",
    description:
        """Piroksenit - magmatik plutonik tog' jinslari. Piroksen kristallarining monomineral agregatidan iborat.

Kimyoviy tarkibi:
Plagioklaz (labrador, bitovnit), piroksen va temir-magneziy minerallar aralashmasidan iborat.

Foydali xususiyatlari:
Qayta ishlangan toshlar uzoq vaqtdan beri buyrak yallig'lanishi, yurak-qon tomir va o'pka kasalliklarini davolash uchun qo'llanilgan. Piroksenitning kimyoviy tarkibi va fizik xarakteristikalari qazib olish joyi va geografik regionning tabiiy xususiyatlariga ko'ra biroz farq qilishi mumkin.

Ishlab chiqarishda:
U ko'pincha fasad va interyerlarni qoplash, shuningdek, kichik arxitektura shakllari va haykaltaroshlik obyektlarini qurish uchun qo'llaniladi. Davolash uchun eng ko'p talab qilinadigani qora yoki to'q yashil piroksenit hisoblanadi.""",
    modelPath: "assets/regional_minerals/minerals/pyroxenite.png",
    referenceData: "Mineralogiya bo'yicha qo'llanma",
    quantity: "aniqlanmoqda",
    locations: [
      {"latitude": 42.134076, "longitude": 60.229223},
    ],
  ),
];

/// Virtual lab qadamlari — `demos/laboratories/laboratoriya_virtual_shablon.md`.
/// Laboratoriya raqami sarlavhadagi prefiks bilan: «6. …» → 6.
int? virtualLabNumberFromTitle(String title) {
  final m = RegExp(r'^(\d+)\s*\.').firstMatch(title.trim());
  if (m == null) return null;
  return int.tryParse(m.group(1)!);
}

/// Til bo‘yicha qadamlar: `uz` — toʻliq; `ru`/`en` — qisman, aks holda uz fallback.
List<String>? virtualLabProcedureSteps(
  int labNumber,
  String lang,
) {
  final primary = _stepsUz(labNumber);
  if (primary == null) return null;
  if (lang == 'uz') return primary;
  return _stepsTranslated(labNumber, lang) ?? primary;
}

List<String>? _stepsUz(int n) {
  switch (n) {
    case 6:
      return const [
        'Probirka 1: 2–3 ml AgNO₃ eritmasi → ichiga Cu simi yoki Cu kukuni.',
        'Probirka 2: 2–3 ml CuSO₄ eritmasi → ichiga Fe kukuni.',
        'Probirka 3: 2–3 ml Pb(NO₃)₂ eritmasi → ichiga Cu kukuni.',
        'Har birida rang, cho‘kma va gaz kabi kuzatuvlarni virtual simulyatsiya orqali tekshiring.',
        'Topshiriq: molekulyar, toʻliq ionli va qisqa ionli tenglamalar (pastki «Monitoring» bloki).',
      ];
    case 7:
      return const [
        'A. CuCl₂ elektrolizi: U-nayning ~¾ qismigacha CuCl₂ eritmasi.',
        'Mis elektrodni anod (+), grafitni katod (─) ulang; katodda Cu ajralishini kuzating.',
        'Anod jarayoni va gazni muhokama qiling; qutblarni almashtirib qayta ulang.',
        'B. KI elektrolizi: 2 M KI, ikki grafit elektrod; katodda H₂, anodda yod.',
        'Tokni o‘chirib yod tomonga 1–2 tomcha kraxmal tomizing — kuzatuv (maydonni keyingi versiyada kengaytirish mumkin).',
        'Topshiriq: katod/anod tenglamalari va rang o‘zgarishlari.',
      ];
    case 8:
      return const [
        'Ikki probirkaga Al boʻlakchalari qo‘ying.',
        'Birinchi probirkaga HCl eritmasi — gaz (H₂) va erish.',
        'Ikkinchi probirkaga NaOH eritmasi — gaz va aluminat.',
        'Jarayon va tenglamalarni yozing.',
      ];
    case 9:
      return const [
        'Aluminiy va qotishma namunalarini tartibli ko‘ring.',
        'Magnit, elektr tekshiruvi va boshqa vositalar bilan xossalarni taqqoslang.',
        'Qo‘llanish sohalari va xulosalarni yozing (bu laboratoriya — asosan kuzatuv).',
      ];
    case 10:
      return const [
        'Al(NO₃)₃ va NaOH ni aralashtiring — Al(OH)₃ cho‘kması.',
        'Cho‘kmani ikki probirkaga bo‘ling.',
        'Biriga HCl tomilang — erish; ikkinchisiga NaOH — erish.',
        'Topshiriq: molekulyar, ionli va qisqartirilgan ionli tenglamalar.',
      ];
    case 11:
      return const [
        'AlCl₃ eritmasiga ko‘k lakmus tomilang — boshlang‘ich holat.',
        'Eritmani ikki probirkaga bo‘ling: (a) suv qo‘shish; (b) qizdirish.',
        'Rang / muhit ko‘rsatkichlarini simulyatsiya sharoitlari bilan bog‘lang.',
        'Topshiriq: gidrolizni bosqichma-bosqich tushuntirish.',
      ];
    case 12:
      return const [
        'CuSO₄ ga sekin NaOH qo‘shing — ko‘kimtir-ko‘k cho‘kma.',
        'Virtual «filtrlash / yuvish» holatiga o‘ting.',
        '(a) Cho‘kma + HCl — erish. (b) Cho‘kmani qizdirish — CuO hosil bo‘lishi.',
        'Topshiriq: tenglamalar va miqdoriy topshiriqlar.',
      ];
    case 13:
      return const [
        'ZnSO₄ + NaOH — Zn(OH)₂ cho‘kması; ikki probirkaga bo‘ling.',
        'Biriga H₂SO₄, ikkinchisiga NaOH — ikkalasida ham erish (amfoterlik).',
        'Ortiqcha NaOH bilan [Zn(OH)₄]²⁻ hosil bo‘lishi ssenariysini eslang.',
      ];
    case 14:
      return const [
        'CrCl₂ + NaOH — sariq cho‘kma; keyin H₂SO₄ bilan o‘zgarishlar.',
        'Cr₂O₃ + H₂SO₄ — eritma rangi; NaOH bilan cho‘kma/piyodalar.',
        'K₂Cr₂O₇ + H₂SO₄ + Na₂SO₃ — redoks va rang o‘zgarishi.',
        'Topshiriq: barcha tenglamalar va ranglar izohi.',
      ];
    case 15:
      return const [
        'FeSO₄ + NaOH → cho‘kma; sekin HCl qo‘shish — erish.',
        'FeCl₃ + NaOH → cho‘kma; sekin H₂SO₄ — erish.',
        'Topshiriq: ranglar, valentlar va tenglamalar.',
      ];
    case 16:
      return const [
        'Fe²⁺: FeSO₄ + K₃[Fe(CN)₆] — Turnbull ko‘k cho‘kma.',
        'Fe³⁺ (A): FeCl₃ + K₄[Fe(CN)₆] — Berlin ko‘k.',
        'Fe³⁺ (B): FeCl₃ + KSCN — qizil kompleks.',
        'Topshiriq: barcha hodisalar va tenglamalar.',
      ];
    default:
      return null;
  }
}

List<String>? _stepsTranslated(int n, String lang) {
  if (lang == 'ru') return _stepsRu(n);
  if (lang == 'en') return _stepsEn(n);
  return null;
}

List<String>? _stepsRu(int n) {
  switch (n) {
    case 6:
      return const [
        'Пробирка 1: 2–3 мл AgNO₃ → медная проволока или порошок Cu.',
        'Пробирка 2: 2–3 мл CuSO₄ → порошок Fe.',
        'Пробирка 3: 2–3 мл Pb(NO₃)₂ → порошок Cu.',
        'Наблюдайте цвет, осадок и газ в симуляции.',
        'Задание: молекулярное, полное и сокращённое ионные уравнения.',
      ];
    case 7:
      return const [
        'А. Электролиз CuCl₂: заполните U‑трубку раствором ~¾ объёма.',
        'Cu — анод (+), графит — катод (−); осадок Cu на катоде.',
        'Обсудите анод и газ; поменяйте полярность.',
        'Б. Электролиз KI (2 М): два графитовых электрода.',
        'На катоде H₂, на аноде йод; после выключения — крахмал.',
      ];
    default:
      return null;
  }
}

List<String>? _stepsEn(int n) {
  switch (n) {
    case 6:
      return const [
        'Tube 1: 2–3 ml AgNO₃ → Cu wire or Cu powder.',
        'Tube 2: 2–3 ml CuSO₄ → Fe powder.',
        'Tube 3: 2–3 ml Pb(NO₃)₂ → Cu powder.',
        'Observe color, precipitate and gas in the simulation.',
        'Task: molecular, full ionic and net ionic equations (Monitoring section).',
      ];
    case 7:
      return const [
        'A. CuCl₂ electrolysis: fill the U‑tube ~¾ with solution.',
        'Cu anode (+), graphite cathode (−); Cu deposits at cathode.',
        'Discuss anode and gas; swap electrodes.',
        'B. KI electrolysis (2 M): two graphite electrodes.',
        'H₂ at cathode, iodine at anode; after power off — starch test.',
      ];
    default:
      return null;
  }
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/colors.dart';
import '../../data/datasources/lesson_lab_item_remote_data_source.dart';
import '../../data/models/lesson_lab_item_model.dart';
import '../../injection_container.dart' as di;
import 'virtual_lab_procedure_catalog.dart';

// ─── Domain data ──────────────────────────────────────────────────────────────

class _Metal {
  final String sym;
  final String name;
  final double activity;
  final double molMass;
  final Color color;
  const _Metal(this.sym, this.name, this.activity, this.molMass, this.color);
}

class _Reagent {
  final String key;
  final String label;
  final String type; // acid | salt | water
  final double strength;
  final bool oxidizing;
  final String gasKind;
  final double cationAct;
  final Color color;
  final String? equation;
  const _Reagent({
    required this.key,
    required this.label,
    required this.type,
    this.strength = 0.0,
    this.oxidizing = false,
    this.gasKind = 'NONE',
    this.cationAct = 0,
    required this.color,
    this.equation,
  });
}

class _GasInfo {
  final String name;
  final String colorName;
  final Color swatch;
  const _GasInfo(this.name, this.colorName, this.swatch);
}

class _PptInfo {
  final String text;
  final String colorName;
  final Color swatch;
  const _PptInfo(this.text, this.colorName, this.swatch);
}

// ─── Simulation engine ────────────────────────────────────────────────────────

class _SimEngine {
  static const _actMap = <String, double>{
    'K': 10, 'Na': 9.5, 'Li': 9.6, 'Ba': 9.2, 'Ca': 8.8,
    'Mg': 8.0, 'Al': 7.2, 'Mn': 6.8, 'Zn': 6.2, 'Cr': 6.0,
    'Fe': 5.6, 'Co': 5.3, 'Ni': 5.0, 'Sn': 4.4, 'Pb': 4.0,
    'Cu': 2.4, 'Hg': 2.0, 'Ag': 1.6, 'Pt': 1.1, 'Au': 0.8,
  };

  static double activityOf(String sym) => _actMap[sym] ?? 4.6;

  static double relativeActivity(_Metal m, _Reagent r) {
    if (r.type == 'salt') return m.activity - r.cationAct;
    return m.activity - 3.0;
  }

  static double computeBaseRate(
      _Metal m, _Reagent r, double temp, double conc, double mass, bool powder) {
    final rel = relativeActivity(m, r);
    final form = powder ? 1.25 : 0.9;
    final tCoef = 0.65 + (temp - 20) / 120;
    final cCoef = 0.45 + conc / 2.6;
    final mCoef = 0.6 + mass / 7;
    double rCoef = 0;
    if (r.type == 'acid') {
      rCoef = math.max(0, rel > 0 ? 0.5 + rel / 12 : rel / 25) * r.strength;
    } else if (r.type == 'salt') {
      rCoef = math.max(0, rel / 9) * 0.95;
    } else {
      // water — very slow reaction for most metals
      rCoef = math.max(0, (rel - 6.0) / 12);
    }
    return math.max(0, rCoef * tCoef * cCoef * mCoef * form);
  }

  static ({String gas, String ppt}) determineProducts(
      _Metal m, _Reagent r, double relAct) {
    String g = 'NONE', p = 'NONE';
    if (r.type == 'acid') {
      if (!r.oxidizing) {
        if (relAct > 0) { g = 'H2'; }
      } else {
        if (r.key == 'HNO3c') { g = 'NO2'; }
        else if (r.key == 'HNO3d') { g = 'NO'; }
        else if (r.key == 'H2SO4c' &&
            ['Cu', 'Ag', 'Fe', 'Zn'].contains(m.sym)) { g = 'SO2'; }
        else if (relAct > 0) { g = 'H2'; }
      }
      if (r.key == 'H2CO3' && relAct > 0) g = 'CO2';
    } else if (r.type == 'salt') {
      if (relAct > 0) {
        if (['CuSO4', 'CuCl2'].contains(r.key)) p = 'Cu';
        if (r.key == 'AgNO3') p = 'Ag';
        if (['FeSO4', 'FeCl3'].contains(r.key)) p = 'Fe';
        if (r.key == 'PbNO32') p = 'Pb';
        if (['Na2CO3', 'BaCl2'].contains(r.key)) p = 'WHITE';
      }
    } else if (r.type == 'water') {
      if (relAct > 0) { g = 'H2'; }
      else if (['Fe'].contains(m.sym)) { g = 'NONE'; } // rust, no gas
    }
    return (gas: g, ppt: p);
  }

  static String classify(double rate) {
    if (rate >= 0.85) return 'bad';
    if (rate >= 0.35) return 'warn';
    return 'ok';
  }

  /// Shablon ichidagi `M`, `MCl₂`, `MSO₄`, … ni tanlangan metall bilan almashtiradi.
  static String _substituteMetalInTemplate(String template, String sym) {
    var s = template;
    s = s.replaceAll('M(NO₃)₂', '$sym(NO₃)₂');
    s = s.replaceAll('MCl₂', '${sym}Cl₂');
    s = s.replaceAll('MSO₄', '${sym}SO₄');
    s = s.replaceAll('MOH', '${sym}OH');
    s = s.replaceAllMapped(RegExp(r'(?<![A-Za-zÀ-ÿ])3M(?![A-Za-zÀ-ÿ])'), (_) => '3$sym');
    s = s.replaceAllMapped(RegExp(r'(?<![A-Za-zÀ-ÿ])2M(?![A-Za-zÀ-ÿ])'), (_) => '2$sym');
    s = s.replaceAllMapped(RegExp(r'(?<![A-Za-zÀ-ÿ])M(?![A-Za-zÀ-ÿ])'), (_) => sym);
    return s;
  }

  /// Kuzatiladigan asosiy tenglama (metall aniq ko‘rinsin).
  static String? personalizedEquation(_Metal m, _Reagent r) {
    final base = r.equation;
    if (base == null) return null;
    final sym = m.sym;

    if (r.key == 'HCl' && sym == 'Al') {
      return '2Al + 6HCl → 2AlCl₃ + 3H₂↑';
    }
    if (r.key == 'H2SO4d' && sym == 'Al') {
      return '2Al + 3H₂SO₄(dil.) → Al₂(SO₄)₃ + 3H₂↑';
    }
    if (r.key == 'CuSO4' && sym == 'Al') {
      return '2Al + 3CuSO₄ → Al₂(SO₄)₃ + 3Cu↓';
    }
    if (r.key == 'CuSO4' && const {'Li', 'Na', 'K'}.contains(sym)) {
      return '2$sym + CuSO₄ → $sym₂SO₄ + Cu↓';
    }

    return _substituteMetalInTemplate(base, sym);
  }

  /// Yakuniy xulosa uchun qisqa matn (takrorlanmasin: «cho'kma: mis cho'kma»).
  static String gasResultUz(String gasKind) {
    switch (gasKind) {
      case 'H2':
        return 'vodorod (H₂)';
      case 'NO':
        return 'NO';
      case 'NO2':
        return 'NO₂';
      case 'SO2':
        return 'SO₂';
      case 'CO2':
        return 'CO₂';
      case 'NONE':
      default:
        return 'yo\'q';
    }
  }

  static String pptResultUz(String pptKind) {
    switch (pptKind) {
      case 'Cu':
        return 'mis (Cu↓)';
      case 'Ag':
        return 'kumush (Ag↓)';
      case 'Fe':
        return 'temir (Fe↓)';
      case 'Pb':
        return 'qo\'rg\'oshin (Pb↓)';
      case 'WHITE':
        return 'oq cho\'kma';
      case 'NONE':
      default:
        return 'yo\'q';
    }
  }

  /// Tuz eritmasidagi kationni o‘zbekcha (displacement tushuntirish uchun).
  static String _saltCationPhraseUz(String reagentKey) {
    switch (reagentKey) {
      case 'AgNO3':
        return 'Ag⁺ (kumush) ionlari';
      case 'CuSO4':
      case 'CuCl2':
        return 'Cu²⁺ (mis) ionlari';
      case 'PbNO32':
        return 'Pb²⁺ (qo\'rg\'oshin) ionlari';
      case 'FeSO4':
        return 'Fe²⁺ (temir) ionlari';
      case 'FeCl3':
        return 'Fe³⁺ (temir) ionlari';
      case 'ZnSO4':
        return 'Zn²⁺ (rux) ionlari';
      case 'NiSO4':
        return 'Ni²⁺ (nikel) ionlari';
      case 'MgSO4':
        return 'Mg²⁺ (magniy) ionlari';
      case 'Al2SO43':
        return 'Al³⁺ (alyuminiy) ionlari';
      case 'Na2CO3':
        return 'Na⁺ va CO₃²⁻';
      case 'BaCl2':
        return 'Ba²⁺ ionlari';
      default:
        return 'tuz kationlari';
    }
  }

  static String _intensityPhraseUz(String rateKind) {
    switch (rateKind) {
      case 'bad':
        return 'tez (yuqori)';
      case 'warn':
        return 'o\'rtacha tezlikda';
      default:
        return 'sekin (sust)';
    }
  }

  /// Yakuniy «Natija» kartochkasi uchun bir nechta aniq qatorlar (barcha asosiy reaktiv turlari).
  static List<String> buildOutcomeBulletsUz({
    required _Metal m,
    required _Reagent r,
    required double relAct,
    required double baseRate,
    required String gasKind,
    required String pptKind,
    required double temp,
    required double conc,
    required bool powder,
  }) {
    if (relAct <= 0) {
      final buf = StringBuffer()
        ..write('${m.name} ushbu eritma (${r.label}) bilan tipik metallni tuzdan chiqarish reaksiyasini ')
        ..write(r.type == 'salt'
            ? 'ko\'rsatmaydi: metall eritmadagi ${_saltCationPhraseUz(r.key)} dan kamroq faol.'
            : 'ko\'rsatmaydi yoki juda sekin (faollik qatori / model).');
      return [
        buf.toString(),
        'Boshqa metall va reaktiv kombinatsiyasini tanlang — masalan, laboratoriya qo\'llanmasidagi juftliklar.',
      ];
    }

    final rk = classify(baseRate);
    final intensity = _intensityPhraseUz(rk);
    final cond = '${temp.round()} °C, ~${conc.toStringAsFixed(1)} M'
        '${powder ? ', metall poroshok holda' : ''}';

    final lines = <String>[];

    if (r.type == 'salt') {
      if (r.key == 'FeCl3') {
        lines.add(
          '${m.name} ${r.label} bilan murakkab redoks-tuzaroq tasvirda ishlaydi: '
          'Fe³⁺ qisman Fe²⁺ ga tiklanishi va metall holatiga yaqin cho\'kma kuzatilishi mumkin.',
        );
      } else {
        lines.add(
          '${m.name} eritmadagi ${_saltCationPhraseUz(r.key)} ni metall ko\'rinishiga qadar chiqaradi '
          '(displacement / siljish). Hosil bo\'lgan yangi metall ionlari eritmada qoladi.',
        );
      }
      if (pptKind != 'NONE') {
        final pTxt = pptResultUz(pptKind);
        final pinfo = _Catalog.pptInfo[pptKind];
        final colorHint = pinfo != null ? ' Rang (didaktik): ${pinfo.colorName}.' : '';
        lines.add('Cho\'kma / ajralma: $pTxt.$colorHint');
      } else {
        lines.add('Bu juftlikda aniq ko\'rinadigan cho\'kma modelda ajratilmadi.');
      }
      if (gasKind == 'NONE') {
        lines.add('Gaz ajralmaydi — bu ko\'p tuz almashtirishlar uchun xos.');
      }
    } else if (r.type == 'acid') {
      if (!r.oxidizing) {
        lines.add(
          '${m.name} kislota bilan ta\'sirlanib tuz va vodorod gaziga aylanadi (soddalashtirilgan sxema).',
        );
      } else if (r.key == 'HNO3c' || r.key == 'HNO3d') {
        lines.add(
          '${m.name} nitrat kislota bilan redoks: NO₂ yoki NO gazlari va tuzlar hosil bo\'lishi mumkin.',
        );
      } else if (r.key == 'H2SO4c') {
        lines.add(
          '${m.name} konsentrlangan sulfat kislota bilan SO₂ va suv bilan birga tuz hosil bo\'lishi mumkin.',
        );
      } else {
        lines.add('${m.name} kislota bilan gaz ajralishi va tuzlanishi kuzatiladi.');
      }
      if (gasKind != 'NONE') {
        lines.add('Ajralayotgan gaz (model): ${gasResultUz(gasKind)}.');
      }
    } else if (r.type == 'water') {
      lines.add(
        relAct > 0
            ? 'Faol metallar suv bilan ta\'sirlanib gidroksid va H₂ ajratishi mumkin (model).'
            : 'Bu metall suv bilan sekin yoki reaksiyasiz (model).',
      );
      if (gasKind == 'H2' && relAct > 0) {
        lines.add('Kuzatuv: vodorod gazining pufakchalari.');
      }
    }

    lines.add('Simulyatsiya tezligi: $intensity ($cond).');

    return lines;
  }

  /// Tuz almashtirish uchun: molekulyar allaqachon [personalizedEquation] da.
  /// Ag, Pb²⁺, Cu²⁺, Fe²⁺, … bilan oddiy ketma-ketliklar (+2 metall, FeCl₃ bundan mustasno).
  static ({String mol, String fullIonic, String netIonic})? saltIonicTriple(
    _Metal m,
    _Reagent r,
    double relAct,
  ) {
    if (relAct <= 0 || r.type != 'salt') return null;
    final mol = personalizedEquation(m, r);
    if (mol == null) return null;

    final sym = m.sym;

    if (sym == 'Al' && r.key == 'CuSO4') {
      return (
        mol: mol,
        fullIonic: '2Al + 3Cu²⁺ + 3SO₄²⁻ → 2Al³⁺ + 3SO₄²⁻ + 3Cu↓',
        netIonic: '2Al + 3Cu²⁺ → 2Al³⁺ + 3Cu↓',
      );
    }

    if (sym == 'Al') return null;

    String ion2(String s) => '$s²⁺';

    switch (r.key) {
      case 'AgNO3':
        return (
          mol: mol,
          fullIonic: '$sym + 2Ag⁺ + 2NO₃⁻ → ${ion2(sym)} + 2NO₃⁻ + 2Ag↓',
          netIonic: '$sym + 2Ag⁺ → ${ion2(sym)} + 2Ag↓',
        );
      case 'CuSO4':
        return (
          mol: mol,
          fullIonic: '$sym + Cu²⁺ + SO₄²⁻ → ${ion2(sym)} + SO₄²⁻ + Cu↓',
          netIonic: '$sym + Cu²⁺ → ${ion2(sym)} + Cu↓',
        );
      case 'PbNO32':
        return (
          mol: mol,
          fullIonic: '$sym + Pb²⁺ + 2NO₃⁻ → ${ion2(sym)} + 2NO₃⁻ + Pb↓',
          netIonic: '$sym + Pb²⁺ → ${ion2(sym)} + Pb↓',
        );
      case 'FeSO4':
        return (
          mol: mol,
          fullIonic: '$sym + Fe²⁺ + SO₄²⁻ → ${ion2(sym)} + SO₄²⁻ + Fe↓',
          netIonic: '$sym + Fe²⁺ → ${ion2(sym)} + Fe↓',
        );
      case 'ZnSO4':
        return (
          mol: mol,
          fullIonic: '$sym + Zn²⁺ + SO₄²⁻ → ${ion2(sym)} + SO₄²⁻ + Zn↓',
          netIonic: '$sym + Zn²⁺ → ${ion2(sym)} + Zn↓',
        );
      case 'NiSO4':
        return (
          mol: mol,
          fullIonic: '$sym + Ni²⁺ + SO₄²⁻ → ${ion2(sym)} + SO₄²⁻ + Ni↓',
          netIonic: '$sym + Ni²⁺ → ${ion2(sym)} + Ni↓',
        );
      case 'MgSO4':
        return (
          mol: mol,
          fullIonic: '$sym + Mg²⁺ + SO₄²⁻ → ${ion2(sym)} + SO₄²⁻ + Mg↓',
          netIonic: '$sym + Mg²⁺ → ${ion2(sym)} + Mg↓',
        );
      case 'CuCl2':
        return (
          mol: mol,
          fullIonic: '$sym + Cu²⁺ + 2Cl⁻ → ${ion2(sym)} + 2Cl⁻ + Cu↓',
          netIonic: '$sym + Cu²⁺ → ${ion2(sym)} + Cu↓',
        );
      default:
        return null;
    }
  }
}

// ─── Built-in catalogs ────────────────────────────────────────────────────────

class _Catalog {
  static const metals = <_Metal>[
    _Metal('Li', 'Litiy', 9.6, 6.94, Color(0xFFE1BEE7)),
    _Metal('Na', 'Natriy', 9.5, 22.99, Color(0xFFE3F2FD)),
    _Metal('Mg', 'Magniy', 8.0, 24.31, Color(0xFFE8F5E9)),
    _Metal('Al', 'Alyuminiy', 7.2, 26.98, Color(0xFFECEFF1)),
    _Metal('K', 'Kaliy', 10.0, 39.10, Color(0xFFF3E5F5)),
    _Metal('Ca', 'Kalsiy', 8.8, 40.08, Color(0xFFFFF9C4)),
    _Metal('Mn', 'Marganets', 6.8, 54.94, Color(0xFFFCE4EC)),
    _Metal('Fe', 'Temir', 5.6, 55.85, Color(0xFFFFF3E0)),
    _Metal('Co', 'Kobalt', 5.3, 58.93, Color(0xFFE1F5FE)),
    _Metal('Ni', 'Nikel', 5.0, 58.69, Color(0xFFE8EAF6)),
    _Metal('Cu', 'Mis', 2.4, 63.55, Color(0xFFFFE0B2)),
    _Metal('Zn', 'Rux', 6.2, 65.38, Color(0xFFE0F7FA)),
    _Metal('Ag', 'Kumush', 1.6, 107.87, Color(0xFFF5F5F5)),
    _Metal('Sn', 'Qalay', 4.4, 118.71, Color(0xFFEEEEEE)),
    _Metal('Pb', 'Qo\'rg\'oshin', 4.0, 207.2, Color(0xFFEFEBE9)),
    _Metal('Au', 'Oltin', 0.8, 196.97, Color(0xFFFFF8E1)),
    _Metal('Pt', 'Platina', 1.1, 195.08, Color(0xFFF1F8E9)),
    _Metal('Hg', 'Simob', 2.0, 200.59, Color(0xFFE8F5E9)),
    _Metal('Ba', 'Bariy', 9.2, 137.33, Color(0xFFEDE7F6)),
    _Metal('Cr', 'Xrom', 6.0, 52.00, Color(0xFFE3F2FD)),
  ];

  static const reagents = <_Reagent>[
    _Reagent(
      key: 'HCl', label: 'HCl — xlorid kislota', type: 'acid',
      strength: 0.95, gasKind: 'H2',
      color: Color(0xFFE3F2FD),
      equation: 'M + 2HCl → MCl₂ + H₂↑',
    ),
    _Reagent(
      key: 'H2SO4d', label: 'H₂SO₄ (suyultirilgan)', type: 'acid',
      strength: 0.9, gasKind: 'H2',
      color: Color(0xFFFFF9C4),
      equation: 'M + H₂SO₄(dil.) → MSO₄ + H₂↑',
    ),
    _Reagent(
      key: 'H2SO4c', label: 'H₂SO₄ (konsentrlangan)', type: 'acid',
      strength: 1.1, oxidizing: true, gasKind: 'SO2',
      color: Color(0xFFFFF3E0),
      equation: 'M + 2H₂SO₄(konts.) → MSO₄ + SO₂↑ + 2H₂O',
    ),
    _Reagent(
      key: 'HNO3d', label: 'HNO₃ (suyultirilgan)', type: 'acid',
      strength: 0.95, oxidizing: true, gasKind: 'NO',
      color: Color(0xFFF3E5F5),
      equation: '3M + 8HNO₃(dil.) → 3M(NO₃)₂ + 2NO↑ + 4H₂O',
    ),
    _Reagent(
      key: 'HNO3c', label: 'HNO₃ (konsentrlangan)', type: 'acid',
      strength: 1.12, oxidizing: true, gasKind: 'NO2',
      color: Color(0xFFFFEBEE),
      equation: 'M + 4HNO₃(konts.) → M(NO₃)₂ + 2NO₂↑ + 2H₂O',
    ),
    _Reagent(
      key: 'H2O', label: 'H₂O — distillangan suv', type: 'water',
      strength: 0.1, gasKind: 'H2',
      color: Color(0xFFE3F2FD),
      equation: '2M + 2H₂O → 2MOH + H₂↑ (faol metallar)',
    ),
    _Reagent(
      key: 'CuSO4', label: 'CuSO₄ — mis(II) sulfat', type: 'salt',
      cationAct: 2.4,
      color: Color(0xFFE1F5FE),
      equation: 'M + CuSO₄ → MSO₄ + Cu↓',
    ),
    _Reagent(
      key: 'AgNO3', label: 'AgNO₃ — kumush nitrat', type: 'salt',
      cationAct: 1.6,
      color: Color(0xFFF5F5F5),
      equation: 'M + 2AgNO₃ → M(NO₃)₂ + 2Ag↓',
    ),
    _Reagent(
      key: 'FeSO4', label: 'FeSO₄ — temir(II) sulfat', type: 'salt',
      cationAct: 5.6,
      color: Color(0xFFFFF8E1),
      equation: 'M + FeSO₄ → MSO₄ + Fe↓',
    ),
    _Reagent(
      key: 'FeCl3', label: 'FeCl₃ — temir(III) xlorid', type: 'salt',
      cationAct: 5.8,
      color: Color(0xFFFFF3E0),
      equation: 'M + 2FeCl₃ → MCl₂ + 2FeCl₂',
    ),
    _Reagent(
      key: 'ZnSO4', label: 'ZnSO₄ — rux sulfat', type: 'salt',
      cationAct: 6.2,
      color: Color(0xFFE0F7FA),
      equation: 'M + ZnSO₄ → MSO₄ + Zn↓',
    ),
    _Reagent(
      key: 'PbNO32', label: 'Pb(NO₃)₂ — qo\'rg\'oshin nitrat', type: 'salt',
      cationAct: 4.0,
      color: Color(0xFFF5F5F5),
      equation: 'M + Pb(NO₃)₂ → M(NO₃)₂ + Pb↓',
    ),
    _Reagent(
      key: 'Al2SO43', label: 'Al₂(SO₄)₃ — alyuminiy sulfat', type: 'salt',
      cationAct: 7.2,
      color: Color(0xFFE8EAF6),
      equation: '3M + Al₂(SO₄)₃ → 3MSO₄ + 2Al↓',
    ),
    _Reagent(
      key: 'NiSO4', label: 'NiSO₄ — nikel sulfat', type: 'salt',
      cationAct: 5.0,
      color: Color(0xFFE8F5E9),
      equation: 'M + NiSO₄ → MSO₄ + Ni↓',
    ),
    _Reagent(
      key: 'MgSO4', label: 'MgSO₄ — magniy sulfat', type: 'salt',
      cationAct: 8.0,
      color: Color(0xFFE8F5E9),
      equation: 'M + MgSO₄ → MSO₄ + Mg↓',
    ),
  ];

  static const gasInfo = <String, _GasInfo>{
    'H2': _GasInfo('H₂', 'rangsiz', Color(0xFFE2E8F0)),
    'NO': _GasInfo('NO', 'rangsiz', Color(0xFFF1F5F9)),
    'NO2': _GasInfo('NO₂', 'jigarrang', Color(0xFFB45309)),
    'SO2': _GasInfo('SO₂', 'rangsiz', Color(0xFFCBD5E1)),
    'CO2': _GasInfo('CO₂', 'rangsiz', Color(0xFFDBEAFE)),
    'NONE': _GasInfo('yo\'q', '—', Color(0xFFCBD5E1)),
  };

  static const pptInfo = <String, _PptInfo>{
    'Cu': _PptInfo('Cu cho\'kma', 'qizg\'ish-jigarrang', Color(0xFFB45309)),
    'Ag': _PptInfo('Ag cho\'kma', 'kumush', Color(0xFF9CA3AF)),
    'Fe': _PptInfo('Fe cho\'kma', 'to\'q kulrang', Color(0xFF4B5563)),
    'Pb': _PptInfo('Pb cho\'kma', 'kulrang-oq', Color(0xFFD1D5DB)),
    'WHITE': _PptInfo('oq cho\'kma', 'oq', Color(0xFFF1F5F9)),
    'NONE': _PptInfo('yo\'q', '—', Color(0xFFE5E7EB)),
  };
}

// ─── Bubble model ─────────────────────────────────────────────────────────────

class _Bubble {
  final double x;
  final double size;
  double y;
  double opacity;
  final Color color;

  _Bubble({required this.x, required this.size, required this.y,
      required this.opacity, required this.color});
}

// ─── Log entry ────────────────────────────────────────────────────────────────

class _LogEntry {
  final String time;
  final String message;
  final String cls; // ok | warn | err | normal

  const _LogEntry(this.time, this.message, this.cls);
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class VirtualLabPage extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;

  const VirtualLabPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<VirtualLabPage> createState() => _VirtualLabPageState();
}

class _VirtualLabPageState extends State<VirtualLabPage>
    with TickerProviderStateMixin {
  final _ds = LessonLabItemRemoteDataSourceImpl(
    dio: di.sl<DioClient>().dio,
  );

  // API items
  List<LessonLabItemModel> _labItems = [];
  bool _loading = true;
  String? _error;

  // Selected materials — driven by API lab items
  late _Metal _selMetal;
  late _Reagent _selReagent;
  int _selMetalIdx = 0;
  int _selReagentIdx = 0;

  /// Reaksiya boshidagi nisbiy faollik (xulosa matni uchun).
  double _relActivityAtStart = 0;

  // Conditions
  double _temp = 25;
  double _conc = 1.0;
  double _mass = 1.0;

  // Simulation state
  bool _running = false;
  bool _paused = false;
  bool _usePowder = false;
  double _liveRate = 0;
  double _progress = 0;
  double _gas = 0;
  double _heat = 0;
  double _ppt = 0;
  double _t = 0;
  double _baseRate = 0;
  String _gasKind = 'NONE';
  String _pptKind = 'NONE';
  Timer? _tick;

  // Bubbles
  final _bubbles = <_Bubble>[];
  late final AnimationController _bubbleAnim;
  Timer? _bubbleCleaner;

  // Logs
  final _logs = <_LogEntry>[];

  @override
  void initState() {
    super.initState();
    // Temporary defaults — will be overridden by _tryPreSelectFromApi() after API load
    _selMetal = _Catalog.metals.firstWhere((m) => m.sym == 'Fe',
        orElse: () => _Catalog.metals.first);
    _selReagent = _Catalog.reagents.firstWhere((r) => r.key == 'HCl',
        orElse: () => _Catalog.reagents.first);

    _bubbleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_animateBubbles)..repeat();

    _loadItems();
    _log('Virtual laboratoriya ishga tayyor.', 'ok');
  }

  @override
  void dispose() {
    _tick?.cancel();
    _bubbleCleaner?.cancel();
    _bubbleAnim.dispose();
    super.dispose();
  }

  // ── API ──────────────────────────────────────────────────────────────────────

  Future<void> _loadItems() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _ds.getLabItems(widget.lessonId);
      if (!mounted) return;
      setState(() => _labItems = items);
      // Pre-select from API if available
      _tryPreSelectFromApi();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Lab item helpers ──────────────────────────────────────────────────────────

  /// Items from API grouped by category
  List<LessonLabItemModel> get _labMetals =>
      _labItems.where((i) => i.category == 'element' && i.isActive).toList();

  List<LessonLabItemModel> get _labReagents =>
      _labItems.where((i) => i.category == 'reagent' && i.isActive && i.formula != null).toList();

  /// Derive vessel type from lab equipment/vessel items
  String get _derivedVessel {
    for (final item in _labItems) {
      if (item.category == 'vessel' || item.category == 'equipment') {
        final n = item.name.toLowerCase();
        if (n.contains('probirka')) return 'tube';
        if (n.contains('kolba')) return 'flask';
      }
    }
    return 'beaker';
  }

  /// Normalize unicode subscripts in formula strings
  static String _cleanFormula(String s) => s
      .replaceAll('₁', '1').replaceAll('₂', '2').replaceAll('₃', '3')
      .replaceAll('₄', '4').replaceAll('₅', '5').replaceAll('₆', '6')
      .replaceAll('₇', '7').replaceAll('₈', '8').replaceAll('₉', '9')
      .replaceAll('⁺', '+').replaceAll('⁻', '-');

  /// API formulalari (`Pb(NO₃)₂`, `AgNO₃`) → [\_Catalog.reagents] kaliti (`PbNO32`, `AgNO3`).
  static String _normalizeReagentCatalogKey(String raw) {
    final cleaned = _cleanFormula(raw).replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return '';
    return cleaned.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  }

  bool _labMetalIsPowder(LessonLabItemModel item) {
    final n = item.name.toLowerCase();
    return n.contains('kukun') || n.contains('chang') || n.contains('powder');
  }

  /// Map lab item (element) → simulation _Metal
  _Metal _metalFromItem(LessonLabItemModel item) {
    final sym = _cleanFormula(item.formula ?? item.name).trim();
    return _Catalog.metals.firstWhere(
      (m) => m.sym.toUpperCase() == sym.toUpperCase(),
      orElse: () => _Metal(
        sym, item.name, _SimEngine.activityOf(sym), 50.0,
        Colors.blueGrey.shade300,
      ),
    );
  }

  /// Map lab item (reagent) → simulation _Reagent
  _Reagent _reagentFromItem(LessonLabItemModel item) {
    final raw = item.formula ?? '';
    final flatKey = _normalizeReagentCatalogKey(raw);
    if (flatKey.isEmpty) {
      return _Reagent(
        key: item.name,
        label: item.name,
        type: 'water',
        color: Colors.blue.shade50,
      );
    }
    return _Catalog.reagents.firstWhere(
      (r) => r.key.toUpperCase() == flatKey.toUpperCase(),
      orElse: () {
        final disp = _cleanFormula(raw).trim();
        final typeGuess =
            flatKey.toUpperCase().startsWith('H') && flatKey.length <= 6 ? 'acid' : 'salt';
        return _Reagent(
          key: flatKey,
          label: disp.isNotEmpty ? '${item.name} ($disp)' : item.name,
          type: typeGuess,
          color: typeGuess == 'acid' ? Colors.orange.shade50 : Colors.teal.shade50,
        );
      },
    );
  }

  void _tryPreSelectFromApi() {
    final metals = _labMetals;
    final reagents = _labReagents;
    setState(() {
      _selMetalIdx = 0;
      _selReagentIdx = 0;
      if (metals.isNotEmpty) {
        _selMetal = _metalFromItem(metals[0]);
        _usePowder = _labMetalIsPowder(metals[0]);
      }
      if (reagents.isNotEmpty) _selReagent = _reagentFromItem(reagents[0]);
    });
  }

  // ── Simulation ────────────────────────────────────────────────────────────────

  void _start() {
    if (_running) return;
    _progress = 0;
    _gas = 0;
    _heat = 0;
    _ppt = 0;
    _t = 0;
    _liveRate = 0;
    _baseRate = _SimEngine.computeBaseRate(
        _selMetal, _selReagent, _temp, _conc, _mass, _usePowder);
    final rel = _SimEngine.relativeActivity(_selMetal, _selReagent);
    _relActivityAtStart = rel;
    final p = _SimEngine.determineProducts(_selMetal, _selReagent, rel);
    _gasKind = p.gas; _pptKind = p.ppt;
    _running = true; _paused = false;
    _log('START  ${_selMetal.name} + ${_selReagent.label}  |  rate=${_baseRate.toStringAsFixed(2)}', 'ok');
    _tick = Timer.periodic(const Duration(milliseconds: 120), (_) => _step());
    setState(() {});
  }

  void _pause() {
    if (!_running) return;
    _running = false; _paused = true; _tick?.cancel();
    _log('PAUZA', 'warn');
    setState(() {});
  }

  void _resume() {
    if (!_paused) return;
    _running = true; _paused = false;
    _tick = Timer.periodic(const Duration(milliseconds: 120), (_) => _step());
    setState(() {});
  }

  void _reset() {
    _running = false; _paused = false; _tick?.cancel();
    _progress = 0;
    _gas = 0;
    _heat = 0;
    _ppt = 0;
    _t = 0;
    _liveRate = 0;
    _baseRate = 0;
    _gasKind = 'NONE';
    _pptKind = 'NONE';
    _relActivityAtStart = 0;
    _bubbles.clear();
    _log('RESET', 'normal');
    setState(() {});
  }

  void _step() {
    if (!_running || !mounted) return;
    _t += 0.12;
    final rnd = math.Random();
    final rate = _baseRate * (0.75 + rnd.nextDouble() * 0.5);
    _liveRate = rate;
    _progress = math.min(100, _progress + 0.35 + rate * 1.2);
    _gas = math.min(220, _gas + rate * (_gasKind == 'NONE' ? 0.1 : 2.0));
    _heat = math.min(100, _heat + rate * 1.7);
    _ppt = math.min(8, _ppt + rate * (_pptKind == 'NONE' ? 0.05 : 0.4));
    final wantsBubbles =
        _gasKind != 'NONE' || (_selReagent.type == 'acid' && _relActivityAtStart > 0);
    if (wantsBubbles && rate > 0.2) _spawnBubble(rate);
    if (_progress >= 100) _finish();
    if (mounted) setState(() {});
  }

  void _finish() {
    _running = false; _paused = false; _tick?.cancel();
    final kind = _SimEngine.classify(_baseRate);
    final summ = kind == 'bad' ? 'kuchli' : kind == 'warn' ? 'o\'rtacha' : 'sust';
    _log('YAKUNLANDI  mode=$summ  gaz=${_SimEngine.gasResultUz(_gasKind)}  cho\'kma=${_SimEngine.pptResultUz(_pptKind)}', 'warn');
    setState(() {});
  }

  // ── Bubbles ───────────────────────────────────────────────────────────────────

  void _spawnBubble(double rate) {
    final n = (rate * 2).round().clamp(0, 4);
    final rnd = math.Random();
    for (var i = 0; i < n; i++) {
      _bubbles.add(_Bubble(
        x: 0.1 + rnd.nextDouble() * 0.8,
        size: 4 + rnd.nextDouble() * 8,
        y: 0.85,
        opacity: 0.9,
        color: Colors.white.withValues(alpha: 0.75),
      ));
    }
  }

  void _animateBubbles() {
    if (_bubbles.isEmpty) return;
    final remove = <_Bubble>[];
    for (final b in _bubbles) {
      b.y -= 0.025;
      b.opacity -= 0.018;
      if (b.opacity <= 0 || b.y < 0) remove.add(b);
    }
    _bubbles.removeWhere(remove.contains);
    if (mounted) setState(() {});
  }

  // ── Logging ───────────────────────────────────────────────────────────────────

  void _log(String msg, String cls) {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    setState(() {
      _logs.insert(0, _LogEntry(time, msg, cls));
      if (_logs.length > 80) _logs.removeLast();
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String get _stateText {
    if (_running) return 'Jarayon ketmoqda...';
    if (_paused) return 'To\'xtatildi';
    if (_progress >= 100) return 'Yakunlandi ✓';
    return 'Kutilmoqda';
  }

  Color get _stateColor {
    if (_running) {
      final k = _SimEngine.classify(_baseRate);
      if (k == 'bad') return Colors.redAccent;
      if (k == 'warn') return Colors.orange;
      return AppColors.primaryGreen;
    }
    if (_paused) return Colors.orange;
    if (_progress >= 100) return AppColors.primaryGreen;
    return Colors.grey;
  }

  /// Reaksiya mumkin bo‘lganligi (tanlov yoki boshlangan jarayon bo‘yicha).
  double _effectiveRelForDisplay() {
    if (_running || _paused || _progress > 0) return _relActivityAtStart;
    return _SimEngine.relativeActivity(_selMetal, _selReagent);
  }

  String _monitorRateLabel() {
    final br = _SimEngine.computeBaseRate(
      _selMetal, _selReagent, _temp, _conc, _mass, _usePowder,
    );
    if (_running || _paused) return _liveRate.toStringAsFixed(2);
    return br.toStringAsFixed(2);
  }

  String _phMonitorLine() {
    final rel = _effectiveRelForDisplay();
    if (_selReagent.type == 'acid') {
      return (_running || _progress >= 100) ? 'pH ↓' : 'kislota';
    }
    if (_selReagent.type == 'salt') {
      if (rel <= 0) return 'reaksiya yo\'q';
      if (!_running && _progress < 100) return 'tuz ▶';
      return 'tuz • siljish';
    }
    if (_selReagent.type == 'water') return 'H₂O';
    return '—';
  }

  /// Monitoring kartochkasi: metall bilan shaxsiylashtirilgan molekulyar tenglama.
  String? _equationForMonitorPreview() {
    final rel = _effectiveRelForDisplay();
    if (rel <= 0) return null;
    return _SimEngine.personalizedEquation(_selMetal, _selReagent);
  }

  ({String mol, String fullIonic, String netIonic})? _ionicTriplePreview() =>
      _SimEngine.saltIonicTriple(_selMetal, _selReagent, _effectiveRelForDisplay());

  List<String> _outcomeBulletLines() {
    return _SimEngine.buildOutcomeBulletsUz(
      m: _selMetal,
      r: _selReagent,
      relAct: _relActivityAtStart,
      baseRate: _baseRate,
      gasKind: _gasKind,
      pptKind: _pptKind,
      temp: _temp,
      conc: _conc,
      powder: _usePowder,
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildAppBar(isDark),
          Expanded(child: _buildSimTab(isDark)),
        ],
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────

  Widget _buildAppBar(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B2FBE), Color(0xFF4527A0)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚗️  Virtual Laboratoriya',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(widget.lessonTitle,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SIMULATION TAB ───────────────────────────────────────────────────────────

  Widget _buildSimTab(bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.solidPurple));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadItems, child: const Text('Qayta urinish')),
          ],
        ),
      );
    }

    final procedure = _procedureSteps(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (_labItems.isNotEmpty) ...[
            _buildTemplateChecklistCard(context, isDark),
            const SizedBox(height: 10),
          ],
          if (procedure != null && procedure.isNotEmpty) ...[
            _buildProcedureCard(context, isDark, procedure),
            const SizedBox(height: 10),
          ],
          _buildControlsCard(isDark),
          const SizedBox(height: 10),
          _buildSimCard(isDark),
          const SizedBox(height: 10),
          _buildMonitorCard(isDark),
          const SizedBox(height: 10),
          _buildJournalCard(isDark),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── Shablon: checklist va amaliyot (demos/laboratories/laboratoriya_virtual_shablon.md) ──

  List<String>? _procedureSteps(BuildContext context) {
    final n = virtualLabNumberFromTitle(widget.lessonTitle);
    if (n == null) return null;
    return virtualLabProcedureSteps(n, context.locale.languageCode);
  }

  static const List<String> _checklistCategoryOrder = [
    'vessel',
    'equipment',
    'reagent',
    'element',
  ];

  List<LessonLabItemModel> _itemsSortedForCategory(String category) {
    final list =
        _labItems.where((i) => i.category == category && i.isActive).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  IconData _categoryIconData(String cat) {
    switch (cat) {
      case 'vessel':
        return Icons.science_outlined;
      case 'equipment':
        return Icons.precision_manufacturing_outlined;
      case 'reagent':
        return Icons.opacity_rounded;
      case 'element':
        return Icons.grain_rounded;
      default:
        return Icons.label_outline_rounded;
    }
  }

  String _categoryTitleFromCode(BuildContext context, String cat) {
    switch (cat) {
      case 'vessel':
        return context.tr('virtual_lab_tab_vessel');
      case 'equipment':
        return context.tr('virtual_lab_tab_equipment');
      case 'reagent':
        return context.tr('virtual_lab_tab_reagent');
      case 'element':
        return context.tr('virtual_lab_tab_element');
      default:
        return cat;
    }
  }

  List<Widget> _categoryChecklistBlock(BuildContext context, bool isDark, String cat) {
    final rows = _itemsSortedForCategory(cat);
    if (rows.isEmpty) return const <Widget>[];
    return [
      Row(
        children: [
          Icon(_categoryIconData(cat), size: 16, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 6),
          Text(
            _categoryTitleFromCode(context, cat).toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      ...rows.map((item) => _checklistItemTile(context, isDark, item)),
      const SizedBox(height: 10),
    ];
  }

  Widget _checklistItemTile(
    BuildContext context,
    bool isDark,
    LessonLabItemModel item,
  ) {
    final subtitle = StringBuffer();
    if (item.quantity != null && item.quantity!.trim().isNotEmpty) {
      subtitle.write(item.quantity!.trim());
      if (item.unit != null && item.unit!.trim().isNotEmpty) {
        subtitle.write(' ${item.unit!.trim()}');
      }
    }
    final sub = subtitle.toString().trim();
    final note = item.notes?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFA855F7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.formula != null && item.formula!.trim().isNotEmpty
                            ? '${item.name} (${item.formula})'
                            : item.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                    ),
                    if (!item.isRequired)
                      Padding(
                        padding: const EdgeInsets.only(left: 6, top: 1),
                        child: Text(
                          '(${context.tr('virtual_lab_optional')})',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white38 : Colors.black45,
                          ),
                        ),
                      ),
                  ],
                ),
                if (sub.isNotEmpty)
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                if (note != null && note.isNotEmpty)
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.25,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white38 : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateChecklistCard(BuildContext context, bool isDark) {
    const accent = Color(0xFF8B5CF6);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2D1B4E).withValues(alpha: 0.55),
                  const Color(0xFF161B22),
                ]
              : const [Color(0xFFF3E8FF), Colors.white],
        ),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE9D5FF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: accent, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('virtual_lab_checklist_title'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final cat in _checklistCategoryOrder)
            ..._categoryChecklistBlock(context, isDark, cat),
        ],
      ),
    );
  }

  Widget _buildProcedureCard(
    BuildContext context,
    bool isDark,
    List<String> steps,
  ) {
    const accent = Color(0xFF6366F1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E2A5E).withValues(alpha: 0.55),
                  const Color(0xFF161B22),
                ]
              : const [Color(0xFFEEF2FF), Colors.white],
        ),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFC7D2FE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.format_list_numbered_rounded, color: accent, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('virtual_lab_procedure_title'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark ? Colors.white.withValues(alpha: 0.92) : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (i < steps.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          Text(
            context.tr('virtual_lab_template_footer'),
            style: TextStyle(
              fontSize: 10,
              height: 1.3,
              color: isDark ? Colors.white38 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Controls card ─────────────────────────────────────────────────────────────

  Widget _buildControlsCard(bool isDark) {
    final bg = isDark ? const Color(0xFF161B22) : Colors.white;
    final metals = _labMetals;
    final reagents = _labReagents;
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Reaksiya komponentlari', isDark),
          const SizedBox(height: 10),
          // ── Metal selector (from API lab items) ────────────────────────────
          _label('Metall (element)', isDark),
          if (metals.isEmpty)
            _emptyItemsHint('Bu darsda metall elementi topilmadi', isDark)
          else
            _dropdownRow<int>(
              isDark: isDark,
              value: _selMetalIdx.clamp(0, metals.length - 1),
              items: List.generate(metals.length, (i) {
                final it = metals[i];
                return DropdownMenuItem(
                  value: i,
                  child: Text(
                    it.formula != null
                        ? '${it.name} (${it.formula})'
                        : it.name,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _selMetalIdx = v;
                  _selMetal = _metalFromItem(metals[v]);
                  _usePowder = _labMetalIsPowder(metals[v]);
                  if (_running || _paused || _progress >= 100) _reset();
                });
              },
              bg: bg,
            ),
          const SizedBox(height: 8),
          // ── Reagent selector (from API lab items) ──────────────────────────
          _label('Reaktiv (kislota / tuz)', isDark),
          if (reagents.isEmpty)
            _emptyItemsHint('Bu darsda reaktiv topilmadi', isDark)
          else
            _dropdownRow<int>(
              isDark: isDark,
              value: _selReagentIdx.clamp(0, reagents.length - 1),
              items: List.generate(reagents.length, (i) {
                final it = reagents[i];
                final mapped = _reagentFromItem(it);
                return DropdownMenuItem(
                  value: i,
                  child: Row(children: [
                    Container(
                      width: 10, height: 10,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: mapped.color, shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        it.formula != null ? '${it.name} (${it.formula})' : it.name,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                );
              }),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _selReagentIdx = v;
                  _selReagent = _reagentFromItem(reagents[v]);
                  if (_running || _paused || _progress >= 100) _reset();
                });
              },
              bg: bg,
            ),
          const SizedBox(height: 14),
          _sectionTitle('Sharoitlar', isDark),
          const SizedBox(height: 8),
          _slider(isDark, 'Harorat', '${_temp.round()} °C', _temp, 20, 98, (v) => setState(() => _temp = v)),
          _slider(isDark, 'Konsentratsiya', '${_conc.toStringAsFixed(1)} M', _conc, 0.2, 3.0, (v) => setState(() => _conc = v)),
          _slider(isDark, 'Metall massasi', '${_mass.toStringAsFixed(1)} g', _mass, 0.5, 6.0, (v) => setState(() => _mass = v)),
          const SizedBox(height: 14),
          _sectionTitle('Boshqaruv', isDark),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _actionBtn('▶  Ishga tushirish', const Color(0xFF03A9F4), Colors.white,
                  (!_running && !_paused && _progress < 100) ? _start : null)),
              const SizedBox(width: 6),
              Expanded(child: _actionBtn('⏸  Pauza', const Color(0xFFDBEAFE), const Color(0xFF1E3A8A),
                  _running ? _pause : (_paused ? _resume : null))),
              const SizedBox(width: 6),
              Expanded(child: _actionBtn('↺  Tozalash', const Color(0xFFF3F4F6), const Color(0xFF374151), _reset)),
            ],
          ),
          const SizedBox(height: 8),
          // State chip
          Row(children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: _stateColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(_stateText, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.textSecondary)),
          ]),
        ],
      ),
    );
  }

  // ── Simulation visual card ─────────────────────────────────────────────────────

  Widget _buildSimCard(bool isDark) {
    final liquidH = math.max(0.15, (0.52 - _progress * 0.0017));
    final isHot = _heat > 35;
    final showFlame = _SimEngine.classify(_baseRate) == 'bad' && _running;
    var liquidColor = isHot
        ? _selReagent.color.withValues(alpha: 0.7)
        : _selReagent.color.withValues(alpha: 0.5);

    if (_selReagent.key == 'CuSO4' &&
        _selMetal.sym == 'Fe' &&
        _effectiveRelForDisplay() > 0 &&
        _progress > 2) {
      liquidColor = Color.lerp(
            liquidColor,
            const Color(0xFFBBDEFB),
            (_progress / 100).clamp(0.0, 1.0) * 0.75,
          ) ??
          liquidColor;
    }

    return _card(
      isDark: isDark,
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _sectionTitle('Simulyatsiya', isDark),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white12 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_derivedVessel == 'beaker' ? 'Beaker' : _derivedVessel == 'tube' ? 'Probirka' : 'Kolba',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.textSecondary)),
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: Center(
              child: _VesselPainter(
                vesselType: _derivedVessel,
                liquidHeightFraction: liquidH,
                liquidColor: liquidColor,
                bubbles: List.from(_bubbles),
                metalProgress: _progress,
                powder: _usePowder,
                metalColor: _selMetal.color,
                showFlame: showFlame,
                pptColor: _pptKind != 'NONE'
                    ? _Catalog.pptInfo[_pptKind]!.swatch
                    : Colors.transparent,
                pptFraction: math.min(1.0, _ppt / 8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Gas + precipitate pills
          Row(children: [
            _colorPill(_Catalog.gasInfo[_gasKind]!, 'Gaz', isDark),
            const SizedBox(width: 8),
            _pptPill(_Catalog.pptInfo[_pptKind]!, 'Cho\'kma', isDark),
          ]),
        ],
      ),
    );
  }

  Widget _colorPill(_GasInfo g, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
        ),
        child: Row(children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(
              color: g.swatch, shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400))),
          const SizedBox(width: 6),
          Flexible(child: Text('$label: ${g.name} (${g.colorName})',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textSecondary),
              overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  Widget _pptPill(_PptInfo p, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
        ),
        child: Row(children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(
              color: p.swatch, shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400))),
          const SizedBox(width: 6),
          Flexible(child: Text('$label: ${p.text}',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textSecondary),
              overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  // ── Monitor card ──────────────────────────────────────────────────────────────

  Widget _buildMonitorCard(bool isDark) {
    final displayEq = _equationForMonitorPreview();
    final ionTrip = _ionicTriplePreview();
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Monitoring', isDark),
          const SizedBox(height: 10),
          // Reading grid
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.42,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _readCard('Tezlik', _monitorRateLabel(), isDark, Colors.blue),
              _readCard('Gaz', '${_gas.round()} ml', isDark, Colors.teal),
              _readCard('Issiqlik', '${_heat.round()}%', isDark, Colors.orange),
              _readCard('Cho\'kma', '${_ppt.toStringAsFixed(2)} g', isDark, Colors.brown),
              _readCard('Muhit', _phMonitorLine(), isDark, Colors.purple),
              _readCard('Vaqt', '${_t.toStringAsFixed(1)} s', isDark, Colors.indigo),
            ],
          ),
          const SizedBox(height: 10),
          // Progress
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Jarayon', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black38)),
            Text('${_progress.round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : AppColors.textPrimary)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
              color: _stateColor,
            ),
          ),
          // Equations
          if (displayEq != null &&
              !(_progress >= 100 && _relActivityAtStart <= 0)) ...[
            const SizedBox(height: 12),
            _sectionTitle('Tenglamalar', isDark),
            const SizedBox(height: 6),
            _equationLine(isDark, 'Molekulyar', displayEq),
            if (ionTrip != null) ...[
              const SizedBox(height: 6),
              _equationLine(isDark, 'To\'liq ionli', ionTrip.fullIonic),
              const SizedBox(height: 6),
              _equationLine(isDark, 'Qisqa ionli', ionTrip.netIonic),
            ],
          ],
          // Result summary
          if (_progress >= 100) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Natija-xulosa',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.lightGreenAccent : AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._outcomeBulletLines().map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white54 : AppColors.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              line,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.38,
                                color: isDark ? Colors.white.withValues(alpha: 0.88) : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _equationLine(bool isDark, String title, String equation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue.withValues(alpha: 0.12) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: SelectableText(
            equation,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11.5,
              height: 1.35,
              color: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1E3A8A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _readCard(String k, String v, bool isDark, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.black38),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                v,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                  color: accent,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Journal card ───────────────────────────────────────────────────────────────

  Widget _buildJournalCard(bool isDark) {
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _sectionTitle('Laboratoriya jurnali', isDark),
            TextButton.icon(
              onPressed: () => setState(() => _logs.clear()),
              icon: const Icon(Icons.delete_outline_rounded, size: 14),
              label: const Text('Tozalash', style: TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8)),
            ),
          ]),
          const SizedBox(height: 6),
          Container(
            height: 160,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : const Color(0xFFFCFDFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (_, i) {
                final l = _logs[i];
                Color c = isDark ? Colors.white54 : Colors.black54;
                if (l.cls == 'ok') c = const Color(0xFF16A34A);
                if (l.cls == 'warn') c = const Color(0xFFD97706);
                if (l.cls == 'err') c = Colors.redAccent;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: RichText(
                    text: TextSpan(style: const TextStyle(fontSize: 11, fontFamily: 'monospace'), children: [
                      TextSpan(text: '[${l.time}] ', style: const TextStyle(color: Color(0xFF2563EB))),
                      TextSpan(text: l.message, style: TextStyle(color: c)),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: const Text(
              'Eslatma: bu didaktik simulyatsiya. Real laboratoriya protokoli va xavfsizlik qoidalari alohida bajariladi.',
              style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared widgets ───────────────────────────────────────────────────────────

  Widget _card({required bool isDark, Widget? child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String t, bool isDark) => Text(t, style: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700,
      letterSpacing: 0.04, color: isDark ? Colors.white60 : Colors.black45));

  Widget _label(String t, bool isDark) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(t, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)));

  Widget _emptyItemsHint(String msg, bool isDark) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
    ),
    child: Row(children: [
      Icon(Icons.info_outline_rounded, size: 14, color: isDark ? Colors.white38 : Colors.grey.shade500),
      const SizedBox(width: 6),
      Flexible(child: Text(msg, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey.shade500))),
    ]),
  );

  Widget _dropdownRow<T>({
    required bool isDark, required T value, required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged, required Color bg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButton<T>(
        value: value, items: items, onChanged: onChanged,
        isExpanded: true, underline: const SizedBox(),
        dropdownColor: bg, style: TextStyle(
            fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary),
        icon: Icon(Icons.expand_more_rounded, size: 18,
            color: isDark ? Colors.white54 : Colors.black38),
      ),
    );
  }

  Widget _slider(bool isDark, String label, String val, double cur, double min,
      double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(
          width: 110,
          child: Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              activeTrackColor: const Color(0xFF03A9F4),
              inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade200,
              thumbColor: const Color(0xFF03A9F4),
              overlayColor: const Color(0x2003A9F4),
            ),
            child: Slider(value: cur, min: min, max: max, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(val, textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF5F7AA0))),
        ),
      ]),
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(label, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg))),
        ),
      ),
    );
  }
}

// ─── Vessel Painter ───────────────────────────────────────────────────────────

class _VesselPainter extends StatelessWidget {
  final String vesselType;
  final double liquidHeightFraction;
  final Color liquidColor;
  final List<_Bubble> bubbles;
  final double metalProgress;
  final bool powder;
  final Color metalColor;
  final bool showFlame;
  final Color pptColor;
  final double pptFraction;

  const _VesselPainter({
    required this.vesselType,
    required this.liquidHeightFraction,
    required this.liquidColor,
    required this.bubbles,
    required this.metalProgress,
    required this.powder,
    required this.metalColor,
    required this.showFlame,
    required this.pptColor,
    required this.pptFraction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(180, 220),
      painter: _VesselCustomPainter(
        vesselType: vesselType,
        liquidFraction: liquidHeightFraction,
        liquidColor: liquidColor,
        bubbles: bubbles,
        metalProgress: metalProgress,
        powder: powder,
        metalColor: metalColor,
        showFlame: showFlame,
        pptColor: pptColor,
        pptFraction: pptFraction,
      ),
    );
  }
}

class _VesselCustomPainter extends CustomPainter {
  final String vesselType;
  final double liquidFraction;
  final Color liquidColor;
  final List<_Bubble> bubbles;
  final double metalProgress;
  final bool powder;
  final Color metalColor;
  final bool showFlame;
  final Color pptColor;
  final double pptFraction;

  _VesselCustomPainter({
    required this.vesselType,
    required this.liquidFraction,
    required this.liquidColor,
    required this.bubbles,
    required this.metalProgress,
    required this.powder,
    required this.metalColor,
    required this.showFlame,
    required this.pptColor,
    required this.pptFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final h = size.height;

    double vesselLeft, vesselRight, vesselTop, vesselBottom;

    if (vesselType == 'tube') {
      vesselLeft = cx - 30;
      vesselRight = cx + 30;
      vesselTop = 20.0;
      vesselBottom = h - 20;
    } else if (vesselType == 'flask') {
      vesselLeft = cx - 55;
      vesselRight = cx + 55;
      vesselTop = 20.0;
      vesselBottom = h - 20;
    } else {
      // beaker
      vesselLeft = cx - 55;
      vesselRight = cx + 55;
      vesselTop = 30.0;
      vesselBottom = h - 20;
    }

    final vesselH = vesselBottom - vesselTop;
    final vesselW = vesselRight - vesselLeft;

    // ── Draw vessel shape ────────────────────────────────────────────────────────
    final vesselPaint = Paint()
      ..color = const Color(0xFF9AB1CC).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = const Color(0xFFDCECFF).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    Path vesselPath;
    if (vesselType == 'flask') {
      // Flask: narrow neck, wide bottom
      final neckW = 22.0;
      final bodyW = vesselW;
      vesselPath = Path()
        ..moveTo(cx - neckW / 2, vesselTop)
        ..lineTo(cx + neckW / 2, vesselTop)
        ..lineTo(cx + bodyW / 2, vesselBottom - 10)
        ..arcToPoint(Offset(cx - bodyW / 2, vesselBottom - 10),
            radius: const Radius.circular(12), clockwise: true)
        ..lineTo(cx - neckW / 2, vesselTop)
        ..close();
    } else {
      // Beaker or tube
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTRB(vesselLeft, vesselTop, vesselRight, vesselBottom),
        vesselType == 'tube' ? const Radius.circular(20) : const Radius.circular(6),
      );
      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, vesselPaint);
      vesselPath = Path()..addRRect(rrect);
    }

    if (vesselType == 'flask') {
      canvas.drawPath(vesselPath, fillPaint);
      canvas.drawPath(vesselPath, vesselPaint);
    }

    // ── Clip to vessel ────────────────────────────────────────────────────────────
    canvas.save();
    canvas.clipPath(vesselType == 'flask' ? vesselPath : (Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(vesselLeft + 2, vesselTop + 2, vesselRight - 2, vesselBottom - 2),
        vesselType == 'tube' ? const Radius.circular(19) : const Radius.circular(5)))));

    // ── Liquid ────────────────────────────────────────────────────────────────────
    final liquidTop = vesselTop + vesselH * (1 - liquidFraction);
    final liquidPaint = Paint()
      ..color = liquidColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTRB(vesselLeft + 2, liquidTop, vesselRight - 2, vesselBottom - 2), liquidPaint);

    // ── Precipitate layer ─────────────────────────────────────────────────────────
    if (pptFraction > 0.01 && pptColor != Colors.transparent) {
      final pptH = vesselH * 0.15 * pptFraction;
      final pptPaint = Paint()
        ..color = pptColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTRB(vesselLeft + 2, vesselBottom - 2 - pptH, vesselRight - 2, vesselBottom - 2), pptPaint);
    }

    // ── Bubbles ───────────────────────────────────────────────────────────────────
    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.8)..style = PaintingStyle.fill;
    for (final b in bubbles) {
      if (b.opacity <= 0) continue;
      final bx = vesselLeft + (vesselRight - vesselLeft) * b.x;
      final by = vesselTop + (vesselBottom - vesselTop) * b.y;
      bubblePaint.color = Colors.white.withValues(alpha: b.opacity * 0.8);
      canvas.drawCircle(Offset(bx, by), b.size / 2, bubblePaint);
    }

    // ── Metal piece ───────────────────────────────────────────────────────────────
    final metalOpacity = math.max(0.1, 1 - metalProgress / 100);
    final metalW = powder ? (20 + (1 - metalProgress / 100) * 40) : (14 + (1 - metalProgress / 100) * 25);
    final metalH2 = powder ? 8.0 : (8 + (1 - metalProgress / 100) * 12);
    final metalPaint = Paint()..color = metalColor.withValues(alpha: metalOpacity)..style = PaintingStyle.fill;
    final metalBorderPaint = Paint()
      ..color = Colors.grey.withValues(alpha: metalOpacity * 0.5)
      ..style = PaintingStyle.stroke..strokeWidth = 1;
    final metalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, liquidTop + (vesselBottom - liquidTop) * 0.45),
          width: metalW, height: metalH2),
      const Radius.circular(3),
    );
    canvas.drawRRect(metalRect, metalPaint);
    canvas.drawRRect(metalRect, metalBorderPaint);

    canvas.restore();

    // ── Flame ─────────────────────────────────────────────────────────────────────
    if (showFlame) {
      final flamePaint = Paint()..color = const Color(0xFFFB923C).withValues(alpha: 0.9)..style = PaintingStyle.fill;
      final flamePath = Path()
        ..moveTo(cx, vesselBottom + 5)
        ..lineTo(cx - 12, vesselBottom + 28)
        ..quadraticBezierTo(cx, vesselBottom + 18, cx + 12, vesselBottom + 28)
        ..close();
      canvas.drawPath(flamePath, flamePaint);
    }

    // ── Surface / bench ───────────────────────────────────────────────────────────
    final surfacePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
      ).createShader(Rect.fromLTWH(cx - 80, h - 14, 160, 12))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, h - 8), width: 160, height: 10), const Radius.circular(8)),
      surfacePaint,
    );
  }

  @override
  bool shouldRepaint(_VesselCustomPainter old) => true;
}

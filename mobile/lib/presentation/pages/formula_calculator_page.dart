import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../injection_container.dart';
import '../bloc/element_bloc.dart';
import '../bloc/element_state.dart';
import '../../domain/entities/element.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/formula_bloc.dart';
import '../bloc/formula_event.dart';
import '../bloc/formula_state.dart';
import '../../domain/entities/formula.dart';

// ---------------------------------------------------------------------------
// Local element data — mirrors the HTML demo so the calculator always works
// even when the API has not loaded yet.
// ---------------------------------------------------------------------------
class _LE {
  final int n;
  final String sym;
  final String name;
  final double mass;
  final int period;
  final String cat; // metal | nonmetal | noble | metalloid | actinide
  const _LE(this.n, this.sym, this.name, this.mass, this.period, this.cat);
}

const List<_LE> _kElements = [
  _LE(1,'H','Vodorod',1.008,1,'nonmetal'),
  _LE(2,'He','Geliy',4.003,1,'noble'),
  _LE(3,'Li','Litiy',6.941,2,'metal'),
  _LE(4,'Be','Berilliy',9.012,2,'metal'),
  _LE(5,'B','Bor',10.811,2,'metalloid'),
  _LE(6,'C','Uglerod',12.011,2,'nonmetal'),
  _LE(7,'N','Azot',14.007,2,'nonmetal'),
  _LE(8,'O','Kislorod',15.999,2,'nonmetal'),
  _LE(9,'F','Ftor',18.998,2,'nonmetal'),
  _LE(10,'Ne','Neon',20.18,2,'noble'),
  _LE(11,'Na','Natriy',22.99,3,'metal'),
  _LE(12,'Mg','Magniy',24.305,3,'metal'),
  _LE(13,'Al','Alyuminiy',26.982,3,'metal'),
  _LE(14,'Si','Kremniy',28.086,3,'metalloid'),
  _LE(15,'P','Fosfor',30.974,3,'nonmetal'),
  _LE(16,'S','Oltingugurt',32.06,3,'nonmetal'),
  _LE(17,'Cl','Xlor',35.45,3,'nonmetal'),
  _LE(18,'Ar','Argon',39.948,3,'noble'),
  _LE(19,'K','Kaliy',39.098,4,'metal'),
  _LE(20,'Ca','Kaltsiy',40.078,4,'metal'),
  _LE(21,'Sc','Skandiy',44.956,4,'metal'),
  _LE(22,'Ti','Titan',47.867,4,'metal'),
  _LE(23,'V','Vanadiy',50.942,4,'metal'),
  _LE(24,'Cr','Xrom',51.996,4,'metal'),
  _LE(25,'Mn','Marganets',54.938,4,'metal'),
  _LE(26,'Fe','Temir',55.845,4,'metal'),
  _LE(27,'Co','Kobalt',58.933,4,'metal'),
  _LE(28,'Ni','Nikel',58.693,4,'metal'),
  _LE(29,'Cu','Mis',63.546,4,'metal'),
  _LE(30,'Zn','Rux',65.38,4,'metal'),
  _LE(31,'Ga','Galliy',69.723,4,'metal'),
  _LE(32,'Ge','Germaniy',72.63,4,'metalloid'),
  _LE(33,'As','Mishyak',74.922,4,'metalloid'),
  _LE(34,'Se','Selen',78.971,4,'nonmetal'),
  _LE(35,'Br','Brom',79.904,4,'nonmetal'),
  _LE(36,'Kr','Kripton',83.798,4,'noble'),
  _LE(37,'Rb','Rubidiy',85.468,5,'metal'),
  _LE(38,'Sr','Stronsiy',87.62,5,'metal'),
  _LE(39,'Y','Itriy',88.906,5,'metal'),
  _LE(40,'Zr','Zirkoniy',91.224,5,'metal'),
  _LE(41,'Nb','Niobiy',92.906,5,'metal'),
  _LE(42,'Mo','Molibden',95.95,5,'metal'),
  _LE(43,'Tc','Texnetsiy',98.0,5,'metal'),
  _LE(44,'Ru','Ruteniy',101.07,5,'metal'),
  _LE(45,'Rh','Rodiy',102.906,5,'metal'),
  _LE(46,'Pd','Palladiy',106.42,5,'metal'),
  _LE(47,'Ag','Kumush',107.868,5,'metal'),
  _LE(48,'Cd','Kadmiy',112.414,5,'metal'),
  _LE(49,'In','Indiy',114.818,5,'metal'),
  _LE(50,'Sn','Qalay',118.71,5,'metal'),
  _LE(51,'Sb','Surma',121.76,5,'metalloid'),
  _LE(52,'Te','Tellur',127.6,5,'metalloid'),
  _LE(53,'I','Yod',126.904,5,'nonmetal'),
  _LE(54,'Xe','Ksenon',131.293,5,'noble'),
  _LE(55,'Cs','Seziy',132.905,6,'metal'),
  _LE(56,'Ba','Bariy',137.327,6,'metal'),
  _LE(57,'La','Lantan',138.905,6,'metal'),
  _LE(58,'Ce','Seriy',140.116,6,'metal'),
  _LE(59,'Pr','Prazeodim',140.908,6,'metal'),
  _LE(60,'Nd','Neodim',144.242,6,'metal'),
  _LE(61,'Pm','Prometiy',145.0,6,'metal'),
  _LE(62,'Sm','Samariy',150.36,6,'metal'),
  _LE(63,'Eu','Evropiy',151.964,6,'metal'),
  _LE(64,'Gd','Gadoliniy',157.25,6,'metal'),
  _LE(65,'Tb','Terbiy',158.925,6,'metal'),
  _LE(66,'Dy','Disproziy',162.5,6,'metal'),
  _LE(67,'Ho','Golmiy',164.93,6,'metal'),
  _LE(68,'Er','Erbiy',167.259,6,'metal'),
  _LE(69,'Tm','Tuliy',168.934,6,'metal'),
  _LE(70,'Yb','Itterbiy',173.045,6,'metal'),
  _LE(71,'Lu','Lyutetiy',174.967,6,'metal'),
  _LE(72,'Hf','Hafniy',178.49,6,'metal'),
  _LE(73,'Ta','Tantal',180.948,6,'metal'),
  _LE(74,'W','Volfram',183.84,6,'metal'),
  _LE(75,'Re','Reniy',186.207,6,'metal'),
  _LE(76,'Os','Osmiy',190.23,6,'metal'),
  _LE(77,'Ir','Iridiy',192.217,6,'metal'),
  _LE(78,'Pt','Platina',195.084,6,'metal'),
  _LE(79,'Au','Oltin',196.967,6,'metal'),
  _LE(80,'Hg','Simob',200.592,6,'metal'),
  _LE(81,'Tl','Talliy',204.38,6,'metal'),
  _LE(82,'Pb',"Qo'rg'oshin",207.2,6,'metal'),
  _LE(83,'Bi','Vismut',208.98,6,'metal'),
  _LE(84,'Po','Poloniy',209.0,6,'metalloid'),
  _LE(85,'At','Astat',210.0,6,'nonmetal'),
  _LE(86,'Rn','Radon',222.0,6,'noble'),
  _LE(87,'Fr','Fransiy',223.0,7,'metal'),
  _LE(88,'Ra','Radiy',226.0,7,'metal'),
  _LE(89,'Ac','Aktiniy',227.0,7,'actinide'),
  _LE(90,'Th','Toriy',232.038,7,'actinide'),
  _LE(91,'Pa','Protaktiniy',231.036,7,'actinide'),
  _LE(92,'U','Uran',238.029,7,'actinide'),
  _LE(93,'Np','Neptuniy',237.0,7,'actinide'),
  _LE(94,'Pu','Plutoniy',244.0,7,'actinide'),
  _LE(95,'Am','Ameritsiy',243.0,7,'actinide'),
  _LE(96,'Cm','Kyuriy',247.0,7,'actinide'),
  _LE(97,'Bk','Berkeliy',247.0,7,'actinide'),
  _LE(98,'Cf','Kaliforniy',251.0,7,'actinide'),
  _LE(99,'Es','Eynshteiniy',252.0,7,'actinide'),
  _LE(100,'Fm','Fermiy',257.0,7,'actinide'),
  _LE(101,'Md','Mendeleviy',258.0,7,'actinide'),
  _LE(102,'No','Nobeliy',259.0,7,'actinide'),
  _LE(103,'Lr','Lorensiy',266.0,7,'actinide'),
  _LE(104,'Rf','Rezerfordiy',267.0,7,'metal'),
  _LE(105,'Db','Dubniy',268.0,7,'metal'),
  _LE(106,'Sg','Siborgiy',269.0,7,'metal'),
  _LE(107,'Bh','Boriy',270.0,7,'metal'),
  _LE(108,'Hs','Xassiy',269.0,7,'metal'),
  _LE(109,'Mt','Meyteriy',278.0,7,'metal'),
  _LE(110,'Ds','Darmshtadtiy',281.0,7,'metal'),
  _LE(111,'Rg','Rentgeniy',282.0,7,'metal'),
  _LE(112,'Cn','Koperniysiy',285.0,7,'metal'),
  _LE(113,'Nh','Nihoniy',286.0,7,'metal'),
  _LE(114,'Fl','Fleroviy',289.0,7,'metal'),
  _LE(115,'Mc','Moskoviy',290.0,7,'metal'),
  _LE(116,'Lv','Livermoriy',293.0,7,'metal'),
  _LE(117,'Ts','Tennessiy',294.0,7,'nonmetal'),
  _LE(118,'Og','Oganesson',294.0,7,'noble'),
];

// Local popular formulas — fallback when FormulaBloc has not loaded yet
const List<Map<String, String>> _kPopular = [
  {'formula': 'H2O',       'name': 'Suv'},
  {'formula': 'NaCl',      'name': 'Osh tuzi'},
  {'formula': 'CO2',       'name': 'Karbonat angidrid'},
  {'formula': 'H2SO4',     'name': 'Sulfat kislota'},
  {'formula': 'HCl',       'name': 'Xlorid kislota'},
  {'formula': 'NH3',       'name': 'Ammiak'},
  {'formula': 'C6H12O6',   'name': 'Glukoza'},
  {'formula': 'Ca(OH)2',   'name': 'Kaltsiy gidroksid'},
  {'formula': 'Na2CO3',    'name': 'Soda'},
  {'formula': 'KMnO4',     'name': 'Kaliy permanganat'},
  {'formula': 'HNO3',      'name': 'Azot kislota'},
  {'formula': 'H3PO4',     'name': 'Fosfor kislota'},
  {'formula': 'NaOH',      'name': 'Natriy gidroksid'},
  {'formula': 'CaCO3',     'name': 'Kaltsiy karbonat'},
  {'formula': 'Al2O3',     'name': 'Alyuminiy oksid'},
];

// Fast lookup: symbol → local mass
double? _localMass(String sym) {
  for (final e in _kElements) {
    if (e.sym == sym) return e.mass;
  }
  return null;
}

bool _isKnownElement(String sym) {
  for (final e in _kElements) {
    if (e.sym == sym) return true;
  }
  return false;
}

// ---------------------------------------------------------------------------

class FormulaCalculatorPage extends StatefulWidget {
  const FormulaCalculatorPage({super.key});

  @override
  State<FormulaCalculatorPage> createState() => _FormulaCalculatorPageState();
}

class _FormulaCalculatorPageState extends State<FormulaCalculatorPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  Map<String, int>? _resultElements;
  double _totalMass = 0;
  int _coefficient = 1;
  String? _error;
  late TabController _tabController;

  String _activeCategory = 'all';
  int _activePeriod = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Subscript helpers
  // -------------------------------------------------------------------------

  String _toSubscript(String text) {
    const Map<String, String> sub = {
      '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄',
      '5': '₅', '6': '₆', '7': '₇', '8': '₈', '9': '₉',
    };
    final buf = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      if (RegExp(r'\d').hasMatch(ch)) {
        // Only convert to subscript when preceded by a letter or ')'
        if (i > 0 && RegExp(r'[A-Za-z)]').hasMatch(text[i - 1])) {
          buf.write(sub[ch] ?? ch);
        } else {
          buf.write(ch);
        }
      } else {
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  String _fromSubscript(String text) {
    const Map<String, String> normal = {
      '₀': '0', '₁': '1', '₂': '2', '₃': '3', '₄': '4',
      '₅': '5', '₆': '6', '₇': '7', '₈': '8', '₉': '9',
    };
    final buf = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buf.write(normal[text[i]] ?? text[i]);
    }
    return buf.toString();
  }

  // -------------------------------------------------------------------------
  // Core calculation — uses API element masses first, local data as fallback
  // -------------------------------------------------------------------------

  void _calculate(List<ElementEntity> apiElements) {
    final rawFormula = _controller.text.trim();
    if (rawFormula.isEmpty) return;

    // Convert subscripts back to plain digits and strip any stray spaces
    final formula = _fromSubscript(rawFormula).replaceAll(RegExp(r'\s+'), '');
    if (formula.isEmpty) return;

    try {
      // Strip optional leading integer coefficient (e.g. "2H2O")
      final coeffMatch = RegExp(r'^(\d+)').firstMatch(formula);
      int coeff = 1;
      String pureFormula = formula;
      if (coeffMatch != null) {
        coeff = int.parse(coeffMatch.group(1)!);
        pureFormula = formula.substring(coeffMatch.group(1)!.length);
      }

      final parsed = _parseFormula(pureFormula, apiElements);
      if (parsed.isEmpty) throw Exception('empty');

      double mass = 0;
      parsed.forEach((sym, cnt) {
        // Prefer API mass (may be more precise), fall back to local table
        final apiEl = apiElements.where((e) => e.symbol == sym).firstOrNull;
        final double elMass = apiEl?.mass ?? _localMass(sym)!;
        mass += elMass * cnt;
      });

      setState(() {
        _resultElements = parsed;
        _coefficient = coeff;
        _totalMass = mass * coeff;
        _error = null;
      });
    } catch (_) {
      setState(() {
        _error = context.tr('formula_invalid');
        _resultElements = null;
      });
    }
  }

  // -------------------------------------------------------------------------
  // Recursive descent parser — validates against API list OR local table
  // -------------------------------------------------------------------------

  Map<String, int> _parseFormula(String formula, List<ElementEntity> apiElements) {
    int pos = 0;

    Map<String, int> parse(String s) {
      final Map<String, int> res = {};
      while (pos < s.length && s[pos] != ')') {
        if (s[pos] == '(') {
          pos++;
          final sub = parse(s);
          if (pos < s.length && s[pos] == ')') pos++;
          String num = '';
          while (pos < s.length && RegExp(r'\d').hasMatch(s[pos])) {
            num += s[pos];
            pos++;
          }
          final mult = num.isEmpty ? 1 : int.parse(num);
          sub.forEach((k, v) => res[k] = (res[k] ?? 0) + v * mult);
        } else if (RegExp(r'[A-Z]').hasMatch(s[pos])) {
          String sym = s[pos];
          pos++;
          while (pos < s.length && RegExp(r'[a-z]').hasMatch(s[pos])) {
            sym += s[pos];
            pos++;
          }
          String num = '';
          while (pos < s.length && RegExp(r'\d').hasMatch(s[pos])) {
            num += s[pos];
            pos++;
          }
          final cnt = num.isEmpty ? 1 : int.parse(num);
          // Accept element if found in API data OR in local table
          final knownInApi = apiElements.any((e) => e.symbol == sym);
          if (!knownInApi && !_isKnownElement(sym)) {
            throw Exception('Unknown element: $sym');
          }
          res[sym] = (res[sym] ?? 0) + cnt;
        } else {
          pos++; // skip unknown chars (e.g. dots, spaces)
        }
      }
      return res;
    }

    return parse(formula);
  }

  // -------------------------------------------------------------------------
  // Keyboard input
  // -------------------------------------------------------------------------

  void _onKeyTap(String key, List<ElementEntity> allElements) {
    final text = _controller.text;
    String newText;

    if (key == 'BACKSPACE') {
      newText = text.isEmpty ? '' : text.substring(0, text.length - 1);
    } else if (key == 'CLEAR') {
      newText = '';
      setState(() {
        _resultElements = null;
        _error = null;
      });
    } else {
      newText = text + key;
    }

    setState(() {
      _controller.text = _toSubscript(newText);
    });
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider<FormulaBloc>(
          create: (context) => sl<FormulaBloc>()..add(LoadFormulasEvent()),
        ),
      ],
      child: BlocBuilder<ElementBloc, ElementState>(
        bloc: sl<ElementBloc>(),
        builder: (context, elementState) {
          final allElements =
              elementState is ElementLoaded ? elementState.elements : <ElementEntity>[];

          return BlocBuilder<FormulaBloc, FormulaState>(
            builder: (context, formulaState) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(context.tr('formula_calc_title')),
                  centerTitle: true,
                ),
                body: Column(
                  children: [
                    // Result display
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildScreen(context, isDark, allElements),
                        ],
                      ),
                    ),
                    // Keyboard
                    _buildAdvancedKeyboard(context, allElements, formulaState),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Screen (display + result card)
  // -------------------------------------------------------------------------

  Widget _buildScreen(
      BuildContext context, bool isDark, List<ElementEntity> allElements) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('formula_input_hint'),
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          // Formula display with tokens
          Container(
            constraints: const BoxConstraints(minHeight: 50),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_controller.text.isEmpty)
                  Text(
                    context.tr('formula_example'),
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  )
                else
                  ..._buildFormulaTokens(context),
                _buildCursor(),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          if (_resultElements != null) ...[
            const SizedBox(height: 16),
            _buildResultCard(allElements),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Formula token rendering (matches HTML demo's formatFormula)
  // -------------------------------------------------------------------------

  List<Widget> _buildFormulaTokens(BuildContext context) {
    final text = _controller.text;
    final widgets = <Widget>[];
    int i = 0;
    while (i < text.length) {
      final ch = text[i];

      if (ch == '(' || ch == ')') {
        widgets.add(Text(
          ch,
          style: const TextStyle(fontSize: 22, color: Colors.grey),
        ));
        i++;
        continue;
      }

      // Subscript digits
      if (RegExp(r'[₀-₉]').hasMatch(ch)) {
        widgets.add(Text(
          ch,
          style: const TextStyle(
              fontSize: 16,
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold),
        ));
        i++;
        continue;
      }

      // Plain leading digits (coefficient)
      if (RegExp(r'\d').hasMatch(ch)) {
        widgets.add(Text(
          ch,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ));
        i++;
        continue;
      }

      // Element symbol — collect uppercase + optional lowercase
      if (RegExp(r'[A-Z]').hasMatch(ch)) {
        String sym = ch;
        int j = i + 1;
        while (j < text.length && RegExp(r'[a-z]').hasMatch(text[j])) {
          sym += text[j];
          j++;
        }
        widgets.add(Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            sym,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPurple),
          ),
        ));
        i = j;
        continue;
      }

      widgets.add(Text(ch, style: const TextStyle(fontSize: 22)));
      i++;
    }
    return widgets;
  }

  Widget _buildCursor() {
    return Container(
      width: 2,
      height: 24,
      color: AppColors.primaryPurple,
      margin: const EdgeInsets.only(left: 2),
    );
  }

  // -------------------------------------------------------------------------
  // Result card
  // -------------------------------------------------------------------------

  Widget _buildResultCard(List<ElementEntity> apiElements) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Molekulyar massa',
            style: TextStyle(color: Color(0xFF0F6E56), fontSize: 11),
          ),
          Text(
            '${_totalMass.toStringAsFixed(3)} g/mol',
            style: const TextStyle(
                color: Color(0xFF085041),
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _buildBreakdownText(apiElements),
            style: const TextStyle(
                color: Color(0xFF0F6E56), fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }

  String _buildBreakdownText(List<ElementEntity> apiElements) {
    final buf = StringBuffer();
    if (_coefficient > 1) buf.writeln('Koeffitsient: $_coefficient');
    _resultElements!.forEach((sym, cnt) {
      final apiEl = apiElements.where((e) => e.symbol == sym).firstOrNull;
      final elMass = apiEl?.mass ?? _localMass(sym) ?? 0.0;
      buf.writeln(
          '$sym: ${elMass.toStringAsFixed(3)} × $cnt = ${(elMass * cnt).toStringAsFixed(3)}');
    });
    buf.write('\nJami: ${_totalMass.toStringAsFixed(3)} g/mol');
    return buf.toString().trim();
  }

  // -------------------------------------------------------------------------
  // Advanced keyboard
  // -------------------------------------------------------------------------

  Widget _buildAdvancedKeyboard(
      BuildContext context,
      List<ElementEntity> allElements,
      FormulaState formulaState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primaryPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryPurple,
            tabs: const [
              Tab(text: 'Elementlar'),
              Tab(text: 'Raqamlar'),
              Tab(text: 'Belgilar'),
              Tab(text: 'Mashhur'),
            ],
          ),
          SizedBox(
            height: 260,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildElementsPanel(allElements),
                _buildNumbersPanel(allElements),
                _buildSymbolsPanel(allElements),
                _buildPopularPanel(allElements, formulaState),
              ],
            ),
          ),
          _buildActionRow(allElements),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Elements panel — always uses local _kElements, enriched with API names
  // -------------------------------------------------------------------------

  static const _kCats = ['all', 'metal', 'nonmetal', 'metalloid', 'noble', 'actinide'];
  static const _kCatLabels = [
    'Hammasi', 'Metall', 'Metall emas', 'Metalloid', 'Inert gaz', 'Aktinid',
  ];

  Widget _buildElementsPanel(List<ElementEntity> apiElements) {
    final filtered = _filteredLocalElements();

    return Column(
      children: [
        // Category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: List.generate(_kCats.length, (i) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(_kCatLabels[i],
                    style: const TextStyle(fontSize: 10)),
                selected: _activeCategory == _kCats[i],
                onSelected: (_) =>
                    setState(() => _activeCategory = _kCats[i]),
                selectedColor: AppColors.primaryPurple.withOpacity(0.2),
              ),
            )),
          ),
        ),
        // Period chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
          child: Row(
            children: List.generate(8, (i) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(i == 0 ? 'Hammasi' : '$i-davr',
                    style: const TextStyle(fontSize: 10)),
                selected: _activePeriod == i,
                onSelected: (_) => setState(() => _activePeriod = i),
              ),
            )),
          ),
        ),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final el = filtered[index];
              final apiEl = apiElements
                  .where((e) => e.symbol == el.sym)
                  .firstOrNull;
              final name = apiEl?.getName(context.locale.languageCode) ?? el.name;
              return _buildElementButton(el, name, apiElements);
            },
          ),
        ),
      ],
    );
  }

  List<_LE> _filteredLocalElements() {
    var list = _kElements.toList();
    if (_activeCategory != 'all') {
      list = list.where((e) => e.cat == _activeCategory).toList();
    }
    if (_activePeriod > 0) {
      list = list.where((e) => e.period == _activePeriod).toList();
    }
    return list;
  }

  Widget _buildElementButton(
      _LE el, String displayName, List<ElementEntity> apiElements) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _onKeyTap(el.sym, apiElements),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(el.sym,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _catColor(el.cat, isDark))),
            Text('${el.n}',
                style: TextStyle(
                    fontSize: 8,
                    color: isDark ? Colors.white38 : Colors.black38)),
            Text(
              displayName.length > 8
                  ? '${displayName.substring(0, 8)}.'
                  : displayName,
              style: TextStyle(
                  fontSize: 8,
                  color: isDark ? Colors.white38 : Colors.black38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _catColor(String cat, bool isDark) {
    switch (cat) {
      case 'nonmetal':
        return const Color(0xFF085041);
      case 'noble':
        return const Color(0xFF633806);
      case 'metalloid':
        return const Color(0xFF3C3489);
      case 'actinide':
        return const Color(0xFF791F1F);
      default:
        return isDark ? Colors.white70 : const Color(0xFF0C447C);
    }
  }

  // -------------------------------------------------------------------------
  // Numbers panel
  // -------------------------------------------------------------------------

  Widget _buildNumbersPanel(List<ElementEntity> allElements) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const keys = ['7', '8', '9', '(', '4', '5', '6', ')', '1', '2', '3', '0'];
    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        ...keys.map((k) => _buildNumKey(k, isDark, allElements)),
        _buildNumKey('⌫', isDark, allElements,
            onTap: () => _onKeyTap('BACKSPACE', allElements),
            color: Colors.redAccent),
      ],
    );
  }

  Widget _buildNumKey(
    String label,
    bool isDark,
    List<ElementEntity> allElements, {
    VoidCallback? onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap ?? () => _onKeyTap(label, allElements),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: color ?? (isDark ? Colors.white : Colors.black87)),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Symbols panel
  // -------------------------------------------------------------------------

  Widget _buildSymbolsPanel(List<ElementEntity> allElements) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const syms = [
      {'c': '(', 'l': 'Qavos ochish'},
      {'c': ')', 'l': 'Qavos yopish'},
      {'c': '·', 'l': 'Nuqta'},
      {'c': '•', 'l': 'Qalin nuqta'},
      {'c': '2', 'l': 'Indeks 2'},
      {'c': '3', 'l': 'Indeks 3'},
      {'c': '4', 'l': 'Indeks 4'},
      {'c': '5', 'l': 'Indeks 5'},
      {'c': '6', 'l': 'Indeks 6'},
      {'c': '7', 'l': 'Indeks 7'},
      {'c': '8', 'l': 'Indeks 8'},
      {'c': '9', 'l': 'Indeks 9'},
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: syms.length,
      itemBuilder: (context, i) {
        final s = syms[i];
        return InkWell(
          onTap: () => _onKeyTap(s['c']!, allElements),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s['c']!,
                    style: TextStyle(
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 2),
                Text(s['l']!,
                    style: TextStyle(
                        fontSize: 8,
                        color: isDark ? Colors.white38 : Colors.black45),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Popular panel — API formulas first, local fallback
  // -------------------------------------------------------------------------

  Widget _buildPopularPanel(
      List<ElementEntity> allElements, FormulaState formulaState) {
    if (formulaState is FormulaLoaded && formulaState.formulas.isNotEmpty) {
      return _buildApiPopularList(allElements, formulaState.formulas);
    }
    // Fallback: local popular list (always available)
    return _buildLocalPopularList(allElements);
  }

  Widget _buildApiPopularList(
      List<ElementEntity> allElements, List<FormulaEntity> formulas) {
    final popular =
        formulas.where((f) => f.category == 'popular').toList();
    final carbonates =
        formulas.where((f) => f.category == 'carbonate').toList();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (popular.isNotEmpty) ...[
          _sectionHeader('Mashhur formulalar'),
          ...popular.map((f) => _apiFormulaItem(f, allElements)),
        ],
        if (carbonates.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionHeader('Tuzlar (Karbonatlar)'),
          ...carbonates.map((f) => _apiFormulaItem(f, allElements)),
        ],
      ],
    );
  }

  Widget _buildLocalPopularList(List<ElementEntity> allElements) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _kPopular.length,
      itemBuilder: (context, i) {
        final p = _kPopular[i];
        final formula = p['formula']!;
        final name = p['name']!;
        return _localFormulaItem(formula, name, allElements);
      },
    );
  }

  Widget _localFormulaItem(
      String formula, String name, List<ElementEntity> allElements) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side:
            BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              _toSubscript(formula),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        title: Text(name,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text(formula,
            style:
                TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.grey),
        onTap: () {
          setState(() {
            _controller.text = _toSubscript(formula);
            _error = null;
            _resultElements = null;
          });
          _calculate(allElements);
        },
      ),
    );
  }

  Widget _apiFormulaItem(
      FormulaEntity f, List<ElementEntity> allElements) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              _toSubscript(f.formula),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        title: Text(
          f.getName(context.locale.languageCode),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${f.molarMass.toStringAsFixed(3)} g/mol',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.grey),
        onTap: () {
          setState(() {
            _controller.text = _toSubscript(f.formula);
            _error = null;
            _resultElements = null;
          });
          _calculate(allElements);
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple)),
    );
  }

  // -------------------------------------------------------------------------
  // Action row
  // -------------------------------------------------------------------------

  Widget _buildActionRow(List<ElementEntity> allElements) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _actionBtn(
              '⌫ O\'chir',
              Colors.redAccent.withOpacity(0.1),
              Colors.redAccent,
              () => _onKeyTap('BACKSPACE', allElements),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _actionBtn(
              '✕ Tozala',
              Colors.grey.withOpacity(0.1),
              Colors.grey,
              () => _onKeyTap('CLEAR', allElements),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _actionBtn(
              '= Hisoblash',
              AppColors.primaryPurple,
              Colors.white,
              () => _calculate(allElements),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
      String label, Color bg, Color fg, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import 'alkali_metal_detail_page.dart';

// ─── Element data model ───────────────────────────────────────
class AlkaliElement {
  final int z;
  final String sym, uz, en;
  final double mass;
  final String conf, val;
  final double melt, boil, density;
  final int period, group, discovery;
  final String who, uses, fact;
  final List<int> shells;

  const AlkaliElement({
    required this.z, required this.sym, required this.uz, required this.en,
    required this.mass, required this.conf, required this.val,
    required this.melt, required this.boil, required this.density,
    required this.period, required this.group, required this.discovery,
    required this.who, required this.uses, required this.fact,
    required this.shells,
  });
}

class AlkaliGroup {
  final String key, titleUz, titleRu, titleEn;
  final Color color, chipBg, chipText;
  final List<Color> gradient;
  final List<AlkaliElement> elements;

  const AlkaliGroup({
    required this.key, required this.titleUz, required this.titleRu,
    required this.titleEn, required this.color, required this.chipBg,
    required this.chipText, required this.gradient, required this.elements,
  });
}

// ─── Data ──────────────────────────────────────────────────────
const _alkali = AlkaliGroup(
  key: 'alkali',
  titleUz: 'Ishqoriy metallar',
  titleRu: 'Щелочные металлы',
  titleEn: 'Alkali Metals',
  color: Color(0xFFc62828),
  chipBg: Color(0xFFFFEBEE),
  chipText: Color(0xFF7f0000),
  gradient: [Color(0xFFb71c1c), Color(0xFFe53935)],
  elements: [
    AlkaliElement(z:3,  sym:'Li', uz:'Litiy',   en:'Lithium',   mass:6.941,  conf:'[He] 2s¹',       val:'+1', melt:180.5, boil:1342,  density:0.534, period:2, group:1, discovery:1817, who:'Johan August Arfvedson', shells:[2,1], uses:'Litiy-ion batareyalar, shisha, psixiatrik dori (Li₂CO₃)', fact:'Eng yengil metall — suv ustida suzadi. Alanga karmin-qizil rangli.'),
    AlkaliElement(z:11, sym:'Na', uz:'Natriy',  en:'Sodium',    mass:22.990, conf:'[Ne] 3s¹',       val:'+1', melt:97.7,  boil:882.9, density:0.968, period:3, group:1, discovery:1807, who:'Humphry Davy', shells:[2,8,1], uses:'Osh tuzi (NaCl), NaOH, natriy bug\'li lampalari', fact:'Suv bilan portlash: 2Na + 2H₂O → 2NaOH + H₂↑. Alanga sariq.'),
    AlkaliElement(z:19, sym:'K',  uz:'Kaliy',   en:'Potassium', mass:39.098, conf:'[Ar] 4s¹',       val:'+1', melt:63.4,  boil:758.8, density:0.862, period:4, group:1, discovery:1807, who:'Humphry Davy', shells:[2,8,8,1], uses:'Kaliy o\'g\'itlari (KCl, K₂SO₄), KOH, oziq-ovqat sanoati', fact:'Suv bilan portlash hosil bo\'lishi mumkin. Alanga binafsha-qizil.'),
    AlkaliElement(z:37, sym:'Rb', uz:'Rubidiy', en:'Rubidium',  mass:85.468, conf:'[Kr] 5s¹',       val:'+1', melt:39.3,  boil:688,   density:1.532, period:5, group:1, discovery:1861, who:'Bunsen, Kirchhoff', shells:[2,8,18,8,1], uses:'Atom soatlar (Rb-87), fotoelementlar, GPS qurilmalari', fact:'Nomi "rubidus" — quyuq qizil. Havodagi namlikda o\'z-o\'zi alovlanadi.'),
    AlkaliElement(z:55, sym:'Cs', uz:'Seziy',   en:'Cesium',    mass:132.905,conf:'[Xe] 6s¹',       val:'+1', melt:28.4,  boil:671,   density:1.879, period:6, group:1, discovery:1860, who:'Bunsen, Kirchhoff', shells:[2,8,18,18,8,1], uses:'Atom soatlar (SI sekundi ta\'rifida), GPS, ion dvigatellar', fact:'Xona haroratida deyarli suyuq (Tm=28°C). Eng aniq soatlar Cs-133 asosida.'),
    AlkaliElement(z:87, sym:'Fr', uz:'Fransiy',  en:'Francium',  mass:223,    conf:'[Rn] 7s¹',       val:'+1', melt:27,    boil:677,   density:1.87,  period:7, group:1, discovery:1939, who:'Marguerite Perey', shells:[2,8,18,32,18,8,1], uses:'Faqat ilmiy tadqiqotlarda (radioaktiv, t½ ≈ 22 daqiqa)', fact:'Tabiatda eng kam tarqalgan element. Yer yuzida atigi ~30 gramm bo\'ladi.'),
  ],
);

const _alkaline = AlkaliGroup(
  key: 'alkaline',
  titleUz: 'Ishqoriy-Yer metallar',
  titleRu: 'Щелочноземельные металлы',
  titleEn: 'Alkaline Earth Metals',
  color: Color(0xFFe65100),
  chipBg: Color(0xFFFFF3E0),
  chipText: Color(0xFF7f3000),
  gradient: [Color(0xFFbf360c), Color(0xFFfb8c00)],
  elements: [
    AlkaliElement(z:4,  sym:'Be', uz:'Berilliy',  en:'Beryllium', mass:9.012,   conf:'[He] 2s²',   val:'+2', melt:1287, boil:2469,  density:1.848, period:2, group:2, discovery:1798, who:'Louis-Nicolas Vauquelin', shells:[2,2], uses:'Aerokosmik qotishmalar, rentgen naylari, yadro reaktorlari', fact:'Zaharli metall. X-nurlarni deyarli to\'xtatmaydi — rentgen trubkalarida.'),
    AlkaliElement(z:12, sym:'Mg', uz:'Magniy',    en:'Magnesium', mass:24.305,  conf:'[Ne] 3s²',   val:'+2', melt:650,  boil:1090,  density:1.738, period:3, group:2, discovery:1755, who:'Joseph Black', shells:[2,8,2], uses:'Engil qotishmalar (aviatsiya, avto), tibbiy preparatlar, o\'g\'itlar', fact:'Yonayotganda oq nur chiqaradi (2Mg + O₂ → 2MgO). Xlorofil tarkibida.'),
    AlkaliElement(z:20, sym:'Ca', uz:'Kalsiy',    en:'Calcium',   mass:40.078,  conf:'[Ar] 4s²',   val:'+2', melt:842,  boil:1484,  density:1.55,  period:4, group:2, discovery:1808, who:'Humphry Davy', shells:[2,8,8,2], uses:'Suyak va tishlar (Ca₃(PO₄)₂), sement, ohak (CaCO₃), suv tozalash', fact:'Inson organizmida eng ko\'p metall (1–1.5 kg). Ohaktosh, marmar, bo\'r.'),
    AlkaliElement(z:38, sym:'Sr', uz:'Stronsiy',  en:'Strontium', mass:87.62,   conf:'[Kr] 5s²',   val:'+2', melt:777,  boil:1382,  density:2.64,  period:5, group:2, discovery:1790, who:'Adair Crawford', shells:[2,8,18,8,2], uses:'Otashin alangasi (qizil rang), Sr-90 yadro energetikada', fact:'Sr tuzlari alangaga qo\'shilganda yorqin qizil rang beradi — bayram otashinlari.'),
    AlkaliElement(z:56, sym:'Ba', uz:'Bariy',     en:'Barium',    mass:137.327, conf:'[Xe] 6s²',   val:'+2', melt:727,  boil:1897,  density:3.51,  period:6, group:2, discovery:1808, who:'Humphry Davy', shells:[2,8,18,18,8,2], uses:'Rentgen kontrast moddasi (BaSO₄), shisha ishlab chiqarish', fact:'BaSO₄ suvda erimaydi va zaharli emas — me\'da-ichak rentgenida xavfsiz.'),
    AlkaliElement(z:88, sym:'Ra', uz:'Radiy',     en:'Radium',    mass:226,     conf:'[Rn] 7s²',   val:'+2', melt:700,  boil:1140,  density:5.5,   period:7, group:2, discovery:1898, who:'Marie & Pierre Curie', shells:[2,8,18,32,18,8,2], uses:'O\'tmishda rak davolash, hozirda ilmiy tadqiqotlarda', fact:'Mariya Kyuri kashf etdi. Qorong\'uda yashil yorug\'lik chiqaradi. Juda radioaktiv.'),
  ],
);

const _groups = [_alkali, _alkaline];

// ─── List Page ─────────────────────────────────────────────────
class AlkaliMetalsListPage extends StatefulWidget {
  const AlkaliMetalsListPage({super.key});

  @override
  State<AlkaliMetalsListPage> createState() => _AlkaliMetalsListPageState();
}

class _AlkaliMetalsListPageState extends State<AlkaliMetalsListPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldBackgroundDark : const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('alkali_page_title'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('Davriy jadval · I–II A guruh',
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: isDark ? AppColors.scaffoldBackgroundDark : const Color(0xFFF4F6FB),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
                decoration: InputDecoration(
                  hintText: context.tr('alkali_search_hint'),
                  hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey[400]),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: isDark ? Colors.white38 : Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () { _controller.clear(); setState(() => _query = ''); },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 32),
              itemCount: _groups.length * 2,
              itemBuilder: (ctx, i) {
                final grpIdx = i ~/ 2;
                final isHeader = i % 2 == 0;
                final grp = _groups[grpIdx];

                if (isHeader) {
                  final filtered = _filteredElements(grp.elements);
                  if (filtered.isEmpty) return const SizedBox.shrink();
                  return _SectionHeader(
                    title: _grpTitle(grp, lang),
                    color: grp.color,
                    count: filtered.length,
                  );
                }

                final elements = _filteredElements(grp.elements);
                if (elements.isEmpty) return const SizedBox.shrink();

                return Column(
                  children: [
                    ...elements.map((el) => _ElementCard(
                      el: el, grp: grp, isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AlkaliMetalDetailPage(el: el, grp: grp, allGroups: _groups)),
                      ),
                    )),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<AlkaliElement> _filteredElements(List<AlkaliElement> list) {
    if (_query.isEmpty) return list;
    return list.where((e) =>
      e.uz.toLowerCase().contains(_query) ||
      e.en.toLowerCase().contains(_query) ||
      e.sym.toLowerCase().contains(_query) ||
      e.z.toString().contains(_query)
    ).toList();
  }

  String _grpTitle(AlkaliGroup g, String lang) {
    if (lang == 'ru') return g.titleRu;
    if (lang == 'en') return g.titleEn;
    return g.titleUz;
  }
}

// ─── Section Header ────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final int count;
  const _SectionHeader({required this.title, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.8)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
            child: Text('$count ta', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── Element Card ──────────────────────────────────────────────
class _ElementCard extends StatelessWidget {
  final AlkaliElement el;
  final AlkaliGroup grp;
  final bool isDark;
  final VoidCallback onTap;
  const _ElementCard({required this.el, required this.grp, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .15 : .05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.hardEdge,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                // Left color strip
                Container(
                  width: 5, height: 80,
                  decoration: BoxDecoration(
                    color: grp.color,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                  ),
                ),
                // Symbol box
                Container(
                  width: 68, height: 80,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFF0F0F4))),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${el.z}', style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey[400], fontWeight: FontWeight.w500)),
                      Text(el.sym, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: grp.color, height: 1.1)),
                      Text('${el.mass}', style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.grey[400])),
                    ],
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(el.uz, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textPrimary)),
                        Text(el.en, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[500])),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4, runSpacing: 3,
                          children: [
                            _chip('val: ${el.val}', grp.chipBg, grp.chipText, isDark),
                            _chip('${el.melt.toInt()}°C eritish', grp.chipBg, grp.chipText, isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Arrow
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right_rounded, size: 20,
                      color: isDark ? Colors.white24 : const Color(0xFFC5B9E8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : text)),
    );
  }
}

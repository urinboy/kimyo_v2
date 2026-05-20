import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'alkali_metals_list_page.dart';

// ─── Orbit painter ─────────────────────────────────────────────
class _OrbitPainter extends CustomPainter {
  final Color color;
  final List<double> configs; // [rx1,ry1, rx2,ry2, ...]
  _OrbitPainter({required this.color, required this.configs});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final paint = Paint()
      ..color = color.withOpacity(.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < configs.length; i += 2) {
      final rx = configs[i];
      final ry = configs[i + 1];
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => color != old.color;
}

// ─── Electron dot animation ─────────────────────────────────────
class _ElectronDot extends StatefulWidget {
  final Color color;
  final double orbitRx, orbitRy;
  final double speed;
  final double startAngle;
  const _ElectronDot({
    required this.color, required this.orbitRx, required this.orbitRy,
    required this.speed, required this.startAngle,
  });
  @override State<_ElectronDot> createState() => _ElectronDotState();
}

class _ElectronDotState extends State<_ElectronDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: (widget.speed * 1000).toInt()))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final angle = widget.startAngle + _ctrl.value * 2 * math.pi;
        final dx = widget.orbitRx * math.cos(angle);
        final dy = widget.orbitRy * math.sin(angle);
        return Positioned(
          left: 100 + dx - 5,
          top:  100 + dy - 5,
          child: Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: widget.color.withOpacity(.7), blurRadius: 8, spreadRadius: 1)],
            ),
          ),
        );
      },
    );
  }
}

// ─── Atom Widget ───────────────────────────────────────────────
class _AtomWidget extends StatefulWidget {
  final AlkaliElement el;
  final AlkaliGroup grp;
  const _AtomWidget({required this.el, required this.grp});
  @override State<_AtomWidget> createState() => _AtomWidgetState();
}

class _AtomWidgetState extends State<_AtomWidget> with SingleTickerProviderStateMixin {
  late AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
  }
  @override
  void dispose() { _float.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final el = widget.el;
    final grp = widget.grp;
    final n = math.min(el.shells.length, 4);
    final baseRx = 72.0;
    final baseRy = 22.0;

    final orbitConfigs = <double>[];
    for (int i = 0; i < n; i++) {
      final scale = 0.45 + i * 0.16;
      orbitConfigs.addAll([baseRx * scale, baseRy * (1.8 + i * 0.5)]);
    }

    return SizedBox(
      width: 200, height: 200,
      child: Stack(
        children: [
          // Orbit rings
          CustomPaint(
            size: const Size(200, 200),
            painter: _OrbitPainter(color: grp.color, configs: orbitConfigs),
          ),

          // Electrons
          for (int i = 0; i < n; i++)
            _ElectronDot(
              color: grp.hi,
              orbitRx: orbitConfigs[i * 2],
              orbitRy: orbitConfigs[i * 2 + 1],
              speed: 3.5 + i * 1.5,
              startAngle: (i * 1.05) % (2 * math.pi),
            ),

          // Sphere (floating)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _float,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, -6 + 12 * _float.value),
                child: child,
              ),
              child: Center(
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.35, -0.35),
                      radius: 1.0,
                      colors: [
                        Colors.white.withOpacity(.55),
                        grp.hi,
                        grp.color,
                        grp.drk,
                      ],
                      stops: const [0.0, 0.18, 0.52, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(color: grp.color.withOpacity(.45), blurRadius: 40, spreadRadius: 4),
                      BoxShadow(color: grp.color.withOpacity(.2),  blurRadius: 80, spreadRadius: 10),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${el.z}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.6), fontWeight: FontWeight.w300)),
                      Text(el.sym, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white,
                          shadows: [Shadow(color: Colors.black38, blurRadius: 10)]), ),
                      Text(el.en.toUpperCase(), style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(.75), letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Shine
          Positioned(
            left: 72, top: 48,
            child: Container(
              width: 38, height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(.4), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Page ───────────────────────────────────────────────
class AlkaliMetalDetailPage extends StatelessWidget {
  final AlkaliElement el;
  final AlkaliGroup grp;
  final List<AlkaliGroup> allGroups;

  const AlkaliMetalDetailPage({
    super.key,
    required this.el,
    required this.grp,
    required this.allGroups,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: grp.gradient,
    );
    final pageBg = isDark ? AppColors.scaffoldBackgroundDark : (grp.key == 'alkali' ? const Color(0xFFFFF6F5) : const Color(0xFFFFF9F0));

    return Scaffold(
      backgroundColor: pageBg,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar with Hero section ──
          SliverAppBar(
            expandedHeight: 370,
            pinned: true,
            stretch: true,
            backgroundColor: grp.drk,
            leading: IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${el.uz} (${el.sym})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(grp.titleUz, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 14),
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text('${el.z}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: gradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pinned AppBar (~60px) + status bar (~24px) → 84px boʻshliq
                    const SizedBox(height: 84),
                    _AtomWidget(el: el, grp: grp),
                    const SizedBox(height: 10),
                    Text('${el.uz} (${el.sym})',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(grp.titleUz.toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 1.0)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 40),
              child: Column(
                children: [
                  // Quick stats
                  Row(children: [
                    _qsCard('${el.mass}', 'Atom massasi', grp.color),
                    const SizedBox(width: 8),
                    _qsCard(el.val, 'Valentligi', grp.color),
                    const SizedBox(width: 8),
                    _qsCard('${el.density}', 'g/cm³', grp.color),
                  ]),
                  const SizedBox(height: 12),

                  // Asosiy xususiyatlar
                  _infoCard(
                    isDark: isDark,
                    title: 'Asosiy xususiyatlari',
                    color: grp.color,
                    children: [
                      _confChip(el.conf, isDark, grp),
                      _row('Atom raqami (Z)', '${el.z}', isDark),
                      _row('Atom massasi', '${el.mass} a.e.m.', isDark),
                      _row('Valentligi', el.val, isDark),
                      _row('Davr / Guruh', '${el.period}-davr, ${el.group}-guruh', isDark),
                      _row('Zichlik', '${el.density} g/cm³', isDark),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Issiqlik
                  _infoCard(
                    isDark: isDark,
                    title: 'Issiqlik xususiyatlari',
                    color: grp.color,
                    children: [
                      _row('Eritish harorati', '${el.melt} °C', isDark),
                      _row('Qaynash harorati', '${el.boil} °C', isDark),
                      _row('Agregat holati (25°C)', el.melt < 25 ? '🟡 Suyuq' : '⬜ Qattiq', isDark),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Elektron qavatlari
                  _shellsCard(isDark, grp),
                  const SizedBox(height: 12),

                  // Kashfiyot
                  _infoCard(
                    isDark: isDark,
                    title: 'Kashfiyot',
                    color: grp.color,
                    children: [
                      _row('Yili', '${el.discovery}', isDark),
                      _row('Kashf etgan', el.who, isDark, smallVal: true),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Qo'llanilishi
                  _infoCard(
                    isDark: isDark,
                    title: 'Qo\'llanilishi',
                    color: grp.color,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: Text(el.uses,
                            style: TextStyle(fontSize: 13, height: 1.6, color: isDark ? Colors.white70 : AppColors.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Fakt
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: gradient,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('QIZIQARLI FAKT',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                      color: Colors.white70, letterSpacing: 1.0)),
                              const SizedBox(height: 8),
                              Text(el.fact,
                                  style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.6)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('💡', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Related
                  _infoCard(
                    isDark: isDark,
                    title: '${grp.titleUz} — barchasi',
                    color: grp.color,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Wrap(
                          spacing: 8, runSpacing: 8,
                          children: grp.elements.map((sib) {
                            final isActive = sib.z == el.z;
                            return GestureDetector(
                              onTap: isActive ? null : () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => AlkaliMetalDetailPage(
                                  el: sib, grp: grp, allGroups: allGroups,
                                )),
                              ),
                              child: Container(
                                width: 68,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isActive ? grp.color.withOpacity(.1) : (isDark ? Colors.white.withOpacity(.05) : const Color(0xFFFAFAFA)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isActive ? grp.color : (isDark ? Colors.white12 : Colors.transparent), width: 2),
                                ),
                                child: Column(children: [
                                  Text('${sib.z}', style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.grey[400])),
                                  Text(sib.sym, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: grp.color, height: 1.1)),
                                  Text(sib.uz, style: TextStyle(fontSize: 9, color: isDark ? Colors.white54 : Colors.grey[500], height: 1.2), textAlign: TextAlign.center),
                                ]),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qsCard(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                color: Color(0xFFBBBBBB), letterSpacing: 0.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required bool isDark, required String title, required Color color, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .15 : .07), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.0)),
          ),
          Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFF0F0F4)),
          ...children,
        ],
      ),
    );
  }

  Widget _confChip(String conf, bool isDark, AlkaliGroup grp) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? grp.color.withOpacity(.15) : (grp.key == 'alkali' ? const Color(0xFFFFF4F4) : const Color(0xFFFFF5E6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(conf, style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'monospace',
          color: isDark ? grp.hi : grp.drk, letterSpacing: 1.0)),
    );
  }

  Widget _row(String label, String val, bool isDark, {bool smallVal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFF7F7FA)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(val, textAlign: TextAlign.right,
                style: TextStyle(fontSize: smallVal ? 12 : 13, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _shellsCard(bool isDark, AlkaliGroup grp) {
    const names = ['K', 'L', 'M', 'N', 'O', 'P', 'Q'];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .15 : .07), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ELEKTRON QAVATLARI  (${el.shells.join(' + ')} = ${el.z})',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: grp.color, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < el.shells.length; i++) ...[
                Column(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: grp.color,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: grp.color.withOpacity(.4), blurRadius: 8, spreadRadius: 1)],
                    ),
                    child: Center(child: Text('${el.shells[i]}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
                  ),
                  const SizedBox(height: 4),
                  Text(names[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white54 : Colors.grey[500], letterSpacing: 0.5)),
                ]),
                if (i < el.shells.length - 1)
                  Padding(padding: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
                      child: Icon(Icons.arrow_forward_rounded, size: 16, color: isDark ? Colors.white24 : Colors.grey[300])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Extension for color access from group
extension AlkaliGroupColors on AlkaliGroup {
  Color get drk => gradient.first;
  Color get hi  => Color.lerp(color, Colors.white, .45)!;
}

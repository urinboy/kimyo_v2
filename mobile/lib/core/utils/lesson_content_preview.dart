/// Darslar ro'yxatidagi kartochka preview uchun: Markdown va LaTeX qoldiqlarini soddalashtiradi.
String lessonContentPreview(String? raw, {int maxChars = 200}) {
  if (raw == null || raw.isEmpty) return '';

  var s = raw;

  // Ba'zan matnda "\n" ketma-ketligi (ikki belgi) saqlanib qolgan
  s = s.replaceAll(r'\n', ' ');

  // Blok tenglamalar
  s = s.replaceAllMapped(RegExp(r'\$\$[\s\S]*?\$\$'), (_) => ' ');

  // Sathdagi $...$ (bloklar olib tashlangach)
  s = s.replaceAllMapped(
    RegExp(r'\$([^\$\n]+?)\$'),
    (_) => ' ',
  );

  s = s.replaceAll(RegExp(r'^[ ]*-{3,}[ ]*$', multiLine: true), ' ');
  s = s.replaceAll(RegExp(r'^[ ]*\*{3,}[ ]*$', multiLine: true), ' ');

  final lines = s.split('\n');
  final buf = StringBuffer();
  for (final line in lines) {
    var l = line.trim();
    if (l.isEmpty) continue;
    l = l.replaceFirst(RegExp(r'^#{1,6}\s+'), '');
    l = l.replaceFirst(RegExp(r'^[-*+]\s+'), '');
    l = l.replaceFirst(RegExp(r'^>\s*'), '');
    buf.write('$l ');
  }
  s = buf.toString();

  s = s.replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m.group(1)!);
  s = s.replaceAllMapped(RegExp(r'__([^_]+)__'), (m) => m.group(1)!);

  s = s.replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (m) => m.group(1)!);

  s = s.replaceAllMapped(RegExp(r'\\text\{([^}]*)\}'), (m) => m.group(1)!);

  s = s.replaceAllMapped(
    RegExp(
      r'\\(?:xrightarrow|xrightarroweq|rightarrow|leftarrow|Delta|cdot|times|to)'
      r'(?:\{[^}]*\}|\[[^\]]*\])?',
    ),
    (_) => ' ',
  );
  s = s.replaceAllMapped(RegExp(r'\\[a-zA-Z]+'), (_) => ' ');

  s = s.replaceAll(RegExp(r'[{}]'), ' ');

  const subs = '₀₁₂₃₄₅₆₇₈₉';
  s = s.replaceAllMapped(RegExp(r'_([0-9])'), (m) {
    final d = int.tryParse(m.group(1)!);
    if (d == null || d > 9) return m.group(0)!;
    return subs[d];
  });

  s = s.replaceAll('|', ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (s.length > maxChars) {
    return '${s.substring(0, maxChars).trimRight()}…';
  }
  return s;
}

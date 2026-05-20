import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../core/theme/colors.dart';

/// Dars mazmunidagi `$$ ... $$` bloklarini TeX sifatida, qolganini Markdown sifatida chiqaradi.
class LessonMarkdownWithMath extends StatelessWidget {
  final String data;
  final MarkdownStyleSheet styleSheet;
  final bool isDark;

  static final _displayMath = RegExp(r'\$\$([\s\S]*?)\$\$');

  const LessonMarkdownWithMath({
    super.key,
    required this.data,
    required this.styleSheet,
    required this.isDark,
  });

  Color get _mathColor =>
      isDark ? Colors.white.withValues(alpha: 0.92) : AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    final segments = _splitSegments(data);
    if (segments.length == 1 && segments.first.isMarkdown) {
      return _SafeMarkdownBody(text: segments.first.text, styleSheet: styleSheet);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in segments)
          if (s.isMarkdown)
            _SafeMarkdownBody(text: s.text, styleSheet: styleSheet)
          else
            _EquationBlock(
              tex: s.text,
              color: _mathColor,
              isDark: isDark,
            ),
      ],
    );
  }
}

/// MarkdownBody ni xavfsiz wrapper — xato bo'lsa plain text ko'rsatadi.
class _SafeMarkdownBody extends StatelessWidget {
  final String text;
  final MarkdownStyleSheet styleSheet;

  const _SafeMarkdownBody({required this.text, required this.styleSheet});

  @override
  Widget build(BuildContext context) {
    try {
      return MarkdownBody(data: text, styleSheet: styleSheet);
    } catch (_) {
      return SelectableText(
        text,
        style: styleSheet.p,
      );
    }
  }
}

class _Segment {
  final String text;
  final bool isMarkdown;

  const _Segment.markdown(this.text) : isMarkdown = true;
  const _Segment.math(this.text) : isMarkdown = false;
}

List<_Segment> _splitSegments(String source) {
  final out = <_Segment>[];
  var start = 0;
  for (final m in LessonMarkdownWithMath._displayMath.allMatches(source)) {
    if (m.start > start) {
      final md = source.substring(start, m.start);
      if (md.trim().isNotEmpty) {
        out.add(_Segment.markdown(md));
      }
    }
    final inner = (m.group(1) ?? '').trim();
    if (inner.isNotEmpty) {
      out.add(_Segment.math(inner));
    }
    start = m.end;
  }
  if (start < source.length) {
    final tail = source.substring(start);
    if (tail.trim().isNotEmpty) {
      out.add(_Segment.markdown(tail));
    }
  }
  if (out.isEmpty) {
    return [_Segment.markdown(source)];
  }
  return out;
}

class _EquationBlock extends StatelessWidget {
  final String tex;
  final Color color;
  final bool isDark;

  const _EquationBlock({
    required this.tex,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);
    final fill = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.primaryPurple.withValues(alpha: 0.07);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Center(
                    child: Math.tex(
                      tex,
                      mathStyle: MathStyle.display,
                      textStyle: TextStyle(
                        fontSize: 17,
                        height: 1.25,
                        color: color,
                      ),
                      settings: const TexParserSettings(strict: Strict.ignore),
                      onErrorFallback: (_) => SelectableText(
                        tex,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: color,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

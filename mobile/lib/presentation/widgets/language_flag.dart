import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Admin `languageFlags.ts` bilan bir xil: til kodi → mamlakat → flagcdn.
String _countryForLangCode(String isoOrLang) {
  final c = isoOrLang.split('-').first.toLowerCase();
  switch (c) {
    case 'uz':
    case 'kaa':
      return 'uz';
    case 'ru':
      return 'ru';
    case 'en':
      return 'gb';
    default:
      return 'un';
  }
}

String _emojiForLangCode(String isoOrLang) {
  final c = isoOrLang.split('-').first.toLowerCase();
  switch (c) {
    case 'uz':
    case 'kaa':
      return '🇺🇿';
    case 'ru':
      return '🇷🇺';
    case 'en':
      return '🇬🇧';
    default:
      return '🌐';
  }
}

/// Saytdagi `LanguageFlag` kabi: flagcdn rasmi, xato/offlayn → emoji.
class LanguageFlag extends StatelessWidget {
  final String langCode;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const LanguageFlag({
    super.key,
    required this.langCode,
    this.width = 28,
    this.height = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(3)),
  });

  @override
  Widget build(BuildContext context) {
    final country = _countryForLangCode(langCode);
    final url = 'https://flagcdn.com/w40/$country.png';
    final emoji = _emojiForLangCode(langCode);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.06),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
          placeholder: (_, _) => Center(
            child: Text(emoji, style: TextStyle(fontSize: height * 0.65)),
          ),
          errorWidget: (_, _, _) => Center(
            child: Text(emoji, style: TextStyle(fontSize: height * 0.65)),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/colors.dart';
import '../../data/datasources/standalone_quiz_remote_data_source.dart';
import '../../injection_container.dart';
import 'quiz_page.dart';
import 'standalone_quiz_page.dart';

/// Mobil: kimyo testlari. Serverda `standalone-quizzes` bo‘lsa API ro‘yxati, aks holda lokal ro‘yxat.
class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  bool _loadingApi = true;
  List<StandaloneQuizListItem>? _apiQuizzes;

  static const List<Map<String, dynamic>> _fallbackQuizzes = [
    {
      'id': 'elements',
      'title': {'uz': 'Kimyoviy elementlar', 'ru': 'Химические элементы', 'en': 'Chemical elements'},
      'questions': 10,
      'icon': Icons.science_rounded,
      'color': Color(0xFFE3F2FD),
      'iconColor': Color(0xFF2196F3),
    },
    {
      'id': 'periodic_table',
      'title': {'uz': 'Davriy jadval', 'ru': 'Периодическая таблица', 'en': 'Periodic table'},
      'questions': 10,
      'icon': Icons.grid_on_rounded,
      'color': Color(0xFFE8F5E9),
      'iconColor': Color(0xFF4CAF50),
    },
    {
      'id': 'reactions',
      'title': {'uz': 'Kimyoviy reaksiyalar', 'ru': 'Химические реакции', 'en': 'Chemical reactions'},
      'questions': 10,
      'icon': Icons.rebase_edit,
      'color': Color(0xFFFFF3E0),
      'iconColor': Color(0xFFFFA726),
    },
    {
      'id': 'general',
      'title': {'uz': 'Umumiy kimyo', 'ru': 'Общая химия', 'en': 'General chemistry'},
      'questions': 10,
      'icon': Icons.book_rounded,
      'color': Color(0xFFF3E5F5),
      'iconColor': Color(0xFFAB47BC),
    },
    {
      'id': 'soda',
      'title': {'uz': 'Soda ishlab chiqarish', 'ru': 'Производство соды', 'en': 'Soda production'},
      'questions': 7,
      'icon': Icons.local_drink_rounded,
      'color': Color(0xFFE0F2F1),
      'iconColor': Color(0xFF009688),
    },
    {
      'id': 'na_k_properties',
      'title': {
        'uz': 'Natriy va kaliyning xossalari va eng muhim birikmalari',
        'ru': 'Свойства натрия и калия',
        'en': 'Properties of Na and K',
      },
      'questions': 7,
      'icon': Icons.bolt_rounded,
      'color': Color(0xFFFFEBEE),
      'iconColor': Color(0xFFE57373),
    },
    {
      'id': 'alkali_metals',
      'title': {'uz': 'Ishqoriy metallar', 'ru': 'Щелочные металлы', 'en': 'Alkali metals'},
      'questions': 8,
      'icon': Icons.electric_bolt_rounded,
      'color': Color(0xFFE1F5FE),
      'iconColor': Color(0xFF03A9F4),
    },
    {
      'id': 'ca_mg',
      'title': {'uz': 'Kalsiy va magniy', 'ru': 'Кальций и магний', 'en': 'Calcium and magnesium'},
      'questions': 8,
      'icon': Icons.layers_rounded,
      'color': Color(0xFFEDE7F6),
      'iconColor': Color(0xFF673AB7),
    },
    {
      'id': 'iron',
      'title': {'uz': 'Temir', 'ru': 'Железо', 'en': 'Iron'},
      'questions': 6,
      'icon': Icons.build_rounded,
      'color': Color(0xFFEFEBE9),
      'iconColor': Color(0xFF795548),
    },
    {
      'id': 'water_hardness',
      'title': {
        'uz': 'Suvning qattiqligi va uni yumshatish usullari',
        'ru': 'Жесткость воды',
        'en': 'Water hardness',
      },
      'questions': 8,
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFFE0F7FA),
      'iconColor': Color(0xFF00BCD4),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadApi();
  }

  Future<void> _loadApi() async {
    try {
      final ds = StandaloneQuizRemoteDataSourceImpl(dio: sl<DioClient>().dio);
      final list = await ds.listChemistry();
      if (!mounted) return;
      setState(() {
        _apiQuizzes = list.isEmpty ? null : list;
        _loadingApi = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _apiQuizzes = null;
          _loadingApi = false;
        });
      }
    }
  }

  IconData _iconForCategory(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('iron') || c.contains('temir')) return Icons.build_rounded;
    if (c.contains('soda')) return Icons.local_drink_rounded;
    if (c.contains('alkali') || c.contains('ishqor')) return Icons.electric_bolt_rounded;
    if (c.contains('water') || c.contains('suv')) return Icons.water_drop_rounded;
    if (c.contains('tabl') || c.contains('jadval')) return Icons.grid_on_rounded;
    return Icons.quiz_rounded;
  }

  Color _colorForIndex(int i) {
    const palette = [
      Color(0xFFF3E5F5),
      Color(0xFFE3F2FD),
      Color(0xFFE8F5E9),
      Color(0xFFE0F2F1),
      Color(0xFFFFF3E0),
    ];
    return palette[i % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('menu_quiz')),
        centerTitle: true,
        actions: [
          if (_apiQuizzes != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() => _loadingApi = true);
                _loadApi();
              },
            ),
        ],
      ),
      body: _loadingApi
          ? const Center(child: CircularProgressIndicator())
          : _apiQuizzes != null
              ? RefreshIndicator(
                  onRefresh: _loadApi,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _apiQuizzes!.length,
                    itemBuilder: (context, index) {
                      final q = _apiQuizzes![index];
                      final icon = _iconForCategory(q.category);
                      final tint = _colorForIndex(index);
                      return _buildApiCard(context, q, isDark, lang, icon, tint);
                    },
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    try {
                      final ds = StandaloneQuizRemoteDataSourceImpl(dio: sl<DioClient>().dio);
                      final list = await ds.listChemistry();
                      if (!mounted) return;
                      if (list.isNotEmpty) {
                        setState(() => _apiQuizzes = list);
                      }
                    } catch (_) {}
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _fallbackQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = _fallbackQuizzes[index];
                      return _buildFallbackCard(context, quiz, isDark, lang);
                    },
                  ),
                ),
    );
  }

  Widget _buildApiCard(
    BuildContext context,
    StandaloneQuizListItem q,
    bool isDark,
    String lang,
    IconData icon,
    Color softBg,
  ) {
    final title = q.titleForLang(lang);
    final iconColor = isDark ? AppColors.primaryPurple : const Color(0xFF7B1FA2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => StandaloneQuizPage(quizId: q.id, title: title),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withOpacity(0.22) : softBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lang == 'uz'
                            ? '${q.questionsCount} ta savol'
                            : (lang == 'ru' ? '${q.questionsCount} вопросов' : '${q.questionsCount} questions'),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.black38,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackCard(BuildContext context, Map<String, dynamic> quiz, bool isDark, String lang) {
    final title = (quiz['title'] as Map)[lang] as String? ?? (quiz['title'] as Map)['uz'] as String;
    final questionsCount = quiz['questions'] as int;
    final iconColor = quiz['iconColor'] as Color;
    final softBg = quiz['color'] as Color;
    final icon = quiz['icon'] as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final category = (quiz['id'] as String?) ?? 'elements';
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => QuizPage(
                  title: title,
                  category: category,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withOpacity(0.2) : softBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lang == 'uz'
                            ? '$questionsCount ta savol'
                            : (lang == 'ru' ? '$questionsCount вопросов' : '$questionsCount questions'),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.black38,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


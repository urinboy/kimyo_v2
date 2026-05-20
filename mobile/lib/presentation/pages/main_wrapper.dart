import 'package:flutter/material.dart';
import 'home_page.dart';
import 'geography_page.dart';
import 'documents_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import 'mines_page.dart';
import 'lessons_page.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/toast_util.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ToastUtil.init(context);
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const GeographyPage(),
    const DocumentsPage(),
    const SettingsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.science_outlined),
            activeIcon: const Icon(Icons.science),
            label: context.tr('tab_kimyo'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.public_outlined),
            activeIcon: const Icon(Icons.public),
            label: context.tr('tab_geografiya'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.description_outlined),
            activeIcon: const Icon(Icons.description),
            label: context.tr('tab_hujjatlar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: context.tr('tab_sozlamalar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: context.tr('tab_profil'),
          ),
        ],
      ),
    );
  }
}

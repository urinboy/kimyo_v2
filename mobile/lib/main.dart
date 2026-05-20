import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'data/datasources/element_bundled_data_source.dart';
import 'injection_container.dart' as di;
import 'core/auth/auth_session.dart';
import 'core/services/app_foreground_time_service.dart';
import 'core/config/mobile_api_settings.dart';
import 'presentation/gates/app_session_gate.dart';

/// Chrome DevTools qurilma rejimi / oyna o‘lchami o‘zgarganda Flutter Web ba’zan
/// manfiy [MediaQuery.viewInsets] beradi — engine "ViewInsets cannot be negative" bilan qulatiladi.
/// Bu yordamchi katta darajada shuni oldini oladi.
final TransitionBuilder _materialAppToastBuilder = FToastBuilder();

Widget _wrapWebMediaQuery(BuildContext context, Widget child) {
  if (!kIsWeb) return child;
  final data = MediaQuery.maybeOf(context);
  if (data == null) return child;
  final vi = data.viewInsets;
  if (vi.left >= 0 && vi.top >= 0 && vi.right >= 0 && vi.bottom >= 0) {
    return child;
  }
  return MediaQuery(
    data: data.copyWith(
      viewInsets: EdgeInsets.only(
        left: math.max(0.0, vi.left),
        top: math.max(0.0, vi.top),
        right: math.max(0.0, vi.right),
        bottom: math.max(0.0, vi.bottom),
      ),
    ),
    child: child,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  await MobileApiSettings.loadFromAssets();
  MobileApiSettings.logMisconfigHint();

  // Initialize dependency injection
  await di.init();

  // Elementlar paket ichidagi JSON — birinchi sahifa (jadval / ro‘yxat) uchun API kutmaydi.
  try {
    await di.sl<ElementBundledDataSource>().loadBundledElements();
  } catch (_) {}

  await LocaleService().init();
  await di.sl<AuthSession>().load();
  await di.sl<AppForegroundTimeService>().restorePersisted();

  runApp(const KimyoApp());
}

class KimyoApp extends StatefulWidget {
  const KimyoApp({super.key});

  @override
  State<KimyoApp> createState() => _KimyoAppState();
}

class _KimyoAppState extends State<KimyoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ls = WidgetsBinding.instance.lifecycleState;
      if (ls != null) {
        di.sl<AppForegroundTimeService>().handleLifecycle(ls);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    di.sl<AppForegroundTimeService>().handleLifecycle(state);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeMode,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LocaleService().locale,
          builder: (context, locale, child) {
            return MaterialApp(
              title: 'Kimyo v2',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [
                Locale('uz'),
                Locale('ru'),
                Locale('en'),
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                final next = _wrapWebMediaQuery(context, child ?? const SizedBox.shrink());
                return _materialAppToastBuilder(context, next);
              },
              home: const AppSessionGate(),
            );
          },
        );
      },
    );
  }
}

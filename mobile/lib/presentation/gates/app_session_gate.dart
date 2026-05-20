import 'package:flutter/material.dart';
import '../../core/auth/auth_session.dart';
import '../../injection_container.dart' as di;
import '../pages/auth_flow_page.dart';
import '../pages/language_onboarding_page.dart';
import '../pages/main_wrapper.dart';
import '../pages/splash_page.dart';

/// Splash → (birinchi marta) til → login/register → asosiy ilova
class AppSessionGate extends StatefulWidget {
  const AppSessionGate({super.key});

  @override
  State<AppSessionGate> createState() => _AppSessionGateState();
}

class _AppSessionGateState extends State<AppSessionGate> {
  var _showSplash = true;

  @override
  void initState() {
    super.initState();
    di.sl<AuthSession>().addListener(_onAuth);
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    di.sl<AuthSession>().removeListener(_onAuth);
    super.dispose();
  }

  void _afterSplash() {
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashPage(onReady: _afterSplash);
    }

    final s = di.sl<AuthSession>();
    if (!s.languageOnboardingDone) {
      return const LanguageOnboardingPage();
    }
    if (!s.isLoggedIn) {
      return const AuthFlowPage();
    }
    return const MainWrapper();
  }
}

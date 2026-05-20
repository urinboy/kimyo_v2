import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Qachon ilova rejimlari [paused] / [hidden] ga o‘tganda yozilib,
/// rejimlar [resumed] bo‘lganda yig‘ilishni davom ettiriladi.
///
/// Qo‘lda qo‘yilgan [inactive] uchun vaqtni to‘xtatmaymiz (qisqa oraliq bildirishnomalar oynasi).
class AppForegroundTimeService extends ChangeNotifier {
  AppForegroundTimeService({required this.prefs});

  final SharedPreferences prefs;

  static const _kKeySeconds = 'app_foreground_seconds_v1';

  int _persistedSeconds = 0;
  DateTime? _resumeAt;
  AppLifecycleState? _lastLifecycle;
  Timer? _refreshUiTimer;

  /// Qo‘lda saqlangan jami sekundlar + hozirgi ochiq sessiya.
  int get totalForegroundSeconds =>
      _persistedSeconds + _currentSliceSecondsElapsed;

  int get _currentSliceSecondsElapsed {
    final start = _resumeAt;
    if (start == null) return 0;
    final d = DateTime.now().difference(start).inSeconds;
    return d < 0 ? 0 : d;
  }

  Future<void> restorePersisted() async {
    _persistedSeconds = prefs.getInt(_kKeySeconds) ?? 0;
    notifyListeners();
  }

  void handleLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_lastLifecycle != AppLifecycleState.resumed) {
          _resumeAt = DateTime.now();
        }
        _refreshUiTimer ??= Timer.periodic(
          const Duration(seconds: 30),
          (_) => notifyListeners(),
        );
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _refreshUiTimer?.cancel();
        _refreshUiTimer = null;
        _flushSliceToPersisted();
        break;
    }
    _lastLifecycle = state;
    notifyListeners();
  }

  void _flushSliceToPersisted() {
    final start = _resumeAt;
    if (start == null) return;
    final extra = DateTime.now().difference(start).inSeconds;
    if (extra <= 0) return;
    _persistedSeconds += extra;
    prefs.setInt(_kKeySeconds, _persistedSeconds);
    _resumeAt = null;
  }
}

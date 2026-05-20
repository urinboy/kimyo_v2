import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_session.dart';

/// Qurilmada so‘nggi muvaffaqiyatli bahoni eslab qoladi (anonim yoki login bilan).
class AppReviewLocalStorage {
  AppReviewLocalStorage._();

  static const String prefRatingKey = 'mobile_app_review_rating';

  static int? readRating(SharedPreferences prefs) {
    if (!prefs.containsKey(prefRatingKey)) return null;
    final v = prefs.getInt(prefRatingKey);
    if (v == null || v < 1 || v > 5) return null;
    return v;
  }

  static Future<void> saveRating(SharedPreferences prefs, int rating) async {
    if (rating < 1 || rating > 5) return;
    await prefs.setInt(prefRatingKey, rating);
  }

  static int? _parseRating(dynamic raw) {
    if (raw is int) return raw >= 1 && raw <= 5 ? raw : null;
    if (raw is num) {
      final n = raw.toInt();
      return n >= 1 && n <= 5 ? n : null;
    }
    return null;
  }

  /// Dialog / sozlamalar: login bo‘lsa server ustuvor; aks holda prefs.
  static Future<AppReviewUiState> resolveDisplayState({
    required SharedPreferences prefs,
    required AuthSession auth,
    required Dio dio,
  }) async {
    if (auth.isLoggedIn) {
      try {
        final res = await dio.get<Map<String, dynamic>>('/mobile/reviews/me');
        final body = res.data;
        if (body != null && body['status'] == 'success') {
          final data = body['data'];
          if (data is Map<String, dynamic>) {
            final review = data['review'];
            if (review is Map<String, dynamic>) {
              final n = _parseRating(review['rating']);
              if (n != null) {
                await saveRating(prefs, n);
                return AppReviewUiState(rating: n, locked: true);
              }
            }
            return const AppReviewUiState(rating: 0, locked: false);
          }
        }
        return const AppReviewUiState(rating: 0, locked: false);
      } catch (_) {
        final local = readRating(prefs);
        if (local != null) {
          return AppReviewUiState(rating: local, locked: true);
        }
        return const AppReviewUiState(rating: 0, locked: false);
      }
    }

    final local = readRating(prefs);
    if (local != null) {
      return AppReviewUiState(rating: local, locked: true);
    }
    return const AppReviewUiState(rating: 0, locked: false);
  }
}

class AppReviewUiState {
  const AppReviewUiState({required this.rating, required this.locked});

  /// 0 — hali baholanmagan (UI da yulduz tanlanmagan).
  final int rating;
  final bool locked;
}

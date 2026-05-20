import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/colors.dart';

class ToastUtil {
  static FToast? _fToast;

  static void init(BuildContext context) {
    _fToast = FToast();
    _fToast!.init(context);
  }

  static void showSuccess(String message) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFF4CAF50),
      textColor: Colors.white,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showInfo(String message, {bool isDark = false}) {
    _showToast(
      message: message,
      backgroundColor: isDark ? Colors.white : Colors.black87,
      textColor: isDark ? Colors.black : Colors.white,
      icon: Icons.info_rounded,
    );
  }

  static void showError(String message) {
    _showToast(
      message: message,
      backgroundColor: AppColors.iconRed,
      textColor: Colors.white,
      icon: Icons.error_outline_rounded,
    );
  }

  static void _showToast({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
  }) {
    if (_fToast == null) return;

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12.0),
          Text(
            message,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );

    _fToast!.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
      positionedToastBuilder: (context, child, gravity) {
        return Positioned(
          bottom: 100.0, // Above bottom navigation bar
          left: 16.0,
          right: 16.0,
          child: Center(child: child),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_window_view_model.dart';

class MethodButton extends StatelessWidget {
  final HttpMethod method;
  final bool isActive;
  final VoidCallback onTap;

  const MethodButton({
    super.key,
    required this.method,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final methodName = method.name.toUpperCase();

    return Container(
      height: 32,
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 61, 61, 61),
        borderRadius: BorderRadius.circular(2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(2),
        onTap: onTap,
        child: Stack(
          children: [
            // Indicator bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 12,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.mainColor
                      : const Color.fromARGB(255, 61, 61, 61),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    bottomLeft: Radius.circular(2),
                  ),
                ),
              ),
            ),
            // Centered text
            Center(
              child: Text(
                methodName,
                style: TextStyle(
                  color: isActive ? AppTheme.mainColor : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

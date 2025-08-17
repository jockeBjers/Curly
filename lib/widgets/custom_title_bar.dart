import 'package:curly/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTitleBar extends StatelessWidget {
  final String title;

  const CustomTitleBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: MoveWindow(
                  child: WindowTitleBarBox(
                    child: Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.mainColor,
                                fontFamily:
                                    GoogleFonts.pressStart2p().fontFamily,
                                fontSize: 38,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black54,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(top: 0, right: 0, child: WindowButtons()),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(
          colors: WindowButtonColors(
            iconNormal: AppTheme.mainColor,
            mouseOver: Colors.grey.withValues(alpha: 0.2),
            mouseDown: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        MaximizeWindowButton(
          colors: WindowButtonColors(
            iconNormal: AppTheme.mainColor,
            mouseOver: Colors.grey.withValues(alpha: 0.2),
            mouseDown: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        CloseWindowButton(
          colors: WindowButtonColors(
            iconNormal: Colors.red.withValues(alpha: 0.8),
            mouseOver: Colors.red.withValues(alpha: 0.8),
            mouseDown: Colors.red.withValues(alpha: 0.9),
            iconMouseOver: Colors.white,
            iconMouseDown: Colors.white,
          ),
        ),
      ],
    );
  }
}

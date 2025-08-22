import 'package:flutter/material.dart';

class HistoryArrows extends StatelessWidget {
  final bool hasHistory;
  final VoidCallback onUpPressed;
  final VoidCallback onDownPressed;

  const HistoryArrows({
    super.key,
    required this.hasHistory,
    required this.onUpPressed,
    required this.onDownPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasHistory) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 23,
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_up, size: 22),
                onPressed: onUpPressed,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1),
                  ),
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            SizedBox(
              width: 30,
              height: 24,
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, size: 22),
                onPressed: onDownPressed,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1),
                  ),
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

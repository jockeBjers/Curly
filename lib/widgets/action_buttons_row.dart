import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_window_view_model.dart';

class ActionButtonsRow extends StatelessWidget {
  final bool isSubmitting;
  final HttpMethod selectedMethod;
  final VoidCallback onSubmit;
  final VoidCallback? onOpenResponse;
  final VoidCallback onClear;

  const ActionButtonsRow({
    super.key,
    required this.isSubmitting,
    required this.selectedMethod,
    required this.onSubmit,
    required this.onOpenResponse,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubmitting ? Colors.grey : null,
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: AppTheme.mainColor,
            ),
            child: isSubmitting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Sending...'),
                    ],
                  )
                : Text('Send ${selectedMethod.name.toUpperCase()} Request'),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onOpenResponse,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return AppTheme.surfaceColor; // bg when disabled
              }
              return Color.fromARGB(255, 38, 43, 38);
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.white30; // text color when disabled
              }
              return Colors.white;
            }),
          ),
          child: const Text('Show Response'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onClear,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 38, 43, 38),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: const Text(
            'Clear',
            style: TextStyle(color: AppTheme.mainColor),
          ),
        ),
      ],
    );
  }
}

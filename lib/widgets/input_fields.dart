import 'package:flutter/material.dart';
import 'history_arrows.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool hasHistory;
  final VoidCallback onUpPressed;
  final VoidCallback onDownPressed;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;
  final InputDecoration? decoration;
  final bool expands;
  final int? maxLines;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.hasHistory,
    required this.onUpPressed,
    required this.onDownPressed,
    this.onChanged,
    this.style,
    this.decoration,
    this.expands = false,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: controller,
          textAlignVertical: TextAlignVertical.top,
          style: style,
          maxLines: maxLines,
          expands: expands,
          decoration:
              decoration ??
              InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(1),
                  borderSide: BorderSide(color: Colors.white30, width: 0.5),
                ),
                alignLabelWithHint: true,
              ),
          onChanged: onChanged,
        ),
        HistoryArrows(
          hasHistory: hasHistory,
          onUpPressed: onUpPressed,
          onDownPressed: onDownPressed,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ResponseDialog extends StatefulWidget {
  final String response;
  final bool isError;
  final int? statusCode;
  final String? reasonPhrase;

  const ResponseDialog({
    super.key,
    required this.response,
    this.isError = false,
    this.statusCode,
    this.reasonPhrase,
  });

  static void show(
    BuildContext context,
    String response, {
    bool isError = false,
    int? statusCode,
    String? reasonPhrase,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => ResponseDialog(
        response: response,
        isError: isError,
        statusCode: statusCode,
        reasonPhrase: reasonPhrase,
      ),
    );
  }

  @override
  State<ResponseDialog> createState() => _ResponseDialogState();
}

class _ResponseDialogState extends State<ResponseDialog> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.isError ? 'Error' : 'Response',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: widget.isError ? Colors.red : AppTheme.mainColor,
                  fontFamily: GoogleFonts.pressStart2p().fontFamily,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          if (widget.statusCode != null && widget.reasonPhrase != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${widget.statusCode} ${widget.reasonPhrase}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.isError ? Colors.red[300] : Colors.greenAccent,
                  fontFamily: GoogleFonts.pressStart2p().fontFamily,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: SelectableText(
            widget.response,
            style: TextStyle(
              fontFamily: 'monospace',
              color: widget.isError ? Colors.red[200] : Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: widget.isError ? Colors.red : AppTheme.mainColor,
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: widget.response));
            setState(() {
              _copied = true;
            });
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _copied = false;
                });
              }
            });
          },
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: TextStyle(color: _copied ? Colors.green : Colors.amber),
            child: Text(_copied ? 'Copied!' : 'Copy'),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

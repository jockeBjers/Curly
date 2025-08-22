import 'package:curly/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'widgets/custom_title_bar.dart';
import 'widgets/method_button.dart';
import 'widgets/response_dialog.dart';
import 'widgets/action_buttons_row.dart';
import 'main_window_view_model.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with TickerProviderStateMixin {
  final MainWindowViewModel _viewModel = MainWindowViewModel(
    timeout: Duration(seconds: 5),
  );
  String? _lastResponse;
  bool _lastIsError = false;
  int? _lastStatusCode;
  String? _lastReasonPhrase;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _jsonController = TextEditingController();

  bool _isSubmitting = false;
  HttpMethod _selectedMethod = HttpMethod.post;

  @override
  void initState() {
    super.initState();

    _loadInitialData().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _viewModel.initializeHistory();
    final (savedUrl, savedJson) = await _viewModel.loadData();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _urlController.text = savedUrl;
    } else {
      _urlController.text = "https://jsonplaceholder.typicode.com/posts";
    }
    if (savedJson != null && savedJson.isNotEmpty) {
      _jsonController.text = savedJson;
    } else {
      const initialJson = {
        "id": 1,
        "key": "Value",
        "email": "Name@example.com",
        "description": "A tool for testing HTTP requests",
      };
      _jsonController.text = const JsonEncoder.withIndent(
        '  ',
      ).convert(initialJson);
    }
  }

  FormValidation _validateInputs(String url, String json) {
    return _viewModel.validateInputs(url, json, _selectedMethod);
  }

  Future<
    (
      bool success,
      String? errorMsg,
      String? responseBody,
      int? statusCode,
      String? reasonPhrase,
    )
  >
  _sendRequest(String url, String json) async {
    return _viewModel.sendRequestWithQueryParams(
      url: url,
      json: json,
      method: _selectedMethod,
    );
  }

  Future<void> _submitRequest() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final url = _urlController.text;
      final json = _jsonController.text;
      final state = _validateInputs(url, json);
      if (state != FormValidation.filled) {
        String errorMsg;
        switch (state) {
          case FormValidation.urlEmpty:
            errorMsg = "URL is required.";
            break;
          case FormValidation.jsonEmpty:
            errorMsg = "JSON body is required for this method.";
            break;
          case FormValidation.bothEmpty:
            errorMsg = "URL and JSON body are required.";
            break;
          default:
            errorMsg = "Invalid input.";
        }
        _showResponseDialog(errorMsg, isError: true);
        return;
      }

      final (success, errorMsg, responseBody, statusCode, reasonPhrase) =
          await _sendRequest(url, json);

      if (success) {
        await _viewModel.addToHistory(url, json);
      }

      if (responseBody != null && responseBody.isNotEmpty) {
        _showResponseDialog(
          responseBody,
          isError: !success,
          statusCode: statusCode,
          reasonPhrase: reasonPhrase,
        );
      } else {
        _showResponseDialog(
          errorMsg ?? "Unknown error",
          isError: true,
          statusCode: statusCode,
          reasonPhrase: reasonPhrase,
        );
      }
    } catch (e) {
      _showResponseDialog(
        "An unexpected error occurred: ${e.toString()}",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearFields() {
    _urlController.clear();
    _jsonController.clear();
    _viewModel.clearData();
    setState(() {});
  }

  void _showResponseDialog(
    String response, {
    bool isError = false,
    int? statusCode,
    String? reasonPhrase,
  }) {
    if (mounted) {
      setState(() {
        _lastResponse = response;
        _lastIsError = isError;
        _lastStatusCode = statusCode;
        _lastReasonPhrase = reasonPhrase;
      });
    }
    if (mounted && context.mounted) {
      ResponseDialog.show(
        context,
        response,
        isError: isError,
        statusCode: statusCode,
        reasonPhrase: reasonPhrase,
      );
    }
  }

  void _navigateUrlHistory(bool goUp) {
    final historyUrl = _viewModel.navigateUrlHistory(goUp);
    if (historyUrl != null) {
      setState(() {
        _urlController.text = historyUrl;
      });
    }
  }

  void _navigateJsonHistory(bool goUp) {
    final historyJson = _viewModel.navigateJsonHistory(goUp);
    if (historyJson != null) {
      setState(() {
        _jsonController.text = historyJson;
      });
    }
  }

  Widget _buildMethodButton(HttpMethod method) {
    return MethodButton(
      method: method,
      isActive: _selectedMethod == method,
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
    );
  }

  Widget _buildHistoryArrows({
    required bool hasHistory,
    required VoidCallback onUpPressed,
    required VoidCallback onDownPressed,
    bool isJsonField = false,
  }) {
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

  Widget _buildUrlField() {
    return Stack(
      children: [
        TextFormField(
          controller: _urlController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          selectionControls: materialTextSelectionControls,
          decoration: InputDecoration(
            labelText: 'URL',
            labelStyle: const TextStyle(color: Colors.white70),
            hintText: 'https://api.example.com/endpoint',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1),
              borderSide: BorderSide(color: Colors.white30, width: 0.5),
            ),
            alignLabelWithHint: true,
          ),
          onChanged: (value) async {
            setState(() {});
            await _viewModel.saveData(
              url: _urlController.text,
              json: _jsonController.text,
            );
          },
        ),
        _buildHistoryArrows(
          hasHistory: _viewModel.hasUrlHistory,
          onUpPressed: () => _navigateUrlHistory(true),
          onDownPressed: () => _navigateUrlHistory(false),
        ),
      ],
    );
  }

  Widget _buildJsonField() {
    return Expanded(
      child: Stack(
        children: [
          TextFormField(
            controller: _jsonController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(color: AppTheme.mainColor, fontSize: 14),
            cursorColor: Colors.white,
            selectionControls: materialTextSelectionControls,
            decoration: InputDecoration(
              labelText: 'JSON Body',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: '{\n  "key": "value"\n}',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1),
                borderSide: BorderSide(color: Colors.white30, width: 0.5),
              ),
              alignLabelWithHint: true,
            ),
            onChanged: (value) async {
              await _viewModel.saveData(
                url: _urlController.text,
                json: _jsonController.text,
              );
            },
          ),
          _buildHistoryArrows(
            hasHistory: _viewModel.hasJsonHistory,
            onUpPressed: () => _navigateJsonHistory(true),
            onDownPressed: () => _navigateJsonHistory(false),
            isJsonField: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.surfaceColor),
        child: Column(
          children: [
            const CustomTitleBar(title: 'Curly'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HTTP Method buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildMethodButton(HttpMethod.get),
                        _buildMethodButton(HttpMethod.post),
                        _buildMethodButton(HttpMethod.patch),
                        _buildMethodButton(HttpMethod.put),
                        _buildMethodButton(HttpMethod.delete),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildUrlField(),
                    const SizedBox(height: 16),

                    _buildJsonField(),
                    const SizedBox(height: 26),

                    ActionButtonsRow(
                      isSubmitting: _isSubmitting,
                      selectedMethod: _selectedMethod,
                      onSubmit: _submitRequest,
                      onOpenResponse:
                          (_lastResponse != null && _lastResponse!.isNotEmpty)
                          ? () => _showResponseDialog(
                              _lastResponse!,
                              isError: _lastIsError,
                              statusCode: _lastStatusCode,
                              reasonPhrase: _lastReasonPhrase,
                            )
                          : null,
                      onClear: _clearFields,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

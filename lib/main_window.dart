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
  final MainWindowViewModel _viewModel = MainWindowViewModel();
  String? _lastResponse;
  bool _lastIsError = false;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _jsonController = TextEditingController();

  bool _isSubmitting = false;
  HttpMethod _selectedMethod = HttpMethod.post;

  @override
  void initState() {
    super.initState();

    _loadDebugSampleData();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  void _loadDebugSampleData() {
    const jsonRaw = {
      "id": 42,
      "name": "Name",
      "email": "Name@example.com",
      "roles": ["admin"],
      "description": "A tool for testing HTTP requests",
    };
    _jsonController.text = const JsonEncoder.withIndent('  ').convert(jsonRaw);
    _urlController.text = "https://jsonplaceholder.typicode.com/posts";
  }

  FormValidationState _validateInputs(String url, String json) {
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
    return _viewModel.sendRequest(
      url: url,
      json: json,
      method: _selectedMethod,
    );
  }

  Future<void> _submitRequest() async {
    setState(() {
      _isSubmitting = true;
    });
    final url = _urlController.text;
    final json = _jsonController.text;
    final state = _validateInputs(url, json);
    if (state != FormValidationState.filled) {
      setState(() {
        _isSubmitting = false;
      });
      String errorMsg;
      switch (state) {
        case FormValidationState.urlEmpty:
          errorMsg = "URL is required.";
          break;
        case FormValidationState.jsonEmpty:
          errorMsg = "JSON body is required for this method.";
          break;
        case FormValidationState.bothEmpty:
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
    if (responseBody != null && responseBody.isNotEmpty) {
      String dialogContent = responseBody;
      _showResponseDialog(
        dialogContent,
        isError: !success,
        statusCode: statusCode,
        reasonPhrase: reasonPhrase,
      );
    } else {
      String errorContent = errorMsg ?? "Unknown error";
      _showResponseDialog(
        errorContent,
        isError: true,
        statusCode: statusCode,
        reasonPhrase: reasonPhrase,
      );
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  void _clearFields() {
    _urlController.clear();
    _jsonController.clear();
    setState(() {});
  }

  void _showResponseDialog(
    String response, {
    bool isError = false,
    int? statusCode,
    String? reasonPhrase,
  }) {
    // Save last response and error state
    setState(() {
      _lastResponse = response;
      _lastIsError = isError;
    });
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
                    // URL Input
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
                          borderSide: BorderSide(
                            color: Colors.white30,
                            width: 0.5,
                          ),
                        ),
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    // JSON Input
                    Expanded(
                      child: TextFormField(
                        controller: _jsonController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          color: AppTheme.mainColor,
                          fontSize: 14,
                        ),
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
                            borderSide: BorderSide(
                              color: Colors.white30,
                              width: 0.5,
                            ),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    // Buttons
                    ActionButtonsRow(
                      isSubmitting: _isSubmitting,
                      selectedMethod: _selectedMethod,
                      onSubmit: _submitRequest,
                      onOpenResponse:
                          (_lastResponse != null && _lastResponse!.isNotEmpty)
                          ? () => _showResponseDialog(
                              _lastResponse!,
                              isError: _lastIsError,
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

import 'package:curly/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'widgets/custom_title_bar.dart';

enum FormValidationState { filled, urlEmpty, jsonEmpty, bothEmpty }

enum HttpMethod { get, post, patch, put, delete }

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with TickerProviderStateMixin {
  String? _lastResponse;
  bool _lastIsError = false;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _jsonController = TextEditingController();

  Timer? _messageTimer;
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
    _messageTimer?.cancel();
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
    final uri = Uri.tryParse(url);
    final isUrlEmpty =
        url.trim().isEmpty || uri == null || !uri.hasAbsolutePath;
    final isJsonEmpty = json.trim().isEmpty;
    if (isUrlEmpty && isJsonEmpty) return FormValidationState.bothEmpty;
    if (isUrlEmpty) return FormValidationState.urlEmpty;
    if (isJsonEmpty && _selectedMethod != HttpMethod.get) {
      return FormValidationState.jsonEmpty;
    }
    return FormValidationState.filled;
  }

  Future<(bool success, String? errorMsg, String? responseBody)> _sendRequest(
    String url,
    String json,
  ) async {
    const genericError = "Error sending request!";
    try {
      final uri = Uri.parse(url);
      final headers = {'Content-Type': 'application/json'};
      http.Response response;

      switch (_selectedMethod) {
        case HttpMethod.get:
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 5));
          break;
        case HttpMethod.post:
          response = await http
              .post(uri, headers: headers, body: json)
              .timeout(const Duration(seconds: 5));
          break;
        case HttpMethod.patch:
          response = await http
              .patch(uri, headers: headers, body: json)
              .timeout(const Duration(seconds: 5));
          break;
        case HttpMethod.put:
          response = await http
              .put(uri, headers: headers, body: json)
              .timeout(const Duration(seconds: 5));
          break;
        case HttpMethod.delete:
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 5));
          break;
      }

      if (response.statusCode == 404) {
        return (false, "404: Endpoint not found!", null);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return (
          false,
          "${response.statusCode}: ${response.reasonPhrase ?? genericError}",
          response.body,
        );
      }

      // Try to format JSON response for better display
      String formattedResponse = response.body;
      try {
        final dynamic jsonResponse = jsonDecode(response.body);
        formattedResponse = const JsonEncoder.withIndent(
          '  ',
        ).convert(jsonResponse);
      } catch (e) {
        // If not valid JSON, use the raw response
      }

      return (true, null, formattedResponse);
    } on TimeoutException {
      return (false, "Request timed out after 5 seconds!", null);
    } on http.ClientException {
      return (false, genericError, null);
    } catch (e) {
      return (false, genericError, null);
    }
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
      return;
    }
    final (success, errorMsg, responseBody) = await _sendRequest(url, json);
    if (success && responseBody != null && responseBody.isNotEmpty) {
      _showResponseDialog(responseBody, isError: false);
    } else {
      String errorContent = errorMsg ?? "Unknown error";
      if (responseBody != null && responseBody.isNotEmpty) {
        errorContent += "\n\nDetails:\n$responseBody";
      }
      _showResponseDialog(errorContent, isError: true);
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

  void _showResponseDialog(String response, {bool isError = false}) {
    // Save last response and error state
    setState(() {
      _lastResponse = response;
      _lastIsError = isError;
    });
    if (mounted && context.mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Row(
              children: [
                Text(
                  isError ? 'Error' : 'Response',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isError ? Colors.red : AppTheme.mainColor,
                    fontFamily: GoogleFonts.pressStart2p().fontFamily,
                    fontSize: 22,
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
                  response,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: isError ? Colors.red[200] : Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: isError ? Colors.red : AppTheme.mainColor,
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildMethodButton(HttpMethod method) {
    final isActive = _selectedMethod == method;
    final methodName = method.name.toUpperCase();

    return Container(
      height: 32,
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(2),
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 12,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.mainColor : Colors.grey[700],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    bottomLeft: Radius.circular(2),
                  ),
                ),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 58, 66, 58),
              Color.fromARGB(255, 38, 43, 38),
              Color.fromARGB(255, 40, 41, 40),
              Color.fromARGB(255, 40, 41, 40),
              Color.fromARGB(255, 23, 24, 23),
            ],
          ),
        ),
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
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.mainColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1),
                          borderSide: BorderSide(
                            color: AppTheme.mainColor,
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
                              color: AppTheme.mainColor,
                              width: 0.5,
                            ),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSubmitting
                                  ? Colors.grey
                                  : null,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isSubmitting
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Sending...'),
                                    ],
                                  )
                                : Text(
                                    'Send ${_selectedMethod.name.toUpperCase()} Request',
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed:
                              (_lastResponse != null &&
                                  _lastResponse!.isNotEmpty)
                              ? () => _showResponseDialog(
                                  _lastResponse!,
                                  isError: _lastIsError,
                                )
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                          ),
                          child: const Text(
                            'Open Response',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
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

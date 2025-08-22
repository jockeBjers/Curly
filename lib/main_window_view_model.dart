import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum FormValidation { filled, urlEmpty, jsonEmpty, bothEmpty }

enum HttpMethod { get, post, patch, put, delete }

class MainWindowViewModel {
  String? _jwtToken;

  Future<
    (
      bool success,
      String? errorMsg,
      String? responseBody,
      int? statusCode,
      String? reasonPhrase,
    )
  >
  sendRequestWithQueryParams({
    required String url,
    required String json,
    required HttpMethod method,
  }) async {
    if (method == HttpMethod.get && json.trim().isNotEmpty) {
      try {
        final Map<String, dynamic> params = jsonDecode(json);
        final queryString = Uri(
          queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
        ).query;
        String finalUrl = url;
        if (queryString.isNotEmpty) {
          finalUrl = url.contains('?')
              ? '$url&$queryString'
              : '$url?$queryString';
        }
        return await sendRequest(url: finalUrl, json: json, method: method);
      } catch (e) {
        return (false, "Invalid JSON for query parameters.", null, null, null);
      }
    } else {
      return await sendRequest(url: url, json: json, method: method);
    }
  }

  final Duration timeout;

  static const int _maxHistoryItems = 5;
  List<String> _urlHistory = [];
  List<String> _jsonHistory = [];
  int _currentUrlIndex = 0;
  int _currentJsonIndex = 0;

  // for navigation
  bool get hasUrlHistory => _urlHistory.isNotEmpty;
  bool get hasJsonHistory => _jsonHistory.isNotEmpty;
  int get urlHistoryCount => _urlHistory.length;
  int get jsonHistoryCount => _jsonHistory.length;
  int get currentUrlHistoryIndex => _currentUrlIndex + 1;
  int get currentJsonHistoryIndex => _currentJsonIndex + 1;

  MainWindowViewModel({this.timeout = const Duration(seconds: 5)});

  void setToken(String token) {
    _jwtToken = token;
  }

  void clearToken() {
    _jwtToken = null;
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
  sendRequest({
    required String url,
    required String json,
    required HttpMethod method,
  }) async {
    const genericError = "Error sending request!";
    try {
      final uri = Uri.parse(url);

      // Build header
      final headers = <String, String>{'Content-Type': 'application/json'};

      // Add Authorization header if there's a token
      if (_jwtToken != null && _jwtToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_jwtToken';
      }

      http.Response response;
      switch (method) {
        case HttpMethod.get:
          response = await http.get(uri, headers: headers).timeout(timeout);
          break;
        case HttpMethod.post:
          response = await http
              .post(uri, headers: headers, body: json)
              .timeout(timeout);
          break;
        case HttpMethod.patch:
          response = await http
              .patch(uri, headers: headers, body: json)
              .timeout(timeout);
          break;
        case HttpMethod.put:
          response = await http
              .put(uri, headers: headers, body: json)
              .timeout(timeout);
          break;
        case HttpMethod.delete:
          response = await http.delete(uri, headers: headers).timeout(timeout);
          break;
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        clearToken();
      }
      if (response.statusCode == 404) {
        return (
          false,
          "404: Endpoint not found!",
          null,
          response.statusCode,
          response.reasonPhrase,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return (
          false,
          "${response.statusCode}: ${response.reasonPhrase ?? genericError}",
          response.body,
          response.statusCode,
          response.reasonPhrase,
        );
      }
      String formattedResponse = response.body;
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/json')) {
        try {
          final dynamic jsonResponse = jsonDecode(response.body);
          formattedResponse = const JsonEncoder.withIndent(
            '  ',
          ).convert(jsonResponse);
          _tryAutoExtractToken(jsonResponse);
        } catch (e) {
          formattedResponse = response.body;
        }
      } else {
        formattedResponse = response.body;
      }

      return (
        true,
        null,
        formattedResponse,
        response.statusCode,
        response.reasonPhrase,
      );
    } on TimeoutException {
      return (false, "Request timed out after 5 seconds!", null, null, null);
    } on http.ClientException {
      return (false, genericError, null, null, null);
    } catch (e) {
      return (false, genericError, null, null, null);
    }
  }

  void _tryAutoExtractToken(dynamic jsonResponse) {
    try {
      if (jsonResponse is Map<String, dynamic>) {
        final String? accessToken = jsonResponse['accessToken'];

        if (accessToken != null) {
          setToken(accessToken);
        }
      }
    } catch (e) {
      // sadness
    }
  }

  //local storage

  Future<void> saveData({required String url, required String json}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("url", url);
    await prefs.setString("json", json);
  }

  Future<(String?, String?)> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = prefs.getString("url") ?? "";
    final json = prefs.getString("json") ?? "";
    return (url, json);
  }

  Future<void> clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _urlHistory = prefs.getStringList("urlHistory") ?? [];
    _jsonHistory = prefs.getStringList("jsonHistory") ?? [];
  }

  Future<void> _saveHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("urlHistory", _urlHistory);
    await prefs.setStringList("jsonHistory", _jsonHistory);
  }

  Future<void> initializeHistory() async {
    await _loadHistory();
  }

  Future<void> addToHistory(String? url, String? json) async {
    await _loadHistory();
    if (url != null && url.isNotEmpty) {
      _urlHistory.remove(url);
      _urlHistory.insert(0, url);
      if (_urlHistory.length > _maxHistoryItems) {
        _urlHistory = _urlHistory.take(_maxHistoryItems).toList();
      }
      _currentUrlIndex = 0;
    }
    if (json != null && json.isNotEmpty) {
      _jsonHistory.remove(json);
      _jsonHistory.insert(0, json);
      if (_jsonHistory.length > _maxHistoryItems) {
        _jsonHistory = _jsonHistory.take(_maxHistoryItems).toList();
      }
      _currentJsonIndex = 0;
    }

    await _saveHistory();
  }

  String? navigateUrlHistory(bool goUp) {
    if (_urlHistory.isEmpty) return null;

    if (goUp) {
      _currentUrlIndex =
          (_currentUrlIndex - 1 + _urlHistory.length) % _urlHistory.length;
    } else {
      _currentUrlIndex = (_currentUrlIndex + 1) % _urlHistory.length;
    }
    return _urlHistory[_currentUrlIndex];
  }

  String? navigateJsonHistory(bool goUp) {
    if (_jsonHistory.isEmpty) return null;

    if (goUp) {
      _currentJsonIndex =
          (_currentJsonIndex - 1 + _jsonHistory.length) % _jsonHistory.length;
    } else {
      _currentJsonIndex = (_currentJsonIndex + 1) % _jsonHistory.length;
    }
    return _jsonHistory[_currentJsonIndex];
  }

  FormValidation validateInputs(String url, String json, HttpMethod method) {
    bool isValidUrl = false;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      isValidUrl = uri.hasScheme && uri.hasAuthority;
    }

    final isUrlEmpty = url.trim().isEmpty || !isValidUrl;
    final isJsonEmpty = json.trim().isEmpty;

    if (isUrlEmpty && isJsonEmpty) return FormValidation.bothEmpty;
    if (isUrlEmpty) return FormValidation.urlEmpty;
    if (isJsonEmpty &&
        method != HttpMethod.get &&
        method != HttpMethod.delete) {
      return FormValidation.jsonEmpty;
    }
    return FormValidation.filled;
  }
}

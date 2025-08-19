import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

enum FormValidation { filled, urlEmpty, jsonEmpty, bothEmpty }

enum HttpMethod { get, post, patch, put, delete }

class MainWindowViewModel {
  final Duration timeout;

  MainWindowViewModel({this.timeout = const Duration(seconds: 5)});

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
      final headers = {'Content-Type': 'application/json'};
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
      try {
        final dynamic jsonResponse = jsonDecode(response.body);
        formattedResponse = const JsonEncoder.withIndent(
          '  ',
        ).convert(jsonResponse);
      } catch (e) {
        return (
          false,
          "An unexpected error occurred: ${e.toString()}",
          null,
          null,
          null,
        );
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

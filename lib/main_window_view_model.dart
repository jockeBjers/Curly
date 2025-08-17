import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

enum FormValidationState { filled, urlEmpty, jsonEmpty, bothEmpty }

enum HttpMethod { get, post, patch, put, delete }

class MainWindowViewModel {
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
        print("Error decoding JSON response: $e");
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

  FormValidationState validateInputs(
    String url,
    String json,
    HttpMethod method,
  ) {
    final uri = Uri.tryParse(url);
    final isUrlEmpty =
        url.trim().isEmpty || uri == null || !uri.hasAbsolutePath;
    final isJsonEmpty = json.trim().isEmpty;
    if (isUrlEmpty && isJsonEmpty) return FormValidationState.bothEmpty;
    if (isUrlEmpty) return FormValidationState.urlEmpty;
    if (isJsonEmpty && method != HttpMethod.get) {
      return FormValidationState.jsonEmpty;
    }
    return FormValidationState.filled;
  }
}

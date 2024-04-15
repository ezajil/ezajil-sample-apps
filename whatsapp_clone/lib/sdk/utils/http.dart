import 'dart:convert';
import 'package:http/http.dart' as http;

Future<http.Response> httpGet(
    String url, Future<String> Function(bool) authSupplier,
    [Map<String, dynamic>? queryParams]) async {
  var uri = Uri.parse(url);
  if (queryParams != null) {
    uri = uri.replace(queryParameters: queryParams);
  }

  var response = await callAPI(uri, authSupplier, 'GET');
  return response;
}

Future<http.Response> httpPost(
    String url, Future<String> Function(bool) authSupplier, dynamic body,
    [Map<String, dynamic>? queryParams]) async {
  var uri = Uri.parse(url);
  if (queryParams != null) {
    uri = uri.replace(queryParameters: queryParams);
  }

  var response = await callAPI(uri, authSupplier, 'POST',
      headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  return response;
}

Future<http.Response> uploadFile(String apiUrl,
    Future<String> Function(bool) authSupplier, dynamic body) async {
  var uri = Uri.parse(apiUrl);
  var response = await callAPI(uri, authSupplier, 'POST', body: body);
  return response;
}

Future<http.Response> callAPI(
    Uri url, Future<String> Function(bool) authSupplier, String method,
    {Map<String, String>? headers, dynamic body}) async {
  var accessToken = await authSupplier(true); // TODO
  headers ??= {};
  headers['Authorization'] = 'Bearer $accessToken';

  try {
    var response = http.Request(method, url)
      ..headers.addAll(headers)
      ..body = body ?? '';
    var streamedResponse = await response.send();
    var finalResponse = await http.Response.fromStream(streamedResponse);

    if (finalResponse.statusCode != 200) {
      // TODO
      // Handle non-200 responses or throw an error
      throw Exception('Failed to load data');
    }

    return finalResponse;
  } catch (e) {
    // Handle exceptions
    throw Exception('Error occurred: $e');
  }
}

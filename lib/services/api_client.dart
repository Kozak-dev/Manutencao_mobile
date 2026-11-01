import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static String baseUrl = 'http://10.0.2.2:5000/api'; // IP padrão do emulador Android para localhost
  static String? authToken;

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    return _send(() => http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers));
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    return _send(() => http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        ));
  }

  static Future<dynamic> patch(String endpoint, [Map<String, dynamic>? body]) async {
    return _send(() => http.patch(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  static Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Não foi possível conectar ao servidor.');
    } on HttpException {
      throw ApiException('Erro na comunicação com o servidor.');
    } on FormatException {
      throw ApiException('Resposta do servidor em formato inválido.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Não foi possível conectar ao servidor.');
    }
  }

  static dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      case 204:
        return null;
      case 400:
        String message = 'Dados inválidos.';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('message')) {
            message = data['message'].toString();
          } else if (data is Map && data.containsKey('errors')) {
            message = data['errors'].toString();
          }
        } catch (_) {}
        throw ApiException(message, statusCode: 400);
      case 401:
        throw ApiException('Sessão expirada. Faça login novamente.', statusCode: 401);
      case 403:
        throw ApiException('Você não possui permissão para realizar esta ação.', statusCode: 403);
      case 404:
        throw ApiException('Registro não encontrado.', statusCode: 404);
      case 500:
      default:
        throw ApiException('Erro no servidor. Tente novamente mais tarde.', statusCode: response.statusCode);
    }
  }
}

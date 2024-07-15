import 'dart:io';

import 'package:http/http.dart';

import '../modals/base_modal.dart';

abstract class ApiService<T extends BaseModal> {
  final Client client = Client();

  String get baseUrl;

  Map<String, String> getTokenHeaders(String token) => {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
      };

  Future<String> login(String username, String password);

  Future<T> getProfile(String token);
}

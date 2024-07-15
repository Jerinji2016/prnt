import 'dart:io';

import 'package:http/http.dart';

import '../modals/user_profile.dart';

abstract class ApiService {
  final Client client = Client();

  String get baseUrl;

  Map<String, String> getTokenHeaders(String token) => {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
      };

  Future<String> login(String username, String password);

  Future<DineazyProfile> getProfile(String token);
}

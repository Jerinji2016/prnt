import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../helpers/environment.dart';
import '../modals/profile/eazypms.profile.dart';
import 'api_service.dart';

class EazypmsApiService extends ApiService<EazypmsProfile> {
  @override
  String get baseUrl => Environment.eazypmsBaseUrl;

  @override
  Future<String> login(String username, String password) async {
    final uri = Uri.parse("$baseUrl/auth/login");
    Map<String, dynamic> body = {"email": username, "password": password};

    Response response = await client.post(
      uri,
      body: jsonEncode(body),
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    );

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    if (responseJson["status"] != 200) {
      debugPrint("EazyPMSApiService.login: ❌ERROR: $responseJson");
      throw responseJson["message"];
    }

    String? token = responseJson["data"]["token"];
    if (token == null) {
      debugPrint("EazyPMSApiService.login: ❌ERROR: ");
      throw "Failed to fetch token";
    }

    debugPrint("EazyPMSApiService.login: ✅ EazyPMS Login Successful");
    return token;
  }

  @override
  Future<EazypmsProfile> getProfile(String token) async {
    Uri uri = Uri.parse("$baseUrl/auth/profile");
    final headers = getTokenHeaders(token);
    Response response = await client.get(uri, headers: headers);

    if (response.statusCode != 200) {
      debugPrint("ApiManager.getUserProfile: ❌ERROR: ${response.body}");
      throw "Failed to fetch profile";
    }

    Map<String, dynamic> json = jsonDecode(response.body);
    return EazypmsProfile(json["data"]);
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../helpers/environment.dart';
import '../modals/profile/dineazy.profile.dart';
import 'api_service.dart';

class DineazyApiService extends ApiService<DineazyProfile> {
  @override
  String get baseUrl => Environment.dineazyBaseUrl;

  @override
  Future<String> login(String username, String password) async {
    Uri uri = Uri.parse("$baseUrl/auth/login");

    Map<String, dynamic> body = {
      "email": username,
      "password": password,
    };

    Response response = await client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
      body: jsonEncode(body),
    );

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    if (responseJson['code'] != 200) {
      debugPrint("DineazyApiService.login: ❌ERROR: $responseJson");
      throw "Invalid credentials";
    }

    String? token = responseJson["data"]["token"];
    if (token == null) {
      debugPrint("DineazyApiService.login: ❌ERROR: $responseJson");
      throw "Failed to fetch token";
    }

    debugPrint("DineazyApiService.login: ✅ Dineazy Login Successful");
    return token;
  }

  @override
  Future<DineazyProfile> getProfile(String token) async {
    Uri uri = Uri.parse("$baseUrl/auth/profile");
    final headers = getTokenHeaders(token);
    Response response = await client.get(uri, headers: headers);

    Map<String, dynamic> json = jsonDecode(response.body);
    if (json["code"] != 200) {
      throw "Failed to fetch Profile";
    }
    debugPrint("DineazyApiService.getProfile: ✅ Profile fetched successfully");
    return DineazyProfile(json["data"]);
  }
}

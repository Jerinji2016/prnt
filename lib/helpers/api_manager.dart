import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../modals/restaurant.dart';
import '../modals/user_profile.dart';

const String _prodBaseUrl = "https://dineazy-api.elaachi.com/api/v2";

const String _baseUrl = _prodBaseUrl;

class ApiManager {
  final Client _client = Client();

  Map<String, String> _getTokenHeaders(String token) => {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
      };

  Future<String> login(String username, String password) async {
    Uri uri = Uri.parse("$_baseUrl/auth/login");

    Map<String, dynamic> body = {
      "email": username,
      "password": password,
    };

    Response response = await _client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
      body: jsonEncode(body),
    );

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    if (responseJson['code'] != 200) {
      debugPrint("ApiManager.login: ❌ERROR: $responseJson");
      throw "Invalid credentials";
    }

    String? token = responseJson["data"]["token"];
    if (token == null) {
      debugPrint("ApiManager.login: ❌ERROR: $responseJson");
      throw "Failed to fetch token";
    }

    debugPrint("ApiManager.login: ✅ Login Successful");
    return token;
  }

  Future<UserProfile> getProfile(String token) async {
    Uri uri = Uri.parse("$_baseUrl/auth/profile");
    final headers = _getTokenHeaders(token);
    Response response = await _client.get(uri, headers: headers);

    Map<String, dynamic> json = jsonDecode(response.body);
    if (json["code"] != 200) {
      throw "Failed to fetch Profile";
    }
    debugPrint("ApiManager.getProfile: ✅ Profile fetched successfully");
    return UserProfile(json["data"]);
  }

  Future<Restaurant> getRestaurant(String token, String companyId, String revenueCenterId) async {
    Uri uri = Uri.parse("$_baseUrl/companies/$companyId");
    Response response = await _client.get(uri);

    Map<String, dynamic> json = jsonDecode(response.body);

    if (json["code"] != 200) {
      throw "Failed to fetch Restaurant details";
    }

    Map<String, dynamic> restaurantJson = (json["data"] as Map<String, dynamic>)
      ..addAll({
        "revenueCenterId": revenueCenterId,
      });

    Restaurant restaurant = Restaurant(restaurantJson);
    debugPrint("ApiManager.getRestaurantDetails: ✅ Fetched Restaurant Details: $restaurant");
    return restaurant;
  }
}

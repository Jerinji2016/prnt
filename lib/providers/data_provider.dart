import 'dart:convert';

import 'package:flutter/material.dart';

import '../helpers/globals.dart';
import '../modals/restaurant.dart';
import '../modals/user_profile.dart';

class DataProvider extends ChangeNotifier {
  static const _profileKey = "user-profile";
  static const _restaurantKey = "restaurant";

  DataProvider() {
    String? profileJson = sharedPreferences.getString(_profileKey);
    if (profileJson != null) {
      _profile = UserProfile(jsonDecode(profileJson));
    }

    String? restaurantJson = sharedPreferences.getString(_restaurantKey);
    if (restaurantJson != null) {
      _restaurant = Restaurant(jsonDecode(restaurantJson));
    }
  }

  UserProfile? _profile;

  Restaurant? _restaurant;

  bool get hasProfile => _profile != null;

  void save(UserProfile profile, Restaurant restaurant) {
    _profile = profile;
    _restaurant = restaurant;

    sharedPreferences.setString(
      _profileKey,
      jsonEncode(profile.json),
    );
    sharedPreferences.setString(
      _restaurantKey,
      jsonEncode(restaurant.json),
    );
  }

  bool hasSubscribed = false;

  UserProfile get profile => _profile!;

  Restaurant? get restaurant => _restaurant;

  void logout() {
    debugPrint("DataProvider.logout: ");
    sharedPreferences.remove(_profileKey);
    sharedPreferences.remove(_restaurantKey);
  }
}

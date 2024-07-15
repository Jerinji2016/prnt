import 'dart:convert';

import 'package:flutter/material.dart';

import '../helpers/globals.dart';
import '../modals/restaurant.dart';
import '../modals/user_profile.dart';

class DataProvider extends ChangeNotifier {
  static const _dineazyProfileKey = "dineazy-user-profile";
  static const _restaurantKey = "restaurant";

  static const _eazypmsProfileKey = "eazypms-user-profile";
  static const _propertyKey = "property";

  DataProvider() {
    String? profileJson = sharedPreferences.getString(_dineazyProfileKey);
    if (profileJson != null) {
      _dineazyProfile = DineazyProfile(jsonDecode(profileJson));
    }

    String? restaurantJson = sharedPreferences.getString(_restaurantKey);
    if (restaurantJson != null) {
      _restaurant = Restaurant(jsonDecode(restaurantJson));
    }
  }

  DineazyProfile? _dineazyProfile;

  Restaurant? _restaurant;

  bool get hasDineazyProfile => _dineazyProfile != null;

  void saveDineazyData(DineazyProfile profile, Restaurant restaurant) {
    _dineazyProfile = profile;
    _restaurant = restaurant;

    sharedPreferences.setString(
      _dineazyProfileKey,
      jsonEncode(profile.json),
    );
    sharedPreferences.setString(
      _restaurantKey,
      jsonEncode(restaurant.json),
    );

    notifyListeners();
  }

  DineazyProfile get dineazyProfile => _dineazyProfile!;

  Restaurant? get restaurant => _restaurant;

  void logoutOfDineazy() {
    sharedPreferences.remove(_dineazyProfileKey);
    sharedPreferences.remove(_restaurantKey);
    _dineazyProfile = null;
    _restaurant = null;
    notifyListeners();
  }
}

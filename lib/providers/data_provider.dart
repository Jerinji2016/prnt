import 'dart:convert';

import 'package:flutter/material.dart';

import '../helpers/globals.dart';
import '../modals/profile/dineazy.profile.dart';
import '../modals/profile/eazypms.profile.dart';

class DataProvider extends ChangeNotifier {
  static const _dineazyProfileKey = "dineazy-user-profile";
  static const _eazypmsProfileKey = "eazypms-user-profile";

  DataProvider() {
    String? profileJson = sharedPreferences.getString(_dineazyProfileKey);
    if (profileJson != null) {
      _dineazyProfile = DineazyProfile(jsonDecode(profileJson));
    }
  }

  DineazyProfile? _dineazyProfile;

  DineazyProfile get dineazyProfile => _dineazyProfile!;

  bool get hasDineazyProfile => _dineazyProfile != null;

  EazypmsProfile? _eazypmsProfile;

  EazypmsProfile get eazypmsProfile => _eazypmsProfile!;

  bool get hasEazypmsProfile => _eazypmsProfile != null;

  void saveDineazyData(DineazyProfile profile) {
    _dineazyProfile = profile;
    sharedPreferences.setString(
      _dineazyProfileKey,
      jsonEncode(profile.json),
    );

    debugPrint("DataProvider.saveDineazyData: ✅Dineazy Profile Saved");
    notifyListeners();
  }

  void saveEazypmsData(EazypmsProfile profile) {
    _eazypmsProfile = profile;
    sharedPreferences.setString(
      _eazypmsProfileKey,
      jsonEncode(profile.json),
    );

    notifyListeners();
  }

  void logoutOfDineazy() {
    sharedPreferences.remove(_dineazyProfileKey);
    _dineazyProfile = null;
    notifyListeners();
  }

  void logoutOfEazyPMS() {
    sharedPreferences.remove(_eazypmsProfileKey);
    _eazypmsProfile = null;
    notifyListeners();
  }
}

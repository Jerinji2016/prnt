import 'dart:convert';

import 'package:flutter/material.dart';

import '../enums/service_mode.dart';
import '../helpers/globals.dart';
import '../modals/profile/dineazy.profile.dart';
import '../modals/profile/eazypms.profile.dart';

class DataProvider extends ChangeNotifier {
  static const _dineazyProfileKey = "dineazy-user-profile";
  static const _eazypmsProfileKey = "eazypms-user-profile";

  static const _serviceModeKey = "service-mode";

  DataProvider() {
    String? dineazyProfileJson = sharedPreferences.getString(_dineazyProfileKey);
    if (dineazyProfileJson != null) {
      _dineazyProfile = DineazyProfile(jsonDecode(dineazyProfileJson));
    }

    String? eazypmsProfileJson = sharedPreferences.getString(_eazypmsProfileKey);
    if (eazypmsProfileJson != null) {
      _eazypmsProfile = EazypmsProfile(jsonDecode(eazypmsProfileJson));
    }

    int? modeIndex = sharedPreferences.getInt(_serviceModeKey);
    if (modeIndex != null) {
      _serviceMode = ServiceMode.fromIndex(modeIndex);
    }
  }

  DineazyProfile? _dineazyProfile;

  DineazyProfile get dineazyProfile => _dineazyProfile!;

  bool get hasDineazyProfile => _dineazyProfile != null;

  EazypmsProfile? _eazypmsProfile;

  EazypmsProfile get eazypmsProfile => _eazypmsProfile!;

  bool get hasEazypmsProfile => _eazypmsProfile != null;

  ServiceMode _serviceMode = ServiceMode.background;

  ServiceMode get serviceMode => _serviceMode;

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

  void saveServiceMode(ServiceMode mode) {
    sharedPreferences.setInt(_serviceModeKey, mode.index);
    _serviceMode = mode;
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

import 'dart:convert';

import 'package:flutter/material.dart';

import '../enums/foreground_service_status.dart';
import '../enums/service_mode.dart';
import '../helpers/globals.dart';
import '../modals/profile/dineazy.profile.dart';
import '../modals/profile/eazypms.profile.dart';

class DataProvider extends ChangeNotifier {
  static const _dineazyProfileKey = "dineazy-user-profile";
  static const _eazypmsProfileKey = "eazypms-user-profile";

  static const _serviceModeKey = "service-mode";
  static const _listeningTopicsKey = "listening-topics";

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

    if (_serviceMode == ServiceMode.foreground) return;

    String? listeningTopics = sharedPreferences.getString(_listeningTopicsKey);
    if (listeningTopics == null) return;
    Map<String, int> json = Map.from(jsonDecode(listeningTopics));
    _listeningTopics.clear();
    json.forEach((key, value) {
      ForegroundServiceStatus status = ForegroundServiceStatus.fromIndex(value);
      if (status == ForegroundServiceStatus.loading) {
        status = ForegroundServiceStatus.stopped;
      }
      _listeningTopics[key] = status;
    });
  }

  final Map<String, ForegroundServiceStatus> _listeningTopics = {};

  Map<String, ForegroundServiceStatus> get listeningTopics => _listeningTopics;

  DineazyProfile? _dineazyProfile;

  DineazyProfile get dineazyProfile => _dineazyProfile!;

  bool get hasDineazyProfile => _dineazyProfile != null;

  EazypmsProfile? _eazypmsProfile;

  EazypmsProfile get eazypmsProfile => _eazypmsProfile!;

  bool get hasEazypmsProfile => _eazypmsProfile != null;

  ServiceMode _serviceMode = ServiceMode.background;

  bool get isBackgroundServiceMode => _serviceMode == ServiceMode.background;

  bool get isForegroundServiceMode => _serviceMode == ServiceMode.foreground;

  void updateTopicStatus(String topic, ForegroundServiceStatus status) {
    _listeningTopics[topic] = status;
    Map json = {};
    _listeningTopics.forEach((key, value) {
      json[key] = value.index;
    });
    sharedPreferences.setString(_listeningTopicsKey, jsonEncode(json));
  }

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

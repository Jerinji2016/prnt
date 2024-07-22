import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../enums/foreground_service_status.dart';
import '../enums/service_mode.dart';
import '../helpers/globals.dart';
import '../helpers/utils.dart';
import '../modals/profile/dineazy.profile.dart';
import '../modals/profile/eazypms.profile.dart';
import '../service/redis_service.dart';

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

    isForegroundServiceRunning().then((value) {
      if (!value) {
        sharedPreferences.remove(_listeningTopicsKey);
        _listeningTopics.clear();
        notifyListeners();
      }
    });
  }

  final Map<String, ForegroundServiceStatus> _listeningTopics = {};

  int get listeningTopicsCount => _listeningTopics.values
      .where(
        (element) => element == ForegroundServiceStatus.running,
      )
      .length;

  Iterable<String> getListeningTopicsOfProduct(String product) => _listeningTopics.keys.where(
        (topic) => topic.contains(product.toLowerCase()) && _listeningTopics[topic] == ForegroundServiceStatus.running,
      );

  Future<void> unregisterTopics(Iterable<String> topics) async {
    if (isForegroundServiceMode) {
      RedisService redisService = RedisService();
      await Future.wait(
        topics.map(
          (topic) => redisService.stopListeningOnTopic(topic).then(
                (value) => _listeningTopics.remove(topic),
              ),
        ),
      );
    } else {
      SendPort? port = IsolateNameServer.lookupPortByName(headlessPortName);
      for (String topic in topics) {
        port?.send([topic, "unsubscribe"]);
      }
    }
  }

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
    Map json = _listeningTopics.map((key, value) => MapEntry(key, value.index));
    sharedPreferences.setString(_listeningTopicsKey, jsonEncode(json));
    notifyListeners();
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

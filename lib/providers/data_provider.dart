import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prnt/modals/print_data.dart';

import '../helpers/globals.dart';
import '../modals/message_data.dart';
import '../modals/user_profile.dart';

class DataProvider extends ChangeNotifier {
  static const _profileKey = "user-profile";

  DataProvider() {
    String? profileJson = sharedPreferences.getString(_profileKey);
    if (profileJson != null) {
      _profile = UserProfile(jsonDecode(profileJson));
    }
  }

  UserProfile? _profile;

  bool get hasProfile => _profile != null;

  void setProfile(UserProfile profile) {
    _profile = profile;
    sharedPreferences.setString(
      _profileKey,
      jsonEncode(profile.json),
    );
  }

  bool hasSubscribed = false;

  UserProfile get profile => _profile!;

  final List<PrintMessageData> _messages = [];

  Iterable<PrintMessageData> get messages => _messages;

  void saveMessage(PrintMessageData data) {
    _messages.add(data);
    notifyListeners();
  }
}

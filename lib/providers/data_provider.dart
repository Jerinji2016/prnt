import 'package:flutter/material.dart';

import '../modals/user_profile.dart';

class DataProvider extends ChangeNotifier {
  UserProfile? _profile;

  bool get hasProfile => _profile != null;

  void setProfile(UserProfile profile) => _profile = profile;

  UserProfile get profile => _profile!;
}

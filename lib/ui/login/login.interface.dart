import 'package:flutter/cupertino.dart';

abstract class LoginInterface {
  ValueNotifier<String?> get loadingMessage;

  Future<void> onLogin(BuildContext context, String username, password);
}

import 'dart:isolate';

import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences sharedPreferences;

const headlessPortName = "headless-port";
const uiPortName = "ui-port";

final ReceivePort headlessReceivePort = ReceivePort("port: $headlessPortName");
final ReceivePort uiReceivePort = ReceivePort("port: uiPortName");

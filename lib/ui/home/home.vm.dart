import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/foreground_service_status.dart';
import '../../helpers/globals.dart';
import '../../helpers/utils.dart';
import '../../providers/data_provider.dart';
import '../../service/headless/headless_service.dart';
import '../../service/redis_service.dart';
import '../../ui.bottom_sheet/settings/settings.dart';
import '../messages/messages.dart';
import '../setup_printers/setup_printers.dart';

class HomeViewModal extends ChangeNotifier {
  final BuildContext context;

  HomeViewModal(this.context) {
    IsolateNameServer.removePortNameMapping(uiPortName);
    bool uiPortStatus = IsolateNameServer.registerPortWithName(uiReceivePort.sendPort, uiPortName);
    debugPrint("HomeViewModal.HomeViewModal: ✅UI Port registered ($uiPortStatus)");

    uiReceivePort.listen(_onData);

    isForegroundServiceRunning().then((value) {
      _isHeadlessInitialized = value;
      notifyListeners();
    });
  }

  bool _isHeadlessInitialized = false;

  final Map<String, String> _topicCache = {};

  void onMessagesIconTapped(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MessagesScreen()),
      );

  void onSettingsIconTapped(BuildContext context) => Settings.show(context);

  void onSetupPrinterTapped(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetupPrintersScreen()),
      );

  void _updateStatus(String topic, ForegroundServiceStatus status) {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.updateTopicStatus(topic, status);
    notifyListeners();
  }

  void _listenOnForeground(BuildContext context, String topic) async {
    debugPrint("HomeViewModal._listenOnForeground: 🐞======== FOREGROUND ========");
    bool isListeningToTopic = getTopicStatus(context, topic) == ForegroundServiceStatus.running;
    _updateStatus(topic, ForegroundServiceStatus.loading);

    try {
      RedisService redisService = RedisService();
      String toastMessage;
      if (!isListeningToTopic) {
        await redisService.startListeningOnTopic(topic);
        toastMessage = "Subscribed successfully";
        _updateStatus(topic, ForegroundServiceStatus.running);
      } else {
        await redisService.stopListeningOnTopic(topic);
        toastMessage = "Unsubscribed successfully";
        _updateStatus(topic, ForegroundServiceStatus.stopped);
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        showToast(context, toastMessage, color: Colors.green);
      }
    } catch (e) {
      debugPrint("_DineazyNotificationServicePanelState._onTap: ❌ERROR: $e");
      _updateStatus(topic, ForegroundServiceStatus.stopped);
      if (context.mounted) {
        showToast(context, e.toString(), color: Colors.red);
      }
    }
  }

  void _listenOnBackground(BuildContext context, String topic) async {
    debugPrint("HomeViewModal._listenOnForeground: 🐞======== BACKGROUND ========");
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    bool isListeningToTopic = getTopicStatus(context, topic) == ForegroundServiceStatus.running;
    bool isNotificationServiceRunning = await isForegroundServiceRunning();
    _updateStatus(topic, ForegroundServiceStatus.loading);

    if (isListeningToTopic) {
      SendPort? port = IsolateNameServer.lookupPortByName(headlessPortName);
      port?.send([topic, "unsubscribe"]);
      return;
    }

    if (!isNotificationServiceRunning && context.mounted) {
      try {
        await HeadlessService.initialize(context);
      } catch (e) {
        debugPrint("HomeViewModal.listenToTopic: ❌ERROR: $e");
        dataProvider.updateTopicStatus(topic, ForegroundServiceStatus.stopped);
        notifyListeners();
      }
    }

    if (!_isHeadlessInitialized) {
      debugPrint("HomeViewModal.listenToTopic: 🐞headless not initialized");
      _topicCache[topic] = "subscribe";
      return;
    }

    SendPort? port = IsolateNameServer.lookupPortByName(headlessPortName);
    port?.send([topic, "subscribe"]);
  }

  void toggleTopicListeningStatus(BuildContext context, String topic) async {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    bool isBackgroundServiceMode = dataProvider.isBackgroundServiceMode;
    if (isBackgroundServiceMode) {
      return _listenOnBackground(context, topic);
    }

    return _listenOnForeground(context, topic);
  }

  ForegroundServiceStatus getTopicStatus(BuildContext context, String topic, {bool listen = false}) {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: listen);
    return dataProvider.listeningTopics[topic] ?? ForegroundServiceStatus.stopped;
  }

  void _subscribePendingTopics() {
    debugPrint("HomeViewModal._subscribePendingTopics: 🐞");
    if (_topicCache.isEmpty) return;
    SendPort? port = IsolateNameServer.lookupPortByName(headlessPortName);
    if (port == null) {
      debugPrint("HomeViewModal._subscribePendingTopics: 🐞no port found");
      _topicCache.clear();
      DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
      for (var topic in dataProvider.listeningTopics.keys) {
        dataProvider.updateTopicStatus(topic, ForegroundServiceStatus.stopped);
      }
      return;
    }

    debugPrint("HomeViewModal._subscribePendingTopics: 🐞subscribing to ${_topicCache.keys.length} topics");
    for (String topic in _topicCache.keys) {
      String action = _topicCache[topic]!;
      port.send([topic, action]);
    }

    _topicCache.clear();
  }

  void _onData(dynamic data) {
    debugPrint("HomeViewModal._onData: 🐞$data");

    if (data[0] == 'headless') {
      _isHeadlessInitialized = true;
      _subscribePendingTopics();
      return;
    }

    String topic = data[0];
    bool status = data[2];
    if (!status) {
      _updateStatus(topic, ForegroundServiceStatus.stopped);
      return;
    }

    String action = data[1];

    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);

    String toastMessage;
    if (action == "subscribe") {
      dataProvider.updateTopicStatus(topic, ForegroundServiceStatus.running);
      toastMessage = "Subscribed successfully";
    } else {
      dataProvider.updateTopicStatus(topic, ForegroundServiceStatus.stopped);
      bool hasRunningStatus = dataProvider.listeningTopics.values.any(
        (value) => value == ForegroundServiceStatus.running,
      );

      if (!hasRunningStatus) {
        debugPrint("HomeViewModal._listenOnBackground: 🐞Not listening to any topics");
        dataProvider.clearListeningTopic();
        HeadlessService.stop();
      }

      toastMessage = "Unsubscribed successfully";
    }
    showToast(context, toastMessage, color: Colors.green);
    notifyListeners();
  }
}

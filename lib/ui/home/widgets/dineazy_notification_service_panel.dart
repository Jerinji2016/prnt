import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../enums/foreground_service_status.dart';
import '../../../helpers/utils.dart';
import '../../../providers/data_provider.dart';
import '../../../service/redis_service.dart';
import '../../../widgets/primary_button.dart';

class DineazyNotificationServicePanel extends StatefulWidget {
  const DineazyNotificationServicePanel({super.key});

  @override
  State<DineazyNotificationServicePanel> createState() => _DineazyNotificationServicePanelState();
}

class _DineazyNotificationServicePanelState extends State<DineazyNotificationServicePanel> {
  ForegroundServiceStatus status = ForegroundServiceStatus.stopped;

  bool _runOnUiIsolate = true;

  @override
  void initState() {
    super.initState();
    _loadServiceStatus();
  }

  void _loadServiceStatus() async {
    bool isServiceRunning = await isForegroundServiceRunning();
    setState(() {
      status = isServiceRunning ? ForegroundServiceStatus.running : ForegroundServiceStatus.stopped;
    });
  }

  void _runOnUIIsolate() async {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    String topic = dataProvider.dineazyProfile.redisTopic;

    bool isServiceRunning = status == ForegroundServiceStatus.running;

    setState(() => status = ForegroundServiceStatus.loading);
    ForegroundServiceStatus nextStatus;

    RedisService redisService = RedisService(topic);
    if (!isServiceRunning) {
      redisService.startListeningOnUiIsolate();

      nextStatus = ForegroundServiceStatus.running;
      if (mounted) {
        showToast(context, "Subscribed successfully", color: Colors.green);
      }
    } else {
      await redisService.stopListeningOnUiIsolate();
      nextStatus = ForegroundServiceStatus.stopped;
      if (mounted) {
        showToast(context, "Unsubscribed successfully");
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() => status = nextStatus);
  }

  void _onTap() async {
    if (_runOnUiIsolate) {
      return _runOnUIIsolate();
    }

    bool isServiceRunning = status == ForegroundServiceStatus.running;
    setState(() => status = ForegroundServiceStatus.loading);

    if (isServiceRunning) {
      bool response = await stopForegroundService();
      await Future.delayed(const Duration(seconds: 2));
      debugPrint("_PrinterServiceStatusPanelState._onTap: Stop Foreground Service status: ${response ? "✅" : "❌"}");
    } else {
      bool response = await startForegroundService();
      await Future.delayed(const Duration(seconds: 5));
      debugPrint("_PrinterServiceStatusPanelState._onTap: Start Foreground Service status: ${response ? "✅" : "❌"}");
    }

    _loadServiceStatus();
  }

  void _onSwitchTapped(bool value) {
    showToast(context, "Background Service is unavailable");
    return;

    //  ignore: dead_code
    if (status == ForegroundServiceStatus.running) {
      showToast(context, "Stop service to toggle");
      return;
    }
    if (!value) {
      showToast(context, "Service won't work as expected");
    }
    setState(() => _runOnUiIsolate = value);
  }

  @override
  Widget build(BuildContext context) {
    bool isServiceStopped = status == ForegroundServiceStatus.stopped;

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
      elevation: 10.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Printer Service",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Icon(
                        status.icon,
                        color: status.iconColor,
                        size: 20.0,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Status: ",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      Text(
                        status.name,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 30.0,
                        width: 40.0,
                        child: FittedBox(
                          child: Switch(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            value: _runOnUiIsolate,
                            onChanged: _onSwitchTapped,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        _runOnUiIsolate ? "ON FOREGROUND" : "ON BACKGROUND",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: status == ForegroundServiceStatus.loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : PrimaryButton(
                        onTap: _onTap,
                        color: isServiceStopped ? null : Colors.red.shade900,
                        textColor: isServiceStopped ? null : Colors.white,
                        text: isServiceStopped ? "Start" : "Stop",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

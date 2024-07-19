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

  void _onTap() async {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    String topic = dataProvider.dineazyProfile.redisTopic;

    bool isServiceRunning = status == ForegroundServiceStatus.running;

    setState(() => status = ForegroundServiceStatus.loading);
    ForegroundServiceStatus nextStatus;

    try {
      RedisService redisService = RedisService(topic);
      String toastMessage;
      if (!isServiceRunning) {
        await redisService.listenToTopic(context);

        nextStatus = ForegroundServiceStatus.running;
        toastMessage = "Subscribed successfully";
      } else {
        await redisService.stopListeningToTopic(context);
        nextStatus = ForegroundServiceStatus.stopped;
        toastMessage = "Unsubscribed successfully";
      }

      await Future.delayed(const Duration(seconds: 1));
      setState(() => status = nextStatus);
      if (mounted) {
        showToast(context, toastMessage, color: Colors.green);
      }
    } catch (e) {
      debugPrint("_DineazyNotificationServicePanelState._onTap: ❌ERROR: $e");
      setState(() => status = ForegroundServiceStatus.stopped);
      if (mounted) {
        showToast(context, e.toString(), color: Colors.red);
      }
    }
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
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: status == ForegroundServiceStatus.loading
                    ? const Center(
                        child: SizedBox.square(
                          dimension: 28.0,
                          child: CircularProgressIndicator(),
                        ),
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

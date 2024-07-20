import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../enums/foreground_service_status.dart';
import '../../../providers/data_provider.dart';
import '../../../widgets/primary_button.dart';
import '../home.vm.dart';

class DineazyNotificationServicePanel extends StatefulWidget {
  const DineazyNotificationServicePanel({super.key});

  @override
  State<DineazyNotificationServicePanel> createState() => _DineazyNotificationServicePanelState();
}

class _DineazyNotificationServicePanelState extends State<DineazyNotificationServicePanel> {
  late String topic;

  @override
  void initState() {
    super.initState();

    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    topic = dataProvider.dineazyProfile.redisTopic;
  }

  void _onTap() async {
    HomeViewModal viewModal = Provider.of<HomeViewModal>(context, listen: false);
    viewModal.toggleTopicListeningStatus(context, topic);
  }

  @override
  Widget build(BuildContext context) {
    HomeViewModal viewModal = Provider.of<HomeViewModal>(context);
    ForegroundServiceStatus status = viewModal.getTopicStatus(context, topic);
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

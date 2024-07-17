import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../enums/foreground_service_status.dart';
import '../../../helpers/utils.dart';
import '../../../modals/profile/eazypms.profile.dart';
import '../../../providers/data_provider.dart';
import '../../../service/foreground_service.dart';
import '../../../widgets/primary_button.dart';

class EazypmsNotificationServicePanel extends StatelessWidget {
  const EazypmsNotificationServicePanel({super.key});

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    final revenueCenters = dataProvider.eazypmsProfile.company.revenueCenters.where(
      (rvc) => !["Company", "Property"].contains(rvc.objectType),
    );

    return ListView.builder(
      itemCount: revenueCenters.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      itemBuilder: (context, index) {
        EazypmsRevenueCenter revenueCenter = revenueCenters.elementAt(index);
        return RevenueCenterServiceTile(revenueCenter: revenueCenter);
      },
    );
  }
}

class RevenueCenterServiceTile extends StatefulWidget {
  final EazypmsRevenueCenter revenueCenter;

  const RevenueCenterServiceTile({
    super.key,
    required this.revenueCenter,
  });

  @override
  State<RevenueCenterServiceTile> createState() => _RevenueCenterServiceTileState();
}

class _RevenueCenterServiceTileState extends State<RevenueCenterServiceTile> {
  ForegroundServiceStatus status = ForegroundServiceStatus.stopped;

  void _onTap() async {
    String topic = widget.revenueCenter.redisTopic;
    bool isServiceRunning = status == ForegroundServiceStatus.running;

    setState(() => status = ForegroundServiceStatus.loading);
    ForegroundServiceStatus nextStatus;
    if (!isServiceRunning) {
      runServerOnMainIsolate(topic);

      nextStatus = ForegroundServiceStatus.running;
      if (mounted) {
        showToast(context, "Subscribed successfully", color: Colors.green);
      }
    } else {
      await stopServerOnMainIsolate(topic);
      nextStatus = ForegroundServiceStatus.stopped;
      if (mounted) {
        showToast(context, "Unsubscribed successfully");
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() => status = nextStatus);
  }

  Widget _buildStatusText() {
    return Row(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isServiceStopped = status == ForegroundServiceStatus.stopped;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.revenueCenter.name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Icon(
                          status.icon,
                          color: status.iconColor,
                          size: 20.0,
                        )
                      ],
                    ),
                    _buildStatusText(),
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
      ),
    );
  }
}

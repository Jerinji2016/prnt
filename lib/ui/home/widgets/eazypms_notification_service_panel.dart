import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../enums/foreground_service_status.dart';
import '../../../modals/profile/eazypms.profile.dart';
import '../../../providers/data_provider.dart';
import '../../../widgets/primary_button.dart';
import '../home.vm.dart';

class EazypmsNotificationServicePanel extends StatelessWidget {
  const EazypmsNotificationServicePanel({super.key});

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    final revenueCenters = dataProvider.eazypmsProfile.company.nonPropertyRevenueCenters;

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
  String get topic => widget.revenueCenter.redisTopic;

  void _onTap() async {
    HomeViewModal viewModal = Provider.of<HomeViewModal>(context, listen: false);
    viewModal.toggleTopicListeningStatus(context, topic);
  }

  Widget _buildStatusText(ForegroundServiceStatus status) {

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
    HomeViewModal viewModal = Provider.of<HomeViewModal>(context);
    ForegroundServiceStatus status = viewModal.getTopicStatus(context, topic, listen: true);
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
                        ),
                      ],
                    ),
                    _buildStatusText(status),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../widgets/primary_button.dart';

class ConfirmLogout extends StatelessWidget {
  static Future<bool?> show(BuildContext context, String product) => showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        builder: (context) => BottomSheet(
          onClosing: () {},
          builder: (context) {
            return ConfirmLogout._(product);
          },
        ),
      );

  final String product;

  const ConfirmLogout._(this.product);

  Widget _buildRunningServiceWarning(BuildContext context, int count) {
    return Material(
      color: Colors.yellow.shade200.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Colors.yellow.shade700,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.report_outlined,
              color: Colors.yellow.shade700,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                "You have $count service(s) running. Logging out will stop these services.",
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    int listeningTopicsCount = dataProvider.getListeningTopicsOfProduct(product).length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Confirm Logout?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
            ),
          ),
          const SizedBox(height: 12.0),
          Text("Are you sure you want to logout of $product?"),
          if (listeningTopicsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildRunningServiceWarning(context, listeningTopicsCount),
            ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PrimaryButton(
                text: "Close",
                onTap: () => Navigator.pop(context, false),
                textColor: Colors.white,
                color: Colors.red.shade700,
              ),
              PrimaryButton(
                text: "Yes, Logout",
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

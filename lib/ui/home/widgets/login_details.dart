import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../modals/restaurant.dart';
import '../../../providers/data_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../login.dart';

class LoginDetails extends StatelessWidget {
  const LoginDetails({super.key});

  void _onLogoutTapped(BuildContext context) async {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    Restaurant? restaurant = dataProvider.restaurant;

    return Column(
      children: [
        Text(
          restaurant?.name ?? "Unknown Restaurant",
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (restaurant != null && restaurant.description.isNotEmpty)
          Text(
            restaurant.description,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        SizedBox(
          width: MediaQuery.of(context).size.shortestSide * 0.5,
          child: PrimaryButton(
            text: "Logout",
            onTap: () => _onLogoutTapped(context),
          ),
        ),
      ],
    );
  }
}

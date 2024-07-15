import 'package:flutter/material.dart';

import '../../../widgets/primary_button.dart';

abstract class LogoutInterface {
  void onLogoutTapped(BuildContext context);
}

class LoginDetails extends StatelessWidget {
  final String name;
  final String? description;
  final LogoutInterface impl;

  const LoginDetails({
    super.key,
    required this.name,
    required this.description,
    required this.impl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (description?.isNotEmpty ?? false)
          Text(
            description!,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        SizedBox(
          width: MediaQuery.of(context).size.shortestSide * 0.5,
          child: PrimaryButton(
            text: "Logout",
            onTap: () => impl.onLogoutTapped(context),
          ),
        ),
      ],
    );
  }
}

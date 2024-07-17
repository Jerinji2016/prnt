import 'package:flutter/material.dart';

enum ForegroundServiceStatus {
  stopped(
    name: "Stopped",
    icon: Icons.block_outlined,
    iconColor: Colors.red,
  ),
  running(
    name: "Running",
    icon: Icons.check_circle_outline,
    iconColor: Colors.green,
  ),
  loading(
    name: "Loading",
    icon: Icons.run_circle_outlined,
    iconColor: Colors.grey,
  );

  final String name;
  final IconData icon;
  final Color iconColor;

  const ForegroundServiceStatus({
    required this.name,
    required this.icon,
    required this.iconColor,
  });
}

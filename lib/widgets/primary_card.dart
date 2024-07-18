import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryCard extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;
  final VoidCallback? onTap;

  const PrimaryCard({
    super.key,
    this.padding = const EdgeInsets.all(16.0),
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

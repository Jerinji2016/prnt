import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../helpers/utils.dart';
import '../../modals/print_message_data.dart';

class ViewBillBottomSheet extends StatefulWidget {
  final PrintData data;

  static void show(BuildContext context, {required PrintData data}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ViewBillBottomSheet._(data: data),
    );
  }

  const ViewBillBottomSheet._({required this.data});

  @override
  State<ViewBillBottomSheet> createState() => _ViewBillBottomSheetState();
}

class _ViewBillBottomSheetState extends State<ViewBillBottomSheet> {
  Uint8List _imageBytes = Uint8List(0);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => contentToImage(widget.data.template).then(
        (bytes) => setState(() {
          _imageBytes = Uint8List.fromList(bytes);
          _isLoading = false;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Image.memory(
        _imageBytes,
        width: MediaQuery.of(context).size.shortestSide,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}

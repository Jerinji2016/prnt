import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../db/message.table.dart';
import '../../helpers/globals.dart';
import '../../helpers/types.dart';
import '../../helpers/utils.dart';
import '../../modals/message_data.dart';
import '../../modals/print_message_data.dart';
import '../../providers/data_provider.dart';
import '../../service/redis_service.dart';
import '../../widgets/primary_button.dart';
import 'view_bill.bottom_sheet.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageRecordList _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) => _loadMessages(),
    );
  }

  void _loadMessages() async {
    debugPrint("_MessagesScreenState._loadMessages: ");
    setState(() => _isLoading = true);

    MessageRecordIterable messages = await MessageTable().getAll();
    _messages
      ..clear()
      ..addAll(messages);

    //  simply to get loading feeling
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Log"),
        elevation: 2.0,
        actions: [
          IconButton(
            onPressed: _loadMessages,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10.0),
                  Text("Loading messages..."),
                ],
              ),
            );
          }

          if (_messages.isEmpty) {
            return const Center(
              child: Text("No messages yet!"),
            );
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              MessageRecord message = _messages.elementAt(index);

              return MessageTile(
                index: index,
                record: message,
              );
            },
            itemCount: _messages.length,
          );
        },
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  final int index;
  final MessageRecord record;

  const MessageTile({
    super.key,
    required this.index,
    required this.record,
  });

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _isPrintLoading = false;

  PrintMessageData get message => widget.record.data;

  void _onViewTapped(BuildContext context, PrintMessageData message) =>
      ViewBillBottomSheet.show(context, data: message.data);

  void _onPrintTapped(PrintMessageData message) async {
    setState(() => _isPrintLoading = true);

    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.isBackgroundServiceMode && await isForegroundServiceRunning()) {
      debugPrint("_MessageTileState._onPrintTapped: 🐞Dispatch print in background");
      SendPort? port = IsolateNameServer.lookupPortByName(headlessPortName);
      port?.send(['print', widget.record.id]);
    } else {
      debugPrint("_MessageTileState._onPrintTapped: 🐞Dispatch print in foreground");
      RedisService.dispatchPrint(message);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isPrintLoading = false);
    if (mounted) {
      showToast(context, "Print dispatched successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Message ${widget.record.id}",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Printer: ${message.data.printer.value}",
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 16.0),
                Text(
                  DateFormat("dd MMM yyyy, hh:mm a").format(message.timestamp),
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              PrimaryButton(
                text: "View",
                onTap: () => _onViewTapped(context, message),
              ),
              _isPrintLoading
                  ? const SizedBox(
                      height: 48.0,
                      width: 48.0,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : PrimaryButton(
                      text: "Print",
                      onTap: () => _onPrintTapped(message),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

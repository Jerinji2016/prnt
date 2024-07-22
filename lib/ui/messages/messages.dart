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
import '../../modals/profile/eazypms.profile.dart';
import '../../providers/data_provider.dart';
import '../../service/redis_service.dart';
import '../../widgets/primary_button.dart';
import 'view_bill.bottom_sheet.dart';

class MessageFilter {
  final String label;
  final bool Function(String topic) predicate;

  MessageFilter({
    required this.label,
    required this.predicate,
  });
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageRecordList _messages = [];
  bool _isLoading = false;

  final List<int> _selectedFilterIndex = [];

  final List<MessageFilter> _filters = [];

  MessageRecordList get _filteredMessages {
    if (_selectedFilterIndex.isEmpty) return _messages;

    List<MessageFilter> filters = _selectedFilterIndex.map((index) => _filters.elementAt(index)).toList();
    MessageRecordList filteredMessages = [];
    for (MessageRecord message in _messages) {
      if (filters.any((filter) => filter.predicate(message.data.channel))) {
        filteredMessages.add(message);
      }
    }
    return filteredMessages;
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) => _loadMessages(),
    );

    _loadFilters();
  }

  Future<void> _loadMessages() async {
    debugPrint("_MessagesScreenState._loadMessages: ");
    setState(() => _isLoading = true);

    MessageRecordIterable messages = await MessageTable().getAll();
    _messages
      ..clear()
      ..addAll(messages);

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoading = false);
  }

  void _loadFilters() {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.hasDineazyProfile) {
      final filter = MessageFilter(
        label: "Dineazy",
        predicate: (topic) => topic.contains("dineazy"),
      );
      _filters.add(filter);
    }

    if (dataProvider.hasEazypmsProfile) {
      final filter = MessageFilter(
        label: "eazyPMS",
        predicate: (topic) => topic.contains("eazypms"),
      );
      _filters.add(filter);

      for (EazypmsRevenueCenter revenueCenter in dataProvider.eazypmsProfile.company.nonPropertyRevenueCenters) {
        final filter = MessageFilter(
          label: revenueCenter.name,
          predicate: (topic) => topic.contains("eazypms") && topic.contains(revenueCenter.id),
        );
        _filters.add(filter);
      }
    }
  }

  void _onFilterTapped(int index) => setState(() {
        if (_selectedFilterIndex.contains(index)) {
          _selectedFilterIndex.remove(index);
        } else {
          _selectedFilterIndex.add(index);
        }
      });

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: Wrap(
        runSpacing: 8.0,
        spacing: 12.0,
        children: _filters.indexed.map<Widget>(
          (record) {
            int index = record.$1;
            final filter = record.$2;

            bool isSelected = _selectedFilterIndex.contains(index);
            Color color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor;

            return Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(width: 1.5, color: color),
              ),
              child: InkWell(
                onTap: () => _onFilterTapped(index),
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
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

          MessageRecordList messages = _filteredMessages;

          if (messages.isEmpty) {
            return Column(
              children: [
                _buildFilter(),
                const Divider(),
                const Expanded(
                  child: Center(
                    child: Text("No messages yet!"),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildFilter(),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    MessageRecord message = messages.elementAt(index);

                    return MessageTile(
                      index: index,
                      record: message,
                    );
                  },
                  itemCount: messages.length,
                ),
              ),
            ],
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

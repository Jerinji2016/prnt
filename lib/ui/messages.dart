import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pos_printer_manager/models/pos_printer.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/services/printer_manager.dart';

import '../connection_adapters/impl.dart';
import '../db/message.table.dart';
import '../helpers/extensions.dart';
import '../helpers/types.dart';
import '../helpers/utils.dart';
import '../modals/message_data.dart';
import '../modals/print_data.dart';
import '../service/foreground_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/printer_connection_panel.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

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
    await Future.delayed(const Duration(seconds: 1));

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
      body: Builder(builder: (context) {
        if (_isLoading) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [CircularProgressIndicator(), SizedBox(height: 10.0), Text("Loading messages...")],
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
      }),
    );
  }
}

class MessageTile extends StatefulWidget {
  final int index;
  final MessageRecord record;

  const MessageTile({
    Key? key,
    required this.index,
    required this.record,
  }) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _isPrintLoading = false;

  PrintMessageData get message => widget.record.data;

  void _onViewTapped(BuildContext context, PrintMessageData message) => showModalBottomSheet(
        context: context,
        builder: (context) => ViewReceiptDelegate(data: message.data),
      );

  void _onPrintTapped(PrintMessageData message) async {
    setState(() => _isPrintLoading = true);

    await dispatchPrint(message);

    setState(() => _isPrintLoading = true);
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
          bottom: BorderSide(color: Colors.grey[500]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Message ${widget.index + 1}",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  "Printer: ${message.data.printer.name}",
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Value: ${message.data.printer.value}",
                  style: const TextStyle(
                    fontSize: 12.0,
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

class ViewReceiptDelegate extends StatefulWidget {
  final PrintData data;

  const ViewReceiptDelegate({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<ViewReceiptDelegate> createState() => _ViewReceiptDelegateState();
}

class _ViewReceiptDelegateState extends State<ViewReceiptDelegate> {
  Uint8List _imageBytes = Uint8List(0);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => generateImageBytesFromHtml(widget.data.template).then(
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
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        scale: 4.0,
      ),
    );
  }
}

class SelectPrinterDelegate extends StatefulWidget {
  final List<int> data;

  const SelectPrinterDelegate({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<SelectPrinterDelegate> createState() => _SelectPrinterDelegateState();
}

class _SelectPrinterDelegateState extends State<SelectPrinterDelegate> {
  void _onPrinterSelected(
    ConnectionType type,
    POSPrinter printer,
    PrinterManager manager,
  ) async {
    debugPrint("_SelectPrinterDelegateState._onPrinterSelected: ");
    IPrinterConnectionAdapters? adapter = printer.connectionType?.getAdapter();
    if (adapter == null) {
      debugPrint("_SelectPrinterDelegateState._onPrinterSelected: ❌ERROR: Failed to get connection type");
      return;
    }
    final manager = await adapter.connect(printer);

    await adapter.dispatchPrint(manager, widget.data);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Select Printer",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        PrinterConnectionPanel(
          type: ConnectionType.bluetooth,
          onPrinterTapped: _onPrinterSelected,
        ),
        PrinterConnectionPanel(
          type: ConnectionType.network,
          onPrinterTapped: _onPrinterSelected,
        ),
        PrinterConnectionPanel(
          type: ConnectionType.usb,
          onPrinterTapped: _onPrinterSelected,
        ),
      ],
    );
  }
}

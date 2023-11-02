import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redis/redis.dart';

import '../helpers/globals.dart';
import '../modals/message_data.dart';
import '../modals/print_data.dart';
import '../providers/data_provider.dart';
import '../widgets/primary_button.dart';

class PubSubScreen extends StatefulWidget {
  const PubSubScreen({Key? key}) : super(key: key);

  @override
  State<PubSubScreen> createState() => _PubSubScreenState();
}

class _PubSubScreenState extends State<PubSubScreen> {
  late bool _hasSubscribed = Provider.of<DataProvider>(context).hasSubscribed;

  bool _isLoading = false;

  void _onSubscribeTapped(BuildContext context) async {
    setState(() => _isLoading = true);

    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    String topic = "prod_dineazy_${dataProvider.profile.revenueCenterId}";

    final cmd = await RedisConnection().connect(
      RedisConfig.host,
      RedisConfig.port,
    );

    final responseAuth = await cmd.send_object(['AUTH', RedisConfig.password]);
    debugPrint("PubSubScreen._redisPackage: $responseAuth");

    final pubSub = PubSub(cmd);

    pubSub.subscribe([topic]);

    final stream = pubSub.getStream();
    await for (final msg in stream) {
      MessageData messageData = MessageData(msg);

      if (messageData.type == "subscribe" && messageData.data == 1) {
        debugPrint("_PubSubScreenState._onSubscribeTapped: ✅ Subscribed successfully");
        dataProvider.hasSubscribed = true;
        setState(() {
          _isLoading = false;
          _hasSubscribed = true;
        });
        continue;
      }

      if (messageData.type == "message") {
        log(messageData.data);
        PrintMessageData printMessageData = PrintMessageData(msg);
        dataProvider.saveMessage(printMessageData);
        continue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: const Text("Print Subscription"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.shortestSide * 0.7,
          ),
          child: Builder(builder: (context) {
            if (_isLoading) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12.0),
                  Text("Subscribing..."),
                ],
              );
            }

            if (_hasSubscribed) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: Colors.green,
                    size: 84,
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    "Subscribed successfully",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  PrimaryButton(
                    text: "Back to Home",
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Subscribe to Print Notifications",
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                PrimaryButton(
                  onTap: () => _onSubscribeTapped(context),
                  text: "Subscribe",
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

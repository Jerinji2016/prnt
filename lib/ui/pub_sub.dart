import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redis/redis.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../helpers/globals.dart';
import '../providers/data_provider.dart';

class PubSubScreen extends StatelessWidget {
  const PubSubScreen({Key? key}) : super(key: key);

  void _onSubscribeTapped(BuildContext context) async {
    DataProvider dataProvider = Provider.of<DataProvider>(context, listen: false);
    String topic = "prod_dineazy_${dataProvider.profile.rvcId}";

    _redisPackage(topic);
    _socketPackage(topic);
  }

  void _socketPackage(String topic) async {
    final socket = io(
      'http://${RedisConfig.host}:${RedisConfig.port}',
      <String, dynamic>{
        'transports': ['websocket'],
        'topic': [topic]
      },
    );

    socket.on('new_message', (data) {
      debugPrint("PubSubScreen._socketPackage: $data");
    });

    final conn = socket.connect();
    debugPrint("PubSubScreen._socketPackage: connection status: ${conn.connected}");
  }

  void _redisPackage(String topic) async {
    final cmd = await RedisConnection().connect(
      RedisConfig.host,
      RedisConfig.port,
    );
    final pubSub = PubSub(cmd);

    pubSub.psubscribe([topic]);

    pubSub.subscribe([topic]);
    debugPrint("PubSubScreen._redisPackage: subscribing to $topic...");

    final stream = pubSub.getStream();
    // var streamWithoutErrors = stream.handleError(
    //   (e, st) => debugPrint("PubSubScreen._onSubscribeTapped: ❌ERROR: $e, $st"),
    // );
    await for (final msg in stream) {
      debugPrint("PubSubScreen._redisPackage: message: $msg");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: const Text("Print Subscriptions"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Subscribe to Print Notifications",
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            MaterialButton(
              onPressed: () => _onSubscribeTapped(context),
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: const Text("Subscribe"),
            ),
          ],
        ),
      ),
    );
  }
}

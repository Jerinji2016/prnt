class MessageData<T> {
  final String type;

  final String channel;

  final T data;

  final DateTime timestamp;

  MessageData(List<dynamic> messageList)
      : type = messageList.first,
        channel = messageList[1],
        data = messageList.last,
        timestamp = DateTime.now();
}

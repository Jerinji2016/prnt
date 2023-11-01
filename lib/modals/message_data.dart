class MessageData<T> {
  final List<dynamic> messageList;

  final DateTime timestamp;

  MessageData(
    this.messageList, [
    DateTime? timestamp,
  ]) : timestamp = timestamp ?? DateTime.now();

  String get type => messageList.first;

  String get channel => messageList[1];

  T get data => messageList.last;
}

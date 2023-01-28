/// Represents a single message (aka. "danmaku") in a bililive room.
class Message {
  final String text;
  final int uid;
  final String nickname;
  final DateTime timestamp;
  final Medal? medal;
  final int kanchouLv;

  Message({
    required this.text,
    required this.uid,
    required this.nickname,
    required this.timestamp,
    required this.medal,
    required this.kanchouLv,
  });

  /// Parse message data returned from RESTful APIs.
  static Message fromRestfulJson(dynamic obj) {
    return Message(
      text: obj['text'],
      uid: obj['uid'],
      nickname: obj['nickname'],
      // accurate to 1 second
      timestamp: DateTime.parse(obj['timeline'] as String),
      medal: Medal.fromJsonArray(obj['medal'] as List),
      kanchouLv: obj['guard_level'],
    );
  }

  /// Parse message data returned from WebSocket.
  static Message fromWebSocketJson(dynamic obj) {
    return Message(
      text: obj[1],
      uid: obj[2][0],
      nickname: obj[2][1],
      // accurate to 1 ms (before 2038)
      timestamp: DateTime.fromMillisecondsSinceEpoch(obj[0][4] as int),
      medal: Medal.fromJsonArray(obj[3] as List),
      kanchouLv: obj[7],
    );
  }
}

/// Represents a "fan medal" in bililive.
class Medal {
  final String title;
  final String owner;
  final int level;
  final int color;

  Medal({
    required this.title,
    required this.owner,
    required this.level,
    required this.color,
  });

  static Medal? fromJsonArray(List<dynamic> array) {
    if (array.isEmpty) return null;
    return Medal(
      title: array[1],
      owner: array[2],
      level: array[0],
      color: array[9],
    );
  }
}

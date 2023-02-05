/// Represents a single message (aka. "danmaku") in a bililive room.
class Message {
  final String text;
  final int uid;
  final String nickname;
  final DateTime timestamp;
  final Sticker? sticker;
  final Medal? medal;
  final int kanchouLv;

  Message({
    required this.text,
    required this.uid,
    required this.nickname,
    required this.timestamp,
    required this.sticker,
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
      sticker: Sticker.fromJson(obj['emoticon']),
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
      sticker: Sticker.fromJson(obj[0][13]),
      medal: Medal.fromJsonArray(obj[3] as List),
      kanchouLv: obj[7],
    );
  }

  /// (Experimental) Generate a unique identifier for this message. Useful for
  /// deduplication.
  ///
  /// Warning: these IDs are prone to change between releases! Don't store them
  /// in persistent storages.
  String getUniqueId() => '$uid:${timestamp.millisecondsSinceEpoch ~/ 1000}';
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

/// Represents a sticker (i.e. large emoticon) message.
class Sticker {
  final String id;
  // final String? altText;
  final String imageUrl;
  final int width, height;

  Sticker({
    required this.id,
    // required this.altText,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  static Sticker? fromJson(dynamic obj) {
    // Note: for non-sticker messages, when using RESTful API,
    // obj['emoticon_unique'] will be '';
    // when using WebSocket, the whole obj will be a string '{}'.
    if (obj == '{}' || (obj['emoticon_unique'] as String).isEmpty) return null;

    return Sticker(
      id: obj['emoticon_unique'],
      // This field is missing in WebSocket messages
      // altText: obj['text'],
      imageUrl: obj['url'],
      width: obj['width'],
      height: obj['height'],
    );
  }
}

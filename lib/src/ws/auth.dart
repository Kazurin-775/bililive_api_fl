import 'consts.dart';

/// Bililive WebSocket authentication packet, sent upon successful connection.
class AuthMessage {
  int uid;
  int roomId;
  String key;

  AuthMessage({required this.uid, required this.roomId, required this.key});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'roomid': roomId,
        'protover': BODY_PROTOCOL_VERSION_BROTLI,
        'platform': 'web',
        'type': 2,
        'key': key,
      };
}

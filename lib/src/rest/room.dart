import 'dart:math';

import 'package:dio/dio.dart';
import 'package:tuple/tuple.dart';

import '../danmaku.dart';
import '../message.dart';
import 'cred.dart';
import 'rest.dart';

const String apiServer = 'api.live.bilibili.com';

class WsServerConfig {
  List<WsHost> hosts;
  String token;

  WsServerConfig(this.hosts, this.token);
}

class WsHost {
  String host;
  int wssPort;

  WsHost(this.host, this.wssPort);
}

/// Fetch WebSocket server configuration (including host, port and token)
/// of a specified room ID.
Future<WsServerConfig> getWsServerConfig(Dio dio, int roomId) async {
  var resp = await dio.getUri(Uri.https(
    apiServer,
    '/xlive/web-room/v1/index/getDanmuInfo',
    {'id': roomId.toString()},
  ));

  ensureApiCallSuccess(resp.data);

  return WsServerConfig(
    (resp.data['data']['host_list'] as List)
        .map((item) => WsHost(item['host'], item['wss_port']))
        .toList(growable: false),
    resp.data['data']['token'],
  );
}

/// Fetch the latest 10 messages (from room administrators / normal viewers)
/// in a live room.
Future<Tuple2<List<Message>, List<Message>>> getLast10Messages(
    Dio dio, int roomId) async {
  var resp = await dio.getUri(Uri.https(
    apiServer,
    '/xlive/web-room/v1/dM/gethistory',
    {'roomid': roomId.toString()},
  ));

  ensureApiCallSuccess(resp.data);

  return Tuple2(
    (resp.data['data']['admin'] as List)
        .map((item) => Message.fromRestfulJson(item))
        .toList(),
    (resp.data['data']['room'] as List)
        .map((item) => Message.fromRestfulJson(item))
        .toList(),
  );
}

// Random number generator, used by `sendXxxMessage()` functions.
final Random _random = Random();

/// Send a text message to a live room.
Future<void> sendTextMessage(
  Dio dio,
  int roomId,
  String content,
  BiliCredential cred, {
  DanmakuOptions options = const DanmakuOptions(),
}) async {
  var formData = FormData.fromMap({
    'roomid': roomId,
    'msg': content,
    'bubble': 0,
    'mode': options.position.asInt(),
    'color': options.color,
    'fontsize': options.fontSize.asInt(),
    'rnd': _random.nextInt(1e9.floor() - 1),
    'csrf': cred.biliJct,
    'csrf_token': cred.biliJct,
  });

  await _sendRawMessage(dio, formData, cred);
}

/// Send a sticker message to a live room.
///
/// Note: you may need to have sufficient privilege to send some stickers in
/// some rooms, or the operation may result in a `BiliApiException` with status
/// code `10203`.
Future<void> sendStickerMessage(
  Dio dio,
  int roomId,
  String stickerId,
  BiliCredential cred, {
  DanmakuOptions options = const DanmakuOptions(),
}) async {
  var formData = FormData.fromMap({
    'roomid': roomId,
    'dm_type': 1, // Stickers
    'msg': stickerId,
    'bubble': 0,
    'mode': options.position.asInt(),
    'color': options.color,
    'fontsize': options.fontSize.asInt(),
    'rnd': _random.nextInt(1e9.floor() - 1),
    'csrf': cred.biliJct,
    'csrf_token': cred.biliJct,
  });

  await _sendRawMessage(dio, formData, cred);
}

Future<void> _sendRawMessage(
    Dio dio, FormData formData, BiliCredential cred) async {
  var resp = await dio.postUri(
    Uri.https(apiServer, '/msg/send'),
    data: formData,
    options: Options(headers: {
      'cookie': cred.toCookies(),
    }),
  );

  // print(resp.data);
  ensureApiCallSuccess(resp.data);
}

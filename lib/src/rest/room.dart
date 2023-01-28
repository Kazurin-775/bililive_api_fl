import 'package:dio/dio.dart';
import 'package:tuple/tuple.dart';

import '../message.dart';

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

  if (resp.data['code'] != 0) {
    throw Exception('API endpoint returned status code ${resp.data.code}');
  }

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

  if (resp.data['code'] != 0) {
    throw Exception('API endpoint returned status code ${resp.data.code}');
  }

  return Tuple2(
    (resp.data['data']['admin'] as List)
        .map((item) => Message.fromRestfulJson(item))
        .toList(),
    (resp.data['data']['room'] as List)
        .map((item) => Message.fromRestfulJson(item))
        .toList(),
  );
}

import 'package:dio/dio.dart';

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

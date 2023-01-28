import 'package:bililive_api_fl/bililive_api_fl.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

void main(List<String> args) async {
  Logger.level = Level.verbose;

  var roomId = int.parse(args[0]);

  var dio = Dio();
  installClientConfig(dio);
  var server = await getWsServerConfig(dio, roomId);
  print('Got server name: ${server.hosts[0].host}');

  var sock = BililiveSocket(
    host: server.hosts[0].host,
    port: server.hosts[0].wssPort,
    roomId: roomId,
    token: server.token,
  );
  await for (var packet in sock.run()) {
    var cmd = packet['cmd'] as String;
    //print(cmd);
    if (cmd.startsWith('DANMU_MSG')) {
      //print(msg);
      var msg = Message.fromWebSocketJson(packet['info']);
      print('${msg.nickname} says: ${msg.text}');
    }
  }
  print('WebSocket disconnected, returning from main()');
}

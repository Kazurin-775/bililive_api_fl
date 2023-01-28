import 'package:bililive_api_fl/bililive_api_fl.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

void main(List<String> args) async {
  Logger.level = Level.verbose;

  var roomId = int.parse(args[0]);

  var dio = Dio();
  installClientConfig(dio);
  var msgs = await getLast10Messages(dio, roomId);

  print('Admin messages:');
  for (var msg in msgs.item1) {
    print('${msg.nickname} says: ${msg.text}');
  }
  print('Normal messages:');
  for (var msg in msgs.item2) {
    print('${msg.nickname} says: ${msg.text}');
  }
}

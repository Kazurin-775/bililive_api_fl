import 'package:dio/dio.dart';

import 'rest.dart';

const String apiServer = 'api.bilibili.com';

class UserInfo {
  final String nickname;
  final String avatarUrl;
  final String bio;

  UserInfo({
    required this.nickname,
    required this.avatarUrl,
    required this.bio,
  });

  static UserInfo fromJson(dynamic obj) {
    return UserInfo(
      nickname: obj['name'],
      avatarUrl: obj['face'],
      bio: obj['sign'],
    );
  }
}

Future<UserInfo> getUserInfo(Dio dio, int uid, {Options? options}) async {
  var uri = Uri.https(
    apiServer,
    '/x/space/wbi/acc/info',
    {'mid': uid.toString()},
  );

  var resp = await dio.getUri(uri, options: options);

  ensureApiCallSuccess(resp.data);

  return UserInfo.fromJson(resp.data['data']);
}

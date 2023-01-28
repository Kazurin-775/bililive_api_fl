import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

Future<UserInfo?> getCachedUserInfo(int uid, CacheManager cache) async {
  var uri = Uri.https(
    apiServer,
    '/x/space/wbi/acc/info',
    {'mid': uid.toString()},
  );
  var cached = await cache.getFileFromCache(uri.toString());
  if (cached != null) {
    var data = await cached.file.readAsString();
    return UserInfo.fromJson(jsonDecode(data)['data']);
  } else {
    return null;
  }
}

Future<UserInfo> getUserInfo(Dio dio, int uid,
    {CacheManager? cache, Duration? maxAge}) async {
  var uri = Uri.https(
    apiServer,
    '/x/space/wbi/acc/info',
    {'mid': uid.toString()},
  );

  // Query cache again (in case it is filled by previous requests)
  var cached = await cache?.getFileFromCache(uri.toString());
  if (cached != null) {
    var data = await cached.file.readAsString();
    return UserInfo.fromJson(jsonDecode(data)['data']);
  }

  var resp = await dio.getUri(uri);

  if (resp.data['code'] != 0) {
    throw Exception('API endpoint returned status code ${resp.data.code}');
  }

  // FIXME: any better implementation?
  await cache?.putFile(
    uri.toString(),
    Uint8List.fromList(utf8.encode(jsonEncode(resp.data))),
    maxAge: maxAge ?? Duration(days: 7),
  );

  return UserInfo.fromJson(resp.data['data']);
}

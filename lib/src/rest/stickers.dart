import 'package:dio/dio.dart';

import 'cred.dart';
import 'rest.dart';

const apiServer = 'api.live.bilibili.com';

class StickerItem {
  final String name;
  final String url;
  final int width;
  final int height;
  final String unlockCond;
  final String id;

  StickerItem({
    required this.name,
    required this.url,
    required this.width,
    required this.height,
    required this.unlockCond,
    required this.id,
  });

  static StickerItem fromJson(dynamic obj) {
    return StickerItem(
      name: obj['emoji'],
      url: obj['url'],
      width: obj['width'],
      height: obj['height'],
      unlockCond: obj['unlock_show_text'],
      id: obj['emoticon_unique'],
    );
  }
}

class StickerPack {
  final List<StickerItem> items;
  final int id;
  final String name;
  final String desc;
  final int type;
  final String coverUrl;

  StickerPack({
    required this.items,
    required this.id,
    required this.name,
    required this.desc,
    required this.type,
    required this.coverUrl,
  });

  static StickerPack fromJson(dynamic obj) {
    var rawItems = obj['emoticons'] as List;
    return StickerPack(
      items: rawItems
          .map((obj) => StickerItem.fromJson(obj))
          .toList(growable: false),
      id: obj['pkg_id'],
      name: obj['pkg_name'],
      desc: obj['pkg_descript'],
      type: obj['pkg_type'],
      coverUrl: obj['current_cover'],
    );
  }
}

/// Fetch sticker (emoticon) packs provided by a live room.
Future<List<StickerPack>> getStickerPacksInRoom(
  Dio dio,
  int roomId,
  BiliCredential cred, {
  Options? options,
}) async {
  var resp = await dio.getUri(
    Uri.https(
      apiServer,
      '/xlive/web-ucenter/v2/emoticon/GetEmoticons',
      {
        'platform': 'pc',
        'room_id': roomId.toString(),
      },
    ),
    options: (options ?? Options()).copyWith(headers: {
      'cookie': cred.toCookies(),
    }),
  );

  ensureApiCallSuccess(resp.data);

  var rawPacks = resp.data['data']['data'] as List;
  return rawPacks
      .map((obj) => StickerPack.fromJson(obj))
      .toList(growable: false);
}

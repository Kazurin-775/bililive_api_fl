import 'package:dio/dio.dart';

import 'cred.dart';
import 'rest.dart';

const String apiServer = 'api.live.bilibili.com';

class CheckInResult {
  final String earned;
  final String tips;
  final bool bonusDay;
  final int consecutiveCheckIns;

  CheckInResult({
    required this.earned,
    required this.tips,
    required this.bonusDay,
    required this.consecutiveCheckIns,
  });

  static CheckInResult fromJson(dynamic obj) {
    return CheckInResult(
      earned: obj['text'],
      tips: obj['specialText'],
      bonusDay: (obj['isBonusDay'] as int) != 0,
      consecutiveCheckIns: obj['hadSignDays'],
    );
  }
}

/// Perform daily check in on bililive and earn (free) gift bags.
///
/// If already checked in for today, you get a `BiliApiException` with status
/// code `1011040`.
Future<CheckInResult> dailyCheckIn(Dio dio, BiliCredential cred) async {
  // Yes, this API is GET rather than POST...
  var resp = await dio.getUri(
    Uri.https(apiServer, '/xlive/web-ucenter/v1/sign/DoSign'),
    options: Options(headers: {
      'cookie': cred.toCookies(),
    }),
  );

  ensureApiCallSuccess(resp.data);

  return CheckInResult.fromJson(resp.data['data']);
}

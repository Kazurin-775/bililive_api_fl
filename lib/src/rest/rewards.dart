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

class BatteryRewardProgress {
  final BatteryRewardStatus status;
  final int progress;
  final int target;
  final bool outOfStock;

  BatteryRewardProgress({
    required this.status,
    required this.progress,
    required this.target,
    required this.outOfStock,
  });

  static BatteryRewardProgress fromJson(dynamic obj) {
    return BatteryRewardProgress(
      status: BatteryRewardStatusExt.fromInt(obj['status']),
      progress: obj['progress'],
      target: obj['target'],
      outOfStock: (obj['is_surplus'] as int) == 0,
    );
  }
}

enum BatteryRewardStatus {
  notStarted,
  inProgress,
  rewardAvailable,
  awarded,
  unknown,
}

extension BatteryRewardStatusExt on BatteryRewardStatus {
  static BatteryRewardStatus fromInt(int x) {
    switch (x) {
      case 0:
        return BatteryRewardStatus.notStarted;
      case 1:
        return BatteryRewardStatus.inProgress;
      case 2:
        return BatteryRewardStatus.rewardAvailable;
      case 3:
        return BatteryRewardStatus.awarded;
      default:
        return BatteryRewardStatus.unknown;
    }
  }
}

Future<BatteryRewardProgress> getBatteryRewardProgress(
    Dio dio, BiliCredential cred) async {
  var resp = await dio.getUri(
    Uri.https(apiServer, '/xlive/app-ucenter/v1/userTask/GetUserTaskProgress'),
    options: Options(headers: {
      'cookie': cred.toCookies(),
    }),
  );

  ensureApiCallSuccess(resp.data);

  return BatteryRewardProgress.fromJson(resp.data['data']);
}

/// If successful, returns the number of batteries earned (normally 1).
///
/// If award already received, this results in a `BiliApiException` with status
/// code `27000002`.
Future<int> receiveBatteryReward(Dio dio, BiliCredential cred) async {
  var resp = await dio.postUri(
    Uri.https(
      apiServer,
      '/xlive/app-ucenter/v1/userTask/UserTaskReceiveRewards',
    ),
    data: {
      'csrf': cred.biliJct,
      'csrf_token': cred.biliJct,
    },
    options: Options(
      contentType: Headers.formUrlEncodedContentType,
      headers: {'cookie': cred.toCookies()},
    ),
  );

  ensureApiCallSuccess(resp.data);

  return resp.data['data']['num'];
}

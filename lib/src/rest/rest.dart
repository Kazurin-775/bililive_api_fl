import 'package:dio/dio.dart';

const userAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61';
const spoofOrigin = 'https://www.bilibili.com';
const spoofReferer = 'https://www.bilibili.com/';

/// Install HTTP client configurations that are necessary in circumventing
/// bilibili's API restrictions.
void installClientConfig(Dio dio) {
  dio.options.headers.addAll({
    'user-agent': userAgent,
    'origin': spoofOrigin,
    'referer': spoofReferer,
  });
}

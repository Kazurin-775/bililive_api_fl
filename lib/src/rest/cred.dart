class BiliCredential {
  final String sessdata;
  final String biliJct;
  final String buvid3;
  final int uid;

  /// Warning: this method is insecure! Only run this on trusted inputs.
  BiliCredential({
    required this.sessdata,
    required this.biliJct,
    required this.buvid3,
    required this.uid,
  });

  // TODO: Add sanity checks?
  String toCookies() => 'SESSDATA=$sessdata; bili_jct=$biliJct; '
      'buvid3=$buvid3; DedeUserID=$uid';
}

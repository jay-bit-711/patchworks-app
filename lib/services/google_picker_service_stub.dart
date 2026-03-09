import 'dart:async';

class GooglePickerService {
  static Future<void> openPicker({
    required String oauthToken,
    required String developerKey,
    required String appId,
    void Function(List<Map<String, dynamic>> docs)? onPick,
  }) async {
    throw UnsupportedError('Google Picker is only available on web builds in this project.');
  }
}

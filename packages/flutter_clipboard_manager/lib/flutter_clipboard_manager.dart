import 'package:flutter/services.dart';

class FlutterClipboardManager {
  static Future<void> copyToClipBoard(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }
}

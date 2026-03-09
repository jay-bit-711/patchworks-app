import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class GooglePickerService {
  static Future<void> openPicker({
    required String oauthToken,
    required String developerKey,
    required String appId,
    void Function(List<Map<String, dynamic>> docs)? onPick,
  }) async {
    if (!kIsWeb) throw UnsupportedError('Google Picker requires web platform.');

    await _ensurePickerScript();

    StreamSubscription? sub;
    sub = html.window.onMessage.listen((event) {
      try {
        final data = event.data;
        if (data is Map && data['type'] == 'pickerSelected') {
          final docs = <Map<String, dynamic>>[];
          final rawDocs = data['docs'];
          if (rawDocs is List) {
            for (final d in rawDocs) {
              if (d is Map) docs.add(Map<String, dynamic>.from(d));
            }
          }
          if (onPick != null) onPick(docs);
          sub?.cancel();
        } else if (data is Map && data['type'] == 'pickerCancelled') {
          sub?.cancel();
        }
      } catch (_) {}
    });

    final fn = html.window['loadPickerAndOpen'];
    if (fn is Function) {
      fn(oauthToken, developerKey, appId);
    } else {
      html.window.console?.log('Picker helper not found on window');
    }
  }

  static Future<void> _ensurePickerScript() async {
    if (html.window['loadPickerAndOpen'] != null) return;

    final completer = Completer<void>();

    final script = html.ScriptElement()
      ..src = 'https://apis.google.com/js/api.js'
      ..type = 'text/javascript'
      ..async = true;

    script.onLoad.listen((_) {
      final helper = html.ScriptElement();
      helper.type = 'text/javascript';
      helper.text = r"""
function loadPickerAndOpen(oauthToken, developerKey, appId) {
  try {
    gapi.load('auth', {});
    gapi.load('picker', {'callback': function() {
      var view = new google.picker.DocsView(google.picker.ViewId.DOCS);
      var picker = new google.picker.PickerBuilder()
        .addView(view)
        .setOAuthToken(oauthToken)
        .setDeveloperKey(developerKey)
        .setAppId(appId)
        .setCallback(function(data) {
          if (data.action == google.picker.Action.PICKED) {
            var docs = data.docs.map(function(d){
              return {id:d.id, name:d.name, mimeType:d.mimeType, url:d.url};
            });
            window.postMessage({type:'pickerSelected', docs:docs}, window.location.origin);
          } else {
            window.postMessage({type:'pickerCancelled'}, window.location.origin);
          }
        })
        .build();
      picker.setVisible(true);
    }});
  } catch (e) {
    window.postMessage({type:'pickerCancelled', error: String(e)}, window.location.origin);
  }
}
""";
      html.document.body?.append(helper);
      completer.complete();
    });

    script.onError.listen((_) {
      completer.completeError('Failed to load gapi script');
    });

    html.document.head?.append(script);

    return completer.future;
  }
}

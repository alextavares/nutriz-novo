import 'dart:io';

import 'package:flutter/services.dart';

class PlatformShare {
  static const MethodChannel _channel = MethodChannel('com.nutriz.app/share');

  static Future<bool> shareText(String text) async {
    if (!Platform.isAndroid) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('shareText', {'text': text});
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> shareWhatsApp(String text) async {
    if (!Platform.isAndroid) return false;
    try {
      final ok =
          await _channel.invokeMethod<bool>('shareWhatsApp', {'text': text});
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}


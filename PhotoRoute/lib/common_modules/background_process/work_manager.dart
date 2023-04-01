import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

const platform = MethodChannel('com.kingoapps.photo_route/background');

Future<void> executeBackgroundTask(String param) async {
  String batteryLevel;
  try {
    //var raw = callback?.toRawHandle();
    final tripId = 225883;
    var raw = tripId;
    //final result = await platform.invokeMethod('executeBackgroundTask_native', {"param":param});
    final result = await platform
        .invokeMethod('executeBackgroundTask_native', <dynamic>[raw]);
    batteryLevel = 'Battery level at $result % .';
  } on PlatformException catch (e) {
    batteryLevel = "Failed to get battery level: '${e.message}'.";
  }

  print(batteryLevel);
}

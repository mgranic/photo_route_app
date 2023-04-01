
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:photo_route/screens/main_menu_screen.dart';

// chrome://inspect/#devices
const platform = MethodChannel('com.kingoapps.photo_route/background2');

void testCallFromPlatform() async {
  HttpOverrides.global = MyHttpOverrides();
  print("battery radiiiiiiiiiiiiii xxxxxxxxxxxx");
  /*sleep(Duration(seconds:10));
  print("task nakon sleepa 1");
  sleep(Duration(seconds:20));
  print("task nakon sleepa 2");*/
  //final String url = 'https://localhost:7081/WeatherForecast/testPostRequest?param=mob_poslao'; // on device
  //final String url = 'https://localhost:7081/WeatherForecast/testPostRequestBody';
  final String url = 'https://localhost:7081/DatabaseManager/UploadImage';
  //final String url = 'http://10.0.2.2:7081/WeatherForecast/testPostRequest'; // on emulator
  //final String url = 'https://10.0.2.2:4040/';
  //final String url = 'https://localhost:8081/';
  sleep(Duration(seconds:30));
  post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json'
    },
    body: jsonEncode(<String, String>{
      'name': 'slika sa mobitela 2',
    }),
  ).then((response) {
    print(response?.body);
  }).catchError((err) {
    print('Server communication error: ${err.toString()}');
  })
      .timeout(Duration(seconds: 2), onTimeout: () {
    print(' HTTP request timeout');
  });

  sleep(Duration(seconds:20));
  //post(Uri.parse('${url}isAlive'), body: {"param1": 'parm1'});
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MotoRoute());

}


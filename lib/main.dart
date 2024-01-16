// ignore_for_file: unnecessary_const, prefer_const_constructors

import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io' as IO;
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

enum Enviroment { Dev, QA, Demo, Prod }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
            appBar: AppBar(
              title: Text('Fluter Demo'),
            ),
            body: FlutterPage()));
  }
}

class FlutterPage extends StatefulWidget {
  @override
  FlutterComponent createState() => new FlutterComponent();
}

class FlutterComponent extends State<FlutterPage> {
  static const String _channel =  "test_activity";
  static const platform = const MethodChannel(_channel);
  String _dataFromFlutter = "";

  Enviroment selectedEnvironment = Enviroment.Prod;
  String _APIKey = "[SOLICITAR A DICIO]";
  String _url = "[SOLICITAR A DICIO]";

  _getNewActivity() async {
    String data;
    try {
      final String result = await platform.invokeMethod('startNewActivity', {
        'selectedEnvironment': selectedEnvironment.toString(),
        'APIKey': _APIKey,
        'url': _url,
      });
      data = result;
    } on PlatformException catch (e) {
      data = "Android is not responding please check the code";
    }

    print(data);
    setState(() {
      _dataFromFlutter = data;
    });
    if (IO.Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
          action: 'android.intent.action.RUN',
          package: 'com.example.flutter_app_dicio',
          componentName: 'com.example.flutter_app_dicio.MainActivity');
      await intent.launch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        elevation: 5.0,
        height: 48.0,
        minWidth: 250.0,
        color: Colors.blue,
        textColor: Colors.white,
        onPressed: () {
          _getNewActivity();
        },
        child: const Text('Open Pivot'));
  }
}

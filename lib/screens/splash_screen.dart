// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  checkVersion() async {
    int version = await checkAndroidVersion();
    if (version >= 32) {
     await checkPermission13();
    } else {
     await checkPermission12();
    }
  }

  Future<int> checkAndroidVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    int androidVersion = androidInfo.version.sdkInt;
    print('Android Version: $androidVersion');
    return androidVersion;
  }

  checkPermission13() async {
    final per = await [Permission.audio].request();
    final voicePermission = await Permission.microphone.request();

    if (per.values.every((status) =>
        status == PermissionStatus.granted &&
        voicePermission == PermissionStatus.granted)) {
      await Future.delayed(const Duration(seconds: 3));
      Navigator.of(context).pushReplacementNamed("bottomNavigation");
    } else {
      debugPrint("error in permission");
    }
  }

  checkPermission12() async {
    var storage = await Permission.storage.request();
    var microphone = await Permission.microphone.request();
    if(microphone ==PermissionStatus.granted && storage == PermissionStatus.granted){
      await Future.delayed(const Duration(seconds: 3));
      Navigator.of(context).pushReplacementNamed("bottomNavigation");
    } else {
      debugPrint("error in permission");
    }
    }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Image.asset("assets/images/splash.jpg",
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: const Alignment(0.45, 0)),
    );
  }
}


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';


Future<bool> checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
     
      return false;
    }
  }
   netWorkErrorSnackbar(context) {
   ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: const EdgeInsets.symmetric(vertical: 10),
        content: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'network unavailable ',
                style: TextStyle(
                    fontFamily:"FiraSans", fontSize: mediaqueryHeight(0.02, context)),
              ),
            
              const Icon(Icons.wifi_off_outlined,color: Colors.white,)
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        duration: const Duration(seconds: 1),
      ),
    );
  }
import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/screens/chef.dart';
import 'package:pos/src/screens/join.dart';
import 'package:pos/src/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pos/src/screens/reception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.debug);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const POS());
}

/* Future _connectToFirebaseEmulator() async {
  final localHostString = Platform.isAndroid ? '10.0.2.2' : 'localhost';

  await FirebaseAuth.instance.useAuthEmulator(localHostString, 9099);
} */

class POS extends StatelessWidget {
  const POS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'POS',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: Colors.transparent)),
        home: const JoinApp());
  }
}

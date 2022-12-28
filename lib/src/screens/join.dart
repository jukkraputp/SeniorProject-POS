import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pos/src/screens/chef.dart';
import 'package:pos/src/screens/login.dart';
import 'package:pos/src/screens/reception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JoinApp extends StatefulWidget {
  const JoinApp({super.key});

  @override
  State<JoinApp> createState() => _JoinAppState();
}

class _JoinAppState extends State<JoinApp> {
  bool isAuth = false;
  bool isChef = false;
  String shopKey = '';
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    initSet().whenComplete(() {
      setState(() {
        _ready = true;
      });
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        setState(() {
          isAuth = false;
        });
      } else {
        print('User is sign in!');
        setState(() {
          isAuth = true;
        });
      }
    });
  }

  Future<void> initSet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth');
    bool isChef = false;
    String shopKey = '';
    if (token != null) {
      String? mode = await api.getMode(token);
      String? getShopKey = await api.getShopKey(token);
      if (getShopKey != null) {
        shopKey = getShopKey;
      }
      if ((mode == 'chef') | (mode == 'Chef')) {
        isChef = true;
      }
    }
    setState(() {
      this.isChef = isChef;
      this.shopKey = shopKey;
    });
  }

  void restart() async {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: isAuth & _ready
            ? MaterialApp(
                home: isChef
                    ? Chef(
                        shopKey: shopKey,
                      )
                    : Reception(
                        shopKey: shopKey,
                        restart: restart,
                      ),
                debugShowCheckedModeBanner: false,
                showPerformanceOverlay: true,
              )
            : const Login(),
        onWillPop: () async => false);
  }
}

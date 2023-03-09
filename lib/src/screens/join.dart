import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lottie/lottie.dart';
import 'package:pos/src/interfaces/shop_info.dart';
import 'package:pos/src/screens/chef.dart';
import 'package:pos/src/screens/login.dart';
import 'package:pos/src/screens/reception.dart';
import 'package:pos/src/widgets/showDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JoinApp extends StatefulWidget {
  const JoinApp({super.key});

  @override
  State<JoinApp> createState() => _JoinAppState();
}

class _JoinAppState extends State<JoinApp> {
  bool isAuth = false;
  late ShopInfo shopInfo;
  String mode = '';
  bool _showingLoader = false;

  @override
  void initState() {
    super.initState();
    initSet();

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
          if (_showingLoader) {
            setState(() {
              _showingLoader = false;
              Navigator.of(context).pop();
            });
          }
        });
      }
    });
  }

  Future<void> initSet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jwt = prefs.getString('auth');
    print('jwt: $jwt');
    if (jwt != null) {
      setData(jwt: jwt);
    }
  }

  Future<bool> setData({required String jwt}) async {
    print('setData - jwt: $jwt');
    List? data = await api.getShopByJWT(jwt);
    print('setData: $data');
    if (data != null) {
      setState(() {
        shopInfo = data.first;
        mode = data.last;
      });
      return true;
    } else {
      return false;
    }
  }

  void login({required String token}) {
    setState(() {
      _showingLoader = true;
    });
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Lottie.asset('assets/animations/colors-circle-loader.json'),
          );
        });
    api.getJWT(token: token).then((jwt) {
      try {
        if ((jwt != null) && (!JwtDecoder.isExpired(jwt))) {
          setData(jwt: jwt).then((res) {
            if (res) {
              FirebaseAuth.instance.signInWithCustomToken(jwt);
              saveJWT(jwt: jwt);
            } else {
              showDialog(
                  context: context,
                  builder: ((context) {
                    return AlertDialog(
                      title: const Text('This token is not available.'),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (_showingLoader == true) {
                                Navigator.of(context).pop();
                                setState(() {
                                  _showingLoader = false;
                                });
                              }
                            },
                            child: const Text('Close'))
                      ],
                    );
                  }));
            }
          });
        } else if ((jwt != null) && (JwtDecoder.isExpired(jwt))) {
          // Navigator.of(context).pop();
          showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  title: const Text('This token is not available.'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (_showingLoader == true) {
                            Navigator.of(context).pop();
                            setState(() {
                              _showingLoader = false;
                            });
                          }
                        },
                        child: const Text('Close'))
                  ],
                );
              }));
        }
      } on FirebaseAuthException {
        // ShowDialog()
        //     .error(context, widgets: [const Text('FirebaseAuthException')]);
      } catch (e) {
        // ShowDialog().error(context, widgets: [const Text('error')]);
      }
    });
  }

  Future<bool> saveJWT({required String jwt}) async {
    var prefs = await SharedPreferences.getInstance();
    print('save jwt: $jwt');
    return await prefs.setString('auth', jwt);
  }

  @override
  Widget build(BuildContext context) {
    print('isAuth: $isAuth');
    // FirebaseAuth.instance.signOut();
    if ((mode != 'Chef') && (mode != 'Reception')) {
      SharedPreferences.getInstance().then((prefs) {
        String? jwt = prefs.getString('auth');
        if (jwt != null) {
          setData(jwt: jwt);
        }
      });
    }
    return WillPopScope(
        child: isAuth
            ? MaterialApp(
                home: mode == 'Chef'
                    ? Chef(
                        shopInfo: shopInfo,
                      )
                    : mode == 'Reception'
                        ? Reception(
                            shopInfo: shopInfo,
                          )
                        : const Text(
                            'Error has occurred. Please contact support.'),
                // debugShowCheckedModeBanner: false,
                // showPerformanceOverlay: true,
              )
            : Login(
                login: login,
              ),
        onWillPop: () async => false);
  }
}

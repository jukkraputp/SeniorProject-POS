import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/screens/chef.dart';
import 'package:pos/src/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pos/src/screens/recipient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String _auth = '';
  bool _setup = false;
  bool _render = false;
  dynamic _shopKey = '';

  void setPrefs(String val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth', val);
  }

  dynamic setAuth(String val) async {
    final String? mode = val != '' ? await API().getMode(val) : '';
    // ignore: avoid_print
    print(val);
    // ignore: avoid_print
    print(mode);
    final String? shopKey = val != '' ? await API().getShopKey(val) : '';
    print(shopKey);
    if (mode != null && shopKey != null) {
      setPrefs(val);
      setState(() {
        _auth = mode;
        _shopKey = shopKey;
      });
    } else {
      return const AlertDialog(
        content: Text('Token is not available.'),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final String? token = prefs.getString('auth');
      String auth = '';
      if (token != null) {
        API().getMode(token).then((value) => auth = value ?? '');
      }
      // ignore: avoid_print
      print(auth);
      setAuth(auth);
    });

    setFirebase();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void setFirebase() {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) => {
          setState(() {
            _setup = true;
          })
        });
  }

  void setRender() {}

  @override
  Widget build(BuildContext context) {
    print(_auth);
    return _setup
        ? Visibility(
            visible: !_render,
            child: MaterialApp(
                title: 'Senior Project',
                theme: ThemeData(
                    primarySwatch: Colors.blue,
                    bottomSheetTheme: const BottomSheetThemeData(
                        backgroundColor: Colors.transparent)),
                home: _auth == ''
                    ? Login(
                        setAuth: setAuth,
                      )
                    : _auth == 'Recipient'
                        ? Recipient(
                            setRender: setRender,
                            setAuth: setAuth,
                            shopKey: _shopKey,
                          )
                        : Chef(
                            shopKey: _shopKey,
                            setAuth: setAuth,
                          )),
          )
        : Center(
            child: Lottie.asset('assets/animations/colors-circle-loader.json'),
          );
  }
}

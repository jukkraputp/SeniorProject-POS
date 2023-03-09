import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pos/src/screens/login.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends StatelessWidget {
  final Future<bool> Function() syncData;

  const AppSettings({super.key, required this.syncData});

  @override
  Widget build(BuildContext context) {
    double buttonSizeDivisor = 5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /* Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width / buttonSizeDivisor,
          height: MediaQuery.of(context).size.height / buttonSizeDivisor,
          child: TextButton(
              onPressed: () {
                syncData();
              },
              child: const Text(
                'Sync Data',
                style: TextStyle(fontSize: 36),
              )),
        ), */
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width / buttonSizeDivisor,
          height: MediaQuery.of(context).size.height / buttonSizeDivisor,
          child: TextButton(
              onPressed: () async {
                var prefs = await SharedPreferences.getInstance();
                prefs.clear();
                await FirebaseAuth.instance.signOut();
              },
              child: const Text(
                'Exit',
                style: TextStyle(fontSize: 36),
              )),
        ),
      ],
    );
  }
}

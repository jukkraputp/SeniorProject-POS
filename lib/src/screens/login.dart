import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/screens/chef.dart';
import 'package:pos/src/screens/reception.dart';
import 'package:pos/src/widgets/showDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final inputController = TextEditingController();
  final API api = API();

  bool isChef = false;
  String shopKey = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/login.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 60.0,
                    ),
                    child: const Text(
                      'LOGIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40.0,
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.5,
                    left: 35,
                    right: 35,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: inputController,
                        decoration: InputDecoration(
                          labelText: 'Token',
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                maximumSize: const Size(170.0, 90.0),
                                backgroundColor: Colors.black,
                                minimumSize: const Size(170.0, 60.0),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () async {
                                final String token = inputController.text;
                                String debugToken =
                                    'eyJhbGciOiAiUlMyNTYiLCAidHlwIjogIkpXVCIsICJraWQiOiAiMTQ3ZjQ0YzQ1ZDkyMWM5Mzk3ZDExNGQwYWYxMDBjZmNkMzE2ZWU2MSJ9.eyJpc3MiOiAiZmlyZWJhc2UtYWRtaW5zZGstMm12bzJAc2VuaW9ycHJvamVjdC0zZGY5MC5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsICJzdWIiOiAiZmlyZWJhc2UtYWRtaW5zZGstMm12bzJAc2VuaW9ycHJvamVjdC0zZGY5MC5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsICJhdWQiOiAiaHR0cHM6Ly9pZGVudGl0eXRvb2xraXQuZ29vZ2xlYXBpcy5jb20vZ29vZ2xlLmlkZW50aXR5LmlkZW50aXR5dG9vbGtpdC52MS5JZGVudGl0eVRvb2xraXQiLCAidWlkIjogIjdlYWFjNjM3LThmMzgtNDA4ZS1iMWRmLWZlYTAwMjhmNjJiMyIsICJpYXQiOiAxNjcyMjQ2ODA4LCAiZXhwIjogMTY3MjI1MDQwOH0.oFauIp4TctYGPcGqG901D4u8VS3oEoyoiUEP_m1OCRZs1BdDkcKKUZkbLMFPJROnlPreM7PL6P3XNw_0tTZ_vWANAEv6a1Qv1zJmrL5vv0YYVHebjDsp1cRtvfJnVkaYKmXaBR2fe--4YesSLWUBEnnEg_oXADTCwDZDMW-3T_jMECe-YBifFExO8-187n0tonDxg1B6OgOMhROtAx0IrYVXquJx2iDzR7EWUMSeqbPrKV1971bjrJ7oeexkSMH-TwvhqiPCt_kqtuXkhjg_ykQWMRaq2PVa4oS7RCf1aYxS79QIjahDzgj8-vAW6oG0eO9OsC90nm4G02ZAFkKeDQ';
                                print(debugToken);
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithCustomToken(debugToken);
                                } on FirebaseAuthException {
                                  print('error');
                                  ShowDialog().error(context);
                                } catch (e) {}
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                //crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text('ENTER'),
                                  Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                  ),
                                ],
                              )),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}

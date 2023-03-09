import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/screens/chef.dart';
import 'package:pos/src/screens/reception.dart';
import 'package:pos/src/widgets/showDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.login});

  final void Function({required String token}) login;

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
                                final String otp = inputController.text;
                                widget.login(token: otp);
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/widgets/Contents/Order/order_content.dart';

class Chef extends StatefulWidget {
  const Chef({Key? key, required this.shopKey}) : super(key: key);

  final String shopKey;

  @override
  State<Chef> createState() => _ChefState();
}

class _ChefState extends State<Chef> {
  MenuList menuList = MenuList();
  bool _ready = false;
  double _width = 900;

  final API api = API();

  @override
  void initState() {
    super.initState();
    print('Chef:' + widget.shopKey);
    api.getMenuList(widget.shopKey).then((value) {
      setState(() {
        menuList = value;
        _ready = true;
        _width = context.size!.width;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Chef:' + _ready.toString());
    return _ready
        ? Scaffold(
            appBar: AppBar(title: const Text('Queue')),
            body: OrderContent(
                menuList: menuList, shopKey: widget.shopKey, mode: 'Chef'),
            bottomSheet: Container(
              color: Colors.transparent,
              margin: EdgeInsets.only(left: _width * 0.89),
              height: 100,
              width: 100,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  maximumSize: const Size(100, 100),
                  backgroundColor: Colors.black,
                  minimumSize: const Size(50, 50),
                  shape: const StadiumBorder(),
                ),
                onPressed: () async {
                  FirebaseAuth.instance
                      .signOut()
                      .whenComplete(() => Navigator.of(context).pop());
                },
                child: const Center(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  child: Text('EXIT'),
                ),
              ),
            ),
          )
        : Center(
            child: Lottie.asset('assets/animations/colors-circle-loader.json'),
          );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/widgets/Basket/basket_content.dart';
import 'package:pos/src/widgets/Contents/item_card.dart';
import 'package:pos/src/widgets/basket.dart';
import 'package:pos/src/widgets/content_stage.dart';
import 'package:pos/src/widgets/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

API api = API();

class Recipient extends StatefulWidget {
  const Recipient(
      {Key? key,
      required this.setRender,
      required this.setAuth,
      required this.shopKey})
      : super(key: key);

  final void Function() setRender;
  final void Function(String val) setAuth;
  final String shopKey;

  @override
  State<Recipient> createState() => _RecipientState();
}

class _RecipientState extends State<Recipient> {
  String _content = 'Food1';
  Map<String, int> _basket = {};
  bool confirmingOrder = false;
  bool renderFinished = false;
  MenuList menuList = MenuList();
  List<String> menuTypeList = [];
  List<String> navbarList = [];
  bool showBasket = true;
  int _rendered = 0;
  bool _ready = false;

  final API api = API();

  @override
  void initState() {
    super.initState();
    api.getMenuList(widget.shopKey).then((value) {
      menuTypeList = value.menu.keys.toList();
      navbarList = menuTypeList + ['Order', 'History', 'Exit'];
      setState(() {
        menuTypeList = menuTypeList;
        navbarList = navbarList;
        showBasket = menuTypeList.contains(_content);
        menuList = value;
        _ready = true;
      });
    });
  }

  void setContent(String content) {
    if (content == 'Exit') {
      widget.setAuth('');
    }
    print('setContent: ' + content);
    setState(() {
      _content = content;
      showBasket = menuTypeList.contains(_content);
    });
  }

  void updateBasket(Item item, {String? mode = '+'}) {
    mode == null ? mode = '+' : mode = mode;
    int value = _basket[item.id] ?? 0;
    if (mode == '+') {
      setState(() {
        _basket[item.id] = value + 1;
      });
    } else {
      int count = value - 1;
      if (count <= 0) {
        setState(() {
          _basket.remove(item.id);
        });
      } else {
        setState(() {
          _basket[item.id] = count;
        });
      }
    }
  }

  void clearBasket() {
    setState(() {
      _basket = {};
    });
  }

  void confirmOrder() {
    if (_basket.isNotEmpty) {
      setState(() {
        confirmingOrder = true;
      });
    }
  }

  void incRendered() {
    setState(() {
      _rendered = _rendered + 1;
    });
  }

  List<Widget> buildCurrentOrder(BuildContext context) {
    List<Widget> widgetList = [];
    _basket.forEach((key, value) {
      String type = key.split('-')[0];
      int idx = int.parse(key.split('-')[1]);
      Item item = menuList.menu[type]![idx];
      widgetList.add(ItemCard(item: item));
    });

    return widgetList;
  }

  dynamic showModal(BuildContext context) {
    double contextWidth = context.size!.width;
    double contextHeight = context.size!.height;
    return _basket.isNotEmpty
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: ListView(children: [
                  Container(
                    alignment: Alignment.topRight,
                    child: CloseButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Container(
                    width: 100,
                    constraints: BoxConstraints(maxHeight: contextHeight * 0.8),
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Order',
                                    style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Expanded(
                                  flex: 11,
                                  child: Container(
                                    width: contextWidth * 1.5,
                                    margin: const EdgeInsets.all(15),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: BasketContent(
                                        menuList: menuList,
                                        inBasket: _basket,
                                        updateBasket: updateBasket,
                                        isPopup: true),
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: TextButton(
                                      onPressed: () {
                                        api.addOrder(
                                            widget.shopKey, _basket, menuList);
                                        setState(() {
                                          _basket = {};
                                        });
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.black),
                                      child: const Text(
                                        'Confirm',
                                        style: TextStyle(color: Colors.white),
                                      )))
                            ],
                          ),
                        )),
                  )
                ]),
              );
            })
        : Null;
  }

  @override
  Widget build(BuildContext context) {
    int ratio = 7;
    return widget.shopKey != '' && _ready
        ? Row(
            children: [
              Expanded(
                  flex: 1 * ratio,
                  child: Navbar(
                    navbarList: navbarList,
                    setContent: setContent,
                    currentContent: _content,
                  )),
              Expanded(
                  flex: showBasket ? 4 * ratio : 6 * ratio + 1,
                  child: ContentStage(
                      shopKey: widget.shopKey,
                      content: _content,
                      menuList: menuList,
                      menuTypeList: menuTypeList,
                      renderComplete: () {},
                      setAuth: () {},
                      setEdit: () {},
                      setMenuList: () {},
                      toggleOrder: () {},
                      updateBasket: updateBasket,
                      incRendered: incRendered)),
              if (showBasket)
                Expanded(
                    flex: 2 * ratio + 1,
                    child: Basket(
                        menuList: menuList,
                        basket: _basket,
                        updateBasket: updateBasket,
                        clearBasket: clearBasket,
                        confirmOrder: confirmOrder,
                        showModal: showModal))
            ],
          )
        : Center(
            child: Lottie.asset('assets/animations/colors-circle-loader.json'),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

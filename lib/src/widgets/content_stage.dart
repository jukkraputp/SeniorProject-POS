import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/interfaces/shop_info.dart';
import 'package:pos/src/screens/reception.dart';
import 'package:pos/src/widgets/Contents/Settings/settings.dart';
import 'package:pos/src/widgets/Contents/History/history_content.dart';
import 'package:pos/src/widgets/Contents/Menu/menu_content.dart';
import 'package:pos/src/widgets/Contents/Order/order_content.dart';

class ContentStage extends StatefulWidget {
  const ContentStage(
      {Key? key,
      required this.shopInfo,
      required this.content,
      required this.menuList,
      required this.menuTypeList,
      required this.updateBasket,
      required this.toggleOrder,
      required this.renderComplete,
      required this.setAuth,
      required this.setMenuList,
      required this.setEdit,
      required this.syncData})
      : super(key: key);

  final ShopInfo shopInfo;
  final String content;
  final MenuList menuList;
  final List<String> menuTypeList;
  final void Function(Item, {String? mode}) updateBasket;
  final void Function() toggleOrder;
  final void Function() renderComplete;
  final void Function() setAuth;
  final void Function() setMenuList;
  final void Function() setEdit;
  final Future<bool> Function() syncData;

  @override
  // ignore: no_logic_in_create_state
  State<ContentStage> createState() => _ContentStageState();
}

class _ContentStageState extends State<ContentStage> {
  String _current = '';
  int activePage = 0;
  final PageController _pageController = PageController();
  final PageStorageBucket _bucket = PageStorageBucket();
  bool _needRebuild = false;
  Map<String, bool> widgetReady = {};
  late PageView contentBody;
  late List<String> navbarList = [];
  bool _buildComplete = false;

  @override
  void initState() {
    super.initState();
    widget.menuList.menu.forEach(
        (key, value) => {widget.menuList.menu[key]?.forEach((item) {})});
    for (var type in widget.menuTypeList) {
      widgetReady[type] = false;
    }
    final List<String> navbarList =
        widget.menuTypeList + ['Order', 'History', 'Settings'];
    setState(() {
      _current = widget.content;
      this.navbarList = navbarList;
      contentBody = buildPageView(navbarList);
    });
  }

  Future<bool> syncData() async {
    print('sync data');
    setState(() {
      _needRebuild = true;
    });
    bool res = await widget.syncData();
    if (res) {
      setState(() {
        _buildComplete = false;
        contentBody = buildPageView(navbarList);
        _needRebuild = false;
      });
    }
    return res;
  }

  PageView buildPageView(List<String> navbarList) {
    return PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.menuTypeList.length + 3,
        controller: _pageController,
        onPageChanged: (page) {
          _pageController.jumpToPage(page);
        },
        itemBuilder: (context, pagePosition) {
          if (pagePosition < widget.menuTypeList.length) {
            String foodType = widget.menuTypeList[pagePosition];
            return PageStorage(
              key: PageStorageKey(foodType),
              bucket: _bucket,
              child: MenuContent(
                key: Key(foodType),
                menuList: widget.menuList,
                content: foodType,
                current: _current,
                updateBasket: widget.updateBasket,
              ),
            );
          } else {
            switch (navbarList[pagePosition]) {
              case 'Order':
                return OrderContent(
                  menuList: widget.menuList,
                  shopInfo: widget.shopInfo,
                  mode: 'Recipient',
                );
              case 'History':
                return HistoryContent(
                  menuList: widget.menuList,
                  shopInfo: widget.shopInfo,
                );
              case 'Settings':
                return AppSettings(
                  syncData: syncData,
                );
              default:
                return const Text('No Content');
            }
          }
        });
  }

  /// Used to trigger an event when the widget has been built
  Future<bool> initializeController() {
    Completer<bool> completer = new Completer<bool>();

    /// Callback called after widget has been fully built
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      completer.complete(true);
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (_current != widget.content) {
      setState(() {
        _current = widget.content;
        _pageController.jumpToPage(navbarList.indexOf(widget.content));
      });
    }
    initializeController().then((value) {
      if (!_buildComplete) {
        setState(() {
          _buildComplete = true;
          _pageController.jumpToPage(navbarList.indexOf(widget.content));
        });
      }
    });
    return _needRebuild
        ? Center(
            child: Lottie.asset('assets/animations/colors-circle-loader.json'),
          )
        : Container(
            decoration: const BoxDecoration(
                color: Colors.white, border: Border(right: BorderSide())),
            child: contentBody);
  }
}

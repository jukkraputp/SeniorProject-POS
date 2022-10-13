import 'package:flutter/material.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/screens/recipient.dart';
import 'package:pos/src/widgets/Contents/History/history_content.dart';
import 'package:pos/src/widgets/Contents/Menu/menu_content.dart';
import 'package:pos/src/widgets/Contents/Order/order_content.dart';

class ContentStage extends StatefulWidget {
  const ContentStage({
    Key? key,
    required this.shopKey,
    required this.content,
    required this.menuList,
    required this.menuTypeList,
    required this.updateBasket,
    required this.toggleOrder,
    required this.renderComplete,
    required this.setAuth,
    required this.setMenuList,
    required this.setEdit,
    required this.incRendered,
  }) : super(key: key);

  final String shopKey;
  final String content;
  final MenuList menuList;
  final List<String> menuTypeList;
  final void Function(Item, {String? mode}) updateBasket;
  final void Function() toggleOrder;
  final void Function() renderComplete;
  final void Function() setAuth;
  final void Function() setMenuList;
  final void Function() setEdit;
  final void Function() incRendered;

  @override
  // ignore: no_logic_in_create_state
  State<ContentStage> createState() => _ContentStageState();
}

class _ContentStageState extends State<ContentStage> {
  String _current = '';
  int activePage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    widget.menuList.menu.forEach(
        (key, value) => {widget.menuList.menu[key]?.forEach((item) {})});
    setState(() {
      _current = widget.content;
    });
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
            return MenuContent(
              key: Key(foodType),
              menuList: widget.menuList,
              content: foodType,
              current: _current,
              updateBasket: widget.updateBasket,
            );
          } else {
            switch (navbarList[pagePosition]) {
              case 'Order':
                return OrderContent(
                  menuList: widget.menuList,
                  shopKey: widget.shopKey,
                  mode: 'Recipient',
                );
              case 'History':
                return HistoryContent(
                  menuList: widget.menuList,
                  shopKey: widget.shopKey,
                );
              case 'Exit':
                return const Text('Exit');
              default:
                return const Text('No Content');
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> navbarList =
        widget.menuTypeList + ['Order', 'History', 'Exit'];
    if (_current != widget.content) {
      setState(() {
        _current = widget.content;
        _pageController.jumpToPage(navbarList.indexOf(widget.content));
      });
    }
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white, border: Border(right: BorderSide())),
      child: buildPageView(navbarList),
    );
  }
}

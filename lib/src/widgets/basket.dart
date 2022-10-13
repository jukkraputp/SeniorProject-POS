import 'package:flutter/material.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/widgets/Basket/basket_content.dart';

class Basket extends StatefulWidget {
  const Basket(
      {Key? key,
      required this.menuList,
      required this.basket,
      required this.updateBasket,
      required this.clearBasket,
      required this.confirmOrder,
      required this.showModal})
      : super(key: key);

  final MenuList menuList;
  final Map<String, int> basket;
  final void Function(Item, {String? mode}) updateBasket;
  final void Function() clearBasket;
  final void Function() confirmOrder;
  final dynamic Function(BuildContext) showModal;

  @override
  // ignore: no_logic_in_create_state
  State<Basket> createState() => _BasketState();
}

class _BasketState extends State<Basket> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text(
              'Order',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () => widget.clearBasket(),
                icon: const Icon(Icons.close))
          ]),
          backgroundColor: Colors.black,
        ),
        body: BasketContent(
          menuList: widget.menuList,
          inBasket: widget.basket,
          updateBasket: widget.updateBasket,
          isPopup: false,
        ),
        bottomNavigationBar: Visibility(
            visible: widget.basket.isNotEmpty,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(color: Colors.black),
              child: TextButton(
                  onPressed: () => widget.showModal(context),
                  child: const Text(
                    'Order',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )),
            )));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

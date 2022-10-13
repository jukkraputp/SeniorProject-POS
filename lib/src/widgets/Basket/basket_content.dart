import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';

class BasketContent extends StatelessWidget {
  const BasketContent({
    Key? key,
    required this.menuList,
    required this.inBasket,
    required this.updateBasket,
    required this.isPopup,
  }) : super(key: key);

  final MenuList menuList;
  final Map<String, int> inBasket;
  final void Function(Item, {String? mode}) updateBasket;
  final bool isPopup;

  List<Widget> genItems(BuildContext context) {
    var widgets = <Widget>[];
    double paddingVal = 20;
    inBasket.forEach((key, value) {
      String foodType = key.split('-')[0];
      int factor = 11;
      double width = MediaQuery.of(context).size.width / factor;
      double height = MediaQuery.of(context).size.width / factor;
      List<Item> arr = menuList.menu[foodType] ?? [];
      int index = arr.indexWhere((item) => item.id == key);
      Item item = arr[index];
      double price = double.tryParse(item.price) ?? 0;
      widgets.add(
        Container(
            padding: const EdgeInsets.only(left: 2.5, top: 5),
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: width,
                  height: height + 44,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        width: width,
                        height: height,
                        imageUrl: item.image,
                        fit: BoxFit.cover,
                      ),
                      Text(item.name,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        !isPopup
                            ? IconButton(
                                iconSize: height / 3,
                                padding: const EdgeInsets.only(bottom: 50),
                                onPressed: () => updateBasket(item, mode: '+'),
                                icon: const Icon(Icons.add_circle))
                            : Padding(
                                padding: EdgeInsets.only(
                                    left: paddingVal,
                                    right: paddingVal,
                                    top: 5),
                                child: const SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: Icon(Icons.close)),
                              ),
                        Text(
                          '$value',
                          style: TextStyle(fontSize: !isPopup ? 16 : 32),
                        ),
                        !isPopup
                            ? IconButton(
                                iconSize: height / 3,
                                padding: const EdgeInsets.only(bottom: 50),
                                onPressed: () => updateBasket(item, mode: '-'),
                                icon: const Icon(Icons.remove_circle))
                            : Padding(
                                padding: EdgeInsets.only(
                                    left: paddingVal, right: paddingVal),
                              ),
                        Text(
                          '${price * value} บาท',
                          style: TextStyle(fontSize: !isPopup ? 16 : 32),
                        )
                      ]),
                ),
              ],
            ))),
      );
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> basket = genItems(context);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: ScrollController(),
      child: Column(
        children: basket,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/interfaces/order.dart';
import 'package:pos/src/interfaces/shop_info.dart';
import 'package:pos/src/widgets/Contents/list_table_row.dart';

class HistoryContent extends StatefulWidget {
  const HistoryContent(
      {Key? key, required this.menuList, required this.shopInfo})
      : super(key: key);

  final MenuList menuList;
  final ShopInfo shopInfo;

  @override
  State<HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  _HistoryContentState();

  List<Order> _histories = [];
  final API api = API();

  @override
  void initState() {
    super.initState();

    api
        .getAllHistory(uid: widget.shopInfo.uid, shopName: widget.shopInfo.name)
        .then((histories) {
      print('History');
      for (var order in histories) {
        print(order.itemList);
      }
      setState(() {
        _histories = histories;
      });
    });
  }

  List<Widget> buildWidgets() {
    List<Widget> myWidgets = <Widget>[];
    for (var order in _histories) {
      MenuList orderList = MenuList(typesList: ['order']);
      Map<String, int> amountMap = {};

      for (ItemCounter itemCounter in order.itemList) {
        Item item = itemCounter.item;
        int count = itemCounter.count;
        amountMap[item.id] = count;
        orderList.menu['order']!.add(item);
      }
      int rowNum = ((orderList.menu['order']?.length ?? 5) / 5).ceil();
      double boxHeight = (200 * rowNum + 100).toDouble();
      myWidgets.add(SizedBox(
          height: boxHeight,
          child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.brown.shade400,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 50,
                      children: [
                        Text('Order ID: ${order.orderId}'),
                        Text('ราคารวม ${order.cost} บาท')
                      ],
                    ),
                  ],
                )),
            body: Container(
              decoration: BoxDecoration(color: Colors.blueGrey.shade50),
              child: Table(
                children:
                    genListTableRow(orderList, 'order', 5, null, amountMap),
              ),
            ),
            bottomSheet: Container(
              decoration: const BoxDecoration(color: Colors.black),
              height: 5,
            ),
          )));
    }
    return myWidgets;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> contents = buildWidgets();
    return ListView(
      children: contents,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

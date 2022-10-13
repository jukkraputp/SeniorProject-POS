import 'package:flutter/material.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/interfaces/history.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/widgets/Contents/list_table_row.dart';

class HistoryContent extends StatefulWidget {
  const HistoryContent(
      {Key? key, required this.menuList, required this.shopKey})
      : super(key: key);

  final MenuList menuList;
  final String shopKey;

  @override
  State<HistoryContent> createState() =>
      // ignore: no_logic_in_create_state
      _HistoryContentState(menuList, shopKey);
}

class _HistoryContentState extends State<HistoryContent> {
  _HistoryContentState(MenuList menuList, String shopKey);

  List<History> _histories = [];
  final API api = API();

  @override
  void initState() {
    super.initState();

    api.getHistoryList(widget.shopKey).then((histories) {
      print(histories);
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
      order.foods?.forEach((key, value) {
        String type = key.split('-')[0];
        int index = widget.menuList.menu[type]
                ?.indexWhere((element) => element.id == key) ??
            -1;
        var item = widget.menuList.menu[type]![index];
        orderList.menu['order']?.add(item);
        amountMap[key] = value;
      });
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
                        Text('ราคารวม ${order.totalAmount} บาท')
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

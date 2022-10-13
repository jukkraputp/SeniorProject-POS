import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/interfaces/order.dart';
import 'package:pos/src/widgets/Contents/list_table_row.dart';

class OrderContent extends StatefulWidget {
  const OrderContent(
      {Key? key,
      required this.menuList,
      required this.shopKey,
      required this.mode})
      : super(key: key);

  final MenuList menuList;
  final String shopKey;
  final String mode;

  @override
  State<OrderContent> createState() => _OrderContentState();
}

class _OrderContentState extends State<OrderContent>
    with AutomaticKeepAliveClientMixin {
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;
  List<Order> _orders = [];
  late final StreamSubscription<DatabaseEvent> orderListener;
  final API api = API();

  void completeOrder(String orderId) {
    print('calling api');
    api.completeOrder(widget.shopKey, orderId).then((res) => print(res));
  }

  @override
  void initState() {
    super.initState();

    DatabaseReference ordersRef = _realtimeDB.ref('Order/${widget.shopKey}');
    orderListener = ordersRef.onValue.listen((event) {
      List<Order> orders = [];
      try {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          final datas =
              jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
          datas.forEach((key, obj) {
            var order = Order(
              isFinished: obj['isFinished'],
              orderId: obj['orderId'],
              totalAmount: obj['totalAmount'],
              date: obj['date'],
              foods: obj['foods'],
            );
            orders.add(order);
          });
        }
      } catch (e) {
        print('OrderContent::Error::$e');
      }
      orders.sort(
        (a, b) => a.date!.compareTo(b.date!),
      );
      setState(() {
        _orders = orders;
      });
    });
  }

  List<Widget> buildWidgets() {
    List<Widget> myWidgets = <Widget>[];
    for (var order in _orders) {
      if (widget.mode == 'Chef' && order.isFinished == true) {
      } else {
        print(order);
        MenuList orderList = MenuList(typesList: ['order']);
        Map<String, int> amountMap = {};
        order.foods?.forEach((key, value) {
          String type = key.split('-')[0];
          int index = widget.menuList.menu[type]
                  ?.indexWhere((element) => element.id == key) ??
              -1;
          Item item = widget.menuList.menu[type]![index];
          orderList.menu['order']?.add(item);
          amountMap[key] = value;
        });
        int rowNum = ((orderList.menu['order']?.length ?? 5) / 5).ceil();
        double boxHeight = (200 * rowNum + 100).toDouble();
        double statusLightRadius = 20;
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
                      if (widget.mode == 'Recipient')
                        Wrap(
                          spacing: 10,
                          children: [
                            order.isFinished!
                                ? const Text('Ready')
                                : const Text('Waiting'),
                            Container(
                              width: statusLightRadius,
                              height: statusLightRadius,
                              decoration: BoxDecoration(
                                color: order.isFinished!
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius:
                                    BorderRadius.circular(statusLightRadius),
                              ),
                            ),
                          ],
                        )
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
              bottomNavigationBar: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: order.isFinished!
                        ? Colors.green.shade500
                        : widget.mode != 'Chef'
                            ? Colors.grey
                            : Colors.green.shade500),
                child: TextButton(
                    onPressed: order.isFinished!
                        ? () => completeOrder(order.orderId!)
                        : widget.mode != 'Chef'
                            ? null
                            : () async {
                                await API().finishOrder(
                                    widget.shopKey, order.orderId ?? '');
                              },
                    child: Text(
                      widget.mode != 'Chef'
                          ? order.isFinished!
                              ? 'F I N I S H E D'
                              : 'W A I T I N G'
                          : 'F I N I S H E D',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              order.isFinished! ? Colors.black : Colors.white),
                    )),
              )),
        ));
      }
    }
    print(myWidgets);
    return myWidgets;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Widget> contents = buildWidgets();
    return ListView(
      children: contents,
    );
  }

  @override
  void dispose() {
    orderListener.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

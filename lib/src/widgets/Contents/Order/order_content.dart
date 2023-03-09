import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pos/src/apis/api.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/interfaces/order.dart' as food_order;
import 'package:pos/src/interfaces/shop_info.dart';
import 'package:pos/src/widgets/Contents/list_table_row.dart';

class OrderContent extends StatefulWidget {
  const OrderContent(
      {Key? key,
      required this.menuList,
      required this.shopInfo,
      required this.mode})
      : super(key: key);

  final MenuList menuList;
  final ShopInfo shopInfo;
  final String mode;

  @override
  State<OrderContent> createState() => _OrderContentState();
}

class _OrderContentState extends State<OrderContent>
    with AutomaticKeepAliveClientMixin {
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;
  List<food_order.Order> _orders = [];
  late final StreamSubscription<DatabaseEvent> orderListener;
  final API api = API();

  Future<Response?> completeOrder(food_order.Order order) async {
    return await api.completeOrder(
        shopName: widget.shopInfo.name, uid: widget.shopInfo.uid, order: order);
  }

  @override
  void initState() {
    super.initState();
    String shopKey = '${widget.shopInfo.uid}-${widget.shopInfo.name}';
    DatabaseReference ordersRef = _realtimeDB.ref('Order/$shopKey');
    orderListener = ordersRef.onValue.listen((event) {
      List<food_order.Order> orders = [];
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final datas =
            jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
        datas.forEach((year, obj) {
          Map<String, dynamic> yearData = json.decode(json.encode(obj));
          List<String> months = yearData.keys.toList();
          for (var month in months) {
            Map<String, dynamic> monthData = yearData[month];
            List<String> days = monthData.keys.toList();
            for (var day in days) {
              Map<String, dynamic> dayData = monthData[day];
              List<String> orderNumbers = dayData.keys.toList();
              for (var orderNumber in orderNumbers) {
                Map<String, dynamic> orderData = dayData[orderNumber];
                List<ItemCounter> itemList = [];
                for (Map<String, dynamic> itemData in orderData['itemList']) {
                  String name = itemData['name'];
                  double price = itemData['price'];
                  double time = itemData['time'];
                  String image = itemData['image'];
                  String id = itemData['id'];
                  String? productDetail = itemData['productDetail'];
                  Item item = Item(
                      name: name,
                      price: price,
                      time: time,
                      image: image,
                      id: id,
                      productDetail: productDetail);
                  int count = itemData['count'];
                  String? comment = itemData['comment'];
                  ItemCounter itemCounter =
                      ItemCounter(item, count, comment: comment);
                  itemList.add(itemCounter);
                }
                num cost = orderData['cost'];
                food_order.Order order = food_order.Order(
                    isCompleted: orderData['isCompleted'],
                    isFinished: orderData['isFinished'],
                    isPaid: orderData['isPaid'],
                    orderId: int.parse(orderNumber.split('order').last),
                    cost: cost.toDouble(),
                    date: DateTime.parse(orderData['date']),
                    itemList: itemList,
                    ownerUID: widget.shopInfo.uid,
                    phoneNumber: orderData['shopPhoneNumber'],
                    shopName: widget.shopInfo.name,
                    uid: orderData['uid'],
                    paymentImage: orderData['paymentImage']);
                orders.add(order);
              }
            }
          }
        });
      }

      orders.sort(
        (a, b) => a.date.compareTo(b.date),
      );
      setState(() {
        _orders = orders;
      });
    });
  }

  List<Widget> buildWidgets() {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> myWidgets = <Widget>[];
    for (var order in _orders) {
      if (widget.mode == 'Chef' && order.isFinished == true) {
      } else {
        MenuList orderList = MenuList(typesList: ['order']);
        Map<String, int> amountMap = {};
        for (ItemCounter itemCounter in order.itemList) {
          Item item = itemCounter.item;
          int count = itemCounter.count;
          List<String>? comments = itemCounter.comments;
          String type = item.id.split('-').first;
          int index = widget.menuList.menu[type]
                  ?.indexWhere((element) => element.id == item.id) ??
              -1;
          amountMap[item.id] = count;
          orderList.menu['order']!.add(item);
        }
        int rowNum = ((orderList.menu['order']?.length ?? 5) / 5).ceil();
        double boxHeight = (200 * rowNum + 100).toDouble();
        double statusLightRadius = 20;
        print('${order.orderId}: ${order.isPaid}');
        myWidgets.add(
          Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: SizedBox(
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
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: (order.paymentImage != null
                                          ? 10
                                          : 5)),
                                  child: Text(
                                    'Order ID: ${order.orderId}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top:
                                          (order.paymentImage != null ? 5 : 0)),
                                  child: Text(
                                    'ราคารวม ${order.cost} บาท',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                if (!order.isPaid)
                                  order.paymentImage != null
                                      ? ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: ((context) {
                                                  return Dialog(
                                                    child: CachedNetworkImage(
                                                      height:
                                                          screenSize.height *
                                                              0.85,
                                                      width: screenSize.width *
                                                          0.42,
                                                      fit: BoxFit.contain,
                                                      imageUrl:
                                                          order.paymentImage!,
                                                    ),
                                                  );
                                                }));
                                          },
                                          child: const Text(
                                            'ดูหลักฐานการชำระเงิน',
                                            style: TextStyle(fontSize: 20),
                                          ))
                                      : const Text(
                                          'ไม่พบหลักฐานการชำระเงิน',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                if (!order.isPaid)
                                  ElevatedButton(
                                      onPressed: () {
                                        api
                                            .updatePaymentStatus(
                                                ownerUID: order.ownerUID,
                                                shopName: order.shopName,
                                                orderId: order.orderId!,
                                                date:
                                                    '${order.date.year}/${order.date.month}/${order.date.day}')
                                            .then((res) {
                                          print(res.body);
                                        });
                                      },
                                      child: const Text(
                                        'ยืนยันการชำระเงิน',
                                        style: TextStyle(fontSize: 20),
                                      ))
                              ],
                            ),
                            if (widget.mode == 'Recipient')
                              Wrap(
                                spacing: 10,
                                children: [
                                  order.isFinished
                                      ? const Text('Ready')
                                      : const Text('Waiting'),
                                  Container(
                                    width: statusLightRadius,
                                    height: statusLightRadius,
                                    decoration: BoxDecoration(
                                      color: order.isFinished
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(
                                          statusLightRadius),
                                    ),
                                  ),
                                ],
                              )
                          ],
                        )),
                    body: Container(
                      decoration: BoxDecoration(color: Colors.blueGrey.shade50),
                      child: Table(
                        children: genListTableRow(
                            orderList, 'order', 5, null, amountMap),
                      ),
                    ),
                    bottomSheet: Container(
                      decoration: const BoxDecoration(color: Colors.black),
                      height: 5,
                    ),
                    bottomNavigationBar: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: order.isFinished
                              ? Colors.green.shade500
                              : widget.mode != 'Chef'
                                  ? Colors.grey
                                  : Colors.green.shade500),
                      child: TextButton(
                          onPressed: order.isFinished
                              ? () async {
                                  var res = await completeOrder(order);
                                  if (res != null) {
                                    print('finish order - res: ${res.body}');
                                  }
                                }
                              : widget.mode != 'Chef'
                                  ? null
                                  : () async {
                                      var res = await API().finishOrder(
                                          shopName: widget.shopInfo.name,
                                          uid: widget.shopInfo.uid,
                                          order: order);
                                      if (res != null) {
                                        print(
                                            'finish order - res: ${res.body}');
                                      }
                                    },
                          child: Text(
                            widget.mode != 'Chef'
                                ? order.isFinished
                                    ? 'F I N I S H E D'
                                    : 'W A I T I N G'
                                : 'F I N I S H E D',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: order.isFinished
                                    ? Colors.black
                                    : Colors.white),
                          )),
                    )),
              )),
        );
      }
    }
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

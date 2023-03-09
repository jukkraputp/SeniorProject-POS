import 'dart:convert';
import 'package:pos/src/interfaces/item.dart';

class Order {
  String uid;
  int? orderId;
  String ownerUID;
  String shopName;
  String phoneNumber;
  List<ItemCounter> itemList;
  double cost;
  DateTime date;
  bool isCompleted;
  bool isFinished;
  bool isPaid;
  String? paymentImage;

  Order(
      {required this.uid,
      required this.ownerUID,
      required this.shopName,
      required this.phoneNumber,
      required this.itemList,
      required this.cost,
      required this.date,
      this.isCompleted = false,
      this.isFinished = false,
      this.isPaid = false,
      this.orderId,
      this.paymentImage});

  String toJsonEncoded({Map<String, dynamic>? args}) {
    List<Map<String, dynamic>> itemList = [];
    double totalTime = 0;
    for (var itemCounter in this.itemList) {
      itemList.add({
        'name': itemCounter.item.name,
        'price': itemCounter.item.price,
        'time': itemCounter.item.time,
        'id': itemCounter.item.id,
        'image': itemCounter.item.image,
        'count': itemCounter.count
      });
      totalTime += itemCounter.item.time;
    }
    Map<String, dynamic> obj = {
      'uid': uid,
      'ownerUID': ownerUID,
      'shopName': shopName,
      'shopPhoneNumber': phoneNumber,
      'itemList': itemList,
      'cost': cost,
      'totalTime': totalTime,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'isFinished': isFinished,
      'isPaid': isPaid,
    };
    if (args != null) {
      obj.addAll(args);
    }
    if (orderId != null) {
      obj['orderId'] = orderId;
    }
    if (paymentImage != null) {
      obj['paymentImage'] = paymentImage;
    }
    return json.encode(obj);
  }
}

class PaymentStatus {
  static String waitingForPayment = 'Waiting for payment';
  static String waitingForPaymentConfirmation =
      'Waiting for payment confirmation';
  static String paymentSuccessful = 'Payment successful';
}

class FilteredOrders {
  Map<String, List<Order>> cooking = {};
  Map<String, List<Order>> ready = {};
  Map<String, List<Order>> completed = {};

  int length() {
    int res = 0;
    for (var key in cooking.keys) {
      List list = cooking[key]!;
      res += list.length;
    }
    for (var key in ready.keys) {
      List list = cooking[key]!;
      res += list.length;
    }
    for (var key in completed.keys) {
      List list = cooking[key]!;
      res += list.length;
    }
    return res;
  }
}

class OrderQueue {
  int currentOrder;
  num time;

  OrderQueue({required this.currentOrder, required this.time});
}

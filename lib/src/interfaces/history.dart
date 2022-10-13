// ignore_for_file: prefer_initializing_formals

import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  String? orderId;
  double? totalAmount;
  DateTime? date;
  Map<String, int>? foods;

  History(
      {required String orderId,
      required double totalAmount,
      required Timestamp date,
      required Map<String, dynamic> foods}) {
    this.orderId = orderId;
    this.totalAmount = totalAmount.toDouble();
    this.date = date.toDate();
    Map<String, int> temp = {};
    var keys = foods.keys.toList();
    keys.sort(((a, b) => a.split('-')[1].compareTo(b.split('-')[1])));
    for (var key in keys) {
      temp[key] = foods[key];
    }
    this.foods = temp;
  }
}

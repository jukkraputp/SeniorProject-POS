// ignore_for_file: prefer_initializing_formals

class Order {
  bool? isFinished;
  String? orderId;
  double? totalAmount;
  DateTime? date;
  Map<String, int>? foods;

  Order(
      {required bool isFinished,
      required String orderId,
      required double totalAmount,
      required String date,
      required Map<String, dynamic> foods}) {
    this.isFinished = isFinished;
    this.orderId = orderId;
    this.totalAmount = totalAmount;
    this.date = DateTime.parse(date);
    Map<String, int> temp = {};
    var keys = foods.keys.toList();
    keys.sort(((a, b) => a.split('-')[1].compareTo(b.split('-')[1])));
    for (var key in keys) {
      temp[key] = foods[key];
    }
    this.foods = temp;
  }
}

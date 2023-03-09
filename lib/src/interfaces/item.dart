import 'package:flutter/foundation.dart';

class Item {
  String name;
  double price;
  double time;
  String image;
  String id;
  bool available;
  Uint8List? bytes;
  bool delete;
  double? rating;
  int? rater;
  String? productDetail;

  int? idIn(List<Item> itemList) {
    for (var i = 0; i < itemList.length; i++) {
      Item item = itemList[i];
      if (id == item.id) {
        return i;
      }
    }
    return null;
  }

  Item(
      {required this.name,
      required this.price,
      required this.time,
      required this.image,
      required this.id,
      this.available = true,
      this.bytes,
      this.rating,
      this.rater,
      this.delete = false,
      this.productDetail});
}

class ItemCounter {
  Item item;
  int count;
  List<String> comments = [];

  ItemCounter(this.item, this.count, {String? comment}) {
    if (comment != null) {
      comments.add(comment);
    }
  }
}

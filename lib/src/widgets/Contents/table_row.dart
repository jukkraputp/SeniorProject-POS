import 'package:flutter/material.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/widgets/Contents/item_card.dart';

TableRow genTableRow(
    List<Item> items,
    int perRow,
    void Function(Item, {String? mode})? updateBasket,
    Map<String, int>? amountMap) {
  List<Widget> cardList = <Widget>[];
  for (var item in items) {
    cardList.add(Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Container(
                child: genCard(item, updateBasket),
              )),
          if (amountMap != null)
            Expanded(
                flex: 1,
                child: Text(
                  'x ${amountMap[item.id]}',
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                )),
        ],
      ),
    ));
  }
  for (var i = 0; i < perRow - items.length; i++) {
    cardList.add(Container());
  }
  TableRow tableWidget = TableRow(children: cardList);

  print('tableWidget');
  print(tableWidget);
  return tableWidget;
}

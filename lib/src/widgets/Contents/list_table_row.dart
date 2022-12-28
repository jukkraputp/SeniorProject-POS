import 'package:flutter/cupertino.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/widgets/Contents/table_row.dart';

List<TableRow> genListTableRow(
    MenuList menuList,
    String content,
    int perRow,
    void Function(Item, {String? mode})? updateBasket,
    Map<String, int>? amountMap) {
  List<TableRow> myWidget = <TableRow>[];

  final List<Item> items;
  var menuMap = menuList.menu;
  var menu = menuMap[content];
  menu != null ? items = menu : items = [];
  List<Item> itemList = <Item>[];
  for (var item in items) {
    itemList.add(item);
    if (itemList.length == perRow) {
      myWidget.add(genTableRow(itemList, perRow, updateBasket, amountMap));
      itemList = <Item>[];
    }
  }
  if (itemList.isNotEmpty) {
    myWidget.add(genTableRow(itemList, perRow, updateBasket, amountMap));
  }

  return myWidget;
}

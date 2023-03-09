import 'package:flutter/material.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/widgets/Contents/list_table_row.dart';
import 'package:pos/src/widgets/content_stage.dart';

// ignore: must_be_immutable
class MenuContent extends StatefulWidget {
  const MenuContent({
    Key? key,
    required this.menuList,
    required this.content,
    required this.current,
    required this.updateBasket,
  }) : super(key: key);

  final MenuList menuList;
  final String content;
  final String current;
  final void Function(Item, {String? mode}) updateBasket;

  @override
  State<MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<MenuContent>
    with AutomaticKeepAliveClientMixin {
  _MenuContentState();

  static int perRow = 4;
  List<TableRow> table = <TableRow>[];
  bool wantKeepAlive = true;

  @override
  void initState() {
    super.initState();

    setState(() {
      table = genListTableRow(
          widget.menuList, widget.content, perRow, widget.updateBasket, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: ScrollController(),
      child: Table(
        children: table,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

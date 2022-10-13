import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar(
      {Key? key,
      required this.navbarList,
      required this.setContent,
      required this.currentContent})
      : super(key: key);

  final List<String> navbarList;
  final void Function(String) setContent;
  final String currentContent;

  List<Widget> createButtons() {
    List<Widget> buttonWidgets = <Widget>[];
    for (String navbar in navbarList) {
      buttonWidgets.add(Expanded(
          child: ButtonTheme(
        child: TextButton(
          style: ButtonStyle(
              backgroundColor: navbar == currentContent
                  ? MaterialStateProperty.all<Color>(Colors.blue.shade400)
                  : MaterialStateProperty.all<Color>(Colors.black),
              minimumSize: MaterialStateProperty.all<Size>(Size.infinite)),
          onPressed: () {
            setContent(navbar);
          },
          child: Text(
            navbar,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      )));
    }
    return buttonWidgets;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = createButtons();
    return Column(
      children: buttons,
    );
  }
}

import 'package:flutter/material.dart';

class ShowDialog {
  void error(BuildContext context, {List<Widget>? widgets}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: const Text("Please contact customer support."),
          actions: widgets,
        );
      },
    );
  }
}

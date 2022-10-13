import 'package:firebase_storage/firebase_storage.dart';
import 'package:pos/src/interfaces/item.dart';

class MenuList {
  Map<String, List<Item>> menu = {};

  MenuList({ListResult? types, List<String>? typesList}) {
    if (types != null) {
      for (var type in types.prefixes) {
        menu[type.name] = [];
      }
    } else if (typesList != null) {
      for (var type in typesList) {
        menu[type] = [];
      }
    }
  }
}

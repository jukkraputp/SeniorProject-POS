import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pos/src/interfaces/history.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:http/http.dart' as http;

class API {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Firestore Database

  Future<List<Object?>> getShopList() async {
    QuerySnapshot querySnapshot =
        await _firestoreDB.collection('ShopList').get();
    final shopList = querySnapshot.docs.map((doc) => doc.data()).toList();
    return shopList;
  }

  Future<String?> getShopKey(String token) async {
    try {
      var doc = await _firestoreDB.collection('TokenList').doc(token).get();
      return doc.data()?['key'];
    } on Exception catch (_) {
      return null;
    }
  }

  Future<String?> getMode(String token) async {
    try {
      var doc = await _firestoreDB.collection('TokenList').doc(token).get();
      return doc.data()?['mode'];
    } on Exception catch (_) {
      return null;
    }
  }

  /// Set Name and Price of MenuList object.
  Future<MenuList> setNameAndPrice(
      String key, MenuList menuList, ListResult types) async {
    var ref = _firestoreDB.collection('Menu').doc(key);
    for (var typeRef in types.prefixes) {
      var type = typeRef.name;
      var querySnapshot = await ref.collection(type).get();
      Map<String, Map<String, dynamic>> infoMap = {};
      for (var doc in querySnapshot.docs) {
        infoMap[doc.id] = doc.data();
      }
      menuList.menu[type]?.forEach((element) {
        var id = element.id;
        if (infoMap.containsKey(id)) {
          element.name = infoMap[id]?['name'];
          element.price = '${infoMap[id]?['price']}';
        }
      });
    }
    return menuList;
  }

  Future<History> getHistory(String shopKey, String orderDocId) async {
    DateTime today = DateTime.now();
    String id = '${today.year}${today.month}${today.day}';
    var ref = _firestoreDB
        .collection('History')
        .doc(shopKey)
        .collection(id)
        .doc(orderDocId);
    var doc = await ref.get();
    var data = doc.data();
    var history = History(
        orderId: data?['orderId'],
        totalAmount: data?['totalAmount'],
        date: data?['date'],
        foods: data?['foods']);
    return history;
  }

  Future<List<History>> getHistoryList(String shopKey) async {
    final List<History> historyList = [];
    DateTime today = DateTime.now();
    String id = '${today.year}${today.month}${today.day}';
    var ref = _firestoreDB.collection('History').doc(shopKey).collection(id);
    var datas = await ref.get();
    for (var doc in datas.docs) {
      var data = doc.data();
      var history = History(
          orderId: data['orderId'],
          totalAmount: data['totalAmount'],
          date: data['date'],
          foods: data['foods']);
      historyList.add(history);
    }
    return historyList;
  }

  // Storage

  Future<String> getImage(String key, String type, String name) async {
    var imageURL =
        await _storage.ref().child('$key/$type/$name.jpg').getDownloadURL();
    return imageURL;
  }

  Future<MenuList> getMenuList(String key) async {
    print('get munu list');
    var shopRef = _storage.ref().child(key);
    var types = await shopRef.listAll();
    MenuList result = MenuList(types: types);
    List<String> urls = [];
    for (var typeRef in types.prefixes) {
      result.menu[typeRef.name] = [];
      var images = await typeRef.listAll();
      var imagesRefList = images.items;
      imagesRefList.sort(((a, b) => a.name
          .substring(a.name.length - 6, a.name.length - 4)
          .compareTo(b.name.substring(b.name.length - 6, b.name.length - 4))));
      for (var imageRef in imagesRefList) {
        var url = await imageRef.getDownloadURL();
        urls.add(url);
        result.menu[typeRef.name]?.add(Item(
            '', '', url, imageRef.name.substring(0, imageRef.name.length - 4)));
      }
    }
    print('setting name and price: $key, $result, $types');
    await setNameAndPrice(key, result, types);
    return result;
  }

  // Write data to database through backend server api
  Future<http.Response> addOrder(
      String shopKey, Map<String, int> order, MenuList menuList) async {
    var now = DateTime.now();
    var orderId = '';
    orderId += now.year.toString();
    orderId += now.month.toString();
    orderId += now.day.toString();
    orderId += now.hour.toString();
    orderId += now.minute.toString();
    orderId += now.second.toString();

    return http.post(Uri.parse('http://jukkraputp.sytes.net:7777/add'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "shopKey": shopKey,
          "orderId": orderId,
          "date": now.toIso8601String(),
          "totalAmount": getTotalAmount(order, menuList),
          "foods": order
        }));
  }

  // get total amount of an order
  double getTotalAmount(Map<String, int> order, MenuList menuList) {
    double totalAmount = 0;
    order.forEach((key, value) {
      String type = key.split('-')[0];
      int index =
          menuList.menu[type]?.indexWhere((element) => element.id == key) ?? -1;
      var item = menuList.menu[type]![index];
      double itemVal = 0;
      try {
        itemVal = double.parse(item.price) * value;
      } on Exception catch (_) {
        itemVal = 0;
      }
      totalAmount += itemVal;
    });
    return totalAmount;
  }

  // Change isFinished to True
  Future<http.Response> finishOrder(String shopKey, String orderId) async {
    return http.post(Uri.parse('http://jukkraputp.sytes.net:7777/finish'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{'shopKey': shopKey, 'orderId': orderId}));
  }

  // Move order from realtime database to firestore
  Future<http.Response> completeOrder(String shopKey, String orderId) async {
    return http.post(Uri.parse('http://jukkraputp.sytes.net:7777/complete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{'shopKey': shopKey, 'orderId': orderId}));
  }
}

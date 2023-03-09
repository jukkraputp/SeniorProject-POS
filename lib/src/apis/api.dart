import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pos/src/interfaces/customer/user.dart' as customer;
import 'package:pos/src/interfaces/order.dart' as food_order;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:http/http.dart' as http;
import 'package:pos/src/interfaces/manager/user.dart' as manager_user;
import 'package:pos/src/interfaces/item.dart';
import 'package:pos/src/interfaces/menu_list.dart';
import 'package:pos/src/interfaces/shop_info.dart';

const String backendUrl = 'http://jukkraputp.sytes.net';

class API {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Firestore Database

  Future<String?> getJWT({required String token}) async {
    var doc =
        await FirebaseFirestore.instance.collection('OTP').doc(token).get();
    if (doc.exists) {
      return doc.data()?['token'];
    }
    return null;
  }

  Future<MenuList> getShopMenu(
      {required String uid, required String shopName}) async {
    print('get menu of $shopName');
    List<String> types = await getShopTypes(uid, shopName);
    print('shop types: $types');
    MenuList menuList = MenuList(typesList: types);
    for (var type in types) {
      if (type.isNotEmpty) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestoreDB
            .collection('Menu')
            .doc('$uid-$shopName')
            .collection(type)
            .get();
        for (var doc in querySnapshot.docs) {
          print('Item: ${doc['name']}');
          Item item = Item(
              name: doc['name'],
              price: doc['price'],
              time: doc['time'],
              image: doc['image'],
              id: doc['id'],
              available: doc['available']);
          menuList.menu[type]!.add(item);
        }
      }
    }
    return menuList;
  }

  Future<List<String>> getShopTypes(String uid, String shopName) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _firestoreDB.collection('Menu').doc('$uid-$shopName').get();
    List<String> types = [];
    if (documentSnapshot.exists) {
      var data = documentSnapshot.data();
      List<String> typeList = [];
      for (var type in data?['types'] ?? []) {
        typeList.add(type.toString());
      }
      types = typeList;
    }
    return types;
  }

  Future<String?> getShopName(String key) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await _firestoreDB.collection('ShopList').doc(key).get();
    if (docSnapshot.exists) {
      return docSnapshot['name'];
    }
    return null;
  }

  Future<List<Object?>> getShopList(String? uid) async {
    late QuerySnapshot querySnapshot;
    if (uid != null) {
      querySnapshot = await _firestoreDB
          .collection('ShopList')
          .where('uid', isEqualTo: uid)
          .get();
    } else {
      querySnapshot = await _firestoreDB.collection('ShopList').get();
    }

    var shopList = querySnapshot.docs.map((doc) => doc.data()).toList();
    return shopList;
  }

  Future<String?> getshopName(String token) async {
    try {
      var doc = await _firestoreDB.collection('TokenList').doc(token).get();
      return doc.data()?['key'];
    } on Exception catch (_) {
      return null;
    }
  }

  Future<List?> getShopByJWT(String jwt) async {
    try {
      var doc = await _firestoreDB.collection('TokenList').doc(jwt).get();
      print('getShopByJWT: $doc');
      if (doc.exists) {
        var data = doc.data()!;
        ShopInfo shopInfo = ShopInfo(
            uid: data['uid'],
            name: data['shopName'],
            phoneNumber: data['phoneNumber']);
        String mode = data['mode'];
        return [shopInfo, mode];
      } else {
        return null;
      }
    } on Exception catch (_) {
      return null;
    }
  }

  /// Set Name and Price of MenuList object.
  Future<MenuList> setProductDetails(
      String uid, String shopName, MenuList menuList, ListResult types) async {
    var ref = _firestoreDB.collection('Menu').doc('$uid-$shopName');
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
          element.price = infoMap[id]?['price'];
          element.time = infoMap[id]?['time'];
        }
      });
    }
    return menuList;
  }

  Future<List<food_order.Order>> getAllHistory(
      {required String uid, required String shopName}) async {
    List<food_order.Order> historyList = [];
    List<String> dates = await getHistoryDateList(uid: uid, shopName: shopName);
    for (var date in dates) {
      List<food_order.Order> histories =
          await getHistoryByDate(uid: uid, shopName: shopName, date: date);
      historyList.addAll(histories);
    }

    return historyList;
  }

  Future<List<food_order.Order>> getHistoryByDate(
      {required String uid,
      required String shopName,
      required String date}) async {
    List<food_order.Order> historyList = [];
    var querySnapshot = await _firestoreDB
        .collection('History')
        .doc('$uid-$shopName')
        .collection(date)
        .get();
    for (var doc in querySnapshot.docs) {
      if (doc.exists) {
        var data = doc.data();
        List<ItemCounter> itemList = [];
        for (var item in data['itemList']) {
          Item newItem = Item(
              name: item['name'],
              price: double.parse(item['price'].toString()),
              time: double.parse(item['time'].toString()),
              image: item['image'],
              id: item['id']);
          ItemCounter itemCounter =
              ItemCounter(newItem, item['count'], comment: item['comment']);
          itemList.add(itemCounter);
        }
        Timestamp orderDate = data['date'];
        DateTime datetime = DateTime.fromMillisecondsSinceEpoch(
            orderDate.millisecondsSinceEpoch);
        num cost = data['cost'];
        food_order.Order order = food_order.Order(
          uid: data['uid'],
          ownerUID: data['ownerUID'],
          shopName: shopName,
          phoneNumber: data['shopPhoneNumber'],
          itemList: itemList,
          cost: cost.toDouble(),
          date: datetime,
          orderId: data['orderId'],
          isCompleted: data['isCompleted'],
          isPaid: data['isPaid'],
        );
        historyList.add(order);
      }
    }
    return historyList;
  }

  Future<List<String>> getHistoryDateList(
      {required String uid, required String shopName}) async {
    var doc =
        await _firestoreDB.collection('History').doc('$uid-$shopName').get();
    List<String> dates = [];
    if (doc.exists & (doc.data() != null)) {
      for (var date in doc.data()!['dates']) {
        dates.add(date.toString());
      }
    }
    return dates;
  }

  Future<customer.User?> getCustomerInfo(String uid) async {
    var doc = await _firestoreDB.collection('Customer').doc(uid).get();
    if (doc.exists) {
      var data = doc.data() ?? {};
      if (data.containsKey('username')) {
        return customer.User(
            username: data['username'], displayName: data['displayName']);
      }
    }
    return null;
  }

  // Storage

  Future<http.Response> deleteType(
      String uid, String shopName, String typeName) async {
    try {
      await _storage
          .ref()
          .child('$uid-$shopName/$typeName/not-in-use.txt')
          .putString('this folder is unused');
    } catch (e) {
      print('firebase storage error: $e');
    }
    http.Response res = await http.post(
        Uri.parse('$backendUrl:7777/delete-type'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body:
            json.encode({'uid': uid, 'shopName': shopName, 'type': typeName}));
    return res;
  }

  Future<http.Response> setNewType(
      String uid, String shopName, String typeName) async {
    try {
      await _storage
          .ref()
          .child('$uid-$shopName/$typeName/foo.txt')
          .putString('foo file');
      await _storage
          .ref()
          .child('$uid-$shopName/$typeName/not-in-use.txt')
          .putString('not in use');
      await _storage
          .ref()
          .child('$uid-$shopName/$typeName/not-in-use.txt')
          .delete();
    } catch (e) {
      print('API setNewType: $e');
    }
    http.Response res = await http.post(Uri.parse('$backendUrl:7777/add-type'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body:
            json.encode({'uid': uid, 'shopName': shopName, 'type': typeName}));
    return res;
  }

  // Through backend server

  Future<http.Response> updatePaymentStatus(
      {required String ownerUID,
      required String shopName,
      required int orderId,
      required String date}) async {
    return await http.post(Uri.parse('$backendUrl:7777/update-payment'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'ownerUID': ownerUID,
          'shopName': shopName,
          'orderId': orderId,
          'date': date
        }));
  }

  // delete everything relate to pos tokens
  Future<http.Response> clearToken(
      {required String secret,
      required String username,
      required String token}) async {
    return await http.post(Uri.parse('$backendUrl:7777/clear-token'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({'secret': secret, 'username': username}));
  }

  // Write data to database through backend server api
  Future<http.Response> addOrder(food_order.Order order) async {
    String jsonEncoded = order.toJsonEncoded();

    print('api - addOrder: $jsonEncoded');
    http.Response httpRes = await http.post(Uri.parse('$backendUrl:7777/add'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncoded);
    return httpRes;
  }

  // Change isFinished to True
  Future<http.Response?> finishOrder(
      {required String shopName,
      required String uid,
      required food_order.Order order}) async {
    if (order.orderId == null) {
      return null;
    }
    var jsonBody = jsonEncode(<String, dynamic>{
      'shopName': shopName,
      'uid': uid,
      'orderId': order.orderId!,
      'date': '${order.date.year}/${order.date.month}/${order.date.day}'
    });
    return http.post(Uri.parse('$backendUrl:7777/finish'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody);
  }

  // Move order from realtime database to firestore
  Future<http.Response?> completeOrder({
    required String shopName,
    required String uid,
    required food_order.Order order,
  }) async {
    if (order.orderId == null) return null;
    var jsonBody = jsonEncode(<String, dynamic>{
      'shopName': shopName,
      'uid': uid,
      'orderId': order.orderId,
      'date': '${order.date.year}/${order.date.month}/${order.date.day}'
    });
    print(jsonBody);
    return http.post(Uri.parse('$backendUrl:7777/complete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody);
  }

  // update product info on firebase firestore
  Future<http.Response> updateProductInfo(
      String uid, String shopName, String type, List<Item> itemList) async {
    List<Map<String, dynamic>> productList = [];
    for (Item item in itemList) {
      Map<String, dynamic> product = {};
      product['id'] = item.id;
      product['name'] = item.name;
      product['price'] = item.price;
      product['delete'] = item.delete;
      product['type'] = type;
      product['time'] = item.time;
      product['imageUrl'] = item.image;
      product['available'] = item.available;
      productList.add(product);
    }

    var jsonBody = jsonEncode(<String, dynamic>{
      'uid': uid,
      'shopName': shopName,
      'productList': productList
    });
    print('update-product: $jsonBody');

    return http.post(Uri.parse('$backendUrl:7777/update-product'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody);
  }

  // ------------------- Manager --------------------//

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenFirestore(
      {required String collection, required String documentId}) {
    return _firestoreDB.collection(collection).doc(documentId).snapshots();
  }

  Future<manager_user.User?> getManagerInfo(User user) async {
    DocumentSnapshot<Object> res =
        await _firestoreDB.collection('Manager').doc(user.uid).get();
    var data = res.data();
    if (data != null) {
      var obj = jsonDecode(jsonEncode(data));
      List<ShopInfo> shopList = [];
      for (var shopInfo in obj['shopList']) {
        String? receptionOTP;
        String? chefOTP;
        if (shopInfo['Reception'] != null) {
          DocumentSnapshot<Map<String, dynamic>> res = await _firestoreDB
              .collection('OTP')
              .doc(shopInfo['Reception'])
              .get();
          if (res.exists) {
            var otpData = res.data() ?? {};
            if (!JwtDecoder.isExpired(otpData['token'])) {
              receptionOTP = shopInfo['Reception'];
            }
          }
        }
        if (shopInfo['Chef'] != null) {
          DocumentSnapshot<Map<String, dynamic>> res =
              await _firestoreDB.collection('OTP').doc(shopInfo['Chef']).get();
          if (res.exists) {
            var otpData = res.data() ?? {};
            if (!JwtDecoder.isExpired(otpData['token'])) {
              chefOTP = shopInfo['Chef'];
            }
          }
        }
        shopList.add(shopInfo(
            uid: user.uid,
            name: shopInfo['shopName'],
            reception: receptionOTP,
            chef: chefOTP));
      }

      manager_user.User userInfo = manager_user.User(shopList);
      return userInfo;
    }
    return null;
  }

  //-------------------- Omise ----------------------//

  // create token
  /* Future<OmiseResponse.Token> createToken(
      String publicKey,
      String name,
      String number,
      String expirationMonth,
      String expirationYear,
      String securityCode,
      {OmiseTokenInfo? info}) async {
    OmiseFlutter omise = OmiseFlutter(publicKey);
    if (info != null) {
      final response = await omise.token.create(
          name, number, expirationMonth, expirationYear, securityCode,
          city: info.city,
          country: info.country,
          postalCode: info.postalCode,
          state: info.state,
          street1: info.street1,
          street2: info.street2,
          phoneNumber: info.phoneNumber);
      return response;
    } else {
      final response = await omise.token
          .create(name, number, expirationMonth, expirationYear, securityCode);
      return response;
    }
  }

  // create source
  Future<OmiseResponse.Source> createSource(
      String publicKey, int amount, String currency, String type,
      {OmiseSourceInfo? info}) async {
    OmiseFlutter omise = OmiseFlutter(publicKey);
    final response = await omise.source.create(amount, currency, type);
    return response;
  }

  // retrieve a capability
  Future<OmiseResponse.Capability> retrieveCap(String publicKey) async {
    OmiseFlutter omise = OmiseFlutter(publicKey);
    final response = await omise.capability.retrieve();
    return response;
  } */

  // start transaction
  Future<http.Response> createTrans(
      String sourceId, int amount, String currency) async {
    print(sourceId);
    print(amount);
    print(currency);
    var response = await http.post(
        Uri.parse('$backendUrl:8888/api/v1/start-trans'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'source_id': sourceId,
          'amount': amount * 100,
          'currency': currency
        }));
    print(response.statusCode);
    return response;
  }
}

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:pos/src/interfaces/shop_info.dart';

class User {
  List<ShopInfo> shopList = [];

  User(this.shopList);
}

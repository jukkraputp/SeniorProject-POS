import 'package:jwt_decoder/jwt_decoder.dart';

class ShopInfo {
  String uid;
  String name;
  String phoneNumber;
  String? reception;
  String? chef;

  ShopInfo(
      {required this.uid,
      required this.name,
      required this.phoneNumber,
      this.reception,
      this.chef});
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pos/src/interfaces/item.dart';

ItemCard genCard(
  Item item,
  void Function(Item, {String? mode})? updateBasket,
) {
  ItemCard card = ItemCard(item: item, updateBasket: updateBasket);
  return card;
}

class ItemCard extends StatelessWidget {
  const ItemCard(
      {Key? key,
      this.width,
      this.height,
      this.imageWidth,
      this.imageHeight,
      this.fontSize,
      this.showPrice,
      this.updateBasket,
      required this.item})
      : super(key: key);

  final Item item;
  final void Function(Item, {String? mode})? updateBasket;
  final double? width;
  final double? height;
  final double? imageWidth;
  final double? imageHeight;
  final double? fontSize;
  final bool? showPrice;

  void onPressed(Item item, {String? mode}) {
    if (updateBasket != null) {
      updateBasket!(item, mode: mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = width ?? 200;
    double containerHeight = height ?? 200;
    bool showPriceText = showPrice ?? true;
    return Container(
      width: containerWidth,
      height: containerHeight,
      padding: const EdgeInsets.all(0),
      child: TextButtonTheme(
        data: TextButtonThemeData(
            style: TextButton.styleFrom(
          primary: Colors.black,
        )),
        child: TextButton(
          style: TextButton.styleFrom(
              fixedSize: Size(imageWidth ?? containerWidth * 9 / 16,
                  imageHeight ?? containerHeight * 9 / 16)),
          onPressed: () => onPressed(item),
          child: Column(
            children: [
              CachedNetworkImage(
                  width: imageWidth ?? containerWidth * 9 / 16,
                  height: imageHeight ?? containerHeight * 9 / 16,
                  fit: BoxFit.cover,
                  imageUrl: item.image),
              Text(
                item.name,
                style: TextStyle(
                    fontSize: fontSize ?? 16, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              if (showPriceText)
                Text(
                  '${item.price} บาท',
                  style: TextStyle(
                      fontSize: fontSize != null ? fontSize! - 2 : 14,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                )
            ],
          ),
        ),
      ),
    );
  }
}

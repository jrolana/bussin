import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:bussin/model/item.dart';

Future loadJsonMenu(String category) async {
  String jsonRoot = await rootBundle.loadString('assets/$category.json');
  final itemsDecoded = jsonDecode(jsonRoot);
  final categoryItems = itemsDecoded[category];

  List<dynamic> items =
      categoryItems.map((item) => Item.fromMap(item)).toList();
  return items;
}

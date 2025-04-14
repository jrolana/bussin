import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:bussin/model/item.dart';

Future loadJsonMenu(String category) async {
  String jsonRoot = await rootBundle.loadString('assets/$category.json');
  final itemsDecoded = jsonDecode(jsonRoot);

  List<dynamic> items = itemsDecoded.map((item) => Item.fromMap(item)).toList();

  return items;
}

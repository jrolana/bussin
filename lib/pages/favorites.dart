import 'package:bussin/model/item.dart';
import 'package:bussin/services/database_service.dart';
import 'package:bussin/widgets/saved_order.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<List<Item>> favorites = [];

  Future<void> getFavorites() async {
    var dbFavorites = await DatabaseService.getFavorites();
    setState(() {
      favorites = dbFavorites;
    });
  }

  Future<void> handleRemove(List<Item> items, int index) async {
    await DatabaseService.removeFavorite(items);
    setState(() {
      favorites.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return favorites.length < 1
        ? Center(child: Text("No favorites"))
        : ListView.builder(
          itemCount: favorites.length,
          itemBuilder:
              (context, index) => SavedOrder(
                items: favorites[index],
                onRemove: (items) => handleRemove(items, index),
              ),
        );
  }
}

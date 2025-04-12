import 'package:bussin/exceptions/not_enough_money.dart';
import 'package:bussin/model/item.dart';
import 'package:bussin/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

Future<Item?> getRandomItem(String category, {double? maxPrice}) async {
  Database db = await DatabaseService.instance.db;

  List<Map<String, dynamic>> res = await db.query(
    category,
    where: maxPrice != null ? 'price <= ?' : null,
    whereArgs: maxPrice != null ? ['$maxPrice'] : [],
    orderBy: "random()",
    limit: 1,
  );

  return res.length > 0 ? Item.fromMap(res[0]) : null;
}

Future<double> getMinPrice(String category) async {
  Database db = await DatabaseService.instance.db;

  List<Map<String, dynamic>> res = await db.query(
    category,
    orderBy: "price",
    limit: 1,
  );

  return res[0]['price'].toDouble();
}

// Meal iff all 3 are false
// Returns (main, side, drink, meal)
Future<(Item?, Item?, Item?, Item?)> mcrandomizer({
  required bool main,
  required bool side,
  required bool drink,
  double? maxPrice,
}) async {
  double minMain = await getMinPrice('main'),
      minSide = await getMinPrice('side'),
      minDrink = await getMinPrice('drink'),
      minMeal = await getMinPrice('meal'),
      minNeed = 0;

  if (main) minNeed += minMain;
  if (side) minNeed += minSide;
  if (drink) minNeed += minDrink;
  if (!main && !side && !drink) minNeed += minMeal;

  if (maxPrice != null && maxPrice < minNeed) {
    throw NotEnoughMoneyException(
      "Max price does not reach minimum needed money of $minNeed.",
    );
  }

  Item? mainItem, sideItem, drinkItem, mealItem;

  // Check if meal
  if (!main && !side && !drink) {
    mealItem = await getRandomItem('meal', maxPrice: maxPrice);
  } else {
    double currExtraMoney =
        maxPrice != null ? maxPrice - minNeed : double.maxFinite;

    if (main) {
      mainItem = await getRandomItem(
        'main',
        maxPrice: minMain + currExtraMoney,
      );
      currExtraMoney -= (mainItem!.price - minMain);
    }
    if (side) {
      sideItem = await getRandomItem(
        'side',
        maxPrice: minSide + currExtraMoney,
      );
      currExtraMoney -= (sideItem!.price - minSide);
    }
    if (drink) {
      drinkItem = await getRandomItem(
        'drink',
        maxPrice: minDrink + currExtraMoney,
      );
      currExtraMoney -= (drinkItem!.price - minDrink);
    }
  }

  return (mainItem, sideItem, drinkItem, mealItem);
}

import 'dart:async';

import 'package:bussin/exceptions/not_enough_money.dart';
import 'package:bussin/model/item.dart';
import 'package:bussin/services/mcrandomizer_service.dart';

import 'services/database_service.dart';
import 'widgets/slot_machine.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initDb();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int?> targets = [1, 1, 1, 1];
  List<Item?> items = [null, null, null, null];

  void resetItem(int index) {
    if (index == 3) {
      targets[0] = targets[1] = targets[2] = targets[3] = null;
      items[0] = items[1] = items[2] = items[3] = null;
    }
    targets[index] = null;
    items[index] = null;
  }

  Future<void> rollSlots() async {
    bool chooseMain = true, chooseSide = true, chooseDrink = false;
    double userMaxPrice = 200 ?? double.maxFinite;

    try {
      setState(() {
        if (chooseMain) resetItem(0);
        if (chooseSide) resetItem(1);
        if (chooseDrink) resetItem(2);
        if (!chooseMain && !chooseSide && !chooseDrink) resetItem(3);
      });

      double currMaxPrice = userMaxPrice;
      items.forEach((item) => currMaxPrice -= item?.price ?? 0);

      var newItems = await mcrandomizer(
        main: chooseMain,
        side: chooseSide,
        drink: chooseDrink,
        maxPrice: currMaxPrice,
      );

      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        if (chooseMain) {
          targets[0] = 2;
          items[0] = newItems.$1;
        }
        if (chooseSide) {
          targets[1] = 2;
          items[1] = newItems.$2;
        }
        if (chooseDrink) {
          targets[2] = 2;
          items[2] = newItems.$3;
        }
      });
    } on NotEnoughMoneyException catch (e) {
      double minNeed = e.missing + userMaxPrice;
      String errorMsg =
          "Max price does not reach minimum needed money of $minNeed.";
      SnackBar errorSnackBar = SnackBar(content: Text(errorMsg));
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
      setState(() {
        for (int i = 0; i < 4; i++) {
          if (targets[i] == null) targets[i] = 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Center(
            child: SlotMachine(
              targets: targets,
              imageUrl: items.map((item) => item?.imageUrl).toList(),
            ),
          ),
          for (Item? item in items)
            if (item != null)
              Row(children: [Text(item.name), Text(item.price.toString())]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: rollSlots,
        tooltip: 'Rolling',
        child: const Icon(Icons.rocket_launch_outlined),
      ),
    );
  }
}

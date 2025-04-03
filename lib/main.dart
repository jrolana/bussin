import 'dart:async';
import 'dart:developer';

import 'package:bussin/model/item.dart';

import 'services/database_service.dart';
import 'widgets/slot_machine.dart';

import 'package:flutter/material.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  await DatabaseService.instance.initDb();
  await DatabaseService.instance.initializeItem();

  // Query Sample
  List<Map> result = await DatabaseService.instance.queryAllItems('side');

  List<Item> results = [
    for (final {'id': id, 'name': name, 'price': price, 'imageUrl': imageUrl}
        in result)
      Item(id: id, name: name, price: price, imageUrl: imageUrl),
  ];

  results.forEach((r) => log(r.name));

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
  var targets = List<int?>.filled(3, 1);

  Future<void> _incrementCounter() async {
    setState(() {
      targets = List<int?>.filled(3, null);
    });

    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      targets = List<int?>.filled(3, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: SlotMachine(targets: targets)),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Rolling',
        child: const Icon(Icons.rocket_launch_outlined),
      ),
    );
  }
}

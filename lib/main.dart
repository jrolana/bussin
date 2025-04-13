import 'package:bussin/widgets/three_slots_machine.dart';
import 'services/database_service.dart';
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
      title: "McRandomizer",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "McRandomizer"),
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
  final threeSlotsMachine = GlobalKey<ThreeSlotsMachineState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ThreeSlotsMachine.ThreeSlotsMachine(
              key: threeSlotsMachine,
              itemSize: constraints.maxWidth / 3,
              maxPrice: 200,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          threeSlotsMachine.currentState?.rollSlots();
        },
        tooltip: 'Rolling',
        child: const Icon(Icons.rocket_launch_outlined),
      ),
    );
  }
}

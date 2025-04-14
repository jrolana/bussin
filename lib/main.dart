import 'package:bussin/widgets/one_slot_machine.dart';
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
  final oneSlotMachine = GlobalKey<OneSlotMachineState>();
  // True == three
  // False == one
  bool mode = true;
  double maxPrice = double.maxFinite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        spacing: 50,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (mode) {
                  return ThreeSlotsMachine.ThreeSlotsMachine(
                    key: threeSlotsMachine,
                    itemSize: constraints.maxWidth / 3,
                    maxPrice: maxPrice,
                  );
                } else {
                  return OneSlotMachine.OneSlotMachine(
                    key: oneSlotMachine,
                    itemSize: constraints.maxWidth / 3,
                    maxPrice: maxPrice,
                  );
                }
              },
            ),
          ),

          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter budget',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                maxPrice = double.tryParse(value) ?? double.maxFinite;
              });
            },
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 10,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                mode = !mode;
              });
            },
            tooltip: 'Mode',
            child: const Icon(Icons.mode),
          ),
          FloatingActionButton(
            onPressed: () {
              if (mode) {
                threeSlotsMachine.currentState?.rollSlots();
              } else {
                oneSlotMachine.currentState?.rollSlots();
              }
            },
            tooltip: 'Rolling',
            child: const Icon(Icons.rocket_launch_outlined),
          ),
        ],
      ),
    );
  }
}

import 'package:bussin/model/item.dart';
import 'package:bussin/utils/constants.dart';
import 'package:bussin/widgets/one_slot_machine.dart';
import 'package:bussin/widgets/receipt.dart';
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
      debugShowCheckedModeBanner: false,
      title: "bussin",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "bussin"),
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
  bool setBudget = false;
  bool mode = true;
  double maxPrice = double.maxFinite;
  bool isDone = false;
  late List<Item> items;

  Future<void> showReceipt() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ShowReceipt(items: items);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 40, 8, 16),
          child: Column(
            spacing: 25,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset("lib/assets/mcdo_logo.png", width: 250),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: mcdColor,
                    ),
                    margin: EdgeInsets.only(top: 80),
                    padding: EdgeInsets.all(15),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (mode) {
                          return ThreeSlotsMachine.ThreeSlotsMachine(
                            key: threeSlotsMachine,
                            itemSize: constraints.maxWidth / 3,
                            maxPrice: maxPrice,
                            onSpinEnd: (_items) {
                              setState(() {
                                isDone = true;
                                items = _items;
                              });
                              showReceipt();
                            },
                          );
                        } else {
                          return OneSlotMachine.OneSlotMachine(
                            key: oneSlotMachine,
                            itemSize: constraints.maxWidth / 3,
                            maxPrice: maxPrice,
                            onSpinEnd: (_items) {
                              setState(() {
                                isDone = true;
                                items = [_items];
                              });
                              showReceipt();
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          mode = !mode;
                          isDone = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 4,
                      ),
                      child:
                          mode
                              ? const Text(
                                'Mixed',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              )
                              : const Text(
                                'Meal',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          setBudget = !setBudget;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 4,
                      ),
                      child: const Text(
                        'Budget',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isDone = false;
                      });

                      if (mode) {
                        threeSlotsMachine.currentState?.rollSlots();
                      } else {
                        oneSlotMachine.currentState?.rollSlots();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(40),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Roll',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),

              setBudget
                  ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: .2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter budget',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.monetization_on_outlined,
                            color:
                                Colors
                                    .amber[700], 
                            size: 22,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: const Color.fromRGBO(255, 160, 0, 1),
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            maxPrice =
                                double.tryParse(value) ?? double.maxFinite;
                          });
                        },
                      ),
                    ),
                  )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}


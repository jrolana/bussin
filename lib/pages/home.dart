import 'package:bussin/model/item.dart';
import 'package:bussin/widgets/one_slot_machine.dart';
import 'package:bussin/widgets/receipt.dart';
import 'package:bussin/widgets/three_slots_machine.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final threeSlotsMachine = GlobalKey<ThreeSlotsMachineState>();
  final oneSlotMachine = GlobalKey<OneSlotMachineState>();
  // True == three
  // False == one
  bool setBudget = false;
  bool mode = true;
  double maxPrice = double.maxFinite;
  final Color mcColor = Color(0xFFDA291C);
  bool isDone = false;
  late List<Item> items;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _receiptKey = GlobalKey();

  void scrollToReceipt() {
    if (_receiptKey.currentContext != null) {
      Scrollable.ensureVisible(
        _receiptKey.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          spacing: 5,
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
                    color: mcColor,
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
                            scrollToReceipt();
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
                            scrollToReceipt();
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
                    child: const Text(
                      'Mode',
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
                                  .amber[700], // Using McDonald's gold/amber instead of red
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
                          maxPrice = double.tryParse(value) ?? double.maxFinite;
                        });
                      },
                    ),
                  ),
                )
                : SizedBox(),

            isDone
                ? Container(key: _receiptKey, child: Receipt(items: items))
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

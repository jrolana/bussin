import 'package:bussin/exceptions/not_enough_money.dart';
import 'package:bussin/model/item.dart';
import 'package:bussin/services/mcrandomizer_service.dart';
import 'package:bussin/widgets/single_slot_roller.dart';
import 'package:flutter/material.dart';

const mainColor = Color(0xFFFF0000);
const sideColor = Color(0xFFFFC107);
const drinkColor = Color(0xFF40D0FD);
const disabledColor = Color(0xFFB0B0B0);

class ThreeSlotsMachine extends StatefulWidget {
  final double itemSize;
  final double maxPrice;
  final void Function(List<Item> items)? onSpinEnd;

  const ThreeSlotsMachine.ThreeSlotsMachine({
    Key? key,
    required this.itemSize,
    required this.maxPrice,
    this.onSpinEnd,
  }) : super(key: key);

  @override
  State<ThreeSlotsMachine> createState() => ThreeSlotsMachineState();
}

class ThreeSlotsMachineState extends State<ThreeSlotsMachine> {
  List<Item?> items = [null, null, null];

  final mainSlot = GlobalKey<SlotRollerState>();
  final sideSlot = GlobalKey<SlotRollerState>();
  final drinkSlot = GlobalKey<SlotRollerState>();
  bool chooseMain = true, chooseSide = true, chooseDrink = true;
  // if count == 3: done rolling
  int count = 3;

  void incrementCount() {
    setState(() {
      count += 1;

      if (widget.onSpinEnd != null && count == 3) {
        List<Item> notNullItem = [];
        for (var item in items) {
          if (item != null) {
            notNullItem.add(item);
          }
        }
        widget.onSpinEnd!(notNullItem);
      }
    });
  }

  Future<void> rollSlots() async {
    try {
      setState(() {
        int localCount = 3;
        if (chooseMain) {
          items[0] = null;
          localCount -= 1;
        }
        if (chooseSide) {
          items[1] = null;
          localCount -= 1;
        }
        if (chooseDrink) {
          items[2] = null;
          localCount -= 1;
        }
        count = localCount;
      });

      double currMaxPrice = widget.maxPrice;
      items.forEach((item) => currMaxPrice -= item?.price ?? 0);

      var newItems = await mcrandomizer(
        main: chooseMain,
        side: chooseSide,
        drink: chooseDrink,
        maxPrice: currMaxPrice,
      );

      setState(() {
        if (chooseMain) {
          items[0] = newItems.$1;
          mainSlot.currentState?.spin(newItems.$1!);
        }
        if (chooseSide) {
          items[1] = newItems.$2;
          sideSlot.currentState?.spin(newItems.$2!);
        }
        if (chooseDrink) {
          items[2] = newItems.$3;
          drinkSlot.currentState?.spin(newItems.$3!);
        }
      });
    } on NotEnoughMoneyException catch (e) {
      if (mounted) {
        double minNeed = e.missing + widget.maxPrice;
        String errorMsg =
            "Max price does not reach minimum needed money of $minNeed.";
        SnackBar errorSnackBar = SnackBar(content: Text(errorMsg));
        ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.fromLTRB(0, 0, 0, 25),
      child: Column(
        spacing: 30,
        children: [
          Container(
            height: widget.itemSize * 3,
            decoration: BoxDecoration(),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlotRoller.SlotRoller(
                      key: mainSlot,
                      itemSize: widget.itemSize,
                      onSpinEnd: incrementCount,
                    ),
                    SlotRoller.SlotRoller(
                      key: sideSlot,
                      itemSize: widget.itemSize,
                      onSpinEnd: incrementCount,
                    ),
                    SlotRoller.SlotRoller(
                      key: drinkSlot,
                      itemSize: widget.itemSize,
                      onSpinEnd: incrementCount,
                    ),
                  ],
                ),

                // Fade effect
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: widget.itemSize * 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: widget.itemSize * 0.7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    chooseMain = !chooseMain;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    chooseMain ? mainColor : disabledColor,
                  ),
                  shape: WidgetStateProperty.all(
                    ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(Size(75, 40)),
                ),
                child: Text('Main', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    chooseSide = !chooseSide;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    chooseSide ? sideColor : disabledColor,
                  ),
                  shape: WidgetStateProperty.all(
                    ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(Size(75, 40)),
                ),
                child: Text('Side', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    chooseDrink = !chooseDrink;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    chooseDrink ? drinkColor : disabledColor,
                  ),
                  shape: WidgetStateProperty.all(
                    ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(Size(75, 40)),
                ),
                child: Text('Drink', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

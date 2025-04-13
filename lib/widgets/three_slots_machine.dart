import 'package:bussin/exceptions/not_enough_money.dart';
import 'package:bussin/model/item.dart';
import 'package:bussin/services/mcrandomizer_service.dart';
import 'package:bussin/widgets/single_slot_roller.dart';
import 'package:flutter/material.dart';

class ThreeSlotsMachine extends StatefulWidget {
  final double itemSize;
  final double maxPrice;

  const ThreeSlotsMachine.ThreeSlotsMachine({
    Key? key,
    required this.itemSize,
    required this.maxPrice,
  }) : super(key: key);

  @override
  State<ThreeSlotsMachine> createState() => ThreeSlotsMachineState();
}

class ThreeSlotsMachineState extends State<ThreeSlotsMachine> {
  List<Item?> items = [null, null, null];

  final mainSlot = GlobalKey<SlotRollerState>();
  final sideSlot = GlobalKey<SlotRollerState>();
  final drinkSlot = GlobalKey<SlotRollerState>();

  Future<void> rollSlots() async {
    bool chooseMain = true, chooseSide = true, chooseDrink = true;

    try {
      setState(() {
        if (chooseMain) {
          items[0] = null;
        }
        if (chooseSide) {
          items[1] = null;
        }
        if (chooseDrink) {
          items[2] = null;
        }
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
    return Column(
      children: [
        Container(
          height: widget.itemSize * 3,
          decoration: BoxDecoration(color: Colors.white),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlotRoller.SlotRoller(
                    key: mainSlot,
                    itemSize: widget.itemSize,
                  ),
                  SlotRoller.SlotRoller(
                    key: sideSlot,
                    itemSize: widget.itemSize,
                  ),
                  SlotRoller.SlotRoller(
                    key: drinkSlot,
                    itemSize: widget.itemSize,
                  ),
                ],
              ),

              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: widget.itemSize * 0.7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),

              // Bottom fade effect
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

              // Selection indicator (center line)
              Center(
                child: Container(
                  height: widget.itemSize,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.red.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      bottom: BorderSide(
                        color: Colors.red.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        for (Item? item in items)
          if (item != null)
            Row(children: [Text(item.name), Text(item.price.toString())]),
      ],
    );
  }
}

import 'package:bussin/exceptions/not_enough_money.dart';
import 'package:bussin/model/item.dart';
import 'package:bussin/services/mcrandomizer_service.dart';
import 'package:bussin/widgets/single_slot_roller.dart';
import 'package:flutter/material.dart';

class OneSlotMachine extends StatefulWidget {
  final double itemSize;
  final double maxPrice;

  OneSlotMachine.OneSlotMachine({
    Key? key,
    required this.itemSize,
    required this.maxPrice,
  }) : super(key: key);

  @override
  State<OneSlotMachine> createState() => OneSlotMachineState();
}

class OneSlotMachineState extends State<OneSlotMachine> {
  Item? item;

  final mealSlot = GlobalKey<SlotRollerState>();

  Future<void> rollSlots() async {
    try {
      var newItems = await mcrandomizer(
        main: false,
        side: false,
        drink: false,
        maxPrice: widget.maxPrice,
      );

      mealSlot.currentState?.spin(newItems.$4!);
      setState(() {
        item = newItems.$4;
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
              Center(
                child: SlotRoller.SlotRoller(
                  key: mealSlot,
                  itemSize: widget.itemSize,
                ),
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
      ],
    );
  }
}

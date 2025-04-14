import 'package:bussin/exceptions/not_enough_money.dart';
import 'package:bussin/model/item.dart';
import 'package:bussin/services/mcrandomizer_service.dart';
import 'package:bussin/widgets/single_slot_roller.dart';
import 'package:flutter/material.dart';

class OneSlotMachine extends StatefulWidget {
  final double itemSize;
  final double maxPrice;
  final void Function(Item items)? onSpinEnd;

  OneSlotMachine.OneSlotMachine({
    Key? key,
    required this.itemSize,
    required this.maxPrice,
    this.onSpinEnd,
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
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.fromLTRB(0, 0, 0, 48),
      child: Column(
        children: [
          Container(
            height: widget.itemSize * 3,
            decoration: BoxDecoration(),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Center(
                  child: SlotRoller.SlotRoller(
                    key: mealSlot,
                    itemSize: widget.itemSize,
                    onSpinEnd: () {
                      if (widget.onSpinEnd != null && item != null) {
                        widget.onSpinEnd!(item!);
                      }
                    },
                  ),
                ),

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

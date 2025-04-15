import 'dart:math';

import 'package:bussin/model/item.dart';
import 'package:flutter/material.dart';

class SlotRoller extends StatefulWidget {
  final double itemSize;
  final VoidCallback? onSpinEnd;

  const SlotRoller.SlotRoller({
    Key? key,
    required this.itemSize,
    this.onSpinEnd,
  }) : super(key: key);

  @override
  State<SlotRoller> createState() => SlotRollerState();
}

class SlotRollerState extends State<SlotRoller>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  Item? _targetItem;
  bool _reversed = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void spin(Item targetItem) async {
    setState(() {
      _targetItem = targetItem;
    });

    bool reversed = _reversed;
    double target = reversed ? widget.itemSize * 5 : widget.itemSize * 60;

    setState(() {
      _reversed = !_reversed;
    });

    await _scrollController.animateTo(
      reversed
          ? _scrollController.offset - widget.itemSize * 3
          : _scrollController.offset + widget.itemSize * 3,
      duration: Duration(milliseconds: Random().nextInt(700) + 700),
      curve: Curves.easeInToLinear,
    );
    await _scrollController.animateTo(
      target,
      duration: Duration(seconds: Random().nextInt(4) + 2),
      curve: Curves.linearToEaseOut,
    );

    if (widget.onSpinEnd != null) {
      widget.onSpinEnd!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.itemSize * 3,
      width: widget.itemSize,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        controller: _scrollController,
        itemCount: 63,
        itemBuilder: (context, index) {
          if (_targetItem != null && (!_reversed ? index == 6 : index == 61)) {
            return Center(
              child: Image.network(
                _targetItem!.imageUrl,
                width: widget.itemSize,
                height: widget.itemSize,
              ),
            );
          }

          return Container(
            height: widget.itemSize,
            padding: EdgeInsets.all(10),
            child: Center(child: Image.asset('lib/assets/mcdo_logo.png')),
          );
        },
      ),
    );
  }
}

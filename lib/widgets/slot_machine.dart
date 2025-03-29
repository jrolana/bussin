import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SlotMachineRoller extends StatefulWidget {
  const SlotMachineRoller({
    super.key,
    required this.height,
    required this.width,
    required this.itemBuilder,
    this.target,
    this.reverse = false,
    this.period = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.minTarget = 1,
    this.maxTarget = 1,
  });

  /// Field of view of roller
  final double height, width;

  /// Whether rolling up or down
  final bool reverse;

  /// Rolling period duration
  final Duration period;

  /// Delay at start moment
  final Duration delay;

  /// Item build in roller
  final Widget Function(int number) itemBuilder;

  /// To stop value. when it is null, it is seamless rolling
  final int? target;

  /// For random sample in your target range.
  /// Because during the rolling, items are randomly
  final int minTarget, maxTarget;

  @override
  State<SlotMachineRoller> createState() => _SlotMachineRollerState();
}

class _SlotMachineRollerState extends State<SlotMachineRoller> {
  final scrollController = ScrollController(keepScrollOffset: false);
  final rng = Random();
  bool pipeClosed = true;

  late Stream<int> pipe;
  int? before;

  @override
  Widget build(BuildContext context) {
    if (pipeClosed) {
      pipe = startPipe();
    }
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: StreamBuilder(
          stream: pipe,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final cached =
                before == null
                    ? <int>[]
                    : <int>[before!] +
                        (List.generate(
                          widget.period.inMilliseconds ~/ 125,
                          (index) => getRandomTarget(),
                        ));
            if (data != null) {
              cached.add(data);
              before = data;
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollController.jumpTo(0);
              final curve =
                  !pipeClosed ? Curves.linear : Curves.linearToEaseOut;
              final duration =
                  !pipeClosed
                      ? widget.period
                      : Duration(
                        milliseconds: widget.period.inMilliseconds * 5,
                      );
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: duration,
                curve: curve,
              );
            });
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              controller: scrollController,
              reverse: widget.reverse,
              child: Column(
                children:
                    (widget.reverse ? cached.reversed : cached)
                        .map(widget.itemBuilder)
                        .toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Stream<int> startPipe() async* {
    pipeClosed = false;
    final lastData = before ?? widget.target ?? getRandomTarget();
    before = null;
    yield lastData;
    await Future.delayed(widget.delay);
    before = null;
    while (widget.target == null) {
      yield before == null ? lastData : getRandomTarget();
      await Future.delayed(widget.period);
    }
    pipeClosed = true;
    yield widget.target!;
  }

  int getRandomTarget() =>
      widget.minTarget + rng.nextInt(widget.maxTarget - widget.minTarget + 1);
}

class SlotMachine extends StatelessWidget {
  const SlotMachine({super.key, required this.targets});

  final List<int?> targets;

  @override
  Widget build(BuildContext context) {
    List<String> imageUrl = [
      "https://mcdomenu.ph/wp-content/uploads/2024/09/Mcdo-Big-Mac.webp",
      "https://mcdomenu.ph/wp-content/uploads/2024/09/1pc-Chicken-McDo-with-McSpaghetti.webp",
      "https://mcdomenu.ph/wp-content/uploads/2024/11/Liptin-Iced-Tea.webp",
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth).clamp(.0, 533.0);
        final screenSize = Size(width / 1.5, width / 3.6);
        return Stack(
          children: [
            Image.asset(
              "assets/machine.png",
              width: width,
              package: 'slot_machine_roller',
            ),
            Transform.translate(
              offset: Offset(screenSize.width / 6.4, screenSize.height * 0.94),
              child: SizedBox(
                width: screenSize.width,
                height: screenSize.height,
                child: Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      decoration:
                          index < 2
                              ? const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.grey),
                                ),
                              )
                              : null,
                      child: SlotMachineRoller(
                        height: screenSize.height,
                        width: screenSize.width / 3 - 1,
                        itemBuilder: (number) {
                          if (number == 1) {
                            return Image.asset(
                              'lib/assets/mcdo_logo.png',
                              height: screenSize.height,
                              width: screenSize.width / 3 - 1,
                            );
                          } else {
                            return Image.network(
                              imageUrl[index],
                              height: screenSize.height,
                              width: screenSize.width / 3 - 1,
                            );
                          }
                        },
                        target: targets[index],
                        delay: Duration(milliseconds: 250 * (2 - index)),
                        reverse: index & 1 > 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

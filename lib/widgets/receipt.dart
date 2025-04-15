import 'package:bussin/model/item.dart';
import 'package:bussin/services/database_service.dart';
import 'package:flutter/material.dart';

class ShowReceipt extends StatelessWidget {
  const ShowReceipt({super.key, required this.items});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(0),
      content: Stack(
        children: [
          Receipt(items: items),
          Padding(
            padding: EdgeInsets.all(8),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class Receipt extends StatefulWidget {
  final List<Item> items;
  const Receipt({super.key, required this.items});

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool isFavorite = false;

  Future<void> checkIfFavorite() async {
    bool isFavoriteFromDb = await DatabaseService.isAlreadyFavorite(
      widget.items,
    );
    setState(() {
      isFavorite = isFavoriteFromDb;
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfFavorite();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.fold(0.0, (sum, item) => sum + (item.price));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRect(
          child: FractionalTranslation(
            translation: Offset(0, _slideAnimation.value),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fastfood, color: Colors.amber[700], size: 40),
                      const SizedBox(height: 10),
                      const Text(
                        "Bussin",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            "Here's your meal:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ...List.generate(widget.items.length, (index) {
                        final double startTime = 0.3 + (index * 0.1);
                        final double endTime = startTime + 0.2;

                        final double itemProgress =
                            _controller.value < startTime
                                ? 0.0
                                : _controller.value > endTime
                                ? 1.0
                                : ((_controller.value - startTime) /
                                    (endTime - startTime));

                        return Opacity(
                          opacity: itemProgress,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - itemProgress)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      widget.items[index].name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "₱${(widget.items[index].price).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 15),
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(
                              0.7,
                              0.9,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(
                              0.7,
                              0.9,
                              curve: Curves.easeIn,
                            ),
                          ),
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(
                              0.8,
                              1.0,
                              curve: Curves.elasticOut,
                            ),
                          ),
                        ),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(
                              0.8,
                              1.0,
                              curve: Curves.easeIn,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Price",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              Text(
                                "₱${total.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              if (isFavorite) {
                                await DatabaseService.removeFavorite(
                                  widget.items,
                                );
                              } else {
                                await DatabaseService.insertFavorite(
                                  widget.items,
                                );
                              }

                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isFavorite
                                        ? Colors.red.shade50
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  if (!isFavorite)
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                  if (isFavorite)
                                    BoxShadow(
                                      color: Colors.red.shade100.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          isFavorite
                                              ? Colors.red
                                              : Colors.grey.shade400,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isFavorite ? 'Favorited' : 'Favorite',
                                    style: TextStyle(
                                      color:
                                          isFavorite
                                              ? Colors.red
                                              : Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

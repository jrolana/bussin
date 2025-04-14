import 'package:bussin/model/item.dart';
import 'package:flutter/material.dart';

class McDoReceipt extends StatelessWidget {
  final List<Item> items;
  const McDoReceipt({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = items.fold(0.0, (sum, item) => sum + (item.price));

    return Container(
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
            // Logo and title
            Icon(Icons.fastfood, color: Colors.amber[700], size: 40),
            const SizedBox(height: 10),
            const Text(
              "McDoApp Philippines",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 5),

            const SizedBox(height: 20),
            // Receipt header
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
            // Items
            ...items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          "₱${(item.price).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 15),
            // Divider
            Divider(color: Colors.grey[300], thickness: 1),
            const SizedBox(height: 15),
            // Total
            Row(
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
          ],
        ),
      ),
    );
  }
}

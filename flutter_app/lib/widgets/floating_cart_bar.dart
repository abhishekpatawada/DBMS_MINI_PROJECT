import 'package:flutter/material.dart';
import '../services/cart_manager.dart';
import '../screens/user/cart_checkout_screen.dart';

class FloatingCartBar extends StatelessWidget {
  final Map<String, dynamic> userData;

  const FloatingCartBar({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartManager,
      builder: (context, _) {
        if (cartManager.isEmpty) return const SizedBox.shrink();

        final vendorName = cartManager.orderType == "Restaurant"
            ? (cartManager.activeRestName ?? "Restaurant")
            : "Dark Store #${cartManager.activeStoreId ?? 1}";

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Material(
              elevation: 8,
              shadowColor: const Color(0xFF4F46E5).withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1E1B4B), // Deep Indigo brand surface
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartCheckoutScreen(userData: userData),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      // Cart quantity badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${cartManager.totalCount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Vendor & Total
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "₹${cartManager.grandTotal.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // View Cart action (text only inside button, adhering to constraints)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Emerald green CTA
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "View Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
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

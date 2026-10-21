import 'package:flutter/material.dart';
import '../../services/cart_manager.dart';
import '../../services/api_service.dart';
import '../../utils/item_image_helper.dart';
import 'order_tracking_screen.dart';

class CartCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CartCheckoutScreen({super.key, required this.userData});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  // 0: Your Cart (Screen 5), 1: Checkout (Screen 6)
  int _checkoutStep = 0;

  final _couponController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _selectedPayment = "BiteHub Pay";
  bool _isSubmitting = false;

  final List<String> _savedAddresses = [
    "Home • Sector 62, Green Park, Noida, Uttar Pradesh - 201309",
    "Office • Cyber City, Tower B, Gurugram, Haryana - 122002",
    "Other • Block C, Indiranagar, Bengaluru, Karnataka - 560038",
  ];

  @override
  void dispose() {
    _couponController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 14),
            ..._savedAddresses.map((addr) {
              final isSelected = cartManager.deliveryAddress == addr;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                ),
                child: ListTile(
                  title: Text(
                    addr.split("•").first.trim(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    addr.split("•").last.trim(),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  trailing: isSelected
                      ? const Text("Selected", style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold))
                      : null,
                  onTap: () {
                    cartManager.setDeliveryAddress(addr);
                    Navigator.pop(ctx);
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showAddCustomAddressDialog();
              },
              child: const Text("+ Add New Address", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomAddressDialog() {
    final customAddrController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Address"),
        content: TextField(
          controller: customAddrController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: "Flat / House No, Street, Area, Pincode",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final text = customAddrController.text.trim();
              if (text.isNotEmpty) {
                final full = "Home • $text";
                setState(() => _savedAddresses.add(full));
                cartManager.setDeliveryAddress(full);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save & Deliver Here"),
          ),
        ],
      ),
    );
  }

  void _showCouponDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Apply Coupon",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "Enter coupon code",
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final success = cartManager.applyCoupon(_couponController.text);
                    Navigator.pop(ctx);
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid coupon. Try BITEHUB50 or FEAST20"), backgroundColor: Colors.red),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Applied '${cartManager.appliedCoupon}'!"), backgroundColor: const Color(0xFF10B981)),
                      );
                    }
                  },
                  child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("AVAILABLE COUPONS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            _couponOption("FEAST20", "Flat 20% OFF on all items", "Min order ₹200"),
            _couponOption("BITEHUB50", "50% OFF up to ₹100", "Min order ₹150"),
            _couponOption("INSTA50", "₹50 OFF on Instamart orders", "Valid on groceries"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _couponOption(String code, String desc, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(code, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4F46E5), fontSize: 14)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              Text(sub, style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
            ],
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4F46E5),
              side: const BorderSide(color: Color(0xFF4F46E5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              cartManager.applyCoupon(code);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Applied '$code'!"), backgroundColor: const Color(0xFF10B981)),
              );
            },
            child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlaceOrder() async {
    if (cartManager.isEmpty) return;

    final userId = widget.userData['User_Id'] ?? widget.userData['userId'] ?? 1;

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        "user_id": userId,
        "rest_id": cartManager.activeRestId,
        "store_id": cartManager.activeStoreId,
        "order_type": cartManager.orderType,
        "payment_method": _selectedPayment,
        "delivery_addr": cartManager.deliveryAddress,
        "items": cartManager.toOrderItemsPayload(),
        "discount_amount": cartManager.discountAmount,
        "delivery_fee": cartManager.deliveryFee,
        "taxes": cartManager.taxes,
      };

      final res = await ApiService.placeOrder(payload);
      final orderId = res['order_id'] as int? ?? 1;

      cartManager.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order confirmed! Your meal is being prepared."),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(
              orderId: orderId,
              userData: widget.userData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartManager,
      builder: (context, _) {
        if (cartManager.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text("Your Cart", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A))),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(child: Text("🛒", style: TextStyle(fontSize: 40))),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Your cart is empty",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Explore top-rated restaurants and dishes to satisfy your cravings.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Browse Dishes & Groceries", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Render Step 0 (Screen 5: Your Cart) OR Step 1 (Screen 6: Checkout)
        return _checkoutStep == 0 ? _buildCartScreen() : _buildCheckoutScreen();
      },
    );
  }

  // ===========================================================================
  // SCREEN 5: YOUR CART
  // ===========================================================================
  Widget _buildCartScreen() {
    final isBite = cartManager.orderType == "Restaurant";
    final vendorTitle = isBite
        ? (cartManager.activeRestName ?? "BBQ Bawarchi 1")
        : (cartManager.activeStoreArea != null ? "Instamart • ${cartManager.activeStoreArea}" : "Instamart Hub");
    final vendorSub = isBite ? "Saket, Delhi • 25-35 mins" : "Fast delivery • 10-15 mins";

    final grandTotal = cartManager.grandTotal;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Your Cart", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A))),
        actions: [
          TextButton(
            onPressed: () {
              cartManager.clear();
              Navigator.pop(context);
            },
            child: const Text("Clear", style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Segmented Tabs: Bite (1) / Instamart (0) (Screen 5)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isBite ? const Color(0xFF4F46E5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Bite (${isBite ? cartManager.totalCount : 0})",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isBite ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !isBite ? const Color(0xFF10B981) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Instamart (${!isBite ? cartManager.totalCount : 0})",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: !isBite ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Store Header + Items List (Screen 5)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Info Row
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        ItemImageHelper.getBannerForRestaurant(vendorTitle),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 40,
                          height: 40,
                          color: const Color(0xFFEEF2FF),
                          child: const Icon(Icons.restaurant, color: Color(0xFF4F46E5), size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vendorTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                          Text(vendorSub, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Cart Items
                ...cartManager.items.values.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        ItemImageWidget(
                          imageUrl: item.imageUrl,
                          itemName: item.itemName,
                          isGrocery: cartManager.orderType == "Grocery",
                          width: 55,
                          height: 55,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
                              const SizedBox(height: 3),
                              Text("₹${(item.price * item.quantity).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                        // Stepper: [ - 1 + ] (Screen 5)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => cartManager.decrementItem(item.itemName),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Text("—", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                              ),
                              InkWell(
                                onTap: () => cartManager.addItem(
                                  itemName: item.itemName,
                                  price: item.price,
                                  isVeg: item.isVeg,
                                  imageUrl: item.imageUrl,
                                  restId: cartManager.activeRestId,
                                  restName: cartManager.activeRestName,
                                  storeId: cartManager.activeStoreId,
                                  storeArea: cartManager.activeStoreArea,
                                  type: cartManager.orderType,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Text("+", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Add more items link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("+ Add more items", style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Apply Coupon Tile (Screen 5)
          GestureDetector(
            onTap: _showCouponDialog,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  const Text("🎟️", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cartManager.appliedCoupon != null
                          ? "Coupon '${cartManager.appliedCoupon}' Applied (Saved ₹${cartManager.discountAmount.toStringAsFixed(0)})"
                          : "Apply Coupon",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: cartManager.appliedCoupon != null ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Bill Details (Screen 5)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Bill Details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _billRow("Item Total", "₹${cartManager.subtotal.toStringAsFixed(2)}"),
                _billRow("Delivery Fee", cartManager.deliveryFee == 0 ? "FREE" : "₹${cartManager.deliveryFee.toStringAsFixed(2)}"),
                _billRow("Platform Fee", "₹5.00"),
                _billRow("Taxes & Charges", "₹${cartManager.taxes.toStringAsFixed(2)}"),
                if (cartManager.discountAmount > 0)
                  _billRow("Discount", "- ₹${cartManager.discountAmount.toStringAsFixed(2)}", isDiscount: true),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Grand Total", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    Text("₹${(grandTotal + 5.0).toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sticky Bottom Proceed CTA (Screen 5)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () => setState(() => _checkoutStep = 1),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Proceed to Checkout", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 6: CHECKOUT
  // ===========================================================================
  Widget _buildCheckoutScreen() {
    final isBite = cartManager.orderType == "Restaurant";
    final vendorTitle = isBite
        ? (cartManager.activeRestName ?? "BBQ Bawarchi 1")
        : (cartManager.activeStoreArea != null ? "Instamart • ${cartManager.activeStoreArea}" : "Instamart Hub");
    final grandTotal = cartManager.grandTotal + 5.0; // including platform fee

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => setState(() => _checkoutStep = 0),
        ),
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Delivery Address Card (Screen 6)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Delivery Address", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    InkWell(
                      onTap: _showAddressPicker,
                      child: const Text("Change", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.home_outlined, size: 20, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartManager.deliveryAddress.contains("•")
                                ? cartManager.deliveryAddress.split("•").first.trim()
                                : "Home",
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cartManager.deliveryAddress.contains("•")
                                ? cartManager.deliveryAddress.split("•").last.trim()
                                : cartManager.deliveryAddress,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Delivery Instructions (Screen 6)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Delivery Instructions", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 6),
                TextField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    hintText: "e.g. Gate code, floor, landmark",
                    hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Order Summary Card (Screen 6)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Order Summary", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        ItemImageHelper.getBannerForRestaurant(vendorTitle),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: const Color(0xFFEEF2FF),
                          child: const Icon(Icons.fastfood, color: Color(0xFF4F46E5), size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vendorTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
                          Text("${cartManager.totalCount} items", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("₹${cartManager.subtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("20% OFF", style: TextStyle(color: Color(0xFF16A34A), fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Apply Coupon (Screen 6)
          GestureDetector(
            onTap: _showCouponDialog,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  const Text("🎟️", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cartManager.appliedCoupon != null ? "Coupon '${cartManager.appliedCoupon}' Applied" : "Apply Coupon",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: cartManager.appliedCoupon != null ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 5. Payment Method (Screen 6)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Payment Method", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),

                // BiteHub Pay (Screen 6)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: "BiteHub Pay",
                  groupValue: _selectedPayment,
                  activeColor: const Color(0xFF4F46E5),
                  title: Row(
                    children: [
                      const Text("BiteHub Pay", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                      const SizedBox(width: 8),
                      Text("Balance: ₹450.00", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                  onChanged: (v) => setState(() => _selectedPayment = v!),
                ),

                // UPI (Screen 6)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: "UPI",
                  groupValue: _selectedPayment,
                  activeColor: const Color(0xFF4F46E5),
                  title: const Row(
                    children: [
                      Text("UPI", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                      SizedBox(width: 10),
                      Text("GPay • PhonePe • Paytm", style: TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  onChanged: (v) => setState(() => _selectedPayment = v!),
                ),

                // Credit / Debit Card (Screen 6)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: "Credit / Debit Card",
                  groupValue: _selectedPayment,
                  activeColor: const Color(0xFF4F46E5),
                  title: const Text("Credit / Debit Card", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                  onChanged: (v) => setState(() => _selectedPayment = v!),
                ),

                // Cash on Delivery (Screen 6)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: "Cash on Delivery",
                  groupValue: _selectedPayment,
                  activeColor: const Color(0xFF4F46E5),
                  title: const Text("Cash on Delivery", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                  onChanged: (v) => setState(() => _selectedPayment = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),

      // Sticky Bottom Bar: Grand Total on left + Place Order button on right (Screen 6)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("₹${grandTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                  const Text("Grand Total", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _handlePlaceOrder,
                child: _isSubmitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Place Order", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDiscount ? const Color(0xFF10B981) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

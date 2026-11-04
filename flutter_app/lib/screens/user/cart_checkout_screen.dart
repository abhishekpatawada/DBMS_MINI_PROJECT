import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cart_manager.dart';
import '../../services/api_service.dart';
import '../../utils/item_image_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';
import 'order_tracking_screen.dart';

class CartCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CartCheckoutScreen({super.key, required this.userData});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  // 0: Your Cart, 1: Checkout
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
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          border: Border(
            top: BorderSide(color: AppTheme.black, width: 3.5),
            left: BorderSide(color: AppTheme.black, width: 3.5),
            right: BorderSide(color: AppTheme.black, width: 3.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SELECT DELIVERY ADDRESS",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.black),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._savedAddresses.map((addr) {
              final isSelected = cartManager.deliveryAddress == addr;
              return GestureDetector(
                onTap: () {
                  cartManager.setDeliveryAddress(addr);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.yellow : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(
                      color: AppTheme.black,
                      width: isSelected ? 2.5 : AppTheme.borderWidth,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: AppTheme.black,
                              offset: Offset(2.5, 2.5),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: AppTheme.black,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addr.split("•").first.trim().toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: AppTheme.black,
                              ),
                            ),
                            Text(
                              addr.split("•").last.trim(),
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 11,
                                color: const Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 6),
            BrutalistButton.white(
              text: "+ ADD NEW ADDRESS",
              fullWidth: true,
              onPressed: () {
                Navigator.pop(ctx);
                _showAddCustomAddressDialog();
              },
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
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(color: AppTheme.black, width: 3),
        ),
        title: Text(
          "ADD DELIVERY ADDRESS",
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            color: AppTheme.black,
          ),
        ),
        content: TextField(
          controller: customAddrController,
          maxLines: 2,
          style: GoogleFonts.ibmPlexMono(fontSize: 13),
          decoration: const InputDecoration(
            hintText: "Flat / House No, Street, Area, Pincode",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "CANCEL",
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
          ),
          BrutalistButton.yellow(
            text: "SAVE ADDRESS",
            height: 40,
            onPressed: () {
              final text = customAddrController.text.trim();
              if (text.isNotEmpty) {
                final full = "Home • $text";
                setState(() => _savedAddresses.add(full));
                cartManager.setDeliveryAddress(full);
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showCouponDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          border: Border(
            top: BorderSide(color: AppTheme.black, width: 3.5),
            left: BorderSide(color: AppTheme.black, width: 3.5),
            right: BorderSide(color: AppTheme.black, width: 3.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "APPLY DISCOUNT COUPON",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.black),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _couponOption("FEAST20", "FLAT 20% OFF ON ORDERS OVER ₹249", "Valid across all restaurants"),
            _couponOption("BITE100", "₹100 OFF FOR FIRST-TIME USERS", "Minimum cart ₹399"),
            _couponOption("INSTA50", "₹50 OFF ON INSTAMART GROCERIES", "Valid on 10-min groceries"),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _couponOption(String code, String desc, String sub) {
    return BrutalistCard(
      bgColor: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      shadowOffset: const Offset(2.5, 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: GoogleFonts.ibmPlexMono(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.black,
                  ),
                ),
                Text(
                  sub,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          BrutalistButton.yellow(
            text: "APPLY",
            height: 36,
            onPressed: () {
              cartManager.applyCoupon(code);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "COUPON '$code' APPLIED // SAVED ₹${cartManager.discountAmount.toStringAsFixed(0)}",
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.black,
                    ),
                  ),
                  backgroundColor: AppTheme.green,
                ),
              );
            },
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
          SnackBar(
            content: Text(
              "ORDER CONFIRMED #$orderId // DISPATCHING",
              style: GoogleFonts.ibmPlexMono(
                fontWeight: FontWeight.w900,
                color: AppTheme.black,
              ),
            ),
            backgroundColor: AppTheme.green,
            duration: const Duration(seconds: 2),
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
            backgroundColor: AppTheme.red,
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
            backgroundColor: AppTheme.bg,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "YOUR CART",
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppTheme.black,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: BrutalistCard(
                  bgColor: AppTheme.surface,
                  padding: const EdgeInsets.all(32),
                  shadowOffset: const Offset(6, 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.yellow,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          border: Border.all(
                            color: AppTheme.black,
                            width: AppTheme.borderWidth,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.black,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.remove_shopping_cart_rounded,
                              size: 40, color: AppTheme.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "CART IS EMPTY",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Explore top restaurants or 10-minute groceries to begin.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 24),
                      BrutalistButton.yellow(
                        text: "BROWSE CATALOG →",
                        fullWidth: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return _checkoutStep == 0 ? _buildCartScreen() : _buildCheckoutScreen();
      },
    );
  }

  // ===========================================================================
  // SCREEN 5: YOUR CART (BRUTALIST REDESIGN)
  // ===========================================================================
  Widget _buildCartScreen() {
    final isBite = cartManager.orderType == "Restaurant";
    final vendorTitle = isBite
        ? (cartManager.activeRestName ?? "Restaurant Partner")
        : (cartManager.activeStoreArea != null
            ? "Instamart • ${cartManager.activeStoreArea}"
            : "Instamart Dark Store Hub");
    final vendorSub =
        isBite ? "Gourmet dining • 25-35 mins" : "Direct hub dispatch • 10-15 mins";
    final grandTotal = cartManager.grandTotal;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "YOUR CART",
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppTheme.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                cartManager.clear();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: AppTheme.black, width: 2),
                ),
                child: Text(
                  "CLEAR",
                  style: GoogleFonts.ibmPlexMono(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: AppTheme.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Order Type Segment Tabs
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: AppTheme.black,
                width: AppTheme.borderWidth,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.black,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isBite ? AppTheme.yellow : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "FOOD (${isBite ? cartManager.totalCount : 0})",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ),
                Container(width: AppTheme.borderWidth, height: 38, color: AppTheme.black),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !isBite ? AppTheme.yellow : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "INSTAMART (${!isBite ? cartManager.totalCount : 0})",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vendor & Items Card
          BrutalistCard(
            bgColor: AppTheme.surface,
            padding: const EdgeInsets.all(16),
            shadowOffset: const Offset(4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isBite ? AppTheme.yellow : AppTheme.green,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        border: Border.all(color: AppTheme.black, width: 2),
                      ),
                      child: Icon(
                        isBite ? Icons.restaurant_rounded : Icons.bolt_rounded,
                        color: AppTheme.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendorTitle.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w900,
                              fontSize: 14.5,
                              color: AppTheme.black,
                            ),
                          ),
                          Text(
                            vendorSub,
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 10.5,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 2.0, color: AppTheme.black),
                const SizedBox(height: 14),

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
                          width: 52,
                          height: 52,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.itemName,
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: AppTheme.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹${(item.price * item.quantity).toStringAsFixed(2)}",
                                style: GoogleFonts.ibmPlexMono(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: AppTheme.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Stepper: [ - QTY + ]
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius),
                            border: Border.all(color: AppTheme.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: AppTheme.black,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () =>
                                    cartManager.decrementItem(item.itemName),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text("—",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          color: AppTheme.black)),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  "${item.quantity}",
                                  style: GoogleFonts.ibmPlexMono(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: AppTheme.black,
                                  ),
                                ),
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
                                child: Container(
                                  color: AppTheme.yellow,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: const Text("+",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: AppTheme.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Add more items button
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "+ ADD MORE ITEMS",
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Coupon Tile
          BrutalistCard(
            bgColor: cartManager.appliedCoupon != null
                ? AppTheme.yellow
                : AppTheme.surface,
            padding: const EdgeInsets.all(14),
            shadowOffset: const Offset(3, 3),
            onTap: _showCouponDialog,
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_outlined,
                    color: AppTheme.black, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cartManager.appliedCoupon != null
                        ? "COUPON '${cartManager.appliedCoupon}' ACTIVE // SAVED ₹${cartManager.discountAmount.toStringAsFixed(0)}"
                        : "APPLY DISCOUNT COUPON",
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      color: AppTheme.black,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AppTheme.black),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bill Details
          BrutalistCard(
            bgColor: AppTheme.surface,
            padding: const EdgeInsets.all(16),
            shadowOffset: const Offset(4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BILL DETAILS",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 10),
                Container(height: 2.0, color: AppTheme.black),
                const SizedBox(height: 10),
                _billRow("ITEM TOTAL",
                    "₹${cartManager.subtotal.toStringAsFixed(2)}"),
                _billRow("DELIVERY FEE",
                    cartManager.deliveryFee == 0
                        ? "FREE"
                        : "₹${cartManager.deliveryFee.toStringAsFixed(2)}"),
                _billRow("PLATFORM FEE", "₹5.00"),
                _billRow("TAXES & CHARGES",
                    "₹${cartManager.taxes.toStringAsFixed(2)}"),
                if (cartManager.discountAmount > 0)
                  _billRow("DISCOUNT SAVED",
                      "- ₹${cartManager.discountAmount.toStringAsFixed(2)}",
                      isDiscount: true),
                const SizedBox(height: 10),
                Container(height: 2.0, color: AppTheme.black),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "GRAND TOTAL",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.black,
                        ),
                      ),
                      Text(
                        "₹${(grandTotal + 5.0).toStringAsFixed(2)}",
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Proceed to Checkout CTA
          BrutalistButton(
            text: "PROCEED TO CHECKOUT →",
            fullWidth: true,
            onPressed: () => setState(() => _checkoutStep = 1),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 6: CHECKOUT (BRUTALIST REDESIGN)
  // ===========================================================================
  Widget _buildCheckoutScreen() {
    final grandTotal = cartManager.grandTotal + 5.0;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.black),
          onPressed: () => setState(() => _checkoutStep = 0),
        ),
        title: Text(
          "CHECKOUT & PAYMENT",
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppTheme.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Delivery Address Card
          BrutalistCard(
            bgColor: AppTheme.surface,
            padding: const EdgeInsets.all(16),
            shadowOffset: const Offset(3.5, 3.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "DELIVERY ADDRESS",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddressPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.yellow,
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                          border: Border.all(color: AppTheme.black, width: 1.5),
                        ),
                        child: Text(
                          "CHANGE",
                          style: GoogleFonts.ibmPlexMono(
                            fontWeight: FontWeight.w900,
                            fontSize: 10.5,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 20, color: AppTheme.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartManager.deliveryAddress.contains("•")
                                ? cartManager.deliveryAddress
                                    .split("•")
                                    .first
                                    .trim()
                                    .toUpperCase()
                                : "HOME",
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: AppTheme.black,
                            ),
                          ),
                          Text(
                            cartManager.deliveryAddress.contains("•")
                                ? cartManager.deliveryAddress
                                    .split("•")
                                    .last
                                    .trim()
                                : cartManager.deliveryAddress,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF555555),
                            ),
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

          // 2. Delivery Instructions
          BrutalistCard(
            bgColor: AppTheme.surface,
            padding: const EdgeInsets.all(14),
            shadowOffset: const Offset(3.5, 3.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DELIVERY INSTRUCTIONS",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _instructionsController,
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: "e.g. Leave with security, gate code, ring bell",
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Payment Method Card
          BrutalistCard(
            bgColor: AppTheme.surface,
            padding: const EdgeInsets.all(16),
            shadowOffset: const Offset(4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SELECT PAYMENT METHOD",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 10),
                Container(height: 2.0, color: AppTheme.black),
                const SizedBox(height: 10),

                // Payment Options
                _paymentTile("BiteHub Pay", "WALLET BALANCE: ₹450.00",
                    Icons.account_balance_wallet_rounded),
                _paymentTile("UPI", "GPAY • PHONEPE • PAYTM",
                    Icons.qr_code_scanner_rounded),
                _paymentTile("Credit / Debit Card", "VISA • MASTERCARD • RUPAY",
                    Icons.credit_card_rounded),
                _paymentTile("Cash on Delivery", "PAY CASH / UPI ON ARRIVAL",
                    Icons.payments_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),

      // Sticky Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: AppTheme.black,
          border: Border(
            top: BorderSide(
              color: AppTheme.black,
              width: AppTheme.borderWidth,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TOTAL PAYABLE",
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.yellow,
                    ),
                  ),
                  Text(
                    "₹${grandTotal.toStringAsFixed(2)}",
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppTheme.surface,
                    ),
                  ),
                ],
              ),
              _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppTheme.yellow,
                        strokeWidth: 2.5,
                      ),
                    )
                  : BrutalistButton.yellow(
                      text: "PLACE ORDER ★",
                      onPressed: _handlePlaceOrder,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(String title, String subtitle, IconData icon) {
    final isSelected = _selectedPayment == title;

    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: AppTheme.black,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: AppTheme.black,
              size: 18,
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 20, color: AppTheme.black),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: AppTheme.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF555555),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isDiscount ? AppTheme.green : AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}

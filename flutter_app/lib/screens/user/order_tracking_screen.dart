import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/cart_manager.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';
import 'cart_checkout_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> userData;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.userData,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  OrderModel? _order;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService.getOrderDetails(widget.orderId);
      final orderData = res['order'] as Map<String, dynamic>;
      final itemsData = (res['items'] as List<dynamic>?) ?? [];

      if (mounted) {
        setState(() {
          _order = OrderModel.fromJson(orderData);
          _items = itemsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  int _getStatusStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return 0;
      case 'confirmed':
        return 1;
      case 'preparing':
      case 'cooking':
        return 1;
      case 'out for delivery':
      case 'on the way':
        return 2;
      case 'delivered':
        return 3;
      case 'cancelled':
        return -1;
      default:
        return 2;
    }
  }

  void _reorderDishes() {
    if (_items.isEmpty) return;
    cartManager.clear();

    final isRestaurant = _order?.orderType.toLowerCase() == "restaurant";
    for (final item in _items) {
      final itemName =
          item['Item_Name']?.toString() ?? item['name']?.toString() ?? 'Dish';
      final itemPrice = double.tryParse(item['Item_Price']?.toString() ??
              item['price']?.toString() ??
              '100') ??
          100.0;
      final qty = int.tryParse(item['Quantity']?.toString() ??
              item['Food_quantity']?.toString() ??
              '1') ??
          1;

      for (int i = 0; i < qty; i++) {
        cartManager.addItem(
          itemName: itemName,
          price: itemPrice,
          isVeg: item['Is_Veg'] == 1 || item['Is_Veg'] == true,
          imageUrl: item['Image_Url']?.toString(),
          restId: _order?.restId,
          restName: _order?.restName,
          storeId: _order?.storeId,
          storeArea: _order?.storeArea,
          type: isRestaurant ? "Restaurant" : "Grocery",
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "ITEMS ADDED TO CART // REORDER ACTIVE",
          style: GoogleFonts.ibmPlexMono(
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
          ),
        ),
        backgroundColor: AppTheme.green,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartCheckoutScreen(userData: widget.userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "TRACK ORDER #${widget.orderId}",
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppTheme.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "DISPATCH SUPPORT ALERTED FOR ORDER #${widget.orderId}",
                        style: GoogleFonts.ibmPlexMono(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.black,
                        ),
                      ),
                      backgroundColor: AppTheme.yellow,
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: Text(
                    "HELP",
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      color: AppTheme.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.black,
                strokeWidth: 3,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: BrutalistCard(
                      bgColor: AppTheme.surface,
                      padding: const EdgeInsets.all(24),
                      shadowOffset: const Offset(5, 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppTheme.red, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexMono(
                              color: AppTheme.red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BrutalistButton.white(
                            text: "RETRY FETCH",
                            onPressed: _fetchOrderDetails,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : _buildTrackingContent(),
    );
  }

  Widget _buildTrackingContent() {
    final status = _order?.orderStatus ?? "On the way";
    final isDelivered = status.toLowerCase() == "delivered";
    final isCancelled = status.toLowerCase() == "cancelled";
    final stepIndex = _getStatusStepIndex(status);
    final vendorTitle = _order?.restName ??
        (_order?.storeArea != null
            ? "Dark Store #${_order?.storeId}"
            : "Direct Hub Partner");

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Order Status & Estimated Arrival Card
        BrutalistCard(
          bgColor: AppTheme.surface,
          padding: const EdgeInsets.all(18),
          shadowOffset: const Offset(4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendorTitle.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "ORDER #${widget.orderId} • ${_order?.orderDate ?? 'LIVE SESSION'}",
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  BrutalistBadge(
                    label: isCancelled
                        ? "CANCELLED"
                        : isDelivered
                            ? "DELIVERED"
                            : "ON THE WAY",
                    bgColor: isCancelled
                        ? AppTheme.red
                        : isDelivered
                            ? AppTheme.green
                            : AppTheme.yellow,
                    textColor:
                        isCancelled ? AppTheme.surface : AppTheme.black,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 2.0, color: AppTheme.black),
              const SizedBox(height: 14),

              Text(
                "ESTIMATED DELIVERY WINDOW",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF666666),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: AppTheme.black, size: 26),
                  const SizedBox(width: 4),
                  Text(
                    isDelivered
                        ? "DELIVERED!"
                        : isCancelled
                            ? "ORDER CANCELLED"
                            : "8-12 MINS",
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Step Tracker
              _buildHorizontalStepTracker(stepIndex),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Illustrated Map Route Frame
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: AppTheme.black,
              width: AppTheme.borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.black,
                offset: Offset(3.5, 3.5),
                blurRadius: 0,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapRoutePainter(),
                ),
              ),
              // Restaurant Start Pin
              Positioned(
                top: 36,
                left: 40,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: AppTheme.black, size: 16),
                ),
              ),
              // Live Rider Pin
              Positioned(
                top: 75,
                left: 140,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.blue,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: const Icon(Icons.electric_moped_rounded,
                      color: AppTheme.surface, size: 18),
                ),
              ),
              // Destination Home Pin
              Positioned(
                bottom: 30,
                right: 40,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.green,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: AppTheme.black, size: 16),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. Rider Info Card
        BrutalistCard(
          bgColor: AppTheme.surface,
          padding: const EdgeInsets.all(14),
          shadowOffset: const Offset(3.5, 3.5),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: AppTheme.black, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.delivery_dining_rounded,
                      color: AppTheme.black, size: 26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DISPATCH COURIER",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: AppTheme.black,
                      ),
                    ),
                    Text(
                      _order?.agentName != null
                          ? "${_order!.agentName} • ${_order?.agentVehicle ?? 'KA-05-AB-1234'}"
                          : "Arjun • KA-05-AB-1234",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("DIALING RIDER: +91 9876543210"),
                      backgroundColor: AppTheme.black,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.green,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: const Icon(Icons.phone_rounded,
                      size: 18, color: AppTheme.black),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("OPENING LIVE COURIER CHAT..."),
                      backgroundColor: AppTheme.black,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: const Icon(Icons.chat_bubble_rounded,
                      size: 18, color: AppTheme.black),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. Delivery Address Card
        BrutalistCard(
          bgColor: AppTheme.surface,
          padding: const EdgeInsets.all(14),
          shadowOffset: const Offset(3.5, 3.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppTheme.black, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DELIVERING TO",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _order?.deliveryAddr != null &&
                              _order!.deliveryAddr!.isNotEmpty
                          ? (_order!.deliveryAddr!.contains('•')
                              ? _order!.deliveryAddr!.split('•').last.trim()
                              : _order!.deliveryAddr!)
                          : "14 MG Road, Indiranagar, Bengaluru",
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 5. Items Receipt
        BrutalistCard(
          bgColor: AppTheme.surface,
          padding: const EdgeInsets.all(16),
          shadowOffset: const Offset(4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ORDER ITEMS (${_items.length})",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 2.0, color: AppTheme.black),
              const SizedBox(height: 10),
              ..._items.map((it) {
                final name = it['Item_Name']?.toString() ??
                    it['name']?.toString() ??
                    'Item';
                final qty = it['Quantity']?.toString() ??
                    it['Food_quantity']?.toString() ??
                    '1';
                final price = double.tryParse(it['Item_Price']?.toString() ??
                        it['price']?.toString() ??
                        '0') ??
                    0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$qty x $name",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.black,
                        ),
                      ),
                      Text(
                        "₹${(price * (int.tryParse(qty) ?? 1)).toStringAsFixed(2)}",
                        style: GoogleFonts.ibmPlexMono(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              Container(height: 2.0, color: AppTheme.black),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TOTAL PAID",
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppTheme.black,
                    ),
                  ),
                  Text(
                    "₹${_order?.totalAmount.toStringAsFixed(2) ?? '0.00'}",
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Cancel Button (if active)
        if (!isDelivered && !isCancelled) ...[
          BrutalistButton.red(
            text: "CANCEL ORDER",
            icon: Icons.cancel_rounded,
            fullWidth: true,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    side: const BorderSide(color: AppTheme.black, width: 3),
                  ),
                  title: Text(
                    "CANCEL ORDER #${widget.orderId}?",
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.black,
                    ),
                  ),
                  content: Text(
                    "Are you sure you want to cancel this live order?",
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        "KEEP ORDER",
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                    BrutalistButton.red(
                      text: "CONFIRM CANCEL",
                      height: 40,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  final ok = await ApiService.updateOrderStatus(
                      widget.orderId, "Cancelled");
                  if (mounted) {
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "ORDER #${widget.orderId} CANCELLED",
                            style: GoogleFonts.ibmPlexMono(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.surface,
                            ),
                          ),
                          backgroundColor: AppTheme.red,
                        ),
                      );
                    }
                    _fetchOrderDetails();
                  }
                } catch (_) {}
              }
            },
          ),
          const SizedBox(height: 12),
        ],

        // Reorder Button
        BrutalistButton.yellow(
          text: "REORDER THESE ITEMS ★",
          fullWidth: true,
          onPressed: _reorderDishes,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Step Tracker with Brutalist Milestones
  Widget _buildHorizontalStepTracker(int currentStep) {
    final steps = ["PLACED", "PREPARING", "ON THE WAY", "DELIVERED"];

    return Row(
      children: List.generate(steps.length, (i) {
        final isCompleted = currentStep > i;
        final isCurrent = currentStep == i;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i == 0
                          ? Colors.transparent
                          : (currentStep >= i
                              ? AppTheme.black
                              : const Color(0xFFCCCCCC)),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.green
                          : isCurrent
                              ? AppTheme.yellow
                              : AppTheme.surface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                      border: Border.all(color: AppTheme.black, width: 2),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: AppTheme.black)
                          : isCurrent
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.black,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i == steps.length - 1
                          ? Colors.transparent
                          : (currentStep > i
                              ? AppTheme.black
                              : const Color(0xFFCCCCCC)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[i],
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 9.5,
                  fontWeight:
                      isCurrent || isCompleted ? FontWeight.w900 : FontWeight.w600,
                  color: isCurrent
                      ? AppTheme.black
                      : isCompleted
                          ? const Color(0xFF333333)
                          : const Color(0xFF888888),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF111111).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final routePaint = Paint()
      ..color = AppTheme.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final path = Path()
      ..moveTo(48, 48)
      ..lineTo(148, 86)
      ..lineTo(size.width - 48, size.height - 40);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

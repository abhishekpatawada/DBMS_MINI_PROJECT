import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/cart_manager.dart';
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
      final itemName = item['Item_Name']?.toString() ?? item['name']?.toString() ?? 'Dish';
      final itemPrice = double.tryParse(item['Item_Price']?.toString() ?? item['price']?.toString() ?? '100') ?? 100.0;
      final qty = int.tryParse(item['Quantity']?.toString() ?? item['Food_quantity']?.toString() ?? '1') ?? 1;

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
      const SnackBar(
        content: Text("Items added to your cart!"),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Track Order",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Support team will contact you shortly.")),
              );
            },
            child: const Text("Help", style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("⚠️", style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchOrderDetails,
                          child: const Text("Retry"),
                        ),
                      ],
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
    final vendorTitle = _order?.restName ?? (_order?.storeArea != null ? "Dark Store #${_order?.storeId}" : "Royal Palace 1");

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Order Status & Estimated Arrival Card (Screen 7)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
                          vendorTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Order #${widget.orderId} • ${_order?.orderDate ?? '16 Oct 2026, 10:22 PM'}",
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? const Color(0xFFFEE2E2)
                          : isDelivered
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isCancelled ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isCancelled ? "Cancelled" : isDelivered ? "Delivered" : "On the way",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCancelled ? const Color(0xFFDC2626) : const Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text("Estimated arrival", style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 24),
                  const SizedBox(width: 4),
                  Text(
                    isDelivered ? "Delivered!" : isCancelled ? "Order Cancelled" : "8 mins",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Horizontal Step Tracker (Screen 7: Placed, Preparing, On the way, Delivered)
              _buildHorizontalStepTracker(stepIndex),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Illustrated Map Route Container (Screen 7)
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Map background grid illustration
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapRoutePainter(),
                ),
              ),
              // Restaurant Start Pin
              Positioned(
                top: 36,
                left: 40,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
              // Live Rider Pin
              Positioned(
                top: 75,
                left: 140,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 16),
                ),
              ),
              // Destination Home Pin
              Positioned(
                bottom: 30,
                right: 40,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.home, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. Rider Info Card with Call & Chat (Screen 7)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Icon(Icons.delivery_dining_rounded, color: Color(0xFF4F46E5), size: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rider is on the way",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _order?.agentName != null ? "${_order!.agentName} • ${_order?.agentVehicle ?? 'KA-05-AB-1234'}" : "Arjun • KA-05-AB-1234",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // Call Button
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFECFDF5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Calling rider: 9876543210")),
                  );
                },
              ),
              const SizedBox(width: 6),
              // Chat Button
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF2FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF4F46E5), size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Opening live rider chat...")),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. Delivery Address Card (Screen 7)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF4F46E5), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Delivery Address", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    const Text("Home", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(
                      _order?.deliveryAddr != null && _order!.deliveryAddr!.isNotEmpty
                          ? (_order!.deliveryAddr!.contains('•') ? _order!.deliveryAddr!.split('•').last.trim() : _order!.deliveryAddr!)
                          : "14 MG Road, Indiranagar, Bengaluru",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 5. Items Summary Card
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
              const Text("Items in this order", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 10),
              ..._items.map((it) {
                final name = it['Item_Name']?.toString() ?? it['name']?.toString() ?? 'Item';
                final qty = it['Quantity']?.toString() ?? it['Food_quantity']?.toString() ?? '1';
                final price = double.tryParse(it['Item_Price']?.toString() ?? it['price']?.toString() ?? '0') ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$qty x $name", style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                      Text("₹${(price * (int.tryParse(qty) ?? 1)).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                );
              }),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Paid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                  Text(
                    "₹${_order?.totalAmount.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF4F46E5)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        if (!isDelivered && !isCancelled) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text("Cancel This Order", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text("Cancel Order?", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: Text("Are you sure you want to cancel Order #${widget.orderId}?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Keep Order", style: TextStyle(color: Color(0xFF64748B))),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Cancel Order"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    final ok = await ApiService.updateOrderStatus(widget.orderId, "Cancelled");
                    if (mounted) {
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Order #${widget.orderId} cancelled."),
                            backgroundColor: const Color(0xFFDC2626),
                          ),
                        );
                      }
                      _fetchOrderDetails();
                    }
                  } catch (_) {}
                }
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Reorder Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _reorderDishes,
          child: const Text("Reorder These Items", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Horizontal Step Tracker (Screen 7)
  Widget _buildHorizontalStepTracker(int currentStep) {
    final steps = [
      {"label": "Placed", "sub": "10:22 PM"},
      {"label": "Preparing", "sub": ""},
      {"label": "On the way", "sub": ""},
      {"label": "Delivered", "sub": ""},
    ];

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
                      color: i == 0 ? Colors.transparent : (currentStep >= i ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : isCurrent
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 13, color: Colors.white)
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isCurrent ? Colors.white : const Color(0xFF94A3B8),
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i == steps.length - 1 ? Colors.transparent : (currentStep > i ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[i]["label"]!,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent
                      ? const Color(0xFF4F46E5)
                      : isCompleted
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                ),
                textAlign: TextAlign.center,
              ),
              if (steps[i]["sub"]!.isNotEmpty)
                Text(
                  steps[i]["sub"]!,
                  style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// Custom Painter to draw stylized map street grid and curved delivery path
class _MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE2E8F0));
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Draw some horizontal and vertical roads
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), roadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), roadPaint);

    // Draw Route line in Indigo
    final routePaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(48, 48);
    path.lineTo(size.width * 0.3, 48);
    path.lineTo(size.width * 0.3, size.height * 0.55);
    path.lineTo(size.width * 0.7, size.height * 0.55);
    path.lineTo(size.width * 0.7, size.height - 40);
    path.lineTo(size.width - 48, size.height - 40);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

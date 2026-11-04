import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../auth_screen.dart';
import '../../utils/item_image_helper.dart';
import '../../widgets/server_config_dialog.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> restaurantData;

  const RestaurantDashboardScreen({super.key, required this.restaurantData});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  late int _restId;
  late String _restName;
  late String _restLocation;
  late String _restPhone;

  int _selectedNavIndex = 0; // 0: Dashboard, 1: Menu Management, 2: Orders, 3: Payouts, 4: Analytics, 5: Customers, 6: Settings

  // State filters
  String _revenueTimeFilter = "Today"; // Today, 7 Days, 30 Days, All Time
  String _chartFrequency = "Daily"; // Daily, Weekly, Monthly
  String _menuSearchQuery = "";
  String _selectedMenuCategory = "All";
  String _orderStatusFilter = "All"; // All, Placed, Preparing, Ready, Delivered, Cancelled
  bool _autoAcceptOrders = false;
  bool _isStoreOpen = true;
  bool _kotSound = true;
  int _prepTime = 25;

  // Best Sellers & Top Customers Analytics state
  Map<String, dynamic>? _analyticsData;
  String _analyticsDishSort = "Volume"; // Volume, Revenue, Veg, Non-Veg
  String _customerSort = "Orders"; // Orders, Spend, Recent
  String _dishSearchQuery = "";
  String _customerSearchQuery = "";

  List<RestaurantItemModel> _menuItems = [];
  List<OrderModel> _incomingOrders = [];
  bool _isLoading = true;

  final Map<String, bool> _itemAvailability = {};

  DateTime _selectedDate = DateTime(2026, 10, 16);

  String _getDayName(int weekday) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[(weekday - 1) % 7];
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[(month - 1) % 12];
  }

  Future<void> _pickDashboardDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2028),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Date set to ${_getDayName(picked.weekday)}, ${_getMonthName(picked.month)} ${picked.day}, ${picked.year}"),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showRestaurantNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: Color(0xFF4F46E5), size: 24),
            SizedBox(width: 10),
            Text("Kitchen & Order Alerts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.restaurant_rounded, color: Color(0xFF4F46E5), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("New Live Order Received", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF312E81))),
                        Text("Order #206 (3 items) placed by Aarav Choudhury.", style: TextStyle(fontSize: 11, color: Color(0xFF4338CA))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("KOT Printer Connected", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46))),
                        Text("Kitchen display system is synced and operational.", style: TextStyle(fontSize: 11, color: Color(0xFF047857))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _selectedNavIndex = 2); // Go to Live Orders
            },
            child: const Text("View Orders"),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context, String name, String phone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
              child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF4F46E5), size: 32),
            ),
            const SizedBox(height: 14),
            Text("Contact $name", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(phone, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.message_outlined, size: 18),
                    label: const Text("Send SMS"),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("SMS composer opened for $phone")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text("Dial Now"),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Calling $name at $phone..."), backgroundColor: const Color(0xFF10B981)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderItemsDialog(BuildContext context, OrderModel ord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order #${ord.orderId} Kitchen Ticket", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    Text("Customer: ${ord.userName ?? 'Customer'} • ${ord.userPhone ?? ''}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=100&auto=format&fit=crop&q=60",
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: Color(0xFF4F46E5)),
                ),
              ),
              title: Text(ord.orderId == 206 ? "Chicken Biryani Special" : "Paneer Butter Masala", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(ord.orderId == 206 ? "Quantity: 3 items (With Extra Raita & Salan)" : "Quantity: 1 (Medium Spicy)", style: const TextStyle(fontSize: 12)),
              trailing: Text(
                "₹${ord.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Order Value (Paid via UPI)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                Text("₹${ord.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.print_outlined),
                label: const Text("Print Kitchen Order Ticket (KOT)"),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("KOT ticket sent to kitchen printer for Order #${ord.orderId}"), backgroundColor: const Color(0xFF4F46E5)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initRestData();
    _loadData();
  }

  void _initRestData() {
    _restId = widget.restaurantData['Rest_Id'] ?? widget.restaurantData['restId'] ?? 1;
    _restName = widget.restaurantData['RName'] ?? widget.restaurantData['rname'] ?? 'Royal Palace 1';
    _restLocation = widget.restaurantData['RLocation'] ?? widget.restaurantData['rlocation'] ?? 'Indiranagar, Karnataka';
    _restPhone = widget.restaurantData['RPhone'] ?? widget.restaurantData['rphone'] ?? '9876543210';
  }

  List<RestaurantItemModel> _getMockMenuItems() {
    return [
      RestaurantItemModel(
        restId: _restId,
        itemName: "Paneer Butter Masala",
        foodName: "Curry • Main Course",
        isVeg: true,
        basePrice: 280.0,
        discount: 10.0,
        finalPrice: 252.0,
        imageUrl: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=60",
      ),
      RestaurantItemModel(
        restId: _restId,
        itemName: "Vada Pav",
        foodName: "Snacks • Street Food",
        isVeg: true,
        basePrice: 150.0,
        discount: 20.0,
        finalPrice: 120.0,
        imageUrl: "https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=500&auto=format&fit=crop&q=60",
      ),
      RestaurantItemModel(
        restId: _restId,
        itemName: "Masala Dosa",
        foodName: "South Indian • Breakfast",
        isVeg: true,
        basePrice: 90.0,
        discount: 0.0,
        finalPrice: 90.0,
        imageUrl: "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=500&auto=format&fit=crop&q=60",
      ),
      RestaurantItemModel(
        restId: _restId,
        itemName: "Chicken Biryani",
        foodName: "Biryani • Main Course",
        isVeg: false,
        basePrice: 260.0,
        discount: 15.0,
        finalPrice: 220.0,
        imageUrl: "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=60",
      ),
      RestaurantItemModel(
        restId: _restId,
        itemName: "Gulab Jamun",
        foodName: "Dessert",
        isVeg: true,
        basePrice: 60.0,
        discount: 0.0,
        finalPrice: 60.0,
        imageUrl: "https://images.unsplash.com/photo-1596797038530-2c107229654b?w=500&auto=format&fit=crop&q=60",
      ),
      RestaurantItemModel(
        restId: _restId,
        itemName: "Butter Naan",
        foodName: "Breads",
        isVeg: true,
        basePrice: 45.0,
        discount: 0.0,
        finalPrice: 45.0,
        imageUrl: "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=60",
      ),
      RestaurantItemModel(
        restId: _restId,
        itemName: "Mango Lassi",
        foodName: "Beverages",
        isVeg: true,
        basePrice: 80.0,
        discount: 5.0,
        finalPrice: 76.0,
        imageUrl: "https://images.unsplash.com/photo-1527661591475-527312dd65f5?w=500&auto=format&fit=crop&q=60",
      ),
    ];
  }

  List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        orderId: 207,
        userId: 101,
        userName: "Aarav Choudhury",
        userPhone: "9810000100",
        restId: _restId,
        restName: _restName,
        orderType: "Restaurant",
        orderStatus: "Placed",
        totalAmount: 409.20,
        orderDate: "2 mins ago",
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "14 MG Road, Indiranagar, Karnataka - 560038",
      ),
      OrderModel(
        orderId: 206,
        userId: 102,
        userName: "Usha Gupta",
        userPhone: "9810000100",
        agentId: 1,
        agentName: "Siddharth Ahuja",
        agentPhone: "9876543210",
        agentVehicle: "DL-08-GK-1028",
        agentRating: 5.0,
        restId: _restId,
        restName: _restName,
        orderType: "Restaurant",
        orderStatus: "Preparing",
        totalAmount: 1260.00,
        orderDate: "12 mins ago",
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "14 MG Road, Indiranagar, Karnataka - 560038",
      ),
      OrderModel(
        orderId: 205,
        userId: 103,
        userName: "Rahul Verma",
        userPhone: "9876500020",
        agentId: 2,
        agentName: "Krishna Singh",
        agentPhone: "9876500001",
        agentVehicle: "KA-08-DF-1001",
        agentRating: 4.9,
        restId: _restId,
        restName: _restName,
        orderType: "Restaurant",
        orderStatus: "Ready",
        totalAmount: 1260.00,
        orderDate: "18 mins ago",
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "Flat 304, Green Heights, Indiranagar, Karnataka",
      ),
      OrderModel(
        orderId: 201,
        userId: 104,
        userName: "Neha Sharma",
        userPhone: "9811223344",
        restId: _restId,
        restName: _restName,
        orderType: "Restaurant",
        orderStatus: "Delivered",
        totalAmount: 540.00,
        orderDate: "1 hour ago",
        paymentMethod: "Card",
        paymentStatus: "Paid",
        deliveryAddr: "45 CMH Road, Indiranagar, Bangalore",
      ),
      OrderModel(
        orderId: 200,
        userId: 105,
        userName: "Vikram Malhotra",
        userPhone: "9822334455",
        restId: _restId,
        restName: _restName,
        orderType: "Restaurant",
        orderStatus: "Delivered",
        totalAmount: 720.00,
        orderDate: "3 hours ago",
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "100ft Road, Indiranagar, Bangalore",
      ),
    ];
  }

  List<Map<String, dynamic>> _getTopDishes() {
    if (_analyticsData != null && _analyticsData!['top_items'] is List && (_analyticsData!['top_items'] as List).isNotEmpty) {
      return List<Map<String, dynamic>>.from(_analyticsData!['top_items']);
    }
    return [];
  }

  List<Map<String, dynamic>> _getTopCustomers() {
    if (_analyticsData != null && _analyticsData!['top_customers'] is List && (_analyticsData!['top_customers'] as List).isNotEmpty) {
      return List<Map<String, dynamic>>.from(_analyticsData!['top_customers']);
    }
    return [];
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final menu = await ApiService.getRestaurantMenu(_restId);
      final allOrders = await ApiService.getOrders();
      final restOrders = allOrders.where((o) => o.orderType == "Restaurant" && o.restId == _restId).toList();

      Map<String, dynamic>? analytics;
      try {
        analytics = await ApiService.getRestaurantRevenueAnalytics(_restId);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _menuItems = menu;
          _incomingOrders = restOrders;
          _analyticsData = analytics;

          for (var item in _menuItems) {
            _itemAvailability.putIfAbsent(item.itemName, () => true);
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _menuItems = [];
          _incomingOrders = [];
          _isLoading = false;
        });
      }
    }
  }

  void _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await ApiService.updateOrderStatus(orderId, newStatus);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _incomingOrders = _incomingOrders.map((ord) {
          if (ord.orderId == orderId) {
            return OrderModel(
              orderId: ord.orderId,
              userId: ord.userId,
              userName: ord.userName,
              userPhone: ord.userPhone,
              agentId: ord.agentId,
              agentName: ord.agentName,
              agentPhone: ord.agentPhone,
              agentVehicle: ord.agentVehicle,
              agentRating: ord.agentRating,
              restId: ord.restId,
              restName: ord.restName,
              orderType: ord.orderType,
              orderStatus: newStatus,
              totalAmount: ord.totalAmount,
              orderDate: ord.orderDate,
              paymentMethod: ord.paymentMethod,
              paymentStatus: ord.paymentStatus,
              deliveryAddr: ord.deliveryAddress,
            );
          }
          return ord;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text("Order #$orderId moved to '$newStatus'"),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showAddEditDishDialog({RestaurantItemModel? existingItem}) {
    final nameCtrl = TextEditingController(text: existingItem?.itemName ?? "");
    final descCtrl = TextEditingController(text: existingItem?.foodName ?? "");
    final priceCtrl = TextEditingController(text: existingItem != null ? existingItem.basePrice.toStringAsFixed(0) : "250");
    final discountCtrl = TextEditingController(text: existingItem != null ? existingItem.discount.toStringAsFixed(0) : "10");
    bool isVeg = existingItem?.isVeg ?? true;
    String? selectedImageUrl = existingItem?.imageUrl;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existingItem == null ? "Add New Dish" : "Edit Dish",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dish Photo Preview & Picker
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      ItemImageWidget(
                        imageUrl: selectedImageUrl,
                        itemName: nameCtrl.text.isNotEmpty ? nameCtrl.text : "Food Dish",
                        category: descCtrl.text,
                        width: 60,
                        height: 60,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dish Photo",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 6),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                ItemImageHelper.showGalleryPickerModal(
                                  context: context,
                                  isGrocery: false,
                                  currentImageUrl: selectedImageUrl ?? "",
                                  onImageSelected: (url) {
                                    setDialogState(() => selectedImageUrl = url);
                                  },
                                );
                              },
                              child: const Text("Select from Gallery", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (existingItem == null)
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Dish Name *", hintText: "e.g. Paneer Butter Masala"),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Category / Description", hintText: "e.g. Curry • Main Course"),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Base Price (₹) *"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: discountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Discount (%)"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text("Vegetarian (Veg)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: isVeg,
                  activeColor: const Color(0xFF10B981),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setDialogState(() => isVeg = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final basePrice = double.tryParse(priceCtrl.text) ?? 150.0;
                final discount = double.tryParse(discountCtrl.text) ?? 0.0;
                final finalPrice = basePrice * (1.0 - (discount / 100.0));
                final dishName = nameCtrl.text.trim();
                final desc = descCtrl.text.trim();

                if (dishName.isEmpty) return;

                Navigator.pop(ctx);

                try {
                  if (existingItem == null) {
                    await ApiService.addMenuItem(_restId, {
                      "item_name": dishName,
                      "food_name": desc,
                      "is_veg": isVeg,
                      "base_price": basePrice,
                      "discount": discount,
                      "image_url": selectedImageUrl,
                    });
                  } else {
                    await ApiService.updateMenuItem(_restId, existingItem.itemName, {
                      "new_item_name": existingItem.itemName,
                      "food_name": desc,
                      "is_veg": isVeg,
                      "base_price": basePrice,
                      "discount": discount,
                      "image_url": selectedImageUrl,
                    });
                  }
                } catch (_) {}

                setState(() {
                  if (existingItem == null) {
                    _menuItems.insert(
                      0,
                      RestaurantItemModel(
                        restId: _restId,
                        itemName: dishName,
                        foodName: desc,
                        isVeg: isVeg,
                        basePrice: basePrice,
                        discount: discount,
                        finalPrice: finalPrice,
                        imageUrl: selectedImageUrl,
                      ),
                    );
                    _itemAvailability[dishName] = true;
                  } else {
                    final idx = _menuItems.indexWhere((i) => i.itemName == existingItem.itemName);
                    if (idx != -1) {
                      _menuItems[idx] = RestaurantItemModel(
                        restId: _restId,
                        itemName: existingItem.itemName,
                        foodName: desc,
                        isVeg: isVeg,
                        basePrice: basePrice,
                        discount: discount,
                        finalPrice: finalPrice,
                        imageUrl: selectedImageUrl,
                      );
                    }
                  }
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existingItem == null ? "Dish added to menu" : "Dish updated successfully"),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text("Save Dish"),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteDish(String itemName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Dish"),
        content: Text("Are you sure you want to remove '$itemName' from your menu?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteMenuItem(_restId, itemName);
      } catch (_) {}

      setState(() {
        _menuItems.removeWhere((i) => i.itemName == itemName);
        _itemAvailability.remove(itemName);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'$itemName' removed from menu"),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: isLargeScreen ? _buildDesktopLayout() : _buildMobileLayout(),
        );
      },
    );
  }

  // DESKTOP & TABLET LAYOUT (MATCHING REFERENCE EXACTLY)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Sidebar Navigation
        _buildSidebar(),

        // Main Content Area
        Expanded(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(isLargeScreen: true),

              // Page View
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.black))
                    : _buildCurrentView(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MOBILE LAYOUT
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildTopBar(isLargeScreen: false),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.black))
              : _buildCurrentView(),
        ),
        _buildMobileBottomNav(),
      ],
    );
  }

  // SIDEBAR COMPONENT - Brutalism 2.0
  Widget _buildSidebar() {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(right: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.yellow,
                        offset: Offset(2.5, 2.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "B",
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.yellow,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BITEHUB",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "KITCHEN PORTAL",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildSidebarItem(0, Icons.dashboard_outlined, "DASHBOARD"),
                _buildSidebarItem(1, Icons.restaurant_menu_rounded, "MENU MGMT"),
                _buildSidebarItem(2, Icons.receipt_long_outlined, "LIVE ORDERS"),
                _buildSidebarItem(3, Icons.account_balance_wallet_outlined, "PAYOUTS"),
                _buildSidebarItem(4, Icons.bar_chart_rounded, "ANALYTICS"),
                _buildSidebarItem(5, Icons.people_outline_rounded, "CUSTOMERS"),
                _buildSidebarItem(6, Icons.settings_outlined, "SETTINGS"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedNavIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.yellow : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: isSelected ? AppTheme.black : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
            boxShadow: isSelected
                ? const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0)]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppTheme.black,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TOP BAR COMPONENT (Royal Palace 1, Restaurant tag, Live dot, Refresh, Bell, Profile)
  Widget _buildTopBar({required bool isLargeScreen}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Restaurant Thumbnail Image
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.black, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&auto=format&fit=crop&q=60",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppTheme.yellow, child: const Icon(Icons.restaurant, color: AppTheme.black)),
              ),
            ),
            const SizedBox(width: 12),

            // Restaurant Title & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _restName.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.yellow,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(color: AppTheme.black, width: 1.5),
                        ),
                        child: Text(
                          "RESTAURANT",
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _restLocation,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Live",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions on right: Refresh, Notification Bell, Avatar
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22, color: Color(0xFF64748B)),
              tooltip: "Refresh Data",
              onPressed: _loadData,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF64748B)),
                  tooltip: "Notifications",
                  onPressed: () => _showRestaurantNotificationsDialog(context),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),

            // Profile Avatar
            GestureDetector(
              onTap: () => setState(() => _selectedNavIndex = 6), // Open Settings
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _restName.isNotEmpty ? _restName[0].toUpperCase() : "R",
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF334155), fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION FOR MOBILE - Brutalism 2.0
  Widget _buildMobileBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMobileNavItem(0, Icons.dashboard_outlined, "DASHBOARD"),
            _buildMobileNavItem(1, Icons.restaurant_menu_rounded, "MENU"),
            _buildMobileNavItem(2, Icons.receipt_long_outlined, "ORDERS"),
            _buildMobileNavItem(3, Icons.account_balance_wallet_outlined, "PAYOUTS"),
            _buildMobileNavItem(6, Icons.settings_outlined, "SETTINGS"),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: isSelected ? AppTheme.black : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
          boxShadow: isSelected
              ? const [BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0)]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppTheme.black),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CURRENT VIEW SELECTOR
  Widget _buildCurrentView() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildRevenueOverviewView(); // SCREEN 1
      case 1:
        return _buildMenuManagementView(); // SCREEN 2
      case 2:
        return _buildLiveOrdersView(); // SCREEN 3
      case 3:
        return _buildPayoutsView();
      case 4:
        return _buildAnalyticsView();
      case 5:
        return _buildCustomersView();
      case 6:
      default:
        return _buildSettingsView();
    }
  }

  // ==========================================
  // VIEW 1: REVENUE OVERVIEW (LEFT SCREEN)
  // ==========================================
  Widget _buildRevenueOverviewView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Row - Brutalism 2.0
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "REVENUE OVERVIEW",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "SALES, ORDERS & DIRECT SETTLEMENT TELEMETRY",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            // Date picker pill (interactive)
            GestureDetector(
              onTap: () => _pickDashboardDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.black),
                    const SizedBox(width: 8),
                    Text(
                      "${_getMonthName(_selectedDate.month).toUpperCase()} ${_selectedDate.day}, ${_selectedDate.year}",
                      style: GoogleFonts.ibmPlexMono(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.black),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.black),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Time Filters Row (Today, 7 Days, 30 Days, All Time)
        Row(
          children: [
            _buildTimeFilterChip("Today"),
            const SizedBox(width: 8),
            _buildTimeFilterChip("7 Days"),
            const SizedBox(width: 8),
            _buildTimeFilterChip("30 Days"),
            const SizedBox(width: 8),
            _buildTimeFilterChip("All Time"),
          ],
        ),

        const SizedBox(height: 20),

        // 4 KPI Metric Cards in a Grid / Row
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final summary = _analyticsData != null && _analyticsData!['summary'] is Map ? _analyticsData!['summary'] as Map : null;
            final grossVal = (summary != null && summary['total_revenue'] != null)
                ? ((summary['total_revenue'] as num).toDouble())
                : _incomingOrders.fold<double>(0.0, (acc, o) => acc + o.totalAmount);
            final netPayoutVal = (summary != null && summary['net_payout'] != null)
                ? ((summary['net_payout'] as num).toDouble())
                : (grossVal * 0.85);
            final platformFeeVal = (summary != null && summary['platform_fee'] != null)
                ? ((summary['platform_fee'] as num).toDouble())
                : (grossVal * 0.15);
            final todayRevVal = (summary != null && summary['today_revenue'] != null)
                ? ((summary['today_revenue'] as num).toDouble())
                : 0.0;
            final totalOrdersCount = _incomingOrders.length;
            final deliveredCount = _incomingOrders.where((o) => o.orderStatus.toLowerCase() == 'delivered').length;
            final inPrepCount = _incomingOrders.where((o) => o.orderStatus.toLowerCase() != 'delivered' && o.orderStatus.toLowerCase() != 'cancelled').length;
            final ridersCount = (summary != null && (summary['dispatched_riders'] != null || summary['total_riders'] != null))
                ? (summary['dispatched_riders'] ?? summary['total_riders'])
                : _incomingOrders.map((o) => o.agentId).where((id) => id != null).toSet().length;
            final avgRating = (summary != null && summary['avg_rider_rating'] != null)
                ? (summary['avg_rider_rating'] as num).toDouble()
                : 4.8;

            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 1.6 : 1.4,
              children: [
                _buildKpiCard(
                  icon: Icons.currency_rupee,
                  iconColor: const Color(0xFF10B981),
                  title: "Gross Sales",
                  value: "₹${grossVal.toStringAsFixed(0)}",
                  subtext: "Today: ₹${todayRevVal.toStringAsFixed(0)}",
                  badgeText: grossVal > 0 ? "Live" : null,
                  badgeColor: const Color(0xFF10B981),
                ),
                _buildKpiCard(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF4F46E5),
                  title: "Net Partner Payout",
                  value: "₹${netPayoutVal.toStringAsFixed(0)}",
                  subtext: "Platform Fee: ₹${platformFeeVal.toStringAsFixed(0)} (15%)",
                ),
                _buildKpiCard(
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: "Total Orders",
                  value: "$totalOrdersCount",
                  subtext: "$deliveredCount Delivered • $inPrepCount In-Prep",
                ),
                _buildKpiCard(
                  icon: Icons.delivery_dining_outlined,
                  iconColor: const Color(0xFF10B981),
                  title: "Active Couriers",
                  value: "$ridersCount",
                  subtext: ridersCount > 0 ? "Couriers assigned" : "No active couriers",
                  ratingText: ridersCount > 0 ? "★ $avgRating Rating" : null,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // Bottom Row: Trend Chart (Left) + Live Orders Preview (Right)
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildRevenueChartCard()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildLiveOrdersPreviewCard()),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildRevenueChartCard(),
                  const SizedBox(height: 20),
                  _buildLiveOrdersPreviewCard(),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 24),

        // Row 3: Best Selling Dishes (Left) + Top Repeat Customers (Right)
        _buildOverviewBestSellersAndTopCustomers(),
      ],
    );
  }

  Widget _buildOverviewBestSellersAndTopCustomers() {
    final topDishes = _getTopDishes().take(4).toList();
    final topCustomers = _getTopCustomers().take(4).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 850;

        final bestSellersCard = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
                  Row(
                    children: const [
                      Icon(Icons.local_fire_department_rounded, color: Color(0xFFEF4444), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Best Selling Dishes",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedNavIndex = 4), // Go to Analytics
                    child: const Text(
                      "Full Analytics →",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (topDishes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      "No dish sales data yet. Best sellers will appear here as orders arrive.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...topDishes.asMap().entries.map((entry) {
                final idx = entry.key;
                final dish = entry.value;
                final rank = idx + 1;
                final isVeg = dish['is_veg'] == true || dish['is_veg'] == 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: rank == 1 ? const Color(0xFFFEF3C7) : const Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "#$rank",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: rank == 1 ? const Color(0xFFD97706) : const Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ItemImageWidget(
                        imageUrl: dish['Image_Url'],
                        itemName: dish['Item_Name'] ?? 'Dish',
                        width: 38,
                        height: 38,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: isVeg ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    dish['Item_Name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "₹${(dish['price'] as num?)?.toDouble().toStringAsFixed(0) ?? '0'} • ${dish['category'] ?? ''}",
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${dish['units_sold'] ?? 0} sold",
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "₹${((dish['revenue'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );

        final topCustomersCard = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
                  Row(
                    children: const [
                      Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Top Customers (Ordered Most)",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedNavIndex = 5), // Go to Customers Directory
                    child: const Text(
                      "View all →",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (topCustomers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      "No repeat customer insights yet. Customer history will appear as orders arrive.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...topCustomers.asMap().entries.map((entry) {
                final idx = entry.key;
                final cust = entry.value;
                final rank = idx + 1;
                final name = cust['user_name'] ?? 'Customer';
                final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: rank == 1 ? const Color(0xFFFEF3C7) : const Color(0xFFEEF2FF),
                        child: Text(
                          initials.isNotEmpty ? initials : "VIP",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: rank == 1 ? const Color(0xFFB45309) : const Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 6),
                                if (rank <= 3)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "VIP #$rank",
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cust['favorite_dish'] ?? cust['user_area'] ?? 'Regular Buyer',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${cust['order_count'] ?? 0} Orders",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "₹${((cust['total_spent'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: bestSellersCard),
              const SizedBox(width: 20),
              Expanded(child: topCustomersCard),
            ],
          );
        } else {
          return Column(
            children: [
              bestSellersCard,
              const SizedBox(height: 20),
              topCustomersCard,
            ],
          );
        }
      },
    );
  }

  Widget _buildTimeFilterChip(String label) {
    final isSelected = _revenueTimeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _revenueTimeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: AppTheme.black, width: 2),
          boxShadow: isSelected
              ? const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0)]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtext,
    String? badgeText,
    Color? badgeColor,
    String? ratingText,
  }) {
    return BrutalistCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  border: Border.all(color: AppTheme.black, width: 1.5),
                ),
                child: Icon(icon, color: AppTheme.black, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.black,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  subtext,
                  style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.green,
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: Text(
                    badgeText.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.black),
                  ),
                ),
              if (ratingText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: Text(
                    ratingText.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.black),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChartCard() {
    return BrutalistCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: AppTheme.black, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "REVENUE & ORDERS TREND",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // Frequency Chips: Daily, Weekly, Monthly
              Row(
                children: ["Daily", "Weekly", "Monthly"].map((freq) {
                  final isSel = _chartFrequency == freq;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _chartFrequency = freq),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.yellow : AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          border: Border.all(color: AppTheme.black, width: 1.5),
                          boxShadow: isSel
                              ? const [BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0)]
                              : null,
                        ),
                        child: Text(
                          freq.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: AppTheme.yellow, border: Border.all(color: AppTheme.black, width: 1))),
              const SizedBox(width: 4),
              Text("SALES (₹)", style: GoogleFonts.ibmPlexMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.black)),
              const SizedBox(width: 14),
              Container(width: 10, height: 10, decoration: BoxDecoration(color: AppTheme.surface, border: Border.all(color: AppTheme.black, width: 1))),
              const SizedBox(width: 4),
              Text("ORDERS", style: GoogleFonts.ibmPlexMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.black)),
            ],
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (context) {
              final rawTimeline = (_analyticsData != null && _analyticsData!['timeline'] is List)
                  ? List<Map<String, dynamic>>.from(_analyticsData!['timeline'])
                  : <Map<String, dynamic>>[];

              if (rawTimeline.isEmpty) {
                return Container(
                  height: 140,
                  alignment: Alignment.center,
                  child: Text(
                    "NO SALES RECORDED YET // DAILY REVENUE TELEMETRY PENDING",
                    style: GoogleFonts.ibmPlexMono(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final maxRev = rawTimeline.fold<double>(
                  1.0, (m, item) => ((item['revenue'] as num?)?.toDouble() ?? 0.0) > m ? ((item['revenue'] as num?)?.toDouble() ?? 0.0) : m);

              return SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: rawTimeline.map((item) {
                    final rev = ((item['revenue'] as num?)?.toDouble() ?? 0.0);
                    final ordersCount = item['orders'] ?? 0;
                    final dateStr = (item['date'] ?? '').toString();
                    final shortDate = dateStr.length >= 5 ? dateStr.substring(dateStr.length - 5) : dateStr;
                    final ratio = maxRev > 0 ? (rev / maxRev).clamp(0.1, 1.0) : 0.1;
                    final isPeak = rev == maxRev && rev > 0;

                    return _buildChartBar(
                      date: shortDate,
                      orders: "$ordersCount ord",
                      amount: rev >= 1000 ? "₹${(rev / 1000).toStringAsFixed(1)}k" : "₹${rev.toStringAsFixed(0)}",
                      ratio: ratio,
                      isPeak: isPeak,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar({required String date, required String orders, required String amount, required double ratio, required bool isPeak}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            amount,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isPeak ? AppTheme.black : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 110 * ratio,
            width: 32,
            decoration: BoxDecoration(
              color: isPeak ? AppTheme.yellow : AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(color: AppTheme.black, width: 2),
              boxShadow: isPeak
                  ? const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0)]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(date, style: GoogleFonts.ibmPlexMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.black)),
          Text(orders, style: GoogleFonts.ibmPlexMono(fontSize: 9, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildLiveOrdersPreviewCard() {
    final activeOrders = _incomingOrders.where((o) => o.orderStatus != "Delivered").take(3).toList();

    return BrutalistCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: AppTheme.green, border: Border.all(color: AppTheme.black, width: 1)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "LIVE ORDERS",
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.black, letterSpacing: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                    child: Text(
                      "${_incomingOrders.where((o) => o.orderStatus != 'Delivered').length} ACTIVE",
                      style: GoogleFonts.ibmPlexMono(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.black),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = 2), // Go to Orders
                child: Text(
                  "VIEW ALL →",
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activeOrders.map((ord) {
            Color statusBg = AppTheme.yellow;
            Color statusText = AppTheme.black;
            if (ord.orderStatus == "Preparing") {
              statusBg = AppTheme.blue;
              statusText = AppTheme.surface;
            } else if (ord.orderStatus == "Ready") {
              statusBg = AppTheme.green;
              statusText = AppTheme.black;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.bg,
                border: Border.all(color: AppTheme.black, width: 1.5),
                boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 18, color: AppTheme.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "#${ord.orderId}",
                              style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.black),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "₹${ord.totalAmount.toStringAsFixed(2)}",
                              style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${ord.userName ?? 'Customer'} • ${ord.orderDate ?? 'Just now'}",
                          style: GoogleFonts.spaceGrotesk(fontSize: 10.5, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      border: Border.all(color: AppTheme.black, width: 1),
                    ),
                    child: Text(
                      ord.orderStatus.toUpperCase(),
                      style: GoogleFonts.ibmPlexMono(fontSize: 9.5, fontWeight: FontWeight.w900, color: statusText),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 2: MENU MANAGEMENT (MIDDLE SCREEN)
  // ==========================================
  Widget _buildMenuManagementView() {
    final categories = [
      "All (${_menuItems.length})",
      "⭐ Best Sellers",
      "Main Course",
      "Starters",
      "Breads",
      "Beverages",
      "Desserts"
    ];

    final filteredDishes = _menuItems.where((item) {
      if (_menuSearchQuery.isNotEmpty) {
        final q = _menuSearchQuery.toLowerCase();
        if (!item.itemName.toLowerCase().contains(q) && !(item.foodName?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      if (_selectedMenuCategory == "⭐ Best Sellers") {
        final topNames = _getTopDishes().take(6).map((d) => (d['Item_Name'] ?? '').toString().toLowerCase()).toSet();
        if (!topNames.contains(item.itemName.toLowerCase())) {
          return false;
        }
      } else if (_selectedMenuCategory != "All") {
        final catClean = _selectedMenuCategory.split(" ")[0].toLowerCase();
        if (!(item.foodName?.toLowerCase().contains(catClean) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Row with + Add Dish Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Menu management",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  "Add, edit or remove dishes from your menu",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text("Add Dish", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onPressed: () => _showAddEditDishDialog(),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Search & Category Dropdown
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search dishes (e.g. paneer, biryani, dosa...)",
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _menuSearchQuery = val),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButton<String>(
                value: "All Categories",
                underline: const SizedBox(),
                isDense: true,
                items: ["All Categories", "Main Course", "Starters", "Breads", "Beverages", "Desserts"].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMenuCategory = val == "All Categories" ? "All" : val;
                    });
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Category Pills (All (24), Main Course (8), etc.)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final catKey = cat.startsWith("All") ? "All" : cat.split(" ")[0];
              final isSel = _selectedMenuCategory == catKey || (_selectedMenuCategory == "All" && cat.startsWith("All"));

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMenuCategory = catKey),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF4F46E5) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSel ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Dishes List
        if (filteredDishes.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(
                _menuItems.isEmpty
                    ? "Your menu is empty. Tap '+ Add Dish' above to create your first dish!"
                    : "No dishes match your search or filter.",
                style: const TextStyle(color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...filteredDishes.map((dish) => _buildDishListItem(dish)),
      ],
    );
  }

  Widget _buildDishListItem(RestaurantItemModel dish) {
    final isAvailable = _itemAvailability[dish.itemName] ?? true;

    return BrutalistCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      shadowOffset: const Offset(2.5, 2.5),
      child: Row(
        children: [
          // Food Image with Veg Indicator
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.black, width: 2),
                ),
                child: ItemImageWidget(
                  imageUrl: dish.imageUrl,
                  itemName: dish.itemName,
                  category: dish.foodName,
                  width: 68,
                  height: 68,
                  borderRadius: 0,
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: Text(dish.isVeg ? "🟢" : "🔴", style: const TextStyle(fontSize: 9)),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Dish Details (Title, Category, Price, Discount)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.itemName.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.black),
                ),
                const SizedBox(height: 2),
                Text(
                  (dish.foodName ?? "Main Course").toUpperCase(),
                  style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "₹${dish.finalPrice.toStringAsFixed(2)}",
                      style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.black),
                    ),
                    if (dish.discount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        "₹${dish.basePrice.toStringAsFixed(2)}",
                        style: GoogleFonts.ibmPlexMono(decoration: TextDecoration.lineThrough, color: const Color(0xFF94A3B8), fontSize: 11),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppTheme.yellow,
                          border: Border.all(color: AppTheme.black, width: 1),
                        ),
                        child: Text(
                          "${dish.discount.toStringAsFixed(0)}% OFF",
                          style: GoogleFonts.ibmPlexMono(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 9.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Right Controls: Available Switch, Edit, Delete
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAvailable ? AppTheme.yellow : AppTheme.surface,
                  border: Border.all(color: AppTheme.black, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAvailable ? "IN STOCK" : "SOLD OUT",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Transform.scale(
                      scale: 0.75,
                      child: Switch(
                        value: isAvailable,
                        activeColor: AppTheme.black,
                        activeTrackColor: AppTheme.surface,
                        onChanged: (val) {
                          setState(() => _itemAvailability[dish.itemName] = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${dish.itemName} is now ${val ? 'Available' : 'Sold Out'}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black)),
                              backgroundColor: AppTheme.yellow,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                side: const BorderSide(color: AppTheme.black, width: 2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showAddEditDishDialog(existingItem: dish),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: const Icon(Icons.edit_outlined, color: AppTheme.black, size: 16),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _deleteDish(dish.itemName),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppTheme.red, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 3: LIVE ORDERS (RIGHT SCREEN)
  // ==========================================
  Widget _buildLiveOrdersView() {
    final statusTabs = [
      "All (${_incomingOrders.length})",
      "⭐ Frequent Customers",
      "Placed (${_incomingOrders.where((o) => o.orderStatus == 'Placed').length})",
      "Preparing (${_incomingOrders.where((o) => o.orderStatus == 'Preparing').length})",
      "Ready (${_incomingOrders.where((o) => o.orderStatus == 'Ready').length})",
      "Delivered (${_incomingOrders.where((o) => o.orderStatus == 'Delivered').length})",
      "Cancelled (${_incomingOrders.where((o) => o.orderStatus == 'Cancelled').length})",
    ];

    final filteredOrders = _incomingOrders.where((o) {
      if (_orderStatusFilter == "⭐" || _orderStatusFilter == "⭐ Frequent Customers") {
        final topNames = _getTopCustomers().map((c) => (c['user_name'] ?? '').toString().toLowerCase()).toSet();
        return topNames.contains((o.userName ?? '').toLowerCase()) || o.userId <= 103;
      }
      if (_orderStatusFilter == "All") return true;
      return o.orderStatus == _orderStatusFilter;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Row with Auto-Accept Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Live orders",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage incoming orders and track deliveries",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            // Auto Accept Switch
            Row(
              children: [
                const Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                const Text("Auto-accept", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(width: 6),
                Switch(
                  value: _autoAcceptOrders,
                  activeColor: const Color(0xFF4F46E5),
                  onChanged: (val) {
                    setState(() => _autoAcceptOrders = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? "Auto-accept enabled" : "Auto-accept disabled"),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Status Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: statusTabs.map((tab) {
              final tabKey = tab.startsWith("All")
                  ? "All"
                  : tab.startsWith("⭐")
                      ? "⭐ Frequent Customers"
                      : tab.split(" ")[0];
              final isSel = _orderStatusFilter == tabKey || (_orderStatusFilter == "All" && tab.startsWith("All"));

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => setState(() => _orderStatusFilter = tabKey),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF4F46E5) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSel ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Order Cards
        if (filteredOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(
                _incomingOrders.isEmpty
                    ? "No incoming orders yet. Orders from customers will appear here in real-time."
                    : "No orders found under this status.",
                style: const TextStyle(color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...filteredOrders.map((ord) => _buildLiveOrderCard(ord)),
      ],
    );
  }

  Widget _buildLiveOrderCard(OrderModel ord) {
    Color statusBg = AppTheme.yellow;
    Color statusText = AppTheme.black;

    if (ord.orderStatus == "Preparing") {
      statusBg = AppTheme.blue;
      statusText = AppTheme.surface;
    } else if (ord.orderStatus == "Ready") {
      statusBg = AppTheme.orange;
      statusText = AppTheme.surface;
    } else if (ord.orderStatus == "Delivered") {
      statusBg = AppTheme.green;
      statusText = AppTheme.black;
    } else if (ord.orderStatus == "Cancelled") {
      statusBg = AppTheme.red;
      statusText = AppTheme.surface;
    }

    return BrutalistCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID, Status, Elapsed Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "#${ord.orderId}",
                    style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.black),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      border: Border.all(color: AppTheme.black, width: 1.5),
                      boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0)],
                    ),
                    child: Text(
                      ord.orderStatus.toUpperCase(),
                      style: GoogleFonts.ibmPlexMono(fontSize: 10.5, fontWeight: FontWeight.w900, color: statusText),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    ord.orderDate ?? "2 MINS AGO",
                    style: GoogleFonts.ibmPlexMono(fontSize: 10.5, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "₹${ord.totalAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.black),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Customer and Address
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showCallDialog(context, ord.userName ?? "Customer", ord.userPhone ?? "9810000100"),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16, color: AppTheme.black),
                    const SizedBox(width: 6),
                    Text(
                      "${ord.userName ?? 'Customer'} • ${ord.userPhone ?? '9810000100'}",
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.black),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppTheme.green,
                        border: Border.all(color: AppTheme.black, width: 1),
                      ),
                      child: const Icon(Icons.phone, size: 10, color: AppTheme.black),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.black, width: 1),
                ),
                child: Text(
                  "${ord.paymentMethod ?? 'UPI'} // PAID",
                  style: GoogleFonts.ibmPlexMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.red),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ord.deliveryAddress.isNotEmpty ? ord.deliveryAddress : "14 MG Road, Indiranagar, Karnataka - 560038",
                  style: GoogleFonts.spaceGrotesk(fontSize: 11.5, color: const Color(0xFF4A4A4A), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Dishes in Order Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bg,
              border: Border.all(color: AppTheme.black, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: AppTheme.black, width: 1.5)),
                      child: Image.network(
                        "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=100&auto=format&fit=crop&q=60",
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppTheme.yellow, width: 40, height: 40, child: const Icon(Icons.restaurant, color: AppTheme.black)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ord.orderId == 206 ? "Chicken Biryani + 2 more items" : "Paneer Butter Masala",
                          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.black),
                        ),
                        Text(
                          ord.orderId == 206 ? "3 items • ₹1,260.00" : "1x ₹252.00",
                          style: GoogleFonts.ibmPlexMono(fontSize: 11, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showOrderItemsDialog(context, ord),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ord.orderId == 206 ? "ITEMS (3)" : "ITEMS (1)",
                          style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.black),
                        ),
                        const Icon(Icons.chevron_right, size: 14, color: AppTheme.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Courier info
              Row(
                children: [
                  const Text("🛵", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    ord.agentName != null
                        ? "${ord.agentName} • ${ord.agentVehicle ?? 'KA-08'} ★ ${ord.agentRating ?? 5.0}".toUpperCase()
                        : "ASSIGN COURIER ⌄",
                    style: GoogleFonts.ibmPlexMono(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.black),
                  ),
                  if (ord.agentPhone != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showCallDialog(context, ord.agentName ?? "Courier", ord.agentPhone ?? "9810000100"),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppTheme.green, border: Border.all(color: AppTheme.black, width: 1)),
                        child: const Icon(Icons.call, size: 12, color: AppTheme.black),
                      ),
                    ),
                  ],
                ],
              ),

              // Action Buttons: Reject & Next Status
              Row(
                children: [
                  if (ord.orderStatus == "Placed") ...[
                    BrutalistButton(
                      text: "REJECT",
                      bgColor: AppTheme.surface,
                      textColor: AppTheme.red,
                      borderColor: AppTheme.red,
                      height: 38,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      onPressed: () => _updateOrderStatus(ord.orderId, "Cancelled"),
                    ),
                    const SizedBox(width: 8),
                    BrutalistButton(
                      text: "START PREP",
                      bgColor: AppTheme.yellow,
                      textColor: AppTheme.black,
                      height: 38,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      onPressed: () => _updateOrderStatus(ord.orderId, "Preparing"),
                    ),
                  ] else if (ord.orderStatus == "Preparing") ...[
                    BrutalistButton(
                      text: "READY FOR DISPATCH",
                      bgColor: AppTheme.blue,
                      textColor: AppTheme.surface,
                      height: 38,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      onPressed: () => _updateOrderStatus(ord.orderId, "Ready"),
                    ),
                  ] else if (ord.orderStatus == "Ready") ...[
                    BrutalistButton(
                      text: "HANDED TO COURIER",
                      icon: Icons.moped,
                      bgColor: AppTheme.green,
                      textColor: AppTheme.black,
                      height: 38,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      onPressed: () => _updateOrderStatus(ord.orderId, "Delivered"),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.green,
                        border: Border.all(color: AppTheme.black, width: 1.5),
                      ),
                      child: Text(
                        "COMPLETED",
                        style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.black),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 4: PAYOUTS
  // ==========================================
  Widget _buildPayoutsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Partner Payouts & Statements", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        const Text("Direct deposit account settlement and historical payouts", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.account_balance, color: Color(0xFF4F46E5)),
                      SizedBox(width: 10),
                      Text("Registered Bank Settlement Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                    child: const Text("Verified", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF10B981))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text("HDFC Bank • Account: •••• •••• 8912 • IFSC: HDFC0001234", style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
              const SizedBox(height: 4),
              const Text("Weekly Settlement Schedule: Every Tuesday 08:00 AM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 5: ANALYTICS (BEST SELLING DISHES & REVENUE YIELD)
  // ==========================================
  Widget _buildAnalyticsView() {
    var dishes = _getTopDishes();

    // Search filter
    if (_dishSearchQuery.isNotEmpty) {
      final q = _dishSearchQuery.toLowerCase();
      dishes = dishes.where((d) {
        final name = (d['Item_Name'] ?? '').toString().toLowerCase();
        final cat = (d['category'] ?? '').toString().toLowerCase();
        return name.contains(q) || cat.contains(q);
      }).toList();
    }

    // Sort / category filter
    if (_analyticsDishSort == "Volume") {
      dishes.sort((a, b) => ((b['units_sold'] as num?) ?? 0).compareTo((a['units_sold'] as num?) ?? 0));
    } else if (_analyticsDishSort == "Revenue") {
      dishes.sort((a, b) => ((b['revenue'] as num?) ?? 0.0).compareTo((a['revenue'] as num?) ?? 0.0));
    } else if (_analyticsDishSort == "Veg") {
      dishes = dishes.where((d) => d['is_veg'] == true || d['is_veg'] == 1).toList();
    } else if (_analyticsDishSort == "Non-Veg") {
      dishes = dishes.where((d) => d['is_veg'] == false || d['is_veg'] == 0).toList();
    }

    final topItemName = dishes.isNotEmpty ? dishes.first['Item_Name'] ?? 'Chicken Biryani' : 'Top Dish';
    final topItemSales = dishes.isNotEmpty ? "${dishes.first['units_sold'] ?? 0} sold" : '0 sold';
    final double totalTopRev = dishes.fold(0.0, (acc, item) => acc + (((item['revenue'] as num?)?.toDouble()) ?? 0.0));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Best Selling Dishes & Menu Analytics",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  "Real-time volume ranking, revenue contribution, and kitchen stock status",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add New Dish", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () => _showAddEditDishDialog(),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Quick KPI Banner
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 18),
                        SizedBox(width: 8),
                        Text("#1 Best Seller", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(topItemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                    Text(topItemSales, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF4F46E5), size: 18),
                        SizedBox(width: 8),
                        Text("Top Items Revenue", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("₹${totalTopRev.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Text("68% of outlet revenue", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.pie_chart_rounded, color: Color(0xFF10B981), size: 18),
                        SizedBox(width: 8),
                        Text("Category Mix", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text("58% Veg • 42% Non-Veg", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Text("High conversion on biryani & breads", style: TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Filter and Search Toolbar
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search dishes by name or category...",
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
                onChanged: (val) => setState(() => _dishSearchQuery = val),
              ),
            ),
            const SizedBox(width: 12),
            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  {"id": "Volume", "label": "🔥 Top Volume"},
                  {"id": "Revenue", "label": "💰 Highest Revenue"},
                  {"id": "Veg", "label": "🌱 Pure Veg"},
                  {"id": "Non-Veg", "label": "🍗 Non-Veg"},
                ].map((chip) {
                  final isSel = _analyticsDishSort == chip['id'];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _analyticsDishSort = chip['id']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF4F46E5) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSel ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          chip['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Dishes Leaderboard Cards
        if (dishes.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text("No dishes match the selected filter", style: TextStyle(color: Color(0xFF64748B)))),
          )
        else
          ...dishes.asMap().entries.map((entry) {
            final idx = entry.key;
            final dish = entry.value;
            final rank = idx + 1;
            final isVeg = dish['is_veg'] == true || dish['is_veg'] == 1;
            final dishName = dish['Item_Name'] ?? 'Dish';
            final units = dish['units_sold'] ?? 0;
            final double revenue = ((dish['revenue'] as num?)?.toDouble()) ?? 0.0;
            final double price = ((dish['price'] as num?)?.toDouble()) ?? 0.0;
            final isAvailable = _itemAvailability[dishName] ?? true;

            Color rankColor = const Color(0xFF64748B);
            Color rankBg = const Color(0xFFF1F5F9);
            String rankLabel = "#$rank";
            if (rank == 1) {
              rankColor = const Color(0xFFD97706);
              rankBg = const Color(0xFFFEF3C7);
              rankLabel = "👑 #1 BESTSELLER";
            } else if (rank == 2) {
              rankColor = const Color(0xFF4F46E5);
              rankBg = const Color(0xFFEEF2FF);
              rankLabel = "🥈 #2 TOP PERFORMER";
            } else if (rank == 3) {
              rankColor = const Color(0xFF0284C7);
              rankBg = const Color(0xFFE0F2FE);
              rankLabel = "🥉 #3 POPULAR";
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: rankBg, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      rankLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: rankColor),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Image
                  ItemImageWidget(
                    imageUrl: dish['Image_Url'],
                    itemName: dishName,
                    width: 50,
                    height: 50,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 14),

                  // Dish Info
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: isVeg ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                dishName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dish['category'] ?? 'Main Course',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Price", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text("₹${price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),

                  // Units Sold + Bar
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Orders Sold", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            Text("$units units", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (units / 60.0).clamp(0.05, 1.0),
                            backgroundColor: const Color(0xFFEEF2FF),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Total Revenue
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Gross Revenue", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          "₹${revenue.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Availability Switch
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isAvailable ? "Available" : "Sold Out", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isAvailable ? const Color(0xFF10B981) : const Color(0xFF94A3B8))),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isAvailable,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            setState(() => _itemAvailability[dishName] = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // VIEW 6: CUSTOMERS (WHO ORDERED THE MOST & REPEAT LOYALTY)
  // ==========================================
  Widget _buildCustomersView() {
    var customers = _getTopCustomers();

    // Search filter
    if (_customerSearchQuery.isNotEmpty) {
      final q = _customerSearchQuery.toLowerCase();
      customers = customers.where((c) {
        final name = (c['user_name'] ?? '').toString().toLowerCase();
        final phone = (c['user_phone'] ?? '').toString().toLowerCase();
        final area = (c['user_area'] ?? '').toString().toLowerCase();
        return name.contains(q) || phone.contains(q) || area.contains(q);
      }).toList();
    }

    // Sort filter
    if (_customerSort == "Orders") {
      customers.sort((a, b) => ((b['order_count'] as num?) ?? 0).compareTo((a['order_count'] as num?) ?? 0));
    } else if (_customerSort == "Spend") {
      customers.sort((a, b) => ((b['total_spent'] as num?) ?? 0.0).compareTo((a['total_spent'] as num?) ?? 0.0));
    }

    final topCustomerName = customers.isNotEmpty ? customers.first['user_name'] ?? 'Top Buyer' : 'Top Customer';
    final topCustomerOrders = customers.isNotEmpty ? "${customers.first['order_count'] ?? 0} orders" : '0 orders';
    final double totalVipSpend = customers.fold(0.0, (acc, c) => acc + (((c['total_spent'] as num?)?.toDouble()) ?? 0.0));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Top Customers Directory (\"Who Ordered The Most\")",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  "Customer leaderboard ranked by order frequency, lifetime spend, and favorite dishes",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF4F46E5), size: 16),
                  SizedBox(width: 6),
                  Text("Loyalty Rewards Active", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // KPI Banner
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 18),
                        SizedBox(width: 8),
                        Text("#1 VIP Patron", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(topCustomerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                    Text("$topCustomerOrders placed", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.repeat_rounded, color: Color(0xFF4F46E5), size: 18),
                        SizedBox(width: 8),
                        Text("Repeat Order Ratio", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text("78% Repeat Volume", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Text("High customer retention in Indiranagar", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.savings_rounded, color: Color(0xFF10B981), size: 18),
                        SizedBox(width: 8),
                        Text("Total VIP Spend", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("₹${totalVipSpend.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Text("Average ₹1,120 per customer order", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Search & Filter Toolbar
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search customer by name, phone, or delivery area...",
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
                onChanged: (val) => setState(() => _customerSearchQuery = val),
              ),
            ),
            const SizedBox(width: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  {"id": "Orders", "label": "⭐ Most Orders Placed"},
                  {"id": "Spend", "label": "💎 Highest Spending"},
                ].map((chip) {
                  final isSel = _customerSort == chip['id'];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _customerSort = chip['id']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF4F46E5) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSel ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          chip['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Customer Cards
        if (customers.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text("No customers match the search", style: TextStyle(color: Color(0xFF64748B)))),
          )
        else
          ...customers.asMap().entries.map((entry) {
            final idx = entry.key;
            final cust = entry.value;
            final rank = idx + 1;
            final name = cust['user_name'] ?? 'Valued Customer';
            final phone = cust['user_phone'] ?? '9876543210';
            final area = cust['user_area'] ?? 'Indiranagar';
            final orders = cust['order_count'] ?? 0;
            final double spend = ((cust['total_spent'] as num?)?.toDouble()) ?? 0.0;
            final fav = cust['favorite_dish'] ?? 'Chicken Biryani Special';
            final lastDate = cust['last_order_date'] ?? 'Recently';
            final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();

            Color rankBadgeColor = const Color(0xFF64748B);
            Color rankBg = const Color(0xFFF1F5F9);
            String rankText = "#$rank";
            if (rank == 1) {
              rankBadgeColor = const Color(0xFFD97706);
              rankBg = const Color(0xFFFEF3C7);
              rankText = "👑 VIP #1 (Champion)";
            } else if (rank == 2) {
              rankBadgeColor = const Color(0xFF4F46E5);
              rankBg = const Color(0xFFEEF2FF);
              rankText = "🥈 VIP #2";
            } else if (rank == 3) {
              rankBadgeColor = const Color(0xFF0284C7);
              rankBg = const Color(0xFFE0F2FE);
              rankText = "🥉 VIP #3";
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  // VIP Rank Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: rankBg, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      rankText,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: rankBadgeColor),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: rank == 1 ? const Color(0xFFFEF3C7) : const Color(0xFFEEF2FF),
                    child: Text(
                      initials.isNotEmpty ? initials : "VIP",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: rank == 1 ? const Color(0xFFB45309) : const Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Contact
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(phone, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            const SizedBox(width: 10),
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                area,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Favorite Dish Badge
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("❤️ Favorite Dish", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                          const SizedBox(height: 2),
                          Text(fav, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Orders & Spent
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "$orders Orders Placed",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF4F46E5)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${spend.toStringAsFixed(0)} spent",
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF10B981)),
                      ),
                      Text("Last: $lastDate", style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    ],
                  ),

                  const SizedBox(width: 14),

                  // Contact Button
                  IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF4F46E5), size: 20),
                    tooltip: "Call Customer",
                    onPressed: () => _showCallDialog(context, name, phone),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // VIEW 7: STORE SETTINGS & PROFILE
  // ==========================================
  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Store Profile & Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        const Text("Manage your outlet information, hours and kitchen preferences", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        const SizedBox(height: 20),

        // Store Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF4F46E5),
                    child: Text(_restName.isNotEmpty ? _restName[0].toUpperCase() : "R", style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_restName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text("📍 $_restLocation", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        Text("📞 Phone: $_restPhone", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Store ID: #$_restId  •  4.11 ★ Rating", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text("Edit Outlet Details", style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _showEditRestaurantDialog,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Kitchen Preferences
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.store_rounded, color: Color(0xFF10B981)),
                title: const Text("Store Online & Accepting Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text("Disable to pause new incoming orders temporarily", style: TextStyle(fontSize: 12)),
                value: _isStoreOpen,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) => setState(() => _isStoreOpen = val),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.volume_up_rounded, color: Color(0xFF4F46E5)),
                title: const Text("Kitchen Order Ticket (KOT) Chime", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text("Play loud audio bell when a new customer order arrives", style: TextStyle(fontSize: 12)),
                value: _kotSound,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (val) => setState(() => _kotSound = val),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: Color(0xFFF59E0B)),
                title: const Text("Average Kitchen Prep Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("$_prepTime minutes standard preparation window", style: const TextStyle(fontSize: 12)),
                trailing: DropdownButton<int>(
                  value: _prepTime,
                  underline: const SizedBox(),
                  items: [15, 20, 25, 30, 40].map((t) => DropdownMenuItem(value: t, child: Text("$t mins"))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _prepTime = val);
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.wifi_tethering, color: Color(0xFF4F46E5)),
                title: const Text("Backend Host Network Config", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("Connecting to: ${ApiService.baseUrl.replaceAll('http://', '').replaceAll('/api', '')}", style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => ServerConfigDialog.show(context, onSaved: () => setState(() {})),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            label: const Text("Log Out of Restaurant Partner Portal", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _logout,
          ),
        ),
      ],
    );
  }

  void _showEditRestaurantDialog() {
    final nameCtrl = TextEditingController(text: _restName);
    final locCtrl = TextEditingController(text: _restLocation);
    final phoneCtrl = TextEditingController(text: _restPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Restaurant Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Restaurant Name", prefixIcon: Icon(Icons.storefront))),
            const SizedBox(height: 12),
            TextField(controller: locCtrl, decoration: const InputDecoration(labelText: "Location / Address", prefixIcon: Icon(Icons.location_on))),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newLoc = locCtrl.text.trim();
              final newPhone = phoneCtrl.text.trim();

              try {
                await ApiService.updateRestaurant(_restId, {
                  "name": newName,
                  "location": newLoc,
                  "phone": newPhone,
                  "rating": 4.11,
                });
              } catch (_) {}

              setState(() {
                _restName = newName;
                _restLocation = newLoc;
                _restPhone = newPhone;
              });
              widget.restaurantData['RName'] = newName;
              widget.restaurantData['RLocation'] = newLoc;
              widget.restaurantData['RPhone'] = newPhone;

              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Restaurant profile updated!"), backgroundColor: Color(0xFF10B981)),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

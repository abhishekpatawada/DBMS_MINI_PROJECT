import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../auth_screen.dart';
import '../../utils/item_image_helper.dart';
import '../../widgets/server_config_dialog.dart';

class DarkStoreDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> storeData;

  const DarkStoreDashboardScreen({super.key, required this.storeData});

  @override
  State<DarkStoreDashboardScreen> createState() => _DarkStoreDashboardScreenState();
}

class _DarkStoreDashboardScreenState extends State<DarkStoreDashboardScreen> {
  late int _storeId;
  late String _storeArea;
  late String _storeStreet;
  late String _storeState;
  late String _storePincode;

  int _selectedNavIndex = 0; // 0: Dashboard, 1: Hub Inventory, 2: Hub Orders, 3: Payouts, 4: Analytics, 5: Settings

  // State filters
  String _revenueTimeFilter = "Today"; // Today, 7 Days, 30 Days, All Time
  String _inventorySearchQuery = "";
  String _selectedCategory = "All Categories";
  String _orderStatusFilter = "All"; // All, Placed, Packing, Ready, Dispatched, Delivered

  bool _isStoreActive = true;
  bool _autoBarcodeScan = true;
  int _reorderThreshold = 10;

  List<GroceryItemModel> _groceries = [];
  List<OrderModel> _incomingGroceryOrders = [];
  bool _isLoading = true;

  final Map<String, bool> _itemStatusMap = {};
  final Set<String> _selectedInventoryRows = {};

  DateTime _selectedDate = DateTime(2026, 10, 16);
  String _selectedOrderDateFilter = "Today";

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

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: Color(0xFF4F46E5), size: 24),
            SizedBox(width: 10),
            Text("Hub Notifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Low Stock Warning", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF991B1B))),
                        Text("Fresh Tomato (8 units) and Fresh Banana (12 units) are below threshold.", style: TextStyle(fontSize: 11, color: Color(0xFF7F1D1D))),
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
                  Icon(Icons.delivery_dining_rounded, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rider Station Online", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46))),
                        Text("Courier Siddharth Mehta is within 2 mins of Indiranagar Hub.", style: TextStyle(fontSize: 11, color: Color(0xFF047857))),
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
              setState(() => _selectedNavIndex = 1);
            },
            child: const Text("Restock Inventory"),
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
                    Text("Order #${ord.orderId} Details", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
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
                  ord.orderId == 100
                      ? "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=100&auto=format&fit=crop&q=60"
                      : "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=100&auto=format&fit=crop&q=60",
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(ord.orderId == 100 ? "Aashirvaad Atta 5kg" : "Amul Butter 500g", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(ord.orderId == 100 ? "SKU: #ATT-001 • Category: Atta & Dals" : "SKU: #BUT-001 • Category: Dairy & Bread", style: const TextStyle(fontSize: 12)),
              trailing: Text(
                "₹${ord.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Bill (Paid via UPI)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                Text("₹${ord.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.print_outlined),
                label: const Text("Print Hub Bag Invoice"),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invoice sent to Thermal Printer for Order #${ord.orderId}"), backgroundColor: const Color(0xFF4F46E5)),
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
    _initStoreData();
    _loadData();
  }

  void _initStoreData() {
    _storeId = widget.storeData['Store_Id'] ?? widget.storeData['storeId'] ?? 1;
    _storeArea = widget.storeData['DS_Area'] ?? widget.storeData['dsArea'] ?? 'Indiranagar Hub #1';
    _storeStreet = widget.storeData['DS_Street'] ?? widget.storeData['dsStreet'] ?? '100ft Road';
    _storeState = widget.storeData['DS_State'] ?? widget.storeData['dsState'] ?? 'Karnataka';
    _storePincode = widget.storeData['DS_Pincode'] ?? widget.storeData['dsPincode'] ?? '560038';
  }

  List<GroceryItemModel> _getMockGroceries() {
    return [
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Aashirvaad Atta 5kg",
        price: 245.0,
        availableCount: 75,
        imageUrl: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=60",
      ),
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Amul Butter 500g",
        price: 275.0,
        availableCount: 85,
        imageUrl: "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500&auto=format&fit=crop&q=60",
      ),
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Amul Cheese Slices 200g",
        price: 145.0,
        availableCount: 60,
        imageUrl: "https://images.unsplash.com/photo-1624806992066-5ffcf7ca186b?w=500&auto=format&fit=crop&q=60",
      ),
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Amul Paneer 200g",
        price: 92.0,
        availableCount: 95,
        imageUrl: "https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=500&auto=format&fit=crop&q=60",
      ),
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Amul Taaza Milk 1L",
        price: 56.0,
        availableCount: 110,
        imageUrl: "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=60",
      ),
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Britannia Brown Bread 400g",
        price: 50.0,
        availableCount: 95,
        imageUrl: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=60",
      ),
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Fresh Banana 1kg",
        price: 60.0,
        availableCount: 12, // Low stock
        imageUrl: "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop&q=60",
      ),
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Fresh Tomato 1kg",
        price: 32.0,
        availableCount: 8, // Low stock
        imageUrl: "https://images.unsplash.com/photo-1546470427-e26264be0b11?w=500&auto=format&fit=crop&q=60",
      ),
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Onion 1kg",
        price: 28.0,
        availableCount: 25,
        imageUrl: "https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=500&auto=format&fit=crop&q=60",
      ),
      GroceryItemModel(
        storeId: _storeId,
        itemName: "Potato 1kg",
        price: 24.0,
        availableCount: 18,
        imageUrl: "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=60",
      ),
    ];
  }

  List<OrderModel> _getMockGroceryOrders() {
    return [
      OrderModel(
        orderId: 101,
        userId: 1,
        userName: "Aarav Choudhury",
        userPhone: "9810000100",
        agentId: 1,
        agentName: "Siddharth Mehta",
        agentRating: 4.0,
        storeId: _storeId,
        storeArea: _storeArea,
        orderType: "Grocery",
        orderStatus: "Placed",
        totalAmount: 275.00,
        orderDate: "2 mins ago",
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "3 MG Road, Indiranagar, Karnataka - 560038",
      ),
      OrderModel(
        orderId: 100,
        userId: 2,
        userName: "Rekha Nair",
        userPhone: "9876500020",
        agentId: 2,
        agentName: "Reddy",
        agentVehicle: "KA-08-DF-4421",
        agentRating: 4.2,
        storeId: _storeId,
        storeArea: _storeArea,
        orderType: "Grocery",
        orderStatus: "Packing",
        totalAmount: 220.00,
        orderDate: "8 mins ago",
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "Indiranagar, Bengaluru - 560038",
      ),
      OrderModel(
        orderId: 99,
        userId: 3,
        userName: "Geeta Patel",
        userPhone: "9980012345",
        agentId: 3,
        agentName: "Das",
        agentVehicle: "KA-05-AB-1234",
        agentRating: 4.6,
        storeId: _storeId,
        storeArea: _storeArea,
        orderType: "Grocery",
        orderStatus: "Ready",
        totalAmount: 98.00,
        orderDate: "15 mins ago",
        paymentMethod: "COD",
        paymentStatus: "Pending",
        deliveryAddr: "Domlur, Bengaluru - 560071",
      ),
      OrderModel(
        orderId: 98,
        userId: 4,
        userName: "Anita Ahuja",
        userPhone: "9900011000",
        storeId: _storeId,
        storeArea: _storeArea,
        orderType: "Grocery",
        orderStatus: "Delivered",
        totalAmount: 152.00,
        orderDate: "28 mins ago",
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "Koramangala, Bengaluru - 560034",
      ),
    ];
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getStoreGroceries(_storeId);
      final allOrders = await ApiService.getOrders();
      final gOrders = allOrders.where((o) => o.orderType == "Grocery").toList();

      if (mounted) {
        setState(() {
          _groceries = items.isNotEmpty ? items : _getMockGroceries();
          _incomingGroceryOrders = gOrders.isNotEmpty ? gOrders : _getMockGroceryOrders();

          for (var item in _groceries) {
            _itemStatusMap.putIfAbsent(item.itemName, () => true);
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _groceries = _getMockGroceries();
          _incomingGroceryOrders = _getMockGroceryOrders();
          for (var item in _groceries) {
            _itemStatusMap.putIfAbsent(item.itemName, () => true);
          }
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
        _incomingGroceryOrders = _incomingGroceryOrders.map((ord) {
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
              storeId: ord.storeId,
              storeArea: ord.storeArea,
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

  void _showAddEditGroceryDialog({GroceryItemModel? existingItem}) {
    final nameCtrl = TextEditingController(text: existingItem?.itemName ?? "");
    final priceCtrl = TextEditingController(text: existingItem != null ? existingItem.price.toStringAsFixed(0) : "50");
    final countCtrl = TextEditingController(text: existingItem != null ? existingItem.availableCount.toString() : "40");
    String? selectedImageUrl = existingItem?.imageUrl;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existingItem == null ? "Add Grocery Item" : "Update Stock & Price",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Preview & Gallery Picker
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
                        itemName: nameCtrl.text.isNotEmpty ? nameCtrl.text : "Grocery",
                        isGrocery: true,
                        width: 60,
                        height: 60,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Grocery Photo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 6),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                ItemImageHelper.showGalleryPickerModal(
                                  context: context,
                                  isGrocery: true,
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
                    decoration: const InputDecoration(labelText: "Product Name *", hintText: "e.g. Amul Butter 500g"),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Price (₹) *"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: countCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Available Units *"),
                      ),
                    ),
                  ],
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
                final price = double.tryParse(priceCtrl.text) ?? 50.0;
                final count = int.tryParse(countCtrl.text) ?? 10;
                final itemName = nameCtrl.text.trim();

                if (itemName.isEmpty) return;

                Navigator.pop(ctx);

                try {
                  if (existingItem == null) {
                    await ApiService.addGroceryItem(_storeId, {
                      "item_name": itemName,
                      "price": price,
                      "available_count": count,
                      "image_url": selectedImageUrl,
                    });
                  } else {
                    await ApiService.updateGroceryItem(_storeId, existingItem.itemName, {
                      "new_item_name": existingItem.itemName,
                      "price": price,
                      "available_count": count,
                      "image_url": selectedImageUrl,
                    });
                  }
                } catch (_) {}

                setState(() {
                  if (existingItem == null) {
                    _groceries.insert(
                      0,
                      GroceryItemModel(
                        storeId: _storeId,
                        itemName: itemName,
                        price: price,
                        availableCount: count,
                        imageUrl: selectedImageUrl,
                      ),
                    );
                    _itemStatusMap[itemName] = true;
                  } else {
                    final idx = _groceries.indexWhere((i) => i.itemName == existingItem.itemName);
                    if (idx != -1) {
                      _groceries[idx] = GroceryItemModel(
                        storeId: _storeId,
                        itemName: existingItem.itemName,
                        price: price,
                        availableCount: count,
                        imageUrl: selectedImageUrl,
                      );
                    }
                  }
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existingItem == null ? "Grocery item added" : "Inventory updated successfully"),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text("Save Item"),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGroceryItem(String itemName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Item"),
        content: Text("Are you sure you want to remove '$itemName' from hub inventory?"),
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
        await ApiService.deleteGroceryItem(_storeId, itemName);
      } catch (_) {}

      setState(() {
        _groceries.removeWhere((i) => i.itemName == itemName);
        _itemStatusMap.remove(itemName);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'$itemName' removed"), backgroundColor: const Color(0xFF10B981)),
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
          backgroundColor: const Color(0xFFF8FAFC),
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
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
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
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
              : _buildCurrentView(),
        ),
        _buildMobileBottomNav(),
      ],
    );
  }

  // SIDEBAR COMPONENT
  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: const Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.flash_on_rounded, color: Color(0xFF4F46E5), size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "BiteHub",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
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
                _buildSidebarItem(0, Icons.dashboard_outlined, "Dashboard"),
                _buildSidebarItem(1, Icons.inventory_2_outlined, "Hub Inventory"),
                _buildSidebarItem(2, Icons.shopping_bag_outlined, "Hub Orders"),
                _buildSidebarItem(3, Icons.account_balance_wallet_outlined, "Payouts"),
                _buildSidebarItem(4, Icons.bar_chart_rounded, "Analytics"),
                _buildSidebarItem(5, Icons.settings_outlined, "Settings"),
              ],
            ),
          ),

          // Bottom Store Status badge in Sidebar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront, color: Color(0xFFD97706), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _storeArea,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          const Text("Online", style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
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
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
        tileColor: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
          ),
        ),
        onTap: () => setState(() => _selectedNavIndex = index),
      ),
    );
  }

  // TOP BAR COMPONENT
  Widget _buildTopBar({required bool isLargeScreen}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Dark Store Warehouse Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.warehouse_rounded, color: Color(0xFFD97706), size: 22),
            ),
            const SizedBox(width: 12),

            // Store Title & Live Indicator
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      "Dark Store Hub #$_storeId ($_storeArea)",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "Live",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Actions on right
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22, color: Color(0xFF64748B)),
              tooltip: "Refresh Hub Data",
              onPressed: _loadData,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF64748B)),
                  tooltip: "Notifications",
                  onPressed: () => _showNotificationsDialog(context),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),

            // Profile Avatar 'A'
            GestureDetector(
              onTap: () => setState(() => _selectedNavIndex = 5), // Go to Settings
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "A",
                    style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4F46E5), fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION FOR MOBILE
  Widget _buildMobileBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMobileNavItem(0, Icons.dashboard_outlined, "Dashboard"),
            _buildMobileNavItem(1, Icons.inventory_2_outlined, "Inventory"),
            _buildMobileNavItem(2, Icons.shopping_bag_outlined, "Orders"),
            _buildMobileNavItem(3, Icons.account_balance_wallet_outlined, "Payouts"),
            _buildMobileNavItem(5, Icons.settings_outlined, "Settings"),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // CURRENT VIEW SELECTOR
  Widget _buildCurrentView() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildRevenueDashboardView(); // SCREEN 1
      case 1:
        return _buildHubInventoryView(); // SCREEN 2
      case 2:
        return _buildHubOrdersView(); // SCREEN 3
      case 3:
        return _buildPayoutsView();
      case 4:
        return _buildAnalyticsView();
      case 5:
      default:
        return _buildSettingsView();
    }
  }

  // ==========================================
  // VIEW 1: REVENUE DASHBOARD (LEFT PANEL)
  // ==========================================
  Widget _buildRevenueDashboardView() {
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
                  "Revenue Dashboard",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  "Track your sales, orders and payouts",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            // Date pill (interactive)
            InkWell(
              onTap: () => _pickDashboardDate(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text(
                      "${_getDayName(_selectedDate.weekday)}, ${_getMonthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
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
                  title: "Gross Sales Revenue",
                  value: "₹275",
                  subtext: "Today: ₹275",
                  badgeText: "+13.6% vs prev",
                  badgeColor: const Color(0xFF10B981),
                ),
                _buildKpiCard(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF4F46E5),
                  title: "Net Partner Payout",
                  value: "₹248",
                  subtext: "Platform Fee: ₹28 (10%)",
                ),
                _buildKpiCard(
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: "Order Volume",
                  value: "1 Order",
                  subtext: "1 Delivered • 0 In-Prep",
                ),
                _buildKpiCard(
                  icon: Icons.moped_outlined,
                  iconColor: const Color(0xFF10B981),
                  title: "Rider Dispatch",
                  value: "1 Courier",
                  subtext: "Avg delivery time: 14 mins",
                  ratingText: "★ 4.29 Rating",
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // Revenue & Orders Timeline Chart Card
        _buildTimelineChartCard(),

        const SizedBox(height: 24),

        // 2 Columns: Best Selling Groceries (Left) + Payment Channels Donut (Right)
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildBestSellingGroceriesCard()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildPaymentChannelsCard()),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildBestSellingGroceriesCard(),
                  const SizedBox(height: 20),
                  _buildPaymentChannelsCard(),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 24),

        // Bottom Card: Live Orders & Rider Station (1 ACTIVE)
        _buildLiveOrdersRiderStationCard(),
      ],
    );
  }

  Widget _buildTimeFilterChip(String label) {
    final isSelected = _revenueTimeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _revenueTimeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  subtext,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor ?? const Color(0xFF10B981)),
                  ),
                ),
              if (ratingText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ratingText,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineChartCard() {
    final timelineDays = [
      {"date": "Oct 10", "height": 0.25, "orders": 1},
      {"date": "Oct 11", "height": 0.40, "orders": 1},
      {"date": "Oct 12", "height": 0.30, "orders": 1},
      {"date": "Oct 13", "height": 0.55, "orders": 2},
      {"date": "Oct 14", "height": 0.70, "orders": 2},
      {"date": "Oct 15", "height": 0.80, "orders": 2},
      {"date": "Oct 16", "height": 1.00, "orders": 3, "isPeak": true},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                  Icon(Icons.bar_chart_rounded, color: Color(0xFF4F46E5), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Revenue & Orders Timeline",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "Peak Day: ₹275",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.circle, color: Color(0xFF4F46E5), size: 8),
              SizedBox(width: 4),
              Text("Sales (₹)", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              SizedBox(width: 14),
              Icon(Icons.trending_up, color: Color(0xFF10B981), size: 14),
              SizedBox(width: 4),
              Text("Orders", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: timelineDays.map((d) {
                final ratio = (d['height'] as num).toDouble();
                final date = d['date'] as String;
                final isPeak = d['isPeak'] == true;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 100 * ratio,
                        width: 28,
                        decoration: BoxDecoration(
                          color: isPeak ? const Color(0xFF4F46E5) : const Color(0xFF818CF8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellingGroceriesCard() {
    final bestSellers = [
      {"rank": "1", "name": "Amul Butter 500g", "units": "24", "rev": "₹6,600", "img": "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=100&auto=format&fit=crop&q=60"},
      {"rank": "2", "name": "Aashirvaad Atta 5kg", "units": "18", "rev": "₹4,410", "img": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=100&auto=format&fit=crop&q=60"},
      {"rank": "3", "name": "Amul Cheese Slices 200g", "units": "12", "rev": "₹1,740", "img": "https://images.unsplash.com/photo-1624806992066-5ffcf7ca186b?w=100&auto=format&fit=crop&q=60"},
      {"rank": "4", "name": "Amul Taaza Milk 1L", "units": "10", "rev": "₹560", "img": "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=100&auto=format&fit=crop&q=60"},
      {"rank": "5", "name": "Britannia Brown Bread 400g", "units": "8", "rev": "₹400", "img": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=100&auto=format&fit=crop&q=60"},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                  Icon(Icons.menu_book_rounded, color: Color(0xFFF59E0B), size: 18),
                  SizedBox(width: 8),
                  Text("Best Selling Groceries", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = 1),
                child: const Text("View all", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Header row
          Row(
            children: const [
              SizedBox(width: 24, child: Text("#", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              Expanded(flex: 3, child: Text("Item", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              Expanded(child: Text("Units", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              Expanded(child: Text("Revenue", textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
            ],
          ),
          const Divider(height: 16),
          ...bestSellers.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 24, child: Text(item['rank']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)))),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(item['img']!, width: 28, height: 28, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  Expanded(child: Text(item['units']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                  Expanded(child: Text(item['rev']!, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF0F172A)))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentChannelsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF4F46E5), size: 18),
              SizedBox(width: 8),
              Text("Payment Channels", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Donut Chart Graphic
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4F46E5), width: 14),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("₹275", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                      Text("Total Sales", style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Channel Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: Color(0xFF4F46E5), size: 8),
                            SizedBox(width: 6),
                            Text("UPI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ],
                        ),
                        Text("89% (₹234)", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: Color(0xFF2563EB), size: 8),
                            SizedBox(width: 6),
                            Text("Card", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ],
                        ),
                        Text("10%", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: Color(0xFFF59E0B), size: 8),
                            SizedBox(width: 6),
                            Text("COD", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ],
                        ),
                        Text("1% (₹74)", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveOrdersRiderStationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  const Text("Live Orders & Rider Station", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                    child: const Text("1 ACTIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = 2), // Go to Hub Orders
                child: const Text("View all", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Active order row matching panel 1
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("#101", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                            child: const Text("PLACED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text("Aarav Choudhury • 9810000100", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                      const Text("3 MG Road, Indiranagar, Karnataka - 560038", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network("https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=100&auto=format&fit=crop&q=60", width: 36, height: 36, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("1 Item", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        Text("₹275.00", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Text("🛵", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Siddharth Mehta", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text("★ 4.0", style: TextStyle(fontSize: 11, color: Color(0xFFD97706))),
                      ],
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showCallDialog(context, "Siddharth Mehta", "9810000100"),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                        child: const Icon(Icons.call, size: 14, color: Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _updateOrderStatus(101, "Packing"),
                  child: const Text("Pack Groceries", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 2: HUB INVENTORY (MIDDLE PANEL)
  // ==========================================
  Widget _buildHubInventoryView() {
    final filtered = _groceries.where((item) {
      if (_inventorySearchQuery.isNotEmpty) {
        final q = _inventorySearchQuery.toLowerCase();
        if (!item.itemName.toLowerCase().contains(q)) return false;
      }
      if (_selectedCategory != "All Categories") {
        if (_selectedCategory == "Atta & Dals" && !(item.itemName.contains("Atta") || item.itemName.contains("Dal"))) return false;
        if (_selectedCategory == "Dairy & Bread" && !(item.itemName.contains("Butter") || item.itemName.contains("Milk") || item.itemName.contains("Bread") || item.itemName.contains("Cheese") || item.itemName.contains("Paneer"))) return false;
        if (_selectedCategory == "Fruits & Veg" && !(item.itemName.contains("Banana") || item.itemName.contains("Tomato") || item.itemName.contains("Onion") || item.itemName.contains("Potato"))) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Row with + Add Grocery Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hub Inventory",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage grocery products, prices and stock",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text("Add Grocery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onPressed: () => _showAddEditGroceryDialog(),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Search & Filters Row (All Categories, Availability, Stock Status, Sort)
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search products (e.g. milk, bread, atta...)",
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _inventorySearchQuery = val),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildDropdownFilter(_selectedCategory, ["All Categories", "Atta & Dals", "Dairy & Bread", "Fruits & Veg"], onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            }),
            const SizedBox(width: 10),
            _buildDropdownFilter("Availability", ["Availability", "In Stock", "Out of Stock"]),
            const SizedBox(width: 10),
            _buildDropdownFilter("Stock Status", ["Stock Status", "Normal", "Low Stock"]),
            const SizedBox(width: 10),
            _buildDropdownFilter("Sort: Name (A-Z)", ["Sort: Name (A-Z)", "Price: Low-High", "Price: High-Low"]),
          ],
        ),

        const SizedBox(height: 20),

        // Inventory Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 32, child: Icon(Icons.check_box_outline_blank, size: 18, color: Color(0xFF94A3B8))),
                    Expanded(flex: 3, child: Text("Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                    Expanded(flex: 2, child: Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                    Expanded(child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                    Expanded(child: Text("Stock", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                    Expanded(child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                    SizedBox(width: 80, child: Text("Actions", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Rows
              ...filtered.map((item) => _buildInventoryTableRow(item)),

              // Table Footer: Showing 1-10 of 28 products + Pagination
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Showing 1-${filtered.length} of ${filtered.length} products", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Row(
                      children: [
                        _buildPaginationBtn("<", isSelected: false),
                        const SizedBox(width: 4),
                        _buildPaginationBtn("1", isSelected: true),
                        const SizedBox(width: 4),
                        _buildPaginationBtn("2", isSelected: false),
                        const SizedBox(width: 4),
                        _buildPaginationBtn("3", isSelected: false),
                        const SizedBox(width: 4),
                        _buildPaginationBtn(">", isSelected: false),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(String initial, List<String> options, {ValueChanged<String?>? onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButton<String>(
        value: initial,
        underline: const SizedBox(),
        isDense: true,
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A))))).toList(),
        onChanged: onChanged ?? (_) {},
      ),
    );
  }

  Widget _buildInventoryTableRow(GroceryItemModel item) {
    final isSelected = _selectedInventoryRows.contains(item.itemName);
    final isAvailable = _itemStatusMap[item.itemName] ?? true;
    final isLowStock = item.availableCount < 15;

    String categoryName = "Dairy & Bread";
    Color catBg = const Color(0xFFEFF6FF);
    Color catText = const Color(0xFF2563EB);

    if (item.itemName.contains("Atta") || item.itemName.contains("Dal")) {
      categoryName = "Atta & Dals";
      catBg = const Color(0xFFEEF2FF);
      catText = const Color(0xFF4F46E5);
    } else if (item.itemName.contains("Banana") || item.itemName.contains("Tomato") || item.itemName.contains("Onion") || item.itemName.contains("Potato")) {
      categoryName = "Fruits & Veg";
      catBg = const Color(0xFFECFDF5);
      catText = const Color(0xFF10B981);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 32,
            child: Checkbox(
              value: isSelected,
              activeColor: const Color(0xFF4F46E5),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedInventoryRows.add(item.itemName);
                  } else {
                    _selectedInventoryRows.remove(item.itemName);
                  }
                });
              },
            ),
          ),

          // Product Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ItemImageWidget(
                    imageUrl: item.imageUrl,
                    itemName: item.itemName,
                    isGrocery: true,
                    width: 42,
                    height: 42,
                    borderRadius: 8,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                      Text("#SKU-${item.itemName.hashCode.abs() % 1000}", style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category Badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: catBg, borderRadius: BorderRadius.circular(6)),
                child: Text(categoryName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: catText)),
              ),
            ),
          ),

          // Price
          Expanded(
            child: Text("₹${item.price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
          ),

          // Stock with Low-Stock Indicator
          Expanded(
            child: Text(
              "${item.availableCount} units",
              style: TextStyle(
                fontWeight: isLowStock ? FontWeight.w900 : FontWeight.w600,
                fontSize: 12,
                color: isLowStock ? const Color(0xFFEF4444) : const Color(0xFF334155),
              ),
            ),
          ),

          // Status Switch
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isAvailable,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (val) => setState(() => _itemStatusMap[item.itemName] = val),
                ),
              ),
            ),
          ),

          // Actions: Edit & Delete
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB), size: 18),
                  tooltip: "Edit Item",
                  onPressed: () => _showAddEditGroceryDialog(existingItem: item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                  tooltip: "Delete Item",
                  onPressed: () => _deleteGroceryItem(item.itemName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBtn(String text, {required bool isSelected}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 3: HUB ORDERS (RIGHT PANEL)
  // ==========================================
  Widget _buildHubOrdersView() {
    final statusTabs = [
      "All (${_incomingGroceryOrders.length})",
      "Placed (${_incomingGroceryOrders.where((o) => o.orderStatus == 'Placed').length})",
      "Packing (${_incomingGroceryOrders.where((o) => o.orderStatus == 'Packing').length})",
      "Ready (${_incomingGroceryOrders.where((o) => o.orderStatus == 'Ready').length})",
      "Dispatched (${_incomingGroceryOrders.where((o) => o.orderStatus == 'Dispatched' || o.orderStatus == 'Out for Delivery').length})",
      "Delivered (${_incomingGroceryOrders.where((o) => o.orderStatus == 'Delivered').length})",
    ];

    final filtered = _incomingGroceryOrders.where((o) {
      if (_orderStatusFilter == "All") return true;
      if (_orderStatusFilter == "Dispatched") {
        return o.orderStatus == "Dispatched" || o.orderStatus == "Out for Delivery";
      }
      return o.orderStatus == _orderStatusFilter;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hub Orders",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage incoming orders and track deliveries",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
                PopupMenuButton<String>(
                  initialValue: _selectedOrderDateFilter,
                  onSelected: (val) {
                    setState(() => _selectedOrderDateFilter = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Filtered orders for $val"), duration: const Duration(seconds: 1)),
                    );
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "Today", child: Text("Today")),
                    const PopupMenuItem(value: "Yesterday", child: Text("Yesterday")),
                    const PopupMenuItem(value: "This Week", child: Text("This Week")),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Text(_selectedOrderDateFilter, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
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
              final tabKey = tab.startsWith("All") ? "All" : tab.split(" ")[0];
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

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text("No hub orders for this status.", style: TextStyle(color: Color(0xFF64748B))),
            ),
          )
        else
          ...filtered.map((ord) => _buildHubOrderCard(ord)),
      ],
    );
  }

  Widget _buildHubOrderCard(OrderModel ord) {
    Color statusBg = const Color(0xFFFEF3C7);
    Color statusText = const Color(0xFFD97706);

    if (ord.orderStatus == "Packing") {
      statusBg = const Color(0xFFEEF2FF);
      statusText = const Color(0xFF4F46E5);
    } else if (ord.orderStatus == "Ready") {
      statusBg = const Color(0xFFE0F2FE);
      statusText = const Color(0xFF0284C7);
    } else if (ord.orderStatus == "Dispatched" || ord.orderStatus == "Out for Delivery") {
      statusBg = const Color(0xFFF3E8FF);
      statusText = const Color(0xFF7E22CE);
    } else if (ord.orderStatus == "Delivered") {
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF10B981);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // Order ID, Status, Time, Total, Payment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "#${ord.orderId}",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      ord.orderStatus.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusText),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    ord.orderDate ?? "2 mins ago",
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "₹${ord.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Customer and Payment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showCallDialog(context, ord.userName ?? "Customer", ord.userPhone ?? "9810000100"),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        "${ord.userName ?? 'Customer'} • ${ord.userPhone ?? '9810000100'}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.phone_in_talk_outlined, size: 13, color: Color(0xFF4F46E5)),
                    ],
                  ),
                ),
              ),
              Text(
                "Payment: ${ord.paymentMethod ?? 'UPI'}",
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFEF4444)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ord.deliveryAddress.isNotEmpty ? ord.deliveryAddress : "Indiranagar, Bengaluru - 560038",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Items preview container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ord.orderId == 100
                            ? "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=100&auto=format&fit=crop&q=60"
                            : "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=100&auto=format&fit=crop&q=60",
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ord.orderId == 100 ? "Aashirvaad Atta 5kg" : "Amul Butter 500g",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          ord.orderId == 100 ? "2 x ₹110.00" : "1 x ₹275.00",
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showOrderItemsDialog(context, ord),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("View Items (1)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4F46E5))),
                      Icon(Icons.chevron_right, size: 16, color: Color(0xFF4F46E5)),
                    ],
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
                        ? "Courier: ${ord.agentName} ★ ${ord.agentRating ?? 4.0}"
                        : "Assign Courier ⌄",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showCallDialog(context, ord.agentName ?? "Courier", ord.agentPhone ?? "9810000100"),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                      child: const Icon(Icons.call, size: 14, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),

              // Status Transition Buttons
              if (ord.orderStatus == "Placed")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _updateOrderStatus(ord.orderId, "Packing"),
                  child: const Text("Pack & Prepare", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              else if (ord.orderStatus == "Packing")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _updateOrderStatus(ord.orderId, "Ready"),
                  child: const Text("Ready for Dispatch", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              else if (ord.orderStatus == "Ready")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _updateOrderStatus(ord.orderId, "Dispatched"),
                  child: const Text("Mark as Dispatched", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                  child: const Text("Completed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981))),
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
        const Text("Dark Store Settlements & Ledger", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        const Text("Direct inventory reimbursement and dark store partner payouts", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
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
              const Text("Automated Dark Store Settlement: Every Monday 09:00 AM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 5: ANALYTICS
  // ==========================================
  Widget _buildAnalyticsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        Text("Hub Analytics & Turnaround Times", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        SizedBox(height: 4),
        Text("Packing velocity, stock replenishment schedules and pick rate", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        SizedBox(height: 20),
        Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("Average Dark Store Pick & Pack Time: 3.8 minutes (Target: < 5 mins)"),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 6: SETTINGS
  // ==========================================
  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Hub Settings & Operations", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        const Text("Manage dispatch parameters, barcode scanners and location address", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        const SizedBox(height: 20),

        // Dark Store Details Card
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
                    child: const Icon(Icons.warehouse_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dark Store Hub #$_storeId", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text("📍 $_storeStreet, $_storeArea, $_storeState - $_storePincode", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
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
                  Text("4.29 ★ Dispatch Rating", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text("Edit Hub Address", style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _showEditDarkStoreDialog,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Operational switches
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.sensors_rounded, color: Color(0xFF10B981)),
                title: const Text("Hub Online for Instant 10-Min Delivery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text("Enable customer grocery order placements", style: TextStyle(fontSize: 12)),
                value: _isStoreActive,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) => setState(() => _isStoreActive = val),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.qr_code_scanner, color: Color(0xFF4F46E5)),
                title: const Text("Barcode Verification on Pack", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text("Require SKU scan before tagging bag as ready", style: TextStyle(fontSize: 12)),
                value: _autoBarcodeScan,
                activeThumbColor: const Color(0xFF4F46E5),
                onChanged: (val) => setState(() => _autoBarcodeScan = val),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
                title: const Text("Low Stock Alert Threshold", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("Alert manager when units drop below $_reorderThreshold", style: const TextStyle(fontSize: 12)),
                trailing: DropdownButton<int>(
                  value: _reorderThreshold,
                  underline: const SizedBox(),
                  items: [5, 10, 15, 20].map((t) => DropdownMenuItem(value: t, child: Text("$t units"))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _reorderThreshold = val);
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.wifi_tethering, color: Color(0xFF4F46E5)),
                title: const Text("Backend Server Config", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("Connecting to: ${ApiService.baseUrl.replaceAll('http://', '').replaceAll('/api', '')}", style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => ServerConfigDialog.show(context, onSaved: () => setState(() {})),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Logout
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            label: const Text("Log Out of Dark Store Portal", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14)),
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

  void _showEditDarkStoreDialog() {
    final areaCtrl = TextEditingController(text: _storeArea);
    final streetCtrl = TextEditingController(text: _storeStreet);
    final stateCtrl = TextEditingController(text: _storeState);
    final pincodeCtrl = TextEditingController(text: _storePincode);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Dark Store Details", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: "Hub Area", prefixIcon: Icon(Icons.location_city))),
            const SizedBox(height: 12),
            TextField(controller: streetCtrl, decoration: const InputDecoration(labelText: "Street Address", prefixIcon: Icon(Icons.streetview))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: stateCtrl, decoration: const InputDecoration(labelText: "State"))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: pincodeCtrl, decoration: const InputDecoration(labelText: "Pincode"))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            onPressed: () async {
              final newArea = areaCtrl.text.trim();
              final newStreet = streetCtrl.text.trim();
              final newState = stateCtrl.text.trim();
              final newPincode = pincodeCtrl.text.trim();

              try {
                await ApiService.updateDarkStore(_storeId, {
                  "area": newArea,
                  "street": newStreet,
                  "state": newState,
                  "pincode": newPincode,
                });
              } catch (_) {}

              setState(() {
                _storeArea = newArea;
                _storeStreet = newStreet;
                _storeState = newState;
                _storePincode = newPincode;
              });
              widget.storeData['DS_Area'] = newArea;
              widget.storeData['DS_Street'] = newStreet;
              widget.storeData['DS_State'] = newState;
              widget.storeData['DS_Pincode'] = newPincode;

              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Dark store details updated!"), backgroundColor: Color(0xFF10B981)),
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

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/dbms_settings_service.dart';
import '../../models/models.dart';
import '../../widgets/dbms_operation_modal.dart';
import '../role_selection_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserDashboardScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  late int _userId;
  late String _userName;
  late String _userPhone;

  List<RestaurantModel> _restaurants = [];
  List<DarkStoreModel> _darkStores = [];
  List<OrderModel> _myOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userId = widget.userData['User_Id'] ?? widget.userData['userId'] ?? 1;
    _userName = widget.userData['User_Name'] ?? widget.userData['userName'] ?? 'Customer';
    _userPhone = widget.userData['User_Phone'] ?? widget.userData['userPhone'] ?? '';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final rests = await ApiService.getRestaurants();
      final stores = await ApiService.getDarkStores();
      final orders = await ApiService.getUserOrders(_userId);
      if (mounted) {
        setState(() {
          _restaurants = rests;
          _darkStores = stores;
          _myOrders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  // --- PLACE ORDER DIALOG ---
  void _showOrderDialog({required String itemName, required double price, required String type}) {
    int quantity = 1;
    String paymentMethod = "UPI";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text("Order $itemName"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Unit Price: ₹${price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Quantity:"),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: quantity > 1 ? () => setModalState(() => quantity--) : null,
                      ),
                      Text("$quantity", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setModalState(() => quantity++),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(labelText: "Payment Method"),
                items: ["UPI", "Credit Card", "Debit Card", "Cash on Delivery"]
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setModalState(() => paymentMethod = v!),
              ),
              const SizedBox(height: 16),
              Text(
                "Total Amount: ₹${(price * quantity).toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);

                final totalAmount = price * quantity;
                final sqlStatement = """INSERT INTO orders (User_Id, PlacedAt, Delivery_Addr)
VALUES ($_userId, NOW(), 'Default Customer Address');

INSERT INTO ${type == 'Restaurant' ? 'order_item' : 'order_grocery'} (Order_Id, Item_Name, Quantity)
VALUES (LAST_INSERT_ID(), '$itemName', $quantity);

INSERT INTO payment (Order_Id, Payment_Method, Amount)
VALUES (LAST_INSERT_ID(), '$paymentMethod', ${totalAmount.toStringAsFixed(2)});""";

                await DbmsOperationModal.show(
                  context: context,
                  title: "Placing $type Order ($itemName)",
                  tableName: "orders",
                  operationType: DbmsOpType.insert,
                  sqlStatement: sqlStatement,
                  sampleColumns: {
                    "User_Id": "$_userId",
                    "Item_Name": itemName,
                    "Amount": totalAmount.toStringAsFixed(2),
                    "Method": paymentMethod,
                  },
                  executionTask: () => ApiService.placeOrder({
                    "user_id": _userId,
                    "order_type": type,
                    "payment_method": paymentMethod,
                    "items": [
                      {"name": itemName, "quantity": quantity, "price": price}
                    ]
                  }),
                  onSuccess: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🎉 Order successfully placed & committed to MySQL!"), backgroundColor: Colors.green),
                    );
                    _loadData();
                  },
                );
              },
              child: const Text("Confirm Order"),
            ),
          ],
        ),
      ),
    );
  }

  // --- RESTAURANT MENU VIEW ---
  void _openRestaurantMenu(RestaurantModel restaurant) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => FutureBuilder<List<RestaurantItemModel>>(
        future: ApiService.getRestaurantMenu(restaurant.restId),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
          }
          final items = snapshot.data!;
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (ctx, scrollController) => Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(restaurant.rName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(restaurant.rLocation, style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 24),
                  if (items.isEmpty)
                    const Center(child: Text("No dishes available."))
                  else
                    ...items.map((item) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Text(item.isVeg ? "🟢" : "🔴", style: const TextStyle(fontSize: 20)),
                            title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(item.foodName ?? ""),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("₹${item.finalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                if (item.discount > 0)
                                  Text("${item.discount.toStringAsFixed(0)}% OFF", style: const TextStyle(fontSize: 11, color: Colors.green)),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _showOrderDialog(itemName: item.itemName, price: item.finalPrice, type: "Restaurant");
                            },
                          ),
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi, $_userName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Phone: $_userPhone", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          const DbmsSimulationToggleSwitch(),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.logout), tooltip: "Log Out", onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                // 1. RESTAURANTS VIEW
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _restaurants.length,
                    itemBuilder: (ctx, i) {
                      final r = _restaurants[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFEEF2FF),
                            child: Text("🍽️", style: TextStyle(fontSize: 20)),
                          ),
                          title: Text(r.rName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text("${r.rLocation} • ⭐ ${r.rRating.toStringAsFixed(1)}"),
                          trailing: ElevatedButton(
                            onPressed: () => _openRestaurantMenu(r),
                            child: const Text("View Menu"),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. DARK STORE GROCERIES VIEW
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _darkStores.length,
                    itemBuilder: (ctx, i) {
                      final s = _darkStores[i];
                      return FutureBuilder<List<GroceryItemModel>>(
                        future: ApiService.getStoreGroceries(s.storeId),
                        builder: (ctx, snapshot) {
                          final groceries = snapshot.data ?? [];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text("🏬", style: TextStyle(fontSize: 22)),
                                      const SizedBox(width: 10),
                                      Text("Dark Store #${s.storeId} — ${s.dsArea ?? ''}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  if (groceries.isEmpty)
                                    const Text("No items available.", style: TextStyle(color: Colors.grey))
                                  else
                                    ...groceries.map((g) => ListTile(
                                          title: Text(g.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text("In Stock: ${g.availableCount}"),
                                          trailing: ElevatedButton(
                                            onPressed: g.availableCount > 0 ? () => _showOrderDialog(itemName: g.itemName, price: g.price, type: "Grocery") : null,
                                            child: Text("₹${g.price.toStringAsFixed(2)}"),
                                          ),
                                        )),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // 3. ORDER HISTORY VIEW (READ & CANCEL)
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: _myOrders.isEmpty
                      ? const Center(child: Text("No orders placed yet."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _myOrders.length,
                          itemBuilder: (ctx, i) {
                            final ord = _myOrders[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Order #${ord.orderId} (${ord.orderType})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Chip(
                                          label: Text(ord.orderStatus),
                                          backgroundColor: ord.orderStatus == "Delivered" ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text("Total Amount: ₹${ord.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                                    Text("Payment: ${ord.paymentMethod ?? 'N/A'} • Agent: ${ord.agentName ?? 'Pending'}", style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                          label: const Text("Cancel / Delete", style: TextStyle(color: Colors.red)),
                                          onPressed: () async {
                                            final sqlStatement = "DELETE FROM orders WHERE Order_Id = ${ord.orderId};";
                                            await DbmsOperationModal.show(
                                              context: context,
                                              title: "Canceling Order #${ord.orderId}",
                                              tableName: "orders",
                                              operationType: DbmsOpType.delete,
                                              sqlStatement: sqlStatement,
                                              sampleColumns: {
                                                "Order_Id": "${ord.orderId}",
                                                "User_Id": "$_userId",
                                                "Status": ord.orderStatus,
                                              },
                                              executionTask: () => ApiService.deleteOrder(ord.orderId),
                                              onSuccess: () {
                                                _loadData();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: "Restaurants"),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: "Groceries"),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: "My Orders"),
        ],
      ),
    );
  }
}

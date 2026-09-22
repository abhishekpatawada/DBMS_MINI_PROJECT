import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/dbms_settings_service.dart';
import '../../models/models.dart';
import '../../widgets/dbms_operation_modal.dart';
import '../role_selection_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> restaurantData;

  const RestaurantDashboardScreen({Key? key, required this.restaurantData}) : super(key: key);

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  late int _restId;
  late String _restName;
  late String _restLocation;
  List<RestaurantItemModel> _menuItems = [];
  List<OrderModel> _incomingOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _restId = widget.restaurantData['Rest_Id'] ?? widget.restaurantData['restId'] ?? 1;
    _restName = widget.restaurantData['RName'] ?? widget.restaurantData['rname'] ?? 'Restaurant';
    _restLocation = widget.restaurantData['RLocation'] ?? widget.restaurantData['rlocation'] ?? '';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final menu = await ApiService.getRestaurantMenu(_restId);
      final allOrders = await ApiService.getOrders();
      final restOrders = allOrders.where((o) => o.orderType == "Restaurant").toList();

      if (mounted) {
        setState(() {
          _menuItems = menu;
          _incomingOrders = restOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditDishDialog({RestaurantItemModel? existingItem}) {
    final nameController = TextEditingController(text: existingItem?.itemName ?? "");
    final descController = TextEditingController(text: existingItem?.foodName ?? "");
    final priceController = TextEditingController(text: existingItem?.basePrice.toString() ?? "150");
    final discountController = TextEditingController(text: existingItem?.discount.toString() ?? "0");
    bool isVeg = existingItem?.isVeg ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existingItem == null ? "Add New Dish" : "Edit Dish"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (existingItem == null)
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Dish Name *"),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Category / Description"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Base Price (₹) *"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Discount (%)"),
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text("Vegetarian"),
                  value: isVeg,
                  onChanged: (v) => setDialogState(() => isVeg = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final basePrice = double.tryParse(priceController.text) ?? 100.0;
                final discount = double.tryParse(discountController.text) ?? 0.0;
                final dishName = nameController.text.trim();
                final desc = descController.text.trim();
                final finalPrice = basePrice - (basePrice * discount / 100.0);

                Navigator.pop(ctx);

                final sqlStatement = existingItem == null
                    ? """INSERT INTO rest_items (Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice)
VALUES ($_restId, '$dishName', '$desc', $isVeg, ${basePrice.toStringAsFixed(2)}, ${discount.toStringAsFixed(2)}, ${finalPrice.toStringAsFixed(2)});"""
                    : """UPDATE rest_items
SET BasePrice = ${basePrice.toStringAsFixed(2)}, Discount = ${discount.toStringAsFixed(2)}, FinalPrice = ${finalPrice.toStringAsFixed(2)}
WHERE Rest_Id = $_restId AND Item_Name = '${existingItem.itemName}';""";

                await DbmsOperationModal.show(
                  context: context,
                  title: existingItem == null ? "Adding Dish ($dishName)" : "Updating Dish ($dishName)",
                  tableName: "rest_items",
                  operationType: existingItem == null ? DbmsOpType.insert : DbmsOpType.update,
                  sqlStatement: sqlStatement,
                  sampleColumns: {
                    "Item_Name": dishName,
                    "BasePrice": basePrice.toStringAsFixed(2),
                    "Discount": discount.toStringAsFixed(0),
                  },
                  executionTask: () => existingItem == null
                      ? ApiService.addMenuItem(_restId, {
                          "item_name": dishName,
                          "food_name": desc,
                          "is_veg": isVeg,
                          "base_price": basePrice,
                          "discount": discount,
                        })
                      : ApiService.updateMenuItem(_restId, existingItem.itemName, {
                          "new_item_name": existingItem.itemName,
                          "food_name": desc,
                          "is_veg": isVeg,
                          "base_price": basePrice,
                          "discount": discount,
                        }),
                  onSuccess: () {
                    _loadData();
                  },
                );
              },
              child: const Text("Save Dish"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🏪 $_restName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(_restLocation, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            const DbmsSimulationToggleSwitch(),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Log Out",
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                  (route) => false,
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: "Menu Items (CRUD)"),
              Tab(icon: Icon(Icons.receipt_long), text: "Live Orders"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // 1. MENU CRUD VIEW
                  Scaffold(
                    floatingActionButton: FloatingActionButton.extended(
                      onPressed: () => _showAddEditDishDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text("Add Dish"),
                    ),
                    body: _menuItems.isEmpty
                        ? const Center(child: Text("No menu items added yet."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _menuItems.length,
                            itemBuilder: (ctx, i) {
                              final item = _menuItems[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Text(item.isVeg ? "🟢" : "🔴", style: const TextStyle(fontSize: 22)),
                                  title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("Price: ₹${item.finalPrice.toStringAsFixed(2)} (${item.discount.toStringAsFixed(0)}% off)"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        onPressed: () => _showAddEditDishDialog(existingItem: item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () async {
                                          final sqlStatement = "DELETE FROM rest_items WHERE Rest_Id = $_restId AND Item_Name = '${item.itemName}';";
                                          await DbmsOperationModal.show(
                                            context: context,
                                            title: "Deleting Dish (${item.itemName})",
                                            tableName: "rest_items",
                                            operationType: DbmsOpType.delete,
                                            sqlStatement: sqlStatement,
                                            sampleColumns: {
                                              "Rest_Id": "$_restId",
                                              "Item_Name": item.itemName,
                                              "BasePrice": "${item.basePrice}",
                                            },
                                            executionTask: () => ApiService.deleteMenuItem(_restId, item.itemName),
                                            onSuccess: () {
                                              _loadData();
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // 2. LIVE ORDERS VIEW
                  _incomingOrders.isEmpty
                      ? const Center(child: Text("No incoming food orders."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _incomingOrders.length,
                          itemBuilder: (ctx, i) {
                            final ord = _incomingOrders[i];
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
                                        Text("Order #${ord.orderId}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Chip(label: Text(ord.orderStatus)),
                                      ],
                                    ),
                                    Text("Customer: ${ord.userName ?? 'N/A'} • Total: ₹${ord.totalAmount.toStringAsFixed(2)}"),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await ApiService.updateOrderStatus(ord.orderId, "Preparing");
                                            _loadData();
                                          },
                                          child: const Text("Preparing"),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed: () async {
                                            await ApiService.updateOrderStatus(ord.orderId, "Out for Delivery");
                                            _loadData();
                                          },
                                          child: const Text("Ready for Dispatch"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
      ),
    );
  }
}

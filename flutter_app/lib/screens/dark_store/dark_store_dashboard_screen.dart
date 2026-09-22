import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/dbms_settings_service.dart';
import '../../models/models.dart';
import '../../widgets/dbms_operation_modal.dart';
import '../role_selection_screen.dart';

class DarkStoreDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> storeData;

  const DarkStoreDashboardScreen({Key? key, required this.storeData}) : super(key: key);

  @override
  State<DarkStoreDashboardScreen> createState() => _DarkStoreDashboardScreenState();
}

class _DarkStoreDashboardScreenState extends State<DarkStoreDashboardScreen> {
  late int _storeId;
  late String _storeArea;
  List<GroceryItemModel> _groceries = [];
  List<OrderModel> _incomingGroceryOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storeId = widget.storeData['Store_Id'] ?? widget.storeData['storeId'] ?? 1;
    _storeArea = widget.storeData['DS_Area'] ?? widget.storeData['dsArea'] ?? 'Hub';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getStoreGroceries(_storeId);
      final allOrders = await ApiService.getOrders();
      final gOrders = allOrders.where((o) => o.orderType == "Grocery").toList();

      if (mounted) {
        setState(() {
          _groceries = items;
          _incomingGroceryOrders = gOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditGroceryDialog({GroceryItemModel? existingItem}) {
    final nameController = TextEditingController(text: existingItem?.itemName ?? "");
    final priceController = TextEditingController(text: existingItem?.price.toString() ?? "50");
    final countController = TextEditingController(text: existingItem?.availableCount.toString() ?? "30");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingItem == null ? "Add Grocery Item" : "Update Stock & Price"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (existingItem == null)
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Item Name *"),
              ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Unit Price (₹) *"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stock Available *"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(priceController.text) ?? 50.0;
              final count = int.tryParse(countController.text) ?? 10;
              final itemName = nameController.text.trim();

              Navigator.pop(ctx);

              final sqlStatement = existingItem == null
                  ? """INSERT INTO groceries (Store_Id, Item_Name, Price, Available_count)
VALUES ($_storeId, '$itemName', ${price.toStringAsFixed(2)}, $count);"""
                  : """UPDATE groceries
SET Price = ${price.toStringAsFixed(2)}, Available_count = $count
WHERE Store_Id = $_storeId AND Item_Name = '${existingItem.itemName}';""";

              await DbmsOperationModal.show(
                context: context,
                title: existingItem == null ? "Adding Grocery Item ($itemName)" : "Updating Stock ($itemName)",
                tableName: "groceries",
                operationType: existingItem == null ? DbmsOpType.insert : DbmsOpType.update,
                sqlStatement: sqlStatement,
                sampleColumns: {
                  "Item_Name": itemName,
                  "Price": price.toStringAsFixed(2),
                  "Count": "$count",
                },
                executionTask: () => existingItem == null
                    ? ApiService.addGroceryItem(_storeId, {
                        "item_name": itemName,
                        "price": price,
                        "available_count": count,
                      })
                    : ApiService.updateGroceryItem(_storeId, existingItem.itemName, {
                        "new_item_name": existingItem.itemName,
                        "price": price,
                        "available_count": count,
                      }),
                onSuccess: () {
                  _loadData();
                },
              );
            },
            child: const Text("Save Item"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("🏬 Dark Store Hub #$_storeId ($_storeArea)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              Tab(icon: Icon(Icons.inventory_2), text: "Inventory (CRUD)"),
              Tab(icon: Icon(Icons.shopping_cart), text: "Store Orders"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // 1. INVENTORY CRUD VIEW
                  Scaffold(
                    floatingActionButton: FloatingActionButton.extended(
                      onPressed: () => _showAddEditGroceryDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text("Add Grocery"),
                    ),
                    body: _groceries.isEmpty
                        ? const Center(child: Text("No groceries in this dark store."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _groceries.length,
                            itemBuilder: (ctx, i) {
                              final item = _groceries[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("Price: ₹${item.price.toStringAsFixed(2)} • Stock: ${item.availableCount}"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        onPressed: () => _showAddEditGroceryDialog(existingItem: item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () async {
                                          final sqlStatement = "DELETE FROM groceries WHERE Store_Id = $_storeId AND Item_Name = '${item.itemName}';";
                                          await DbmsOperationModal.show(
                                            context: context,
                                            title: "Deleting Item (${item.itemName})",
                                            tableName: "groceries",
                                            operationType: DbmsOpType.delete,
                                            sqlStatement: sqlStatement,
                                            sampleColumns: {
                                              "Store_Id": "$_storeId",
                                              "Item_Name": item.itemName,
                                              "Price": "${item.price}",
                                            },
                                            executionTask: () => ApiService.deleteGroceryItem(_storeId, item.itemName),
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

                  // 2. STORE ORDERS VIEW
                  _incomingGroceryOrders.isEmpty
                      ? const Center(child: Text("No grocery orders at this moment."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _incomingGroceryOrders.length,
                          itemBuilder: (ctx, i) {
                            final ord = _incomingGroceryOrders[i];
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
                                        Text("Grocery Order #${ord.orderId}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Chip(label: Text(ord.orderStatus)),
                                      ],
                                    ),
                                    Text("Customer: ${ord.userName ?? 'N/A'} • Total: ₹${ord.totalAmount.toStringAsFixed(2)}"),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await ApiService.updateOrderStatus(ord.orderId, "Preparing");
                                        _loadData();
                                      },
                                      child: const Text("Pack & Prepare"),
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

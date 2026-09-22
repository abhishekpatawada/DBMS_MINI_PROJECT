import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/dbms_settings_service.dart';
import '../../models/models.dart';
import '../../widgets/dbms_operation_modal.dart';
import '../role_selection_screen.dart';

class DeliveryAgentDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> agentData;

  const DeliveryAgentDashboardScreen({Key? key, required this.agentData}) : super(key: key);

  @override
  State<DeliveryAgentDashboardScreen> createState() => _DeliveryAgentDashboardScreenState();
}

class _DeliveryAgentDashboardScreenState extends State<DeliveryAgentDashboardScreen> {
  late int _agentId;
  late String _agentName;
  late String _vehicleNo;
  List<OrderModel> _assignedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _agentId = widget.agentData['Agent_Id'] ?? widget.agentData['agentId'] ?? 1;
    _agentName = widget.agentData['Agent_Name'] ?? widget.agentData['agentName'] ?? 'Agent';
    _vehicleNo = widget.agentData['VehicleNO'] ?? widget.agentData['vehicleNo'] ?? '';
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.getAgentOrders(_agentId);
      if (mounted) {
        setState(() {
          _assignedOrders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateStatus(int orderId, String newStatus) async {
    final sqlStatement = """UPDATE orders
SET Order_Status = '$newStatus',
    ${newStatus == 'Delivered' ? 'DeliveredAt = NOW(),' : ''}
    Agent_Id = $_agentId
WHERE Order_Id = $orderId;""";

    await DbmsOperationModal.show(
      context: context,
      title: "Updating Delivery Status (Order #$orderId)",
      tableName: "orders",
      operationType: DbmsOpType.update,
      sqlStatement: sqlStatement,
      sampleColumns: {
        "Order_Id": "$orderId",
        "Agent_Id": "$_agentId",
        "Status": newStatus,
      },
      executionTask: () => ApiService.updateOrderStatus(orderId, newStatus),
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order #$orderId marked as $newStatus & committed in MySQL"), backgroundColor: Colors.green),
        );
        _loadOrders();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🛵 $_agentName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Vehicle: $_vehicleNo", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          const DbmsSimulationToggleSwitch(),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: _assignedOrders.isEmpty
                  ? const Center(child: Text("No active delivery orders assigned."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _assignedOrders.length,
                      itemBuilder: (ctx, i) {
                        final ord = _assignedOrders[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
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
                                Text("Customer: ${ord.userName ?? 'N/A'} (${ord.userPhone ?? ''})", style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text("Order Value: ₹${ord.totalAmount.toStringAsFixed(2)} • ${ord.paymentMethod ?? 'UPI'}", style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.delivery_dining, size: 18),
                                        label: const Text("Out for Delivery"),
                                        onPressed: () => _updateStatus(ord.orderId, "Out for Delivery"),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check_circle_outline, size: 18),
                                        label: const Text("Delivered"),
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                                        onPressed: () => _updateStatus(ord.orderId, "Delivered"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

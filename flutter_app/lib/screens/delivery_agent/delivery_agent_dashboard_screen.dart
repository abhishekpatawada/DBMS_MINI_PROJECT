import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import 'delivery_agent_revenue_view.dart';
import 'delivery_agent_profile_view.dart';

class DeliveryAgentDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> agentData;

  const DeliveryAgentDashboardScreen({super.key, required this.agentData});

  @override
  State<DeliveryAgentDashboardScreen> createState() => _DeliveryAgentDashboardScreenState();
}

class _DeliveryAgentDashboardScreenState extends State<DeliveryAgentDashboardScreen> {
  int _selectedTabIndex = 0; // 0: Deliveries, 1: Earnings
  String _orderFilter = "Ongoing"; // Ongoing, Completed, Cancelled

  late int _agentId;
  late String _agentName;
  late String _agentPhone;
  late String _vehicleNo;
  late double _rating;

  List<OrderModel> _assignedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAgentInfo();
    _loadOrders();
  }

  void _initAgentInfo() {
    _agentId = widget.agentData['Agent_Id'] ?? widget.agentData['agentId'] ?? 1;
    _agentName = widget.agentData['Agent_Name'] ?? widget.agentData['agentName'] ?? 'Krishna Singh';
    _agentPhone = widget.agentData['Agent_Phone'] ?? widget.agentData['agentPhone'] ?? '9876500001';
    _vehicleNo = widget.agentData['VehicleNO'] ?? widget.agentData['vehicleNo'] ?? 'KA-08-DF-1001';
    _rating = double.tryParse(widget.agentData['Rating']?.toString() ?? '4.9') ?? 4.9;
  }

  List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        orderId: 200,
        userId: 1,
        userName: "Usha Gupta",
        userPhone: "9810000100",
        agentId: _agentId,
        agentName: _agentName,
        agentPhone: _agentPhone,
        agentVehicle: _vehicleNo,
        agentRating: _rating,
        storeId: 1,
        storeArea: "Gachibowli",
        orderType: "Grocery",
        orderStatus: "Out for Delivery",
        totalAmount: 145.00,
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "300 FC Road, Gachibowli, Telangana - 500032",
      ),
      OrderModel(
        orderId: 100,
        userId: 1,
        userName: "Usha Gupta",
        userPhone: "9810000100",
        agentId: _agentId,
        agentName: _agentName,
        agentPhone: _agentPhone,
        agentVehicle: _vehicleNo,
        agentRating: _rating,
        restId: 1,
        restName: "Dosa Hub",
        orderType: "Restaurant",
        orderStatus: "Arrived at Location",
        totalAmount: 152.00,
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "300 FC Road, Gachibowli, Telangana - 500032",
      ),
      OrderModel(
        orderId: 198,
        userId: 2,
        userName: "Karthik Verma",
        userPhone: "9823456789",
        agentId: _agentId,
        agentName: _agentName,
        agentPhone: _agentPhone,
        agentVehicle: _vehicleNo,
        agentRating: _rating,
        storeId: 2,
        storeArea: "Kondapur",
        orderType: "Grocery",
        orderStatus: "Delivered",
        totalAmount: 320.00,
        paymentMethod: "UPI",
        paymentStatus: "Paid",
        deliveryAddr: "Flat 402, Green Meadows, Kondapur, Hyderabad",
      ),
    ];
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.getAgentOrders(_agentId);
      if (mounted) {
        setState(() {
          if (orders.isNotEmpty) {
            _assignedOrders = orders;
          } else {
            _assignedOrders = _getMockOrders();
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _assignedOrders = _getMockOrders();
          _isLoading = false;
        });
      }
    }
  }

  void _updateStatus(int orderId, String newStatus) async {
    try {
      await ApiService.updateOrderStatus(orderId, newStatus);
    } catch (_) {
      // Local fallback in case of connection or mock data
    }

    if (mounted) {
      setState(() {
        _assignedOrders = _assignedOrders.map((ord) {
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
              const SizedBox(width: 10),
              Text("Order #$orderId marked as $newStatus"),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _openCallDialog(String customerName, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_rounded, color: Color(0xFF10B981), size: 22),
            ),
            const SizedBox(width: 12),
            const Text("Call Customer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dial $customerName?", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(phone, style: const TextStyle(fontSize: 16, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("This connects directly to the customer's verified delivery contact number.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.phone, size: 16, color: Colors.white),
            label: const Text("Call Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Calling $phone..."),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openNavigationModal(String address) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.near_me_rounded, color: Color(0xFF4F46E5), size: 24),
                    SizedBox(width: 10),
                    Text("Turn-by-Turn Navigation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("DESTINATION ADDRESS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.straighten_rounded, size: 16, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Text("Distance: 2.4 km", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: Color(0xFF10B981)),
                          SizedBox(width: 6),
                          Text("ETA: ~8 mins", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions_rounded, color: Colors.white),
                label: const Text("Open in Google Maps", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Launching Google Maps navigation..."),
                      backgroundColor: Color(0xFF4F46E5),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryAgentProfileView(
          agentData: widget.agentData,
          onProfileUpdated: () {
            setState(() {
              _initAgentInfo();
            });
          },
          onNavigateToDeliveries: () {
            Navigator.pop(context);
            setState(() => _selectedTabIndex = 0);
          },
          onNavigateToEarnings: () {
            Navigator.pop(context);
            setState(() => _selectedTabIndex = 1);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              // BiteHub Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFEEF2FF),
                      child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF4F46E5), size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "BiteHub",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    "Delivery Partner",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Notification Bell with Badge
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0F172A), size: 24),
                  tooltip: "Notifications",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No new system notifications"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),

            // Profile Button in top right
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: _navigateToProfile,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      _agentName.isNotEmpty ? _agentName[0].toUpperCase() : "K",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          // TAB 0: DELIVERIES (SCREEN 4)
          _buildDeliveriesView(),

          // TAB 1: REVENUE & EARNINGS (SCREEN 1 & 2)
          DeliveryAgentRevenueView(
            agentId: _agentId,
            agentName: _agentName,
            vehicleNo: _vehicleNo,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tab 0: Deliveries
            _buildNavItem(
              index: 0,
              icon: Icons.directions_bike_rounded,
              label: "Deliveries",
            ),
            // Tab 1: Earnings
            _buildNavItem(
              index: 1,
              icon: Icons.account_balance_wallet_outlined,
              label: "Earnings",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveriesView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
    }

    final ongoingOrders = _assignedOrders.where((o) => o.orderStatus != "Delivered" && o.orderStatus != "Cancelled").toList();
    final completedOrders = _assignedOrders.where((o) => o.orderStatus == "Delivered").toList();
    final cancelledOrders = _assignedOrders.where((o) => o.orderStatus == "Cancelled").toList();

    List<OrderModel> displayedOrders = ongoingOrders;
    if (_orderFilter == "Completed") {
      displayedOrders = completedOrders;
    } else if (_orderFilter == "Cancelled") {
      displayedOrders = cancelledOrders;
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: const Color(0xFF4F46E5),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on_rounded, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Active & Recent Deliveries",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Complete orders and earn more",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filter Pills Row
          Row(
            children: [
              _buildFilterPill("Ongoing (${ongoingOrders.length})", "Ongoing"),
              const SizedBox(width: 10),
              _buildFilterPill("Completed", "Completed"),
              const SizedBox(width: 10),
              _buildFilterPill("Cancelled", "Cancelled"),
            ],
          ),

          const SizedBox(height: 16),

          // Orders List
          if (displayedOrders.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline, size: 36, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No $_orderFilter Deliveries",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Incoming order dispatches will appear here automatically.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...displayedOrders.map((ord) => _buildOrderCard(ord)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, String value) {
    final isSelected = _orderFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _orderFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel ord) {
    final isGrocery = ord.orderType.toLowerCase() == "grocery" || ord.storeId != null;
    final isDelivered = ord.orderStatus == "Delivered";

    Color statusBg = const Color(0xFFEEF2FF);
    Color statusTextColor = const Color(0xFF4F46E5);

    if (ord.orderStatus == "Arrived at Location") {
      statusBg = const Color(0xFFECFDF5);
      statusTextColor = const Color(0xFF10B981);
    } else if (ord.orderStatus == "Delivered") {
      statusBg = const Color(0xFFD1FAE5);
      statusTextColor = const Color(0xFF065F46);
    } else if (ord.orderStatus == "Cancelled") {
      statusBg = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type Tag, Order ID, Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isGrocery ? const Color(0xFFFEF9C3) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isGrocery ? Icons.bolt_rounded : Icons.restaurant_rounded,
                            size: 14,
                            color: isGrocery ? const Color(0xFF854D0E) : const Color(0xFFC2410C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isGrocery ? "Hub Order" : "Bite Order",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isGrocery ? const Color(0xFF854D0E) : const Color(0xFFC2410C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "#${ord.orderId}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusTextColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ord.orderStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: statusTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Customer Name & Phone Call Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFF475569)),
                    const SizedBox(width: 8),
                    Text(
                      "${ord.userName ?? 'Customer'} (${ord.userPhone ?? '9810000100'})",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _openCallDialog(ord.userName ?? 'Customer', ord.userPhone ?? '9810000100'),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_rounded, size: 18, color: Color(0xFF10B981)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Address Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFFEF4444)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ord.deliveryAddress.isNotEmpty
                        ? ord.deliveryAddress
                        : "300 FC Road, Gachibowli, Telangana - 500032",
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF475569),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Order Amount and Payment Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Order Amount: ",
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      ),
                      Text(
                        "₹${ord.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Payment: ",
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded, size: 12, color: Color(0xFF4F46E5)),
                            const SizedBox(width: 4),
                            Text(
                              ord.paymentMethod ?? "UPI",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xFF0F172A),
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

            // Action Buttons: Navigate + Mark as Delivered
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.near_me_outlined, size: 18),
                    label: const Text(
                      "Navigate",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                      side: const BorderSide(color: Color(0xFF6366F1), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _openNavigationModal(
                      ord.deliveryAddress.isNotEmpty
                          ? ord.deliveryAddress
                          : "300 FC Road, Gachibowli, Telangana - 500032",
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      isDelivered ? Icons.verified_rounded : Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      isDelivered
                          ? "Delivered"
                          : ord.orderStatus == "Out for Delivery"
                              ? "Mark as Delivered"
                              : "Out for Delivery",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDelivered ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: isDelivered
                        ? null
                        : () {
                            if (ord.orderStatus == "Out for Delivery") {
                              _updateStatus(ord.orderId, "Delivered");
                            } else {
                              _updateStatus(ord.orderId, "Out for Delivery");
                            }
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
}

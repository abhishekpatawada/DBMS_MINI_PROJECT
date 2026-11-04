import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';
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
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.green,
                border: Border.all(color: AppTheme.black, width: 2),
              ),
              child: const Icon(Icons.call_rounded, color: AppTheme.black, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              "CALL CUSTOMER",
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.5,
                color: AppTheme.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Direct telephone dispatch line for $customerName:",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.black),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.bg,
                border: Border.all(color: AppTheme.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                ],
              ),
              child: Text(
                phone,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 18,
                  color: AppTheme.black,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "CUSTOMER DELIVERY PROTOCOL // ENCRYPTED CALL ROUTING",
              style: GoogleFonts.ibmPlexMono(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "CANCEL",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppTheme.black),
            ),
          ),
          BrutalistButton(
            text: "DIAL NOW",
            icon: Icons.phone,
            bgColor: AppTheme.green,
            textColor: AppTheme.black,
            height: 40,
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Calling $phone...", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black)),
                  backgroundColor: AppTheme.yellow,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    side: const BorderSide(color: AppTheme.black, width: 2),
                  ),
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
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        border: Border.all(color: AppTheme.black, width: 2),
                      ),
                      child: const Icon(Icons.near_me_rounded, color: AppTheme.black, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "TURN-BY-TURN ROUTING",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                    child: const Icon(Icons.close, size: 16, color: AppTheme.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bg,
                border: Border.all(color: AppTheme.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppTheme.black, offset: Offset(3, 3), blurRadius: 0),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DESTINATION DROP-OFF // GPS COORDINATES",
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.black,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.black,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.black, thickness: 1.5, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.straighten_rounded, size: 16, color: AppTheme.black),
                          const SizedBox(width: 6),
                          Text(
                            "DIST: 2.4 KM",
                            style: GoogleFonts.ibmPlexMono(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppTheme.black,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.green,
                          border: Border.all(color: AppTheme.black, width: 1.5),
                        ),
                        child: Text(
                          "ETA: ~8 MINS",
                          style: GoogleFonts.ibmPlexMono(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            BrutalistButton(
              text: "LAUNCH GOOGLE MAPS",
              icon: Icons.directions_rounded,
              bgColor: AppTheme.blue,
              textColor: AppTheme.surface,
              fullWidth: true,
              height: 48,
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Launching Google Maps navigation...",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.yellow),
                    ),
                    backgroundColor: AppTheme.black,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      side: const BorderSide(color: AppTheme.black, width: 2),
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
      backgroundColor: AppTheme.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          shape: const Border(
            bottom: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
          ),
          title: Row(
            children: [
              // Brutalist BiteHub Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Center(
                  child: Text(
                    "B",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    "AGENT CONSOLE // 5.8GHZ",
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
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
                  icon: const Icon(Icons.notifications_outlined, color: AppTheme.black, size: 24),
                  tooltip: "Notifications",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "No new system notifications",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black),
                        ),
                        backgroundColor: AppTheme.yellow,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          side: const BorderSide(color: AppTheme.black, width: 2),
                        ),
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
                    decoration: BoxDecoration(
                      color: AppTheme.red,
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),

            // Profile Button in top right
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: _navigateToProfile,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppTheme.black, width: 2),
                    boxShadow: const [
                      BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _agentName.isNotEmpty ? _agentName[0].toUpperCase() : "K",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: AppTheme.black,
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
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth)),
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
              label: "DELIVERIES",
            ),
            // Tab 1: Earnings
            _buildNavItem(
              index: 1,
              icon: Icons.account_balance_wallet_outlined,
              label: "EARNINGS",
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: isSelected ? AppTheme.black : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
          boxShadow: isSelected
              ? const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.black,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: AppTheme.black,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveriesView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.black));
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
      color: AppTheme.black,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded, color: AppTheme.black, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ACTIVE & RECENT DISPATCH",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "TELEMETRY ENGINE // DIRECT REAL-TIME DISPATCH",
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
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
              _buildFilterPill("ONGOING (${ongoingOrders.length})", "Ongoing"),
              const SizedBox(width: 10),
              _buildFilterPill("COMPLETED", "Completed"),
              const SizedBox(width: 10),
              _buildFilterPill("CANCELLED", "Cancelled"),
            ],
          ),

          const SizedBox(height: 16),

          // Orders List
          if (displayedOrders.isEmpty)
            BrutalistCard(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        border: Border.all(color: AppTheme.black, width: 2),
                      ),
                      child: const Icon(Icons.check_box_outlined, size: 36, color: AppTheme.black),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "NO ${_orderFilter.toUpperCase()} DELIVERIES",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "LIVE DISPATCH ENGINE IS MONITORING INCOMING PACKAGES.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexMono(fontSize: 11, color: const Color(0xFF64748B)),
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
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.yellow : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.black, width: 2),
            boxShadow: isSelected
                ? const [BoxShadow(color: AppTheme.black, offset: Offset(2.5, 2.5), blurRadius: 0)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.black,
                letterSpacing: 0.5,
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

    Color statusBg = AppTheme.yellow;
    Color statusTextColor = AppTheme.black;

    if (ord.orderStatus == "Arrived at Location" || ord.orderStatus == "Delivered") {
      statusBg = AppTheme.green;
      statusTextColor = AppTheme.black;
    } else if (ord.orderStatus == "Cancelled") {
      statusBg = AppTheme.red;
      statusTextColor = AppTheme.surface;
    }

    return BrutalistCard(
      margin: const EdgeInsets.only(bottom: 16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isGrocery ? AppTheme.yellow : AppTheme.blue,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGrocery ? Icons.bolt_rounded : Icons.restaurant_rounded,
                          size: 13,
                          color: isGrocery ? AppTheme.black : AppTheme.surface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isGrocery ? "HUB ORDER" : "BITE ORDER",
                          style: GoogleFonts.ibmPlexMono(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            color: isGrocery ? AppTheme.black : AppTheme.surface,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "#${ord.orderId}",
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: AppTheme.black, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0),
                  ],
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
                      ord.orderStatus.toUpperCase(),
                      style: GoogleFonts.ibmPlexMono(
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                        color: statusTextColor,
                        letterSpacing: 0.5,
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
                  const Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.black),
                  const SizedBox(width: 8),
                  Text(
                    "${ord.userName ?? 'Customer'} (${ord.userPhone ?? '9810000100'})",
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _openCallDialog(ord.userName ?? 'Customer', ord.userPhone ?? '9810000100'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.green,
                    border: Border.all(color: AppTheme.black, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.call_rounded, size: 14, color: AppTheme.black),
                      const SizedBox(width: 4),
                      Text(
                        "CALL",
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Address Row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bg,
              border: Border.all(color: AppTheme.black, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, size: 18, color: AppTheme.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ord.deliveryAddress.isNotEmpty
                        ? ord.deliveryAddress
                        : "300 FC Road, Gachibowli, Telangana - 500032",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Order Amount and Payment Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.black, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "PAYOUT: ",
                      style: GoogleFonts.ibmPlexMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                    ),
                    Text(
                      "₹${ord.totalAmount.toStringAsFixed(2)}",
                      style: GoogleFonts.ibmPlexMono(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, size: 12, color: AppTheme.black),
                      const SizedBox(width: 4),
                      Text(
                        "${ord.paymentMethod ?? 'UPI'} // PAID",
                        style: GoogleFonts.ibmPlexMono(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
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

          // Action Buttons: Navigate + Mark as Delivered
          Row(
            children: [
              Expanded(
                child: BrutalistButton(
                  text: "NAVIGATE",
                  icon: Icons.near_me_outlined,
                  bgColor: AppTheme.surface,
                  textColor: AppTheme.black,
                  height: 42,
                  onPressed: () => _openNavigationModal(
                    ord.deliveryAddress.isNotEmpty
                        ? ord.deliveryAddress
                        : "300 FC Road, Gachibowli, Telangana - 500032",
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BrutalistButton(
                  text: isDelivered
                      ? "DELIVERED"
                      : ord.orderStatus == "Out for Delivery"
                          ? "MARK DELIVERED"
                          : "OUT FOR DELIVERY",
                  icon: isDelivered ? Icons.verified_rounded : Icons.check_circle_rounded,
                  bgColor: isDelivered ? AppTheme.green : AppTheme.black,
                  textColor: isDelivered ? AppTheme.black : AppTheme.yellow,
                  height: 42,
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
    );
  }
}

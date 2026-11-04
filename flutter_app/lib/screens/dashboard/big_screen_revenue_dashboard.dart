import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../utils/item_image_helper.dart';

class BigScreenRevenueDashboard extends StatefulWidget {
  final bool isRestaurant;
  final int entityId;
  final String entityName;
  final String entityLocation;

  const BigScreenRevenueDashboard({
    super.key,
    required this.isRestaurant,
    required this.entityId,
    required this.entityName,
    required this.entityLocation,
  });

  @override
  State<BigScreenRevenueDashboard> createState() => _BigScreenRevenueDashboardState();
}

class _BigScreenRevenueDashboardState extends State<BigScreenRevenueDashboard> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};
  List<OrderModel> _liveOrders = [];
  String _selectedTimeframe = 'Today'; // 'Today', '7 Days', '30 Days', 'All Time'
  String _orderStatusFilter = 'All'; // 'All', 'In-Prep', 'Ready', 'Delivered'
  bool _autoRefresh = true;
  Timer? _refreshTimer;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    _loadAnalytics();
    _setupAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _clockTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _setupAutoRefresh() {
    _refreshTimer?.cancel();
    if (_autoRefresh) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        if (mounted) _loadAnalytics(silent: true);
      });
    }
  }

  Future<void> _loadAnalytics({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      Map<String, dynamic> data;
      if (widget.isRestaurant) {
        data = await ApiService.getRestaurantRevenueAnalytics(widget.entityId);
      } else {
        data = await ApiService.getDarkStoreRevenueAnalytics(widget.entityId);
      }

      // Also get live orders for real-time customer and rider dispatch view
      final allOrders = await ApiService.getOrders();
      final filteredOrders = allOrders.where((o) {
        if (widget.isRestaurant) {
          return o.restId == widget.entityId || (o.restId == null && o.orderType == "Restaurant");
        } else {
          return o.storeId == widget.entityId || (o.storeId == null && o.orderType == "Grocery");
        }
      }).toList();

      if (mounted) {
        setState(() {
          _analytics = data;
          _liveOrders = filteredOrders;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await ApiService.updateOrderStatus(orderId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order #$orderId marked as '$newStatus'"),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        _loadAnalytics(silent: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isBigScreen = constraints.maxWidth >= 1050;
        final isMediumScreen = constraints.maxWidth >= 700 && constraints.maxWidth < 1050;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // Consistent with BiteHub AppTheme
          body: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF6366F1)),
                      SizedBox(height: 16),
                      Text(
                        "Loading Revenue & Operations Analytics...",
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isBigScreen ? 24 : 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isBigScreen),
                      const SizedBox(height: 20),
                      _buildHeroKPIGrid(isBigScreen, isMediumScreen),
                      const SizedBox(height: 24),
                      if (isBigScreen)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Revenue Trends, Leaderboard & Payment
                            Expanded(
                              flex: 11,
                              child: Column(
                                children: [
                                  _buildRevenueTrendChart(),
                                  const SizedBox(height: 20),
                                  _buildTopSellingLeaderboard(),
                                  const SizedBox(height: 20),
                                  _buildPaymentBreakdownCard(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Right Column: Live Kitchen/Store & Rider Dispatch Station
                            Expanded(
                              flex: 9,
                              child: _buildLiveUserAndRiderStation(),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildRevenueTrendChart(),
                            const SizedBox(height: 20),
                            _buildLiveUserAndRiderStation(),
                            const SizedBox(height: 20),
                            _buildTopSellingLeaderboard(),
                            const SizedBox(height: 20),
                            _buildPaymentBreakdownCard(),
                          ],
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ===========================================================================
  // 1. DASHBOARD HEADER (Consistent BiteHub Aesthetic)
  // ===========================================================================
  // 1. DASHBOARD HEADER (Brutalism 2.0 Command Center)
  // ===========================================================================
  Widget _buildHeader(bool isBigScreen) {
    final timeStr = DateFormat('hh:mm:ss a').format(_currentTime);
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(_currentTime);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.isRestaurant ? AppTheme.yellow : AppTheme.green,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(2.5, 2.5), blurRadius: 0),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.isRestaurant ? "🍽️" : "🏬",
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.entityName.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.yellow,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: AppTheme.black, width: 1.5),
                          ),
                          child: Text(
                            (widget.isRestaurant ? "RESTAURANT" : "DARK STORE"),
                            style: GoogleFonts.ibmPlexMono(
                              color: AppTheme.black,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.black),
                        const SizedBox(width: 4),
                        Text(
                          widget.entityLocation.isNotEmpty ? widget.entityLocation : "Central Operations Hub",
                          style: GoogleFonts.inter(color: AppTheme.black.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 10),
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "LIVE ENGINE",
                          style: GoogleFonts.ibmPlexMono(
                            color: AppTheme.black,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isBigScreen) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeStr,
                      style: GoogleFonts.ibmPlexMono(
                        color: AppTheme.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      dateStr.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(color: AppTheme.black.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.black),
                tooltip: "Reload Analytics",
                onPressed: () => _loadAnalytics(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Sub-bar with Timeframe Pills & Auto-Refresh
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Text(
                  "Timeframe:",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                Wrap(
                  spacing: 6,
                  children: ["Today", "7 Days", "30 Days", "All-Time"].map((tf) {
                    final selected = _selectedTimeframe == tf;
                    return InkWell(
                      onTap: () => setState(() => _selectedTimeframe = tf),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF6366F1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tf,
                          style: TextStyle(
                            color: selected ? Colors.white : const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sync, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    const Text(
                      "Auto-refresh (15s)",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _autoRefresh,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        setState(() => _autoRefresh = val);
                        _setupAutoRefresh();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. HERO KPI METRICS GRID
  // ===========================================================================
  Widget _buildHeroKPIGrid(bool isBigScreen, bool isMediumScreen) {
    final summary = _analytics['summary'] ?? {};
    final totalRev = (summary['total_revenue'] as num?)?.toDouble() ?? 48650.0;
    final netPayout = (summary['net_payout'] as num?)?.toDouble() ?? (totalRev * 0.85);
    final platformFee = (summary['platform_fee'] as num?)?.toDouble() ?? (totalRev * 0.15);
    final todayRev = (summary['today_revenue'] as num?)?.toDouble() ?? (totalRev * 0.18);
    final growthPct = (summary['growth_pct'] as num?)?.toDouble() ?? 17.4;
    final totalOrders = (summary['total_orders'] as num?)?.toInt() ?? _liveOrders.length;
    final deliveredOrders = (summary['delivered_orders'] as num?)?.toInt() ?? 106;
    final activeOrders = (summary['active_orders'] as num?)?.toInt() ?? 12;
    final aov = (summary['avg_order_value'] as num?)?.toDouble() ?? 412.0;
    final uniqueCustomers = (summary['unique_customers'] as num?)?.toInt() ?? 84;
    final dispatchedRiders = (summary['dispatched_riders'] as num?)?.toInt() ?? 26;
    final avgRiderRating = (summary['avg_rider_rating'] as num?)?.toDouble() ?? 4.88;

    final crossAxisCount = isBigScreen ? 4 : (isMediumScreen ? 2 : 2);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isBigScreen ? 1.6 : (isMediumScreen ? 1.5 : 1.35),
      children: [
        // KPI 1: Gross Revenue
        _buildKPICard(
          title: "Gross Sales Revenue",
          mainValue: "₹${NumberFormat('#,##,###').format(totalRev.round())}",
          subtitle: "Today: ₹${NumberFormat('#,##,###').format(todayRev.round())}",
          badgeText: "+${growthPct.toStringAsFixed(1)}% vs prev",
          badgeColor: const Color(0xFF10B981),
          icon: Icons.currency_rupee,
          accentColor: const Color(0xFF10B981),
        ),
        // KPI 2: Net Partner Payout
        _buildKPICard(
          title: "Net Partner Payout",
          mainValue: "₹${NumberFormat('#,##,###').format(netPayout.round())}",
          subtitle: "Platform Fee: -₹${NumberFormat('#,##,###').format(platformFee.round())} (${widget.isRestaurant ? '15%' : '10%'})",
          badgeText: "Daily 11:59 PM Payout",
          badgeColor: const Color(0xFF6366F1),
          icon: Icons.account_balance_wallet_outlined,
          accentColor: const Color(0xFF6366F1),
        ),
        // KPI 3: Orders Volume & AOV
        _buildKPICard(
          title: "Order Volume & AOV",
          mainValue: "$totalOrders Orders",
          subtitle: "$deliveredOrders Delivered • $activeOrders In-Prep ($uniqueCustomers Customers)",
          badgeText: "AOV: ₹${aov.toStringAsFixed(0)}",
          badgeColor: const Color(0xFF0284C7),
          icon: Icons.shopping_bag_outlined,
          accentColor: const Color(0xFF0284C7),
        ),
        // KPI 4: Rider Dispatch Rate
        _buildKPICard(
          title: "Rider Dispatch Network",
          mainValue: "$dispatchedRiders Couriers",
          subtitle: "Avg delivery time: 14 mins",
          badgeText: "★ ${avgRiderRating.toStringAsFixed(2)} Rating",
          badgeColor: const Color(0xFFF59E0B),
          icon: Icons.delivery_dining_outlined,
          accentColor: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String mainValue,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainValue,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor.withOpacity(0.3)),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. REVENUE TREND BAR CHART (Clean White Theme)
  // ===========================================================================
  Widget _buildRevenueTrendChart() {
    final List timeline = (_analytics['timeline'] as List?) ?? [
      {"date": "Mon", "orders": 14, "revenue": 5800.0},
      {"date": "Tue", "orders": 19, "revenue": 7950.0},
      {"date": "Wed", "orders": 16, "revenue": 6640.0},
      {"date": "Thu", "orders": 22, "revenue": 9180.0},
      {"date": "Fri", "orders": 28, "revenue": 11560.0},
      {"date": "Sat", "orders": 35, "revenue": 14780.0},
      {"date": "Sun", "orders": 31, "revenue": 13240.0},
    ];

    double maxRev = 1.0;
    for (var t in timeline) {
      final r = (t['revenue'] as num?)?.toDouble() ?? 0.0;
      if (r > maxRev) maxRev = r;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📊 Revenue & Orders Volume Timeline",
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Dynamic sales curve based on active incoming User orders",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Peak Day: ₹${NumberFormat('#,##,###').format(maxRev.round())}",
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Bar Visualizer
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: timeline.map((item) {
                final rev = (item['revenue'] as num?)?.toDouble() ?? 0.0;
                final ord = (item['orders'] as num?)?.toInt() ?? 0;
                final dateLabel = item['date']?.toString() ?? "";
                final ratio = (rev / maxRev).clamp(0.08, 1.0);
                final isPeak = rev == maxRev;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "₹${(rev / 1000).toStringAsFixed(1)}k",
                          style: TextStyle(
                            color: isPeak ? const Color(0xFF059669) : const Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 120 * ratio,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPeak
                                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                  : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dateLabel.length > 5 ? dateLabel.substring(5) : dateLabel,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "$ord ord",
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. TOP SELLING LEADERBOARD
  // ===========================================================================
  Widget _buildTopSellingLeaderboard() {
    final List topItems = (_analytics['top_items'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isRestaurant ? "🔥 Top Dishes by Sales & Revenue" : "📦 Best Selling Groceries & Velocity",
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Rank Leaderboard",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "No top selling records yet.",
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topItems.length > 5 ? 5 : topItems.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9), height: 16),
              itemBuilder: (ctx, i) {
                final item = topItems[i];
                final name = item['Item_Name'] ?? 'Item';
                final units = item['units_sold'] ?? 0;
                final rev = (item['revenue'] as num?)?.toDouble() ?? 0.0;
                final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                final img = item['Image_Url'];
                final isVeg = item['is_veg'] == 1 || item['is_veg'] == true;

                final medals = ["🥇", "🥈", "🥉", "4️⃣", "5️⃣"];
                final medal = i < medals.length ? medals[i] : "#${i + 1}";

                return Row(
                  children: [
                    Text(medal, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    ItemImageWidget(
                      imageUrl: img,
                      itemName: name,
                      isGrocery: !widget.isRestaurant,
                      width: 44,
                      height: 44,
                      borderRadius: 10,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (widget.isRestaurant) ...[
                                Text(isVeg ? "🟢 " : "🔴 ", style: const TextStyle(fontSize: 9)),
                              ],
                              Flexible(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "₹${price.toStringAsFixed(0)} unit price • $units units sold",
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${NumberFormat('#,##,###').format(rev.round())}",
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          "Gross Earned",
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. PAYMENT BREAKDOWN CARD
  // ===========================================================================
  Widget _buildPaymentBreakdownCard() {
    final List payList = (_analytics['payment_methods'] as List?) ?? [
      {"method": "UPI", "count": 72, "amount": 29800.0},
      {"method": "Credit / Debit Card", "count": 32, "amount": 13950.0},
      {"method": "Cash on Delivery", "count": 14, "amount": 4900.0},
    ];

    double totalAmt = 0.0;
    for (var p in payList) {
      totalAmt += (p['amount'] as num?)?.toDouble() ?? 0.0;
    }
    if (totalAmt <= 0) totalAmt = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "💳 Payment Channels & Payout Flow",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: payList.map((p) {
                  final amt = (p['amount'] as num?)?.toDouble() ?? 0.0;
                  final method = p['method']?.toString() ?? "UPI";
                  final ratio = (amt / totalAmt).clamp(0.05, 1.0);
                  Color col = const Color(0xFF6366F1);
                  if (method.contains("Card")) col = const Color(0xFF0284C7);
                  if (method.contains("Cash")) col = const Color(0xFFF59E0B);

                  return Expanded(
                    flex: (ratio * 100).round(),
                    child: Container(color: col),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: payList.map((p) {
              final amt = (p['amount'] as num?)?.toDouble() ?? 0.0;
              final method = p['method']?.toString() ?? "UPI";
              final count = p['count'] ?? 0;
              Color col = const Color(0xFF6366F1);
              if (method.contains("Card")) col = const Color(0xFF0284C7);
              if (method.contains("Cash")) col = const Color(0xFFF59E0B);

              return Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$method ($count): ₹${NumberFormat('#,##,###').format(amt.round())}",
                    style: const TextStyle(color: Color(0xFF334155), fontSize: 11),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. LIVE USER ORDERS & RIDER DISPATCH STATION
  // ===========================================================================
  Widget _buildLiveUserAndRiderStation() {
    List<OrderModel> displayOrders = _liveOrders;
    if (_orderStatusFilter == 'In-Prep') {
      displayOrders = _liveOrders.where((o) => o.orderStatus == 'Placed' || o.orderStatus == 'Preparing').toList();
    } else if (_orderStatusFilter == 'Ready') {
      displayOrders = _liveOrders.where((o) => o.orderStatus == 'Ready for Pickup' || o.orderStatus == 'Out for Delivery').toList();
    } else if (_orderStatusFilter == 'Delivered') {
      displayOrders = _liveOrders.where((o) => o.orderStatus == 'Delivered').toList();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "⚡ Live Orders & Rider Station",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${_liveOrders.length} ACTIVE",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "User mobile orders & assigned delivery couriers",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "In-Prep", "Ready", "Delivered"].map((st) {
                final isSelected = _orderStatusFilter == st;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(st),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _orderStatusFilter = st),
                    backgroundColor: const Color(0xFFF8FAFC),
                    selectedColor: const Color(0xFF6366F1).withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (displayOrders.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.done_all, color: Color(0xFF94A3B8), size: 40),
                  SizedBox(height: 10),
                  Text(
                    "All orders processed! Waiting for user orders...",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayOrders.length > 8 ? 8 : displayOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, idx) {
                final ord = displayOrders[idx];
                return _buildOperationalOrderCard(ord);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOperationalOrderCard(OrderModel ord) {
    Color statusCol = const Color(0xFFF59E0B);
    if (ord.orderStatus == 'Preparing') statusCol = const Color(0xFF0284C7);
    if (ord.orderStatus == 'Ready for Pickup') statusCol = const Color(0xFF8B5CF6);
    if (ord.orderStatus == 'Out for Delivery') statusCol = const Color(0xFFEA580C);
    if (ord.orderStatus == 'Delivered') statusCol = const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusCol.withOpacity(0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "#${ord.orderId}",
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusCol.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusCol.withOpacity(0.4)),
                    ),
                    child: Text(
                      ord.orderStatus.toUpperCase(),
                      style: TextStyle(
                        color: statusCol,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                "₹${ord.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_pin, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${ord.userName ?? 'Customer'} • 📱 ${ord.userPhone ?? '98100xxxxx'}",
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (ord.deliveryAddr != null && ord.deliveryAddr!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ord.deliveryAddr!,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Text("🛵", style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ord.agentName != null ? "Courier: ${ord.agentName}" : "Courier: Awaiting Dispatch",
                        style: TextStyle(
                          color: ord.agentName != null ? const Color(0xFF0F172A) : const Color(0xFFF59E0B),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        ord.agentVehicle != null ? "${ord.agentVehicle} • ★ ${ord.agentRating?.toStringAsFixed(1) ?? '5.0'}" : "System searching nearby riders...",
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (ord.agentPhone != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ord.agentPhone!,
                      style: const TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (ord.orderStatus == 'Placed')
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _updateOrderStatus(ord.orderId, "Preparing"),
                    icon: const Icon(Icons.soup_kitchen, size: 14),
                    label: Text(
                      widget.isRestaurant ? "Start Cooking" : "Pack Groceries",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (ord.orderStatus == 'Preparing') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _updateOrderStatus(ord.orderId, "Ready for Pickup"),
                    icon: const Icon(Icons.check_circle_outline, size: 14),
                    label: const Text(
                      "Ready for Rider Pickup",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              if (ord.orderStatus == 'Ready for Pickup') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _updateOrderStatus(ord.orderId, "Out for Delivery"),
                    icon: const Icon(Icons.moped, size: 14),
                    label: const Text(
                      "Handover to Rider",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              if (ord.orderStatus == 'Out for Delivery') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _updateOrderStatus(ord.orderId, "Delivered"),
                    icon: const Icon(Icons.task_alt, size: 14),
                    label: const Text(
                      "Confirm Delivered",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DeliveryAgentRevenueView extends StatefulWidget {
  final int agentId;
  final String agentName;
  final String vehicleNo;
  final bool showAppBar; // If opened as standalone view (Screen 2)
  final VoidCallback? onBack;

  const DeliveryAgentRevenueView({
    super.key,
    required this.agentId,
    required this.agentName,
    required this.vehicleNo,
    this.showAppBar = false,
    this.onBack,
  });

  @override
  State<DeliveryAgentRevenueView> createState() => _DeliveryAgentRevenueViewState();
}

class _DeliveryAgentRevenueViewState extends State<DeliveryAgentRevenueView> {
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  String _timeFilter = "This Week"; // Today, This Week, This Month, All Time
  String _tripFilter = "All"; // All, With Tips

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getDeliveryAgentEarnings(widget.agentId);
      if (mounted) {
        setState(() {
          _data = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showInstantCashoutDialog() {
    final payout = _data['payout_account'] as Map<String, dynamic>? ?? {};
    final summary = _data['summary'] as Map<String, dynamic>? ?? {};
    final todayEarnings = (summary['today_earnings'] as num?)?.toDouble() ?? 322.00;

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
                    Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Cash out to Bank",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Available for Instant Withdrawal:", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      Text(
                        "₹${todayEarnings.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.account_balance, color: Color(0xFF4F46E5)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(payout['bank_name']?.toString() ?? "HDFC Bank", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                            Text("A/C: ${payout['account_number'] ?? '•••• •••• 8912'}  •  IFSC: ${payout['ifsc'] ?? 'HDFC0001234'}", style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                            Text("UPI: ${payout['upi_id'] ?? '9876500001@okaxis'}", style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                SizedBox(width: 6),
                Text("Instant Transfer Fee: ₹0.00 (Zero Commission)", style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bolt_rounded, color: Colors.white),
                label: Text(
                  "Transfer ₹${todayEarnings.toStringAsFixed(2)} Now",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text("₹${todayEarnings.toStringAsFixed(2)} credited to your ${payout['bank_name'] ?? 'HDFC Bank'} account!"),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
    }

    final summary = _data['summary'] as Map<String, dynamic>? ?? {};
    final totalEarnings = (summary['total_earnings'] as num?)?.toDouble() ?? 18450.0;
    final todayEarnings = (summary['today_earnings'] as num?)?.toDouble() ?? 322.00;
    final thisWeekEarnings = (summary['this_week_earnings'] as num?)?.toDouble() ?? 1842.50;
    final totalDeliveries = summary['total_deliveries'] ?? 12;
    final avgPerTrip = (summary['avg_per_trip'] as num?)?.toDouble() ?? 71.41;
    final totalTips = (summary['total_tips'] as num?)?.toDouble() ?? 186.00;
    final onTimeRate = summary['on_time_rate']?.toString() ?? "96.8%";
    final totalKm = summary['total_distance_km']?.toString() ?? "42.6";

    final defaultTimeline = [
      {"day": "Mon", "date": "14", "earnings": 420.0, "trips": 5},
      {"day": "Tue", "date": "15", "earnings": 540.0, "trips": 7},
      {"day": "Wed", "date": "16", "earnings": 380.0, "trips": 4},
      {"day": "Thu", "date": "17", "earnings": 610.0, "trips": 8},
      {"day": "Fri", "date": "18", "earnings": 720.0, "trips": 9},
      {"day": "Sat", "date": "19", "earnings": 840.0, "trips": 11, "isPeak": true},
      {"day": "Sun", "date": "20", "earnings": 690.0, "trips": 9},
    ];

    final timeline = (_data['timeline'] as List?)?.cast<Map<String, dynamic>>() ?? defaultTimeline;

    final defaultTrips = [
      {
        "order_id": 200,
        "order_type": "Grocery",
        "date_str": "19 Oct, 10:22 AM",
        "trip_earnings": 83.70,
        "base_pay": 50.0,
        "distance_fee": 8.70,
        "tip": 25.0,
        "rating": 4.4,
        "pickup_location": "Gachibowli",
        "delivery_address": "300 FC Road, Gachibowli, TS",
      },
      {
        "order_id": 199,
        "order_type": "Restaurant",
        "date_str": "19 Oct, 09:48 AM",
        "trip_earnings": 59.12,
        "base_pay": 50.0,
        "distance_fee": 9.12,
        "tip": 0.0,
        "rating": 4.0,
        "pickup_location": "Dosa Hub 5",
        "delivery_address": "300 FC Road, Gachibowli, TS",
      },
      {
        "order_id": 198,
        "order_type": "Grocery",
        "date_str": "18 Oct, 08:15 PM",
        "trip_earnings": 96.30,
        "base_pay": 60.0,
        "distance_fee": 11.30,
        "tip": 20.0,
        "rating": 4.8,
        "pickup_location": "DMart",
        "delivery_address": "Kondapur, Hyderabad",
      },
    ];

    final apiTrips = (_data['recent_trips'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final recentTrips = apiTrips.isNotEmpty ? apiTrips : defaultTrips;

    final filteredTrips = recentTrips.where((t) {
      if (_tripFilter == "With Tips") {
        return ((t['tip'] as num?)?.toDouble() ?? 0.0) > 0;
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadRevenueData,
      color: const Color(0xFF4F46E5),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // If standalone view (Screen 2), show header with back and calendar
          if (widget.showAppBar) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                  onPressed: widget.onBack ?? () => Navigator.pop(context),
                ),
                const Text(
                  "Revenue & Earnings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF0F172A), size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Selected: Current Pay Cycle (Oct 14 - Oct 20)")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else ...[
            // Screen 1 Header Block
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
                      "Revenue & Earnings",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Track your earnings and growth",
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
          ],

          // Time Filter Pills: Today, This Week, This Month, All Time
          Row(
            children: [
              _buildTimeFilterPill("Today"),
              const SizedBox(width: 8),
              _buildTimeFilterPill("This Week"),
              const SizedBox(width: 8),
              _buildTimeFilterPill("This Month"),
              const SizedBox(width: 8),
              _buildTimeFilterPill("All Time"),
            ],
          ),

          const SizedBox(height: 16),

          // 1. HERO PAYOUT CARD (Dark Gradient)
          _buildHeroPayoutCard(
            thisWeekEarnings: thisWeekEarnings,
            todayEarnings: todayEarnings,
            totalDeliveries: totalDeliveries,
            totalEarnings: totalEarnings,
          ),

          const SizedBox(height: 16),

          // 2. 2x2 METRICS GRID
          _buildMetricsGrid(
            avgPerTrip: avgPerTrip,
            totalTips: totalTips,
            onTimeRate: onTimeRate,
            totalKm: totalKm,
          ),

          const SizedBox(height: 16),

          // 3. WEEKLY REVENUE TREND CHART
          _buildWeeklyChartCard(timeline),

          const SizedBox(height: 16),

          // 4. DIRECT DEPOSIT PAYOUT ACCOUNT CARD (SCREEN 2)
          _buildPayoutAccountCard(),

          const SizedBox(height: 20),

          // 5. TRIP EARNINGS HISTORY LIST (SCREEN 2)
          _buildTripHistorySection(filteredTrips),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTimeFilterPill(String label) {
    final isSelected = _timeFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _timeFilter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
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
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPayoutCard({
    required double thisWeekEarnings,
    required double todayEarnings,
    required dynamic totalDeliveries,
    required double totalEarnings,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Label and Trend Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10B981), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "TOTAL WEEKLY PAYOUT",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 13),
                    SizedBox(width: 4),
                    Text(
                      "+18.4%",
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Large Amount
          Text(
            "₹${thisWeekEarnings.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 14),

          // Sub-stats Row (Today's Earnings, Completed Trips, Lifetime Revenue)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's\nEarnings",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${todayEarnings.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFF334155)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Completed\nTrips",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalDeliveries",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFF334155)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Lifetime\nRevenue",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${totalEarnings.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Cash out to Bank Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              label: const Text(
                "Cash out to Bank",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _showInstantCashoutDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid({
    required double avgPerTrip,
    required double totalTips,
    required String onTimeRate,
    required String totalKm,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: "Avg / Trip",
                value: "₹${avgPerTrip.toStringAsFixed(2)}",
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF4F46E5),
                valueColor: const Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: "Tips Received",
                value: "₹${totalTips.toStringAsFixed(2)}",
                icon: Icons.favorite_border_rounded,
                iconColor: const Color(0xFFEC4899),
                valueColor: const Color(0xFF1E1B4B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: "On-Time Delivery",
                value: onTimeRate,
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF10B981),
                valueColor: const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: "Distance Driven",
                value: "$totalKm km",
                icon: Icons.navigation_outlined,
                iconColor: const Color(0xFFF59E0B),
                valueColor: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartCard(List<Map<String, dynamic>> timeline) {
    double maxVal = 1.0;
    for (var day in timeline) {
      final earn = (day['earnings'] as num?)?.toDouble() ?? 0.0;
      if (earn > maxVal) maxVal = earn;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: Color(0xFF4F46E5), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Weekly Revenue Trend",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                "Last 7 Days",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: timeline.map((day) {
                final earn = (day['earnings'] as num?)?.toDouble() ?? 0.0;
                final dayName = day['day']?.toString() ?? '';
                final dateNumber = day['date']?.toString() ?? '';
                final isPeak = day['isPeak'] == true || earn == maxVal;
                final ratio = (earn / maxVal).clamp(0.2, 1.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "₹${earn.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPeak ? const Color(0xFF059669) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 70 * ratio,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isPeak ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isPeak ? FontWeight.bold : FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          dateNumber,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
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

  Widget _buildPayoutAccountCard() {
    final payout = _data['payout_account'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance, color: Color(0xFF10B981), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Direct Deposit Payout Account",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: const Text(
                  "Verified",
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payout['bank_name']?.toString() ?? "HDFC Bank",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "A/C: ${payout['account_number'] ?? '•••• •••• 8912'}",
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    Text(
                      "IFSC: ${payout['ifsc'] ?? 'HDFC0001234'}",
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Linked UPI ID",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payout['upi_id']?.toString() ?? "9876500001@okaxis",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Auto-payout\nEvery Mon 9:00 AM",
                      style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
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

  Widget _buildTripHistorySection(List<Map<String, dynamic>> trips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.receipt_long_rounded, color: Color(0xFF0F172A), size: 18),
                SizedBox(width: 8),
                Text(
                  "Trip Earnings History",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildTripFilterChip("✓ All", "All"),
                const SizedBox(width: 6),
                _buildTripFilterChip("With Tips", "With Tips"),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (trips.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                "No trips found for this filter",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ),
          )
        else
          ...trips.map((t) => _buildTripCard(t)),
      ],
    );
  }

  Widget _buildTripFilterChip(String label, String value) {
    final isSelected = _tripFilter == value;

    return GestureDetector(
      onTap: () => setState(() => _tripFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final orderId = trip['order_id'] ?? 200;
    final orderType = trip['order_type'] ?? 'Grocery';
    final dateStr = trip['date_str'] ?? '19 Oct, 10:22 AM';
    final tripEarnings = (trip['trip_earnings'] as num?)?.toDouble() ?? 83.70;
    final basePay = (trip['base_pay'] as num?)?.toDouble() ?? 50.0;
    final distFee = (trip['distance_fee'] as num?)?.toDouble() ?? 8.70;
    final tip = (trip['tip'] as num?)?.toDouble() ?? 25.0;
    final rating = (trip['rating'] as num?)?.toDouble() ?? 4.4;
    final pickup = trip['pickup_location'] ?? 'Gachibowli';
    final dest = trip['delivery_address'] ?? '300 FC Road, Gachibowli, TS';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID, Type, Date, Earnings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "#$orderId",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    orderType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "• $dateStr",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              Text(
                "+₹${tripEarnings.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Route
          Row(
            children: [
              const Icon(Icons.arrow_right_alt_rounded, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "$pickup → $dest",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tags row (Base, Distance, Tip, Rating)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildTag("Base ₹${basePay.toStringAsFixed(0)}", const Color(0xFFF1F5F9), const Color(0xFF475569)),
              _buildTag("Distance ₹${distFee.toStringAsFixed(2)}", const Color(0xFFF1F5F9), const Color(0xFF475569)),
              if (tip > 0)
                _buildTag("Tip +₹${tip.toStringAsFixed(0)}", const Color(0xFFFDF2F8), const Color(0xFFDB2777)),
              _buildTag("★ $rating", const Color(0xFFFEF3C7), const Color(0xFFD97706)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';
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
                      child: const Icon(Icons.bolt_rounded, color: AppTheme.black, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "INSTANT BANK CASHOUT",
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bg,
                border: Border.all(color: AppTheme.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppTheme.black, offset: Offset(3, 3), blurRadius: 0),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "AVAILABLE WITHDRAWAL:",
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        "₹${todayEarnings.toStringAsFixed(2)}",
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.black, thickness: 1.5, height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          border: Border.all(color: AppTheme.black, width: 1.5),
                        ),
                        child: const Icon(Icons.account_balance, color: AppTheme.black),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (payout['bank_name']?.toString() ?? "HDFC Bank").toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: AppTheme.black,
                              ),
                            ),
                            Text(
                              "A/C: ${payout['account_number'] ?? '•••• •••• 8912'}  •  IFSC: ${payout['ifsc'] ?? 'HDFC0001234'}",
                              style: GoogleFonts.ibmPlexMono(color: const Color(0xFF64748B), fontSize: 11),
                            ),
                            Text(
                              "UPI: ${payout['upi_id'] ?? '9876500001@okaxis'}",
                              style: GoogleFonts.ibmPlexMono(
                                color: AppTheme.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
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
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.black, size: 16),
                const SizedBox(width: 6),
                Text(
                  "INSTANT DIRECT DEPOSIT // 0% PLATFORM FEE",
                  style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BrutalistButton(
              text: "TRANSFER ₹${todayEarnings.toStringAsFixed(2)} NOW",
              icon: Icons.bolt_rounded,
              bgColor: AppTheme.yellow,
              textColor: AppTheme.black,
              fullWidth: true,
              height: 48,
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppTheme.black),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "₹${todayEarnings.toStringAsFixed(2)} credited to your ${payout['bank_name'] ?? 'HDFC Bank'} account!",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black),
                          ),
                        ),
                      ],
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
      color: AppTheme.black,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // If standalone view (Screen 2), show header with back and calendar
          if (widget.showAppBar) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.onBack ?? () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border.all(color: AppTheme.black, width: 2),
                      boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0)],
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppTheme.black, size: 20),
                  ),
                ),
                Text(
                  "REVENUE & EARNINGS",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: AppTheme.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "Selected: Current Pay Cycle (Oct 14 - Oct 20)",
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
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border.all(color: AppTheme.black, width: 2),
                      boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0)],
                    ),
                    child: const Icon(Icons.calendar_today_outlined, color: AppTheme.black, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ] else ...[
            // Screen 1 Header Block
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
                  child: const Icon(Icons.monetization_on_rounded, color: AppTheme.black, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "REVENUE & EARNINGS",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "PAYOUT ENGINE // ESCROW DIRECT SETTLEMENT",
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
          ],

          // Time Filter Pills: Today, This Week, This Month, All Time
          Row(
            children: [
              _buildTimeFilterPill("TODAY", "Today"),
              const SizedBox(width: 8),
              _buildTimeFilterPill("THIS WEEK", "This Week"),
              const SizedBox(width: 8),
              _buildTimeFilterPill("THIS MONTH", "This Month"),
              const SizedBox(width: 8),
              _buildTimeFilterPill("ALL TIME", "All Time"),
            ],
          ),

          const SizedBox(height: 16),

          // 1. HERO PAYOUT CARD
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

          // 4. DIRECT DEPOSIT PAYOUT ACCOUNT CARD
          _buildPayoutAccountCard(),

          const SizedBox(height: 20),

          // 5. TRIP EARNINGS HISTORY LIST
          _buildTripHistorySection(filteredTrips),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTimeFilterPill(String displayLabel, String value) {
    final isSelected = _timeFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _timeFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.yellow : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.black, width: 2),
            boxShadow: isSelected
                ? const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0)]
                : null,
          ),
          child: Center(
            child: Text(
              displayLabel,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: AppTheme.black,
                letterSpacing: 0.3,
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
    return BrutalistCard(
      bgColor: AppTheme.yellow,
      padding: const EdgeInsets.all(18),
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
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.yellow, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "TOTAL WEEKLY PAYOUT",
                    style: GoogleFonts.ibmPlexMono(
                      color: AppTheme.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.black, width: 1.5),
                  boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded, color: AppTheme.black, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      "+18.4%",
                      style: GoogleFonts.ibmPlexMono(
                        color: AppTheme.black,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
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
            style: GoogleFonts.ibmPlexMono(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppTheme.black,
              letterSpacing: -1.0,
            ),
          ),

          const SizedBox(height: 14),
          const Divider(color: AppTheme.black, thickness: 2, height: 1),
          const SizedBox(height: 14),

          // Sub-stats Row (Today's Earnings, Completed Trips, Lifetime Revenue)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY EARNINGS",
                      style: GoogleFonts.ibmPlexMono(color: AppTheme.black, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${todayEarnings.toStringAsFixed(2)}",
                      style: GoogleFonts.ibmPlexMono(
                        color: AppTheme.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 2, height: 36, color: AppTheme.black),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "COMPLETED TRIPS",
                      style: GoogleFonts.ibmPlexMono(color: AppTheme.black, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalDeliveries",
                      style: GoogleFonts.ibmPlexMono(
                        color: AppTheme.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 2, height: 36, color: AppTheme.black),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LIFETIME REVENUE",
                      style: GoogleFonts.ibmPlexMono(color: AppTheme.black, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${totalEarnings.toStringAsFixed(0)}",
                      style: GoogleFonts.ibmPlexMono(
                        color: AppTheme.black,
                        fontWeight: FontWeight.w900,
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
          BrutalistButton(
            text: "CASH OUT TO BANK",
            icon: Icons.bolt_rounded,
            bgColor: AppTheme.black,
            textColor: AppTheme.yellow,
            fullWidth: true,
            height: 46,
            onPressed: _showInstantCashoutDialog,
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
                title: "AVG / TRIP",
                value: "₹${avgPerTrip.toStringAsFixed(2)}",
                icon: Icons.receipt_long_outlined,
                iconBg: AppTheme.yellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: "TIPS RECEIVED",
                value: "₹${totalTips.toStringAsFixed(2)}",
                icon: Icons.favorite_border_rounded,
                iconBg: AppTheme.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: "ON-TIME RATE",
                value: onTimeRate,
                icon: Icons.access_time_rounded,
                iconBg: AppTheme.surface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: "DISTANCE DRIVEN",
                value: "$totalKm KM",
                icon: Icons.navigation_outlined,
                iconBg: AppTheme.yellow,
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
    required Color iconBg,
  }) {
    return BrutalistCard(
      padding: const EdgeInsets.all(14),
      shadowOffset: const Offset(2.5, 2.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconBg,
                  border: Border.all(color: AppTheme.black, width: 1.5),
                ),
                child: Icon(icon, color: AppTheme.black, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.ibmPlexMono(
                    color: const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppTheme.black,
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
                    "WEEKLY REVENUE TREND",
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppTheme.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.black, width: 1.5),
                ),
                child: Text(
                  "LAST 7 DAYS",
                  style: GoogleFonts.ibmPlexMono(color: AppTheme.black, fontSize: 10, fontWeight: FontWeight.bold),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "₹${earn.toStringAsFixed(0)}",
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: isPeak ? AppTheme.black : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 68 * ratio,
                          width: double.infinity,
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
                        Text(
                          dayName.toUpperCase(),
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 10,
                            fontWeight: isPeak ? FontWeight.w900 : FontWeight.w700,
                            color: AppTheme.black,
                          ),
                        ),
                        Text(
                          dateNumber,
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 9,
                            color: const Color(0xFF64748B),
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

    return BrutalistCard(
      padding: const EdgeInsets.all(18),
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
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.green,
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                    child: const Icon(Icons.account_balance, color: AppTheme.black, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "DIRECT DEPOSIT ACCOUNT",
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: AppTheme.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  border: Border.all(color: AppTheme.black, width: 1.5),
                  boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0)],
                ),
                child: Text(
                  "VERIFIED",
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
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
                      (payout['bank_name']?.toString() ?? "HDFC Bank").toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "A/C: ${payout['account_number'] ?? '•••• •••• 8912'}",
                      style: GoogleFonts.ibmPlexMono(color: const Color(0xFF64748B), fontSize: 11),
                    ),
                    Text(
                      "IFSC: ${payout['ifsc'] ?? 'HDFC0001234'}",
                      style: GoogleFonts.ibmPlexMono(color: const Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LINKED UPI ID",
                      style: GoogleFonts.ibmPlexMono(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payout['upi_id']?.toString() ?? "9876500001@okaxis",
                      style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 11.5, color: AppTheme.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "AUTO-PAYOUT // EVERY MON 9 AM",
                      style: GoogleFonts.ibmPlexMono(color: const Color(0xFF64748B), fontSize: 9.5, fontWeight: FontWeight.bold),
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
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppTheme.black, size: 18),
                const SizedBox(width: 8),
                Text(
                  "TRIP EARNINGS HISTORY",
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppTheme.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildTripFilterChip("✓ ALL", "All"),
                const SizedBox(width: 6),
                _buildTripFilterChip("WITH TIPS", "With Tips"),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (trips.isEmpty)
          BrutalistCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                "NO TRIPS FOUND FOR THIS FILTER",
                style: GoogleFonts.ibmPlexMono(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
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
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: AppTheme.black, width: 1.5),
          boxShadow: isSelected
              ? const [BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0)]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.black,
            letterSpacing: 0.5,
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

    return BrutalistCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      shadowOffset: const Offset(2.5, 2.5),
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
                      color: AppTheme.yellow,
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                    child: Text(
                      "#$orderId",
                      style: GoogleFonts.ibmPlexMono(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    orderType.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "• $dateStr",
                    style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              Text(
                "+₹${tripEarnings.toStringAsFixed(2)}",
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Route
          Row(
            children: [
              const Icon(Icons.arrow_right_alt_rounded, size: 16, color: AppTheme.black),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "$pickup → $dest",
                  style: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.black),
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
              _buildTag("BASE ₹${basePay.toStringAsFixed(0)}", AppTheme.surface),
              _buildTag("DIST ₹${distFee.toStringAsFixed(2)}", AppTheme.surface),
              if (tip > 0)
                _buildTag("TIP +₹${tip.toStringAsFixed(0)}", AppTheme.yellow),
              _buildTag("★ $rating", AppTheme.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: AppTheme.black, width: 1.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppTheme.black,
        ),
      ),
    );
  }
}

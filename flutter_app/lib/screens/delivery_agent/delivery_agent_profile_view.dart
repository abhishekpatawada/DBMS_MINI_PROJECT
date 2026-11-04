import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';
import '../../services/api_service.dart';
import '../auth_screen.dart';
import '../../widgets/server_config_dialog.dart';

class DeliveryAgentProfileView extends StatefulWidget {
  final Map<String, dynamic> agentData;
  final VoidCallback onProfileUpdated;
  final VoidCallback? onNavigateToDeliveries;
  final VoidCallback? onNavigateToEarnings;

  const DeliveryAgentProfileView({
    super.key,
    required this.agentData,
    required this.onProfileUpdated,
    this.onNavigateToDeliveries,
    this.onNavigateToEarnings,
  });

  @override
  State<DeliveryAgentProfileView> createState() => _DeliveryAgentProfileViewState();
}

class _DeliveryAgentProfileViewState extends State<DeliveryAgentProfileView> {
  late int _agentId;
  late String _agentName;
  late String _agentPhone;
  late String _vehicleNo;
  late String _vType;
  late bool _hasLicense;
  late double _rating;

  bool _isOnline = true;
  bool _audioAlerts = true;
  bool _autoAcceptOrders = false;
  double _deliveryRadiusKm = 8.0;
  String _preferredNavigation = "Google Maps";

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _agentId = widget.agentData['Agent_Id'] ?? widget.agentData['agentId'] ?? 1;
    _agentName = widget.agentData['Agent_Name'] ?? widget.agentData['agentName'] ?? 'Krishna Singh';
    _agentPhone = widget.agentData['Agent_Phone'] ?? widget.agentData['agentPhone'] ?? '9876500001';
    _vehicleNo = widget.agentData['VehicleNO'] ?? widget.agentData['vehicleNo'] ?? 'KA-08-DF-1001';
    _vType = widget.agentData['V_Type'] ?? widget.agentData['vType'] ?? 'Motorcycle';
    _hasLicense = widget.agentData['Has_license'] == 1 || widget.agentData['Has_license'] == true || widget.agentData['hasLicense'] == true;
    _rating = double.tryParse(widget.agentData['Rating']?.toString() ?? '4.9') ?? 4.9;
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _agentName);
    final phoneCtrl = TextEditingController(text: _agentPhone);
    final vehicleCtrl = TextEditingController(text: _vehicleNo);
    String selectedVType = _vType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            side: const BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
          ),
          title: Text(
            "EDIT RIDER PROFILE",
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0.5,
              color: AppTheme.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrutalistTextField(
                  controller: nameCtrl,
                  label: "FULL NAME",
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                BrutalistTextField(
                  controller: phoneCtrl,
                  label: "PHONE NUMBER",
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                BrutalistTextField(
                  controller: vehicleCtrl,
                  label: "VEHICLE PLATE NUMBER",
                  prefixIcon: Icons.pin_outlined,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedVType,
                      isExpanded: true,
                      items: ["Motorcycle", "Scooter", "Electric Scooter", "Bicycle"].map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(
                            t.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedVType = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
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
              text: "SAVE CHANGES",
              bgColor: AppTheme.yellow,
              textColor: AppTheme.black,
              height: 40,
              onPressed: () async {
                final newName = nameCtrl.text.trim();
                final newPhone = phoneCtrl.text.trim();
                final newVehicle = vehicleCtrl.text.trim();

                try {
                  await ApiService.updateDeliveryAgent(_agentId, {
                    "name": newName,
                    "phone": newPhone,
                    "vehicle_no": newVehicle,
                    "v_type": selectedVType,
                    "has_license": _hasLicense,
                    "rating": _rating,
                  });
                } catch (_) {}

                setState(() {
                  _agentName = newName;
                  _agentPhone = newPhone;
                  _vehicleNo = newVehicle;
                  _vType = selectedVType;
                });
                widget.agentData['Agent_Name'] = newName;
                widget.agentData['Agent_Phone'] = newPhone;
                widget.agentData['VehicleNO'] = newVehicle;
                widget.agentData['V_Type'] = selectedVType;
                widget.onProfileUpdated();

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Rider profile updated successfully!",
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
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPayoutDialog() {
    final upiCtrl = TextEditingController(text: "$_agentPhone@okaxis");
    final bankCtrl = TextEditingController(text: "HDFC Bank");
    final accCtrl = TextEditingController(text: "•••• •••• 8912");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Payout & Banking Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bankCtrl,
              decoration: const InputDecoration(labelText: "Bank Name", prefixIcon: Icon(Icons.account_balance)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: accCtrl,
              decoration: const InputDecoration(labelText: "Account Number", prefixIcon: Icon(Icons.credit_card)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: upiCtrl,
              decoration: const InputDecoration(labelText: "UPI ID for Instant Cashout", prefixIcon: Icon(Icons.bolt)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Payout settings updated!"),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.black, width: 2),
                boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0)],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.black, size: 18),
            ),
          ),
        ),
        title: Text(
          "RIDER PROFILE & SETTINGS",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: AppTheme.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. RIDER PROFILE CARD
          _buildProfileCard(),

          const SizedBox(height: 16),

          // 2. DUTY STATUS TOGGLE CARD
          _buildDutyStatusCard(),

          const SizedBox(height: 20),

          // 3. FINANCIAL & DIRECT DEPOSIT
          _buildSectionHeader("Financial & Direct Deposit"),
          _buildFinancialCard(),

          const SizedBox(height: 20),

          // 4. RIDER PREFERENCES & ROUTE SETTINGS
          _buildSectionHeader("Rider Preferences & Route Settings"),
          _buildRouteSettingsCard(),

          const SizedBox(height: 20),

          // 5. SAFETY & SUPPORT
          _buildSectionHeader("Support & Connection"),
          _buildSupportCard(),

          const SizedBox(height: 24),

          // 6. LOGOUT BUTTON
          BrutalistButton(
            text: "LOG OUT OF DELIVERY PARTNER APP",
            icon: Icons.logout_rounded,
            bgColor: AppTheme.red,
            textColor: AppTheme.surface,
            fullWidth: true,
            height: 48,
            onPressed: _logout,
          ),

          const SizedBox(height: 32),
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
            // Deliveries
            GestureDetector(
              onTap: widget.onNavigateToDeliveries ?? () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.directions_bike_rounded, size: 20, color: AppTheme.black),
                    const SizedBox(width: 6),
                    Text(
                      "DELIVERIES",
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.black),
                    ),
                  ],
                ),
              ),
            ),
            // Earnings
            GestureDetector(
              onTap: widget.onNavigateToEarnings ?? () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppTheme.black),
                    const SizedBox(width: 6),
                    Text(
                      "EARNINGS",
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return BrutalistCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              // Brutalist Avatar
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(2.5, 2.5), blurRadius: 0),
                  ],
                ),
                child: Center(
                  child: Text(
                    _agentName.isNotEmpty ? _agentName[0].toUpperCase() : "K",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      color: AppTheme.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _agentName.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: AppTheme.black, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: AppTheme.black),
                        const SizedBox(width: 4),
                        Text(
                          _agentPhone,
                          style: GoogleFonts.ibmPlexMono(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.yellow,
                            border: Border.all(color: AppTheme.black, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: AppTheme.black, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                "$_rating RATING",
                                style: GoogleFonts.ibmPlexMono(
                                  color: AppTheme.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            border: Border.all(color: AppTheme.black, width: 1.5),
                          ),
                          child: Text(
                            "ID: #$_agentId",
                            style: GoogleFonts.ibmPlexMono(
                              color: AppTheme.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.black, thickness: 1.5, height: 1),
          const SizedBox(height: 12),

          // Vehicle info row with Edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("🛵", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    "$_vType • $_vehicleNo".toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showEditProfileDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    border: Border.all(color: AppTheme.black, width: 1.5),
                    boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5), blurRadius: 0)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 14, color: AppTheme.black),
                      const SizedBox(width: 4),
                      Text(
                        "EDIT",
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
        ],
      ),
    );
  }

  Widget _buildDutyStatusCard() {
    return BrutalistCard(
      bgColor: _isOnline ? AppTheme.yellow : AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.black,
              border: Border.all(color: AppTheme.black, width: 1.5),
            ),
            child: Icon(Icons.sensors_rounded, color: _isOnline ? AppTheme.yellow : AppTheme.surface, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? "ONLINE & READY FOR DISPATCH" : "OFFLINE (ON BREAK)",
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppTheme.black,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isOnline ? "RECEIVING TELEMETRY ORDER ROUTING" : "ORDERS TEMPORARILY PAUSED",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOnline,
            activeColor: AppTheme.black,
            activeTrackColor: AppTheme.surface,
            inactiveTrackColor: const Color(0xFFCCCCCC),
            onChanged: (val) {
              setState(() => _isOnline = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    val ? "You are now ONLINE and ready for orders" : "You are now OFFLINE",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black),
                  ),
                  backgroundColor: AppTheme.yellow,
                  duration: const Duration(seconds: 1),
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

  Widget _buildFinancialCard() {
    return BrutalistCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.yellow,
                border: Border.all(color: AppTheme.black, width: 1.5),
              ),
              child: const Icon(Icons.account_balance, color: AppTheme.black, size: 18),
            ),
            title: Text(
              "HDFC BANK (DIRECT DEPOSIT)",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
            ),
            subtitle: Row(
              children: [
                Text("A/C: •••• •••• 8912 • ", style: GoogleFonts.ibmPlexMono(fontSize: 11, color: const Color(0xFF64748B))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: AppTheme.green, border: Border.all(color: AppTheme.black, width: 1)),
                  child: Text("ACTIVE", style: GoogleFonts.ibmPlexMono(fontSize: 9, color: AppTheme.black, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.black),
            onTap: _showEditPayoutDialog,
          ),
          const Divider(color: AppTheme.black, thickness: 1.5, height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.black, width: 1.5),
              ),
              child: const Icon(Icons.bolt_rounded, color: AppTheme.black, size: 18),
            ),
            title: Text(
              "LINKED INSTANT UPI",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
            ),
            subtitle: Text("$_agentPhone@okaxis", style: GoogleFonts.ibmPlexMono(fontSize: 11, color: const Color(0xFF64748B))),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.black),
            onTap: _showEditPayoutDialog,
          ),
          const Divider(color: AppTheme.black, thickness: 1.5, height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.yellow,
                border: Border.all(color: AppTheme.black, width: 1.5),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: AppTheme.black, size: 18),
            ),
            title: Text(
              "TAX & TDS STATEMENTS (FORM 16A)",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
            ),
            subtitle: Text("Download FY 2025-26 Summary", style: GoogleFonts.ibmPlexMono(fontSize: 11, color: const Color(0xFF64748B))),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.black),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Form 16A Statement downloaded to Downloads",
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
        ],
      ),
    );
  }

  Widget _buildRouteSettingsCard() {
    return BrutalistCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Loud Order Alerts & Voice
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.yellow,
                border: Border.all(color: AppTheme.black, width: 1.5),
              ),
              child: const Icon(Icons.volume_up_rounded, color: AppTheme.black, size: 18),
            ),
            title: Text(
              "LOUD ORDER ALERTS & CHIMES",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
            ),
            subtitle: Text("High-gain alert when new order arrives", style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B))),
            trailing: Switch(
              value: _audioAlerts,
              activeColor: AppTheme.black,
              activeTrackColor: AppTheme.yellow,
              onChanged: (val) => setState(() => _audioAlerts = val),
            ),
          ),
          const Divider(color: AppTheme.black, thickness: 1.5, height: 1),

          // Auto-Accept Nearby Orders
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.green,
                border: Border.all(color: AppTheme.black, width: 1.5),
              ),
              child: const Icon(Icons.radar_rounded, color: AppTheme.black, size: 18),
            ),
            title: Text(
              "AUTO-ACCEPT NEARBY DISPATCHES",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
            ),
            subtitle: Text("Automatically accept high-priority orders within 2 km", style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B))),
            trailing: Switch(
              value: _autoAcceptOrders,
              activeColor: AppTheme.black,
              activeTrackColor: AppTheme.green,
              onChanged: (val) => setState(() => _autoAcceptOrders = val),
            ),
          ),
          const Divider(color: AppTheme.black, thickness: 1.5, height: 1),

          // Max Delivery Radius Slider
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                            color: AppTheme.surface,
                            border: Border.all(color: AppTheme.black, width: 1.5),
                          ),
                          child: const Icon(Icons.location_on_outlined, color: AppTheme.black, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "MAX DELIVERY RADIUS",
                          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        border: Border.all(color: AppTheme.black, width: 1.5),
                      ),
                      child: Text(
                        "${_deliveryRadiusKm.toStringAsFixed(1)} KM",
                        style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, color: AppTheme.black, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.black,
                    inactiveTrackColor: const Color(0xFFDDDDDD),
                    thumbColor: AppTheme.black,
                    overlayColor: AppTheme.yellow.withValues(alpha: 0.3),
                  ),
                  child: Slider(
                    value: _deliveryRadiusKm,
                    min: 1.0,
                    max: 15.0,
                    divisions: 14,
                    onChanged: (val) => setState(() => _deliveryRadiusKm = val),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("1 KM", style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B))),
                      Text("5 KM", style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B))),
                      Text("10 KM", style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B))),
                      Text("15 KM", style: GoogleFonts.ibmPlexMono(fontSize: 10, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.black, thickness: 1.5, height: 1),

          // Preferred Navigation
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.black, width: 1.5),
              ),
              child: const Icon(Icons.navigation_outlined, color: AppTheme.black, size: 18),
            ),
            title: Text(
              "DEFAULT NAVIGATION APP",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
            ),
            subtitle: Text(_preferredNavigation, style: GoogleFonts.ibmPlexMono(fontSize: 11, color: const Color(0xFF64748B))),
            trailing: DropdownButton<String>(
              value: _preferredNavigation,
              underline: const SizedBox(),
              items: ["Google Maps", "Apple Maps", "In-App Navigation"].map((n) {
                return DropdownMenuItem(
                  value: n,
                  child: Text(
                    n.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.black),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _preferredNavigation = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return BrutalistCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.yellow,
                border: Border.all(color: AppTheme.black, width: 1.5),
              ),
              child: const Icon(Icons.wifi_tethering, color: AppTheme.black, size: 18),
            ),
            title: Text(
              "SERVER HOST NETWORK",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
            ),
            subtitle: Text(
              "Connected to: ${ApiService.baseUrl.replaceAll('http://', '').replaceAll('/api', '')}",
              style: GoogleFonts.ibmPlexMono(fontSize: 11, color: const Color(0xFF64748B)),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.black),
            onTap: () => ServerConfigDialog.show(context, onSaved: () => setState(() {})),
          ),
          const Divider(color: AppTheme.black, thickness: 1.5, height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.green,
                border: Border.all(color: AppTheme.black, width: 1.5),
              ),
              child: const Icon(Icons.support_agent_rounded, color: AppTheme.black, size: 18),
            ),
            title: Text(
              "24x7 PARTNER SUPPORT HELPLINE",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
            ),
            subtitle: Text("Toll-free 1800-248-3482", style: GoogleFonts.ibmPlexMono(fontSize: 11, color: const Color(0xFF64748B))),
            trailing: const Icon(Icons.call_rounded, color: AppTheme.black, size: 20),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Calling BiteHub Partner Support 1800-248-3482...",
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
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            color: AppTheme.black,
            margin: const EdgeInsets.only(right: 8),
          ),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}

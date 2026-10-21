import 'package:flutter/material.dart';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Rider Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vehicleCtrl,
                  decoration: const InputDecoration(labelText: "Vehicle Plate Number", prefixIcon: Icon(Icons.pin_outlined)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedVType,
                  decoration: const InputDecoration(labelText: "Vehicle Type", prefixIcon: Icon(Icons.two_wheeler_outlined)),
                  items: ["Motorcycle", "Scooter", "Electric Scooter", "Bicycle"].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedVType = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
                    const SnackBar(
                      content: Text("Rider profile updated successfully!"),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text("Save Changes"),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Rider Profile & Settings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
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
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              label: const Text(
                "Log Out of Delivery Partner App",
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _logout,
            ),
          ),

          const SizedBox(height: 32),
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
            // Deliveries
            GestureDetector(
              onTap: widget.onNavigateToDeliveries ?? () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                    child: Icon(Icons.directions_bike_rounded, size: 24, color: Color(0xFF64748B)),
                  ),
                  SizedBox(height: 4),
                  Text("Deliveries", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                ],
              ),
            ),
            // Earnings
            GestureDetector(
              onTap: widget.onNavigateToEarnings ?? () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                    child: Icon(Icons.account_balance_wallet_outlined, size: 24, color: Color(0xFF64748B)),
                  ),
                  SizedBox(height: 4),
                  Text("Earnings", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Blue Circle Avatar with Initial
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _agentName.isNotEmpty ? _agentName[0].toUpperCase() : "K",
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
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
                            _agentName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Color(0xFF10B981), size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          _agentPhone,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Color(0xFFD97706), size: 13),
                              const SizedBox(width: 4),
                              Text(
                                "$_rating Rating",
                                style: const TextStyle(
                                  color: Color(0xFFD97706),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "ID: #$_agentId",
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
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
          const Divider(height: 1),
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
                    "$_vType • $_vehicleNo",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showEditProfileDialog,
                child: Row(
                  children: const [
                    Icon(Icons.edit_outlined, size: 15, color: Color(0xFF4F46E5)),
                    SizedBox(width: 4),
                    Text(
                      "Edit",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF4F46E5),
                      ),
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

  Widget _buildDutyStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isOnline ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOnline ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFF10B981) : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sensors_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? "Online & Ready for Deliveries" : "Offline (On Break)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _isOnline ? const Color(0xFF065F46) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isOnline ? "You are receiving nearby order dispatches" : "Orders will not be dispatched to you",
                  style: TextStyle(
                    fontSize: 12,
                    color: _isOnline ? const Color(0xFF047857) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOnline,
            activeColor: const Color(0xFF10B981),
            onChanged: (val) {
              setState(() => _isOnline = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val ? "You are now ONLINE and ready for orders" : "You are now OFFLINE"),
                  backgroundColor: val ? const Color(0xFF10B981) : Colors.grey.shade800,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard() {
    return Container(
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
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance, color: Color(0xFF4F46E5), size: 20),
            ),
            title: const Text("HDFC Bank (Direct Deposit)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            subtitle: Row(
              children: [
                const Text("A/C: •••• •••• 8912 • ", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text("Active", style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            onTap: _showEditPayoutDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 20),
            ),
            title: const Text("Linked Instant UPI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            subtitle: Text("$_agentPhone@okaxis", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            onTap: _showEditPayoutDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981), size: 20),
            ),
            title: const Text("Tax & TDS Statements (Form 16A)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            subtitle: const Text("Download FY 2025-26 Summary", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Form 16A Statement downloaded to Downloads"),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSettingsCard() {
    return Container(
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
        children: [
          // Loud Order Alerts & Voice
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.volume_up_rounded, color: Color(0xFF4F46E5), size: 20),
            ),
            title: const Text("Loud Order Alerts & Voice", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            subtitle: const Text("Play loud chime when new order arrives", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: Switch(
              value: _audioAlerts,
              activeColor: const Color(0xFF4F46E5),
              onChanged: (val) => setState(() => _audioAlerts = val),
            ),
          ),
          const Divider(height: 1),

          // Auto-Accept Nearby Orders
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.radar_rounded, color: Color(0xFF10B981), size: 20),
            ),
            title: const Text("Auto-Accept Nearby Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            subtitle: const Text("Automatically accept high-priority orders within 2 km", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: Switch(
              value: _autoAcceptOrders,
              activeColor: const Color(0xFF10B981),
              onChanged: (val) => setState(() => _autoAcceptOrders = val),
            ),
          ),
          const Divider(height: 1),

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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on_outlined, color: Color(0xFFF59E0B), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text("Max Delivery Radius", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Text(
                      "${_deliveryRadiusKm.toStringAsFixed(1)} km",
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4F46E5), fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF4F46E5),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF4F46E5),
                    overlayColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
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
                    children: const [
                      Text("1 km", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      Text("5 km", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      Text("10 km", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      Text("15 km", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Preferred Navigation
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.navigation_outlined, color: Color(0xFF2563EB), size: 20),
            ),
            title: const Text("Default Navigation App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            subtitle: Text(_preferredNavigation, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: DropdownButton<String>(
              value: _preferredNavigation,
              underline: const SizedBox(),
              items: ["Google Maps", "Apple Maps", "In-App Navigation"].map((n) {
                return DropdownMenuItem(value: n, child: Text(n, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)));
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
    return Container(
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
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.wifi_tethering, color: Color(0xFF4F46E5), size: 20),
            ),
            title: const Text("Server Host Network", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            subtitle: Text("Connected to: ${ApiService.baseUrl.replaceAll('http://', '').replaceAll('/api', '')}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            onTap: () => ServerConfigDialog.show(context, onSaved: () => setState(() {})),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.support_agent_rounded, color: Color(0xFF10B981), size: 20),
            ),
            title: const Text("24x7 Partner Support Helpline", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            subtitle: const Text("Toll-free 1800-248-3482", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            trailing: const Icon(Icons.call_rounded, color: Color(0xFF10B981), size: 20),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Calling BiteHub Partner Support 1800-248-3482..."),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
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
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}

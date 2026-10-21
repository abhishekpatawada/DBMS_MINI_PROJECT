import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/cart_manager.dart';
import '../auth_screen.dart';
import '../../widgets/server_config_dialog.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onProfileUpdated;

  const UserProfileScreen({
    super.key,
    required this.userData,
    this.onProfileUpdated,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late int _userId;
  late String _userName;
  late String _userPhone;
  late String _street;
  late String _area;
  late String _state;
  late String _pincode;

  // App settings state
  double _walletBalance = 450.0;
  bool _smsAlerts = true;
  bool _whatsappUpdates = true;
  bool _promoNotifications = false;
  bool _hapticFeedback = true;
  bool _twoFactorAuth = false;

  final List<Map<String, String>> _savedAddresses = [
    {
      "label": "Home",
      "icon": "🏠",
      "address": "Sector 62, Green Park, Noida, Uttar Pradesh - 201309",
      "isDefault": "true",
    },
    {
      "label": "Work",
      "icon": "🏢",
      "address": "Cyber City, Tower B, 5th Floor, Gurugram, Haryana - 122002",
      "isDefault": "false",
    },
    {
      "label": "Hostel / Campus",
      "icon": "🏫",
      "address": "Block C, Knowledge Park III, Greater Noida - 201306",
      "isDefault": "false",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  void _initUserData() {
    _userId = widget.userData['User_Id'] ?? widget.userData['userId'] ?? 1;
    _userName = widget.userData['User_Name'] ?? widget.userData['userName'] ?? 'Customer';
    _userPhone = widget.userData['User_Phone'] ?? widget.userData['userPhone'] ?? '';
    _street = widget.userData['Street'] ?? widget.userData['street'] ?? '';
    _area = widget.userData['Area'] ?? widget.userData['area'] ?? '';
    _state = widget.userData['State'] ?? widget.userData['state'] ?? '';
    _pincode = widget.userData['Pincode'] ?? widget.userData['pincode'] ?? '';
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final streetCtrl = TextEditingController(text: _street);
    final areaCtrl = TextEditingController(text: _area);
    final stateCtrl = TextEditingController(text: _state);
    final pincodeCtrl = TextEditingController(text: _pincode);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Profile Information", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: streetCtrl,
                decoration: const InputDecoration(labelText: "Street / Flat / House", prefixIcon: Icon(Icons.home_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: areaCtrl,
                decoration: const InputDecoration(labelText: "Area / Landmark", prefixIcon: Icon(Icons.location_city_outlined)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stateCtrl,
                      decoration: const InputDecoration(labelText: "State", prefixIcon: Icon(Icons.map_outlined)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: pincodeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Pincode", prefixIcon: Icon(Icons.pin_outlined)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newPhone = phoneCtrl.text.trim();
              final newStreet = streetCtrl.text.trim();
              final newArea = areaCtrl.text.trim();
              final newState = stateCtrl.text.trim();
              final newPincode = pincodeCtrl.text.trim();

              final success = await ApiService.updateUser(_userId, {
                "name": newName,
                "phone": newPhone,
                "street": newStreet,
                "area": newArea,
                "state": newState,
                "pincode": newPincode,
              });

              if (success) {
                setState(() {
                  _userName = newName;
                  _userPhone = newPhone;
                  _street = newStreet;
                  _area = newArea;
                  _state = newState;
                  _pincode = newPincode;
                });
                widget.userData['User_Name'] = newName;
                widget.userData['User_Phone'] = newPhone;
                widget.userData['Street'] = newStreet;
                widget.userData['Area'] = newArea;
                widget.userData['State'] = newState;
                widget.userData['Pincode'] = newPincode;

                if (newStreet.isNotEmpty || newArea.isNotEmpty) {
                  cartManager.setDeliveryAddress("Home • $newStreet, $newArea, $newState - $newPincode".trim());
                }
                widget.onProfileUpdated?.call();

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile details updated successfully!"),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to update profile"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAddWalletDialog() {
    double addAmount = 500.0;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Top Up BiteHub Pay Wallet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Enjoy 1-click checkout and zero payment failures on all food & grocery orders.", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                children: [100.0, 250.0, 500.0, 1000.0].map((amt) {
                  final isSel = addAmount == amt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text("₹${amt.toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? Colors.white : const Color(0xFF0F172A))),
                      selected: isSel,
                      selectedColor: const Color(0xFF4F46E5),
                      onSelected: (val) {
                        if (val) setSheetState(() => addAmount = amt);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_card, color: Colors.white),
                  label: Text("Add ₹${addAmount.toStringAsFixed(0)} via UPI", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() => _walletBalance += addAmount);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("₹${addAmount.toStringAsFixed(0)} added to BiteHub Pay!"),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Current Password")),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: "New Password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password updated successfully!"), backgroundColor: Color(0xFF10B981)),
              );
            },
            child: const Text("Update Password"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    cartManager.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullAddr = [
      if (_street.isNotEmpty) _street,
      if (_area.isNotEmpty) _area,
      if (_state.isNotEmpty) _state,
      if (_pincode.isNotEmpty) _pincode,
    ].join(", ");

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Profile & Settings", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A))),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PROFILE HEADER CARD (Screen 9)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF4F46E5),
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : "A",
                      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userPhone.isNotEmpty ? _userPhone : "9810000001",
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "👑 BiteHub Gold Member",
                            style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _showEditProfileDialog,
                    child: const Text("Edit", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontSize: 13)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. PRIMARY ADDRESS CARD (Screen 9)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: InkWell(
                onTap: _showEditProfileDialog,
                child: Row(
                  children: [
                    const Icon(Icons.home_outlined, color: Color(0xFF4F46E5), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Home", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(
                            fullAddr.isNotEmpty ? fullAddr : "14 MG Road, Indiranagar, Bengaluru",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. BITEHUB PAY WALLET CARD (Screen 9)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("BiteHub Pay", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text("₹${_walletBalance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                        const Text("Available balance", style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: _showAddWalletDialog,
                    child: const Text("+ Top Up", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. SAVED ADDRESSES SECTION
            _buildSectionTitle("Saved Delivery Addresses"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: _savedAddresses.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isSelected = cartManager.deliveryAddress.contains(item['label']!);

                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(item['icon']!, style: const TextStyle(fontSize: 18)),
                        ),
                        title: Row(
                          children: [
                            Text(item['label']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 8),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text("Active Delivery", style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          item['address']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        trailing: Radio<String>(
                          value: item['address']!,
                          groupValue: cartManager.deliveryAddress.contains("•") ? cartManager.deliveryAddress.split("•").last.trim() : "",
                          activeColor: const Color(0xFF4F46E5),
                          onChanged: (_) {
                            setState(() {
                              cartManager.setDeliveryAddress("${item['label']} • ${item['address']}");
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Active delivery address set to ${item['label']}"), duration: const Duration(seconds: 1)),
                            );
                          },
                        ),
                        onTap: () {
                          setState(() {
                            cartManager.setDeliveryAddress("${item['label']} • ${item['address']}");
                          });
                        },
                      ),
                      if (idx < _savedAddresses.length - 1) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 4. NOTIFICATIONS & PREFERENCES
            _buildSectionTitle("App & Notification Preferences"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.sms_outlined, color: Color(0xFF4F46E5)),
                    title: const Text("SMS Live Delivery Updates", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text("Receive SMS when rider is en route", style: TextStyle(fontSize: 12)),
                    value: _smsAlerts,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (val) => setState(() => _smsAlerts = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.chat_bubble_outline, color: Color(0xFF10B981)),
                    title: const Text("WhatsApp Delivery Tracking", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text("Order receipt and live tracking link on WhatsApp", style: TextStyle(fontSize: 12)),
                    value: _whatsappUpdates,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => _whatsappUpdates = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.local_offer_outlined, color: Color(0xFFF59E0B)),
                    title: const Text("Deals & Promo Offers", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text("Special discounts and weekend cashback notifications", style: TextStyle(fontSize: 12)),
                    value: _promoNotifications,
                    activeColor: const Color(0xFFF59E0B),
                    onChanged: (val) => setState(() => _promoNotifications = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration, color: Color(0xFF64748B)),
                    title: const Text("Haptic Feedback on Cart", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text("Vibrate when adding items to cart or placing order", style: TextStyle(fontSize: 12)),
                    value: _hapticFeedback,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (val) => setState(() => _hapticFeedback = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 5. SECURITY & LOGIN SETTINGS
            _buildSectionTitle("Account Security & Privacy"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset, color: Color(0xFF4F46E5)),
                    title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text("Update your login password", style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.shield_outlined, color: Color(0xFF10B981)),
                    title: const Text("Two-Factor Authentication (2FA)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text("Require SMS OTP upon logging in on new devices", style: TextStyle(fontSize: 12)),
                    value: _twoFactorAuth,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() => _twoFactorAuth = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? "2FA enabled" : "2FA disabled")),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.devices, color: Color(0xFF64748B)),
                    title: const Text("Manage Active Sessions", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text("Logged in on 1 device (Chrome / Web)", style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Only this active session is currently logged in.")),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.wifi_tethering, color: Color(0xFF4F46E5)),
                    title: const Text("Backend Server & Host Network", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text("Connecting to: ${ApiService.baseUrl.replaceAll('http://', '').replaceAll('/api', '')}", style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => ServerConfigDialog.show(context, onSaved: () => setState(() {})),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 6. HELP & SUPPORT
            _buildSectionTitle("Help & Support"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.support_agent, color: Color(0xFF10B981)),
                    title: const Text("24x7 BiteHub Customer Care", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text("Chat with our live support team", style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chat_bubble_outline, size: 18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Connecting to BiteHub Live Customer Support...")),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.policy_outlined, color: Color(0xFF64748B)),
                    title: const Text("Cancellation & Refund Policy", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text("Instant refunds back to original payment mode", style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Refund Policy"),
                          content: const Text("Orders cancelled within 60 seconds are 100% refunded to BiteHub Pay Wallet instantly."),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 7. LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text("Log Out of BiteHub Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _logout,
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}

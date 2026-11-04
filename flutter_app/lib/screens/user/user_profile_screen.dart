import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/cart_manager.dart';
import '../auth_screen.dart';
import '../../widgets/server_config_dialog.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';

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
    _userName = widget.userData['User_Name'] ??
        widget.userData['userName'] ??
        'Customer';
    _userPhone =
        widget.userData['User_Phone'] ?? widget.userData['userPhone'] ?? '';
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
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(color: AppTheme.black, width: 3),
        ),
        title: Text(
          "EDIT PROFILE DATA",
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            color: AppTheme.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.ibmPlexMono(fontSize: 13),
                decoration: const InputDecoration(labelText: "FULL NAME"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.ibmPlexMono(fontSize: 13),
                decoration: const InputDecoration(labelText: "PHONE NUMBER"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: streetCtrl,
                style: GoogleFonts.ibmPlexMono(fontSize: 13),
                decoration: const InputDecoration(labelText: "STREET ADDRESS"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: areaCtrl,
                style: GoogleFonts.ibmPlexMono(fontSize: 13),
                decoration: const InputDecoration(labelText: "AREA / CITY"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stateCtrl,
                      style: GoogleFonts.ibmPlexMono(fontSize: 13),
                      decoration: const InputDecoration(labelText: "STATE"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: pincodeCtrl,
                      style: GoogleFonts.ibmPlexMono(fontSize: 13),
                      decoration: const InputDecoration(labelText: "PINCODE"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "CANCEL",
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
          ),
          BrutalistButton.yellow(
            text: "SAVE CHANGES",
            height: 38,
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newPhone = phoneCtrl.text.trim();
              final newStreet = streetCtrl.text.trim();
              final newArea = areaCtrl.text.trim();
              final newState = stateCtrl.text.trim();
              final newPincode = pincodeCtrl.text.trim();

              try {
                await ApiService.updateUserProfile(_userId, {
                  "name": newName,
                  "phone": newPhone,
                  "street": newStreet,
                  "area": newArea,
                  "state": newState,
                  "pincode": newPincode,
                });

                setState(() {
                  _userName = newName;
                  _userPhone = newPhone;
                  _street = newStreet;
                  _area = newArea;
                  _state = newState;
                  _pincode = newPincode;
                  widget.userData['User_Name'] = newName;
                  widget.userData['User_Phone'] = newPhone;
                  widget.userData['Street'] = newStreet;
                  widget.userData['Area'] = newArea;
                  widget.userData['State'] = newState;
                  widget.userData['Pincode'] = newPincode;
                });

                final full = [newStreet, newArea, newState, newPincode]
                    .where((s) => s.isNotEmpty)
                    .join(", ");
                if (full.isNotEmpty) {
                  cartManager.setDeliveryAddress("Home • $full");
                }

                widget.onProfileUpdated?.call();
                if (mounted) Navigator.pop(ctx);
              } catch (_) {
                if (mounted) Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddWalletDialog() {
    double addAmount = 500.0;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: AppTheme.bg,
            border: Border(
              top: BorderSide(color: AppTheme.black, width: 3.5),
              left: BorderSide(color: AppTheme.black, width: 3.5),
              right: BorderSide(color: AppTheme.black, width: 3.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOP UP WALLET",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Instant balance for zero-failure checkout.",
                style: GoogleFonts.inter(
                  color: const Color(0xFF555555),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [100.0, 250.0, 500.0, 1000.0].map((amt) {
                  final isSel = addAmount == amt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => setSheetState(() => addAmount = amt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.yellow : AppTheme.surface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                          border: Border.all(
                            color: AppTheme.black,
                            width: isSel ? 2.5 : 1.5,
                          ),
                          boxShadow: isSel
                              ? const [
                                  BoxShadow(
                                    color: AppTheme.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          "₹${amt.toStringAsFixed(0)}",
                          style: GoogleFonts.ibmPlexMono(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              BrutalistButton.yellow(
                text: "ADD ₹${addAmount.toStringAsFixed(0)} VIA UPI →",
                fullWidth: true,
                onPressed: () {
                  setState(() => _walletBalance += addAmount);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "WALLET CREDITED: ₹${addAmount.toStringAsFixed(0)}",
                        style: GoogleFonts.ibmPlexMono(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.black,
                        ),
                      ),
                      backgroundColor: AppTheme.green,
                    ),
                  );
                },
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
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(color: AppTheme.black, width: 3),
        ),
        title: Text(
          "CHANGE PASSWORD",
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            color: AppTheme.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              style: GoogleFonts.ibmPlexMono(fontSize: 13),
              decoration: const InputDecoration(labelText: "CURRENT PASSWORD"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              style: GoogleFonts.ibmPlexMono(fontSize: 13),
              decoration: const InputDecoration(labelText: "NEW PASSWORD"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "CANCEL",
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
          ),
          BrutalistButton.yellow(
            text: "UPDATE",
            height: 38,
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "PASSWORD UPDATED",
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.black,
                    ),
                  ),
                  backgroundColor: AppTheme.green,
                ),
              );
            },
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
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          "PROFILE & SETTINGS",
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppTheme.black,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppTheme.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header Card
            BrutalistCard(
              bgColor: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              shadowOffset: const Offset(4, 4),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                      border: Border.all(color: AppTheme.black, width: 2.5),
                    ),
                    child: Center(
                      child: Text(
                        _userName.isNotEmpty
                            ? _userName[0].toUpperCase()
                            : "C",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26,
                          color: AppTheme.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _userPhone.isNotEmpty ? _userPhone : "9810000001",
                          style: GoogleFonts.ibmPlexMono(
                            color: const Color(0xFF666666),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const BrutalistBadge(
                          label: "★ BITEHUB GOLD MEMBER",
                          bgColor: AppTheme.yellow,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showEditProfileDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                        border: Border.all(color: AppTheme.black, width: 2),
                      ),
                      child: Text(
                        "EDIT",
                        style: GoogleFonts.ibmPlexMono(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Primary Delivery Address Card
            BrutalistCard(
              bgColor: AppTheme.surface,
              padding: const EdgeInsets.all(14),
              shadowOffset: const Offset(3.5, 3.5),
              onTap: _showEditProfileDialog,
              child: Row(
                children: [
                  const Icon(Icons.home_rounded,
                      color: AppTheme.black, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DEFAULT DELIVERY ADDRESS",
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: AppTheme.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fullAddr.isNotEmpty
                              ? fullAddr
                              : "14 MG Road, Indiranagar, Bengaluru",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: AppTheme.black),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Wallet Card
            BrutalistCard(
              bgColor: AppTheme.black,
              padding: const EdgeInsets.all(18),
              shadowOffset: const Offset(4, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                      border: Border.all(color: AppTheme.black, width: 2),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppTheme.black, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BITEHUB PAY WALLET",
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.yellow,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "₹${_walletBalance.toStringAsFixed(2)}",
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BrutalistButton.yellow(
                    text: "+ TOP UP",
                    height: 38,
                    onPressed: _showAddWalletDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Saved Addresses Section
            const BrutalistSectionHeader(
              title: "SAVED ADDRESSES",
              tag: "DESTINATIONS",
            ),
            const SizedBox(height: 10),
            BrutalistCard(
              bgColor: AppTheme.surface,
              padding: EdgeInsets.zero,
              shadowOffset: const Offset(3.5, 3.5),
              child: Column(
                children: _savedAddresses.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isSelected =
                      cartManager.deliveryAddress.contains(item['label']!);

                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.yellow,
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadius),
                            border:
                                Border.all(color: AppTheme.black, width: 1.5),
                          ),
                          child: Text(item['icon']!,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        title: Row(
                          children: [
                            Text(
                              item['label']!.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: AppTheme.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              const BrutalistBadge(
                                label: "ACTIVE",
                                bgColor: AppTheme.green,
                              ),
                          ],
                        ),
                        subtitle: Text(
                          item['address']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: AppTheme.black,
                        ),
                        onTap: () {
                          setState(() {
                            cartManager.setDeliveryAddress(
                                "${item['label']} • ${item['address']}");
                          });
                        },
                      ),
                      if (idx < _savedAddresses.length - 1)
                        Container(height: 1.5, color: AppTheme.black),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 5. Notifications & Preferences
            const BrutalistSectionHeader(
              title: "PREFERENCES",
              tag: "ALERTS",
            ),
            const SizedBox(height: 10),
            BrutalistCard(
              bgColor: AppTheme.surface,
              padding: EdgeInsets.zero,
              shadowOffset: const Offset(3.5, 3.5),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      "SMS LIVE DELIVERY ALERTS",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppTheme.black,
                      ),
                    ),
                    subtitle: Text(
                      "Receive SMS when courier is dispatched",
                      style: GoogleFonts.inter(fontSize: 11.5),
                    ),
                    value: _smsAlerts,
                    activeColor: AppTheme.black,
                    activeTrackColor: AppTheme.yellow,
                    onChanged: (val) => setState(() => _smsAlerts = val),
                  ),
                  Container(height: 1.5, color: AppTheme.black),
                  SwitchListTile(
                    title: Text(
                      "WHATSAPP TRACKING UPDATES",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppTheme.black,
                      ),
                    ),
                    subtitle: Text(
                      "Live GPS map and bill link on WhatsApp",
                      style: GoogleFonts.inter(fontSize: 11.5),
                    ),
                    value: _whatsappUpdates,
                    activeColor: AppTheme.black,
                    activeTrackColor: AppTheme.yellow,
                    onChanged: (val) => setState(() => _whatsappUpdates = val),
                  ),
                  Container(height: 1.5, color: AppTheme.black),
                  SwitchListTile(
                    title: Text(
                      "PROMO DEALS & CASHBACK",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppTheme.black,
                      ),
                    ),
                    subtitle: Text(
                      "Flash discounts and weekend food cashback",
                      style: GoogleFonts.inter(fontSize: 11.5),
                    ),
                    value: _promoNotifications,
                    activeColor: AppTheme.black,
                    activeTrackColor: AppTheme.yellow,
                    onChanged: (val) =>
                        setState(() => _promoNotifications = val),
                  ),
                  Container(height: 1.5, color: AppTheme.black),
                  SwitchListTile(
                    title: Text(
                      "HAPTIC TOUCH FEEDBACK",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppTheme.black,
                      ),
                    ),
                    subtitle: Text(
                      "Vibrate on adding items or placing order",
                      style: GoogleFonts.inter(fontSize: 11.5),
                    ),
                    value: _hapticFeedback,
                    activeColor: AppTheme.black,
                    activeTrackColor: AppTheme.yellow,
                    onChanged: (val) => setState(() => _hapticFeedback = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 6. Security & Server Settings
            const BrutalistSectionHeader(
              title: "SECURITY & SYSTEM",
              tag: "CONFIG",
            ),
            const SizedBox(height: 10),
            BrutalistCard(
              bgColor: AppTheme.surface,
              padding: EdgeInsets.zero,
              shadowOffset: const Offset(3.5, 3.5),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_rounded,
                        color: AppTheme.black, size: 20),
                    title: Text(
                      "CHANGE PASSWORD",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppTheme.black,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppTheme.black),
                    onTap: _showChangePasswordDialog,
                  ),
                  Container(height: 1.5, color: AppTheme.black),
                  ListTile(
                    leading: const Icon(Icons.hub_rounded,
                        color: AppTheme.black, size: 20),
                    title: Text(
                      "BACKEND SERVER CONFIG",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppTheme.black,
                      ),
                    ),
                    subtitle: Text(
                      "ENDPOINT: ${ApiService.baseUrl}",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        color: const Color(0xFF555555),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppTheme.black),
                    onTap: () => ServerConfigDialog.show(context,
                        onSaved: () => setState(() {})),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 7. Logout Button
            BrutalistButton.red(
              text: "LOG OUT OF BITEHUB ACCOUNT",
              icon: Icons.logout_rounded,
              fullWidth: true,
              onPressed: _logout,
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

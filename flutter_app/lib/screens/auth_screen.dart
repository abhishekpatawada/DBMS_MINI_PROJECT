import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'user/user_dashboard_screen.dart';
import 'delivery_agent/delivery_agent_dashboard_screen.dart';
import 'restaurant/restaurant_dashboard_screen.dart';
import 'dark_store/dark_store_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  final String? selectedRole;
  const AuthScreen({super.key, this.selectedRole});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Sign In controllers
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Sign Up: selected role (User / Customer by default)
  String _selectedSignUpRole = "User";

  // Sign Up controllers
  final _signUpNameController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  bool _obscureSignUpPassword = true;

  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  String _vType = "Motorcycle";
  final bool _hasLicense = true;

  @override
  void initState() {
    super.initState();
    if (widget.selectedRole != null && widget.selectedRole!.isNotEmpty) {
      _selectedSignUpRole = widget.selectedRole!;
      _isSignUp = true;
    }
    // Pre-populate demo user credentials
    _phoneController.text = "9810000001";
    _passwordController.text = "123456";
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _signUpNameController.dispose();
    _signUpPhoneController.dispose();
    _signUpPasswordController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _vehicleNoController.dispose();
    super.dispose();
  }

  void _fillDemo(String phone, String roleName) {
    setState(() {
      _phoneController.text = phone;
      _passwordController.text = "123456";
      _errorMessage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Filled demo credentials for $roleName ($phone / 123456)"),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF4F46E5),
      ),
    );
  }

  void _navigateToDashboard(String role, Map<String, dynamic> userData) {
    Widget targetScreen;
    switch (role) {
      case "User":
        targetScreen = UserDashboardScreen(userData: userData);
        break;
      case "Delivery Agent":
        targetScreen = DeliveryAgentDashboardScreen(agentData: userData);
        break;
      case "Restaurant":
        targetScreen = RestaurantDashboardScreen(restaurantData: userData);
        break;
      case "Dark Store":
        targetScreen = DarkStoreDashboardScreen(storeData: userData);
        break;
      default:
        targetScreen = UserDashboardScreen(userData: userData);
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
      (route) => false,
    );
  }

  Future<void> _handleSignIn() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty) {
      setState(() => _errorMessage = "Please enter your mobile number.");
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = "Please enter your password.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Backend automatically detects the user's role across all 4 tables!
      final res = await ApiService.login(phone, password);
      final role = res['role'] as String? ?? 'User';
      final data = res['data'] as Map<String, dynamic>;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome back! Logged in as $role"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _navigateToDashboard(role, data);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignUp() async {
    final phone = _signUpPhoneController.text.trim();
    final password = _signUpPasswordController.text.trim();

    if (_selectedSignUpRole != "Dark Store" && _signUpNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Please enter your name.");
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = "Please enter a valid mobile number.");
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = "Please choose a password.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> res;
      if (_selectedSignUpRole == "User") {
        res = await ApiService.registerUser({
          "name": _signUpNameController.text.trim(),
          "phone": phone,
          "password": password,
          "street": _streetController.text.trim(),
          "area": _areaController.text.trim(),
          "state": _stateController.text.trim(),
          "pincode": _pincodeController.text.trim(),
        });
      } else if (_selectedSignUpRole == "Delivery Agent") {
        res = await ApiService.registerAgent({
          "name": _signUpNameController.text.trim(),
          "phone": phone,
          "password": password,
          "vehicle_no": _vehicleNoController.text.trim(),
          "v_type": _vType,
          "has_license": _hasLicense,
        });
      } else if (_selectedSignUpRole == "Restaurant") {
        if (_areaController.text.trim().isEmpty) {
          throw Exception("Restaurant location / address is required.");
        }
        res = await ApiService.registerRestaurant({
          "name": _signUpNameController.text.trim(),
          "location": _areaController.text.trim(),
          "phone": phone,
          "password": password,
        });
      } else {
        // Dark Store
        if (_streetController.text.trim().isEmpty || _areaController.text.trim().isEmpty) {
          throw Exception("Street and Area are required for Dark Store Hub.");
        }
        res = await ApiService.registerDarkStore({
          "phone": phone,
          "password": password,
          "street": _streetController.text.trim(),
          "area": _areaController.text.trim(),
          "state": _stateController.text.trim(),
          "pincode": _pincodeController.text.trim(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account created successfully as $_selectedSignUpRole!"),
            backgroundColor: Colors.green,
          ),
        );
        _navigateToDashboard(_selectedSignUpRole, res['data']);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case "User":
        return const Color(0xFF4F46E5); // Indigo
      case "Delivery Agent":
        return const Color(0xFF059669); // Emerald
      case "Restaurant":
        return const Color(0xFFEA580C); // Orange
      case "Dark Store":
        return const Color(0xFF7C3AED); // Violet
      default:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5).withOpacity(0.18),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/logo.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error2, stackTrace2) => Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "B",
                                          style: TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "BiteHub",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Your cravings, our command.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isSignUp
                                  ? "Create your account to get started"
                                  : "Food & Grocery Multi-Vendor Platform",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error Alert Banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Form Body (Sign In or Sign Up)
                      _isSignUp ? _buildSignUpView() : _buildSignInView(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. UNIFIED SIGN IN VIEW (Auto-detects Role)
  // ==========================================
  Widget _buildSignInView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Mobile Number",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: "Enter your registered mobile number",
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("🇮🇳 +91", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14)),
                  SizedBox(width: 8),
                  SizedBox(height: 18, child: VerticalDivider(width: 1, color: Color(0xFFCBD5E1))),
                ],
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          "Password",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: "Enter your password",
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
          ),
        ),
        const SizedBox(height: 18),

        // Quick Demo Role Chips (Test any role with 1 tap)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.flash_on_rounded, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 6),
                  Text(
                    "Quick Fill Demo Login:",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _demoChip("👤 Customer", "9810000001", "Customer", const Color(0xFF4F46E5)),
                  _demoChip("🛵 Agent", "9876500001", "Delivery Agent", const Color(0xFF059669)),
                  _demoChip("🏪 Restaurant", "0800000001", "Restaurant", const Color(0xFFEA580C)),
                  _demoChip("🏬 Dark Store", "9810099999", "Dark Store", const Color(0xFF7C3AED)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Sign In Action Button (No icons in button)
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF4F46E5).withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  "Sign In to BiteHub",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
        const SizedBox(height: 20),

        // Create Account Action below Sign In button (No icons)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = true;
                  _errorMessage = null;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _demoChip(String label, String phone, String roleName, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _fillDemo(phone, roleName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }

  // ==========================================
  // 2. CREATE ACCOUNT VIEW (Asks for Role)
  // ==========================================
  Widget _buildSignUpView() {
    final activeColor = _getRoleColor(_selectedSignUpRole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role Selection Header
        const Text(
          "I am joining BiteHub as:",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 10),

        // 4 Role Cards
        Row(
          children: [
            Expanded(child: _roleCard("User", "👤", "Customer", "Order food & mart")),
            const SizedBox(width: 8),
            Expanded(child: _roleCard("Delivery Agent", "🛵", "Agent", "Deliver orders")),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _roleCard("Restaurant", "🏪", "Restaurant", "Sell dishes")),
            const SizedBox(width: 8),
            Expanded(child: _roleCard("Dark Store", "🏬", "Dark Store", "Grocery hub")),
          ],
        ),
        const SizedBox(height: 20),

        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 12),

        // Form Fields for Selected Role
        if (_selectedSignUpRole != "Dark Store") ...[
          Text(
            _selectedSignUpRole == "Restaurant" ? "Restaurant Name *" : "Full Name *",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _signUpNameController,
            decoration: InputDecoration(
              hintText: _selectedSignUpRole == "Restaurant" ? "e.g. Royal Bistro" : "e.g. Aarav Sharma",
              prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B), size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: activeColor, width: 2)),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Mobile Number
        const Text("Mobile Number *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          controller: _signUpPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: "10-digit mobile number",
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("🇮🇳 +91", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14)),
                  SizedBox(width: 8),
                  SizedBox(height: 18, child: VerticalDivider(width: 1, color: Color(0xFFCBD5E1))),
                ],
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: activeColor, width: 2)),
          ),
        ),
        const SizedBox(height: 14),

        // Create Password
        const Text("Create Password *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          controller: _signUpPasswordController,
          obscureText: _obscureSignUpPassword,
          decoration: InputDecoration(
            hintText: "Minimum 6 characters",
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignUpPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              onPressed: () => setState(() => _obscureSignUpPassword = !_obscureSignUpPassword),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: activeColor, width: 2)),
          ),
        ),
        const SizedBox(height: 14),

        // Delivery Agent Specific Fields
        if (_selectedSignUpRole == "Delivery Agent") ...[
          const Text("Vehicle Number", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextField(
            controller: _vehicleNoController,
            decoration: InputDecoration(
              hintText: "e.g. KA-01-AB-1234",
              prefixIcon: const Icon(Icons.two_wheeler_rounded, color: Color(0xFF64748B), size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _vType,
            decoration: InputDecoration(
              labelText: "Vehicle Type",
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            ),
            items: ["Motorcycle", "Electric Scooter", "Scooter", "Bicycle", "Car"]
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (val) => setState(() => _vType = val!),
          ),
          const SizedBox(height: 14),
        ],

        // Restaurant Location
        if (_selectedSignUpRole == "Restaurant") ...[
          const Text("Restaurant Location / Area *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextField(
            controller: _areaController,
            decoration: InputDecoration(
              hintText: "e.g. Indiranagar, Bengaluru",
              prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Customer & Dark Store Address
        if (_selectedSignUpRole == "User" || _selectedSignUpRole == "Dark Store") ...[
          const Text("Street Address", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextField(
            controller: _streetController,
            decoration: InputDecoration(
              hintText: "e.g. 12th Main, Plot 42",
              prefixIcon: const Icon(Icons.home_outlined, color: Color(0xFF64748B), size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Area / City *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _areaController,
                      decoration: InputDecoration(
                        hintText: "e.g. Koramangala",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pincode", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "e.g. 560034",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],

        const SizedBox(height: 10),

        // Sign Up Action Button (No icons in button)
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: activeColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: activeColor.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  "Register as $_selectedSignUpRole",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
        ),
        const SizedBox(height: 20),

        // Switch back to Sign In (No icons in button)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account? ",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = false;
                  _errorMessage = null;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: activeColor,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              child: const Text(
                "Sign In",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleCard(String roleKey, String icon, String title, String subtitle) {
    final isSelected = _selectedSignUpRole == roleKey;
    final color = _getRoleColor(roleKey);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _selectedSignUpRole = roleKey;
          _errorMessage = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

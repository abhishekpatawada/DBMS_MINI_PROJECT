import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brutalist_widgets.dart';
import 'user/user_dashboard_screen.dart';
import 'delivery_agent/delivery_agent_dashboard_screen.dart';
import 'restaurant/restaurant_dashboard_screen.dart';
import 'dark_store/dark_store_dashboard_screen.dart';
import 'landing/web_landing_screen.dart';

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
        content: Text(
          "FILLED CREDENTIALS: $roleName ($phone / 123456)",
          style: GoogleFonts.ibmPlexMono(
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.yellow,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppTheme.black, width: 2),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
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
      final res = await ApiService.login(phone, password);
      final role = res['role'] as String? ?? 'User';
      final data = res['data'] as Map<String, dynamic>;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ACCESS GRANTED // LOGGED IN AS $role",
              style: GoogleFonts.ibmPlexMono(
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
            backgroundColor: AppTheme.green,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppTheme.black, width: 2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
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

    if (_selectedSignUpRole != "Dark Store" &&
        _signUpNameController.text.trim().isEmpty) {
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
        if (_streetController.text.trim().isEmpty ||
            _areaController.text.trim().isEmpty) {
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
            content: Text(
              "ACCOUNT REGISTERED // $_selectedSignUpRole",
              style: GoogleFonts.ibmPlexMono(
                fontWeight: FontWeight.w800,
                color: AppTheme.surface,
              ),
            ),
            backgroundColor: AppTheme.blue,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppTheme.black, width: 2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
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
        return AppTheme.yellow;
      case "Delivery Agent":
        return AppTheme.green;
      case "Restaurant":
        return AppTheme.orange;
      case "Dark Store":
        return AppTheme.blue;
      default:
        return AppTheme.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: BrutalistCard(
                bgColor: AppTheme.surface,
                padding: const EdgeInsets.all(28),
                shadowOffset: const Offset(6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (kIsWeb) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const WebLandingScreen(),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.arrow_back_rounded,
                              size: 16, color: AppTheme.black),
                          label: Text(
                            "BACK TO PORTAL",
                            style: GoogleFonts.ibmPlexMono(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppTheme.black,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Top Status Ticker Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BrutalistBadge(
                          label: "BITEHUB AUTH",
                          bgColor: AppTheme.yellow,
                        ),
                        Text(
                          "GATEWAY // V2.0",
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Brand Heading
                    Text(
                      "ACCESS PORTAL",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp
                          ? "INITIALIZE NEW ENTITY ACCOUNT"
                          : "ENTER CREDENTIALS TO RESUME SESSION",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Brutalist Segment Switcher (Sign In vs Sign Up)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        border: Border.all(
                          color: AppTheme.black,
                          width: AppTheme.borderWidth,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSignUp = false;
                                  _errorMessage = null;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: !_isSignUp
                                      ? AppTheme.black
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "SIGN IN",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: !_isSignUp
                                        ? AppTheme.yellow
                                        : AppTheme.black,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: AppTheme.borderWidth,
                            height: 38,
                            color: AppTheme.black,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSignUp = true;
                                  _errorMessage = null;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: _isSignUp
                                      ? AppTheme.black
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "CREATE ACCOUNT",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: _isSignUp
                                        ? AppTheme.yellow
                                        : AppTheme.black,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Alert Banner
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.red,
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                          border: Border.all(
                            color: AppTheme.black,
                            width: AppTheme.borderWidth,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.black,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppTheme.surface, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!.toUpperCase(),
                                style: GoogleFonts.ibmPlexMono(
                                  color: AppTheme.surface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
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
    );
  }

  // ==========================================
  // 1. UNIFIED SIGN IN VIEW (Auto-detects Role)
  // ==========================================
  Widget _buildSignInView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "MOBILE NUMBER",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.black,
          ),
          decoration: InputDecoration(
            hintText: "Enter 10-digit mobile number",
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "🇮🇳 +91",
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.black,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 2,
                    height: 18,
                    color: AppTheme.black,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "PASSWORD",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.black,
          ),
          decoration: InputDecoration(
            hintText: "Enter password",
            prefixIcon: const Icon(Icons.lock_rounded,
                color: AppTheme.black, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppTheme.black,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Quick Demo Role Chips
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: AppTheme.black,
              width: AppTheme.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      size: 16, color: AppTheme.black),
                  const SizedBox(width: 4),
                  Text(
                    "QUICK FILL DEMO CREDENTIALS:",
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _demoChip("CUSTOMER", "9810000001", "Customer",
                      AppTheme.yellow),
                  _demoChip("AGENT", "9876500001", "Delivery Agent",
                      AppTheme.green),
                  _demoChip("RESTAURANT", "0800000001", "Restaurant",
                      AppTheme.orange),
                  _demoChip("DARK STORE", "9810099999", "Dark Store",
                      AppTheme.blue),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Sign In Action Button
        _isLoading
            ? Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.black,
                  border: Border.all(
                      color: AppTheme.black, width: AppTheme.borderWidth),
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppTheme.yellow,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : BrutalistButton(
                text: "SIGN IN TO BITEHUB →",
                fullWidth: true,
                onPressed: _handleSignIn,
              ),
      ],
    );
  }

  Widget _demoChip(String label, String phone, String roleName, Color color) {
    return GestureDetector(
      onTap: () => _fillDemo(phone, roleName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: AppTheme.black, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: color == AppTheme.blue ? AppTheme.surface : AppTheme.black,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. CREATE ACCOUNT VIEW (Asks for Role)
  // ==========================================
  Widget _buildSignUpView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role Selection Header
        Text(
          "SELECT REGISTERED IDENTITY",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        // 4 Role Cards
        Row(
          children: [
            Expanded(
              child: _roleCard("User", Icons.fastfood_rounded, "CUSTOMER",
                  "FOOD & MART"),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _roleCard("Delivery Agent", Icons.electric_moped_rounded,
                  "DELIVERY", "DISPATCH"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _roleCard("Restaurant", Icons.storefront_rounded,
                  "RESTAURANT", "MENU & POS"),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _roleCard("Dark Store", Icons.warehouse_rounded,
                  "DARK STORE", "GROCERY HUB"),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(height: 2.5, color: AppTheme.black),
        const SizedBox(height: 16),

        // Form Fields for Selected Role
        if (_selectedSignUpRole != "Dark Store") ...[
          Text(
            _selectedSignUpRole == "Restaurant"
                ? "RESTAURANT NAME *"
                : "FULL NAME *",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _signUpNameController,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: _selectedSignUpRole == "Restaurant"
                  ? "e.g. Royal Bistro"
                  : "e.g. Aarav Sharma",
              prefixIcon: const Icon(Icons.person_rounded,
                  color: AppTheme.black, size: 20),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Mobile Number
        Text(
          "MOBILE NUMBER *",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _signUpPhoneController,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: "10-digit mobile number",
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "🇮🇳 +91",
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.black,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 2, height: 18, color: AppTheme.black),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Create Password
        Text(
          "CREATE PASSWORD *",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _signUpPasswordController,
          obscureText: _obscureSignUpPassword,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: "Minimum 6 characters",
            prefixIcon: const Icon(Icons.lock_rounded,
                color: AppTheme.black, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignUpPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppTheme.black,
                size: 20,
              ),
              onPressed: () => setState(
                  () => _obscureSignUpPassword = !_obscureSignUpPassword),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Delivery Agent Specific Fields
        if (_selectedSignUpRole == "Delivery Agent") ...[
          Text(
            "VEHICLE NUMBER",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _vehicleNoController,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: "e.g. KA-01-AB-1234",
              prefixIcon: Icon(Icons.two_wheeler_rounded,
                  color: AppTheme.black, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _vType,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
            decoration: const InputDecoration(
              labelText: "VEHICLE TYPE",
            ),
            items: [
              "Motorcycle",
              "Electric Scooter",
              "Scooter",
              "Bicycle",
              "Car"
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (val) => setState(() => _vType = val!),
          ),
          const SizedBox(height: 14),
        ],

        // Restaurant Location
        if (_selectedSignUpRole == "Restaurant") ...[
          Text(
            "RESTAURANT LOCATION / AREA *",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _areaController,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: "e.g. Indiranagar, Bengaluru",
              prefixIcon: Icon(Icons.location_on_rounded,
                  color: AppTheme.black, size: 20),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Customer & Dark Store Address
        if (_selectedSignUpRole == "User" ||
            _selectedSignUpRole == "Dark Store") ...[
          Text(
            "STREET ADDRESS",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _streetController,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: "e.g. 12th Main, Plot 42",
              prefixIcon:
                  Icon(Icons.home_rounded, color: AppTheme.black, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AREA / CITY *",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _areaController,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: "e.g. Koramangala",
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
                    Text(
                      "PINCODE",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: "e.g. 560034",
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

        // Sign Up Action Button
        _isLoading
            ? Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.black,
                  border: Border.all(
                      color: AppTheme.black, width: AppTheme.borderWidth),
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppTheme.yellow,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : BrutalistButton(
                text: "REGISTER AS $_selectedSignUpRole →",
                bgColor: AppTheme.black,
                textColor: AppTheme.yellow,
                fullWidth: true,
                onPressed: _handleSignUp,
              ),
      ],
    );
  }

  Widget _roleCard(
      String roleKey, IconData icon, String title, String subtitle) {
    final isSelected = _selectedSignUpRole == roleKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSignUpRole = roleKey;
          _errorMessage = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: AppTheme.black,
            width: isSelected ? 3.0 : AppTheme.borderWidth,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppTheme.black,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: AppTheme.black),
                if (isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.black,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppTheme.black,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF555555),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

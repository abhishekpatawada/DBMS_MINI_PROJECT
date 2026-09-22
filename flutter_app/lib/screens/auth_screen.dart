import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/dbms_settings_service.dart';
import '../widgets/dbms_live_query_visualizer.dart';
import 'user/user_dashboard_screen.dart';
import 'delivery_agent/delivery_agent_dashboard_screen.dart';
import 'restaurant/restaurant_dashboard_screen.dart';
import 'dark_store/dark_store_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  final String selectedRole;

  const AuthScreen({Key? key, required this.selectedRole}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<DbmsLiveQueryVisualizerState> _visualizerKey = GlobalKey<DbmsLiveQueryVisualizerState>();
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;

  // Sign In controller
  final _phoneOrIdController = TextEditingController();

  // Sign Up controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  String _vType = "Motorcycle";
  bool _hasLicense = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Pre-populate with a demo phone number matching database records
    _phoneOrIdController.text = "9810000001";
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneOrIdController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _vehicleNoController.dispose();
    super.dispose();
  }

  void _navigateToDashboard(Map<String, dynamic> userData) {
    Widget targetScreen;
    switch (widget.selectedRole) {
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
    final identifier = _phoneOrIdController.text.trim();
    if (identifier.isEmpty) {
      setState(() => _errorMessage = "Please enter your phone number or ID");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService.login(widget.selectedRole, identifier);
      
      // If DBMS Simulation is enabled globally, trigger Table Selection & Row Scanning Animation
      if (DbmsSettingsService.isSimulationEnabled.value && _visualizerKey.currentState != null) {
        _visualizerKey.currentState!.startExecutionAnimation(
          onDone: () {
            if (mounted) {
              _navigateToDashboard(res['data']);
            }
          },
        );
      } else {
        if (mounted) {
          _navigateToDashboard(res['data']);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> res;
      if (widget.selectedRole == "User") {
        if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
          throw Exception("Name and Phone are required.");
        }
        res = await ApiService.registerUser({
          "name": _nameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "street": _streetController.text.trim(),
          "area": _areaController.text.trim(),
          "state": _stateController.text.trim(),
          "pincode": _pincodeController.text.trim(),
        });
      } else if (widget.selectedRole == "Delivery Agent") {
        if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
          throw Exception("Name and Phone are required.");
        }
        res = await ApiService.registerAgent({
          "name": _nameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "vehicle_no": _vehicleNoController.text.trim(),
          "v_type": _vType,
          "has_license": _hasLicense,
        });
      } else if (widget.selectedRole == "Restaurant") {
        if (_nameController.text.trim().isEmpty || _areaController.text.trim().isEmpty) {
          throw Exception("Restaurant Name and Location are required.");
        }
        res = await ApiService.registerRestaurant({
          "name": _nameController.text.trim(),
          "location": _areaController.text.trim(),
          "phone": _phoneController.text.trim(),
        });
      } else {
        // Dark Store
        if (_streetController.text.trim().isEmpty || _areaController.text.trim().isEmpty) {
          throw Exception("Street and Area are required.");
        }
        res = await ApiService.registerDarkStore({
          "street": _streetController.text.trim(),
          "area": _areaController.text.trim(),
          "state": _stateController.text.trim(),
          "pincode": _pincodeController.text.trim(),
        });
      }

      if (mounted) {
        _navigateToDashboard(res['data']);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text("${widget.selectedRole} Authentication"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: DbmsSimulationToggleSwitch(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 950;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT SCREEN: DBMS Live Execution & Table/Row Scanning Animation
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: DbmsLiveQueryVisualizer(
                      key: _visualizerKey,
                      role: widget.selectedRole,
                      identifier: _phoneOrIdController.text,
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFCBD5E1)),
                // RIGHT SCREEN: Auth Form Card
                Expanded(
                  flex: 5,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _buildAuthCard(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Stacked layout for smaller screens
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 380,
                    child: DbmsLiveQueryVisualizer(
                      key: _visualizerKey,
                      role: widget.selectedRole,
                      identifier: _phoneOrIdController.text,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAuthCard(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAuthCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Target Table / Role: ", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  Text(
                    widget.selectedRole,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6366F1), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF6366F1),
              labelColor: const Color(0xFF6366F1),
              unselectedLabelColor: const Color(0xFF64748B),
              tabs: const [
                Tab(text: "Sign In (Live Scan)"),
                Tab(text: "Sign Up (Register)"),
              ],
            ),
            const SizedBox(height: 20),

            // Error Alert
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tab Content
            SizedBox(
              height: widget.selectedRole == "User" || widget.selectedRole == "Delivery Agent" ? 340 : 280,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // SIGN IN VIEW
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "Enter registered phone number to test row scanning:",
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneOrIdController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: widget.selectedRole == "Dark Store" ? "Store ID / Pincode" : "Phone Number",
                          prefixIcon: const Icon(Icons.phone_outlined),
                          hintText: widget.selectedRole == "Dark Store" ? "e.g. 1 or 560038" : "e.g. 9810010001",
                          helperText: "Watch the SQL query on the left update as you type",
                        ),
                        onChanged: (val) {
                          // Update visualizer state immediately
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _handleSignIn();
                              },
                        icon: _isLoading
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.play_arrow_rounded),
                        label: Text(_isLoading ? "Scanning Tuples in DB..." : "Execute Query & Sign In"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),

                  // SIGN UP VIEW
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.selectedRole != "Dark Store") ...[
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: widget.selectedRole == "Restaurant" ? "Restaurant Name *" : "Full Name *",
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: "Phone Number *",
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (widget.selectedRole == "User" || widget.selectedRole == "Dark Store") ...[
                          TextField(
                            controller: _streetController,
                            decoration: const InputDecoration(
                              labelText: "Street Address",
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _areaController,
                            decoration: const InputDecoration(
                              labelText: "Area / City *",
                              prefixIcon: Icon(Icons.map_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: "State",
                              prefixIcon: Icon(Icons.flag_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Pincode",
                              prefixIcon: Icon(Icons.pin_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (widget.selectedRole == "Restaurant") ...[
                          TextField(
                            controller: _areaController,
                            decoration: const InputDecoration(
                              labelText: "Location / Address *",
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (widget.selectedRole == "Delivery Agent") ...[
                          TextField(
                            controller: _vehicleNoController,
                            decoration: const InputDecoration(
                              labelText: "Vehicle Number",
                              prefixIcon: Icon(Icons.two_wheeler_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _vType,
                            decoration: const InputDecoration(labelText: "Vehicle Type"),
                            items: ["Motorcycle", "Electric Scooter", "Scooter", "Bicycle", "Car"]
                                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (val) => setState(() => _vType = val!),
                          ),
                          const SizedBox(height: 12),
                        ],

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Register & Open Dashboard"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

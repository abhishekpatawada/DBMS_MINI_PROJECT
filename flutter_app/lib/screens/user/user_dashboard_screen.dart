import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';
import '../../services/api_service.dart';
import '../../services/cart_manager.dart';
import '../../models/models.dart';
import '../restaurant/restaurant_detail_screen.dart';
import 'cart_checkout_screen.dart';
import 'order_tracking_screen.dart';
import '../../utils/item_image_helper.dart';
import '../../widgets/floating_cart_bar.dart';
import 'user_profile_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserDashboardScreen({super.key, required this.userData});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0; // 0: Home, 1: Instamart, 2: Orders, 3: Profile
  late int _userId;
  late String _userName;
  late String _userPhone;

  List<RestaurantModel> _restaurants = [];
  List<RestaurantItemModel> _allDishes = [];
  List<DarkStoreModel> _darkStores = [];
  List<GroceryItemModel> _allGroceries = [];
  List<OrderModel> _myOrders = [];
  bool _isLoading = true;

  // Food Delivery Feed State
  String _foodViewMode = "dishes"; // "dishes" or "restaurants"
  String _dishSearchQuery = "";
  String _activeDishCategory = "All";
  final String _activeDishVegFilter = "All";
  String _restaurantSortFilter = "Sort ▾";

  // Groceries / Instamart State
  int? _selectedDarkStoreId;
  String _grocerySearchQuery = "";
  String _activeGroceryCategory = "All";
  bool _isInstamartDarkMode = false;

  // Orders Filter State
  String _orderFilter = "All"; // "All", "Ongoing", "Delivered", "Cancelled", "⭐ Most Ordered"
  String _mostOrderedSubCategory = "All"; // "All", "Dishes", "Groceries", "Restaurants"
  Map<String, dynamic> _mostOrderedData = {
    'dishes': [],
    'groceries': [],
    'restaurants': [],
  };

  // Search Screen Overlay State
  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();
  final List<String> _recentSearches = ["milk", "bread", "chips", "eggs"];
  final List<String> _popularSearches = ["atta", "rice", "oil", "paneer", "butter", "cheese", "curd", "chocolate", "biryani", "pizza"];

  final List<Map<String, String>> _foodCategories = [
    {"name": "All", "icon": "🍽️", "label": "All Dishes"},
    {"name": "Most Ordered", "icon": "⭐", "label": "Most Ordered"},
    {"name": "Biryani", "icon": "🍛", "label": "Biryani"},
    {"name": "Pizza", "icon": "🍕", "label": "Pizzas"},
    {"name": "Burgers", "icon": "🍔", "label": "Burgers"},
    {"name": "Curries", "icon": "🥘", "label": "Curries"},
    {"name": "South Indian", "icon": "🥞", "label": "South Indian"},
    {"name": "Chinese", "icon": "🍜", "label": "Chinese"},
    {"name": "Desserts", "icon": "🍰", "label": "Desserts"},
    {"name": "Beverages", "icon": "☕", "label": "Beverages"},
  ];

  final List<Map<String, String>> _instamartCategories = [
    {"name": "All", "icon": "⚡", "label": "All Items"},
    {"name": "Most Ordered", "icon": "⭐", "label": "Most Ordered"},
    {"name": "Dairy & Bread", "icon": "🥛", "label": "Dairy & Bread"},
    {"name": "Fresh Produce", "icon": "🥦", "label": "Fruits & Veg"},
    {"name": "Snacks & Munchies", "icon": "🍿", "label": "Munchies"},
    {"name": "Atta, Rice & Dal", "icon": "🌾", "label": "Atta & Dals"},
    {"name": "Drinks & Juices", "icon": "🥤", "label": "Cold Drinks"},
    {"name": "Instant Food", "icon": "🍜", "label": "Instant Food"},
    {"name": "Sweets & Treats", "icon": "🍫", "label": "Chocolates"},
    {"name": "Cleaning & Home", "icon": "🧼", "label": "Home & Bath"},
  ];

  @override
  void initState() {
    super.initState();
    _userId = widget.userData['User_Id'] ?? widget.userData['userId'] ?? 1;
    _userName = widget.userData['User_Name'] ?? widget.userData['userName'] ?? 'Customer';
    _userPhone = widget.userData['User_Phone'] ?? widget.userData['userPhone'] ?? '';

    // Initialize delivery address
    final street = widget.userData['Street'] ?? '';
    final area = widget.userData['Area'] ?? '';
    final state = widget.userData['State'] ?? '';
    final pincode = widget.userData['Pincode'] ?? '';
    if (area.isNotEmpty || street.isNotEmpty) {
      cartManager.setDeliveryAddress("Home • $street, $area, $state - $pincode".trim());
    }

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final rests = await ApiService.getRestaurants();
      final dishes = await ApiService.getAllDishes();
      final stores = await ApiService.getDarkStores();
      final groceries = await ApiService.getAllGroceries();
      final orders = await ApiService.getUserOrders(_userId);
      final mostOrdered = await ApiService.getUserMostOrdered(_userId);

      if (mounted) {
        setState(() {
          _restaurants = rests;
          _allDishes = dishes;
          _darkStores = stores;
          _allGroceries = groceries;
          _myOrders = orders;
          _mostOrderedData = mostOrdered;
          if (_selectedDarkStoreId == null && stores.isNotEmpty) {
            _selectedDarkStoreId = stores.first.storeId;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  // Address picker
  void _showAddressPicker() {
    final addresses = [
      "Home • Sector 62, Noida, Uttar Pradesh - 201309",
      "Office • Cyber City, Tower B, Gurugram, Haryana - 122002",
      "Hostel • Block C, Knowledge Park III, Greater Noida - 201306",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Delivery Location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 14),
            ...addresses.map((addr) {
              final isSelected = cartManager.deliveryAddress == addr;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                ),
                child: ListTile(
                  title: Text(addr.split("•").first.trim(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(addr.split("•").last.trim(), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  trailing: isSelected ? const Text("Active", style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)) : null,
                  onTap: () {
                    cartManager.setDeliveryAddress(addr);
                    Navigator.pop(ctx);
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text("Add / Edit Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  side: const BorderSide(color: Color(0xFFC7D2FE)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddEditAddressModal();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Screen 10: Add / Edit Address Modal
  void _showAddEditAddressModal() {
    String selectedType = "Home";
    final nameCtrl = TextEditingController(text: _userName);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final addressSearchCtrl = TextEditingController(text: "14 MG Road, Indiranagar");
    final flatCtrl = TextEditingController(text: "Flat 101, Sunrise Apartments");
    final areaCtrl = TextEditingController(text: "Indiranagar");
    final cityCtrl = TextEditingController(text: "Bengaluru");
    final pinCtrl = TextEditingController(text: "560038");
    bool isDefault = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add/ Edit Address",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Segmented tabs: Home, Work, Other
                Row(
                  children: ["Home", "Work", "Other"].map((type) {
                    final isSel = selectedType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedType = type),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              type,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSel ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _buildAddressField("Full Name", nameCtrl, icon: Icons.person_outline),
                const SizedBox(height: 12),
                _buildAddressField("Phone Number", phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildAddressField("Address", addressSearchCtrl, icon: Icons.search),
                const SizedBox(height: 12),
                _buildAddressField("Flat / House / Building", flatCtrl, icon: Icons.home_outlined),
                const SizedBox(height: 12),
                _buildAddressField("Area / Locality", areaCtrl, icon: Icons.location_city_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildAddressField("City", cityCtrl)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildAddressField("Pincode", pinCtrl, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Set as default address", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    Switch(
                      value: isDefault,
                      activeTrackColor: const Color(0xFF4F46E5),
                      onChanged: (v) => setModalState(() => isDefault = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final formatted = "$selectedType • ${flatCtrl.text.trim()}, ${areaCtrl.text.trim()}, ${cityCtrl.text.trim()} - ${pinCtrl.text.trim()}";
                    cartManager.setDeliveryAddress(formatted);
                    Navigator.pop(ctx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Address saved successfully!"), backgroundColor: Color(0xFF10B981)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField(String label, TextEditingController ctrl, {IconData? icon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF94A3B8)) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }

  // Instamart Dark Store Switcher
  void _showStorePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚡ Select Instamart Dark Store Hub",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              "Orders are fulfilled in 10-15 minutes from your nearest hub.",
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: _darkStores.length,
                itemBuilder: (ctx, i) {
                  final s = _darkStores[i];
                  final isSelected = _selectedDarkStoreId == s.storeId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
                    ),
                    child: ListTile(
                      leading: Text(isSelected ? "⚡" : "🏬", style: const TextStyle(fontSize: 22)),
                      title: Text(
                        "Dark Store Hub #${s.storeId} • ${s.dsArea ?? 'Indiranagar'}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        "${s.dsStreet ?? ''}, ${s.dsState ?? ''} - ${s.dsPincode ?? ''}".trim(),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      trailing: isSelected
                          ? const Text("Connected", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))
                          : null,
                      onTap: () {
                        setState(() => _selectedDarkStoreId = s.storeId);
                        Navigator.pop(ctx);
                      },
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

  // Handle adding items with vendor conflict checking
  void _handleAddItem({
    required String itemName,
    String? foodName,
    required double price,
    bool isVeg = true,
    String? imageUrl,
    int? restId,
    String? restName,
    int? storeId,
    String? storeArea,
    required String type,
  }) {
    if (cartManager.canAddFrom(restId: restId, storeId: storeId, type: type)) {
      cartManager.addItem(
        itemName: itemName,
        foodName: foodName,
        price: price,
        isVeg: isVeg,
        imageUrl: imageUrl,
        restId: restId,
        restName: restName,
        storeId: storeId,
        storeArea: storeArea,
        type: type,
      );
    } else {
      // Vendor conflict: Prompt user to replace cart
      final currentVendor = cartManager.orderType == "Restaurant"
          ? (cartManager.activeRestName ?? "another restaurant")
          : "Instamart Dark Store Hub";
      final newVendor = type == "Restaurant" ? (restName ?? "new restaurant") : "Instamart Quick Groceries";

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Replace Cart Items?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              Text(
                "Your basket currently contains items from $currentVendor.\nDo you want to discard them and add items from $newVendor instead?",
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        cartManager.clear();
                        cartManager.addItem(
                          itemName: itemName,
                          foodName: foodName,
                          price: price,
                          isVeg: isVeg,
                          imageUrl: imageUrl,
                          restId: restId,
                          restName: restName,
                          storeId: storeId,
                          storeArea: storeArea,
                          type: type,
                        );
                      },
                      child: const Text("Discard & Add", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  // Parse weight/pack from item name
  String _parseWeight(String itemName) {
    final reg = RegExp(r'(\d+(\.\d+)?\s*(g|kg|ml|l|pcs|pack))', caseSensitive: false);
    final match = reg.firstMatch(itemName);
    if (match != null) return match.group(0)!;
    return "Standard Pack";
  }

  // Categorize grocery items for Instamart
  String _getGroceryCategory(String itemName) {
    final lower = itemName.toLowerCase();
    if (lower.contains("milk") ||
        lower.contains("butter") ||
        lower.contains("paneer") ||
        lower.contains("cheese") ||
        lower.contains("bread") ||
        lower.contains("egg") ||
        lower.contains("yogurt") ||
        lower.contains("curd")) {
      return "Dairy & Bread";
    }
    if (lower.contains("onion") ||
        lower.contains("potato") ||
        lower.contains("tomato") ||
        lower.contains("vegetable") ||
        lower.contains("fruit") ||
        lower.contains("apple") ||
        lower.contains("banana") ||
        lower.contains("lemon")) {
      return "Fresh Produce";
    }
    if (lower.contains("lays") ||
        lower.contains("kurkure") ||
        lower.contains("bhujia") ||
        lower.contains("oreo") ||
        lower.contains("biscuit") ||
        lower.contains("cookie") ||
        lower.contains("chips") ||
        lower.contains("wafer") ||
        lower.contains("namkeen")) {
      return "Snacks & Munchies";
    }
    if (lower.contains("atta") ||
        lower.contains("rice") ||
        lower.contains("dal") ||
        lower.contains("oil") ||
        lower.contains("salt") ||
        lower.contains("sugar") ||
        lower.contains("flour") ||
        lower.contains("ghee") ||
        lower.contains("basmati")) {
      return "Atta, Rice & Dal";
    }
    if (lower.contains("tea") ||
        lower.contains("coffee") ||
        lower.contains("juice") ||
        lower.contains("coke") ||
        lower.contains("pepsi") ||
        lower.contains("sprite") ||
        lower.contains("drink") ||
        lower.contains("water") ||
        lower.contains("lassi")) {
      return "Drinks & Juices";
    }
    if (lower.contains("maggi") ||
        lower.contains("noodle") ||
        lower.contains("ketchup") ||
        lower.contains("sauce") ||
        lower.contains("nutella") ||
        lower.contains("spread") ||
        lower.contains("pasta") ||
        lower.contains("soup")) {
      return "Instant Food";
    }
    if (lower.contains("chocolate") ||
        lower.contains("cadbury") ||
        lower.contains("sweet") ||
        lower.contains("candy") ||
        lower.contains("bar") ||
        lower.contains("mithai")) {
      return "Sweets & Treats";
    }
    if (lower.contains("soap") ||
        lower.contains("shampoo") ||
        lower.contains("colgate") ||
        lower.contains("paste") ||
        lower.contains("brush") ||
        lower.contains("detergent") ||
        lower.contains("surf") ||
        lower.contains("vim") ||
        lower.contains("cleaner") ||
        lower.contains("harpic") ||
        lower.contains("lizol") ||
        lower.contains("dettol")) {
      return "Cleaning & Home";
    }
    return "All";
  }

  // Filtered dishes
  List<RestaurantItemModel> get _filteredDishes {
    var list = _allDishes.where((dish) {
      // Search filter
      if (_dishSearchQuery.isNotEmpty) {
        final q = _dishSearchQuery.toLowerCase();
        final match = dish.itemName.toLowerCase().contains(q) ||
            (dish.foodName ?? '').toLowerCase().contains(q) ||
            (dish.restaurantName ?? '').toLowerCase().contains(q);
        if (!match) return false;
      }

      // Most Ordered category check
      if (_activeDishCategory == "Most Ordered" || _restaurantSortFilter == "⭐ Most Ordered") {
        final mostOrderedNames = (_mostOrderedData['dishes'] as List? ?? [])
            .map((d) => (d['Item_Name'] ?? d['item_name'] ?? '').toString().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toSet();
        if (mostOrderedNames.isNotEmpty) {
          final dName = dish.itemName.toLowerCase();
          final matches = mostOrderedNames.any((m) => dName.contains(m) || m.contains(dName));
          if (!matches && _activeDishCategory == "Most Ordered") return false;
        }
      }

      // Category filter
      if (_activeDishCategory != "All" && _activeDishCategory != "Most Ordered") {
        final catLower = _activeDishCategory.toLowerCase();
        final nameLower = dish.itemName.toLowerCase();
        final foodLower = (dish.foodName ?? '').toLowerCase();
        if (!nameLower.contains(catLower) && !foodLower.contains(catLower)) {
          if (_activeDishCategory == "Biryani" && !nameLower.contains("biryani") && !foodLower.contains("biryani")) return false;
          if (_activeDishCategory == "Pizza" && !nameLower.contains("pizza") && !foodLower.contains("pizza")) return false;
          if (_activeDishCategory == "Burgers" && !nameLower.contains("burger") && !foodLower.contains("burger")) return false;
          if (_activeDishCategory == "Curries" && !nameLower.contains("curry") && !nameLower.contains("masala") && !foodLower.contains("curry")) return false;
        }
      }

      // Veg / Non-Veg / Rating filters
      if (_activeDishVegFilter == "Pure Veg" && !dish.isVeg) return false;
      if (_activeDishVegFilter == "Non-Veg" && dish.isVeg) return false;
      if (_activeDishVegFilter == "Rating 4.0+" && (dish.restaurantRating ?? 4.0) < 4.0) return false;
      if (_activeDishVegFilter == "Discounts" && dish.discount <= 0) return false;

      return true;
    }).toList();

    if (_activeDishCategory == "Most Ordered" || _restaurantSortFilter == "⭐ Most Ordered") {
      final mostOrderedNames = (_mostOrderedData['dishes'] as List? ?? [])
          .map((d) => (d['Item_Name'] ?? d['item_name'] ?? '').toString().toLowerCase())
          .toList();
      list.sort((a, b) {
        final aIdx = mostOrderedNames.indexWhere((m) => a.itemName.toLowerCase().contains(m) || m.contains(a.itemName.toLowerCase()));
        final bIdx = mostOrderedNames.indexWhere((m) => b.itemName.toLowerCase().contains(m) || m.contains(b.itemName.toLowerCase()));
        if (aIdx != -1 && bIdx != -1) return aIdx.compareTo(bIdx);
        if (aIdx != -1) return -1;
        if (bIdx != -1) return 1;
        return (b.restaurantRating ?? 4.0).compareTo(a.restaurantRating ?? 4.0);
      });
    }

    return list;
  }

  // Filtered restaurants (for hotel view mode)
  List<RestaurantModel> get _filteredRestaurants {
    var list = _restaurants.where((r) {
      final q = _dishSearchQuery.toLowerCase();
      if (q.isNotEmpty) {
        final nameMatches = r.rName.toLowerCase().contains(q) || r.rLocation.toLowerCase().contains(q);
        if (!nameMatches) return false;
      }
      if (_activeDishVegFilter == "Rating 4.0+" && r.rRating < 4.0) return false;
      return true;
    }).toList();

    if (_restaurantSortFilter == "⭐ Most Ordered") {
      final mostOrderedRestIds = (_mostOrderedData['restaurants'] as List? ?? [])
          .map((m) => m['Rest_Id'] ?? m['rest_id'])
          .whereType<int>()
          .toList();
      list.sort((a, b) {
        final aIdx = mostOrderedRestIds.indexOf(a.restId);
        final bIdx = mostOrderedRestIds.indexOf(b.restId);
        if (aIdx != -1 && bIdx != -1) return aIdx.compareTo(bIdx);
        if (aIdx != -1) return -1;
        if (bIdx != -1) return 1;
        return b.rRating.compareTo(a.rRating);
      });
    }

    return list;
  }

  // Filtered groceries for Instamart
  List<GroceryItemModel> get _filteredGroceries {
    var list = _allGroceries.where((g) {
      // Store filter
      if (_selectedDarkStoreId != null && g.storeId != _selectedDarkStoreId) {
        return false;
      }

      // Search query
      if (_grocerySearchQuery.isNotEmpty) {
        final q = _grocerySearchQuery.toLowerCase();
        if (!g.itemName.toLowerCase().contains(q)) return false;
      }

      // Category filter
      if (_activeGroceryCategory == "Most Ordered") {
        final mostOrderedGrocs = (_mostOrderedData['groceries'] as List? ?? [])
            .map((m) => (m['Item_Name'] ?? m['item_name'] ?? '').toString().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toSet();
        if (mostOrderedGrocs.isNotEmpty) {
          final gName = g.itemName.toLowerCase();
          final matches = mostOrderedGrocs.any((m) => gName.contains(m) || m.contains(gName));
          if (!matches) return false;
        }
      } else if (_activeGroceryCategory != "All") {
        final itemCat = _getGroceryCategory(g.itemName);
        if (itemCat != _activeGroceryCategory) return false;
      }

      return true;
    }).toList();

    if (_activeGroceryCategory == "Most Ordered") {
      final mostOrderedGrocs = (_mostOrderedData['groceries'] as List? ?? [])
          .map((m) => (m['Item_Name'] ?? m['item_name'] ?? '').toString().toLowerCase())
          .toList();
      list.sort((a, b) {
        final aIdx = mostOrderedGrocs.indexWhere((m) => a.itemName.toLowerCase().contains(m) || m.contains(a.itemName.toLowerCase()));
        final bIdx = mostOrderedGrocs.indexWhere((m) => b.itemName.toLowerCase().contains(m) || m.contains(b.itemName.toLowerCase()));
        if (aIdx != -1 && bIdx != -1) return aIdx.compareTo(bIdx);
        if (aIdx != -1) return -1;
        if (bIdx != -1) return 1;
        return b.price.compareTo(a.price);
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearching) {
      return _buildSearchOverlayScreen();
    }

    final isDark = _selectedIndex == 1 && _isInstamartDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: _selectedIndex == 3
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag_outlined, color: Color(0xFF4F46E5)),
                    ),
                  ),
                ),
              ),
              title: InkWell(
                onTap: _showAddressPicker,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Home ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5)),
                        ],
                      ),
                      Text(
                        cartManager.deliveryAddress.contains("•") ? cartManager.deliveryAddress.split("•").last.trim() : cartManager.deliveryAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Notification Button with Interactive Sheet
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  tooltip: "Notifications",
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (ctx) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Notifications & Offers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                children: [
                                  Icon(Icons.discount_rounded, color: Color(0xFF4F46E5), size: 22),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("50% OFF on your first Bite order!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                        Text("Use coupon BITE50 at checkout", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                children: [
                                  Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 22),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("10-Minute Hub Express Delivery Active", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                        Text("Groceries delivered to your doorstep in minutes", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Got It"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Active Cart Icon with Badge
                AnimatedBuilder(
                  animation: cartManager,
                  builder: (context, _) => Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_bag_outlined, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                        tooltip: "Cart",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartCheckoutScreen(userData: widget.userData),
                            ),
                          );
                        },
                      ),
                      if (cartManager.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${cartManager.totalCount}",
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Profile Avatar in Top Right
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 3),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        border: Border.all(color: AppTheme.black, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.black,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : "C",
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.black,
                    strokeWidth: 3,
                  ),
                )
              : IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildFoodDeliveryView(),
                    _buildInstamartView(),
                    _buildOrdersView(),
                    UserProfileScreen(
                      userData: widget.userData,
                      onProfileUpdated: () {
                        setState(() {
                          _userName = widget.userData['User_Name'] ?? widget.userData['userName'] ?? _userName;
                          _userPhone = widget.userData['User_Phone'] ?? widget.userData['userPhone'] ?? _userPhone;
                        });
                      },
                    ),
                  ],
                ),

          // Persistent Floating Cart Bar across all views except profile
          if (_selectedIndex != 3)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingCartBar(userData: widget.userData),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBrutalistTab(0, "FOOD", Icons.restaurant_rounded),
                _buildBrutalistTab(1, "10-MIN", Icons.bolt_rounded),
                _buildBrutalistTab(2, "ORDERS", Icons.receipt_long_rounded),
                _buildBrutalistTab(3, "PROFILE", Icons.person_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalistTab(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: isSelected
              ? Border.all(color: AppTheme.black, width: 2.0)
              : Border.all(color: Colors.transparent, width: 2.0),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppTheme.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppTheme.black),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: AppTheme.black,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Screen 11: Interactive Search Overlay
  Widget _buildSearchOverlayScreen() {
    final query = _searchQueryController.text.trim().toLowerCase();
    final matchingDishes = _allDishes
        .where((d) => d.itemName.toLowerCase().contains(query) || (d.foodName ?? '').toLowerCase().contains(query))
        .take(8)
        .toList();
    final matchingGroceries = _allGroceries
        .where((g) => g.itemName.toLowerCase().contains(query))
        .take(8)
        .toList();
    final matchingRests = _restaurants
        .where((r) => r.rName.toLowerCase().contains(query) || r.rLocation.toLowerCase().contains(query))
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => setState(() => _isSearching = false),
        ),
        title: TextField(
          controller: _searchQueryController,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: "Search for restaurants, dishes, groceries...",
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            border: InputBorder.none,
            suffixIcon: _searchQueryController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF64748B), size: 18),
                    onPressed: () {
                      _searchQueryController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (query.isNotEmpty) ...[
            if (matchingDishes.isNotEmpty) ...[
              const Text("DISHES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              ...matchingDishes.map((dish) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                    title: Text(dish.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: Text("₹${dish.finalPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                    onTap: () {
                      _dishSearchQuery = dish.itemName;
                      _isSearching = false;
                      _selectedIndex = 0;
                      _foodViewMode = "dishes";
                      setState(() {});
                    },
                  )),
              const Divider(height: 24),
            ],
            if (matchingGroceries.isNotEmpty) ...[
              const Text("GROCERIES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              ...matchingGroceries.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bolt, size: 20, color: Color(0xFF10B981)),
                    title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: Text("₹${item.price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    onTap: () {
                      _grocerySearchQuery = item.itemName;
                      _isSearching = false;
                      _selectedIndex = 1;
                      setState(() {});
                    },
                  )),
              const Divider(height: 24),
            ],
            if (matchingRests.isNotEmpty) ...[
              const Text("RESTAURANTS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              ...matchingRests.map((r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restaurant, size: 20, color: Color(0xFF4F46E5)),
                    title: Text(r.rName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(r.rLocation, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    onTap: () {
                      _isSearching = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailScreen(restaurant: r, userData: widget.userData),
                        ),
                      );
                    },
                  )),
            ],
          ] else ...[
            // Recent Searches (Screen 11)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                TextButton(
                  onPressed: () => setState(() => _recentSearches.clear()),
                  child: const Text("Clear all", style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE2E8F0))),
                    onPressed: () {
                      _searchQueryController.text = s;
                      setState(() {});
                    },
                  )).toList(),
            ),
            const SizedBox(height: 24),
            // Popular Searches (Screen 11)
            const Text("Popular Searches", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularSearches.map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                    backgroundColor: const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE2E8F0))),
                    onPressed: () {
                      _searchQueryController.text = s;
                      setState(() {});
                    },
                  )).toList(),
            ),
          ],
        ],
      ),
    );
  }


  // ===========================================================================
  // 1. FOOD DELIVERY (ITEM-WISE DISH DISCOVERY FEED)
  // ===========================================================================
  Widget _buildFoodDeliveryView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // 1. Search Bar (Screen 1) - Brutalist 2.0
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: GestureDetector(
                onTap: () => setState(() => _isSearching = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
                    boxShadow: const [
                      BoxShadow(color: AppTheme.black, offset: Offset(3, 3), blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppTheme.black, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dishSearchQuery.isNotEmpty ? _dishSearchQuery : "SEARCH RESTAURANTS, DISHES...",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: _dishSearchQuery.isNotEmpty ? AppTheme.black : AppTheme.black.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (_dishSearchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _dishSearchQuery = ""),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Icon(Icons.close, size: 14, color: AppTheme.yellow),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Hero Promo Banner (Screen 1) - Brutalist 2.0
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(4, 4), blurRadius: 0),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              "⚡ LIGHTNING DISPATCH",
                              style: GoogleFonts.ibmPlexMono(
                                color: AppTheme.yellow,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "DELICIOUS FOOD\nDIRECT TO DOOR",
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Curated chef kitchens & instant deliveries",
                            style: GoogleFonts.inter(
                              color: AppTheme.black.withValues(alpha: 0.8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppTheme.black, width: 2),
                        boxShadow: const [
                          BoxShadow(color: AppTheme.black, offset: Offset(3, 3), blurRadius: 0),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        "https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=300&auto=format&fit=crop&q=80",
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Text("🍛", style: TextStyle(fontSize: 36))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Category Row (Screen 1) - Brutalist 2.0
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: SizedBox(
                height: 84,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _foodCategories.length,
                  itemBuilder: (ctx, i) {
                    final cat = _foodCategories[i];
                    final isSelected = _activeDishCategory == cat["name"];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeDishCategory = cat["name"]!;
                          if (cat["name"] != "All") {
                            _foodViewMode = "dishes";
                          }
                        });
                      },
                      child: Container(
                        width: 68,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.yellow : AppTheme.surface,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                border: Border.all(
                                  color: AppTheme.black,
                                  width: isSelected ? 2.5 : 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.black,
                                    offset: isSelected ? const Offset(2.5, 2.5) : const Offset(1.5, 1.5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(cat["icon"]!, style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat["name"]!.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                color: isSelected ? AppTheme.black : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 4. Top Restaurants Section (Screen 1)
          SliverToBoxAdapter(
            child: _buildTopRestaurantsHorizontal(),
          ),

          // 5. All Restaurants & Filter Bar (Screen 3)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _foodViewMode == "dishes" ? "DISHES TO EXPLORE" : "ALL RESTAURANTS",
                        style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.black),
                      ),
                      if (_foodViewMode == "dishes")
                        TextButton(
                          onPressed: () => setState(() => _foodViewMode = "restaurants"),
                          child: Text("VIEW RESTAURANTS", style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.blue)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildFilterBar(),
                ],
              ),
            ),
          ),

          // Header for items count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (_foodViewMode == "dishes"
                        ? "DISHES TO EXPLORE (${_filteredDishes.length})"
                        : "RESTAURANTS DELIVERING (${_filteredRestaurants.length})").toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.black),
                  ),
                ],
              ),
            ),
          ),

          // Content: Dishes Feed OR Restaurant Cards
          if (_foodViewMode == "dishes")
            _filteredDishes.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text("No dishes match your search or filter.", style: TextStyle(color: Colors.grey))),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final dish = _filteredDishes[i];
                          return _buildDishItemCard(dish);
                        },
                        childCount: _filteredDishes.length,
                      ),
                    ),
                  )
          else
            _filteredRestaurants.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text("No restaurants match your search.", style: TextStyle(color: Colors.grey))),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final r = _filteredRestaurants[i];
                          return _buildRestaurantCard(r);
                        },
                        childCount: _filteredRestaurants.length,
                      ),
                    ),
                  ),

          const SliverToBoxAdapter(child: SizedBox(height: 130)),
        ],
      ),
    );
  }


  // Dish Card with direct ADD stepper
  Widget _buildDishItemCard(RestaurantItemModel dish) {
    return AnimatedBuilder(
      animation: cartManager,
      builder: (context, _) {
        final currentQty = cartManager.getItemQuantity(dish.itemName);

        return BrutalistCard(
          bgColor: AppTheme.surface,
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 12),
          shadowOffset: const Offset(3.5, 3.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Dish Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Veg / Non-Veg Indicator & Category tag
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: dish.isVeg ? AppTheme.green : AppTheme.red,
                            border: Border.all(color: AppTheme.black, width: 1.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        if (dish.foodName != null && dish.foodName!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.yellow,
                              border: Border.all(color: AppTheme.black, width: 1),
                            ),
                            child: Text(
                              dish.foodName!.toUpperCase(),
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Dish Title
                    Text(
                      dish.itemName,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Price Section
                    Row(
                      children: [
                        Text(
                          "₹${dish.finalPrice.toStringAsFixed(0)}",
                          style: GoogleFonts.ibmPlexMono(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppTheme.black,
                          ),
                        ),
                        if (dish.discount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            "₹${dish.basePrice.toStringAsFixed(0)}",
                            style: GoogleFonts.ibmPlexMono(
                              decoration: TextDecoration.lineThrough,
                              color: const Color(0xFF888888),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.yellow,
                              border: Border.all(color: AppTheme.black, width: 1),
                            ),
                            child: Text(
                              "${dish.discount.toStringAsFixed(0)}% OFF",
                              style: GoogleFonts.ibmPlexMono(
                                color: AppTheme.black,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Clickable Restaurant Source Link
                    InkWell(
                      onTap: () {
                        final match = _restaurants.firstWhere(
                          (r) => r.restId == dish.restId,
                          orElse: () => RestaurantModel(
                            restId: dish.restId,
                            rName: dish.restaurantName ?? 'Restaurant',
                            rLocation: dish.restaurantLocation ?? 'Indiranagar',
                            rRating: dish.restaurantRating ?? 4.2,
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetailScreen(
                              restaurant: match,
                              userData: widget.userData,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "from ${dish.restaurantName ?? 'Restaurant'}".toUpperCase(),
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.black,
                              ),
                            ),
                            if (dish.restaurantRating != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                "• ★ ${dish.restaurantRating!.toStringAsFixed(1)}",
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.black,
                                ),
                              ),
                            ],
                            const SizedBox(width: 4),
                            const Text("➔", style: TextStyle(fontSize: 10, color: AppTheme.black)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Right Dish Image + ADD Stepper
              Column(
                children: [
                  ItemImageWidget(
                    imageUrl: dish.imageUrl,
                    itemName: dish.itemName,
                    category: dish.foodName,
                    width: 96,
                    height: 86,
                    borderRadius: 2,
                  ),
                  const SizedBox(height: 8),

                  // ADD Button or Stepper
                  if (currentQty == 0)
                    GestureDetector(
                      onTap: () {
                        _handleAddItem(
                          itemName: dish.itemName,
                          foodName: dish.foodName,
                          price: dish.finalPrice,
                          isVeg: dish.isVeg,
                          imageUrl: dish.imageUrl,
                          restId: dish.restId,
                          restName: dish.restaurantName,
                          type: "Restaurant",
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.yellow,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          border: Border.all(color: AppTheme.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.black,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          "ADD +",
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.black,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        border: Border.all(color: AppTheme.black, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => cartManager.decrementItem(dish.itemName),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              child: Text(
                                "—",
                                style: TextStyle(
                                  color: AppTheme.surface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              "$currentQty",
                              style: GoogleFonts.ibmPlexMono(
                                color: AppTheme.yellow,
                                fontWeight: FontWeight.w900,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _handleAddItem(
                                itemName: dish.itemName,
                                foodName: dish.foodName,
                                price: dish.finalPrice,
                                isVeg: dish.isVeg,
                                imageUrl: dish.imageUrl,
                                restId: dish.restId,
                                restName: dish.restaurantName,
                                type: "Restaurant",
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              child: Text(
                                "+",
                                style: TextStyle(
                                  color: AppTheme.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
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
      },
    );
  }

  // Screen 3: Restaurant Card
  Widget _buildRestaurantCard(RestaurantModel r) {
    final eta = "${20 + (r.restId % 4) * 5}-${30 + (r.restId % 4) * 5} MINS";
    final dist = "${(1.2 + (r.restId % 4) * 0.8).toStringAsFixed(1)} KM";
    final costForTwo = "₹${250 + (r.restId % 5) * 50} FOR TWO";
    final bannerPhoto = ItemImageHelper.getBannerForRestaurant(
      r.rName,
      restId: r.restId,
      imageUrl: r.imageUrl,
    );
    final discount = (r.restId % 2 == 0) ? "20% OFF" : "FREE DELIVERY";

    return BrutalistCard(
      bgColor: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      shadowOffset: const Offset(3.5, 3.5),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(
              restaurant: r,
              userData: widget.userData,
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Image with Discount Badge
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: AppTheme.black, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: AppCachedNetworkImage(
                  imageUrl: bannerPhoto,
                  width: 95,
                  height: 95,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    width: 95,
                    height: 95,
                    color: AppTheme.yellow,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black),
                    ),
                  ),
                  errorWidget: Container(
                    width: 95,
                    height: 95,
                    color: AppTheme.bg,
                    child: const Center(
                      child: Icon(Icons.restaurant, color: AppTheme.black),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: Text(
                    discount,
                    style: GoogleFonts.ibmPlexMono(
                      color: AppTheme.black,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Right Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.rName.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          color: AppTheme.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.favorite_border_rounded, size: 18, color: AppTheme.black),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        border: Border.all(color: AppTheme.black, width: 1),
                      ),
                      child: Text(
                        "★ ${r.rRating.toStringAsFixed(1)}",
                        style: GoogleFonts.ibmPlexMono(
                          color: AppTheme.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "• ${r.rLocation.toUpperCase()}",
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 11,
                          color: const Color(0xFF666666),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "$eta • $dist",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 11.5,
                    color: AppTheme.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  costForTwo,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Screen 1: Top Restaurants Horizontal Carousel
  Widget _buildTopRestaurantsHorizontal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOP RESTAURANTS",
                style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.black),
              ),
              GestureDetector(
                onTap: () => setState(() => _foodViewMode = "restaurants"),
                child: Text(
                  "SEE ALL",
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.blue),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _restaurants.take(6).length,
            itemBuilder: (ctx, i) {
              final r = _restaurants[i];
              final banner = ItemImageHelper.getBannerForRestaurant(r.rName);
              final eta = "${20 + (r.restId % 4) * 5}-${30 + (r.restId % 4) * 5} MINS";
              final discount = (r.restId % 2 == 0) ? "20% OFF" : "10% OFF";

              return Container(
                width: 175,
                margin: const EdgeInsets.only(right: 12),
                child: BrutalistCard(
                  bgColor: AppTheme.surface,
                  padding: EdgeInsets.zero,
                  shadowOffset: const Offset(3, 3),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailScreen(restaurant: r, userData: widget.userData),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 98,
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppTheme.black, width: 2)),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              banner,
                              height: 98,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 98, color: AppTheme.yellow),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.yellow,
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: AppTheme.black, width: 1.5),
                                ),
                                child: Text(
                                  discount,
                                  style: GoogleFonts.ibmPlexMono(
                                    color: AppTheme.black,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.rName.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.black),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: AppTheme.black),
                                const SizedBox(width: 2),
                                Text(
                                  r.rRating.toStringAsFixed(1),
                                  style: GoogleFonts.ibmPlexMono(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.black),
                                ),
                                const SizedBox(width: 4),
                                Text("• $eta", style: GoogleFonts.ibmPlexMono(fontSize: 10, color: Colors.black54)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Screen 1 & 3: Filter Chips Bar
  Widget _buildFilterBar() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _filterPill("⭐ Most Ordered"),
          const SizedBox(width: 8),
          _filterPill("Sort ▾"),
          const SizedBox(width: 8),
          _filterPill("Fastest Delivery"),
          const SizedBox(width: 8),
          _filterPill("Top Rated"),
          const SizedBox(width: 8),
          _filterPill("Offers"),
        ],
      ),
    );
  }

  Widget _filterPill(String title) {
    final isSelected = _restaurantSortFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _restaurantSortFilter = isSelected ? "Sort ▾" : title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: AppTheme.black,
            width: isSelected ? 2.5 : AppTheme.borderWidth,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppTheme.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.black,
            ),
          ),
        ),
      ),
    );
  }


  // ===========================================================================
  // 2. QUICK GROCERIES (INSTAMART REPLICA - SCREEN 2 & SCREEN 12)
  // ===========================================================================
  Widget _buildInstamartView() {
    final isDark = _isInstamartDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final currentStore = _darkStores.firstWhere(
      (s) => s.storeId == _selectedDarkStoreId,
      orElse: () => _darkStores.isNotEmpty
          ? _darkStores.first
          : DarkStoreModel(storeId: 1, dsArea: "Indiranagar Hub"),
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // 1. Instamart Hub Header Banner (Brutalism 2.0)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.yellow,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
                boxShadow: const [
                  BoxShadow(color: AppTheme.black, offset: Offset(3, 3), blurRadius: 0),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: AppTheme.yellow, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "⚡ 10-MIN EXPRESS",
                              style: GoogleFonts.ibmPlexMono(
                                color: AppTheme.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "INSTAMART",
                              style: GoogleFonts.spaceGrotesk(
                                color: AppTheme.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "HUB #${currentStore.storeId} • ${(currentStore.dsArea ?? 'Indiranagar').toUpperCase()}",
                          style: GoogleFonts.ibmPlexMono(
                            color: AppTheme.black.withValues(alpha: 0.8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _showStorePickerBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: AppTheme.black, width: 1.5),
                        boxShadow: const [BoxShadow(color: AppTheme.black, offset: Offset(1.5, 1.5))],
                      ),
                      child: Text(
                        "SWITCH ▾",
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Instamart Search Bar (Brutalism 2.0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: GestureDetector(
                onTap: () {
                  _searchQueryController.clear();
                  setState(() => _isSearching = true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
                    boxShadow: const [
                      BoxShadow(color: AppTheme.black, offset: Offset(3, 3), blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppTheme.black, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _grocerySearchQuery.isNotEmpty
                              ? _grocerySearchQuery
                              : "SEARCH MILK, BREAD, CHIPS, EGGS...",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: _grocerySearchQuery.isNotEmpty ? AppTheme.black : AppTheme.black.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      if (_grocerySearchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _grocerySearchQuery = ""),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Icon(Icons.close, size: 14, color: AppTheme.yellow),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Mint Promo Discount Card (Screen 2 & 12) - Brutalist 2.0
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.yellow,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
                boxShadow: const [
                  BoxShadow(color: AppTheme.black, offset: Offset(3, 3), blurRadius: 0),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text("⚡", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹50 OFF ON FIRST 3 ORDERS",
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "USE CODE INSTA50 AT CHECKOUT",
                          style: GoogleFonts.ibmPlexMono(
                            color: AppTheme.black.withValues(alpha: 0.8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Shop by Category (Screen 2 & 12) - Brutalist 2.0
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "SHOP BY CATEGORY",
                        style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _activeGroceryCategory = "All"),
                        child: Text(
                          "SEE ALL",
                          style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 94,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _instamartCategories.length,
                    itemBuilder: (ctx, i) {
                      final cat = _instamartCategories[i];
                      final isSelected = _activeGroceryCategory == cat["name"];
                      return GestureDetector(
                        onTap: () => setState(() => _activeGroceryCategory = cat["name"]!),
                        child: Container(
                          width: 74,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.yellow : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  border: Border.all(
                                    color: AppTheme.black,
                                    width: isSelected ? 2.5 : 1.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.black,
                                      offset: isSelected ? const Offset(2.5, 2.5) : const Offset(1.5, 1.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(cat["icon"]!, style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat["label"]!.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                  color: isSelected ? AppTheme.black : subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 5. Specially for you (Trending Essentials - Standardized Component)
          if (_allGroceries.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Text(
                  "TRENDING ESSENTIALS",
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 275,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _allGroceries.take(8).length,
                  itemBuilder: (ctx, i) {
                    final g = _allGroceries[i];
                    return Container(
                      width: 165,
                      margin: const EdgeInsets.only(right: 12),
                      child: _buildInstamartProductCard(g, currentStore),
                    );
                  },
                ),
              ),
            ),
          ],

          // 6. Section Title & Items Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (_activeGroceryCategory == "All"
                            ? "ALL ESSENTIALS (${_filteredGroceries.length})"
                            : "$_activeGroceryCategory (${_filteredGroceries.length})")
                        .toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
                  ),
                ],
              ),
            ),
          ),

          // 7. Responsive Product Grid (Content-Driven Height, Zero Stretching)
          if (_filteredGroceries.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    "No grocery items found matching your criteria.",
                    style: GoogleFonts.inter(color: subtextColor),
                  ),
                ),
              ),
            )
          else
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                int crossAxisCount = 2;
                if (width >= 1200) {
                  crossAxisCount = 5;
                } else if (width >= 900) {
                  crossAxisCount = 4;
                } else if (width >= 600) {
                  crossAxisCount = 3;
                } else {
                  crossAxisCount = 2;
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 265, // Content-driven fixed card height! Never stretches vertically.
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final g = _filteredGroceries[i];
                        return _buildInstamartProductCard(g, currentStore);
                      },
                      childCount: _filteredGroceries.length,
                    ),
                  ),
                );
              },
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 130)),
        ],
      ),
    );
  }

  // Unified Standardized Instamart Product Card - Brutalism 2.0
  Widget _buildInstamartProductCard(GroceryItemModel g, DarkStoreModel store) {
    final weight = _parseWeight(g.itemName);
    final mrp = (g.price * 1.18).roundToDouble();
    final discountPercent = ((mrp - g.price) / mrp * 100).round();

    return AnimatedBuilder(
      animation: cartManager,
      builder: (context, _) {
        final currentQty = cartManager.getItemQuantity(g.itemName);

        return BrutalistCard(
          bgColor: AppTheme.surface,
          padding: EdgeInsets.zero,
          shadowOffset: const Offset(3, 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Product Image Section (Fixed, proportional height)
              Container(
                height: 112,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.bg,
                  border: Border(bottom: BorderSide(color: AppTheme.black, width: 2)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ItemImageWidget(
                          imageUrl: g.imageUrl,
                          itemName: g.itemName,
                          isGrocery: true,
                          width: 80,
                          height: 80,
                          borderRadius: 2,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.yellow,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: AppTheme.black, width: 1.5),
                        ),
                        child: Text(
                          "⚡ 10-MIN",
                          style: GoogleFonts.ibmPlexMono(
                            color: AppTheme.black,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    if (discountPercent > 0)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.green,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: AppTheme.black, width: 1.5),
                          ),
                          child: Text(
                            "$discountPercent% OFF",
                            style: GoogleFonts.ibmPlexMono(
                              color: AppTheme.black,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 2. Product Info & Pricing & Action Section
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quantity / Weight
                    Text(
                      weight.toUpperCase(),
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 9.5,
                        color: Colors.black54,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Product Title (2-line clamped with fixed 32px height)
                    SizedBox(
                      height: 32,
                      child: Text(
                        g.itemName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.black,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Pricing Section (Prominent current price + MRP strikethrough)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "₹${g.price.toStringAsFixed(0)}",
                          style: GoogleFonts.ibmPlexMono(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppTheme.black,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "₹${mrp.toStringAsFixed(0)}",
                          style: GoogleFonts.ibmPlexMono(
                            decoration: TextDecoration.lineThrough,
                            color: const Color(0xFF888888),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Action Stepper Button (Directly beneath pricing, consistent 32px height)
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: currentQty == 0
                          ? GestureDetector(
                              onTap: g.availableCount > 0
                                  ? () {
                                      _handleAddItem(
                                        itemName: g.itemName,
                                        price: g.price,
                                        isVeg: true,
                                        imageUrl: g.imageUrl,
                                        storeId: store.storeId,
                                        storeArea: store.dsArea,
                                        type: "Grocery",
                                      );
                                    }
                                  : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: g.availableCount > 0 ? AppTheme.yellow : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: AppTheme.black, width: 2),
                                  boxShadow: g.availableCount > 0
                                      ? const [
                                          BoxShadow(
                                            color: AppTheme.black,
                                            offset: Offset(2, 2),
                                            blurRadius: 0,
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  g.availableCount > 0 ? "ADD +" : "OUT OF STOCK",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: AppTheme.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: AppTheme.black,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: AppTheme.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppTheme.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () => cartManager.decrementItem(g.itemName),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      child: Text(
                                        "—",
                                        style: TextStyle(
                                          color: AppTheme.surface,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "$currentQty",
                                    style: GoogleFonts.ibmPlexMono(
                                      color: AppTheme.yellow,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _handleAddItem(
                                        itemName: g.itemName,
                                        price: g.price,
                                        isVeg: true,
                                        imageUrl: g.imageUrl,
                                        storeId: store.storeId,
                                        storeArea: store.dsArea,
                                        type: "Grocery",
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      child: Text(
                                        "+",
                                        style: TextStyle(
                                          color: AppTheme.yellow,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 3. MY ORDERS & TRACKING VIEW (SCREEN 8)
  // ===========================================================================
  Widget _buildOrdersView() {
    if (_orderFilter == "⭐ Most Ordered") {
      return _buildMostOrderedOrdersView();
    }

    // Filter orders according to _orderFilter
    final filtered = _myOrders.where((ord) {
      final st = ord.orderStatus.toLowerCase();
      if (_orderFilter == "Ongoing") {
        return st != "delivered" && st != "cancelled";
      } else if (_orderFilter == "Delivered") {
        return st == "delivered";
      } else if (_orderFilter == "Cancelled") {
        return st == "cancelled";
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Screen 8: Order Filter Pills (All, Ongoing, Delivered, Cancelled, ⭐ Most Ordered)
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ["All", "Ongoing", "Delivered", "Cancelled", "⭐ Most Ordered"].map((pill) {
                final isSel = _orderFilter == pill;
                return GestureDetector(
                  onTap: () => setState(() => _orderFilter = pill),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.yellow : AppTheme.surface,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppTheme.black, width: 2),
                      boxShadow: isSel ? const [BoxShadow(color: AppTheme.black, offset: Offset(2, 2))] : null,
                    ),
                    child: Center(
                      child: Text(
                        pill.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("📦", style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      _orderFilter == "All" ? "No orders placed yet." : "No $_orderFilter orders.",
                      style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.black),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yellow,
                        foregroundColor: AppTheme.black,
                        side: const BorderSide(color: AppTheme.black, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        elevation: 0,
                      ),
                      onPressed: () => setState(() => _selectedIndex = 0),
                      child: Text("ORDER DELICIOUS FOOD", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filtered.map((ord) {
              final isDelivered = ord.orderStatus.toLowerCase() == "delivered";
              final isCancelled = ord.orderStatus.toLowerCase() == "cancelled";
              final isPlaced = ord.orderStatus.toLowerCase() == "placed" || ord.orderStatus.toLowerCase() == "pending";
              final bannerPhoto = ItemImageHelper.getBannerForRestaurant(ord.restName ?? "Food");

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(3.5, 3.5), blurRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: Thumbnail + Details + Status Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: AppTheme.black, width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            bannerPhoto,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.yellow,
                              child: const Icon(Icons.fastfood, color: AppTheme.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      (ord.restName ?? (ord.orderType == "Restaurant" ? "Food Delivery" : "Instamart")).toUpperCase(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: AppTheme.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isCancelled
                                          ? AppTheme.red
                                          : isDelivered
                                              ? AppTheme.green
                                              : AppTheme.yellow,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                      border: Border.all(color: AppTheme.black, width: 1.5),
                                    ),
                                    child: Text(
                                      (isPlaced ? "Placed" : ord.orderStatus).toUpperCase(),
                                      style: GoogleFonts.ibmPlexMono(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ORDER #${ord.orderId} • ${ord.orderDate ?? '16 Oct 2026'}",
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 10.5,
                                  color: AppTheme.black.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${ord.totalAmount.toStringAsFixed(2)}",
                                style: GoogleFonts.ibmPlexMono(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.black,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Items • ${ord.deliveryAddr != null && ord.deliveryAddr!.contains('•') ? ord.deliveryAddr!.split('•').first.trim() : 'Home'}",
                                style: GoogleFonts.inter(
                                  color: AppTheme.black.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1.5, color: AppTheme.black),
                    const SizedBox(height: 12),
                    // Action Buttons Row (Screen 8)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isDelivered && !isCancelled) ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.black,
                              backgroundColor: AppTheme.surface,
                              side: const BorderSide(color: AppTheme.black, width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppTheme.bg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    side: const BorderSide(color: AppTheme.black, width: 2.5),
                                  ),
                                  title: Text("CANCEL ORDER?", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppTheme.black)),
                                  content: Text("Are you sure you want to cancel Order #${ord.orderId}?", style: GoogleFonts.inter(color: AppTheme.black)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text("KEEP ORDER", style: GoogleFonts.spaceGrotesk(color: AppTheme.black, fontWeight: FontWeight.bold)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.red,
                                        foregroundColor: AppTheme.black,
                                        side: const BorderSide(color: AppTheme.black, width: 2),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                                      ),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text("CANCEL ORDER", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  final ok = await ApiService.updateOrderStatus(ord.orderId, "Cancelled");
                                  if (mounted) {
                                    if (ok) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Order #${ord.orderId} cancelled."),
                                          backgroundColor: AppTheme.red,
                                        ),
                                      );
                                    }
                                  }
                                  await _loadData();
                                } catch (_) {}
                              }
                            },
                            child: Text("CANCEL", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.red)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.yellow,
                              foregroundColor: AppTheme.black,
                              side: const BorderSide(color: AppTheme.black, width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderTrackingScreen(
                                    orderId: ord.orderId,
                                    userData: widget.userData,
                                  ),
                                ),
                              );
                            },
                            child: Text("TRACK ORDER", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                        ] else ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.black,
                              backgroundColor: AppTheme.surface,
                              side: const BorderSide(color: AppTheme.black, width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                            ),
                            onPressed: () => setState(() => _selectedIndex = 0),
                            child: Text("REORDER", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.black,
                              foregroundColor: AppTheme.yellow,
                              side: const BorderSide(color: AppTheme.black, width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderTrackingScreen(
                                    orderId: ord.orderId,
                                    userData: widget.userData,
                                  ),
                                ),
                              );
                            },
                            child: Text("VIEW DETAILS", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 130),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3.1 MOST ORDERED DASHBOARD & RE-ORDER VIEW
  // ===========================================================================
  Widget _buildMostOrderedOrdersView() {
    final rawDishes = (_mostOrderedData['dishes'] as List? ?? []);
    final rawGroceries = (_mostOrderedData['groceries'] as List? ?? []);
    final rawRestaurants = (_mostOrderedData['restaurants'] as List? ?? []);

    final dishes = rawDishes;
    final groceries = rawGroceries;
    final restaurants = rawRestaurants;
    final bool hasAnyData = dishes.isNotEmpty || groceries.isNotEmpty || restaurants.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Pills Header (All, Ongoing, Delivered, Cancelled, ⭐ Most Ordered)
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ["All", "Ongoing", "Delivered", "Cancelled", "⭐ Most Ordered"].map((pill) {
                final isSel = _orderFilter == pill;
                return GestureDetector(
                  onTap: () => setState(() => _orderFilter = pill),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.yellow : AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.black, width: isSel ? 2.5 : 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.black,
                          offset: isSel ? const Offset(2.5, 2.5) : const Offset(1.5, 1.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        pill.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (!hasAnyData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
                        boxShadow: const [
                          BoxShadow(color: AppTheme.black, offset: Offset(4, 4), blurRadius: 0),
                        ],
                      ),
                      child: const Text("⭐", style: TextStyle(fontSize: 42)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "NO ORDER HISTORY YET",
                      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your most ordered dishes, groceries, and favourite restaurants will appear here once you place orders.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12.5, color: AppTheme.black.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yellow,
                        foregroundColor: AppTheme.black,
                        side: const BorderSide(color: AppTheme.black, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                      ),
                      onPressed: () => setState(() => _orderFilter = "All"),
                      child: Text("VIEW ALL ORDERS", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
          // Hero Highlights Card - Brutalist 2.0
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.yellow,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
              boxShadow: const [
                BoxShadow(color: AppTheme.black, offset: Offset(4, 4), blurRadius: 0),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.black,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Text("⭐", style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WHAT YOU ORDER MOST",
                            style: GoogleFonts.spaceGrotesk(color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Your personal favorites across food, groceries & restaurants",
                            style: GoogleFonts.inter(color: AppTheme.black.withValues(alpha: 0.8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Quick stats summary
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCol("DISHES", "${dishes.length}", "🍕"),
                      Container(width: 1.5, height: 24, color: AppTheme.black),
                      _statCol("GROCERIES", "${groceries.length}", "🥦"),
                      Container(width: 1.5, height: 24, color: AppTheme.black),
                      _statCol("STORES", "${restaurants.length}", "🏪"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sub-category selector tabs: All, Food Dishes, Groceries, Restaurants
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _mostOrderedSubTab("All", "🔥 All Top Picks"),
                _mostOrderedSubTab("Dishes", "🍔 Food Dishes (${dishes.length})"),
                _mostOrderedSubTab("Groceries", "🥦 Groceries (${groceries.length})"),
                _mostOrderedSubTab("Restaurants", "🏪 Restaurants (${restaurants.length})"),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. DISHES SECTION
          if (_mostOrderedSubCategory == "All" || _mostOrderedSubCategory == "Dishes") ...[
            _sectionHeader("Top Ordered Food Dishes", "Dishes you keep coming back to", "🍔"),
            const SizedBox(height: 10),
            if (dishes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No dish orders yet. Start exploring!", style: GoogleFonts.inter(color: AppTheme.black.withValues(alpha: 0.6)))),
              )
            else
              ...dishes.map((d) => _buildMostOrderedDishCard(d)),
            const SizedBox(height: 16),
          ],

          // 2. GROCERIES SECTION
          if (_mostOrderedSubCategory == "All" || _mostOrderedSubCategory == "Groceries") ...[
            _sectionHeader("Top Ordered Groceries", "Daily staples from 10-Min Dark Store", "🥦"),
            const SizedBox(height: 10),
            if (groceries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No grocery orders yet. Check Instamart!", style: GoogleFonts.inter(color: AppTheme.black.withValues(alpha: 0.6)))),
              )
            else
              ...groceries.map((g) => _buildMostOrderedGroceryCard(g)),
            const SizedBox(height: 16),
          ],

          // 3. RESTAURANTS SECTION
          if (_mostOrderedSubCategory == "All" || _mostOrderedSubCategory == "Restaurants") ...[
            _sectionHeader("Most Ordered Restaurants", "Your highest-visited dining partners", "🏪"),
            const SizedBox(height: 10),
            if (restaurants.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No restaurant orders recorded yet.", style: GoogleFonts.inter(color: AppTheme.black.withValues(alpha: 0.6)))),
              )
            else
              ...restaurants.map((r) => _buildMostOrderedRestaurantCard(r)),
            const SizedBox(height: 16),
          ],
          ],

          const SizedBox(height: 130),
        ],
      ),
    );
  }

  Widget _statCol(String label, String count, String emoji) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              count,
              style: GoogleFonts.ibmPlexMono(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(color: AppTheme.black.withValues(alpha: 0.7), fontSize: 9.5, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _mostOrderedSubTab(String key, String title) {
    final isSel = _mostOrderedSubCategory == key;
    return GestureDetector(
      onTap: () => setState(() => _mostOrderedSubCategory = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.yellow : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppTheme.black, width: isSel ? 2.5 : 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black,
              offset: isSel ? const Offset(2, 2) : const Offset(1, 1),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle, String icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.yellow,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.black, width: 1.5),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.black),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.black.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMostOrderedDishCard(dynamic d) {
    final name = (d['Item_Name'] ?? d['name'] ?? 'Delicious Dish').toString();
    final foodName = d['Food_Name']?.toString();
    final restName = (d['Rest_Name'] ?? 'Popular Restaurant').toString();
    final price = double.tryParse((d['Price'] ?? d['price'] ?? 199.0).toString()) ?? 199.0;
    final isVeg = d['Is_Veg'] == true || d['is_veg'] == true || d['Is_Veg'] == 1;
    final imgUrl = ItemImageHelper.resolveItemImage(
      d['Image_Url']?.toString(),
      name,
      category: foodName,
    );
    final count = d['Order_Count'] ?? d['order_count'] ?? 1;
    final restId = d['Rest_Id'] ?? d['rest_id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
        boxShadow: const [
          BoxShadow(color: AppTheme.black, offset: Offset(3.5, 3.5), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail with veg indicator badge
          Stack(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.yellow,
                    child: const Icon(Icons.fastfood, color: AppTheme.black),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: isVeg ? AppTheme.green : AppTheme.red, width: 1.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isVeg ? AppTheme.green : AppTheme.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Times ordered chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.black, width: 1.2),
                  ),
                  child: Text(
                    "🔥 ORDERED $count TIMES",
                    style: GoogleFonts.ibmPlexMono(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.black),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "from $restName",
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.black.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${price.toStringAsFixed(0)}",
                  style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.black),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Quick Reorder button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.yellow,
              foregroundColor: AppTheme.black,
              side: const BorderSide(color: AppTheme.black, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            ),
            onPressed: () {
              _handleAddItem(
                itemName: name,
                foodName: foodName,
                price: price,
                isVeg: isVeg,
                imageUrl: imgUrl,
                restId: restId is int ? restId : null,
                restName: restName,
                type: 'Restaurant',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Added '$name' to your basket"),
                  backgroundColor: AppTheme.green,
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "VIEW CART",
                    textColor: AppTheme.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartCheckoutScreen(userData: widget.userData)),
                      );
                    },
                  ),
                ),
              );
            },
            child: Text("REORDER", style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildMostOrderedGroceryCard(dynamic g) {
    final name = (g['Item_Name'] ?? g['name'] ?? 'Grocery Item').toString();
    final storeArea = (g['Store_Area'] ?? 'Indiranagar Hub').toString();
    final price = double.tryParse((g['Price'] ?? g['price'] ?? 45.0).toString()) ?? 45.0;
    final imgUrl = ItemImageHelper.resolveItemImage(
      g['Image_Url']?.toString(),
      name,
      isGrocery: true,
    );
    final count = g['Order_Count'] ?? g['order_count'] ?? 1;
    final storeId = g['Store_Id'] ?? g['store_id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
        boxShadow: const [
          BoxShadow(color: AppTheme.black, offset: Offset(3.5, 3.5), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.black, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              imgUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppTheme.yellow,
                child: const Icon(Icons.bolt, color: AppTheme.black),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.black, width: 1.2),
                  ),
                  child: Text(
                    "⚡ ORDERED $count TIMES",
                    style: GoogleFonts.ibmPlexMono(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.black),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "10-min Dark Store • $storeArea",
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.black.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${price.toStringAsFixed(0)}",
                  style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.black),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.yellow,
              foregroundColor: AppTheme.black,
              side: const BorderSide(color: AppTheme.black, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            ),
            onPressed: () {
              _handleAddItem(
                itemName: name,
                price: price,
                isVeg: true,
                imageUrl: imgUrl,
                storeId: storeId is int ? storeId : _selectedDarkStoreId,
                storeArea: storeArea,
                type: 'Grocery',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Added '$name' to your basket"),
                  backgroundColor: AppTheme.green,
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "VIEW CART",
                    textColor: AppTheme.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartCheckoutScreen(userData: widget.userData)),
                      );
                    },
                  ),
                ),
              );
            },
            child: Text("ADD +", style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildMostOrderedRestaurantCard(dynamic r) {
    final name = (r['Rest_Name'] ?? r['name'] ?? 'Restaurant').toString();
    final location = (r['Rest_Location'] ?? 'Indiranagar').toString();
    final rating = double.tryParse((r['Rest_Rating'] ?? r['rating'] ?? 4.5).toString()) ?? 4.5;
    final orderCount = r['Order_Count'] ?? r['order_count'] ?? 1;
    final totalSpent = double.tryParse((r['Total_Spent'] ?? r['total_spent'] ?? 0.0).toString()) ?? 0.0;
    final restId = r['Rest_Id'] ?? r['rest_id'] ?? 1;
    final banner = (r['Banner_Url'] != null && r['Banner_Url'].toString().isNotEmpty)
        ? r['Banner_Url'].toString()
        : (r['Image_Url'] != null && r['Image_Url'].toString().isNotEmpty)
            ? r['Image_Url'].toString()
            : ItemImageHelper.getBannerForRestaurant(
                name,
                restId: restId is int ? restId : int.tryParse(restId.toString()),
              );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
        boxShadow: const [
          BoxShadow(color: AppTheme.black, offset: Offset(3.5, 3.5), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image with stats badge overlay
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.black, width: 2)),
                ),
                child: AppCachedNetworkImage(
                  imageUrl: banner,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    height: 120,
                    width: double.infinity,
                    color: AppTheme.yellow,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black),
                      ),
                    ),
                  ),
                  errorWidget: Container(
                    height: 120,
                    width: double.infinity,
                    color: AppTheme.yellow,
                    child: const Center(child: Icon(Icons.restaurant, color: AppTheme.black, size: 36)),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("⭐ ", style: TextStyle(fontSize: 10)),
                      Text(
                        "$orderCount ORDERS PLACED",
                        style: GoogleFonts.ibmPlexMono(color: AppTheme.yellow, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppTheme.black, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.ibmPlexMono(color: AppTheme.black, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$location • SPENT: ₹${totalSpent.toStringAsFixed(0)}",
                        style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppTheme.black.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: AppTheme.yellow,
                    side: const BorderSide(color: AppTheme.black, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                  ),
                  onPressed: () {
                    final match = _restaurants.firstWhere(
                      (rObj) => rObj.restId == restId,
                      orElse: () => RestaurantModel(
                        restId: restId is int ? restId : 1,
                        rName: name,
                        rLocation: location,
                        rRating: rating,
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailScreen(
                          restaurant: match,
                          userData: widget.userData,
                        ),
                      ),
                    );
                  },
                  child: Text("VIEW MENU", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


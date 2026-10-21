import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/cart_manager.dart';
import '../../utils/item_image_helper.dart';
import '../../widgets/floating_cart_bar.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  final Map<String, dynamic> userData;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    required this.userData,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  List<RestaurantItemModel> _menuItems = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedCategory = "Popular";
  bool _showSearchField = false;

  final List<String> _categories = ["Popular", "Biryani", "Starters", "Main Course"];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getRestaurantMenu(widget.restaurant.restId);
      if (mounted) {
        setState(() {
          _menuItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<RestaurantItemModel> get _filteredDishes {
    return _menuItems.where((dish) {
      if (_searchQuery.isNotEmpty) {
        final matches = dish.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (dish.foodName ?? "").toLowerCase().contains(_searchQuery.toLowerCase());
        if (!matches) return false;
      }

      if (_selectedCategory == "Popular") return true;
      final cat = _selectedCategory.toLowerCase();
      final name = dish.itemName.toLowerCase();
      final food = (dish.foodName ?? "").toLowerCase();
      return name.contains(cat) || food.contains(cat);
    }).toList();
  }

  void _handleAddItem(RestaurantItemModel dish) {
    if (!cartManager.canAddFrom(
      restId: widget.restaurant.restId,
      restName: widget.restaurant.rName,
      type: "Restaurant",
    )) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Replace cart items?"),
          content: Text(
            "Your cart already has items from ${cartManager.activeRestName ?? 'another vendor'}. Would you like to clear it and start fresh with ${widget.restaurant.rName}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                cartManager.clear();
                cartManager.addItem(
                  itemName: dish.itemName,
                  foodName: dish.foodName,
                  price: dish.finalPrice,
                  isVeg: dish.isVeg,
                  imageUrl: dish.imageUrl,
                  restId: widget.restaurant.restId,
                  restName: widget.restaurant.rName,
                  type: "Restaurant",
                );
                Navigator.pop(ctx);
              },
              child: const Text("Discard & Add"),
            ),
          ],
        ),
      );
    } else {
      cartManager.addItem(
        itemName: dish.itemName,
        foodName: dish.foodName,
        price: dish.finalPrice,
        isVeg: dish.isVeg,
        imageUrl: dish.imageUrl,
        restId: widget.restaurant.restId,
        restName: widget.restaurant.rName,
        type: "Restaurant",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final eta = "${25 + (r.restId % 3) * 5}-${35 + (r.restId % 3) * 5} mins";
    final dist = "${(1.8 + (r.restId % 3) * 0.4).toStringAsFixed(1)} km";
    final costForTwo = "₹${350 + (r.restId % 4) * 50} for two";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          r.rName,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF0F172A)),
            tooltip: "Favorite",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Added to favorites!"), duration: Duration(seconds: 1)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF0F172A)),
            tooltip: "Search dishes",
            onPressed: () => setState(() => _showSearchField = !_showSearchField),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // Search bar when toggled
                    if (_showSearchField)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: TextField(
                            autofocus: true,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: "Search in ${r.rName}...",
                              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => setState(() {
                                  _showSearchField = false;
                                  _searchQuery = "";
                                }),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                          ),
                        ),
                      ),

                    // Restaurant Header Card (Screen 4)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.rName,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          r.rLocation,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Yellow rating pill: ★ 5.0 (2.1k) (Screen 4)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                                        const SizedBox(width: 3),
                                        Text(
                                          "${r.rRating.toStringAsFixed(1)} (2.1k)",
                                          style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _metaItem(Icons.timer_outlined, eta, "Delivery"),
                                  const SizedBox(width: 16),
                                  _metaItem(Icons.location_on_outlined, dist, "Distance"),
                                  const SizedBox(width: 16),
                                  _metaItem(Icons.payments_outlined, costForTwo, "Cost for two"),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Promo offer banner (Screen 4)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: const Row(
                                  children: [
                                    Text("🎉", style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Flat 20% OFF on all items",
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                          ),
                                          Text(
                                            "Use code FEAST20 at checkout",
                                            style: TextStyle(fontSize: 10.5, color: Color(0xFFB45309)),
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
                      ),
                    ),

                    // Category Pills Row (Popular, Biryani, Starters, Main Course - Screen 4)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 36,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _categories.map((cat) {
                                  final isSel = _selectedCategory == cat;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedCategory = cat),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSel ? const Color(0xFF4F46E5) : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: isSel ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSel ? Colors.white : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Section Title
                            Text(
                              "$_selectedCategory Items",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    // Menu Items List (Screen 4)
                    if (_filteredDishes.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text("No dishes match your filter.", style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                              final dish = _filteredDishes[i];
                              return _buildDishCard(dish);
                            },
                            childCount: _filteredDishes.length,
                          ),
                        ),
                      ),

                    // Spacing for floating cart bar
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),

          // Floating Cart Bar at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingCartBar(userData: widget.userData),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }

  // Dish Card with Overlaid ADD Stepper on Right Image (Screen 4)
  Widget _buildDishCard(RestaurantItemModel dish) {
    return AnimatedBuilder(
      animation: cartManager,
      builder: (context, _) {
        final currentQty = cartManager.getItemQuantity(dish.itemName);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dish Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Veg / Non-Veg Indicator
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            border: Border.all(color: dish.isVeg ? const Color(0xFF16A34A) : const Color(0xFFDC2626), width: 1.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: dish.isVeg ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dish.isVeg ? "VEG" : "NON-VEG",
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: dish.isVeg ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.itemName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    if (dish.foodName != null && dish.foodName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          dish.foodName!,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "₹${dish.finalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        if (dish.discount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            "₹${dish.basePrice.toStringAsFixed(2)}",
                            style: const TextStyle(decoration: TextDecoration.lineThrough, color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${dish.discount.toStringAsFixed(0)}% OFF",
                            style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Dish Image with Overlaid ADD Button at bottom (Screen 4)
              SizedBox(
                width: 95,
                height: 105,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ItemImageWidget(
                        imageUrl: dish.imageUrl,
                        itemName: dish.itemName,
                        category: dish.foodName,
                        width: 95,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Overlaid ADD / Stepper button at bottom edge
                    Positioned(
                      bottom: 0,
                      child: currentQty == 0
                          ? Container(
                              height: 30,
                              width: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF16A34A), width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: InkWell(
                                onTap: () => _handleAddItem(dish),
                                borderRadius: BorderRadius.circular(8),
                                child: const Center(
                                  child: Text(
                                    "ADD",
                                    style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF16A34A), fontSize: 12),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 30,
                              width: 76,
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF16A34A).withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: () => cartManager.decrementItem(dish.itemName),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      child: Text("—", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ),
                                  Text(
                                    "$currentQty",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  InkWell(
                                    onTap: () => _handleAddItem(dish),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      child: Text("+", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
}

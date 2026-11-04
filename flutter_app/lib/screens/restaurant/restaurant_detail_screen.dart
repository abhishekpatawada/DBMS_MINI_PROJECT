import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/cart_manager.dart';
import '../../utils/item_image_helper.dart';
import '../../widgets/floating_cart_bar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';

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

  final List<String> _categories = [
    "Popular",
    "Biryani",
    "Starters",
    "Main Course"
  ];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      final items =
          await ApiService.getRestaurantMenu(widget.restaurant.restId);
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
        final matches = dish.itemName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (dish.foodName ?? "")
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
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
          backgroundColor: AppTheme.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            side: const BorderSide(color: AppTheme.black, width: 3),
          ),
          title: Text(
            "REPLACE CART ITEMS?",
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900,
              color: AppTheme.black,
            ),
          ),
          content: Text(
            "Your cart already has items from ${cartManager.activeRestName ?? 'another vendor'}. Clear it and start fresh with ${widget.restaurant.rName}?",
            style: GoogleFonts.inter(fontSize: 13),
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
              text: "DISCARD & ADD",
              height: 38,
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
    final eta = "${25 + (r.restId % 3) * 5}-${35 + (r.restId % 3) * 5} MINS";
    final dist = "${(1.8 + (r.restId % 3) * 0.4).toStringAsFixed(1)} KM";
    final costForTwo = "₹${350 + (r.restId % 4) * 50} FOR TWO";

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          r.rName.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppTheme.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded,
                color: AppTheme.black),
            tooltip: "Favorite",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "ADDED TO FAVORITES ★",
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.black,
                    ),
                  ),
                  backgroundColor: AppTheme.yellow,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppTheme.black),
            tooltip: "Search dishes",
            onPressed: () =>
                setState(() => _showSearchField = !_showSearchField),
          ),
          const SizedBox(width: 6),
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
              : CustomScrollView(
                  slivers: [
                    // Search bar when toggled
                    if (_showSearchField)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: TextField(
                            autofocus: true,
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            style: GoogleFonts.ibmPlexMono(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Search in ${r.rName}...",
                              prefixIcon: const Icon(Icons.search_rounded,
                                  size: 20, color: AppTheme.black),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: AppTheme.black),
                                onPressed: () => setState(() {
                                  _showSearchField = false;
                                  _searchQuery = "";
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Restaurant Header Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BrutalistCard(
                          bgColor: AppTheme.surface,
                          padding: EdgeInsets.zero,
                          shadowOffset: const Offset(4, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Restaurant Banner
                              Container(
                                height: 140,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppTheme.black,
                                      width: AppTheme.borderWidth,
                                    ),
                                  ),
                                ),
                                child: AppCachedNetworkImage(
                                  imageUrl: ItemImageHelper.getBannerForRestaurant(
                                    r.rName,
                                    restId: r.restId,
                                    imageUrl: r.imageUrl,
                                  ),
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: Container(
                                    color: AppTheme.yellow,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppTheme.black,
                                      ),
                                    ),
                                  ),
                                  errorWidget: Container(
                                    color: AppTheme.bg,
                                    child: const Center(
                                      child: Icon(Icons.restaurant,
                                          color: AppTheme.black, size: 36),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                r.rName.toUpperCase(),
                                                style:
                                                    GoogleFonts.spaceGrotesk(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppTheme.black,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                r.rLocation.toUpperCase(),
                                                style:
                                                    GoogleFonts.ibmPlexMono(
                                                  fontSize: 11,
                                                  color:
                                                      const Color(0xFF666666),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Rating badge
                                        BrutalistBadge(
                                          label:
                                              "★ ${r.rRating.toStringAsFixed(1)} (2.1K)",
                                          bgColor: AppTheme.yellow,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                        height: 2.0, color: AppTheme.black),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _metaItem(Icons.timer_outlined, eta,
                                            "DELIVERY"),
                                        const SizedBox(width: 14),
                                        _metaItem(
                                            Icons.location_on_outlined,
                                            dist,
                                            "DISTANCE"),
                                        const SizedBox(width: 14),
                                        _metaItem(Icons.payments_outlined,
                                            costForTwo, "COST FOR TWO"),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // Promo Offer Banner
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.yellow,
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.borderRadius),
                                        border: Border.all(
                                            color: AppTheme.black, width: 2),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text("⚡",
                                              style: TextStyle(fontSize: 16)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "FLAT 20% OFF ON ALL ITEMS",
                                                  style:
                                                      GoogleFonts.spaceGrotesk(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w900,
                                                    color: AppTheme.black,
                                                  ),
                                                ),
                                                Text(
                                                  "USE COUPON: FEAST20 AT CHECKOUT",
                                                  style:
                                                      GoogleFonts.ibmPlexMono(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    color:
                                                        const Color(0xFF444444),
                                                  ),
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
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Category Pills Row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 38,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _categories.map((cat) {
                                  final isSel = _selectedCategory == cat;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedCategory = cat),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSel
                                            ? AppTheme.yellow
                                            : AppTheme.surface,
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.borderRadius),
                                        border: Border.all(
                                          color: AppTheme.black,
                                          width: isSel
                                              ? 2.5
                                              : AppTheme.borderWidth,
                                        ),
                                        boxShadow: isSel
                                            ? const [
                                                BoxShadow(
                                                  color: AppTheme.black,
                                                  offset: Offset(2.5, 2.5),
                                                  blurRadius: 0,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          cat.toUpperCase(),
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.black,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 18),
                            BrutalistSectionHeader(
                              title: "$_selectedCategory Menu",
                              tag: "${_filteredDishes.length} DISHES",
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // Menu Items List
                    if (_filteredDishes.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            "NO DISHES MATCH YOUR FILTER.",
                            style: GoogleFonts.ibmPlexMono(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF666666),
                            ),
                          ),
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

                    const SliverToBoxAdapter(child: SizedBox(height: 130)),
                  ],
                ),

          // Floating Cart Bar
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
        Icon(icon, size: 14, color: AppTheme.black),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.black,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Dish Card with Overlaid ADD Stepper on Right Image
  Widget _buildDishCard(RestaurantItemModel dish) {
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
                            color: dish.isVeg
                                ? AppTheme.green
                                : AppTheme.red,
                            border: Border.all(
                                color: AppTheme.black, width: 1.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dish.isVeg ? "VEG" : "NON-VEG",
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.itemName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                      ),
                    ),
                    if (dish.foodName != null && dish.foodName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          dish.foodName!,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "₹${dish.finalPrice.toStringAsFixed(2)}",
                          style: GoogleFonts.ibmPlexMono(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppTheme.black,
                          ),
                        ),
                        if (dish.discount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            "₹${dish.basePrice.toStringAsFixed(2)}",
                            style: GoogleFonts.ibmPlexMono(
                              decoration: TextDecoration.lineThrough,
                              color: const Color(0xFF888888),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.yellow,
                              border: Border.all(
                                  color: AppTheme.black, width: 1),
                            ),
                            child: Text(
                              "${dish.discount.toStringAsFixed(0)}% OFF",
                              style: GoogleFonts.ibmPlexMono(
                                color: AppTheme.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Dish Image with Overlaid Stepper
              SizedBox(
                width: 95,
                height: 105,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ItemImageWidget(
                      imageUrl: dish.imageUrl,
                      itemName: dish.itemName,
                      category: dish.foodName,
                      width: 95,
                      height: 85,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      child: currentQty == 0
                          ? GestureDetector(
                              onTap: () => _handleAddItem(dish),
                              child: Container(
                                height: 28,
                                width: 72,
                                decoration: BoxDecoration(
                                  color: AppTheme.yellow,
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadius),
                                  border: Border.all(
                                      color: AppTheme.black, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppTheme.black,
                                      offset: Offset(1.5, 1.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "ADD +",
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.black,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 28,
                              width: 76,
                              decoration: BoxDecoration(
                                color: AppTheme.black,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadius),
                                border: Border.all(
                                    color: AppTheme.black, width: 2),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: () => cartManager
                                        .decrementItem(dish.itemName),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      child: Text(
                                        "—",
                                        style: TextStyle(
                                            color: AppTheme.surface,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "$currentQty",
                                    style: GoogleFonts.ibmPlexMono(
                                      color: AppTheme.yellow,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _handleAddItem(dish),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      child: Text(
                                        "+",
                                        style: TextStyle(
                                            color: AppTheme.yellow,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13),
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
}

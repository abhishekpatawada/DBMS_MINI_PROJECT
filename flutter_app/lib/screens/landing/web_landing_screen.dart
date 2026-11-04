import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../auth_screen.dart';

class WebLandingScreen extends StatefulWidget {
  const WebLandingScreen({super.key});

  @override
  State<WebLandingScreen> createState() => _WebLandingScreenState();
}

class _WebLandingScreenState extends State<WebLandingScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _courierController;
  late Animation<double> _courierProgress;
  late Animation<double> _radarRipple;
  late AnimationController _roadDashController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Section anchor keys for precision navigation
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _speedKey = GlobalKey();
  final GlobalKey _ecosystemKey = GlobalKey();
  final GlobalKey _whyKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  // Interactive states
  int _selectedCategoryIndex = 0;
  double _simulatedDistance = 3.5;
  int _selectedTransportMode = 0; // 0: Hyper Bike, 1: Drone, 2: Eco Rider
  int _cartItemCount = 0;
  int _expandedFaqIndex = -1;
  final TextEditingController _pincodeController = TextEditingController();
  String? _speedCheckResult;

  final List<String> _categories = [
    "🔥 Trending Bites",
    "⭐ Most Ordered",
    "🍕 Gourmet Dining",
    "🥦 10-Min Dark Store",
    "🍣 Sushi & Asian",
    "🍰 Desserts",
  ];

  final List<Map<String, dynamic>> _foodItems = [
    {
      "name": "Smoked Truffle Wagyu Burger",
      "category": 0,
      "isMostOrdered": true,
      "tag": "🔥 #1 Most Ordered (8.4k)",
      "rating": 4.95,
      "price": 249.00,
      "time": "12 mins",
      "image":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80",
      "emoji": "🍔",
      "bg": Color(0xFFFFF1F2),
      "desc":
          "Double grilled Wagyu beef, aged gouda, black truffle aioli, toasted brioche.",
    },
    {
      "name": "Hyderabadi Royal Dum Biryani",
      "category": 2,
      "isMostOrdered": true,
      "tag": "⭐ 12.1k Orders",
      "rating": 4.97,
      "price": 280.00,
      "time": "15 mins",
      "image":
          "https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600&auto=format&fit=crop&q=80",
      "emoji": "🍛",
      "bg": Color(0xFFFEF3C7),
      "desc":
          "Slow-cooked saffron basmati, tender marinated spices, served with cooling salan & raita.",
    },
    {
      "name": "Artisanal Burrata Margherita",
      "category": 2,
      "isMostOrdered": true,
      "tag": "Wood-Fired Favorite",
      "rating": 4.92,
      "price": 299.00,
      "time": "14 mins",
      "image":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&auto=format&fit=crop&q=80",
      "emoji": "🍕",
      "bg": Color(0xFFFFF7ED),
      "desc":
          "San Marzano tomatoes, fresh cream burrata, fresh basil, extra virgin olive oil.",
    },
    {
      "name": "Organic Hass Avocados & Berry Box",
      "category": 3,
      "isMostOrdered": true,
      "tag": "🥦 Top Grocery Pick (14k)",
      "rating": 4.98,
      "price": 149.00,
      "time": "8 mins",
      "image":
          "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=600&auto=format&fit=crop&q=80",
      "emoji": "🥑",
      "bg": Color(0xFFECFDF5),
      "desc":
          "Freshly harvested Hass avocados, wild blueberries, and chilled Greek yogurt.",
    },
    {
      "name": "Farm Fresh Milk & Country Eggs Pack",
      "category": 3,
      "isMostOrdered": true,
      "tag": "🥛 Daily Essential (19k)",
      "rating": 4.94,
      "price": 95.00,
      "time": "7 mins",
      "image":
          "https://images.unsplash.com/photo-1528750997573-59b89d56f4f7?w=600&auto=format&fit=crop&q=80",
      "emoji": "🥛",
      "bg": Color(0xFFF0FDF4),
      "desc":
          "Pasteurized pure whole milk pouch (1L) paired with farm-fresh organic brown eggs.",
    },
    {
      "name": "Dragon Flame Salmon Roll",
      "category": 4,
      "isMostOrdered": false,
      "tag": "Top Asian Dining",
      "rating": 4.96,
      "price": 320.00,
      "time": "15 mins",
      "image":
          "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600&auto=format&fit=crop&q=80",
      "emoji": "🍣",
      "bg": Color(0xFFEFF6FF),
      "desc":
          "Torched Atlantic salmon, tempura shrimp, avocado, tobiko, unagi glaze.",
    },
    {
      "name": "Molten Belgian Lava Cake & Gelato",
      "category": 5,
      "isMostOrdered": true,
      "tag": "Sweet Indulgence (6.2k)",
      "rating": 4.99,
      "price": 180.00,
      "time": "10 mins",
      "image":
          "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=600&auto=format&fit=crop&q=80",
      "emoji": "🍫",
      "bg": Color(0xFFFAF5FF),
      "desc":
          "Warm 70% dark Belgian chocolate center paired with Madagascar vanilla gelato.",
    },
    {
      "name": "Farm Fresh Hydroponic Bowl",
      "category": 0,
      "isMostOrdered": false,
      "tag": "Clean Eating",
      "rating": 4.88,
      "price": 199.00,
      "time": "9 mins",
      "image":
          "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&auto=format&fit=crop&q=80",
      "emoji": "🥗",
      "bg": Color(0xFFF0FDF4),
      "desc":
          "Crisp romaine, quinoa, cherry tomatoes, kalamata olives, tahini lemon dressing.",
    },
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _courierController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _courierProgress = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _courierController, curve: Curves.easeInOut),
    );
    _radarRipple = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _courierController, curve: Curves.easeOut),
    );

    _roadDashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _courierController.dispose();
    _roadDashController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _navigateToAuth({String? role}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim, secAnim) => AuthScreen(selectedRole: role),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.08,
      );
    }
  }

  void _scrollToSection(double offset) {
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _checkDeliverySpeed() {
    final code = _pincodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a pincode or delivery area!"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _speedCheckResult =
          "⚡ Lightning Hub Active in $code: Dispatch in 9-11 mins!";
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Scrollable Landing Page Body
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 76), // Navbar clearance
                _buildHeroSection(isMobile),
                const SizedBox(height: 48),
                _buildStatsRibbon(isMobile),
                const SizedBox(height: 80),
                Container(key: _menuKey, child: _buildInteractiveCategories(isMobile)),
                const SizedBox(height: 80),
                Container(key: _speedKey, child: _buildSpeedSimulator(isMobile)),
                const SizedBox(height: 80),
                Container(key: _ecosystemKey, child: _buildEcosystemSection(isMobile)),
                const SizedBox(height: 80),
                Container(key: _whyKey, child: _buildBentoFeatures(isMobile)),
                const SizedBox(height: 80),
                Container(key: _reviewsKey, child: _buildReviewsSection(isMobile)),
                const SizedBox(height: 80),
                Container(key: _faqKey, child: _buildFaqSection(isMobile)),
                const SizedBox(height: 80),
                _buildCtaBanner(isMobile),
                _buildFooter(isMobile),
              ],
            ),
          ),

          // Clean Top Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildNavigationBar(isMobile),
          ),

          // Floating Cart Order Pill
          if (_cartItemCount > 0)
            Positioned(
              bottom: 24,
              right: 24,
              child: _buildFloatingCartPill(),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. NAVIGATION BAR - Brutalism 2.0
  // -------------------------------------------------------------
  Widget _buildNavigationBar(bool isMobile) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 48),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(
          bottom: BorderSide(color: AppTheme.black, width: 2.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Brand
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _scrollToSection(0),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.yellow,
                          offset: Offset(2.5, 2.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "B",
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.yellow,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: TextSpan(
                      text: "BITE",
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      children: const [
                        TextSpan(
                          text: "HUB",
                          style: TextStyle(
                            color: AppTheme.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.black, width: 1.5),
                    ),
                    child: Text(
                      "⚡ COMMERCE 2.0",
                      style: GoogleFonts.ibmPlexMono(
                        color: AppTheme.black,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nav links for desktop
          if (!isMobile)
            Row(
              children: [
                _navLinkItem("LIVE MENU", _menuKey),
                _navLinkItem("SPEED TEST", _speedKey),
                _navLinkItem("ECOSYSTEM", _ecosystemKey),
                _navLinkItem("WHY US", _whyKey),
                _navLinkItem("REVIEWS", _reviewsKey),
              ],
            ),

          // Action CTAs
          Row(
            children: [
              if (!isMobile)
                TextButton(
                  onPressed: () => _navigateToAuth(role: "Restaurant"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    "PARTNER LOGIN",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _navigateToAuth(),
                icon: const Icon(Icons.bolt, size: 18),
                label: Text(
                  isMobile ? "LAUNCH" : "LAUNCH APP",
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellow,
                  foregroundColor: AppTheme.black,
                  elevation: 0,
                  side: const BorderSide(color: AppTheme.black, width: 2),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navLinkItem(String title, GlobalKey key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _scrollToKey(key),
          child: Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. HERO SECTION - Brutalism 2.0
  // -------------------------------------------------------------
  Widget _buildHeroSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: isMobile
              ? Column(
                  children: [
                    _buildHeroText(isMobile),
                    const SizedBox(height: 36),
                    _buildHeroMockup(isMobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 11, child: _buildHeroText(isMobile)),
                    const SizedBox(width: 48),
                    Expanded(flex: 9, child: _buildHeroMockup(isMobile)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroText(bool isMobile) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Brutalist announcement badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.yellow,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.black, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: AppTheme.black,
                  offset: Offset(2.5, 2.5),
                  blurRadius: 0),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("⚡", style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                "FASTEST 10-MINUTE QUICK-COMMERCE & FOOD",
                style: GoogleFonts.ibmPlexMono(
                  color: AppTheme.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Main Title
        Text(
          "YOUR CRAVINGS,\nOUR COMMAND.",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.spaceGrotesk(
            fontSize: isMobile ? 42 : 62,
            fontWeight: FontWeight.w900,
            height: 1.05,
            color: AppTheme.black,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.black,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Text(
            "10-MINUTE DARK STORE & GOURMET DINING",
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: GoogleFonts.spaceGrotesk(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.yellow,
            ),
          ),
        ),
        const SizedBox(height: 18),

        Text(
          "Order chef-curated restaurant dishes or instant dark-store groceries in seconds. Powered by smart multi-role dispatch and sub-12-minute electric courier delivery.",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 15 : 16.5,
            color: AppTheme.black.withValues(alpha: 0.8),
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),

        // Brutalist Pincode Checker
        Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border:
                Border.all(color: AppTheme.black, width: AppTheme.borderWidth),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.black,
                offset: Offset(3.5, 3.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.location_on_rounded,
                    color: AppTheme.black, size: 22),
              ),
              Expanded(
                child: TextField(
                  controller: _pincodeController,
                  style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: "ENTER PINCODE OR AREA...",
                    hintStyle: GoogleFonts.spaceGrotesk(
                        color: AppTheme.black.withValues(alpha: 0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => _checkDeliverySpeed(),
                ),
              ),
              ElevatedButton(
                onPressed: _checkDeliverySpeed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellow,
                  foregroundColor: AppTheme.black,
                  elevation: 0,
                  side: const BorderSide(color: AppTheme.black, width: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
                child: Text(
                  "CHECK SPEED",
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_speedCheckResult != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.yellow,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.black, width: 2),
              boxShadow: const [
                BoxShadow(
                    color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
              ],
            ),
            child: Text(
              _speedCheckResult!,
              style: GoogleFonts.ibmPlexMono(
                color: AppTheme.black,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],

        const SizedBox(height: 30),

        // CTA Buttons
        Wrap(
          spacing: 14,
          runSpacing: 12,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToAuth(role: "User"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.yellow,
                foregroundColor: AppTheme.black,
                elevation: 0,
                side: const BorderSide(color: AppTheme.black, width: 2.5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ORDER FOOD & MART",
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: AppTheme.black),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _scrollToKey(_menuKey),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.black,
                side: const BorderSide(color: AppTheme.black, width: 2.5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: Text(
                "EXPLORE LIVE MENU",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Rating Strip
        Row(
          mainAxisAlignment:
              isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (i) => const Icon(
                  Icons.star_rounded,
                  color: AppTheme.accentColor,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "4.95/5 Rating • 150,000+ orders this month",
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Hero Mockup with Kinetic Brutalist Levitation & Interactive Radar (Brutalism 2.0)
  Widget _buildHeroMockup(bool isMobile) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatAnimation,
        _courierController,
        _roadDashController,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(0.0, _floatAnimation.value)
            ..rotateZ(isMobile ? 0.0 : -0.012),
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. MAIN RADAR CHASSIS
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.black, width: 3.0),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: Column(
                children: [
                  // Window Header with Terminal Window Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    color: AppTheme.black,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.red,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: AppTheme.black, width: 1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.yellow,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: AppTheme.black, width: 1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.green,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: AppTheme.black, width: 1),
                          ),
                        ),
                        const Spacer(),
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppTheme.yellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "RADAR TELEMETRY // 5.8GHZ [ACTIVE]",
                          style: GoogleFonts.ibmPlexMono(
                            color: AppTheme.yellow,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Panel
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Live Dispatch Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: AppTheme.black, width: 2),
                            boxShadow: const [
                              BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
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
                                      color: AppTheme.yellow,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                      border: Border.all(color: AppTheme.black, width: 1.5),
                                    ),
                                    child: const Icon(
                                      Icons.electric_bike_rounded,
                                      color: AppTheme.black,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "COURIER ALEX (#A-402)",
                                          style: GoogleFonts.spaceGrotesk(
                                            color: AppTheme.black,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          "0.4 km away • 54 km/h EV Express",
                                          style: GoogleFonts.ibmPlexMono(
                                            color: AppTheme.black.withValues(alpha: 0.7),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.yellow,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                      border: Border.all(color: AppTheme.black, width: 1.5),
                                    ),
                                    child: Text(
                                      "⚡ ETA 4 MINS",
                                      style: GoogleFonts.ibmPlexMono(
                                        color: AppTheme.black,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Kinetic Animated Road Surface & Courier
                              Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppTheme.black,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  border: Border.all(color: AppTheme.black, width: 2),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    // Animated moving road lane dashes
                                    AnimatedBuilder(
                                      animation: _roadDashController,
                                      builder: (context, _) {
                                        return Positioned.fill(
                                          child: ClipRect(
                                            child: Transform.translate(
                                              offset: Offset(-_roadDashController.value * 28, 0),
                                              child: OverflowBox(
                                                minWidth: 0.0,
                                                maxWidth: double.infinity,
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: List.generate(
                                                    24,
                                                    (idx) => Container(
                                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                                      width: 16,
                                                      height: 3,
                                                      color: AppTheme.yellow.withValues(alpha: 0.4),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    // Kinetic moving courier pin with sonar radar pulses
                                    AnimatedBuilder(
                                      animation: _courierController,
                                      builder: (context, _) {
                                        final barWidth = isMobile ? 220.0 : 270.0;
                                        return Positioned(
                                          left: barWidth * _courierProgress.value,
                                          top: -8,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Sonar expanding ripple
                                              Container(
                                                width: 32 * (0.8 + _radarRipple.value * 0.8),
                                                height: 32 * (0.8 + _radarRipple.value * 0.8),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppTheme.yellow.withValues(
                                                      alpha: (1.0 - _radarRipple.value).clamp(0.0, 1.0),
                                                    ),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              // Courier Pin
                                              Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.yellow,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: AppTheme.black, width: 2),
                                                  boxShadow: const [
                                                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                                                  ],
                                                ),
                                                child: const Text("🛵", style: TextStyle(fontSize: 16)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "[HUB DISPATCH]",
                                    style: GoogleFonts.ibmPlexMono(
                                      color: AppTheme.black.withValues(alpha: 0.7),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    "⚡ RAPID COURIER EN ROUTE",
                                    style: GoogleFonts.ibmPlexMono(
                                      color: AppTheme.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    "[YOUR DOOR]",
                                    style: GoogleFonts.ibmPlexMono(
                                      color: AppTheme.black.withValues(alpha: 0.7),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Item preview widgets
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  border: Border.all(color: AppTheme.black, width: 2),
                                  boxShadow: const [
                                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                        border: Border.all(color: AppTheme.black, width: 1.5),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=100&auto=format&fit=crop&q=80",
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(child: Text("🍔", style: TextStyle(fontSize: 18))),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "TRUFFLE BURGER",
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: AppTheme.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "₹249 • GOURMET",
                                            style: GoogleFonts.ibmPlexMono(
                                              color: AppTheme.black.withValues(alpha: 0.7),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  border: Border.all(color: AppTheme.black, width: 2),
                                  boxShadow: const [
                                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                        border: Border.all(color: AppTheme.black, width: 1.5),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        "https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=100&auto=format&fit=crop&q=80",
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(child: Text("🥑", style: TextStyle(fontSize: 18))),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "AVOCADO BOX",
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: AppTheme.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "₹149 • 10-MIN MART",
                                            style: GoogleFonts.ibmPlexMono(
                                              color: AppTheme.black.withValues(alpha: 0.7),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Action Button
                        ElevatedButton(
                          onPressed: () => _navigateToAuth(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.yellow,
                            foregroundColor: AppTheme.black,
                            elevation: 0,
                            side: const BorderSide(color: AppTheme.black, width: 2.5),
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "LAUNCH LIVE WEB APP",
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.black),
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

          // 2. Floating Top-Left Kinetic Sticker
          Positioned(
            top: -16,
            left: -14,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnimation.value * 0.7),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.black,
                      offset: Offset(3.5, 3.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("⚡", style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      "10-MIN RAPID DISPATCH",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating Bottom-Right Kinetic Sticker
          Positioned(
            bottom: -16,
            right: -14,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnimation.value * 0.5),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.black,
                      offset: Offset(3.5, 3.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("★", style: TextStyle(fontSize: 12, color: AppTheme.black)),
                    const SizedBox(width: 6),
                    Text(
                      "4.95 RATING • 150K+ ORDERS",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. STATS RIBBON - Brutalism 2.0 Editorial Metrics Strip
  // -------------------------------------------------------------
  Widget _buildStatsRibbon(bool isMobile) {
    final stats = [
      {
        "icon": Icons.bolt_rounded,
        "value": "9.4 MINS",
        "label": "AVG WEB DISPATCH",
        "boxColor": AppTheme.yellow,
        "iconColor": AppTheme.black,
      },
      {
        "icon": Icons.sentiment_very_satisfied_rounded,
        "value": "150,000+",
        "label": "ACTIVE FOODIES",
        "boxColor": AppTheme.green,
        "iconColor": AppTheme.black,
      },
      {
        "icon": Icons.storefront_rounded,
        "value": "2,400+",
        "label": "KITCHENS & MARTS",
        "boxColor": AppTheme.blue,
        "iconColor": AppTheme.surface,
      },
      {
        "icon": Icons.verified_rounded,
        "value": "99.98%",
        "label": "ON-TIME PRECISION",
        "boxColor": AppTheme.yellow,
        "iconColor": AppTheme.black,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.black, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.black,
                  offset: Offset(5, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: isMobile
                ? Column(
                    children: List.generate(stats.length, (index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          border: index < stats.length - 1
                              ? const Border(
                                  bottom: BorderSide(color: AppTheme.black, width: 2),
                                )
                              : null,
                        ),
                        child: _buildStatItem(stats[index]),
                      );
                    }),
                  )
                : IntrinsicHeight(
                    child: Row(
                      children: List.generate(stats.length, (index) {
                        return Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                            decoration: BoxDecoration(
                              border: index < stats.length - 1
                                  ? const Border(
                                      right: BorderSide(color: AppTheme.black, width: 2),
                                    )
                                  : null,
                            ),
                            child: _buildStatItem(stats[index]),
                          ),
                        );
                      }),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(Map<String, dynamic> s) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: s["boxColor"] as Color,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.black,
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              s["icon"] as IconData,
              color: s["iconColor"] as Color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s["value"] as String,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s["label"] as String,
                style: GoogleFonts.ibmPlexMono(
                  color: AppTheme.black.withValues(alpha: 0.75),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 4. INTERACTIVE CATEGORIES
  // -------------------------------------------------------------
  // -------------------------------------------------------------
  // 4. INTERACTIVE CATEGORIES - Brutalism 2.0
  // -------------------------------------------------------------
  Widget _buildInteractiveCategories(bool isMobile) {
    final filteredItems = _selectedCategoryIndex == 0
        ? _foodItems
        : _selectedCategoryIndex == 1
            ? _foodItems.where((i) => i["isMostOrdered"] == true).toList()
            : _foodItems
                .where((i) => i["category"] == _selectedCategoryIndex)
                .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Text(
                  "⚡ CRAVE-WORTHY SELECTIONS // 10-MIN ENGINE",
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "FRESH FROM KITCHENS & AUTOMATED HUBS",
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.black,
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select a category to browse popular chef creations and 10-minute dark store grocery staples.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.black.withValues(alpha: 0.75),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // Brutalist Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.yellow : AppTheme.surface,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(
                                color: AppTheme.black,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.black,
                                  offset: isSelected
                                      ? const Offset(3, 3)
                                      : const Offset(1.5, 1.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              _categories[index],
                              style: GoogleFonts.spaceGrotesk(
                                color: AppTheme.black,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 36),

              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: (filteredItems.isEmpty ? _foodItems : filteredItems)
                    .map((item) => _buildFoodCard(item, isMobile))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> item, bool isMobile) {
    final cardWidth = isMobile ? double.infinity : 375.0;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(4.5, 4.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.black, width: 2.5),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item["image"] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: item["bg"] as Color,
                    child: Center(
                      child: Text(
                        item["emoji"] as String,
                        style: const TextStyle(fontSize: 58),
                      ),
                    ),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: item["bg"] as Color,
                      child: const Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.black, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                      ],
                    ),
                    child: Text(
                      item["tag"] as String,
                      style: GoogleFonts.ibmPlexMono(
                        color: AppTheme.black,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.yellow, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                      ],
                    ),
                    child: Text(
                      "⚡ ${item["time"]}",
                      style: GoogleFonts.ibmPlexMono(
                        color: AppTheme.yellow,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item["name"] as String,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppTheme.black, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppTheme.black, size: 15),
                          const SizedBox(width: 2),
                          Text(
                            "${item["rating"]}",
                            style: GoogleFonts.ibmPlexMono(
                              color: AppTheme.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item["desc"] as String,
                  style: GoogleFonts.inter(
                    color: AppTheme.black.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${(item["price"] as double).toStringAsFixed(0)}",
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _cartItemCount++;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Added ${item['name']} to order tray!",
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.black,
                              ),
                            ),
                            backgroundColor: AppTheme.yellow,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              side: const BorderSide(color: AppTheme.black, width: 2),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(
                        "ORDER NOW",
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yellow,
                        foregroundColor: AppTheme.black,
                        elevation: 0,
                        side: const BorderSide(color: AppTheme.black, width: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
    );
  }

  // -------------------------------------------------------------
  // 5. SPEED & ETA SIMULATOR - Brutalism 2.0 Engine Testbench
  // -------------------------------------------------------------
  Widget _buildSpeedSimulator(bool isMobile) {
    final speedMultiplier = _selectedTransportMode == 0
        ? 1.8
        : _selectedTransportMode == 1
            ? 1.2
            : 2.5;
    final calculatedMinutes =
        (4 + (_simulatedDistance * speedMultiplier)).round();
    final calculatedFee = _simulatedDistance > 5 ? "₹35" : "FREE";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.black, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.black, width: 1.5),
                  ),
                  child: Text(
                    "// REAL-TIME ENGINE TESTBENCH //",
                    style: GoogleFonts.ibmPlexMono(
                      color: AppTheme.yellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "SPEED & DISTANCE ETA SIMULATOR",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.black,
                    fontSize: isMobile ? 26 : 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Drag the distance slider to test BiteHub's AI courier dispatch and route calculation in real time.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppTheme.black.withValues(alpha: 0.75),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                isMobile
                    ? Column(
                        children: [
                          _buildSimulatorControls(),
                          const SizedBox(height: 28),
                          _buildSimulatorGauge(
                              calculatedMinutes, calculatedFee),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(flex: 12, child: _buildSimulatorControls()),
                          const SizedBox(width: 44),
                          Expanded(
                              flex: 8,
                              child: _buildSimulatorGauge(
                                  calculatedMinutes, calculatedFee)),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatorControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "DELIVERY DISTANCE:",
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.black,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.yellow,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                ],
              ),
              child: Text(
                "${_simulatedDistance.toStringAsFixed(1)} KM",
                style: GoogleFonts.ibmPlexMono(
                  color: AppTheme.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.black,
            inactiveTrackColor: AppTheme.bg,
            thumbColor: AppTheme.yellow,
            overlayColor: Colors.transparent,
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: _simulatedDistance,
            min: 0.5,
            max: 15.0,
            divisions: 29,
            onChanged: (val) {
              setState(() {
                _simulatedDistance = val;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        // Animated Live Road Track
        Container(
          margin: const EdgeInsets.only(bottom: 22),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.black,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.black,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = (constraints.maxWidth - 44).clamp(80.0, 600.0);
              final progressFraction =
                  ((_simulatedDistance - 0.5) / 14.5).clamp(0.0, 1.0);
              final courierX = progressFraction * trackWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "DISPATCH ROAD CORRIDOR // LIVE",
                            style: GoogleFonts.ibmPlexMono(
                              color: AppTheme.surface,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${(_simulatedDistance * 4.2).round()} KM/H TELEMETRY",
                        style: GoogleFonts.ibmPlexMono(
                          color: AppTheme.yellow,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 32,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Asphalt dashed lane
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _roadDashController,
                            builder: (context, _) => CustomPaint(
                              painter:
                                  _RoadDashesPainter(_roadDashController.value),
                            ),
                          ),
                        ),
                        // Origin store flag
                        const Positioned(
                          left: 0,
                          child: Text("🏪", style: TextStyle(fontSize: 16)),
                        ),
                        // Destination home
                        const Positioned(
                          right: 0,
                          child: Text("📍", style: TextStyle(fontSize: 16)),
                        ),
                        // Moving courier vehicle
                        Positioned(
                          left: (14 + courierX).toDouble(),
                          child: Text(
                            _selectedTransportMode == 0
                                ? "⚡🛵"
                                : _selectedTransportMode == 1
                                    ? "🛸"
                                    : "🚲",
                            style: const TextStyle(fontSize: 19),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Text(
          "SELECT DISPATCH MODE:",
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.black,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _transportModeCard(0, "⚡ HYPER BIKE", "Sub-12 min"),
            const SizedBox(width: 10),
            _transportModeCard(1, "🛸 DRONE AIR", "Express Pilot"),
            const SizedBox(width: 10),
            _transportModeCard(2, "🚲 ECO RIDER", "Zero Carbon"),
          ],
        ),
      ],
    );
  }

  Widget _transportModeCard(int index, String title, String sub) {
    final isSelected = _selectedTransportMode == index;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedTransportMode = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.yellow : AppTheme.bg,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppTheme.black,
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black,
                  offset: isSelected ? const Offset(3, 3) : const Offset(1.5, 1.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.black.withValues(alpha: 0.7),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatorGauge(int minutes, String fee) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(4.5, 4.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              "PREDICTED ARRIVAL TIME",
              style: GoogleFonts.ibmPlexMono(
                color: AppTheme.yellow,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "$minutes",
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.black,
              fontSize: 72,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          Text(
            "MINUTES ESTIMATED",
            style: GoogleFonts.ibmPlexMono(
              color: AppTheme.black,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: 2,
            color: AppTheme.black,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DELIVERY FEE: $fee",
                style: GoogleFonts.ibmPlexMono(
                  color: AppTheme.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 1.5),
                ),
                child: Text(
                  "100% ELECTRIC",
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.black,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 6. ECOSYSTEM SECTION (4 ROLES) - Brutalism 2.0
  // -------------------------------------------------------------
  Widget _buildEcosystemSection(bool isMobile) {
    final roles = [
      {
        "title": "HUNGRY FOODIES",
        "sub": "Customer App",
        "desc":
            "1-tap checkout, live courier radar, zero minimum order, and personalized food cravings.",
        "roleArg": "User",
        "icon": Icons.lunch_dining_rounded,
        "boxBg": AppTheme.yellow,
        "iconColor": AppTheme.black,
      },
      {
        "title": "KITCHEN PARTNERS",
        "sub": "Restaurant Portal",
        "desc":
            "Real-time kitchen order display (KDS), automated menu sync, dish toggles, and daily payouts.",
        "roleArg": "Restaurant",
        "icon": Icons.soup_kitchen_rounded,
        "boxBg": AppTheme.black,
        "iconColor": AppTheme.yellow,
      },
      {
        "title": "HYPERLOCAL HUBS",
        "sub": "Dark Store Inventory",
        "desc":
            "Sub-second barcode scanner sync, real-time restock alerts, and 90-second bag-and-tag dispatch.",
        "roleArg": "Dark Store Hub",
        "icon": Icons.inventory_2_rounded,
        "boxBg": AppTheme.blue,
        "iconColor": AppTheme.surface,
      },
      {
        "title": "SPEED COURIERS",
        "sub": "Delivery Fleet",
        "desc":
            "AI multi-order batch routing, surge pricing incentives, flexible shifts, and instant earnings.",
        "roleArg": "Delivery Agent",
        "icon": Icons.two_wheeler_rounded,
        "boxBg": AppTheme.green,
        "iconColor": AppTheme.black,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Text(
                  "⚡ ONE PLATFORM // FOUR EXPERIENCES",
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "THE COMPLETE BITEHUB ECOSYSTEM",
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.black,
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Whether dining, cooking, packing, or riding, every role enjoys an effortless experience.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.black.withValues(alpha: 0.75),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: roles.map((r) {
                  final cardWidth = isMobile ? double.infinity : 285.0;
                  return Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.black, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.black,
                          offset: Offset(4.5, 4.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: r["boxBg"] as Color,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: AppTheme.black, width: 2),
                            boxShadow: const [
                              BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              r["icon"] as IconData,
                              color: r["iconColor"] as Color,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          r["title"] as String,
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (r["sub"] as String).toUpperCase(),
                          style: GoogleFonts.ibmPlexMono(
                            color: AppTheme.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          r["desc"] as String,
                          style: GoogleFonts.inter(
                            color: AppTheme.black.withValues(alpha: 0.75),
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () =>
                              _navigateToAuth(role: r["roleArg"] as String),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.yellow,
                            foregroundColor: AppTheme.black,
                            side: const BorderSide(color: AppTheme.black, width: 2),
                            minimumSize: const Size(double.infinity, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${(r['sub'] as String).toUpperCase()}",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 7. BENTO GRID FEATURES - Brutalism 2.0
  // -------------------------------------------------------------
  Widget _buildBentoFeatures(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Text(
                  "★ PROPRIETARY HARDWARE & LOGISTICS",
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "WHY BITEHUB DELIVERS DIFFERENTLY",
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.black,
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Engineered from the ground up for sub-12 minute cold-chain and hot-dish integrity.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.black.withValues(alpha: 0.75),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 34),
              isMobile
                  ? Column(
                      children: [
                        _bentoCard("🌡️ Temperature-Lock Pods",
                            "Insulated compartments keep wood-fired pizzas hot at 65°C and gelato frosty at -5°C."),
                        const SizedBox(height: 16),
                        _bentoCard("📡 Micro-GPS Live Radar",
                            "Direct sub-meter live coordinates with turn-by-turn routing for zero driver disorientation."),
                        const SizedBox(height: 16),
                        _bentoCard("🍃 100% Green Urban Fleet",
                            "Express dispatches powered by zero-emission electric bikes and e-mopeds."),
                        const SizedBox(height: 16),
                        _bentoCard("🛡️ Tamper-Evident Seals",
                            "Every order is digitally sealed with dual verification barcodes unlocked by recipient."),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                flex: 12,
                                child: _bentoCard("🌡️ Temperature-Lock Pods",
                                    "Patented insulated compartments keep pizzas crisp at 65°C and gelato frosty at -5°C throughout transit.")),
                            const SizedBox(width: 18),
                            Expanded(
                                flex: 9,
                                child: _bentoCard("📡 Micro-GPS Live Radar",
                                    "Direct sub-meter live coordinates with turn-by-turn routing for zero driver disorientation.")),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                                flex: 9,
                                child: _bentoCard("🍃 100% Green Fleet",
                                    "All urban express dispatches are conducted via zero-emission electric cargo bikes.")),
                            const SizedBox(width: 18),
                            Expanded(
                                flex: 12,
                                child: _bentoCard("🛡️ Tamper-Evident Seals",
                                    "Every bag is digitally sealed with dual verification barcodes that only you can unlock.")),
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bentoCard(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(4.5, 4.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.inter(
              color: AppTheme.black.withValues(alpha: 0.75),
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 8. REVIEWS - Brutalism 2.0
  // -------------------------------------------------------------
  Widget _buildReviewsSection(bool isMobile) {
    final reviews = [
      {
        "name": "Sarah Jenkins",
        "role": "Verified Foodie • 42 orders",
        "text":
            "BiteHub is ridiculously fast. My smashed burger arrived piping hot in 11 minutes while I was on a call!",
      },
      {
        "name": "Chef Marco Rossi",
        "role": "Owner, Bella Napoli Trattoria",
        "text":
            "The Restaurant Partner Dashboard allows us to handle 200+ lunch orders with zero confusion. Game changer.",
      },
      {
        "name": "David K.",
        "role": "Verified Foodie • 18 orders",
        "text":
            "Ran out of milk and eggs for breakfast—the 10-minute dark store delivery arrived in 8 minutes flat.",
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Text(
                  "★ VERIFIED DISPATCH TELEMETRY",
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "TRUSTED BY 150,000+ FOODIES & PARTNERS",
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.black,
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 32),
              isMobile
                  ? Column(
                      children: reviews
                          .map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildReviewCard(r),
                              ))
                          .toList(),
                    )
                  : Row(
                      children: reviews
                          .map((r) => Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10),
                                  child: _buildReviewCard(r),
                                ),
                              ))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> r) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.yellow,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.black, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (i) => const Icon(Icons.star_rounded,
                    color: AppTheme.black, size: 16),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "\"${r["text"]}\"",
            style: GoogleFonts.inter(
              color: AppTheme.black,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            r["name"] as String,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.black,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            r["role"] as String,
            style: GoogleFonts.ibmPlexMono(
              color: AppTheme.black.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 9. FAQ ACCORDION - Brutalism 2.0
  // -------------------------------------------------------------
  Widget _buildFaqSection(bool isMobile) {
    final faqs = [
      {
        "q": "How does BiteHub achieve 10-minute delivery?",
        "a":
            "We operate hyperlocal micro-fulfillment dark stores and geo-cluster partner kitchens. Orders are packed in 90 seconds and dispatched to couriers stationed within 1.5 km.",
      },
      {
        "q": "Is there a minimum order requirement?",
        "a":
            "No! You can order a single pack of chewing gum or a 10-person gourmet family feast.",
      },
      {
        "q": "How can restaurants and stores join the BiteHub network?",
        "a":
            "Click 'Partner Login' in the navigation bar to register your cloud kitchen or store. Our verification team activates your account within 2 hours.",
      },
      {
        "q": "Why is this landing page web-exclusive?",
        "a":
            "This landing page is tailored for large-screen web discovery. When opened on mobile devices or native apps, BiteHub boots directly into the native mobile client!",
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.black, width: 2),
                  boxShadow: const [
                    BoxShadow(color: AppTheme.black, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Text(
                  "? FREQUENTLY ASKED QUESTIONS",
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "ANSWERS TO CORE QUESTIONS",
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.black,
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 28),
              ...List.generate(faqs.length, (i) {
                final isExpanded = _expandedFaqIndex == i;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isExpanded ? AppTheme.yellow : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: AppTheme.black,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.black,
                        offset: isExpanded ? const Offset(4, 4) : const Offset(2.5, 2.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: Key("faq_$i"),
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (exp) {
                        setState(() {
                          _expandedFaqIndex = exp ? i : -1;
                        });
                      },
                      title: Text(
                        faqs[i]["q"]!,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faqs[i]["a"]!,
                            style: GoogleFonts.inter(
                              color: AppTheme.black.withValues(alpha: 0.85),
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 10. CTA BANNER - Brutalism 2.0 Stark Black Chassis
  // -------------------------------------------------------------
  Widget _buildCtaBanner(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 32 : 52),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.black, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.yellow,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    "⚡ ZERO COMPROMISE QUICK-COMMERCE",
                    style: GoogleFonts.ibmPlexMono(
                      color: AppTheme.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "HUNGRY RIGHT NOW?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.surface,
                    fontSize: isMobile ? 32 : 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Order chef-curated meals or 10-minute grocery essentials. High-speed electric couriers are stationed in your area.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppTheme.surface.withValues(alpha: 0.85),
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _navigateToAuth(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.yellow,
                    foregroundColor: AppTheme.black,
                    elevation: 0,
                    side: const BorderSide(color: AppTheme.black, width: 2.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "LAUNCH BITEHUB WEB APP",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.black),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 11. FOOTER - Brutalism 2.0 Off-White & Black Telemetry
  // -------------------------------------------------------------
  Widget _buildFooter(bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(top: 70),
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: 40),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(top: BorderSide(color: AppTheme.black, width: 2.5)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.black,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(color: AppTheme.black, width: 2),
                          boxShadow: const [
                            BoxShadow(color: AppTheme.yellow, offset: Offset(2, 2), blurRadius: 0),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "B",
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.yellow,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "BITEHUB",
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "ALL SYSTEMS OPERATIONAL // 99.98% SLA",
                        style: GoogleFonts.ibmPlexMono(
                          color: AppTheme.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 2, color: AppTheme.black),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "© 2026 BITEHUB PLATFORM INC. ALL RIGHTS RESERVED.",
                    style: GoogleFonts.ibmPlexMono(
                      color: AppTheme.black.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "WEB EDITION • 10-MIN ENGINE",
                    style: GoogleFonts.ibmPlexMono(
                      color: AppTheme.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating Cart Tray - Brutalism 2.0
  Widget _buildFloatingCartPill() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _navigateToAuth(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.yellow,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.black, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_bag_rounded,
                  color: AppTheme.black, size: 20),
              const SizedBox(width: 8),
              Text(
                "$_cartItemCount ITEM${_cartItemCount > 1 ? 'S' : ''} IN TRAY",
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.black,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  "CHECKOUT →",
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.yellow,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadDashesPainter extends CustomPainter {
  final double animationValue;
  _RoadDashesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.yellow.withValues(alpha: 0.5)
      ..strokeWidth = 2.0;

    const dashWidth = 14.0;
    const dashSpace = 12.0;
    const total = dashWidth + dashSpace;
    final offset = animationValue * total;
    double startX = -total + offset;
    final y = size.height / 2;

    while (startX < size.width + total) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += total;
    }
  }

  @override
  bool shouldRepaint(covariant _RoadDashesPainter oldDelegate) => true;
}

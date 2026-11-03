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
      "emoji": "🍔",
      "bg": Color(0xFFFFF1F2),
      "desc": "Double grilled Wagyu beef, aged gouda, black truffle aioli, toasted brioche.",
    },
    {
      "name": "Hyderabadi Royal Dum Biryani",
      "category": 2,
      "isMostOrdered": true,
      "tag": "⭐ 12.1k Orders",
      "rating": 4.97,
      "price": 280.00,
      "time": "15 mins",
      "emoji": "🍛",
      "bg": Color(0xFFFEF3C7),
      "desc": "Slow-cooked saffron basmati, tender marinated spices, served with cooling salan & raita.",
    },
    {
      "name": "Artisanal Burrata Margherita",
      "category": 2,
      "isMostOrdered": true,
      "tag": "Wood-Fired Favorite",
      "rating": 4.92,
      "price": 299.00,
      "time": "14 mins",
      "emoji": "🍕",
      "bg": Color(0xFFFFF7ED),
      "desc": "San Marzano tomatoes, fresh cream burrata, fresh basil, extra virgin olive oil.",
    },
    {
      "name": "Organic Hass Avocados & Berry Box",
      "category": 3,
      "isMostOrdered": true,
      "tag": "🥦 Top Grocery Pick (14k)",
      "rating": 4.98,
      "price": 149.00,
      "time": "8 mins",
      "emoji": "🥑",
      "bg": Color(0xFFECFDF5),
      "desc": "Freshly harvested Hass avocados, wild blueberries, and chilled Greek yogurt.",
    },
    {
      "name": "Farm Fresh Milk & Country Eggs Pack",
      "category": 3,
      "isMostOrdered": true,
      "tag": "🥛 Daily Essential (19k)",
      "rating": 4.94,
      "price": 95.00,
      "time": "7 mins",
      "emoji": "🥛",
      "bg": Color(0xFFF0FDF4),
      "desc": "Pasteurized pure whole milk pouch (1L) paired with farm-fresh organic brown eggs.",
    },
    {
      "name": "Dragon Flame Salmon Roll",
      "category": 4,
      "isMostOrdered": false,
      "tag": "Top Asian Dining",
      "rating": 4.96,
      "price": 320.00,
      "time": "15 mins",
      "emoji": "🍣",
      "bg": Color(0xFFEFF6FF),
      "desc": "Torched Atlantic salmon, tempura shrimp, avocado, tobiko, unagi glaze.",
    },
    {
      "name": "Molten Belgian Lava Cake & Gelato",
      "category": 5,
      "isMostOrdered": true,
      "tag": "Sweet Indulgence (6.2k)",
      "rating": 4.99,
      "price": 180.00,
      "time": "10 mins",
      "emoji": "🍫",
      "bg": Color(0xFFFAF5FF),
      "desc": "Warm 70% dark Belgian chocolate center paired with Madagascar vanilla gelato.",
    },
    {
      "name": "Farm Fresh Hydroponic Bowl",
      "category": 0,
      "isMostOrdered": false,
      "tag": "Clean Eating",
      "rating": 4.88,
      "price": 199.00,
      "time": "9 mins",
      "emoji": "🥗",
      "bg": Color(0xFFF0FDF4),
      "desc": "Crisp romaine, quinoa, cherry tomatoes, kalamata olives, tahini lemon dressing.",
    },
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _courierController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _courierProgress = Tween<double>(begin: 0.40, end: 0.78).animate(
      CurvedAnimation(parent: _courierController, curve: Curves.easeInOut),
    );
    _radarRipple = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _courierController, curve: Curves.easeOut),
    );

    _roadDashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _courierController.dispose();
    _roadDashController.dispose();
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
      _speedCheckResult = "⚡ Lightning Hub Active in $code: Dispatch in 9-11 mins!";
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Clean #F8FAFC
      body: Stack(
        children: [
          // Subtle ambient glow orbs in corners
          Positioned(
            top: -100,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 600,
            left: -120,
            child: IgnorePointer(
              child: Container(
                width: 550,
                height: 550,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.secondaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Scrollable Landing Page Body
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 76), // Navbar clearance
                _buildHeroSection(isMobile),
                const SizedBox(height: 50),
                _buildStatsRibbon(isMobile),
                const SizedBox(height: 70),
                _buildInteractiveCategories(isMobile),
                const SizedBox(height: 80),
                _buildSpeedSimulator(isMobile),
                const SizedBox(height: 80),
                _buildEcosystemSection(isMobile),
                const SizedBox(height: 80),
                _buildBentoFeatures(isMobile),
                const SizedBox(height: 80),
                _buildReviewsSection(isMobile),
                const SizedBox(height: 80),
                _buildFaqSection(isMobile),
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
  // 1. NAVIGATION BAR
  // -------------------------------------------------------------
  Widget _buildNavigationBar(bool isMobile) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "B",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: TextSpan(
                      text: "Bite",
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                      children: const [
                        TextSpan(
                          text: "Hub",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "WEB PORTAL",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF059669),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
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
                _navLinkItem("Live Menu", 520),
                _navLinkItem("Speed Test", 1120),
                _navLinkItem("Ecosystem", 1680),
                _navLinkItem("Why Us", 2220),
                _navLinkItem("Reviews", 2700),
              ],
            ),

          // Action CTAs
          Row(
            children: [
              if (!isMobile)
                TextButton(
                  onPressed: () => _navigateToAuth(role: "Restaurant"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    "Partner Login",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: () => _navigateToAuth(),
                icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                label: Text(
                  isMobile ? "Launch" : "Launch App",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 22,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navLinkItem(String title, double offset) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _scrollToSection(offset),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. HERO SECTION
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
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Clean announcement badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("⚡", style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                "FASTEST 10-MINUTE QUICK-COMMERCE & FOOD",
                style: GoogleFonts.inter(
                  color: const Color(0xFF4F46E5),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Main Title
        Text(
          "Your Cravings,\nOur Command.",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 42 : 58,
            fontWeight: FontWeight.w900,
            height: 1.1,
            color: AppTheme.textPrimary,
            letterSpacing: -1.6,
          ),
        ),
        const SizedBox(height: 12),
        // Subtitle gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF059669)],
          ).createShader(bounds),
          child: Text(
            "10-Minute Dark Store & Gourmet Dining.",
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(height: 18),

        Text(
          "Order chef-curated restaurant dishes or instant dark-store groceries in seconds. Powered by smart multi-role dispatch and sub-12-minute electric courier delivery.",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 15 : 16.5,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),

        // Clean Pincode Checker
        Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.location_on_rounded, color: AppTheme.secondaryColor, size: 20),
              ),
              Expanded(
                child: TextField(
                  controller: _pincodeController,
                  style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Enter pincode or delivery area...",
                    hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
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
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Check Speed",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_speedCheckResult != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Text(
              _speedCheckResult!,
              style: GoogleFonts.inter(
                color: const Color(0xFF059669),
                fontSize: 13,
                fontWeight: FontWeight.w700,
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
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                shadowColor: AppTheme.primaryColor.withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Order Food & Mart",
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _scrollToSection(520),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.textPrimary,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "Explore Live Menu",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Rating Strip
        Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
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

  // Hero Mockup with Levitation & Floating Badges
  Widget _buildHeroMockup(bool isMobile) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. MAIN CARD (Rendered first as the base surface)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 36,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // Window Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppTheme.errorColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppTheme.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "⚡ LIVE RADAR DISPATCH #BH-9821",
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.electric_bike_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Courier Alex (#A-402)",
                                          style: GoogleFonts.inter(
                                            color: AppTheme.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          "0.6 km away • EV Express",
                                          style: GoogleFonts.inter(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      "ETA 5 MINS",
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF059669),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.centerLeft,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: const LinearProgressIndicator(
                                      value: 0.78,
                                      backgroundColor: Color(0xFFE2E8F0),
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                                      minHeight: 8,
                                    ),
                                  ),
                                  AnimatedBuilder(
                                    animation: _courierController,
                                    builder: (context, _) {
                                      final barWidth = isMobile ? 220.0 : 280.0;
                                      return Positioned(
                                        left: barWidth * _courierProgress.value,
                                        top: -15,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 24 * (0.8 + _radarRipple.value * 0.7),
                                              height: 24 * (0.8 + _radarRipple.value * 0.7),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppTheme.secondaryColor
                                                      .withOpacity((1.0 - _radarRipple.value).clamp(0.0, 1.0)),
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                            Transform.scale(
                                              scaleX: -1,
                                              child: const Text("🛵", style: TextStyle(fontSize: 18)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Kitchen Ready",
                                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 10.5),
                                  ),
                                  Text(
                                    "Out for Delivery 🚀",
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF059669),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    "Your Door",
                                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 10.5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Text("🍔", style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Truffle Burger",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            "₹249",
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF059669),
                                              fontSize: 12,
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Text("🥑", style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Avocado Box",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            "₹149",
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF059669),
                                              fontSize: 12,
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
                          ],
                        ),

                        const SizedBox(height: 18),

                        ElevatedButton(
                          onPressed: () => _navigateToAuth(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Launch Live Web Experience →",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Floating Top Chip (Placed AFTER the card so it paints ON TOP without being hidden)
          Positioned(
            top: -16,
            left: -14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🔥", style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    "10-Min Dispatch",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Bottom Chip (Placed AFTER the card so it paints ON TOP without being hidden)
          Positioned(
            bottom: -16,
            right: -14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("⭐", style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    "4.95 Rating (85k+ Reviews)",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 3. STATS RIBBON
  // -------------------------------------------------------------
  Widget _buildStatsRibbon(bool isMobile) {
    final stats = [
      {"icon": Icons.bolt_rounded, "value": "9.4 Mins", "label": "Avg Web Dispatch", "color": AppTheme.secondaryColor},
      {"icon": Icons.sentiment_very_satisfied_rounded, "value": "150,000+", "label": "Happy Foodies", "color": AppTheme.primaryColor},
      {"icon": Icons.storefront_rounded, "value": "2,400+", "label": "Kitchens & Marts", "color": AppTheme.accentColor},
      {"icon": Icons.verified_rounded, "value": "99.98%", "label": "On-Time Precision", "color": const Color(0xFFEC4899)},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isMobile
                ? Column(
                    children: stats
                        .map((s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: _buildStatItem(s),
                            ))
                        .toList(),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: stats.map((s) => _buildStatItem(s)).toList(),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (s["color"] as Color).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(s["icon"] as IconData, color: s["color"] as Color, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s["value"] as String,
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              s["label"] as String,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 4. INTERACTIVE CATEGORIES
  // -------------------------------------------------------------
  Widget _buildInteractiveCategories(bool isMobile) {
    final filteredItems = _selectedCategoryIndex == 0
        ? _foodItems
        : _selectedCategoryIndex == 1
            ? _foodItems.where((i) => i["isMostOrdered"] == true).toList()
            : _foodItems.where((i) => i["category"] == _selectedCategoryIndex).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Text(
                  "CRAVE-WORTHY SELECTIONS",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF4F46E5),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Fresh From Kitchens & Automated Hubs",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: isMobile ? 28 : 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select a category to browse popular dishes and 10-minute mart essentials.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        label: Text(_categories[index]),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: Colors.white,
                        labelStyle: GoogleFonts.inter(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 36),

              Wrap(
                spacing: 20,
                runSpacing: 20,
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
    final cardWidth = isMobile ? double.infinity : 380.0;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: item["bg"] as Color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    item["emoji"] as String,
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item["tag"] as String,
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item["time"] as String,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item["name"] as String,
                        style: GoogleFonts.outfit(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.accentColor, size: 17),
                        const SizedBox(width: 3),
                        Text(
                          "${item["rating"]}",
                          style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item["desc"] as String,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${(item["price"] as double).toStringAsFixed(0)}",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF059669),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _cartItemCount++;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Added ${item['name']} to order tray!"),
                            backgroundColor: AppTheme.primaryColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(
                        "Order Now",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
  // 5. SPEED & ETA SIMULATOR
  // -------------------------------------------------------------
  Widget _buildSpeedSimulator(bool isMobile) {
    final speedMultiplier = _selectedTransportMode == 0
        ? 1.8
        : _selectedTransportMode == 1
            ? 1.2
            : 2.5;
    final calculatedMinutes = (4 + (_simulatedDistance * speedMultiplier)).round();
    final calculatedFee = _simulatedDistance > 5 ? "₹35" : "FREE";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "REAL-TIME ENGINE TESTBENCH",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF4F46E5),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Speed & Distance ETA Simulator",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Drag the distance slider to preview BiteHub's AI courier dispatch prediction.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 36),

                isMobile
                    ? Column(
                        children: [
                          _buildSimulatorControls(),
                          const SizedBox(height: 28),
                          _buildSimulatorGauge(calculatedMinutes, calculatedFee),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(flex: 12, child: _buildSimulatorControls()),
                          const SizedBox(width: 44),
                          Expanded(flex: 8, child: _buildSimulatorGauge(calculatedMinutes, calculatedFee)),
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
              "Delivery Distance:",
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "${_simulatedDistance.toStringAsFixed(1)} km",
              style: GoogleFonts.outfit(
                color: const Color(0xFF059669),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.secondaryColor,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            thumbColor: AppTheme.secondaryColor,
            overlayColor: AppTheme.secondaryColor.withOpacity(0.15),
            trackHeight: 6,
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
        const SizedBox(height: 10),
        // Animated Live Road Track
        Container(
          margin: const EdgeInsets.only(bottom: 22),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = (constraints.maxWidth - 44).clamp(80.0, 600.0);
              final progressFraction = ((_simulatedDistance - 0.5) / 14.5).clamp(0.0, 1.0);
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
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "DISPATCH ROAD CORRIDOR",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${(_simulatedDistance * 4.2).round()} km/h avg speed",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 28,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Asphalt dashed lane
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _roadDashController,
                            builder: (context, _) => CustomPaint(
                              painter: _RoadDashesPainter(_roadDashController.value),
                            ),
                          ),
                        ),
                        // Origin store flag
                        const Positioned(
                          left: 0,
                          child: Text("🏪", style: TextStyle(fontSize: 14)),
                        ),
                        // Destination home
                        const Positioned(
                          right: 0,
                          child: Text("📍", style: TextStyle(fontSize: 14)),
                        ),
                        // Moving courier vehicle
                        Positioned(
                          left: 14 + courierX,
                          child: Text(
                            _selectedTransportMode == 0
                                ? "⚡🛵"
                                : _selectedTransportMode == 1
                                    ? "🛸"
                                    : "🚲",
                            style: const TextStyle(fontSize: 18),
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
          "Select Dispatch Mode:",
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _transportModeCard(0, "⚡ Hyper Bike", "Sub-12 min"),
            const SizedBox(width: 10),
            _transportModeCard(1, "🛸 Drone Air", "Express Pilot"),
            const SizedBox(width: 10),
            _transportModeCard(2, "🚲 Eco Rider", "Zero Carbon"),
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
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            "PREDICTED ARRIVAL TIME",
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$minutes",
            style: GoogleFonts.outfit(
              color: const Color(0xFF059669),
              fontSize: 64,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          Text(
            "MINUTES",
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery Fee: $fee",
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "100% Green",
                style: GoogleFonts.inter(
                  color: const Color(0xFF059669),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 6. ECOSYSTEM SECTION (4 ROLES)
  // -------------------------------------------------------------
  Widget _buildEcosystemSection(bool isMobile) {
    final roles = [
      {
        "title": "Hungry Foodies",
        "sub": "Customer App",
        "desc": "1-tap checkout, live courier radar, zero minimum order, and personalized food cravings.",
        "roleArg": "User",
        "icon": Icons.lunch_dining_rounded,
        "color": AppTheme.primaryColor,
        "bg": const Color(0xFFEEF2FF),
      },
      {
        "title": "Kitchen Partners",
        "sub": "Restaurant Portal",
        "desc": "Real-time kitchen order display (KDS), automated menu sync, dish toggles, and daily payouts.",
        "roleArg": "Restaurant",
        "icon": Icons.soup_kitchen_rounded,
        "color": AppTheme.accentColor,
        "bg": const Color(0xFFFFFBEB),
      },
      {
        "title": "Hyperlocal Hubs",
        "sub": "Dark Store Inventory",
        "desc": "Sub-second barcode scanner sync, real-time restock alerts, and 90-second bag-and-tag dispatch.",
        "roleArg": "Dark Store Hub",
        "icon": Icons.inventory_2_rounded,
        "color": AppTheme.secondaryColor,
        "bg": const Color(0xFFECFDF5),
      },
      {
        "title": "Speed Couriers",
        "sub": "Delivery Fleet",
        "desc": "AI multi-order batch routing, surge pricing incentives, flexible shifts, and instant earnings.",
        "roleArg": "Delivery Agent",
        "icon": Icons.two_wheeler_rounded,
        "color": const Color(0xFFE11D48),
        "bg": const Color(0xFFFFF1F2),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "ONE PLATFORM • FOUR EXPERIENCES",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF4F46E5),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "The Complete BiteHub Ecosystem",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: isMobile ? 28 : 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Whether dining, cooking, packing, or riding, every role enjoys an effortless experience.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14.5),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: r["bg"] as Color,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(r["icon"] as IconData, color: r["color"] as Color, size: 24),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          r["title"] as String,
                          style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          r["sub"] as String,
                          style: GoogleFonts.inter(
                            color: r["color"] as Color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          r["desc"] as String,
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () => _navigateToAuth(role: r["roleArg"] as String),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.textPrimary,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "${r['sub']} →",
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
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
  // 7. BENTO GRID FEATURES
  // -------------------------------------------------------------
  Widget _buildBentoFeatures(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Text(
                "Why BiteHub Delivers Differently",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 32),
              isMobile
                  ? Column(
                      children: [
                        _bentoCard("🌡️ Temperature-Lock Pods", "Insulated compartments keep wood-fired pizzas hot at 65°C and gelato frosty at -5°C."),
                        const SizedBox(height: 16),
                        _bentoCard("📡 Micro-GPS Live Radar", "Direct sub-meter live coordinates with turn-by-turn routing for zero driver disorientation."),
                        const SizedBox(height: 16),
                        _bentoCard("🍃 100% Green Urban Fleet", "Express dispatches powered by zero-emission electric bikes and e-mopeds."),
                        const SizedBox(height: 16),
                        _bentoCard("🛡️ Tamper-Evident Seals", "Every order is digitally sealed with dual verification barcodes unlocked by recipient."),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 12, child: _bentoCard("🌡️ Temperature-Lock Pods", "Patented insulated compartments keep pizzas crisp at 65°C and gelato frosty at -5°C throughout transit.")),
                            const SizedBox(width: 18),
                            Expanded(flex: 9, child: _bentoCard("📡 Micro-GPS Live Radar", "Direct sub-meter live coordinates with turn-by-turn routing for zero driver disorientation.")),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(flex: 9, child: _bentoCard("🍃 100% Green Fleet", "All urban express dispatches are conducted via zero-emission electric cargo bikes.")),
                            const SizedBox(width: 18),
                            Expanded(flex: 12, child: _bentoCard("🛡️ Tamper-Evident Seals", "Every bag is digitally sealed with dual verification barcodes that only you can unlock.")),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 8. REVIEWS
  // -------------------------------------------------------------
  Widget _buildReviewsSection(bool isMobile) {
    final reviews = [
      {
        "name": "Sarah Jenkins",
        "role": "Verified Foodie • 42 orders",
        "text": "BiteHub is ridiculously fast. My smashed burger arrived piping hot in 11 minutes while I was on a call!",
      },
      {
        "name": "Chef Marco Rossi",
        "role": "Owner, Bella Napoli Trattoria",
        "text": "The Restaurant Partner Dashboard allows us to handle 200+ lunch orders with zero confusion. Game changer.",
      },
      {
        "name": "David K.",
        "role": "Verified Foodie • 18 orders",
        "text": "Ran out of milk and eggs for breakfast—the 10-minute dark store delivery arrived in 8 minutes flat.",
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Text(
                "Trusted By 150,000+ Foodies & Partners",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w800,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 9),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => const Icon(Icons.star_rounded, color: AppTheme.accentColor, size: 17),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "\"${r["text"]}\"",
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            r["name"] as String,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            r["role"] as String,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 9. FAQ ACCORDION
  // -------------------------------------------------------------
  Widget _buildFaqSection(bool isMobile) {
    final faqs = [
      {
        "q": "How does BiteHub achieve 10-minute delivery?",
        "a": "We operate hyperlocal micro-fulfillment dark stores and geo-cluster partner kitchens. Orders are packed in 90 seconds and dispatched to couriers stationed within 1.5 km.",
      },
      {
        "q": "Is there a minimum order requirement?",
        "a": "No! You can order a single pack of chewing gum or a 10-person gourmet family feast.",
      },
      {
        "q": "How can restaurants and stores join the BiteHub network?",
        "a": "Click 'Partner Login' in the navigation bar to register your cloud kitchen or store. Our verification team activates your account within 2 hours.",
      },
      {
        "q": "Why is this landing page web-exclusive?",
        "a": "This landing page is tailored for large-screen web discovery. When opened on mobile devices or native apps, BiteHub boots directly into the native mobile client!",
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            children: [
              Text(
                "Frequently Asked Questions",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 28),
              ...List.generate(faqs.length, (i) {
                final isExpanded = _expandedFaqIndex == i;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isExpanded ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                        style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faqs[i]["a"]!,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.5,
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
  // 10. CTA BANNER
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
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xFF4338CA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.25),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Hungry Right Now?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: isMobile ? 32 : 44,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Order gourmet meals or dark store groceries. Delivery arrives at your door in minutes.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: const Color(0xFFE0E7FF), fontSize: 16),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => _navigateToAuth(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4338CA),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Launch BiteHub Web App →",
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
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
  // 11. FOOTER
  // -------------------------------------------------------------
  Widget _buildFooter(bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(top: 70),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
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
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "B",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "BiteHub",
                        style: GoogleFonts.outfit(
                          color: AppTheme.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "All systems operational",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF059669),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "© 2026 BiteHub Platform Inc. All rights reserved.",
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Web Edition • 10-Min Engine",
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
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

  // Floating Cart Tray
  Widget _buildFloatingCartPill() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _navigateToAuth(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                "$_cartItemCount item${_cartItemCount > 1 ? 's' : ''} in tray",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Checkout →",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
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
      ..color = const Color(0xFFE2E8F0).withOpacity(0.35)
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

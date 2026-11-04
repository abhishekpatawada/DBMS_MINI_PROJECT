import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brutalist_widgets.dart';
import 'auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: BrutalistCard(
                bgColor: AppTheme.surface,
                padding: const EdgeInsets.all(28),
                shadowOffset: const Offset(6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Tag & Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BrutalistBadge(
                          label: "ACCESS CONTROL",
                          bgColor: AppTheme.yellow,
                        ),
                        Text(
                          "BITEHUB // 01",
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Header
                    Text(
                      "SELECT ROLE",
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
                      "Choose your workspace identity to access the portal.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF555555),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(height: 2.5, color: AppTheme.black),
                    const SizedBox(height: 20),

                    // Role 1: Customer
                    _buildRoleCard(
                      context,
                      title: "CUSTOMER / FOODIE",
                      subtitle: "ORDER FOOD & 10-MIN GROCERY INSTANTLY",
                      icon: Icons.fastfood_rounded,
                      role: "User",
                      accentColor: AppTheme.yellow,
                    ),
                    const SizedBox(height: 14),

                    // Role 2: Delivery Agent
                    _buildRoleCard(
                      context,
                      title: "DELIVERY AGENT",
                      subtitle: "LIVE DISPATCH, ROUTING & EARNINGS",
                      icon: Icons.electric_moped_rounded,
                      role: "Delivery Agent",
                      accentColor: AppTheme.green,
                    ),
                    const SizedBox(height: 14),

                    // Role 3: Restaurant Partner
                    _buildRoleCard(
                      context,
                      title: "RESTAURANT PARTNER",
                      subtitle: "MENU CATALOG, POS PIPELINE & SETTLEMENTS",
                      icon: Icons.storefront_rounded,
                      role: "Restaurant",
                      accentColor: AppTheme.orange,
                    ),
                    const SizedBox(height: 14),

                    // Role 4: Dark Store Hub
                    _buildRoleCard(
                      context,
                      title: "DARK STORE HUB",
                      subtitle: "QUICK-COMMERCE WAREHOUSE & INVENTORY",
                      icon: Icons.warehouse_rounded,
                      role: "Dark Store",
                      accentColor: AppTheme.blue,
                    ),
                    const SizedBox(height: 24),

                    // Direct Sign In Button
                    BrutalistButton.white(
                      text: "DIRECT SIGN IN →",
                      fullWidth: true,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String role,
    required Color accentColor,
  }) {
    return BrutalistCard(
      bgColor: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shadowOffset: const Offset(3.5, 3.5),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AuthScreen(selectedRole: role),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(color: AppTheme.black, width: 2.0),
            ),
            child: Icon(icon, size: 22, color: AppTheme.black),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.black),
        ],
      ),
    );
  }
}

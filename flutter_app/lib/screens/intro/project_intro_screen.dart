import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brutalist_widgets.dart';
import '../landing/web_landing_screen.dart';

class ProjectIntroScreen extends StatelessWidget {
  const ProjectIntroScreen({super.key});

  void _navigateToLanding(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WebLandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.05);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 960),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: isMobile ? 24 : 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- TOP BAR: UNIVERSITY / LAB BADGES ---
                  _buildTopBar(isMobile),
                  const SizedBox(height: 24),

                  // --- MAIN HERO BRUTALIST CONTAINER ---
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.black,
                        width: AppTheme.borderWidth + 0.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.black,
                          offset: Offset(8, 8),
                          blurRadius: 0,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Window Title Bar (Retro Terminal Style)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: AppTheme.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(2),
                              topRight: Radius.circular(2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppTheme.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppTheme.yellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppTheme.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  "DBMS_PROJECT_PRESENTATION // V2.0",
                                  style: GoogleFonts.ibmPlexMono(
                                    color: AppTheme.surface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.yellow,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  "LIVE",
                                  style: GoogleFonts.ibmPlexMono(
                                    color: AppTheme.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Main Content Body
                        Padding(
                          padding: EdgeInsets.all(isMobile ? 20 : 36),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Heading: DBMS PROJECT
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.blue,
                                      border: Border.all(
                                        color: AppTheme.black,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      "DATABASE MANAGEMENT SYSTEMS",
                                      style: GoogleFonts.ibmPlexMono(
                                        color: AppTheme.surface,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Text(
                                "DBMS PROJECT",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: isMobile ? 36 : 56,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.black,
                                  height: 1.05,
                                  letterSpacing: -1.5,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 2. Project Name: BITEHUB
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.yellow,
                                      border: Border.all(
                                        color: AppTheme.black,
                                        width: 2.5,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppTheme.black,
                                          offset: Offset(3, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "PROJECT: BITEHUB",
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: isMobile ? 18 : 24,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.black,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Hyperlocal Quick-Commerce & Multi-Role Delivery Ecosystem",
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: isMobile ? 12 : 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.black,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                              const Divider(
                                color: AppTheme.black,
                                thickness: 2,
                                height: 2,
                              ),
                              const SizedBox(height: 24),

                              // 3. Small Explanation
                              Text(
                                "SYSTEM OVERVIEW & ARCHITECTURE",
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF666666),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.bg,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppTheme.black,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  "BiteHub is an end-to-end relational database management system designed to coordinate high-frequency food delivery and 10-minute dark store grocery fulfillment. Built on a fully normalized (3NF) relational schema, it guarantees ACID transactional consistency across concurrent customer carts, real-time live GPS order dispatches, stock ledger deductions, and multi-tenant portal management for Customers, Delivery Agents, Restaurant Kitchens, and Dark Store Hubs.",
                                  style: GoogleFonts.inter(
                                    fontSize: isMobile ? 13 : 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.55,
                                    color: AppTheme.black,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Technical Highlights Pills
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildSpecPill("SCHEMA: 3NF RELATIONAL"),
                                  _buildSpecPill("TRANSACTIONS: ACID COMPLIANT"),
                                  _buildSpecPill("ACTORS: 4 INTEGRATED ROLES"),
                                  _buildSpecPill("DB ENGINE: MYSQL 8.0+"),
                                ],
                              ),

                              const SizedBox(height: 32),
                              const Divider(
                                color: AppTheme.black,
                                thickness: 2,
                                height: 2,
                              ),
                              const SizedBox(height: 24),

                              // 4. Team Members: Abhishek & Beergond
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people_alt,
                                    size: 18,
                                    color: AppTheme.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "PROJECT DEVELOPED BY",
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.black,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              isMobile
                                  ? Column(
                                      children: [
                                        _buildStudentCard(
                                          name: "Abhishek",
                                          usn: "U25UV24T029002",
                                          role: "Database Architecture & Frontend System",
                                          initials: "AB",
                                          accentColor: AppTheme.yellow,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildStudentCard(
                                          name: "Beergond",
                                          usn: "U25UV24T029023",
                                          role: "Backend Queries, Relations & Triggers",
                                          initials: "BG",
                                          accentColor: AppTheme.green,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: _buildStudentCard(
                                            name: "Abhishek",
                                            usn: "U25UV24T029002",
                                            role: "Database Architecture & Frontend System",
                                            initials: "AB",
                                            accentColor: AppTheme.yellow,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildStudentCard(
                                            name: "Beergond",
                                            usn: "U25UV24T029023",
                                            role: "Backend Queries, Relations & Triggers",
                                            initials: "BG",
                                            accentColor: AppTheme.green,
                                          ),
                                        ),
                                      ],
                                    ),

                              const SizedBox(height: 36),

                              // 5. Button to open Landing Page
                              Center(
                                child: SizedBox(
                                  width: isMobile ? double.infinity : 440,
                                  height: 56,
                                  child: BrutalistButton(
                                    text: "ENTER BITEHUB LANDING PAGE →",
                                    icon: Icons.rocket_launch,
                                    bgColor: AppTheme.yellow,
                                    textColor: AppTheme.black,
                                    fontSize: isMobile ? 13 : 15,
                                    onPressed: () => _navigateToLanding(context),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  "Click above to launch the interactive live platform",
                                  style: GoogleFonts.ibmPlexMono(
                                    fontSize: 11,
                                    color: const Color(0xFF777777),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Bottom Footer note
                  Center(
                    child: Text(
                      "DEPARTMENT OF COMPUTER SCIENCE & ENGINEERING • DBMS CAPSTONE 2026",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF666666),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.black,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  "DBMS LAB",
                  style: GoogleFonts.ibmPlexMono(
                    color: AppTheme.yellow,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "PROJECT SUBMISSION",
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppTheme.black,
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
              const SizedBox(width: 6),
              Text(
                "READY TO LAUNCH",
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppTheme.black, width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.black,
        ),
      ),
    );
  }

  Widget _buildStudentCard({
    required String name,
    required String usn,
    required String role,
    required String initials,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: AppTheme.black,
          width: AppTheme.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.black,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Initials Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: AppTheme.black, width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    usn,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.yellow,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  role,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


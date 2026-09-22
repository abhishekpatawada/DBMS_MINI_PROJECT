import 'package:flutter/material.dart';
import '../services/dbms_settings_service.dart';
import 'auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DBMS Delivery System"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: DbmsSimulationToggleSwitch(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text("📦", style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "DBMS Project",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Food & Grocery Multi-Vendor Delivery System",
                    style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 36),

                  // Header
                  const Text(
                    "Select Your Role",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role Cards
                  _buildRoleCard(
                    context: context,
                    role: "User",
                    icon: "👤",
                    title: "Customer (User)",
                    subtitle: "Order food from restaurants & groceries from dark stores",
                    badgeColor: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 14),

                  _buildRoleCard(
                    context: context,
                    role: "Delivery Agent",
                    icon: "🛵",
                    title: "Delivery Agent",
                    subtitle: "View assigned deliveries & update live delivery transit statuses",
                    badgeColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 14),

                  _buildRoleCard(
                    context: context,
                    role: "Restaurant",
                    icon: "🏪",
                    title: "Restaurant Partner",
                    subtitle: "Manage menus, dishes, discounts, and prepare food orders",
                    badgeColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 14),

                  _buildRoleCard(
                    context: context,
                    role: "Dark Store",
                    icon: "🏬",
                    title: "Dark Store Hub",
                    subtitle: "Manage grocery inventory counts, prices & dispatch supplies",
                    badgeColor: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String role,
    required String icon,
    required String title,
    required String subtitle,
    required Color badgeColor,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuthScreen(selectedRole: role),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

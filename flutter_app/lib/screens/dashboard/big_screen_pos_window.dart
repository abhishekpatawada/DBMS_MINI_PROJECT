import 'package:flutter/material.dart';
import 'big_screen_revenue_dashboard.dart';

class BigScreenPosWindowScreen extends StatelessWidget {
  final bool isRestaurant;
  final int entityId;
  final String entityName;
  final String entityLocation;

  const BigScreenPosWindowScreen({
    super.key,
    required this.isRestaurant,
    required this.entityId,
    required this.entityName,
    required this.entityLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isRestaurant ? "🍽️ $entityName - Revenue & POS" : "🏬 $entityName - Revenue & Dispatch",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: BigScreenRevenueDashboard(
        isRestaurant: isRestaurant,
        entityId: entityId,
        entityName: entityName,
        entityLocation: entityLocation,
      ),
    );
  }
}

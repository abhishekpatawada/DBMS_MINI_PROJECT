import 'package:flutter/material.dart';

class DbmsSettingsService {
  // Global simulation toggle (default: true / ON)
  static final ValueNotifier<bool> isSimulationEnabled = ValueNotifier<bool>(true);

  static void toggleSimulation() {
    isSimulationEnabled.value = !isSimulationEnabled.value;
  }

  static void setSimulation(bool enabled) {
    isSimulationEnabled.value = enabled;
  }
}

/// A compact toggle widget that can be placed in any AppBar or header.
class DbmsSimulationToggleSwitch extends StatelessWidget {
  const DbmsSimulationToggleSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DbmsSettingsService.isSimulationEnabled,
      builder: (context, isEnabled, _) {
        return Tooltip(
          message: isEnabled ? "DBMS Animation is ON (Click to Disable)" : "DBMS Animation is OFF (Click to Enable)",
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: DbmsSettingsService.toggleSimulation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isEnabled ? const Color(0xFF6366F1).withOpacity(0.15) : const Color(0xFF94A3B8).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isEnabled ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isEnabled ? "⚡" : "⏸️", style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    isEnabled ? "Animation: ON" : "Animation: OFF",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

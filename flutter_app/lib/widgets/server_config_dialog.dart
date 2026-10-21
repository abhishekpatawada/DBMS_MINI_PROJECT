import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ServerConfigDialog extends StatefulWidget {
  final VoidCallback? onSaved;

  const ServerConfigDialog({super.key, this.onSaved});

  static Future<void> show(BuildContext context, {VoidCallback? onSaved}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ServerConfigDialog(onSaved: onSaved),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late TextEditingController _urlController;
  bool _isTesting = false;
  bool? _isConnected;
  String? _statusMessage;
  int? _latencyMs;

  final String _currentLaptopIp = ApiService.defaultLaptopIp;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiService.baseUrl);
    _testCurrent();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testCurrent([String? urlToTest]) async {
    setState(() {
      _isTesting = true;
      _statusMessage = null;
    });

    final testTarget = urlToTest ?? _urlController.text.trim();
    final res = await ApiService.testConnection(testTarget);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _isConnected = res['connected'] == true;
        _statusMessage = res['message']?.toString();
        _latencyMs = res['latencyMs'] as int?;
      });
    }
  }

  void _applyPreset(String host) {
    final newUrl = "http://$host/api";
    _urlController.text = newUrl;
    _testCurrent(newUrl);
  }

  void _save() {
    ApiService.setBaseUrl(_urlController.text.trim());
    widget.onSaved?.call();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text("Connected to server: ${ApiService.baseUrl}")),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wifi_tethering, color: Color(0xFF4F46E5), size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Server Connection Settings",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "To use BiteHub on other devices (phones, tablets, laptops), connect to the host laptop's local Wi-Fi IP address instead of 'localhost'.",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 18),

            // Connection Status Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isTesting
                    ? const Color(0xFFF1F5F9)
                    : (_isConnected == true ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isTesting
                      ? const Color(0xFFE2E8F0)
                      : (_isConnected == true ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                ),
              ),
              child: Row(
                children: [
                  if (_isTesting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _isConnected == true ? Icons.check_circle : Icons.error_outline,
                      color: _isConnected == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      size: 22,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isTesting
                              ? "Testing connection..."
                              : (_isConnected == true ? "Server Online (Connected)" : "Cannot Connect to Server"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _isConnected == true ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                          ),
                        ),
                        if (_statusMessage != null)
                          Text(
                            _statusMessage!,
                            style: TextStyle(
                              fontSize: 11,
                              color: _isConnected == true ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_latencyMs != null)
                    Text(
                      "${_latencyMs}ms",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isConnected == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Preset Buttons
            const Text(
              "QUICK PRESETS (TAP TO SELECT)",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip("📱 Wi-Fi Network ($_currentLaptopIp:8000)", "$_currentLaptopIp:8000", isPrimary: true),
                _buildPresetChip("💻 This Laptop (localhost:8000)", "localhost:8000"),
                _buildPresetChip("🤖 Android Emulator (10.0.2.2:8000)", "10.0.2.2:8000"),
              ],
            ),

            const SizedBox(height: 18),

            // Input field
            const Text(
              "SERVER API URL",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: "Test URL",
                  onPressed: () => _testCurrent(),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) {
                setState(() => _isConnected = null);
              },
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.network_ping, size: 18),
                    label: const Text("Test Connection"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isTesting ? null : () => _testCurrent(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18, color: Colors.white),
                    label: const Text("Save & Connect", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, String host, {bool isPrimary = false}) {
    final isSelected = _urlController.text.contains(host);
    return ActionChip(
      avatar: isPrimary ? const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)) : null,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF334155),
        ),
      ),
      backgroundColor: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
      ),
      onPressed: () => _applyPreset(host),
    );
  }
}

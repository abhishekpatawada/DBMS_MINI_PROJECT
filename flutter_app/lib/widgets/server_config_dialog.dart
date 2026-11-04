import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'brutalist_widgets.dart';

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
        content: Text(
          "SERVER TARGET UPDATED: ${ApiService.baseUrl}",
          style: GoogleFonts.ibmPlexMono(
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
          ),
        ),
        backgroundColor: AppTheme.yellow,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppTheme.black, width: 2),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
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
        color: AppTheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        border: Border(
          top: BorderSide(color: AppTheme.black, width: 3.5),
          left: BorderSide(color: AppTheme.black, width: 3.5),
          right: BorderSide(color: AppTheme.black, width: 3.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hub_rounded,
                        color: AppTheme.black, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      "SERVER CONFIG",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Route API traffic across Wi-Fi host network or local loopback.",
              style: GoogleFonts.inter(
                color: const Color(0xFF555555),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 16),

            // Connection Status Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isTesting
                    ? AppTheme.surface
                    : (_isConnected == true ? AppTheme.yellow : AppTheme.red),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                border: Border.all(
                  color: AppTheme.black,
                  width: AppTheme.borderWidth,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.black,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_isTesting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.black,
                      ),
                    )
                  else
                    Icon(
                      _isConnected == true
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: _isConnected == true
                          ? AppTheme.black
                          : AppTheme.surface,
                      size: 24,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isTesting
                              ? "PINGING SERVER..."
                              : (_isConnected == true
                                  ? "HOST ONLINE // ACTIVE"
                                  : "CONNECTION TIMEOUT // UNREACHABLE"),
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: _isConnected == true
                                ? AppTheme.black
                                : AppTheme.surface,
                          ),
                        ),
                        if (_statusMessage != null)
                          Text(
                            _statusMessage!.toUpperCase(),
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _isConnected == true
                                  ? const Color(0xFF333333)
                                  : AppTheme.surface,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_latencyMs != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.black,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      child: Text(
                        "${_latencyMs}ms",
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.yellow,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Quick Preset Buttons
            Text(
              "PRESET NETWORKS (TAP TO APPLY)",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip("WI-FI: $_currentLaptopIp:8000",
                    "$_currentLaptopIp:8000",
                    isPrimary: true),
                _buildPresetChip("LOCALHOST: 8000", "localhost:8000"),
                _buildPresetChip("EMULATOR: 10.0.2.2:8000", "10.0.2.2:8000"),
              ],
            ),

            const SizedBox(height: 18),

            // Input field
            Text(
              "BASE API ENDPOINT",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link_rounded,
                    size: 20, color: AppTheme.black),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      size: 20, color: AppTheme.black),
                  tooltip: "Ping URL",
                  onPressed: () => _testCurrent(),
                ),
              ),
              onChanged: (_) {
                setState(() => _isConnected = null);
              },
            ),

            const SizedBox(height: 22),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: BrutalistButton.white(
                    text: "TEST",
                    icon: Icons.network_ping_rounded,
                    onPressed: _isTesting ? null : () => _testCurrent(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BrutalistButton.yellow(
                    text: "SAVE & SYNC",
                    icon: Icons.check_rounded,
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
    return GestureDetector(
      onTap: () => _applyPreset(host),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellow : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: AppTheme.black,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppTheme.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPrimary) ...[
              const Icon(Icons.star_rounded, size: 14, color: AppTheme.black),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

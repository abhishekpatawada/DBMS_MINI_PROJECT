import 'dart:async';
import 'package:flutter/material.dart';
import '../services/dbms_settings_service.dart';

enum DbmsOpType { select, insert, update, delete }

class DbmsOperationModal extends StatefulWidget {
  final String title;
  final String tableName;
  final DbmsOpType operationType;
  final String sqlStatement;
  final Map<String, dynamic> sampleColumns;
  final Future<dynamic> Function() executionTask;
  final VoidCallback? onSuccess;

  const DbmsOperationModal({
    Key? key,
    required this.title,
    required this.tableName,
    required this.operationType,
    required this.sqlStatement,
    required this.sampleColumns,
    required this.executionTask,
    this.onSuccess,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String tableName,
    required DbmsOpType operationType,
    required String sqlStatement,
    required Map<String, dynamic> sampleColumns,
    required Future<T> Function() executionTask,
    VoidCallback? onSuccess,
  }) async {
    // If simulation is globally disabled, execute immediately without dialog
    if (!DbmsSettingsService.isSimulationEnabled.value) {
      try {
        final res = await executionTask();
        if (onSuccess != null) onSuccess();
        return res;
      } catch (e) {
        rethrow;
      }
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DbmsOperationModal(
        title: title,
        tableName: tableName,
        operationType: operationType,
        sqlStatement: sqlStatement,
        sampleColumns: sampleColumns,
        executionTask: executionTask,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<DbmsOperationModal> createState() => _DbmsOperationModalState();
}

class _DbmsOperationModalState extends State<DbmsOperationModal>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0: Select Table, 1: Lock/Index, 2: Row Scan/Mutate, 3: Committed, 4: Error
  int _scanRowIndex = 0;
  String _liveLog = "Initializing transaction...";
  String? _errorMessage;
  bool _isFinished = false;
  Timer? _stepTimer;

  // Mock table rows for the visual animation
  late List<Map<String, String>> _mockRows;

  @override
  void initState() {
    super.initState();
    _mockRows = _generateMockRows();
    _startAnimationPipeline();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  List<Map<String, String>> _generateMockRows() {
    final tName = widget.tableName.toLowerCase();
    if (tName == "orders") {
      return [
        {"Order_Id": "1001", "User_Id": "1", "Status": "Delivered", "Total": "₹450.00"},
        {"Order_Id": "1002", "User_Id": "2", "Status": "Delivered", "Total": "₹160.00"},
        {"Order_Id": "1003", "User_Id": "1", "Status": "Placed", "Total": "₹320.00"},
        {"Order_Id": "1004 (NEW)", "User_Id": "${widget.sampleColumns['User_Id'] ?? '1'}", "Status": "Placed", "Total": "₹${widget.sampleColumns['Amount'] ?? '250.00'}"},
      ];
    } else if (tName == "rest_items") {
      return [
        {"Rest_Id": "1", "Item_Name": "Paneer Butter Masala", "BasePrice": "280.00", "Discount": "10%"},
        {"Rest_Id": "1", "Item_Name": "Butter Chicken", "BasePrice": "340.00", "Discount": "15%"},
        {"Rest_Id": "1", "Item_Name": "${widget.sampleColumns['Item_Name'] ?? 'All American Burger'}", "BasePrice": "${widget.sampleColumns['BasePrice'] ?? '225.00'}", "Discount": "${widget.sampleColumns['Discount'] ?? '5'}%"},
        {"Rest_Id": "2", "Item_Name": "Chicken Biryani", "BasePrice": "320.00", "Discount": "10%"},
      ];
    } else if (tName == "groceries") {
      return [
        {"Store_Id": "1", "Item_Name": "Amul Butter 500g", "Price": "275.00", "Count": "80"},
        {"Store_Id": "1", "Item_Name": "Aashirvaad Atta 5kg", "Price": "245.00", "Count": "60"},
        {"Store_Id": "1", "Item_Name": "${widget.sampleColumns['Item_Name'] ?? 'Fortune Oil 1L'}", "Price": "${widget.sampleColumns['Price'] ?? '160.00'}", "Count": "${widget.sampleColumns['Count'] ?? '45'}"},
        {"Store_Id": "2", "Item_Name": "Tata Salt 1kg", "Price": "28.00", "Count": "150"},
      ];
    } else if (tName == "payment") {
      return [
        {"Payment_Id": "501", "Order_Id": "1001", "Method": "UPI", "Amount": "₹450.00"},
        {"Payment_Id": "502", "Order_Id": "1002", "Method": "Credit Card", "Amount": "₹160.00"},
        {"Payment_Id": "503 (NEW)", "Order_Id": "${widget.sampleColumns['Order_Id'] ?? '1004'}", "Method": "${widget.sampleColumns['Method'] ?? 'UPI'}", "Amount": "₹${widget.sampleColumns['Amount'] ?? '250.00'}"},
      ];
    } else {
      return [
        {"Id": "1", "Attribute_1": "Val_A", "Attribute_2": "Val_B"},
        {"Id": "2", "Attribute_1": "Val_C", "Attribute_2": "Val_D"},
        {"Id": "3", "Attribute_1": "${widget.sampleColumns['Item_Name'] ?? 'Target Record'}", "Attribute_2": "Active"},
      ];
    }
  }

  void _startAnimationPipeline() {
    setState(() {
      _currentStep = 0;
      _liveLog = "🔍 Phase 1: Acquiring Table Lock on '${widget.tableName.toUpperCase()}' in DBMS catalog...";
    });

    // Step 1: Select Table (500ms)
    _stepTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 1;
        _liveLog = "🎯 Phase 2: Allocating transaction buffer & checking primary key constraints...";
      });

      // Step 2: Index / Buffer Allocation (500ms)
      _stepTimer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _currentStep = 2;
          _scanRowIndex = 0;
        });
        _runRowScanning();
      });
    });
  }

  void _runRowScanning() {
    if (_scanRowIndex >= _mockRows.length - 1) {
      // Execute the real API task
      _executeTask();
      return;
    }

    setState(() {
      if (widget.operationType == DbmsOpType.insert) {
        _liveLog = "📝 Phase 3: Inserting tuple into buffer page #$_scanRowIndex...";
      } else if (widget.operationType == DbmsOpType.update) {
        _liveLog = "✏️ Phase 3: Scanning rows to update tuple where condition matches (Row #$_scanRowIndex)...";
      } else if (widget.operationType == DbmsOpType.delete) {
        _liveLog = "🗑️ Phase 3: Scanning index to mark tuple for deletion (Row #$_scanRowIndex)...";
      } else {
        _liveLog = "🔎 Phase 3: Evaluating WHERE predicate on Row #$_scanRowIndex...";
      }
    });

    _stepTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _scanRowIndex++);
      _runRowScanning();
    });
  }

  Future<void> _executeTask() async {
    try {
      await widget.executionTask();
      if (!mounted) return;

      setState(() {
        _currentStep = 3;
        _isFinished = true;
        _liveLog = "🎉 COMMIT SUCCESS: Transaction committed to MySQL write-ahead log in 0.42 ms!";
      });

      // Auto close after showing success
      Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        if (widget.onSuccess != null) widget.onSuccess!();
        Navigator.of(context).pop(true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentStep = 4;
        _isFinished = true;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _liveLog = "❌ ROLLBACK: Query execution error -> $_errorMessage";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cols = _mockRows.isNotEmpty ? _mockRows.first.keys.toList() : [];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF334155)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getOpColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_getOpIcon(), style: const TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            "DBMS Live Pipeline • ${widget.tableName.toUpperCase()}",
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getOpColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _getOpColor()),
                      ),
                      child: Text(
                        _getOpLabel(),
                        style: TextStyle(color: _getOpColor(), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Live SQL Statement Box
              Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF030712),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.code_rounded, size: 14, color: Color(0xFF38BDF8)),
                        SizedBox(width: 6),
                        Text(
                          "GENERATED SQL QUERY",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.sqlStatement,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF38BDF8),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              // Animated Table Scanner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF020617),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        color: const Color(0xFF1E293B),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            ...cols.map((c) => Expanded(
                                  child: Text(
                                    c,
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      // Rows
                      ..._mockRows.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final r = entry.value;
                        final isScanning = _currentStep == 2 && _scanRowIndex == idx;
                        final isTarget = idx == _mockRows.length - 1;
                        final isCommitted = _currentStep == 3;

                        Color rowBg = Colors.transparent;
                        Color textCol = const Color(0xFFCBD5E1);

                        if (isTarget && isCommitted) {
                          rowBg = const Color(0xFF064E3B);
                          textCol = const Color(0xFF34D399);
                        } else if (isScanning) {
                          rowBg = const Color(0xFF312E81);
                          textCol = const Color(0xFFA5B4FC);
                        }

                        return Container(
                          color: rowBg,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                child: Text(
                                  isTarget && isCommitted
                                      ? "✅"
                                      : isScanning
                                          ? "👉"
                                          : "${idx + 1}",
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                ),
                              ),
                              ...cols.map((c) => Expanded(
                                    child: Text(
                                      r[c] ?? '',
                                      style: TextStyle(
                                        color: textCol,
                                        fontWeight: isTarget && isCommitted ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Live Log Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF030712),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(17)),
                ),
                child: Row(
                  children: [
                    if (!_isFinished)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                      )
                    else if (_errorMessage != null)
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16)
                    else
                      const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _liveLog,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: _errorMessage != null ? const Color(0xFFFCA5A5) : const Color(0xFFA7F3D0),
                        ),
                      ),
                    ),
                    if (_isFinished && _errorMessage != null)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Dismiss", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getOpColor() {
    switch (widget.operationType) {
      case DbmsOpType.select:
        return const Color(0xFF38BDF8);
      case DbmsOpType.insert:
        return const Color(0xFF10B981);
      case DbmsOpType.update:
        return const Color(0xFFF59E0B);
      case DbmsOpType.delete:
        return const Color(0xFFEF4444);
    }
  }

  String _getOpIcon() {
    switch (widget.operationType) {
      case DbmsOpType.select:
        return "🔍";
      case DbmsOpType.insert:
        return "➕";
      case DbmsOpType.update:
        return "✏️";
      case DbmsOpType.delete:
        return "🗑️";
    }
  }

  String _getOpLabel() {
    switch (widget.operationType) {
      case DbmsOpType.select:
        return "SELECT SCAN";
      case DbmsOpType.insert:
        return "INSERT TUPLE";
      case DbmsOpType.update:
        return "UPDATE TUPLE";
      case DbmsOpType.delete:
        return "DELETE TUPLE";
    }
  }
}

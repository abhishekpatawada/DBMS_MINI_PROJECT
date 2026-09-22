import 'dart:async';
import 'package:flutter/material.dart';

enum QueryExecutionPhase {
  idle,
  selectingTable,
  focusingColumn,
  scanningRows,
  matched,
  complete,
  failed
}

class DbmsLiveQueryVisualizer extends StatefulWidget {
  final String role;
  final String identifier;
  final bool isExecuting;
  final VoidCallback? onAnimationComplete;

  const DbmsLiveQueryVisualizer({
    Key? key,
    required this.role,
    required this.identifier,
    this.isExecuting = false,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<DbmsLiveQueryVisualizer> createState() => DbmsLiveQueryVisualizerState();
}

class DbmsLiveQueryVisualizerState extends State<DbmsLiveQueryVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  QueryExecutionPhase _currentPhase = QueryExecutionPhase.idle;
  int _currentRowIndex = -1;
  int? _matchedRowIndex;
  String _comparisonLog = "Ready for execution...";
  Timer? _animationTimer;

  // Real sample database records matching database/sample_data.sql
  List<Map<String, String>> get _tableRows {
    switch (widget.role) {
      case "User":
        return [
          {"User_Id": "1", "User_Name": "Aarav Choudhury", "User_Phone": "9810000001", "City": "Indiranagar"},
          {"User_Id": "2", "User_Name": "Vivaan Mukherjee", "User_Phone": "9810000002", "City": "Koramangala"},
          {"User_Id": "3", "User_Name": "Aditya Kulkarni", "User_Phone": "9810000003", "City": "Whitefield"},
          {"User_Id": "4", "User_Name": "Vihaan Bhat", "User_Phone": "9810000004", "City": "HSR Layout"},
          {"User_Id": "5", "User_Name": "Arjun Shetty", "User_Phone": "9810000005", "City": "Jayanagar"},
          {"User_Id": "6", "User_Name": "Sai Naidu", "User_Phone": "9810000006", "City": "Bandra West"},
        ];
      case "Delivery Agent":
        return [
          {"Agent_Id": "1", "Agent_Name": "Aarav Sharma", "Agent_Phone": "9876500001", "VehicleNO": "KA-08-AA-1001"},
          {"Agent_Id": "2", "Agent_Name": "Vivaan Patel", "Agent_Phone": "9876500002", "VehicleNO": "MH-15-BB-1002"},
          {"Agent_Id": "3", "Agent_Name": "Aditya Verma", "Agent_Phone": "9876500003", "VehicleNO": "DL-22-CC-1003"},
          {"Agent_Id": "4", "Agent_Name": "Vihaan Reddy", "Agent_Phone": "9876500004", "VehicleNO": "TN-29-DD-1004"},
          {"Agent_Id": "5", "Agent_Name": "Arjun Nair", "Agent_Phone": "9876500005", "VehicleNO": "TS-36-EE-1005"},
          {"Agent_Id": "6", "Agent_Name": "Sai Iyer", "Agent_Phone": "9876500006", "VehicleNO": "KA-43-FF-1006"},
        ];
      case "Restaurant":
        return [
          {"Rest_Id": "1", "RName": "Royal Bistro 1", "RPhone": "0800000001", "RLocation": "Indiranagar"},
          {"Rest_Id": "2", "RName": "Spice Diner 1", "RPhone": "0800000002", "RLocation": "Koramangala"},
          {"Rest_Id": "3", "RName": "Taste of Treats 1", "RPhone": "0800000003", "RLocation": "Whitefield"},
          {"Rest_Id": "4", "RName": "The Golden Grill 1", "RPhone": "0800000004", "RLocation": "HSR Layout"},
          {"Rest_Id": "5", "RName": "Urban Court 1", "RPhone": "0800000005", "RLocation": "Jayanagar"},
          {"Rest_Id": "6", "RName": "Flavors of Hub 1", "RPhone": "0800000006", "RLocation": "Bandra West"},
        ];
      default:
        // Dark Store
        return [
          {"Store_Id": "1", "DS_Street": "Plot 20, MG Rd", "DS_Area": "Indiranagar", "DS_Pincode": "560038"},
          {"Store_Id": "2", "DS_Street": "Plot 39, Residency Rd", "DS_Area": "Koramangala", "DS_Pincode": "560034"},
          {"Store_Id": "3", "DS_Street": "Plot 58, Linking Rd", "DS_Area": "Whitefield", "DS_Pincode": "560066"},
          {"Store_Id": "4", "DS_Street": "Plot 77, Anna Salai", "DS_Area": "HSR Layout", "DS_Pincode": "560102"},
          {"Store_Id": "5", "DS_Street": "Plot 96, Park Avenue", "DS_Area": "Jayanagar", "DS_Pincode": "560041"},
          {"Store_Id": "6", "DS_Street": "Plot 115, Station Rd", "DS_Area": "Bandra West", "DS_Pincode": "400050"},
        ];
    }
  }

  String get _tableName {
    switch (widget.role) {
      case "User":
        return "users";
      case "Delivery Agent":
        return "delivery_agent";
      case "Restaurant":
        return "restaurant";
      default:
        return "dark_store";
    }
  }

  String get _filterColumn {
    switch (widget.role) {
      case "User":
        return "User_Phone";
      case "Delivery Agent":
        return "Agent_Phone";
      case "Restaurant":
        return "RPhone";
      default:
        return "Store_Id";
    }
  }

  String get _currentSqlQuery {
    final input = widget.identifier.trim();
    final val = input.isEmpty ? "<ENTER_VALUE>" : "'$input'";
    return """SELECT *
FROM $_tableName
WHERE $_filterColumn = $val
LIMIT 1;""";
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }

  void startExecutionAnimation({VoidCallback? onDone}) {
    _animationTimer?.cancel();
    final userInput = widget.identifier.trim();

    setState(() {
      _currentPhase = QueryExecutionPhase.selectingTable;
      _currentRowIndex = -1;
      _matchedRowIndex = null;
      _comparisonLog = "🔍 Phase 1: Identifying target table '$_tableName' in database catalog...";
    });

    // Step 1: Select Table (600ms)
    _animationTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _currentPhase = QueryExecutionPhase.focusingColumn;
        _comparisonLog = "🎯 Phase 2: Index lookup on WHERE clause column '$_filterColumn' = '$userInput'...";
      });

      // Step 2: Focus Column (600ms)
      _animationTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _currentPhase = QueryExecutionPhase.scanningRows;
          _currentRowIndex = 0;
          _stepScanRow(0, userInput, onDone);
        });
      });
    });
  }

  void _stepScanRow(int index, String userInput, VoidCallback? onDone) {
    final rows = _tableRows;

    if (index >= rows.length) {
      // Reached end of table without finding a match
      setState(() {
        _currentPhase = QueryExecutionPhase.failed;
        _currentRowIndex = -1;
        _matchedRowIndex = null;
        _comparisonLog = "❌ SCAN COMPLETE: 0 tuples matched WHERE $_filterColumn = '$userInput' (Record Not Found).";
      });
      if (onDone != null) onDone();
      if (widget.onAnimationComplete != null) widget.onAnimationComplete!();
      return;
    }

    final row = rows[index];
    final rowVal = (row[_filterColumn] ?? "").trim();
    // Genuine comparison between actual row value and user input
    final bool isMatch = userInput.isNotEmpty && (rowVal.toLowerCase() == userInput.toLowerCase());

    setState(() {
      _currentRowIndex = index;
      if (isMatch) {
        _matchedRowIndex = index;
        _currentPhase = QueryExecutionPhase.matched;
        _comparisonLog = "✅ Tuple #$index Match: ('$rowVal' == '$userInput') -> TRUE! Fetching record attributes.";
      } else {
        _comparisonLog = "❌ Tuple #$index Check: ('$rowVal' == '$userInput') -> FALSE. Advancing pointer.";
      }
    });

    _animationTimer = Timer(Duration(milliseconds: isMatch ? 850 : 500), () {
      if (!mounted) return;
      if (isMatch) {
        setState(() {
          _currentPhase = QueryExecutionPhase.complete;
          _comparisonLog = "🎉 SUCCESS: 1 tuple matched in table '$_tableName' (0.32 ms). Authenticating session...";
        });
        if (onDone != null) onDone();
        if (widget.onAnimationComplete != null) widget.onAnimationComplete!();
      } else {
        _stepScanRow(index + 1, userInput, onDone);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Visualizer Top Bar
          _buildTopBar(),

          // SQL Query Display Box
          _buildSqlCodeBox(),

          // Progress & Step Pipeline
          _buildStepPipeline(),

          // Animated Table & Row Comparison Engine
          Expanded(
            child: _buildAnimatedTableScanner(),
          ),

          // Live Execution Log Footer
          _buildExecutionFooter(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text("⚡", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DBMS Engine Execution Stream",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                "Live Query Generation • Table Selection • Row-by-Row Scan",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor().withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSqlCodeBox() {
    final inputVal = widget.identifier.trim();
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _currentPhase == QueryExecutionPhase.idle
              ? const Color(0xFF334155)
              : const Color(0xFF6366F1),
          width: _currentPhase != QueryExecutionPhase.idle ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code_rounded, size: 14, color: Color(0xFF38BDF8)),
              const SizedBox(width: 6),
              const Text(
                "LIVE GENERATED SQL STATEMENT",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                "INPUT: ${inputVal.isEmpty ? '(Empty)' : inputVal}",
                style: TextStyle(
                  color: inputVal.isEmpty ? const Color(0xFF64748B) : const Color(0xFFF59E0B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentSqlQuery,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFF38BDF8),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPipeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _buildStepChip(
            stepNumber: "1",
            label: "Table Select",
            isActive: _currentPhase == QueryExecutionPhase.selectingTable,
            isDone: _currentPhase.index > QueryExecutionPhase.selectingTable.index && _currentPhase != QueryExecutionPhase.failed,
          ),
          const SizedBox(width: 6),
          _buildStepChip(
            stepNumber: "2",
            label: "Column Focus",
            isActive: _currentPhase == QueryExecutionPhase.focusingColumn,
            isDone: _currentPhase.index > QueryExecutionPhase.focusingColumn.index && _currentPhase != QueryExecutionPhase.failed,
          ),
          const SizedBox(width: 6),
          _buildStepChip(
            stepNumber: "3",
            label: "Row Scan",
            isActive: _currentPhase == QueryExecutionPhase.scanningRows,
            isDone: _currentPhase.index > QueryExecutionPhase.scanningRows.index && _currentPhase != QueryExecutionPhase.failed,
          ),
          const SizedBox(width: 6),
          _buildStepChip(
            stepNumber: "4",
            label: _currentPhase == QueryExecutionPhase.failed ? "Not Found" : "Match & Return",
            isActive: _currentPhase == QueryExecutionPhase.matched,
            isDone: _currentPhase == QueryExecutionPhase.complete,
            isError: _currentPhase == QueryExecutionPhase.failed,
          ),
        ],
      ),
    );
  }

  Widget _buildStepChip({
    required String stepNumber,
    required String label,
    required bool isActive,
    required bool isDone,
    bool isError = false,
  }) {
    Color bg = const Color(0xFF1E293B);
    Color textCol = const Color(0xFF64748B);
    Color borderCol = const Color(0xFF334155);

    if (isError) {
      bg = const Color(0xFF7F1D1D);
      textCol = const Color(0xFFFCA5A5);
      borderCol = const Color(0xFFEF4444);
    } else if (isDone) {
      bg = const Color(0xFF064E3B);
      textCol = const Color(0xFF34D399);
      borderCol = const Color(0xFF059669);
    } else if (isActive) {
      bg = const Color(0xFF312E81);
      textCol = const Color(0xFF818CF8);
      borderCol = const Color(0xFF6366F1);
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderCol),
        ),
        child: Column(
          children: [
            Text(
              isError ? "✕" : isDone ? "✓" : stepNumber,
              style: TextStyle(
                color: textCol,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(color: textCol, fontSize: 9, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTableScanner() {
    final rows = _tableRows;
    if (rows.isEmpty) return const SizedBox();

    final cols = rows.first.keys.toList();
    final bool isTableHighlighted = _currentPhase != QueryExecutionPhase.idle;
    final userInput = widget.identifier.trim();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isTableHighlighted ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
            width: isTableHighlighted ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
              ),
              child: Row(
                children: [
                  Text(
                    "TABLE: ${_tableName.toUpperCase()}",
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _currentPhase == QueryExecutionPhase.scanningRows
                        ? "SCANNING ROW ${_currentRowIndex + 1}/${rows.length}"
                        : _matchedRowIndex != null
                            ? "MATCH AT ROW ${_matchedRowIndex! + 1}"
                            : "READY",
                    style: TextStyle(
                      color: _matchedRowIndex != null ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Column Header Row
            Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(width: 24), // Space for pointer
                  ...cols.map((c) {
                    final isFilterCol = c == _filterColumn;
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isFilterCol && _currentPhase != QueryExecutionPhase.idle
                              ? const Color(0xFFF59E0B).withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: isFilterCol && _currentPhase != QueryExecutionPhase.idle
                              ? Border.all(color: const Color(0xFFF59E0B), width: 1)
                              : null,
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            color: isFilterCol ? const Color(0xFFFBBF24) : const Color(0xFF94A3B8),
                            fontWeight: isFilterCol ? FontWeight.bold : FontWeight.w600,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            // Rows List with Animated Scanning Pointer
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF1E293B)),
                itemBuilder: (context, idx) {
                  final row = rows[idx];
                  final isCurrentScan = _currentRowIndex == idx && _currentPhase == QueryExecutionPhase.scanningRows;
                  final isMatched = _matchedRowIndex == idx &&
                      (_currentPhase == QueryExecutionPhase.matched || _currentPhase == QueryExecutionPhase.complete);

                  Color rowBg = Colors.transparent;
                  Color textColor = const Color(0xFFCBD5E1);

                  if (isMatched) {
                    rowBg = const Color(0xFF064E3B);
                    textColor = const Color(0xFF6EE7B7);
                  } else if (isCurrentScan) {
                    rowBg = const Color(0xFF312E81);
                    textColor = const Color(0xFFA5B4FC);
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: rowBg,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    child: Row(
                      children: [
                        // Pointer or verdict icon
                        SizedBox(
                          width: 24,
                          child: Center(
                            child: isMatched
                                ? const Text("✅", style: TextStyle(fontSize: 12))
                                : isCurrentScan
                                    ? const Text("👉", style: TextStyle(fontSize: 12))
                                    : Text("${idx + 1}", style: const TextStyle(color: Color(0xFF475569), fontSize: 9)),
                          ),
                        ),
                        ...cols.map((c) {
                          final isFilterCol = c == _filterColumn;
                          final rowVal = row[c] ?? '';
                          final isValMatch = isFilterCol && isMatched;

                          return Expanded(
                            child: Text(
                              rowVal,
                              style: TextStyle(
                                color: isValMatch
                                    ? const Color(0xFF34D399)
                                    : isFilterCol
                                        ? (userInput == rowVal ? const Color(0xFF34D399) : const Color(0xFFFBBF24))
                                        : textColor,
                                fontWeight: isFilterCol || isMatched ? FontWeight.bold : FontWeight.normal,
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF030712),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Icon(
            _currentPhase == QueryExecutionPhase.failed
                ? Icons.error_outline_rounded
                : Icons.terminal_rounded,
            size: 14,
            color: _currentPhase == QueryExecutionPhase.failed
                ? const Color(0xFFEF4444)
                : const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _comparisonLog,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: _currentPhase == QueryExecutionPhase.failed
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFA7F3D0),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_currentPhase) {
      case QueryExecutionPhase.idle:
        return const Color(0xFF64748B);
      case QueryExecutionPhase.selectingTable:
      case QueryExecutionPhase.focusingColumn:
        return const Color(0xFF6366F1);
      case QueryExecutionPhase.scanningRows:
        return const Color(0xFFF59E0B);
      case QueryExecutionPhase.matched:
      case QueryExecutionPhase.complete:
        return const Color(0xFF10B981);
      case QueryExecutionPhase.failed:
        return const Color(0xFFEF4444);
    }
  }

  String _getStatusText() {
    switch (_currentPhase) {
      case QueryExecutionPhase.idle:
        return "IDLE";
      case QueryExecutionPhase.selectingTable:
        return "TABLE SELECT";
      case QueryExecutionPhase.focusingColumn:
        return "COLUMN FOCUS";
      case QueryExecutionPhase.scanningRows:
        return "SCANNING TUPLES";
      case QueryExecutionPhase.matched:
        return "TUPLE MATCHED";
      case QueryExecutionPhase.complete:
        return "SUCCESS";
      case QueryExecutionPhase.failed:
        return "NOT FOUND (0 ROWS)";
    }
  }
}

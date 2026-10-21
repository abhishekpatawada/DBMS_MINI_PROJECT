import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

class SqlVisualizerScreen extends StatefulWidget {
  const SqlVisualizerScreen({super.key});

  @override
  State<SqlVisualizerScreen> createState() => _SqlVisualizerScreenState();
}

class _SqlVisualizerScreenState extends State<SqlVisualizerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _sqlController = TextEditingController();

  bool _isLoadingSchema = true;
  bool _isExecuting = false;
  String? _schemaError;

  Map<String, dynamic>? _schemaData;
  List<dynamic> _presets = [];
  Map<String, dynamic>? _executionResult;
  List<Map<String, dynamic>> _history = [];

  // Active highlights
  Set<String> _highlightedTables = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sqlController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingSchema = true;
      _schemaError = null;
    });

    try {
      final schema = await ApiService.getSchemaMetadata();
      final presets = await ApiService.getPresetQueries();

      setState(() {
        _schemaData = schema;
        _presets = presets;
        _isLoadingSchema = false;

        // Load first preset query by default
        if (_presets.isNotEmpty && _sqlController.text.trim().isEmpty) {
          _sqlController.text = _presets[0]['sql'] ?? '';
          _detectHighlightedTables(_sqlController.text);
        }
      });
    } catch (e) {
      setState(() {
        _schemaError = e.toString();
        _isLoadingSchema = false;
      });
    }
  }

  void _detectHighlightedTables(String sql) {
    final clean = sql.toLowerCase();
    final allKnown = [
      "users", "delivery_agent", "restaurant", "rest_items", "dark_store",
      "groceries", "orders", "order_item", "order_grocery", "payment"
    ];

    final found = <String>{};
    for (var t in allKnown) {
      if (clean.contains(t)) {
        found.add(t);
      }
    }

    setState(() {
      _highlightedTables = found;
    });
  }

  Future<void> _executeQuery() async {
    final query = _sqlController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a SQL query to execute")),
      );
      return;
    }

    setState(() {
      _isExecuting = true;
    });

    try {
      final res = await ApiService.executeSql(query);

      setState(() {
        _executionResult = res;
        _isExecuting = false;

        // Update highlighted tables from analysis
        if (res['analysis'] != null && res['analysis']['touched_tables'] != null) {
          final List touched = res['analysis']['touched_tables'];
          _highlightedTables = touched.map((e) => e.toString().toLowerCase()).toSet();
        }

        // Add to history
        _history.insert(0, {
          'query': query,
          'timestamp': DateTime.now().toIso8601String(),
          'success': res['success'] == true,
          'exec_time': res['execution_time_ms'] ?? 0,
          'row_count': res['row_count'] ?? 0,
        });

        // Switch to Results tab automatically on success
        if (res['success'] == true && _tabController.index == 0) {
          _tabController.animateTo(1);
        }
      });
    } catch (e) {
      setState(() {
        _executionResult = {
          'success': false,
          'error': e.toString(),
          'columns': [],
          'rows': [],
          'row_count': 0,
          'execution_time_ms': 0,
        };
        _isExecuting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text("⚡", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SQL Visualizer & DBMS Workbench",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                Text(
                  "Interactive Schema Graph • Real-Time Query Runner • Table Animations",
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Schema",
            onPressed: _loadInitialData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingSchema
          ? const Center(child: CircularProgressIndicator())
          : _schemaError != null
              ? _buildErrorView()
              : Row(
                  children: [
                    // Left: SQL Editor & Controls (40% on wide screen)
                    Expanded(
                      flex: 4,
                      child: _buildEditorPanel(),
                    ),
                    const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                    // Right: Tabs (Schema Visualizer, Results, Analysis, History)
                    Expanded(
                      flex: 6,
                      child: _buildVisualizationPanel(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 48),
            const SizedBox(height: 16),
            const Text("Database Connection Error", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_schemaError ?? "Unknown error", textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry Connection"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preset Query Selector
          Row(
            children: [
              const Icon(Icons.bookmarks_outlined, size: 18, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              const Text("Preset Query:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
              const Spacer(),
              if (_presets.isNotEmpty)
                DropdownButton<String>(
                  value: null,
                  hint: const Text("Load Example...", style: TextStyle(fontSize: 12)),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  items: _presets.map<DropdownMenuItem<String>>((p) {
                    return DropdownMenuItem<String>(
                      value: p['sql'],
                      child: Text(p['title'] ?? 'Preset', style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _sqlController.text = val;
                        _detectHighlightedTables(val);
                      });
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Code Editor Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _sqlController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFF38BDF8),
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter your SQL query here (e.g. SELECT * FROM orders;)",
                  hintStyle: TextStyle(color: Color(0xFF64748B), fontFamily: 'monospace', fontSize: 13),
                ),
                onChanged: _detectHighlightedTables,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action Toolbar
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _sqlController.clear();
                  setState(() => _highlightedTables.clear());
                },
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text("Clear"),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _sqlController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Query copied to clipboard!")),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text("Copy"),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isExecuting ? null : _executeQuery,
                icon: _isExecuting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.play_arrow_rounded, size: 20),
                label: Text(_isExecuting ? "Running..." : "Run Query"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizationPanel() {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF6366F1),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF6366F1),
            tabs: [
              Tab(
                icon: const Icon(Icons.hub_outlined, size: 18),
                text: "Schema Graph (${_schemaData?['tables']?.length ?? 10} Tables)",
              ),
              Tab(
                icon: const Icon(Icons.table_chart_outlined, size: 18),
                text: "Query Results",
              ),
              Tab(
                icon: const Icon(Icons.analytics_outlined, size: 18),
                text: "Query Analysis",
              ),
              Tab(
                icon: const Icon(Icons.history_rounded, size: 18),
                text: "History (${_history.length})",
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSchemaGraphTab(),
              _buildQueryResultsTab(),
              _buildQueryAnalysisTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchemaGraphTab() {
    final tables = (_schemaData?['tables'] as List?) ?? [];
    final relationships = (_schemaData?['relationships'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF4F46E5), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _highlightedTables.isEmpty
                        ? "Run a query or load a preset above to see accessed tables glow with live highlights."
                        : "Active Query accesses: ${_highlightedTables.map((t) => t.toUpperCase()).join(', ')}",
                    style: const TextStyle(fontSize: 13, color: Color(0xFF3730A3), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Table Grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: tables.map<Widget>((t) => _buildTableCard(t)).toList(),
          ),
          const SizedBox(height: 24),

          // Foreign Key Relationships
          const Text(
            "🔗 Foreign Key Relationships",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          _buildRelationshipsCard(relationships),
        ],
      ),
    );
  }

  Widget _buildTableCard(dynamic table) {
    final String tableName = table['table_name'] ?? '';
    final String title = table['title'] ?? tableName;
    final String icon = table['icon'] ?? '📄';
    final int rowCount = table['row_count'] ?? 0;
    final List cols = table['columns'] ?? [];

    final bool isHighlighted = _highlightedTables.contains(tableName.toLowerCase());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 290,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
          width: isHighlighted ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? const Color(0xFF10B981).withOpacity(0.25)
                : Colors.black.withOpacity(0.04),
            blurRadius: isHighlighted ? 12 : 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tableName.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isHighlighted ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isHighlighted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$rowCount rows",
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Columns List
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cols.map<Widget>((c) {
                final String colName = c['name'] ?? '';
                final String colType = c['type'] ?? '';
                final bool isPk = c['is_primary_key'] == true;
                final bool isFk = c['is_foreign_key'] == true;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      if (isPk)
                        const Text("🔑 ", style: TextStyle(fontSize: 11))
                      else if (isFk)
                        const Text("🔗 ", style: TextStyle(fontSize: 11))
                      else
                        const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          colName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isPk ? FontWeight.bold : FontWeight.normal,
                            color: isPk ? const Color(0xFF0F172A) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      Text(
                        colType.toLowerCase(),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipsCard(List relationships) {
    if (relationships.isEmpty) {
      return const Text("No foreign key constraints defined.", style: TextStyle(color: Color(0xFF94A3B8)));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: relationships.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, idx) {
          final r = relationships[idx];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.arrow_right_alt_rounded, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Text(
                  "${r['from_table']}.${r['from_column']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                ),
                const Text("  REFERENCES  ", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                Text(
                  "${r['to_table']}.${r['to_column']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4F46E5)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQueryResultsTab() {
    if (_executionResult == null) {
      return const Center(
        child: Text("Run a query using the editor on the left to see results here.", style: TextStyle(color: Color(0xFF94A3B8))),
      );
    }

    final bool success = _executionResult!['success'] == true;
    final String? error = _executionResult!['error'];
    final List cols = _executionResult!['columns'] ?? [];
    final List rows = _executionResult!['rows'] ?? [];
    final num execTime = _executionResult!['execution_time_ms'] ?? 0;
    final int rowCount = _executionResult!['row_count'] ?? 0;

    if (!success) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDA4AF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFE11D48)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("SQL Execution Failed", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9F1239))),
                    const SizedBox(height: 6),
                    Text(error ?? "An unexpected error occurred.", style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF881337))),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text("⚡ $execTime ms", style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Text("📊 $rowCount row(s)", style: const TextStyle(color: Color(0xFF3730A3), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Data Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: rows.isEmpty
                  ? const Center(child: Text("Query executed successfully. 0 rows returned.", style: TextStyle(color: Color(0xFF94A3B8))))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                          columns: cols.map<DataColumn>((c) {
                            return DataColumn(
                              label: Text(
                                c.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                              ),
                            );
                          }).toList(),
                          rows: rows.map<DataRow>((r) {
                            return DataRow(
                              cells: cols.map<DataCell>((c) {
                                final val = r[c];
                                return DataCell(
                                  Text(
                                    val?.toString() ?? 'NULL',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: val == null ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                                      fontStyle: val == null ? FontStyle.italic : FontStyle.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryAnalysisTab() {
    final analysis = _executionResult?['analysis'];
    if (analysis == null) {
      return const Center(child: Text("Execute a query to inspect syntax breakdown and access pattern.", style: TextStyle(color: Color(0xFF94A3B8))));
    }

    final String qType = analysis['query_type'] ?? 'SQL';
    final List touched = analysis['touched_tables'] ?? [];
    final bool hasJoin = analysis['has_join'] == true;
    final bool hasSubquery = analysis['has_subquery'] == true;
    final bool hasGroupBy = analysis['has_group_by'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard("Operation Type", qType, Icons.category_rounded, const Color(0xFF6366F1)),
          const SizedBox(height: 14),
          _buildAnalysisCard(
            "Referenced Tables (${touched.length})",
            touched.isEmpty ? "None detected" : touched.map((e) => e.toString().toUpperCase()).join(", "),
            Icons.table_chart_rounded,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 14),
          _buildAnalysisCard(
            "Complex SQL Features",
            "Multi-table JOIN: ${hasJoin ? 'Yes' : 'No'}  •  GROUP BY Aggregation: ${hasGroupBy ? 'Yes' : 'No'}  •  Subqueries: ${hasSubquery ? 'Yes' : 'No'}",
            Icons.auto_awesome_rounded,
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const Center(child: Text("No queries executed in this session.", style: TextStyle(color: Color(0xFF94A3B8))));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = _history[idx];
        return Card(
          child: ListTile(
            leading: Icon(
              item['success'] == true ? Icons.check_circle_outline : Icons.error_outline,
              color: item['success'] == true ? const Color(0xFF10B981) : const Color(0xFFE11D48),
            ),
            title: Text(
              item['query'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            subtitle: Text(
              "Executed in ${item['exec_time']} ms • ${item['row_count']} row(s)",
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow_rounded, color: Color(0xFF6366F1)),
              tooltip: "Load & Run Again",
              onPressed: () {
                _sqlController.text = item['query'];
                _detectHighlightedTables(item['query']);
                _executeQuery();
              },
            ),
          ),
        );
      },
    );
  }
}

"""
Query Analyzer & SQL Executor: Analyzes queries, extracts referenced tables/columns,
and executes SQL statements with timing and safety checks.
"""
import re
import time
from backend.database import get_db_connection

# Known tables in the database (both lower and upper for robust matching)
KNOWN_TABLES = [
    "users", "delivery_agent", "restaurant", "rest_items", "dark_store",
    "groceries", "orders", "order_item", "order_grocery", "payment"
]


def detect_tables_in_query(query: str) -> list[str]:
    """Extract table names referenced in an SQL query."""
    clean_query = re.sub(r'--.*$', '', query, flags=re.MULTILINE)
    clean_query = re.sub(r'/\*.*?\*/', '', clean_query, flags=re.DOTALL)
    
    found_tables = set()
    
    # 1. Regex patterns for SQL table locations
    patterns = [
        r'\bFROM\s+([`\w]+)',
        r'\bJOIN\s+([`\w]+)',
        r'\bUPDATE\s+([`\w]+)',
        r'\bINTO\s+([`\w]+)',
        r'\bTABLE\s+([`\w]+)'
    ]
    
    for pattern in patterns:
        matches = re.findall(pattern, clean_query, re.IGNORECASE)
        for match in matches:
            t = match.strip('`').lower()
            if t in KNOWN_TABLES:
                found_tables.add(t)

    # 2. Additional scan for any known table mentioned in the query
    for table in KNOWN_TABLES:
        if re.search(r'\b' + re.escape(table) + r'\b', clean_query, re.IGNORECASE):
            found_tables.add(table)
            
    return sorted(list(found_tables))


def detect_query_type(query: str) -> str:
    """Classify the type of SQL query."""
    clean = query.strip().upper()
    if clean.startswith("SELECT"):
        if "JOIN" in clean:
            return "SELECT (Multi-Table JOIN)"
        elif "GROUP BY" in clean or "COUNT(" in clean or "SUM(" in clean or "AVG(" in clean:
            return "SELECT (Aggregate Query)"
        return "SELECT (Read Query)"
    elif clean.startswith("INSERT"):
        return "INSERT (Create Record)"
    elif clean.startswith("UPDATE"):
        return "UPDATE (Modify Record)"
    elif clean.startswith("DELETE"):
        return "DELETE (Remove Record)"
    elif clean.startswith("EXPLAIN"):
        return "EXPLAIN (Query Plan)"
    elif clean.startswith("SHOW") or clean.startswith("DESCRIBE"):
        return "METADATA (Schema Inspection)"
    return "CUSTOM SQL"


def analyze_sql_query(query: str) -> dict:
    """Analyze SQL query syntax and detect referenced entities."""
    touched_tables = detect_tables_in_query(query)
    q_type = detect_query_type(query)
    has_join = "JOIN" in query.upper()
    has_subquery = bool(re.search(r'\(\s*SELECT\b', query, re.IGNORECASE))
    has_group_by = "GROUP BY" in query.upper()

    return {
        "query": query,
        "query_type": q_type,
        "touched_tables": touched_tables,
        "has_join": has_join,
        "has_subquery": has_subquery,
        "has_group_by": has_group_by,
        "table_count": len(touched_tables)
    }


def execute_sql_workbench(query: str, max_rows: int = 100) -> dict:
    """
    Execute a query directly for the visualizer workbench.
    Measures execution time in ms, captures column names and rows safely.
    """
    analysis = analyze_sql_query(query)
    conn = get_db_connection()
    if not conn:
        return {
            "success": False,
            "error": "Failed to connect to MySQL database",
            "execution_time_ms": 0,
            "columns": [],
            "rows": [],
            "row_count": 0,
            "analysis": analysis
        }

    start_time = time.perf_counter()
    try:
        cursor = conn.cursor(dictionary=True)
        # Execute query
        cursor.execute(query)
        
        # Check if query returned rows (e.g. SELECT / SHOW / EXPLAIN)
        if cursor.description:
            columns = [desc[0] for desc in cursor.description]
            raw_rows = cursor.fetchmany(max_rows)
            # Format row values cleanly (convert datetime/decimal to str/float if needed)
            formatted_rows = []
            for r in raw_rows:
                row_dict = {}
                for col in columns:
                    val = r.get(col)
                    if val is None:
                        row_dict[col] = "NULL"
                    elif hasattr(val, "isoformat"):
                        row_dict[col] = val.isoformat()
                    elif hasattr(val, "__float__") and not isinstance(val, (int, float, bool)):
                        row_dict[col] = float(val)
                    else:
                        row_dict[col] = val
                formatted_rows.append(row_dict)
            
            end_time = time.perf_counter()
            exec_time_ms = round((end_time - start_time) * 1000, 2)
            
            return {
                "success": True,
                "columns": columns,
                "rows": formatted_rows,
                "row_count": len(formatted_rows),
                "is_truncated": len(formatted_rows) >= max_rows,
                "execution_time_ms": exec_time_ms,
                "analysis": analysis,
                "message": f"Successfully fetched {len(formatted_rows)} rows in {exec_time_ms} ms."
            }
        else:
            # INSERT / UPDATE / DELETE statement
            conn.commit()
            affected = cursor.rowcount
            end_time = time.perf_counter()
            exec_time_ms = round((end_time - start_time) * 1000, 2)
            
            return {
                "success": True,
                "columns": ["Affected Rows"],
                "rows": [{"Affected Rows": affected}],
                "row_count": affected,
                "is_truncated": False,
                "execution_time_ms": exec_time_ms,
                "analysis": analysis,
                "message": f"Query executed successfully. {affected} row(s) affected in {exec_time_ms} ms."
            }

    except Exception as e:
        end_time = time.perf_counter()
        exec_time_ms = round((end_time - start_time) * 1000, 2)
        conn.rollback()
        return {
            "success": False,
            "error": str(e),
            "columns": [],
            "rows": [],
            "row_count": 0,
            "execution_time_ms": exec_time_ms,
            "analysis": analysis,
            "message": f"Execution Error: {str(e)}"
        }
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

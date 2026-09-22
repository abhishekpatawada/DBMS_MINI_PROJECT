"""
Schema Inspector: Fetches full relational schema, columns, primary keys,
foreign keys, row counts, and relationships directly from MySQL.
"""
from backend.database import get_db_connection
from backend.config import DB_NAME

ENTITY_METADATA = {
    "users": {
        "title": "Users (Customers)",
        "icon": "👤",
        "category": "Actor",
        "description": "Registered system customers who place food & grocery orders."
    },
    "delivery_agent": {
        "title": "Delivery Agent",
        "icon": "🛵",
        "category": "Actor",
        "description": "Courier riders assigned to deliver restaurant & grocery orders."
    },
    "restaurant": {
        "title": "Restaurant",
        "icon": "🏪",
        "category": "Partner",
        "description": "Food partner establishments offering diverse cuisine menus."
    },
    "rest_items": {
        "title": "Restaurant Items",
        "icon": "🍔",
        "category": "Menu Catalog",
        "description": "Menu items linked to restaurants via composite key (Rest_Id, Item_Name)."
    },
    "dark_store": {
        "title": "Dark Store Hub",
        "icon": "🏬",
        "category": "Fulfillment",
        "description": "Micro-warehouses storing quick-commerce groceries."
    },
    "groceries": {
        "title": "Groceries (Weak Entity)",
        "icon": "🛒",
        "category": "Inventory Catalog",
        "description": "Weak entity identifying stock at a dark store via (Store_Id, Item_Name)."
    },
    "orders": {
        "title": "Orders",
        "icon": "📦",
        "category": "Transaction Core",
        "description": "Central order entity linking users, agents, restaurants, or dark stores."
    },
    "order_item": {
        "title": "Order Items (M:N)",
        "icon": "📋",
        "category": "Relationship Junction",
        "description": "Associates restaurant food items with orders along with food quantity."
    },
    "order_grocery": {
        "title": "Order Grocery (M:N)",
        "icon": "🛍️",
        "category": "Relationship Junction",
        "description": "Associates dark store groceries with orders along with quantities."
    },
    "payment": {
        "title": "Payment (1:1)",
        "icon": "💳",
        "category": "Transaction Core",
        "description": "1:1 payment transaction record corresponding to an order."
    }
}


def get_schema_metadata() -> dict:
    """Fetch complete database schema including tables, columns, keys, and foreign relationships."""
    conn = get_db_connection()
    if not conn:
        return {"success": False, "error": "Database connection failed", "tables": [], "relationships": []}

    try:
        cursor = conn.cursor(dictionary=True)

        # 1. Fetch tables & estimated row counts
        tables_query = """
            SELECT 
                TABLE_NAME AS table_name,
                TABLE_ROWS AS estimated_rows,
                TABLE_COMMENT AS table_comment
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = %s
            ORDER BY TABLE_NAME;
        """
        cursor.execute(tables_query, (DB_NAME,))
        raw_tables = cursor.fetchall()

        # 2. Fetch column definitions
        columns_query = """
            SELECT 
                TABLE_NAME AS table_name,
                COLUMN_NAME AS column_name,
                COLUMN_TYPE AS column_type,
                DATA_TYPE AS data_type,
                IS_NULLABLE AS is_nullable,
                COLUMN_KEY AS column_key,
                COLUMN_DEFAULT AS column_default,
                EXTRA AS extra
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = %s
            ORDER BY TABLE_NAME, ORDINAL_POSITION;
        """
        cursor.execute(columns_query, (DB_NAME,))
        raw_columns = cursor.fetchall()

        # 3. Fetch foreign key relationships
        fk_query = """
            SELECT 
                k.TABLE_NAME AS from_table,
                k.COLUMN_NAME AS from_column,
                k.REFERENCED_TABLE_NAME AS to_table,
                k.REFERENCED_COLUMN_NAME AS to_column,
                k.CONSTRAINT_NAME AS constraint_name
            FROM information_schema.KEY_COLUMN_USAGE k
            WHERE k.TABLE_SCHEMA = %s
              AND k.REFERENCED_TABLE_NAME IS NOT NULL;
        """
        cursor.execute(fk_query, (DB_NAME,))
        relationships = cursor.fetchall()

        # Group columns by table
        columns_by_table = {}
        for col in raw_columns:
            t_name = col["table_name"].lower()
            if t_name not in columns_by_table:
                columns_by_table[t_name] = []
            
            is_pk = col["column_key"] == "PRI"
            # Check if this column is a foreign key
            is_fk = any(
                r["from_table"].lower() == t_name and r["from_column"].lower() == col["column_name"].lower()
                for r in relationships
            )

            columns_by_table[t_name].append({
                "name": col["column_name"],
                "type": col["column_type"],
                "data_type": col["data_type"],
                "is_nullable": col["is_nullable"] == "YES",
                "is_primary_key": is_pk,
                "is_foreign_key": is_fk,
                "default": col["column_default"],
                "extra": col["extra"]
            })

        # Get exact row counts for accurate UI display
        tables = []
        for t in raw_tables:
            t_name = t["table_name"].lower()
            
            # Count actual rows
            try:
                cursor.execute(f"SELECT COUNT(*) AS total FROM `{t['table_name']}`;")
                count_res = cursor.fetchone()
                row_count = count_res["total"] if count_res else 0
            except Exception:
                row_count = t["estimated_rows"] or 0

            meta = ENTITY_METADATA.get(t_name, {
                "title": t["table_name"],
                "icon": "📄",
                "category": "Table",
                "description": "Database Table"
            })

            tables.append({
                "table_name": t["table_name"],
                "title": meta["title"],
                "icon": meta["icon"],
                "category": meta["category"],
                "description": meta["description"],
                "row_count": row_count,
                "columns": columns_by_table.get(t_name, [])
            })

        return {
            "success": True,
            "database_name": DB_NAME,
            "table_count": len(tables),
            "tables": tables,
            "relationships": relationships
        }

    except Exception as e:
        print(f"Error inspecting database schema: {e}")
        return {"success": False, "error": str(e), "tables": [], "relationships": []}
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

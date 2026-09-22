from backend.database import fetch_all, fetch_one, execute_query


def get_all_dark_stores() -> list:
    """Retrieve all dark stores."""
    query = "SELECT * FROM dark_store ORDER BY Store_Id ASC;"
    return fetch_all(query)


def get_store_by_id(store_id: int) -> dict | None:
    """Retrieve a dark store by ID."""
    query = "SELECT * FROM dark_store WHERE Store_Id = %s;"
    return fetch_one(query, (store_id,))


def get_groceries_by_store(store_id: int) -> list:
    """Retrieve all grocery items for a dark store."""
    query = """
        SELECT Store_Id, Item_Name, Price, Available_count
        FROM groceries
        WHERE Store_Id = %s
        ORDER BY Item_Name ASC;
    """
    return fetch_all(query, (store_id,))


def update_grocery_stock(store_id: int, item_name: str, new_count: int) -> bool:
    """Update stock for a grocery item in a dark store."""
    query = """
        UPDATE groceries
        SET Available_count = %s
        WHERE Store_Id = %s AND Item_Name = %s;
    """
    return execute_query(query, (new_count, store_id, item_name))

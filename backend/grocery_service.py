from backend.database import fetch_all, fetch_one, execute_query, get_db_connection


def get_all_dark_stores() -> list:
    """Retrieve all dark stores (Read)."""
    query = "SELECT * FROM DARK_STORE ORDER BY Store_Id ASC;"
    return fetch_all(query)


def get_store_by_id(store_id: int) -> dict | None:
    """Retrieve a dark store by ID (Read)."""
    query = "SELECT * FROM DARK_STORE WHERE Store_Id = %s;"
    return fetch_one(query, (store_id,))


def create_dark_store(street: str, area: str, state: str, pincode: str) -> bool:
    """Create a new dark store location (Create)."""
    conn = get_db_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(Store_Id), 0) + 1 AS next_id FROM DARK_STORE;")
        next_id = cursor.fetchone()["next_id"]

        query = """
            INSERT INTO DARK_STORE (Store_Id, DS_Street, DS_Area, DS_State, DS_Pincode)
            VALUES (%s, %s, %s, %s, %s);
        """
        cursor.execute(query, (next_id, street, area, state, pincode))
        conn.commit()
        return True
    except Exception as e:
        print(f"Error creating dark store: {e}")
        conn.rollback()
        return False
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


def update_dark_store(store_id: int, street: str, area: str, state: str, pincode: str) -> bool:
    """Update dark store location details (Update)."""
    query = """
        UPDATE DARK_STORE
        SET DS_Street = %s, DS_Area = %s, DS_State = %s, DS_Pincode = %s
        WHERE Store_Id = %s;
    """
    return execute_query(query, (street, area, state, pincode, store_id))


def delete_dark_store(store_id: int) -> bool:
    """Delete a dark store and all its groceries (Delete)."""
    query = "DELETE FROM DARK_STORE WHERE Store_Id = %s;"
    return execute_query(query, (store_id,))


# --- Grocery Items CRUD ---

def get_groceries_by_store(store_id: int) -> list:
    """Retrieve all grocery items for a dark store (Read)."""
    query = """
        SELECT Store_Id, Item_Name, Price, Available_count
        FROM GROCERIES
        WHERE Store_Id = %s
        ORDER BY Item_Name ASC;
    """
    return fetch_all(query, (store_id,))


def add_grocery_item(store_id: int, item_name: str, price: float, available_count: int) -> bool:
    """Add a new grocery item to a store (Create)."""
    query = """
        INSERT INTO GROCERIES (Store_Id, Item_Name, Price, Available_count)
        VALUES (%s, %s, %s, %s);
    """
    return execute_query(query, (store_id, item_name, price, available_count))


def update_grocery_item(store_id: int, original_item_name: str, new_item_name: str, price: float, available_count: int) -> bool:
    """Update grocery item details and stock (Update)."""
    query = """
        UPDATE GROCERIES
        SET Item_Name = %s, Price = %s, Available_count = %s
        WHERE Store_Id = %s AND Item_Name = %s;
    """
    return execute_query(query, (new_item_name, price, available_count, store_id, original_item_name))


def delete_grocery_item(store_id: int, item_name: str) -> bool:
    """Delete a grocery item from a store (Delete)."""
    query = "DELETE FROM GROCERIES WHERE Store_Id = %s AND Item_Name = %s;"
    return execute_query(query, (store_id, item_name))

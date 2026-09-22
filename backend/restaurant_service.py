from backend.database import fetch_all, fetch_one, execute_query, get_db_connection


def get_all_restaurants() -> list:
    """Retrieve all restaurants (Read)."""
    query = "SELECT * FROM RESTAURANT ORDER BY Rest_Id ASC;"
    return fetch_all(query)


def get_restaurant_by_id(rest_id: int) -> dict | None:
    """Retrieve a restaurant by ID (Read)."""
    query = "SELECT * FROM RESTAURANT WHERE Rest_Id = %s;"
    return fetch_one(query, (rest_id,))


def create_restaurant(name: str, location: str, phone: str, rating: float = 4.0) -> bool:
    """Create a new restaurant (Create)."""
    conn = get_db_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(Rest_Id), 0) + 1 AS next_id FROM RESTAURANT;")
        next_id = cursor.fetchone()["next_id"]

        query = """
            INSERT INTO RESTAURANT (Rest_Id, RName, RLocation, RPhone, RRating)
            VALUES (%s, %s, %s, %s, %s);
        """
        cursor.execute(query, (next_id, name, location, phone, rating))
        conn.commit()
        return True
    except Exception as e:
        print(f"Error creating restaurant: {e}")
        conn.rollback()
        return False
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


def update_restaurant(rest_id: int, name: str, location: str, phone: str, rating: float) -> bool:
    """Update restaurant information (Update)."""
    query = """
        UPDATE RESTAURANT
        SET RName = %s, RLocation = %s, RPhone = %s, RRating = %s
        WHERE Rest_Id = %s;
    """
    return execute_query(query, (name, location, phone, rating, rest_id))


def delete_restaurant(rest_id: int) -> bool:
    """Delete restaurant and its menu items (Delete)."""
    query = "DELETE FROM RESTAURANT WHERE Rest_Id = %s;"
    return execute_query(query, (rest_id,))


# --- Menu Items CRUD ---

def get_menu_by_restaurant(rest_id: int) -> list:
    """Retrieve all menu items for a restaurant (Read)."""
    query = """
        SELECT Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice
        FROM REST_ITEMS
        WHERE Rest_Id = %s
        ORDER BY Item_Name ASC;
    """
    return fetch_all(query, (rest_id,))


def add_menu_item(rest_id: int, item_name: str, food_name: str, is_veg: bool, base_price: float, discount: float = 0.0) -> bool:
    """Add a new dish to a restaurant menu (Create)."""
    final_price = base_price - (base_price * discount / 100.0)
    query = """
        INSERT INTO REST_ITEMS (Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice)
        VALUES (%s, %s, %s, %s, %s, %s, %s);
    """
    return execute_query(query, (rest_id, item_name, food_name, is_veg, base_price, discount, final_price))


def update_menu_item(rest_id: int, original_item_name: str, new_item_name: str, food_name: str, is_veg: bool, base_price: float, discount: float) -> bool:
    """Update dish details and recalculate final price (Update)."""
    final_price = base_price - (base_price * discount / 100.0)
    query = """
        UPDATE REST_ITEMS
        SET Item_Name = %s, Food_Name = %s, Is_Veg = %s, BasePrice = %s, Discount = %s, FinalPrice = %s
        WHERE Rest_Id = %s AND Item_Name = %s;
    """
    return execute_query(query, (new_item_name, food_name, is_veg, base_price, discount, final_price, rest_id, original_item_name))


def delete_menu_item(rest_id: int, item_name: str) -> bool:
    """Delete a dish from a restaurant (Delete)."""
    query = "DELETE FROM REST_ITEMS WHERE Rest_Id = %s AND Item_Name = %s;"
    return execute_query(query, (rest_id, item_name))


# Aliases for route compatibility
get_restaurant_menu = get_menu_by_restaurant
add_restaurant_item = add_menu_item
update_restaurant_item = update_menu_item
delete_restaurant_item = delete_menu_item


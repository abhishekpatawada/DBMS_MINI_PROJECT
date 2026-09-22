from backend.database import fetch_all, fetch_one, execute_query


def get_all_restaurants() -> list:
    """Retrieve all restaurants (Read)."""
    query = "SELECT * FROM restaurant ORDER BY Rest_Id ASC;"
    return fetch_all(query)


def get_restaurant_by_id(rest_id: int) -> dict | None:
    """Retrieve a restaurant by ID (Read)."""
    query = "SELECT * FROM restaurant WHERE Rest_Id = %s;"
    return fetch_one(query, (rest_id,))


def create_restaurant(name: str, location: str, phone: str, rating: float = 4.0) -> bool:
    """Create a new restaurant (Create)."""
    query = """
        INSERT INTO restaurant (RName, RLocation, RPhone, RRating)
        VALUES (%s, %s, %s, %s);
    """
    return execute_query(query, (name, location, phone, rating))


def update_restaurant(rest_id: int, name: str, location: str, phone: str, rating: float) -> bool:
    """Update restaurant information (Update)."""
    query = """
        UPDATE restaurant
        SET RName = %s, RLocation = %s, RPhone = %s, RRating = %s
        WHERE Rest_Id = %s;
    """
    return execute_query(query, (name, location, phone, rating, rest_id))


def delete_restaurant(rest_id: int) -> bool:
    """Delete restaurant and its menu items (Delete)."""
    query = "DELETE FROM restaurant WHERE Rest_Id = %s;"
    return execute_query(query, (rest_id,))


# --- Menu Items CRUD ---

def get_restaurant_menu(rest_id: int) -> list:
    """Retrieve all menu items for a restaurant (Read)."""
    query = """
        SELECT Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice
        FROM rest_items
        WHERE Rest_Id = %s
        ORDER BY Item_Name ASC;
    """
    return fetch_all(query, (rest_id,))


def add_restaurant_item(rest_id: int, item_name: str, food_name: str, is_veg: bool, base_price: float, discount: float = 0.0) -> bool:
    """Add a new item to restaurant menu (Create)."""
    query = """
        INSERT INTO rest_items (Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount)
        VALUES (%s, %s, %s, %s, %s, %s);
    """
    return execute_query(query, (rest_id, item_name, food_name, is_veg, base_price, discount))


def update_restaurant_item(rest_id: int, original_item_name: str, new_item_name: str, food_name: str, is_veg: bool, base_price: float, discount: float) -> bool:
    """Update an existing menu item (Update)."""
    query = """
        UPDATE rest_items
        SET Item_Name = %s, Food_Name = %s, Is_Veg = %s, BasePrice = %s, Discount = %s
        WHERE Rest_Id = %s AND Item_Name = %s;
    """
    return execute_query(query, (new_item_name, food_name, is_veg, base_price, discount, rest_id, original_item_name))


def delete_restaurant_item(rest_id: int, item_name: str) -> bool:
    """Delete a menu item from a restaurant (Delete)."""
    query = "DELETE FROM rest_items WHERE Rest_Id = %s AND Item_Name = %s;"
    return execute_query(query, (rest_id, item_name))

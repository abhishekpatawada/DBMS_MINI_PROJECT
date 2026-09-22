from backend.database import fetch_all, fetch_one, execute_query


def get_all_restaurants() -> list:
    """Retrieve all restaurants."""
    query = "SELECT * FROM restaurant ORDER BY RRating DESC;"
    return fetch_all(query)


def get_restaurant_by_id(rest_id: int) -> dict | None:
    """Retrieve a restaurant by ID."""
    query = "SELECT * FROM restaurant WHERE Rest_Id = %s;"
    return fetch_one(query, (rest_id,))


def get_restaurant_menu(rest_id: int) -> list:
    """Retrieve all menu items for a given restaurant."""
    query = """
        SELECT Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice
        FROM rest_items
        WHERE Rest_Id = %s
        ORDER BY Item_Name ASC;
    """
    return fetch_all(query, (rest_id,))


def add_restaurant_item(rest_id: int, item_name: str, food_name: str, is_veg: bool, base_price: float, discount: float) -> bool:
    """Add a new item to restaurant menu."""
    query = """
        INSERT INTO rest_items (Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount)
        VALUES (%s, %s, %s, %s, %s, %s);
    """
    return execute_query(query, (rest_id, item_name, food_name, is_veg, base_price, discount))

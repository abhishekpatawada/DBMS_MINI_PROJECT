from backend.database import fetch_all, fetch_one, execute_query, get_db_connection


def get_all_orders() -> list:
    """Retrieve all orders with customer and agent details."""
    query = """
        SELECT o.Order_Id, o.User_Id, u.User_Name, da.Agent_Name,
               o.Order_Type, o.Order_Status, o.Total_Amount, o.Order_Date
        FROM orders o
        JOIN users u ON o.User_Id = u.User_Id
        LEFT JOIN delivery_agent da ON o.Agent_Id = da.Agent_Id
        ORDER BY o.Order_Date DESC;
    """
    return fetch_all(query)


def get_user_orders(user_id: int) -> list:
    """Retrieve all orders placed by a specific user."""
    query = """
        SELECT o.Order_Id, o.Order_Type, o.Order_Status, o.Total_Amount, 
               o.Order_Date, da.Agent_Name, da.Agent_Phone
        FROM orders o
        LEFT JOIN delivery_agent da ON o.Agent_Id = da.Agent_Id
        WHERE o.User_Id = %s
        ORDER BY o.Order_Date DESC;
    """
    return fetch_all(query, (user_id,))


def get_order_items(order_id: int) -> list:
    """Retrieve item breakdown for an order."""
    query = """
        SELECT Item_Order_Id, Item_Name, Quantity, Item_Price, Subtotal
        FROM order_items
        WHERE Order_Id = %s;
    """
    return fetch_all(query, (order_id,))

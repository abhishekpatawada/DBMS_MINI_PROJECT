from backend.database import fetch_all, fetch_one, execute_query, get_db_connection


def get_all_orders() -> list:
    """Retrieve all orders with customer and agent details (Read)."""
    query = """
        SELECT o.Order_Id, o.User_Id, u.User_Name, u.User_Phone, 
               o.Agent_Id, da.Agent_Name,
               o.Order_Type, o.Order_Status, o.Total_Amount, o.Order_Date,
               p.Payment_Method, p.Payment_Status
        FROM orders o
        JOIN users u ON o.User_Id = u.User_Id
        LEFT JOIN delivery_agent da ON o.Agent_Id = da.Agent_Id
        LEFT JOIN payments p ON o.Order_Id = p.Order_Id
        ORDER BY o.Order_Date DESC;
    """
    return fetch_all(query)


def get_user_orders(user_id: int) -> list:
    """Retrieve all orders placed by a specific user (Read)."""
    query = """
        SELECT o.Order_Id, o.Order_Type, o.Order_Status, o.Total_Amount, 
               o.Order_Date, da.Agent_Name, da.Agent_Phone,
               p.Payment_Method, p.Payment_Status
        FROM orders o
        LEFT JOIN delivery_agent da ON o.Agent_Id = da.Agent_Id
        LEFT JOIN payments p ON o.Order_Id = p.Order_Id
        WHERE o.User_Id = %s
        ORDER BY o.Order_Date DESC;
    """
    return fetch_all(query, (user_id,))


def get_order_by_id(order_id: int) -> dict | None:
    """Retrieve single order details."""
    query = """
        SELECT o.Order_Id, o.User_Id, u.User_Name, u.User_Phone, 
               o.Agent_Id, da.Agent_Name, da.Agent_Phone,
               o.Order_Type, o.Order_Status, o.Total_Amount, o.Order_Date,
               p.Payment_Method, p.Payment_Status
        FROM orders o
        JOIN users u ON o.User_Id = u.User_Id
        LEFT JOIN delivery_agent da ON o.Agent_Id = da.Agent_Id
        LEFT JOIN payments p ON o.Order_Id = p.Order_Id
        WHERE o.Order_Id = %s;
    """
    return fetch_one(query, (order_id,))


def get_order_items(order_id: int) -> list:
    """Retrieve item breakdown for an order (Read)."""
    query = """
        SELECT Item_Order_Id, Item_Name, Quantity, Item_Price, Subtotal
        FROM order_items
        WHERE Order_Id = %s;
    """
    return fetch_all(query, (order_id,))


def create_order_with_items(user_id: int, agent_id: int | None, order_type: str, items: list, payment_method: str) -> tuple[bool, int | None]:
    """
    Create an order atomically:
    1. Insert into orders
    2. Insert into order_items
    3. Insert into payments
    """
    conn = get_db_connection()
    if not conn:
        return False, None
    try:
        cursor = conn.cursor()
        
        # Calculate total
        total_amount = sum(item["quantity"] * item["price"] for item in items)
        
        # 1. Insert order
        order_query = """
            INSERT INTO orders (User_Id, Agent_Id, Order_Type, Order_Status, Total_Amount)
            VALUES (%s, %s, %s, 'Placed', %s);
        """
        cursor.execute(order_query, (user_id, agent_id, order_type, total_amount))
        order_id = cursor.lastrowid
        
        # 2. Insert order items
        item_query = """
            INSERT INTO order_items (Order_Id, Item_Name, Quantity, Item_Price)
            VALUES (%s, %s, %s, %s);
        """
        for item in items:
            cursor.execute(item_query, (order_id, item["name"], item["quantity"], item["price"]))
            
        # 3. Insert payment
        payment_query = """
            INSERT INTO payments (Order_Id, Payment_Method, Payment_Status, Amount)
            VALUES (%s, %s, 'Completed', %s);
        """
        cursor.execute(payment_query, (order_id, payment_method, total_amount))
        
        conn.commit()
        return True, order_id
    except Exception as e:
        print(f"Error creating order transaction: {e}")
        conn.rollback()
        return False, None
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


def update_order_status(order_id: int, new_status: str) -> bool:
    """Update order status (Update)."""
    query = "UPDATE orders SET Order_Status = %s WHERE Order_Id = %s;"
    return execute_query(query, (new_status, order_id))


def delete_order(order_id: int) -> bool:
    """Delete an order, cascading to order_items and payments (Delete)."""
    query = "DELETE FROM orders WHERE Order_Id = %s;"
    return execute_query(query, (order_id,))

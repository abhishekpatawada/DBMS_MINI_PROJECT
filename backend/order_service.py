from backend.database import fetch_all, fetch_one, execute_query, get_db_connection


def get_all_orders() -> list:
    """Retrieve all orders with customer and agent details (Read)."""
    query = """
        SELECT 
            o.Order_Id, 
            o.User_Id, 
            u.User_Name, 
            u.User_Phone, 
            o.Agent_Id, 
            da.Agent_Name,
            IF(o.Rest_Id IS NOT NULL, 'Restaurant', 'Grocery') AS Order_Type,
            IF(o.DeliveredAt IS NOT NULL, 'Delivered', 'Placed') AS Order_Status,
            COALESCE(p.Amount, 0.00) AS Total_Amount,
            o.PlacedAt AS Order_Date,
            p.Payment_Method, 
            IF(p.Payment_Id IS NOT NULL, 'Completed', 'Pending') AS Payment_Status,
            o.Delivery_Addr
        FROM ORDERS o
        JOIN USERS u ON o.User_Id = u.User_Id
        LEFT JOIN DELIVERY_AGENT da ON o.Agent_Id = da.Agent_Id
        LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
        ORDER BY o.PlacedAt DESC;
    """
    return fetch_all(query)


def get_user_orders(user_id: int) -> list:
    """Retrieve all orders placed by a specific user (Read)."""
    query = """
        SELECT 
            o.Order_Id, 
            IF(o.Rest_Id IS NOT NULL, 'Restaurant', 'Grocery') AS Order_Type,
            IF(o.DeliveredAt IS NOT NULL, 'Delivered', 'Placed') AS Order_Status,
            COALESCE(p.Amount, 0.00) AS Total_Amount,
            o.PlacedAt AS Order_Date,
            da.Agent_Name, 
            da.Agent_Phone,
            p.Payment_Method, 
            IF(p.Payment_Id IS NOT NULL, 'Completed', 'Pending') AS Payment_Status,
            o.Delivery_Addr
        FROM ORDERS o
        LEFT JOIN DELIVERY_AGENT da ON o.Agent_Id = da.Agent_Id
        LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
        WHERE o.User_Id = %s
        ORDER BY o.PlacedAt DESC;
    """
    return fetch_all(query, (user_id,))


def get_order_by_id(order_id: int) -> dict | None:
    """Retrieve single order details."""
    query = """
        SELECT 
            o.Order_Id, 
            o.User_Id, 
            u.User_Name, 
            u.User_Phone, 
            o.Agent_Id, 
            da.Agent_Name, 
            da.Agent_Phone,
            IF(o.Rest_Id IS NOT NULL, 'Restaurant', 'Grocery') AS Order_Type,
            IF(o.DeliveredAt IS NOT NULL, 'Delivered', 'Placed') AS Order_Status,
            COALESCE(p.Amount, 0.00) AS Total_Amount,
            o.PlacedAt AS Order_Date,
            p.Payment_Method, 
            IF(p.Payment_Id IS NOT NULL, 'Completed', 'Pending') AS Payment_Status,
            o.Delivery_Addr
        FROM ORDERS o
        JOIN USERS u ON o.User_Id = u.User_Id
        LEFT JOIN DELIVERY_AGENT da ON o.Agent_Id = da.Agent_Id
        LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
        WHERE o.Order_Id = %s;
    """
    return fetch_one(query, (order_id,))


def get_order_items(order_id: int) -> list:
    """Retrieve item breakdown for an order (either from ORDER_ITEM or ORDER_GROCERY)."""
    # Check if restaurant order item
    food_query = """
        SELECT oi.Item_Name, oi.Food_quantity AS Quantity, ri.FinalPrice AS Item_Price, (oi.Food_quantity * ri.FinalPrice) AS Subtotal
        FROM ORDER_ITEM oi
        JOIN REST_ITEMS ri ON oi.Rest_Id = ri.Rest_Id AND oi.Item_Name = ri.Item_Name
        WHERE oi.Order_Id = %s;
    """
    food_items = fetch_all(food_query, (order_id,))
    if food_items:
        return food_items

    # Otherwise check grocery order items
    grocery_query = """
        SELECT og.Item_Name, og.Quantity, g.Price AS Item_Price, (og.Quantity * g.Price) AS Subtotal
        FROM ORDER_GROCERY og
        JOIN GROCERIES g ON og.Store_Id = g.Store_Id AND og.Item_Name = g.Item_Name
        WHERE og.Order_Id = %s;
    """
    return fetch_all(grocery_query, (order_id,))


def create_order_with_items(user_id: int, agent_id: int | None, order_type: str, items: list, payment_method: str) -> tuple[bool, int | None]:
    """
    Create an order atomically:
    1. Determine next Order_Id and target Rest_Id / Store_Id
    2. Insert into ORDERS
    3. Insert into ORDER_ITEM or ORDER_GROCERY
    4. Insert into PAYMENT
    """
    conn = get_db_connection()
    if not conn:
        return False, None
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Calculate next Order_Id
        cursor.execute("SELECT COALESCE(MAX(Order_Id), 0) + 1 AS next_id FROM ORDERS;")
        order_res = cursor.fetchone()
        order_id = order_res["next_id"] if order_res else 1

        # Calculate next Payment_Id
        cursor.execute("SELECT COALESCE(MAX(Payment_Id), 0) + 1 AS next_id FROM PAYMENT;")
        pay_res = cursor.fetchone()
        payment_id = pay_res["next_id"] if pay_res else 1

        # Calculate total amount
        total_amount = sum(item["quantity"] * item["price"] for item in items)
        
        # Find default Delivery Agent if not supplied
        if not agent_id:
            cursor.execute("SELECT Agent_Id FROM DELIVERY_AGENT ORDER BY RAND() LIMIT 1;")
            ag_row = cursor.fetchone()
            agent_id = ag_row["Agent_Id"] if ag_row else 1

        # Find user address
        cursor.execute("SELECT Street, Area, State, Pincode FROM USERS WHERE User_Id = %s;", (user_id,))
        u_row = cursor.fetchone()
        if u_row:
            delivery_addr = f"{u_row.get('Street', '')}, {u_row.get('Area', '')}, {u_row.get('State', '')} - {u_row.get('Pincode', '')}"
        else:
            delivery_addr = "Customer Delivery Address"

        if order_type.lower() == "restaurant":
            # Lookup Rest_Id for the first item from REST_ITEMS
            first_item = items[0]["name"] if items else ""
            cursor.execute("SELECT Rest_Id FROM REST_ITEMS WHERE Item_Name = %s LIMIT 1;", (first_item,))
            r_row = cursor.fetchone()
            rest_id = r_row["Rest_Id"] if r_row else 1

            # 1. Insert into ORDERS
            order_query = """
                INSERT INTO ORDERS (Order_Id, User_Id, Agent_Id, Rest_Id, Store_Id, PlacedAt, Delivery_Addr)
                VALUES (%s, %s, %s, %s, NULL, NOW(), %s);
            """
            cursor.execute(order_query, (order_id, user_id, agent_id, rest_id, delivery_addr))

            # 2. Insert into ORDER_ITEM
            item_query = """
                INSERT INTO ORDER_ITEM (Order_Id, Rest_Id, Item_Name, Food_quantity)
                VALUES (%s, %s, %s, %s);
            """
            for item in items:
                cursor.execute(item_query, (order_id, rest_id, item["name"], item["quantity"]))

        else:
            # Grocery Order
            first_item = items[0]["name"] if items else ""
            cursor.execute("SELECT Store_Id FROM GROCERIES WHERE Item_Name = %s LIMIT 1;", (first_item,))
            s_row = cursor.fetchone()
            store_id = s_row["Store_Id"] if s_row else 1

            # 1. Insert into ORDERS
            order_query = """
                INSERT INTO ORDERS (Order_Id, User_Id, Agent_Id, Rest_Id, Store_Id, PlacedAt, Delivery_Addr)
                VALUES (%s, %s, %s, NULL, %s, NOW(), %s);
            """
            cursor.execute(order_query, (order_id, user_id, agent_id, store_id, delivery_addr))

            # 2. Insert into ORDER_GROCERY
            item_query = """
                INSERT INTO ORDER_GROCERY (Order_Id, Store_Id, Item_Name, Quantity)
                VALUES (%s, %s, %s, %s);
            """
            for item in items:
                cursor.execute(item_query, (order_id, store_id, item["name"], item["quantity"]))

        # 3. Insert into PAYMENT
        payment_query = """
            INSERT INTO PAYMENT (Payment_Id, Order_Id, Payment_Method, Amount)
            VALUES (%s, %s, %s, %s);
        """
        cursor.execute(payment_query, (payment_id, order_id, payment_method, total_amount))
        
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
    if new_status.lower() == "delivered":
        query = "UPDATE ORDERS SET DeliveredAt = NOW() WHERE Order_Id = %s;"
    else:
        query = "UPDATE ORDERS SET DeliveredAt = NULL WHERE Order_Id = %s;"
    return execute_query(query, (order_id,))


def delete_order(order_id: int) -> bool:
    """Delete an order, cascading to line items and payments (Delete)."""
    query = "DELETE FROM ORDERS WHERE Order_Id = %s;"
    return execute_query(query, (order_id,))

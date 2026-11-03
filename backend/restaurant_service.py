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
        SELECT Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Image_Url
        FROM REST_ITEMS
        WHERE Rest_Id = %s
        ORDER BY Item_Name ASC;
    """
    return fetch_all(query, (rest_id,))


def add_menu_item(rest_id: int, item_name: str, food_name: str, is_veg: bool, base_price: float, discount: float = 0.0, image_url: str = None) -> bool:
    """Add a new dish to a restaurant menu (Create)."""
    final_price = base_price - (base_price * discount / 100.0)
    query = """
        INSERT INTO REST_ITEMS (Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Image_Url)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
    """
    return execute_query(query, (rest_id, item_name, food_name, is_veg, base_price, discount, final_price, image_url))


def update_menu_item(rest_id: int, original_item_name: str, new_item_name: str, food_name: str, is_veg: bool, base_price: float, discount: float, image_url: str = None) -> bool:
    """Update dish details and recalculate final price (Update)."""
    final_price = base_price - (base_price * discount / 100.0)
    if image_url is not None:
        query = """
            UPDATE REST_ITEMS
            SET Item_Name = %s, Food_Name = %s, Is_Veg = %s, BasePrice = %s, Discount = %s, FinalPrice = %s, Image_Url = %s
            WHERE Rest_Id = %s AND Item_Name = %s;
        """
        return execute_query(query, (new_item_name, food_name, is_veg, base_price, discount, final_price, image_url, rest_id, original_item_name))
    else:
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


def get_all_dishes() -> list:
    """Retrieve all dishes across all restaurants joined with restaurant details."""
    query = """
        SELECT 
            m.Rest_Id, 
            m.Item_Name, 
            m.Food_Name, 
            m.Is_Veg, 
            m.BasePrice, 
            m.Discount, 
            m.FinalPrice, 
            m.Image_Url,
            r.RName AS Restaurant_Name,
            r.RLocation AS Restaurant_Location,
            r.RRating AS Restaurant_Rating
        FROM REST_ITEMS m
        JOIN RESTAURANT r ON m.Rest_Id = r.Rest_Id
        ORDER BY r.RRating DESC, m.Discount DESC, m.Item_Name ASC;
    """
    return fetch_all(query)


# Aliases for route compatibility
get_restaurant_menu = get_menu_by_restaurant
add_restaurant_item = add_menu_item
update_restaurant_item = update_menu_item
delete_restaurant_item = delete_menu_item


def get_restaurant_revenue_analytics(rest_id: int) -> dict:
    """Retrieve comprehensive big-screen revenue & operational intelligence for a restaurant."""
    # 1. Total revenue & orders count
    rev_query = """
        SELECT 
            COALESCE(SUM(p.Amount), 0.0) AS total_revenue,
            COUNT(DISTINCT o.Order_Id) AS total_orders,
            COUNT(DISTINCT CASE WHEN o.Order_Status = 'Delivered' OR o.DeliveredAt IS NOT NULL THEN o.Order_Id END) AS delivered_orders,
            COUNT(DISTINCT CASE WHEN o.Order_Status IN ('Placed', 'Preparing', 'Ready for Pickup', 'Out for Delivery') AND o.DeliveredAt IS NULL THEN o.Order_Id END) AS active_orders,
            COUNT(DISTINCT CASE WHEN o.Order_Status = 'Cancelled' THEN o.Order_Id END) AS cancelled_orders,
            COUNT(DISTINCT o.User_Id) AS total_customers,
            COUNT(DISTINCT o.Agent_Id) AS total_riders,
            COALESCE(AVG(o.Agent_Rating), 4.8) AS avg_rider_rating
        FROM ORDERS o
        LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
        WHERE o.Rest_Id = %s;
    """
    summary_data = fetch_one(rev_query, (rest_id,)) or {}
    total_rev = float(summary_data.get("total_revenue") or 0.0)
    total_orders = int(summary_data.get("total_orders") or 0)
    delivered = int(summary_data.get("delivered_orders") or 0)
    active = int(summary_data.get("active_orders") or 0)
    cancelled = int(summary_data.get("cancelled_orders") or 0)
    customers = int(summary_data.get("total_customers") or 0)
    riders = int(summary_data.get("total_riders") or 0)
    avg_rider_rating = round(float(summary_data.get("avg_rider_rating") or 4.8), 2)
    aov = round(total_rev / total_orders, 2) if total_orders > 0 else 0.0
    net_payout = round(total_rev * 0.85, 2)
    platform_fee = round(total_rev * 0.15, 2)

    # 2. Timeline (Daily revenue & orders)
    timeline_query = """
        SELECT 
            DATE(o.PlacedAt) AS date_str,
            COUNT(DISTINCT o.Order_Id) AS orders_count,
            COALESCE(SUM(p.Amount), 0.0) AS revenue
        FROM ORDERS o
        LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
        WHERE o.Rest_Id = %s AND o.PlacedAt IS NOT NULL
        GROUP BY DATE(o.PlacedAt)
        ORDER BY date_str DESC
        LIMIT 14;
    """
    raw_timeline = fetch_all(timeline_query, (rest_id,))
    timeline = []
    for row in reversed(raw_timeline):
        timeline.append({
            "date": str(row["date_str"]),
            "orders": int(row["orders_count"]),
            "revenue": round(float(row["revenue"]), 2)
        })

    today_revenue = round(timeline[-1]["revenue"], 2) if timeline else 0.0
    yesterday_revenue = round(timeline[-2]["revenue"], 2) if len(timeline) >= 2 else round(today_revenue * 0.85, 2)
    growth_pct = round(((today_revenue - yesterday_revenue) / yesterday_revenue * 100), 1) if yesterday_revenue > 0 else 12.5

    # 3. Top Selling Dishes Leaderboard
    top_items_query = """
        SELECT 
            oi.Item_Name,
            COALESCE(ri.Food_Name, 'Main Course') AS category,
            COALESCE(ri.Is_Veg, 1) AS is_veg,
            COALESCE(ri.FinalPrice, 150.0) AS price,
            ri.Image_Url,
            SUM(oi.Food_quantity) AS units_sold,
            SUM(oi.Food_quantity * COALESCE(ri.FinalPrice, 150.0)) AS revenue
        FROM ORDER_ITEM oi
        LEFT JOIN REST_ITEMS ri ON oi.Rest_Id = ri.Rest_Id AND oi.Item_Name = ri.Item_Name
        WHERE oi.Rest_Id = %s
        GROUP BY oi.Item_Name, ri.Food_Name, ri.Is_Veg, ri.FinalPrice, ri.Image_Url
        ORDER BY revenue DESC
        LIMIT 8;
    """
    top_items = fetch_all(top_items_query, (rest_id,))
    if not top_items:
        top_items = []

    # 4. Payment breakdown
    pay_query = """
        SELECT 
            COALESCE(p.Payment_Method, 'UPI') AS method,
            COUNT(*) AS count,
            COALESCE(SUM(p.Amount), 0.0) AS amount
        FROM ORDERS o
        LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
        WHERE o.Rest_Id = %s
        GROUP BY p.Payment_Method;
    """
    pay_data = fetch_all(pay_query, (rest_id,))
    payment_methods = []
    for p in pay_data:
        payment_methods.append({
            "method": p["method"] or "UPI",
            "count": int(p["count"]),
            "amount": round(float(p["amount"]), 2)
        })

    # 5. Live Orders feed (with Customer and Rider details)
    live_orders_query = """
        SELECT 
            o.Order_Id,
            o.User_Id,
            u.User_Name,
            u.User_Phone,
            o.Agent_Id,
            da.Agent_Name,
            da.Agent_Phone,
            da.VehicleNO AS Agent_Vehicle,
            da.Rating AS Agent_Rating,
            o.Delivery_Addr,
            o.PlacedAt,
            COALESCE(o.Order_Status, IF(o.DeliveredAt IS NOT NULL, 'Delivered', 'Placed')) AS Order_Status,
            COALESCE(p.Amount, 0.0) AS Total_Amount,
            p.Payment_Method
        FROM ORDERS o
        JOIN USERS u ON o.User_Id = u.User_Id
        LEFT JOIN DELIVERY_AGENT da ON o.Agent_Id = da.Agent_Id
        LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
        WHERE o.Rest_Id = %s
        ORDER BY o.PlacedAt DESC
        LIMIT 30;
    """
    raw_live_orders = fetch_all(live_orders_query, (rest_id,))
    live_orders = []
    for ro in raw_live_orders:
        order_id = ro["Order_Id"]
        items_query = """
            SELECT oi.Item_Name, oi.Food_quantity AS quantity, ri.FinalPrice AS price, ri.Is_Veg
            FROM ORDER_ITEM oi
            LEFT JOIN REST_ITEMS ri ON oi.Rest_Id = ri.Rest_Id AND oi.Item_Name = ri.Item_Name
            WHERE oi.Order_Id = %s;
        """
        items = fetch_all(items_query, (order_id,))
        live_orders.append({
            "order_id": order_id,
            "user_id": ro["User_Id"],
            "user_name": ro["User_Name"],
            "user_phone": ro["User_Phone"],
            "agent_id": ro["Agent_Id"],
            "agent_name": ro["Agent_Name"],
            "agent_phone": ro["Agent_Phone"],
            "agent_vehicle": ro["Agent_Vehicle"],
            "agent_rating": float(ro["Agent_Rating"] or 5.0),
            "delivery_addr": ro["Delivery_Addr"],
            "placed_at": str(ro["PlacedAt"]),
            "order_status": ro["Order_Status"],
            "total_amount": round(float(ro["Total_Amount"]), 2),
            "payment_method": ro["Payment_Method"] or "UPI",
            "items": items
        })

    # 6. Top Customers Leaderboard ("who ordered the more")
    top_customers = []
    try:
        cust_query = """
            SELECT 
                o.User_Id,
                u.User_Name,
                u.User_Phone,
                COALESCE(u.Area, 'Indiranagar') AS user_area,
                COUNT(o.Order_Id) AS order_count,
                COALESCE(SUM(p.Amount), 0.0) AS total_spent,
                MAX(o.PlacedAt) AS last_order_date
            FROM ORDERS o
            JOIN USERS u ON o.User_Id = u.User_Id
            LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
            WHERE o.Rest_Id = %s
            GROUP BY o.User_Id, u.User_Name, u.User_Phone, u.Area
            ORDER BY order_count DESC, total_spent DESC
            LIMIT 15;
        """
        raw_custs = fetch_all(cust_query, (rest_id,))
        for c in raw_custs:
            u_id = c["User_Id"]
            fav_dish_query = """
                SELECT oi.Item_Name, SUM(oi.Food_quantity) AS qty
                FROM ORDER_ITEM oi
                JOIN ORDERS o ON oi.Order_Id = o.Order_Id
                WHERE o.Rest_Id = %s AND o.User_Id = %s
                GROUP BY oi.Item_Name
                ORDER BY qty DESC
                LIMIT 1;
            """
            fav_res = fetch_one(fav_dish_query, (rest_id, u_id))
            top_customers.append({
                "user_id": u_id,
                "user_name": c["User_Name"],
                "user_phone": c["User_Phone"],
                "user_area": c["user_area"],
                "order_count": int(c["order_count"]),
                "total_spent": round(float(c["total_spent"]), 2),
                "last_order_date": str(c["last_order_date"]),
                "favorite_dish": fav_res["Item_Name"] if fav_res else (top_items[0]["Item_Name"] if top_items else "Signature Dish")
            })
    except Exception as e:
        print(f"Error computing restaurant top customers: {e}")

    if not top_customers:
        top_customers = []

    return {
        "status": "success",
        "restaurant_id": rest_id,
        "summary": {
            "total_revenue": total_rev,
            "net_payout": net_payout,
            "platform_fee": platform_fee,
            "today_revenue": today_revenue,
            "yesterday_revenue": yesterday_revenue,
            "growth_pct": growth_pct,
            "total_orders": total_orders,
            "delivered_orders": delivered,
            "active_orders": active,
            "cancelled_orders": cancelled,
            "avg_order_value": aov,
            "unique_customers": customers,
            "dispatched_riders": riders,
            "avg_rider_rating": avg_rider_rating
        },
        "timeline": timeline,
        "top_items": top_items,
        "top_customers": top_customers,
        "payment_methods": payment_methods,
        "live_orders": live_orders
    }



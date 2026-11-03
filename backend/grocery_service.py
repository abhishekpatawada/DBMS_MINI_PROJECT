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


# Curated complete catalog for Indiranagar Dark Store (Store #1)
INDIRANAGAR_GROCERY_CATALOG = [
    ("Amul Butter 500g", 275.00, 85, "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500&auto=format&fit=crop&q=80"),
    ("Nandini GoodLife Milk 1L", 62.00, 120, "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=80"),
    ("Amul Taaza Milk 1L", 56.00, 110, "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500&auto=format&fit=crop&q=80"),
    ("Britannia Brown Bread 400g", 50.00, 95, "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80"),
    ("Farm Fresh Eggs (6 pcs)", 48.00, 100, "https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=500&auto=format&fit=crop&q=80"),
    ("Farm Fresh Eggs (12 pcs)", 92.00, 90, "https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=500&auto=format&fit=crop&q=80"),
    ("Amul Cheese Slices 200g", 145.00, 80, "https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?w=500&auto=format&fit=crop&q=80"),
    ("Amul Paneer 200g", 92.00, 95, "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80"),
    ("Epigamia Greek Yogurt 90g", 50.00, 65, "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop&q=80"),
    ("Fresh Onion 1kg", 35.00, 120, "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80"),
    ("Fresh Potato 1kg", 30.00, 140, "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80"),
    ("Fresh Tomato Local 1kg", 40.00, 130, "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80"),
    ("Aashirvaad Atta 5kg", 245.00, 75, "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80"),
    ("Fortune Sunflower Oil 1L", 160.00, 110, "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&auto=format&fit=crop&q=80"),
    ("Tata Salt 1kg", 28.00, 150, "https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?w=500&auto=format&fit=crop&q=80"),
    ("Madhur Pure Sugar 1kg", 55.00, 140, "https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=500&auto=format&fit=crop&q=80"),
    ("Tata Sampann Toor Dal 1kg", 185.00, 100, "https://images.unsplash.com/photo-1585994192701-512cb59f0f97?w=500&auto=format&fit=crop&q=80"),
    ("India Gate Basmati Rice 5kg", 450.00, 85, "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80"),
    ("Lays Classic Salted 50g", 20.00, 180, "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&auto=format&fit=crop&q=80"),
    ("Kurkure Masala Munch 90g", 20.00, 170, "https://images.unsplash.com/photo-1621447504864-d8686e12698c?w=500&auto=format&fit=crop&q=80"),
    ("Haldiram Bhujia 400g", 115.00, 95, "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80"),
    ("Oreo Original Cookies 120g", 40.00, 160, "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500&auto=format&fit=crop&q=80"),
    ("Maggi 2-Minute Noodles 280g", 58.00, 150, "https://images.unsplash.com/photo-1612927601601-6638404737ce?w=500&auto=format&fit=crop&q=80"),
    ("Kissan Tomato Ketchup 1kg", 130.00, 80, "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&auto=format&fit=crop&q=80"),
    ("Nutella Hazelnut Spread 350g", 380.00, 60, "https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=500&auto=format&fit=crop&q=80"),
    ("Nescafe Classic Coffee 100g", 310.00, 90, "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&auto=format&fit=crop&q=80"),
    ("Taj Mahal Tea 500g", 340.00, 90, "https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&auto=format&fit=crop&q=80"),
    ("Cadbury Dairy Milk 150g", 175.00, 110, "https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=500&auto=format&fit=crop&q=80"),
    ("Dettol Original Soap (3 pcs)", 135.00, 120, "https://images.unsplash.com/photo-1608248597359-364e0a4f5263?w=500&auto=format&fit=crop&q=80"),
    ("Colgate Strong Teeth 150g", 98.00, 140, "https://images.unsplash.com/photo-1559591937-e62fb330f248?w=500&auto=format&fit=crop&q=80"),
    ("Head & Shoulders Shampoo 340ml", 280.00, 90, "https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=500&auto=format&fit=crop&q=80"),
    ("Surf Excel Matic Liquid 1L", 220.00, 65, "https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80"),
    ("Vim Dishwash Gel 750ml", 145.00, 90, "https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80"),
    ("Harpic Toilet Cleaner 1L", 195.00, 85, "https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80"),
    ("Lizol Floor Cleaner 1L", 190.00, 90, "https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80"),
]


def ensure_indiranagar_inventory(store_id: int = 1):
    """Ensures Indiranagar dark store (Store #1) has the full Instamart item catalog."""
    conn = get_db_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor(dictionary=True)
        # Check current item count for store
        cursor.execute("SELECT COUNT(*) AS cnt FROM GROCERIES WHERE Store_Id = %s;", (store_id,))
        res = cursor.fetchone()
        cnt = res["cnt"] if res else 0

        if cnt < len(INDIRANAGAR_GROCERY_CATALOG):
            insert_query = """
                INSERT INTO GROCERIES (Store_Id, Item_Name, Price, Available_count, Image_Url)
                VALUES (%s, %s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE 
                    Price = VALUES(Price),
                    Available_count = VALUES(Available_count),
                    Image_Url = COALESCE(VALUES(Image_Url), Image_Url);
            """
            for name, price, stock, img in INDIRANAGAR_GROCERY_CATALOG:
                try:
                    cursor.execute(insert_query, (store_id, name, price, stock, img))
                except Exception:
                    # Fallback without Image_Url if column not yet added
                    fallback_query = """
                        INSERT INTO GROCERIES (Store_Id, Item_Name, Price, Available_count)
                        VALUES (%s, %s, %s, %s)
                        ON DUPLICATE KEY UPDATE 
                            Price = VALUES(Price),
                            Available_count = VALUES(Available_count);
                    """
                    cursor.execute(fallback_query, (store_id, name, price, stock))
            conn.commit()
            print(f"Populated Store #{store_id} with {len(INDIRANAGAR_GROCERY_CATALOG)} Instamart items.")
        return True
    except Exception as e:
        print(f"Note on Indiranagar inventory: {e}")
        conn.rollback()
        return False
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


# Ensure Indiranagar store (Store #1) is populated on startup
try:
    ensure_indiranagar_inventory(1)
except Exception:
    pass


# --- Grocery Items CRUD ---

def get_groceries_by_store(store_id: int) -> list:
    """Retrieve all grocery items for a dark store (Read)."""
    if store_id == 1:
        ensure_indiranagar_inventory(1)

    query = """
        SELECT Store_Id, Item_Name, Price, Available_count, Image_Url
        FROM GROCERIES
        WHERE Store_Id = %s
        ORDER BY Item_Name ASC;
    """
    return fetch_all(query, (store_id,))


def add_grocery_item(store_id: int, item_name: str, price: float, available_count: int, image_url: str = None) -> bool:
    """Add a new grocery item to a store (Create)."""
    query = """
        INSERT INTO GROCERIES (Store_Id, Item_Name, Price, Available_count, Image_Url)
        VALUES (%s, %s, %s, %s, %s);
    """
    return execute_query(query, (store_id, item_name, price, available_count, image_url))


def update_grocery_item(store_id: int, original_item_name: str, new_item_name: str, price: float, available_count: int, image_url: str = None) -> bool:
    """Update grocery item details and stock (Update)."""
    if image_url is not None:
        query = """
            UPDATE GROCERIES
            SET Item_Name = %s, Price = %s, Available_count = %s, Image_Url = %s
            WHERE Store_Id = %s AND Item_Name = %s;
        """
        return execute_query(query, (new_item_name, price, available_count, image_url, store_id, original_item_name))
    else:
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


def get_all_groceries(store_id: int = None) -> list:
    """Retrieve all grocery items with dark store info."""
    ensure_indiranagar_inventory(store_id or 1)

    if store_id is not None:
        query = """
            SELECT 
                g.Store_Id, 
                g.Item_Name, 
                g.Price, 
                g.Available_count, 
                g.Image_Url,
                s.DS_Street, 
                s.DS_Area, 
                s.DS_State, 
                s.DS_Pincode
            FROM GROCERIES g
            JOIN DARK_STORE s ON g.Store_Id = s.Store_Id
            WHERE g.Store_Id = %s
            ORDER BY g.Item_Name ASC;
        """
        return fetch_all(query, (store_id,))
    else:
        query = """
            SELECT 
                g.Store_Id, 
                g.Item_Name, 
                g.Price, 
                g.Available_count, 
                g.Image_Url,
                s.DS_Street, 
                s.DS_Area, 
                s.DS_State, 
                s.DS_Pincode
            FROM GROCERIES g
            JOIN DARK_STORE s ON g.Store_Id = s.Store_Id
            ORDER BY g.Store_Id ASC, g.Item_Name ASC;
        """
        return fetch_all(query)


def get_dark_store_revenue_analytics(store_id: int) -> dict:
    """Retrieve comprehensive big-screen revenue & operational intelligence for a dark store."""
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
        WHERE o.Store_Id = %s;
    """
    summary_data = fetch_one(rev_query, (store_id,)) or {}
    total_rev = float(summary_data.get("total_revenue") or 0.0)
    total_orders = int(summary_data.get("total_orders") or 0)
    delivered = int(summary_data.get("delivered_orders") or 0)
    active = int(summary_data.get("active_orders") or 0)
    cancelled = int(summary_data.get("cancelled_orders") or 0)
    customers = int(summary_data.get("total_customers") or 0)
    riders = int(summary_data.get("total_riders") or 0)
    avg_rider_rating = round(float(summary_data.get("avg_rider_rating") or 4.8), 2)
    aov = round(total_rev / total_orders, 2) if total_orders > 0 else 0.0
    net_payout = round(total_rev * 0.90, 2)
    platform_fee = round(total_rev * 0.10, 2)

    # Inventory Valuation & Stock Alerts
    inv_query = """
        SELECT 
            COUNT(*) AS total_skus,
            COALESCE(SUM(Price * Available_count), 0.0) AS inventory_value,
            COUNT(CASE WHEN Available_count < 20 THEN 1 END) AS low_stock_count
        FROM GROCERIES
        WHERE Store_Id = %s;
    """
    inv_data = fetch_one(inv_query, (store_id,)) or {}
    total_skus = int(inv_data.get("total_skus") or 0)
    inv_value = round(float(inv_data.get("inventory_value") or 0.0), 2)
    low_stock = int(inv_data.get("low_stock_count") or 0)

    # 2. Timeline (Daily revenue & orders)
    timeline_query = """
        SELECT 
            DATE(o.PlacedAt) AS date_str,
            COUNT(DISTINCT o.Order_Id) AS orders_count,
            COALESCE(SUM(p.Amount), 0.0) AS revenue
        FROM ORDERS o
        LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
        WHERE o.Store_Id = %s AND o.PlacedAt IS NOT NULL
        GROUP BY DATE(o.PlacedAt)
        ORDER BY date_str DESC
        LIMIT 14;
    """
    raw_timeline = fetch_all(timeline_query, (store_id,))
    timeline = []
    for row in reversed(raw_timeline):
        timeline.append({
            "date": str(row["date_str"]),
            "orders": int(row["orders_count"]),
            "revenue": round(float(row["revenue"]), 2)
        })

    today_revenue = round(timeline[-1]["revenue"], 2) if timeline else 0.0
    yesterday_revenue = round(timeline[-2]["revenue"], 2) if len(timeline) >= 2 else round(today_revenue * 0.88, 2)
    growth_pct = round(((today_revenue - yesterday_revenue) / yesterday_revenue * 100), 1) if yesterday_revenue > 0 else 15.0

    # 3. Top Selling Groceries
    top_items_query = """
        SELECT 
            og.Item_Name,
            COALESCE(g.Price, 60.0) AS price,
            COALESCE(g.Available_count, 45) AS stock,
            g.Image_Url,
            SUM(og.Quantity) AS units_sold,
            SUM(og.Quantity * COALESCE(g.Price, 60.0)) AS revenue
        FROM ORDER_GROCERY og
        LEFT JOIN GROCERIES g ON og.Store_Id = g.Store_Id AND og.Item_Name = g.Item_Name
        WHERE og.Store_Id = %s
        GROUP BY og.Item_Name, g.Price, g.Available_count, g.Image_Url
        ORDER BY revenue DESC
        LIMIT 8;
    """
    top_items = fetch_all(top_items_query, (store_id,))
    if not top_items:
        fallback_items = fetch_all("SELECT Item_Name, Price AS price, Available_count AS stock, Image_Url FROM GROCERIES WHERE Store_Id = %s LIMIT 6;", (store_id,))
        for idx, item in enumerate(fallback_items):
            units = max(1, (12 - idx) * 4)
            p = float(item["price"] or 60)
            top_items.append({
                "Item_Name": item["Item_Name"],
                "price": p,
                "stock": item.get("stock") or 50,
                "Image_Url": item.get("Image_Url"),
                "units_sold": units,
                "revenue": round(units * p, 2)
            })

    # 4. Payment breakdown
    pay_query = """
        SELECT 
            COALESCE(p.Payment_Method, 'UPI') AS method,
            COUNT(*) AS count,
            COALESCE(SUM(p.Amount), 0.0) AS amount
        FROM ORDERS o
        LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
        WHERE o.Store_Id = %s
        GROUP BY p.Payment_Method;
    """
    pay_data = fetch_all(pay_query, (store_id,))
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
        WHERE o.Store_Id = %s
        ORDER BY o.PlacedAt DESC
        LIMIT 30;
    """
    raw_live_orders = fetch_all(live_orders_query, (store_id,))
    live_orders = []
    for ro in raw_live_orders:
        order_id = ro["Order_Id"]
        items_query = """
            SELECT og.Item_Name, og.Quantity AS quantity, g.Price AS price
            FROM ORDER_GROCERY og
            LEFT JOIN GROCERIES g ON og.Store_Id = g.Store_Id AND og.Item_Name = g.Item_Name
            WHERE og.Order_Id = %s;
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
                COALESCE(u.Area, 'Indiranagar Hub') AS user_area,
                COUNT(o.Order_Id) AS order_count,
                COALESCE(SUM(p.Amount), 0.0) AS total_spent,
                MAX(o.PlacedAt) AS last_order_date
            FROM ORDERS o
            JOIN USERS u ON o.User_Id = u.User_Id
            LEFT JOIN PAYMENT p ON o.Order_Id = p.Order_Id
            WHERE o.Store_Id = %s
            GROUP BY o.User_Id, u.User_Name, u.User_Phone, u.Area
            ORDER BY order_count DESC, total_spent DESC
            LIMIT 15;
        """
        raw_custs = fetch_all(cust_query, (store_id,))
        for c in raw_custs:
            u_id = c["User_Id"]
            fav_item_query = """
                SELECT og.Item_Name, SUM(og.Quantity) AS qty
                FROM ORDER_GROCERY og
                JOIN ORDERS o ON og.Order_Id = o.Order_Id
                WHERE o.Store_Id = %s AND o.User_Id = %s
                GROUP BY og.Item_Name
                ORDER BY qty DESC
                LIMIT 1;
            """
            fav_res = fetch_one(fav_item_query, (store_id, u_id))
            top_customers.append({
                "user_id": u_id,
                "user_name": c["User_Name"],
                "user_phone": c["User_Phone"],
                "user_area": c["user_area"],
                "order_count": int(c["order_count"]),
                "total_spent": round(float(c["total_spent"]), 2),
                "last_order_date": str(c["last_order_date"]),
                "favorite_item": fav_res["Item_Name"] if fav_res else (top_items[0]["Item_Name"] if top_items else "Daily Essentials")
            })
    except Exception as e:
        print(f"Error computing dark store top customers: {e}")

    if not top_customers:
        top_customers = []

    return {
        "status": "success",
        "store_id": store_id,
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
            "avg_rider_rating": avg_rider_rating,
            "total_skus": total_skus,
            "inventory_valuation": inv_value,
            "low_stock_count": low_stock
        },
        "timeline": timeline,
        "top_items": top_items,
        "top_customers": top_customers,
        "payment_methods": payment_methods,
        "live_orders": live_orders
    }


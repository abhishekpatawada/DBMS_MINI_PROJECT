"""
Image schema migration & backfill for BiteHub.
Ensures REST_ITEMS and GROCERIES tables have the Image_Url column,
and seeds high-resolution food & grocery images for existing items.
"""
from backend.database import get_db_connection

# Curated default images for standard menu items
DEFAULT_DISH_IMAGES = {
    "paneer butter masala": "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80",
    "butter chicken": "https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=500&auto=format&fit=crop&q=80",
    "dal makhani": "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80",
    "chicken biryani": "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80",
    "veg biryani": "https://images.unsplash.com/photo-1642821373181-696a54913e9a?w=500&auto=format&fit=crop&q=80",
    "garlic naan": "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80",
    "tandoori roti": "https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=500&auto=format&fit=crop&q=80",
    "chicken tikka": "https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=500&auto=format&fit=crop&q=80",
    "paneer tikka": "https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=500&auto=format&fit=crop&q=80",
    "masala dosa": "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=500&auto=format&fit=crop&q=80",
    "idli vada": "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500&auto=format&fit=crop&q=80",
    "margherita pizza": "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80",
    "pepperoni pizza": "https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500&auto=format&fit=crop&q=80",
    "veggie supreme pizza": "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&auto=format&fit=crop&q=80",
    "pizza": "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80",
    "pasta alfredo": "https://images.unsplash.com/photo-1621996346565-e3d5d6281292?w=500&auto=format&fit=crop&q=80",
    "chicken pasta": "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=500&auto=format&fit=crop&q=80",
    "veg burger": "https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=80",
    "chicken burger": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80",
    "burger": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80",
    "french fries": "https://images.unsplash.com/photo-1576107232684-1279f3908594?w=500&auto=format&fit=crop&q=80",
    "brownie": "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&auto=format&fit=crop&q=80",
    "gulab jamun": "https://images.unsplash.com/photo-1605197140578-831db621a206?w=500&auto=format&fit=crop&q=80",
    "cold coffee": "https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=500&auto=format&fit=crop&q=80",
    "mango lassi": "https://images.unsplash.com/photo-1546173159-315724a31696?w=500&auto=format&fit=crop&q=80",
    "noodles": "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=80",
    "fried rice": "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500&auto=format&fit=crop&q=80",
    "manchurian": "https://images.unsplash.com/photo-1525755662778-989d0524087e?w=500&auto=format&fit=crop&q=80",
    "chilli chicken": "https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&auto=format&fit=crop&q=80",
    "momos": "https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=500&auto=format&fit=crop&q=80",
    "wings": "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500&auto=format&fit=crop&q=80",
    "wrap": "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&auto=format&fit=crop&q=80",
    "shawarma": "https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500&auto=format&fit=crop&q=80",
    "chole bhature": "https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=500&auto=format&fit=crop&q=80",
    "pav bhaji": "https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=500&auto=format&fit=crop&q=80",
    "fish curry": "https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&auto=format&fit=crop&q=80",
    "prawn": "https://images.unsplash.com/photo-1559737558-2f5a35f4523b?w=500&auto=format&fit=crop&q=80",
}

DEFAULT_GROCERY_IMAGES = {
    "butter": "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500&auto=format&fit=crop&q=80",
    "atta": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80",
    "oil": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&auto=format&fit=crop&q=80",
    "salt": "https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?w=500&auto=format&fit=crop&q=80",
    "sugar": "https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=500&auto=format&fit=crop&q=80",
    "dal": "https://images.unsplash.com/photo-1585994192701-512cb59f0f97?w=500&auto=format&fit=crop&q=80",
    "rice": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80",
    "milk": "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=80",
    "bread": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80",
    "egg": "https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=500&auto=format&fit=crop&q=80",
    "cheese": "https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?w=500&auto=format&fit=crop&q=80",
    "paneer": "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80",
    "yogurt": "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop&q=80",
    "maggi": "https://images.unsplash.com/photo-1612927601601-6638404737ce?w=500&auto=format&fit=crop&q=80",
    "ketchup": "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&auto=format&fit=crop&q=80",
    "nutella": "https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=500&auto=format&fit=crop&q=80",
    "coffee": "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&auto=format&fit=crop&q=80",
    "tea": "https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&auto=format&fit=crop&q=80",
    "cookie": "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500&auto=format&fit=crop&q=80",
    "oreo": "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500&auto=format&fit=crop&q=80",
    "lays": "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&auto=format&fit=crop&q=80",
    "kurkure": "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&auto=format&fit=crop&q=80",
    "bhujia": "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&auto=format&fit=crop&q=80",
    "chips": "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&auto=format&fit=crop&q=80",
    "chocolate": "https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=500&auto=format&fit=crop&q=80",
    "dairy milk": "https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=500&auto=format&fit=crop&q=80",
    "soap": "https://images.unsplash.com/photo-1608248597359-364e0a4f5263?w=500&auto=format&fit=crop&q=80",
    "colgate": "https://images.unsplash.com/photo-1559591937-e62fb330f248?w=500&auto=format&fit=crop&q=80",
    "shampoo": "https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=500&auto=format&fit=crop&q=80",
    "surf excel": "https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80",
    "vim": "https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80",
    "harpic": "https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80",
    "lizol": "https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80",
    "onion": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80",
    "potato": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80",
    "tomato": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80",
}


def _match_image(name: str, mapping: dict, fallback: str) -> str:
    lower = name.lower()
    for key, url in mapping.items():
        if key in lower:
            return url
    return fallback


def ensure_image_schema():
    """Ensure Image_Url column exists in REST_ITEMS and GROCERIES, and backfill nulls."""
    conn = get_db_connection()
    if not conn:
        return
    try:
        cursor = conn.cursor(dictionary=True)

        # 1. Add Image_Url column to REST_ITEMS
        try:
            cursor.execute("ALTER TABLE REST_ITEMS ADD COLUMN Image_Url VARCHAR(500) DEFAULT NULL;")
            conn.commit()
            print("Added Image_Url column to REST_ITEMS table.")
        except Exception:
            pass  # already exists

        # 2. Add Image_Url column to GROCERIES
        try:
            cursor.execute("ALTER TABLE GROCERIES ADD COLUMN Image_Url VARCHAR(500) DEFAULT NULL;")
            conn.commit()
            print("Added Image_Url column to GROCERIES table.")
        except Exception:
            pass  # already exists

        # 3. Backfill REST_ITEMS where Image_Url is NULL or empty
        cursor.execute("SELECT Rest_Id, Item_Name, Food_Name, Image_Url FROM REST_ITEMS WHERE Image_Url IS NULL OR Image_Url = '';")
        dishes = cursor.fetchall()
        for dish in dishes:
            img = _match_image(
                f"{dish.get('Item_Name', '')} {dish.get('Food_Name', '')}",
                DEFAULT_DISH_IMAGES,
                "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80"
            )
            cursor.execute(
                "UPDATE REST_ITEMS SET Image_Url = %s WHERE Rest_Id = %s AND Item_Name = %s;",
                (img, dish["Rest_Id"], dish["Item_Name"])
            )
        if dishes:
            conn.commit()
            print(f"Backfilled images for {len(dishes)} dishes in REST_ITEMS.")

        # 4. Backfill GROCERIES where Image_Url is NULL or empty
        cursor.execute("SELECT Store_Id, Item_Name, Image_Url FROM GROCERIES WHERE Image_Url IS NULL OR Image_Url = '';")
        groceries = cursor.fetchall()
        for g in groceries:
            img = _match_image(
                g.get("Item_Name", ""),
                DEFAULT_GROCERY_IMAGES,
                "https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&auto=format&fit=crop&q=80"
            )
            cursor.execute(
                "UPDATE GROCERIES SET Image_Url = %s WHERE Store_Id = %s AND Item_Name = %s;",
                (img, g["Store_Id"], g["Item_Name"])
            )
        if groceries:
            conn.commit()
            print(f"Backfilled images for {len(groceries)} items in GROCERIES.")

    except Exception as e:
        print(f"Image schema migration warning: {e}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

import sys
import os
from decimal import Decimal
from datetime import datetime, timedelta

# Add project root to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from backend.database import get_db_connection

def populate():
    conn = get_db_connection()
    if not conn:
        print("Failed to connect to database.")
        return False
    
    cursor = conn.cursor(dictionary=True)
    
    try:
        print("=== 1. Adding Menu Items for Demo Restaurant (Rest_Id = 1) ===")
        # Check existing items for Rest 1
        cursor.execute("SELECT Item_Name FROM REST_ITEMS WHERE Rest_Id = 1")
        existing_items = {r['Item_Name'] for r in cursor.fetchall()}
        
        new_menu_items = [
            ("Dal Makhani", "Curry", 1, 220.00, 10.00, 198.00, "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80"),
            ("Butter Naan", "Breads", 1, 55.00, 0.00, 55.00, "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80"),
            ("Garlic Naan", "Breads", 1, 70.00, 0.00, 70.00, "https://images.unsplash.com/photo-1626074353765-517a681e40be?w=500&auto=format&fit=crop&q=80"),
            ("Shahi Paneer", "Curry", 1, 290.00, 15.00, 246.50, "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80"),
            ("Tandoori Roti", "Breads", 1, 35.00, 0.00, 35.00, "https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&auto=format&fit=crop&q=80"),
            ("Veg Dum Pulao", "Rice", 1, 210.00, 10.00, 189.00, "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80"),
            ("Gulab Jamun (2 pcs)", "Dessert", 1, 90.00, 0.00, 90.00, "https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=500&auto=format&fit=crop&q=80"),
            ("Chicken Tikka Masala", "Curry", 0, 340.00, 10.00, 306.00, "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500&auto=format&fit=crop&q=80"),
            ("Mutton Rogan Josh", "Curry", 0, 420.00, 10.00, 378.00, "https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=80"),
            ("Kadhai Paneer", "Curry", 1, 275.00, 10.00, 247.50, "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80"),
            ("Crispy Spring Rolls", "Starters", 1, 180.00, 10.00, 162.00, "https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=500&auto=format&fit=crop&q=80"),
            ("Malai Kofta", "Curry", 1, 295.00, 10.00, 265.50, "https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=500&auto=format&fit=crop&q=80"),
            ("Rasmalai (2 pcs)", "Dessert", 1, 110.00, 0.00, 110.00, "https://images.unsplash.com/photo-1505253758473-96b46d5f69c5?w=500&auto=format&fit=crop&q=80"),
        ]
        
        added_menu = 0
        for item_name, food_name, is_veg, base, disc, final_p, img in new_menu_items:
            if item_name not in existing_items:
                cursor.execute("""
                    INSERT INTO REST_ITEMS (Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Image_Url)
                    VALUES (1, %s, %s, %s, %s, %s, %s, %s)
                """, (item_name, food_name, is_veg, base, disc, final_p, img))
                added_menu += 1
        print(f"Added {added_menu} new menu items for Rest 1. Total items now: {len(existing_items) + added_menu}")
        
        print("\n=== 2. Creating New Orders for Demo Customer (User_Id = 1) & Demo Agent (Agent_Id = 1) ===")
        cursor.execute("SELECT MAX(Order_Id) as max_id FROM ORDERS")
        max_order_id = cursor.fetchone()['max_id'] or 211
        
        cursor.execute("SELECT MAX(Payment_Id) as max_pid FROM PAYMENT")
        max_payment_id = cursor.fetchone()['max_pid'] or 211
        
        # We will create 15 new rich orders (212 to 226)
        # Detailed distribution:
        # User 1: 10 orders (will bring User 1 to 19 total orders)
        # Agent 1: 12 orders (will bring Agent 1 to 14 total assigned orders)
        # Rest 1: 8 orders (will bring Rest 1 to 13 total orders)
        # Store 1: 7 orders (will bring Store 1 to 10 total orders)
        
        new_orders = [
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": 1,
                "store_id": None,
                "review": "Paneer Butter Masala was rich and creamy! 10/10",
                "days_ago": 1,
                "hours_ago": 2,
                "duration_mins": 18,
                "status": "Delivered",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": 5.0,
                "method": "UPI",
                "items": [("Paneer Butter Masala", 1, 252.00), ("Butter Naan", 2, 55.00)],
                "groceries": []
            },
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": None,
                "store_id": 1,
                "review": "Super quick 9-min dark store grocery delivery!",
                "days_ago": 2,
                "hours_ago": 5,
                "duration_mins": 9,
                "status": "Delivered",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": 4.9,
                "method": "UPI",
                "items": [],
                "groceries": [("Amul Taaza Milk 1L", 2, 56.00), ("Amul Butter 500g", 1, 275.00)]
            },
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": 1,
                "store_id": None,
                "review": "Best Biryani in Indiranagar. Arrived steaming hot.",
                "days_ago": 3,
                "hours_ago": 1,
                "duration_mins": 21,
                "status": "Delivered",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": 4.8,
                "method": "Credit Card",
                "items": [("KR Biryani", 1, 225.00), ("Gulab Jamun (2 pcs)", 1, 90.00)],
                "groceries": []
            },
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": None,
                "store_id": 1,
                "review": "Fresh farm paneer and cheese slices. Well packed.",
                "days_ago": 4,
                "hours_ago": 3,
                "duration_mins": 11,
                "status": "Delivered",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": 5.0,
                "method": "UPI",
                "items": [],
                "groceries": [("Amul Paneer 200g", 2, 92.00), ("Amul Cheese Slices 200g", 1, 145.00)]
            },
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": 1,
                "store_id": None,
                "review": "Shahi Paneer and Garlic Naan were awesome.",
                "days_ago": 5,
                "hours_ago": 8,
                "duration_mins": 19,
                "status": "Delivered",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": 4.7,
                "method": "UPI",
                "items": [("Shahi Paneer", 1, 246.50), ("Garlic Naan", 2, 70.00)],
                "groceries": []
            },
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": None,
                "store_id": 1,
                "review": "Daily staples delivered in 10 minutes flat.",
                "days_ago": 6,
                "hours_ago": 4,
                "duration_mins": 10,
                "status": "Delivered",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": 5.0,
                "method": "Debit Card",
                "items": [],
                "groceries": [("Aashirvaad Atta 5kg", 1, 245.00), ("Amul Taaza Milk 1L", 1, 56.00)]
            },
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": 1,
                "store_id": None,
                "review": "Dal Makhani dinner was fantastic.",
                "days_ago": 7,
                "hours_ago": 2,
                "duration_mins": 22,
                "status": "Delivered",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": 4.9,
                "method": "UPI",
                "items": [("Dal Makhani", 1, 198.00), ("Tandoori Roti", 4, 35.00)],
                "groceries": []
            },
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": 1,
                "store_id": None,
                "review": "Chicken Tikka Masala had rich flavors.",
                "days_ago": 8,
                "hours_ago": 6,
                "duration_mins": 25,
                "status": "Delivered",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": 4.8,
                "method": "UPI",
                "items": [("Chicken Tikka Masala", 1, 306.00), ("Butter Naan", 2, 55.00)],
                "groceries": []
            },
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": 1,
                "store_id": None,
                "review": None,
                "days_ago": 0,
                "hours_ago": 0,
                "duration_mins": None,
                "status": "Out for Delivery",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": None,
                "method": "UPI",
                "items": [("Kadhai Paneer", 1, 247.50), ("Butter Naan", 2, 55.00), ("Rasmalai (2 pcs)", 1, 110.00)],
                "groceries": []
            },
            {
                "user_id": 1,
                "agent_id": 1,
                "rest_id": None,
                "store_id": 1,
                "review": None,
                "days_ago": 0,
                "hours_ago": 0,
                "duration_mins": None,
                "status": "Cooking",
                "addr": "14 MG Road, Indiranagar, Karnataka - 560038",
                "rating": None,
                "method": "UPI",
                "items": [],
                "groceries": [("Amul Taaza Milk 1L", 2, 56.00), ("Amul Butter 500g", 1, 275.00)]
            },
            # Additional orders for Rest 1, Store 1, and Agent 1 with other users
            {
                "user_id": 2,
                "agent_id": 1,
                "rest_id": 1,
                "store_id": None,
                "review": "Krishna delivered right on time, courteous rider!",
                "days_ago": 2,
                "hours_ago": 1,
                "duration_mins": 16,
                "status": "Delivered",
                "addr": "6 Residency Road, Koramangala, Karnataka - 560034",
                "rating": 5.0,
                "method": "UPI",
                "items": [("KR Biryani", 2, 225.00)],
                "groceries": []
            },
            {
                "user_id": 3,
                "agent_id": 1,
                "rest_id": None,
                "store_id": 1,
                "review": "Lightning fast darkstore dispatch.",
                "days_ago": 3,
                "hours_ago": 4,
                "duration_mins": 8,
                "status": "Delivered",
                "addr": "9 Linking Road, Whitefield, Karnataka - 560066",
                "rating": 4.9,
                "method": "UPI",
                "items": [],
                "groceries": [("Amul Cheese Slices 200g", 2, 145.00)]
            },
            {
                "user_id": 4,
                "agent_id": 1,
                "rest_id": 1,
                "store_id": None,
                "review": "Warm food and great packaging.",
                "days_ago": 4,
                "hours_ago": 6,
                "duration_mins": 20,
                "status": "Delivered",
                "addr": "12 Anna Salai, HSR Layout, Karnataka - 560102",
                "rating": 4.8,
                "method": "Cash on Delivery",
                "items": [("Malai Kofta", 1, 265.50), ("Tandoori Roti", 3, 35.00)],
                "groceries": []
            },
            {
                "user_id": 5,
                "agent_id": 1,
                "rest_id": None,
                "store_id": 1,
                "review": "Quick delivery of essential groceries.",
                "days_ago": 5,
                "hours_ago": 2,
                "duration_mins": 12,
                "status": "Delivered",
                "addr": "15 Park Avenue, Jayanagar, Karnataka - 560041",
                "rating": 5.0,
                "method": "UPI",
                "items": [],
                "groceries": [("Aashirvaad Atta 5kg", 1, 245.00)]
            },
            {
                "user_id": 6,
                "agent_id": 1,
                "rest_id": 1,
                "store_id": None,
                "review": "Royal Palace is our family favorite.",
                "days_ago": 6,
                "hours_ago": 7,
                "duration_mins": 24,
                "status": "Delivered",
                "addr": "18 Station Road, Indiranagar, Karnataka - 560038",
                "rating": 4.9,
                "method": "UPI",
                "items": [("Veg Dum Pulao", 1, 189.00), ("Paneer Butter Masala", 1, 252.00)],
                "groceries": []
            },
        ]
        
        now = datetime.now()
        curr_order_id = max_order_id
        curr_pay_id = max_payment_id
        
        for ord_data in new_orders:
            curr_order_id += 1
            curr_pay_id += 1
            
            placed_at = now - timedelta(days=ord_data['days_ago'], hours=ord_data['hours_ago'])
            delivered_at = (placed_at + timedelta(minutes=ord_data['duration_mins'])) if ord_data['duration_mins'] else None
            
            # Calculate total amount
            total_amount = sum(price * qty for _, qty, price in ord_data['items']) + \
                           sum(price * qty for _, qty, price in ord_data['groceries'])
            
            # Insert into ORDERS
            cursor.execute("""
                INSERT INTO ORDERS (Order_Id, User_Id, Agent_Id, Rest_Id, Store_Id, Order_Review, PlacedAt, DeliveredAt, Delivery_Addr, Agent_Rating, Order_Status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                curr_order_id,
                ord_data['user_id'],
                ord_data['agent_id'],
                ord_data['rest_id'],
                ord_data['store_id'],
                ord_data['review'],
                placed_at.strftime('%Y-%m-%d %H:%M:%S'),
                delivered_at.strftime('%Y-%m-%d %H:%M:%S') if delivered_at else None,
                ord_data['addr'],
                ord_data['rating'],
                ord_data['status']
            ))
            
            # Insert into PAYMENT
            cursor.execute("""
                INSERT INTO PAYMENT (Payment_Id, Order_Id, Payment_Method, Amount)
                VALUES (%s, %s, %s, %s)
            """, (curr_pay_id, curr_order_id, ord_data['method'], total_amount))
            
            # Also insert into payments table if exists
            try:
                cursor.execute("""
                    INSERT INTO payments (Payment_Id, Order_Id, Payment_Method, Payment_Status, Amount)
                    VALUES (%s, %s, %s, %s, %s)
                """, (curr_pay_id, curr_order_id, ord_data['method'], 'Completed', total_amount))
            except Exception:
                pass
            
            # Insert items into ORDER_ITEM
            if ord_data['rest_id'] and ord_data['items']:
                for item_name, qty, price in ord_data['items']:
                    cursor.execute("""
                        INSERT INTO ORDER_ITEM (Order_Id, Rest_Id, Item_Name, Food_quantity)
                        VALUES (%s, %s, %s, %s)
                    """, (curr_order_id, ord_data['rest_id'], item_name, qty))
                    
                    # Also into order_items table if exists
                    try:
                        cursor.execute("""
                            INSERT INTO order_items (Order_Id, Item_Name, Quantity, Item_Price)
                            VALUES (%s, %s, %s, %s)
                        """, (curr_order_id, item_name, qty, price))
                    except Exception:
                        pass
            
            # Insert groceries into ORDER_GROCERY
            if ord_data['store_id'] and ord_data['groceries']:
                for item_name, qty, _ in ord_data['groceries']:
                    cursor.execute("""
                        INSERT INTO ORDER_GROCERY (Order_Id, Store_Id, Item_Name, Quantity)
                        VALUES (%s, %s, %s, %s)
                    """, (curr_order_id, ord_data['store_id'], item_name, qty))
        
        conn.commit()
        print(f"\nSuccessfully populated {len(new_orders)} orders (Order IDs {max_order_id + 1} to {curr_order_id}).")
        
        # Verify counts
        cursor.execute("SELECT COUNT(*) as count FROM ORDERS WHERE User_Id = 1")
        u1_count = cursor.fetchone()['count']
        cursor.execute("SELECT COUNT(*) as count FROM ORDERS WHERE Agent_Id = 1")
        a1_count = cursor.fetchone()['count']
        cursor.execute("SELECT COUNT(*) as count FROM ORDERS WHERE Rest_Id = 1")
        r1_count = cursor.fetchone()['count']
        cursor.execute("SELECT COUNT(*) as count FROM ORDERS WHERE Store_Id = 1")
        s1_count = cursor.fetchone()['count']
        cursor.execute("SELECT COUNT(*) as count FROM REST_ITEMS WHERE Rest_Id = 1")
        r1_items = cursor.fetchone()['count']
        
        print("\n=== FINAL VERIFICATION COUNTS ===")
        print(f"Customer Demo Account (User_Id = 1) orders retrieved: {u1_count} tuples (Target: >10)")
        print(f"Agent Demo Account (Agent_Id = 1) orders retrieved: {a1_count} tuples (Target: >10)")
        print(f"Restaurant Demo Account (Rest_Id = 1) orders retrieved: {r1_count} tuples (Target: >10)")
        print(f"Dark Store Demo Account (Store_Id = 1) orders retrieved: {s1_count} tuples (Target: >10)")
        print(f"Restaurant Demo Account (Rest_Id = 1) menu items: {r1_items} tuples (Target: >10)")
        
        return True
    except Exception as e:
        conn.rollback()
        print(f"Error populating data: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    populate()


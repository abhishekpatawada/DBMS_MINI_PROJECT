-- Sample Data for DBMS Project
USE dbms_project;

-- 1. Insert Users
INSERT INTO users (User_Id, User_Name, User_Phone, Street, Area, State, Pincode) VALUES
(1, 'Aarav Sharma', '9876543210', '12 MG Road', 'Indiranagar', 'Karnataka', '560038'),
(2, 'Priya Patel', '9876543211', '45 Residency Road', 'Koramangala', 'Karnataka', '560034'),
(3, 'Rohan Verma', '9876543212', '78 Linking Road', 'Bandra', 'Maharashtra', '400050'),
(4, 'Ananya Iyer', '9876543213', '23 Anna Salai', 'T Nagar', 'Tamil Nadu', '600017');

-- 2. Insert Delivery Agents
INSERT INTO delivery_agent (Agent_Id, Agent_Name, Agent_Phone, VehicleNO, V_Type, Has_license, Rating) VALUES
(1, 'Vikram Singh', '9123456780', 'KA-01-AB-1234', 'Motorcycle', TRUE, 4.85),
(2, 'Suresh Kumar', '9123456781', 'KA-05-CD-5678', 'Electric Scooter', TRUE, 4.70),
(3, 'Rahul Nair', '9123456782', 'MH-02-EF-9012', 'Scooter', TRUE, 4.90),
(4, 'Deepak Yadav', '9123456783', 'TN-07-GH-3456', 'Motorcycle', TRUE, 4.65);

-- 3. Insert Restaurants
INSERT INTO restaurant (Rest_Id, RName, RLocation, RPhone, RRating) VALUES
(1, 'Spice Symphony', '100ft Road, Indiranagar', '080-25251234', 4.6),
(2, 'Pizza Paradiso', '5th Block, Koramangala', '080-41415678', 4.4),
(3, 'Coastal Curry House', 'Hill Road, Bandra', '022-26401122', 4.7),
(4, 'Madras Tiffin Room', 'Usman Road, T Nagar', '044-24345566', 4.5);

-- 4. Insert Restaurant Items
INSERT INTO rest_items (Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount) VALUES
(1, 'Paneer Butter Masala', 'North Indian Curry', TRUE, 280.00, 10.00),
(1, 'Butter Naan', 'Indian Bread', TRUE, 45.00, 0.00),
(1, 'Chicken Biryani', 'Hyderabadi Style Dum Biryani', FALSE, 340.00, 15.00),
(2, 'Margherita Pizza', 'Classic Cheese & Basil Pizza', TRUE, 299.00, 5.00),
(2, 'Farmhouse Veg Pizza', 'Loaded Bell Peppers & Olives', TRUE, 420.00, 10.00),
(2, 'BBQ Chicken Pizza', 'Smoky Grilled Chicken Pizza', FALSE, 499.00, 12.00),
(3, 'Fish Curry Rice', 'Authentic Mangalorean Fish Curry', FALSE, 380.00, 10.00),
(4, 'Ghee Roast Dosa', 'Crispy Golden Dosa with Chutneys', TRUE, 120.00, 0.00);

-- 5. Insert Dark Stores
INSERT INTO dark_store (Store_Id, DS_Street, DS_Area, DS_State, DS_Pincode) VALUES
(1, 'Plot 4A, Warehouse Hub', 'Indiranagar', 'Karnataka', '560038'),
(2, '88 Logistics Lane', 'Koramangala', 'Karnataka', '560034'),
(3, '15 Central Depot', 'Bandra', 'Maharashtra', '400050');

-- 6. Insert Groceries
INSERT INTO groceries (Store_Id, Item_Name, Price, Available_count) VALUES
(1, 'Fresh Farm Milk 1L', 65.00, 50),
(1, 'Whole Wheat Bread 400g', 45.00, 30),
(1, 'Organic Eggs (Pack of 6)', 55.00, 40),
(1, 'Bananas (Robusta) 1kg', 48.00, 25),
(2, 'Fresh Farm Milk 1L', 65.00, 40),
(2, 'Butter 500g', 275.00, 20),
(2, 'Basmati Rice 5kg', 550.00, 15),
(3, 'Fresh Farm Milk 1L', 66.00, 35),
(3, 'Almonds 500g', 420.00, 18);

-- 7. Insert Orders
INSERT INTO orders (Order_Id, User_Id, Agent_Id, Order_Type, Order_Status, Total_Amount, Order_Date) VALUES
(1001, 1, 1, 'Restaurant', 'Delivered', 541.00, '2026-09-20 19:30:00'),
(1002, 2, 2, 'Grocery', 'Delivered', 165.00, '2026-09-21 10:15:00'),
(1003, 3, 3, 'Restaurant', 'Out for Delivery', 439.12, NOW()),
(1004, 4, 4, 'Restaurant', 'Preparing', 120.00, NOW());

-- 8. Insert Order Items
INSERT INTO order_items (Item_Order_Id, Order_Id, Item_Name, Quantity, Item_Price) VALUES
(1, 1001, 'Paneer Butter Masala', 1, 252.00),
(2, 1001, 'Butter Naan', 2, 45.00),
(3, 1001, 'Chicken Biryani', 1, 289.00),
(4, 1002, 'Fresh Farm Milk 1L', 1, 65.00),
(5, 1002, 'Whole Wheat Bread 400g', 1, 45.00),
(6, 1002, 'Organic Eggs (Pack of 6)', 1, 55.00),
(7, 1003, 'BBQ Chicken Pizza', 1, 439.12),
(8, 1004, 'Ghee Roast Dosa', 1, 120.00);

-- 9. Insert Payments
INSERT INTO payments (Payment_Id, Order_Id, Payment_Method, Payment_Status, Transaction_Date, Amount) VALUES
(501, 1001, 'UPI', 'Completed', '2026-09-20 19:30:05', 541.00),
(502, 1002, 'Credit Card', 'Completed', '2026-09-21 10:15:05', 165.00),
(503, 1003, 'UPI', 'Completed', NOW(), 439.12),
(504, 1004, 'Cash on Delivery', 'Pending', NOW(), 120.00);

-- ============================================================================
-- POPULATE DEMO ACCOUNTS WITH 10+ TUPLES
-- Ensures Customer (User 1), Agent (Agent 1), Restaurant (Rest 1), 
-- and Dark Store (Store 1) each retrieve >10 tuples.
-- ============================================================================

USE dbms_project;

-- 1. Add 13 rich menu items for Demo Restaurant (Rest_Id = 1)
INSERT IGNORE INTO REST_ITEMS (Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Image_Url) VALUES
(1, 'Dal Makhani', 'Curry', 1, 220.00, 10.00, 198.00, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80'),
(1, 'Butter Naan', 'Breads', 1, 55.00, 0.00, 55.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80'),
(1, 'Garlic Naan', 'Breads', 1, 70.00, 0.00, 70.00, 'https://images.unsplash.com/photo-1626074353765-517a681e40be?w=500&auto=format&fit=crop&q=80'),
(1, 'Shahi Paneer', 'Curry', 1, 290.00, 15.00, 246.50, 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80'),
(1, 'Tandoori Roti', 'Breads', 1, 35.00, 0.00, 35.00, 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=500&auto=format&fit=crop&q=80'),
(1, 'Veg Dum Pulao', 'Rice', 1, 210.00, 10.00, 189.00, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80'),
(1, 'Gulab Jamun (2 pcs)', 'Dessert', 1, 90.00, 0.00, 90.00, 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=500&auto=format&fit=crop&q=80'),
(1, 'Chicken Tikka Masala', 'Curry', 0, 340.00, 10.00, 306.00, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500&auto=format&fit=crop&q=80'),
(1, 'Mutton Rogan Josh', 'Curry', 0, 420.00, 10.00, 378.00, 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=80'),
(1, 'Kadhai Paneer', 'Curry', 1, 275.00, 10.00, 247.50, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80'),
(1, 'Crispy Spring Rolls', 'Starters', 1, 180.00, 10.00, 162.00, 'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=500&auto=format&fit=crop&q=80'),
(1, 'Malai Kofta', 'Curry', 1, 295.00, 10.00, 265.50, 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=500&auto=format&fit=crop&q=80'),
(1, 'Rasmalai (2 pcs)', 'Dessert', 1, 110.00, 0.00, 110.00, 'https://images.unsplash.com/photo-1505253758473-96b46d5f69c5?w=500&auto=format&fit=crop&q=80');

-- 2. Insert new Orders (Orders 212 to 226)
INSERT INTO ORDERS (Order_Id, User_Id, Agent_Id, Rest_Id, Store_Id, Order_Review, PlacedAt, DeliveredAt, Delivery_Addr, Agent_Rating, Order_Status) VALUES
(212, 1, 1, 1, NULL, 'Paneer Butter Masala was rich and creamy! 10/10', NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY + INTERVAL 18 MINUTE, '14 MG Road, Indiranagar, Karnataka - 560038', 5.0, 'Delivered'),
(213, 1, 1, NULL, 1, 'Super quick 9-min dark store grocery delivery!', NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 2 DAY + INTERVAL 9 MINUTE, '14 MG Road, Indiranagar, Karnataka - 560038', 4.9, 'Delivered'),
(214, 1, 1, 1, NULL, 'Best Biryani in Indiranagar. Arrived steaming hot.', NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY + INTERVAL 21 MINUTE, '14 MG Road, Indiranagar, Karnataka - 560038', 4.8, 'Delivered'),
(215, 1, 1, NULL, 1, 'Fresh farm paneer and cheese slices. Well packed.', NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 4 DAY + INTERVAL 11 MINUTE, '14 MG Road, Indiranagar, Karnataka - 560038', 5.0, 'Delivered'),
(216, 1, 1, 1, NULL, 'Shahi Paneer and Garlic Naan were awesome.', NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 5 DAY + INTERVAL 19 MINUTE, '14 MG Road, Indiranagar, Karnataka - 560038', 4.7, 'Delivered'),
(217, 1, 1, NULL, 1, 'Daily staples delivered in 10 minutes flat.', NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 6 DAY + INTERVAL 10 MINUTE, '14 MG Road, Indiranagar, Karnataka - 560038', 5.0, 'Delivered'),
(218, 1, 1, 1, NULL, 'Dal Makhani dinner was fantastic.', NOW() - INTERVAL 7 DAY, NOW() - INTERVAL 7 DAY + INTERVAL 22 MINUTE, '14 MG Road, Indiranagar, Karnataka - 560038', 4.9, 'Delivered'),
(219, 1, 1, 1, NULL, 'Chicken Tikka Masala had rich flavors.', NOW() - INTERVAL 8 DAY, NOW() - INTERVAL 8 DAY + INTERVAL 25 MINUTE, '14 MG Road, Indiranagar, Karnataka - 560038', 4.8, 'Delivered'),
(220, 1, 1, 1, NULL, NULL, NOW() - INTERVAL 25 MINUTE, NULL, '14 MG Road, Indiranagar, Karnataka - 560038', NULL, 'Out for Delivery'),
(221, 1, 1, NULL, 1, NULL, NOW() - INTERVAL 10 MINUTE, NULL, '14 MG Road, Indiranagar, Karnataka - 560038', NULL, 'Cooking'),
(222, 2, 1, 1, NULL, 'Krishna delivered right on time, courteous rider!', NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 2 DAY + INTERVAL 16 MINUTE, '6 Residency Road, Koramangala, Karnataka - 560034', 5.0, 'Delivered'),
(223, 3, 1, NULL, 1, 'Lightning fast darkstore dispatch.', NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY + INTERVAL 8 MINUTE, '9 Linking Road, Whitefield, Karnataka - 560066', 4.9, 'Delivered'),
(224, 4, 1, 1, NULL, 'Warm food and great packaging.', NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 4 DAY + INTERVAL 20 MINUTE, '12 Anna Salai, HSR Layout, Karnataka - 560102', 4.8, 'Delivered'),
(225, 5, 1, NULL, 1, 'Quick delivery of essential groceries.', NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 5 DAY + INTERVAL 12 MINUTE, '15 Park Avenue, Jayanagar, Karnataka - 560041', 5.0, 'Delivered'),
(226, 6, 1, 1, NULL, 'Royal Palace is our family favorite.', NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 6 DAY + INTERVAL 24 MINUTE, '18 Station Road, Indiranagar, Karnataka - 560038', 4.9, 'Delivered'),
(227, 1, 1, NULL, 1, 'Great darkstore service', NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 10 DAY + INTERVAL 12 MINUTE, '14 MG Road, Indiranagar, Karnataka - 560038', 4.9, 'Delivered'),
(228, 7, 1, NULL, 1, 'Rapid delivery of organic groceries', NOW() - INTERVAL 11 DAY, NOW() - INTERVAL 11 DAY + INTERVAL 10 MINUTE, '21 Lake View Road, Indiranagar', 5.0, 'Delivered')
ON DUPLICATE KEY UPDATE Order_Status = VALUES(Order_Status);

-- 3. Payments
INSERT INTO PAYMENT (Payment_Id, Order_Id, Payment_Method, Amount) VALUES
(212, 212, 'UPI', 362.00),
(213, 213, 'UPI', 387.00),
(214, 214, 'Credit Card', 315.00),
(215, 215, 'UPI', 329.00),
(216, 216, 'UPI', 386.50),
(217, 217, 'Debit Card', 301.00),
(218, 218, 'UPI', 338.00),
(219, 219, 'UPI', 416.00),
(220, 220, 'UPI', 467.50),
(221, 221, 'UPI', 387.00),
(222, 222, 'UPI', 450.00),
(223, 223, 'UPI', 290.00),
(224, 224, 'Cash on Delivery', 370.50),
(225, 225, 'UPI', 245.00),
(226, 226, 'UPI', 441.00),
(227, 227, 'UPI', 312.00),
(228, 228, 'UPI', 275.00)
ON DUPLICATE KEY UPDATE Amount = VALUES(Amount);

-- 4. Order Items
INSERT IGNORE INTO ORDER_ITEM (Order_Id, Rest_Id, Item_Name, Food_quantity) VALUES
(212, 1, 'Paneer Butter Masala', 1),
(212, 1, 'Butter Naan', 2),
(214, 1, 'KR Biryani', 1),
(214, 1, 'Gulab Jamun (2 pcs)', 1),
(216, 1, 'Shahi Paneer', 1),
(216, 1, 'Garlic Naan', 2),
(218, 1, 'Dal Makhani', 1),
(218, 1, 'Tandoori Roti', 4),
(219, 1, 'Chicken Tikka Masala', 1),
(219, 1, 'Butter Naan', 2),
(220, 1, 'Kadhai Paneer', 1),
(220, 1, 'Butter Naan', 2),
(220, 1, 'Rasmalai (2 pcs)', 1),
(222, 1, 'KR Biryani', 2),
(224, 1, 'Malai Kofta', 1),
(224, 1, 'Tandoori Roti', 3),
(226, 1, 'Veg Dum Pulao', 1),
(226, 1, 'Paneer Butter Masala', 1);

-- 5. Order Groceries
INSERT IGNORE INTO ORDER_GROCERY (Order_Id, Store_Id, Item_Name, Quantity) VALUES
(213, 1, 'Amul Taaza Milk 1L', 2),
(213, 1, 'Amul Butter 500g', 1),
(215, 1, 'Amul Paneer 200g', 2),
(215, 1, 'Amul Cheese Slices 200g', 1),
(217, 1, 'Aashirvaad Atta 5kg', 1),
(217, 1, 'Amul Taaza Milk 1L', 1),
(221, 1, 'Amul Taaza Milk 1L', 2),
(221, 1, 'Amul Butter 500g', 1),
(223, 1, 'Amul Cheese Slices 200g', 2),
(225, 1, 'Aashirvaad Atta 5kg', 1),
(227, 1, 'Amul Butter 500g', 1),
(228, 1, 'Amul Butter 500g', 1);

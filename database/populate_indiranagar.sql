-- ============================================================================
-- POPULATE INDIRANAGAR DARK STORE (Store_Id = 1) WITH COMPLETE INSTAMART CATALOG
-- ============================================================================
USE food_delivery_db;

-- Ensure Image_Url column exists on GROCERIES
ALTER TABLE GROCERIES ADD COLUMN IF NOT EXISTS Image_Url VARCHAR(500) DEFAULT NULL;

-- Populate all 35 essential Instamart grocery items for Indiranagar Dark Store (Store_Id = 1)
INSERT INTO GROCERIES (Store_Id, Item_Name, Price, Available_count, Image_Url) VALUES
-- 1. Dairy, Bread & Eggs
(1, 'Amul Butter 500g', 275.00, 85, 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500&auto=format&fit=crop&q=80'),
(1, 'Nandini GoodLife Milk 1L', 62.00, 120, 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=80'),
(1, 'Amul Taaza Milk 1L', 56.00, 110, 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500&auto=format&fit=crop&q=80'),
(1, 'Britannia Brown Bread 400g', 50.00, 95, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80'),
(1, 'Farm Fresh Eggs (6 pcs)', 48.00, 100, 'https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=500&auto=format&fit=crop&q=80'),
(1, 'Farm Fresh Eggs (12 pcs)', 92.00, 90, 'https://images.unsplash.com/photo-1516448620398-c5f44bf9f441?w=500&auto=format&fit=crop&q=80'),
(1, 'Amul Cheese Slices 200g', 145.00, 80, 'https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?w=500&auto=format&fit=crop&q=80'),
(1, 'Amul Paneer 200g', 92.00, 95, 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80'),
(1, 'Epigamia Greek Yogurt 90g', 50.00, 65, 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop&q=80'),

-- 2. Fresh Produce (Fruits & Vegetables)
(1, 'Fresh Onion 1kg', 35.00, 120, 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80'),
(1, 'Fresh Potato 1kg', 30.00, 140, 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80'),
(1, 'Fresh Tomato Local 1kg', 40.00, 130, 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80'),

-- 3. Atta, Rice, Oil & Dal (Pantry Essentials)
(1, 'Aashirvaad Atta 5kg', 245.00, 75, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80'),
(1, 'Fortune Sunflower Oil 1L', 160.00, 110, 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&auto=format&fit=crop&q=80'),
(1, 'Tata Salt 1kg', 28.00, 150, 'https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?w=500&auto=format&fit=crop&q=80'),
(1, 'Madhur Pure Sugar 1kg', 55.00, 140, 'https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=500&auto=format&fit=crop&q=80'),
(1, 'Tata Sampann Toor Dal 1kg', 185.00, 100, 'https://images.unsplash.com/photo-1585994192701-512cb59f0f97?w=500&auto=format&fit=crop&q=80'),
(1, 'India Gate Basmati Rice 5kg', 450.00, 85, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80'),

-- 4. Snacks & Munchies
(1, 'Lays Classic Salted 50g', 20.00, 180, 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&auto=format&fit=crop&q=80'),
(1, 'Kurkure Masala Munch 90g', 20.00, 170, 'https://images.unsplash.com/photo-1621447504864-d8686e12698c?w=500&auto=format&fit=crop&q=80'),
(1, 'Haldiram Bhujia 400g', 115.00, 95, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80'),
(1, 'Oreo Original Cookies 120g', 40.00, 160, 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500&auto=format&fit=crop&q=80'),

-- 5. Instant & Packaged Food
(1, 'Maggi 2-Minute Noodles 280g', 58.00, 150, 'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=500&auto=format&fit=crop&q=80'),
(1, 'Kissan Tomato Ketchup 1kg', 130.00, 80, 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&auto=format&fit=crop&q=80'),
(1, 'Nutella Hazelnut Spread 350g', 380.00, 60, 'https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=500&auto=format&fit=crop&q=80'),

-- 6. Drinks & Beverages
(1, 'Nescafe Classic Coffee 100g', 310.00, 90, 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&auto=format&fit=crop&q=80'),
(1, 'Taj Mahal Tea 500g', 340.00, 90, 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&auto=format&fit=crop&q=80'),

-- 7. Chocolates & Sweets
(1, 'Cadbury Dairy Milk 150g', 175.00, 110, 'https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=500&auto=format&fit=crop&q=80'),

-- 8. Personal & Household Cleaning
(1, 'Dettol Original Soap (3 pcs)', 135.00, 120, 'https://images.unsplash.com/photo-1608248597359-364e0a4f5263?w=500&auto=format&fit=crop&q=80'),
(1, 'Colgate Strong Teeth 150g', 98.00, 140, 'https://images.unsplash.com/photo-1559591937-e62fb330f248?w=500&auto=format&fit=crop&q=80'),
(1, 'Head & Shoulders Shampoo 340ml', 280.00, 90, 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=500&auto=format&fit=crop&q=80'),
(1, 'Surf Excel Matic Liquid 1L', 220.00, 65, 'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80'),
(1, 'Vim Dishwash Gel 750ml', 145.00, 90, 'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80'),
(1, 'Harpic Toilet Cleaner 1L', 195.00, 85, 'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80'),
(1, 'Lizol Floor Cleaner 1L', 190.00, 90, 'https://images.unsplash.com/photo-1585421514284-efb74c2b69ba?w=500&auto=format&fit=crop&q=80')

ON DUPLICATE KEY UPDATE 
    Price = VALUES(Price),
    Available_count = VALUES(Available_count),
    Image_Url = VALUES(Image_Url);

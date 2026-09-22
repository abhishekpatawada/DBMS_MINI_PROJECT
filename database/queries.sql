-- Useful SQL Queries for DBMS Project
USE dbms_project;

-- 1. View all orders with customer, agent, and payment details
SELECT 
    o.Order_Id,
    u.User_Name,
    u.User_Phone,
    da.Agent_Name,
    da.VehicleNO,
    o.Order_Type,
    o.Order_Status,
    o.Total_Amount,
    p.Payment_Method,
    p.Payment_Status,
    o.Order_Date
FROM orders o
JOIN users u ON o.User_Id = u.User_Id
LEFT JOIN delivery_agent da ON o.Agent_Id = da.Agent_Id
LEFT JOIN payments p ON o.Order_Id = p.Order_Id
ORDER BY o.Order_Date DESC;

-- 2. View order details and item breakdown for a specific order (e.g., Order_Id = 1001)
SELECT 
    oi.Order_Id,
    oi.Item_Name,
    oi.Quantity,
    oi.Item_Price,
    oi.Subtotal
FROM order_items oi
WHERE oi.Order_Id = 1001;

-- 3. Restaurant menu with final calculated prices after discount
SELECT 
    r.RName AS Restaurant_Name,
    ri.Item_Name,
    ri.Food_Name,
    ri.Is_Veg,
    ri.BasePrice,
    ri.Discount,
    ri.FinalPrice
FROM rest_items ri
JOIN restaurant r ON ri.Rest_Id = r.Rest_Id
ORDER BY r.RName, ri.Item_Name;

-- 4. Dark store grocery inventory overview
SELECT 
    ds.Store_Id,
    ds.DS_Area,
    g.Item_Name,
    g.Price,
    g.Available_count
FROM groceries g
JOIN dark_store ds ON g.Store_Id = ds.Store_Id
ORDER BY ds.DS_Area, g.Item_Name;

-- 5. Total revenue by payment method
SELECT 
    p.Payment_Method,
    COUNT(p.Payment_Id) AS Total_Transactions,
    SUM(p.Amount) AS Total_Revenue
FROM payments p
WHERE p.Payment_Status = 'Completed'
GROUP BY p.Payment_Method;

-- 6. Active deliveries assigned to agents
SELECT 
    da.Agent_Name,
    da.Agent_Phone,
    da.VehicleNO,
    o.Order_Id,
    o.Order_Status,
    u.User_Name AS Customer_Name,
    CONCAT(u.Street, ', ', u.Area, ', ', u.State, ' - ', u.Pincode) AS Delivery_Address
FROM orders o
JOIN delivery_agent da ON o.Agent_Id = da.Agent_Id
JOIN users u ON o.User_Id = u.User_Id
WHERE o.Order_Status IN ('Preparing', 'Out for Delivery');

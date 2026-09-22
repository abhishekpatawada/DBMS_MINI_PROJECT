-- DBMS Project Database Schema
-- Database: MySQL

CREATE DATABASE IF NOT EXISTS dbms_project;
USE dbms_project;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    User_Id INT AUTO_INCREMENT PRIMARY KEY,
    User_Name VARCHAR(100) NOT NULL,
    User_Phone VARCHAR(15) NOT NULL UNIQUE,
    Street VARCHAR(150),
    Area VARCHAR(100),
    State VARCHAR(100),
    Pincode VARCHAR(10)
);

-- 2. Delivery Agent Table
CREATE TABLE IF NOT EXISTS delivery_agent (
    Agent_Id INT AUTO_INCREMENT PRIMARY KEY,
    Agent_Name VARCHAR(100) NOT NULL,
    Agent_Phone VARCHAR(15) NOT NULL UNIQUE,
    VehicleNO VARCHAR(30),
    V_Type VARCHAR(50),
    Has_license BOOLEAN DEFAULT TRUE,
    Rating DECIMAL(3, 2) DEFAULT 5.00 CHECK (Rating >= 0 AND Rating <= 5.00)
);

-- 3. Restaurant Table
CREATE TABLE IF NOT EXISTS restaurant (
    Rest_Id INT AUTO_INCREMENT PRIMARY KEY,
    RName VARCHAR(150) NOT NULL,
    RLocation VARCHAR(200) NOT NULL,
    RPhone VARCHAR(15),
    RRating DECIMAL(3, 2) DEFAULT 4.00 CHECK (RRating >= 0 AND RRating <= 5.00)
);

-- 4. Restaurant Items Table
CREATE TABLE IF NOT EXISTS rest_items (
    Rest_Id INT NOT NULL,
    Item_Name VARCHAR(100) NOT NULL,
    Food_Name VARCHAR(100),
    Is_Veg BOOLEAN DEFAULT TRUE,
    BasePrice DECIMAL(10, 2) NOT NULL,
    Discount DECIMAL(5, 2) DEFAULT 0.00,
    FinalPrice DECIMAL(10, 2) GENERATED ALWAYS AS (BasePrice - (BasePrice * Discount / 100)) STORED,
    PRIMARY KEY (Rest_Id, Item_Name),
    FOREIGN KEY (Rest_Id) REFERENCES restaurant(Rest_Id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. Dark Store Table
CREATE TABLE IF NOT EXISTS dark_store (
    Store_Id INT AUTO_INCREMENT PRIMARY KEY,
    DS_Street VARCHAR(150),
    DS_Area VARCHAR(100),
    DS_State VARCHAR(100),
    DS_Pincode VARCHAR(10)
);

-- 6. Groceries Table
CREATE TABLE IF NOT EXISTS groceries (
    Store_Id INT NOT NULL,
    Item_Name VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Available_count INT NOT NULL DEFAULT 0,
    PRIMARY KEY (Store_Id, Item_Name),
    FOREIGN KEY (Store_Id) REFERENCES dark_store(Store_Id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 7. Orders Table
CREATE TABLE IF NOT EXISTS orders (
    Order_Id INT AUTO_INCREMENT PRIMARY KEY,
    User_Id INT NOT NULL,
    Agent_Id INT DEFAULT NULL,
    Order_Type ENUM('Restaurant', 'Grocery') NOT NULL DEFAULT 'Restaurant',
    Order_Status ENUM('Placed', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled') DEFAULT 'Placed',
    Total_Amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    Order_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User_Id) REFERENCES users(User_Id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Agent_Id) REFERENCES delivery_agent(Agent_Id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 8. Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    Item_Order_Id INT AUTO_INCREMENT PRIMARY KEY,
    Order_Id INT NOT NULL,
    Item_Name VARCHAR(100) NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    Item_Price DECIMAL(10, 2) NOT NULL,
    Subtotal DECIMAL(10, 2) GENERATED ALWAYS AS (Quantity * Item_Price) STORED,
    FOREIGN KEY (Order_Id) REFERENCES orders(Order_Id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 9. Payments Table
CREATE TABLE IF NOT EXISTS payments (
    Payment_Id INT AUTO_INCREMENT PRIMARY KEY,
    Order_Id INT NOT NULL UNIQUE,
    Payment_Method ENUM('UPI', 'Credit Card', 'Debit Card', 'Cash on Delivery', 'Net Banking') NOT NULL,
    Payment_Status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Completed',
    Transaction_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Order_Id) REFERENCES orders(Order_Id) ON DELETE CASCADE ON UPDATE CASCADE
);

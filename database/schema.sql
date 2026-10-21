-- =====================================================
-- DBMS Project Database Schema
-- Database: MySQL
-- =====================================================

CREATE DATABASE IF NOT EXISTS dbms_project;
USE dbms_project;


-- =====================================================
-- 1. USERS
-- =====================================================

CREATE TABLE IF NOT EXISTS USERS (
    User_Id INT PRIMARY KEY,
    User_Name VARCHAR(100) NOT NULL,
    User_Phone VARCHAR(15),
    Password VARCHAR(255) DEFAULT '123456',
    Street VARCHAR(100),
    Area VARCHAR(100),
    State VARCHAR(50),
    Pincode VARCHAR(10)
);


-- =====================================================
-- 2. DELIVERY_AGENT
-- =====================================================

CREATE TABLE IF NOT EXISTS DELIVERY_AGENT (
    Agent_Id INT PRIMARY KEY,
    Agent_Name VARCHAR(100) NOT NULL,
    Agent_Phone VARCHAR(15),
    Password VARCHAR(255) DEFAULT '123456',
    VehicleNO VARCHAR(30),
    V_Type VARCHAR(50),
    Has_license BOOLEAN,
    Rating DECIMAL(3,2)
);


-- =====================================================
-- 3. RESTAURANT
-- =====================================================

CREATE TABLE IF NOT EXISTS RESTAURANT (
    Rest_Id INT PRIMARY KEY,
    RName VARCHAR(100) NOT NULL,
    RLocation VARCHAR(200),
    RPhone VARCHAR(15),
    Password VARCHAR(255) DEFAULT '123456',
    RRating DECIMAL(3,2)
);


-- =====================================================
-- 4. REST_ITEMS
-- Restaurant 1 : N Rest_Items
-- Composite PK = (Rest_Id, Item_Name)
-- =====================================================

CREATE TABLE IF NOT EXISTS REST_ITEMS (
    Rest_Id INT,
    Item_Name VARCHAR(100),
    Food_Name VARCHAR(100),
    Is_Veg BOOLEAN,
    BasePrice DECIMAL(10,2),
    Discount DECIMAL(5,2),
    FinalPrice DECIMAL(10,2),
    Image_Url VARCHAR(500),

    PRIMARY KEY (Rest_Id, Item_Name),

    FOREIGN KEY (Rest_Id)
        REFERENCES RESTAURANT(Rest_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =====================================================
-- 5. DARK_STORE
-- =====================================================

CREATE TABLE IF NOT EXISTS DARK_STORE (
    Store_Id INT PRIMARY KEY,
    DS_Phone VARCHAR(15) DEFAULT '9810099999',
    Password VARCHAR(255) DEFAULT '123456',
    DS_Street VARCHAR(100),
    DS_Area VARCHAR(100),
    DS_State VARCHAR(50),
    DS_Pincode VARCHAR(10)
);


-- =====================================================
-- 6. GROCERIES
-- WEAK ENTITY
-- Owner entity = DARK_STORE
-- Partial key = Item_Name
-- PK = (Store_Id, Item_Name)
-- =====================================================

CREATE TABLE IF NOT EXISTS GROCERIES (
    Store_Id INT,
    Item_Name VARCHAR(100),
    Price DECIMAL(10,2),
    Available_count INT,
    Image_Url VARCHAR(500),

    PRIMARY KEY (Store_Id, Item_Name),

    FOREIGN KEY (Store_Id)
        REFERENCES DARK_STORE(Store_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =====================================================
-- 7. ORDERS
--
-- USERS       1 : N ORDERS
-- AGENT       1 : N ORDERS
-- RESTAURANT  1 : N ORDERS
-- DARK_STORE  1 : N ORDERS
-- =====================================================

CREATE TABLE IF NOT EXISTS ORDERS (
    Order_Id INT PRIMARY KEY,

    User_Id INT NOT NULL,
    Agent_Id INT,
    Rest_Id INT,
    Store_Id INT,

    Order_Review VARCHAR(500),
    PlacedAt DATETIME,
    DeliveredAt DATETIME,
    Delivery_Addr VARCHAR(200),
    Agent_Rating DECIMAL(3,2),

    FOREIGN KEY (User_Id)
        REFERENCES USERS(User_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (Agent_Id)
        REFERENCES DELIVERY_AGENT(Agent_Id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    FOREIGN KEY (Rest_Id)
        REFERENCES RESTAURANT(Rest_Id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    FOREIGN KEY (Store_Id)
        REFERENCES DARK_STORE(Store_Id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


-- =====================================================
-- 8. ORDER_ITEM
--
-- ORDERS M : N REST_ITEMS
-- Relationship attribute = Food_quantity
-- =====================================================

CREATE TABLE IF NOT EXISTS ORDER_ITEM (
    Order_Id INT,
    Rest_Id INT,
    Item_Name VARCHAR(100),
    Food_quantity INT NOT NULL,

    PRIMARY KEY (Order_Id, Rest_Id, Item_Name),

    FOREIGN KEY (Order_Id)
        REFERENCES ORDERS(Order_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (Rest_Id, Item_Name)
        REFERENCES REST_ITEMS(Rest_Id, Item_Name)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- =====================================================
-- 9. PAYMENT
--
-- ORDER 1 : 1 PAYMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS PAYMENT (
    Payment_Id INT PRIMARY KEY,
    Order_Id INT NOT NULL,
    Payment_Method VARCHAR(50),
    Amount DECIMAL(10,2),

    FOREIGN KEY (Order_Id)
        REFERENCES ORDERS(Order_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    UNIQUE (Order_Id)
);


-- =====================================================
-- 10. ORDER_GROCERY
--
-- ORDERS M : N GROCERIES
-- GROCERIES has composite PK: (Store_Id, Item_Name)
-- =====================================================

CREATE TABLE IF NOT EXISTS ORDER_GROCERY (
    Order_Id INT,
    Store_Id INT,
    Item_Name VARCHAR(100),
    Quantity INT NOT NULL DEFAULT 1,

    PRIMARY KEY (Order_Id, Store_Id, Item_Name),

    FOREIGN KEY (Order_Id)
        REFERENCES ORDERS(Order_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (Store_Id, Item_Name)
        REFERENCES GROCERIES(Store_Id, Item_Name)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

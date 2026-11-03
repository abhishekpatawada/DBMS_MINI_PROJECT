# BiteHub - Food & Hyperlocal Quick-Commerce Platform
> *"Your cravings, our command."*

[![Flutter 3](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Python FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![MySQL 8.0](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com)
[![Material 3](https://img.shields.io/badge/Material%20Design-3-7C4DFF?logo=materialdesign&logoColor=white)](https://m3.material.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A production-grade, multi-vendor Food & Hyperlocal Grocery delivery database management system built with **Flutter** (Cross-Platform Mobile, Web & Desktop), **Python FastAPI** (Asynchronous REST API), and **MySQL** (Relational Database with ACID transactions).

---

## 📑 Table of Contents
1. [System Architecture](#-system-architecture)
2. [Comprehensive Feature Matrix](#-comprehensive-feature-matrix)
   - [Enterprise Web Landing Page](#1-enterprise-web-landing-page)
   - [Customer Experience (Food & 10-Min Groceries)](#2-customer-experience-food--10-min-groceries)
   - [Restaurant Partner Operations](#3-restaurant-partner-operations)
   - [Dark Store Hub (Quick-Commerce Inventory)](#4-dark-store-hub-quick-commerce-inventory)
   - [Delivery Agent Fleet App](#5-delivery-agent-fleet-app)
   - [Executive Operations Dashboard (Big Screen)](#6-executive-operations-dashboard-big-screen)
   - [Live SQL Visualizer & DBMS Explorer](#7-live-sql-visualizer--dbms-explorer)
3. [Network & Media Architecture](#-network--media-architecture)
4. [Database Design & Schema (3NF)](#-database-design--schema-3nf)
5. [REST API Reference](#-rest-api-reference)
6. [Getting Started & Local Setup](#-getting-started--local-setup)
7. [Default Test Accounts](#-default-test-accounts)
8. [Project Structure](#-project-structure)

---

## 🏛️ System Architecture

```text
┌────────────────────────────────────────────────────────────────────────┐
│                      FLUTTER CLIENT APPLICATION                        │
│   (Web Browser / Windows Desktop / Android Mobile / iOS / Tablets)     │
│                                                                        │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌───────────────┐  │
│  │   Landing    │ │   Customer   │ │  Restaurant  │ │  Dark Store   │  │
│  │  Enterprise  │ │  Food & Mart │ │  Kitchen Hub │ │ Quick-Commerce│  │
│  └──────────────┘ └──────────────┘ └──────────────┘ └───────────────┘  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌───────────────┐  │
│  │   Delivery   │ │  Operations  │ │   Live SQL   │ │ Server Config │  │
│  │  Fleet App   │ │  Dashboard   │ │  Visualizer  │ │  Diagnostics  │  │
│  └──────────────┘ └──────────────┘ └──────────────┘ └───────────────┘  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ HTTP REST + JSON (Port 8000)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        PYTHON FASTAPI BACKEND                          │
│                                                                        │
│  ┌──────────────────────┐ ┌──────────────────────┐ ┌────────────────┐  │
│  │  Auth & Role Router  │ │  Order & ACID Engine │ │ Catalog Routers│  │
│  └──────────────────────┘ └──────────────────────┘ └────────────────┘  │
│  ┌──────────────────────┐ ┌──────────────────────┐ ┌────────────────┐  │
│  │ Inventory Management │ │  Delivery Dispatcher │ │ SQL Visualizer │  │
│  └──────────────────────┘ └──────────────────────┘ └────────────────┘  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ MySQL Native Connector (Port 3306)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                         MYSQL RELATIONAL DB                            │
│                                                                        │
│   USERS • RESTAURANT • REST_ITEMS • DARK_STORE • GROCERIES             │
│   DELIVERY_AGENT • ORDERS • ORDER_ITEM • ORDER_GROCERY • PAYMENT       │
└────────────────────────────────────────────────────────────────────────┘
```

---

## ✨ Comprehensive Feature Matrix

### 1. Enterprise Web Landing Page
* **Hero Banner**: Engaging call-to-action with interactive order simulation buttons and animated metrics pill badges (*"50K+ Happy Foodies"*, *"10-Min Fast Delivery"*, *"4.8★ Top Rated"*).
* **Role Showcase Switcher**: Interactive switcher demonstrating user workflows for Customers, Restaurants, Dark Stores, and Delivery Riders.
* **Feature Highlights Grid**: Highlighting lightning-fast delivery, curated multi-cuisine discovery, live GPS tracking, and contactless payments.
* **Interactive FAQ Accordion**: Expandable answers addressing delivery zones, partnership onboarding, food hygiene, and payment support.
* **Global Navigation**: One-click routing to Sign In, Role Registration, and live app instances.

### 2. Customer Experience (Food & 10-Min Groceries)
* **Dual-Delivery Model**: Switch seamlessly between **Restaurant Food Delivery** (Swiggy/Zomato style) and **10-Minute Dark Store Groceries** (Blinkit/Zepto/Instamart style).
* **Distinct Curated Visuals**: Every restaurant features a distinct, high-definition banner (Royal Palace, Spice House, Bawarchi Biryani, Artisan Pizzeria, Sizzling Street Food) with zero duplicate images.
* **Advanced Exploration & Filtering**:
  - Live Search across restaurant names, dishes, groceries, and categories.
  - Veg / Non-Veg toggle with real-time UI badges.
  - Category pill filter: Popular, Biryani, Starters, Main Course, Desserts, Beverages.
* **Restaurant Detail View**:
  - Distance & ETA estimation pills with rating summaries.
  - Promotional offer banners (e.g., *Flat 20% OFF using FEAST20*).
  - Add-to-cart item cards with quantity increment/decrement controls.
  - Bottom sticky floating cart bar displaying live item count and total subtotal.
* **Checkout & Smart Cart**:
  - Real-time billing breakdown: Subtotal, GST/Service Tax, Delivery Partner Fee, Platform Fee, and Tip.
  - Delivery Agent Tipping selector (₹10, ₹20, ₹30, ₹50, or custom).
  - Promo code discounts with instant coupon application.
  - Multiple payment options: UPI (GPay, PhonePe, Paytm), Credit/Debit Card, NetBanking, and Cash on Delivery (COD).
* **Order Tracking & Lifecycle**:
  - Live status tracking (`Order Placed` $\rightarrow$ `Preparing` $\rightarrow$ `Out for Delivery` $\rightarrow$ `Delivered`).
  - Active order cancellation with automatic transactional inventory rollback.
  - One-tap re-ordering from comprehensive past order history.
* **User Profile & Diagnostics**:
  - Multiple saved addresses management.
  - Dark/Light theme switching and server connectivity test utility.

### 3. Restaurant Partner Operations
* **Live Kitchen Management**: Real-time incoming order queue displaying ordered items, quantities, and customer instructions.
* **Status Progression Pipeline**: Transition orders with single taps: `Accept` $\rightarrow$ `Preparing` $\rightarrow$ `Ready for Pickup` $\rightarrow$ `Dispatched`.
* **Full Menu CRUD**:
  - Add new dishes with name, cuisine, category, base price, and discount percentage.
  - Instant final price calculation (`FinalPrice = BasePrice - (BasePrice * Discount / 100)`).
  - Update dish details or delete existing dishes with cascade safety.
* **Interactive Food Gallery Picker**:
  - Select photos from an integrated gallery of 100+ categorized, curated HD food items (Biryani, Pizzas, Burgers, Asian, Desserts).
  - Paste any custom external image URL with live preview.
* **In-Stock / Out-of-Stock Toggle**: Instantly hide sold-out items from customer screens without deleting the dish.
* **Business Analytics**: Track total gross sales, today's order count, pending dispatches, and average customer ratings.

### 4. Dark Store Hub (Quick-Commerce Inventory)
* **Real-Time Stock Monitoring**: Manage fast-moving grocery inventory across Fresh Fruits & Vegetables, Dairy, Bakery, Snacks, Beverages, and Daily Essentials.
* **Low-Stock Visual Indicators**: Automatic amber/red badges alerting managers when inventory drops below safety thresholds.
* **Inventory CRUD**: Add new grocery SKUs, adjust counts, update unit prices, or remove discontinued items.
* **Curated Grocery Gallery Picker**: Pick photos from a library of produce, dairy packs, staples, and snacks, or enter custom URLs.
* **Order Fulfillment Flow**: Manage order picking and store dispatches to assigned delivery agents.

### 5. Delivery Agent Fleet App
* **Delivery Task Stream**: Live list of active food and grocery orders assigned to the agent.
* **Fast-Action Status Progression**:
  - Mark order as `Picked Up` from restaurant/dark store.
  - Update status to `Out for Delivery`.
  - Finalize delivery with `Delivered` confirmation.
* **Earnings & Revenue View**:
  - Breakdown of delivery base pay and direct customer tips.
  - Daily, weekly, and total cumulative earnings metrics.
* **Fleet Profile**:
  - Online/Offline shift status toggle.
  - Vehicle details (Motorcycle, Scooter, EV, Bicycle), license status verification, and customer rating scores.

### 6. Executive Operations Dashboard (Big Screen)
* **Command Center Layout**: Built specifically for operations rooms, franchise displays, and tablet kiosks.
* **Key Performance Indicators**:
  - Total Gross Merchandise Value (GMV).
  - Platform-wide active order volume.
  - Active delivery agent fleet density.
  - Average fulfillment latency.
* **Operations Visuals**: Top-performing restaurants, busiest dark store hubs, and real-time revenue breakdowns.

### 7. Live SQL Visualizer & DBMS Explorer
* **Integrated Database Inspector**: Inspect live MySQL tables and relationships directly within the Flutter app.
* **Schema Explorer**: Interactive schema inspector detailing columns, composite primary keys, foreign keys, and constraints.
* **Live SQL Console**:
  - Execute custom SQL queries (`SELECT`, `JOIN`, `GROUP BY`, `HAVING`, aggregations) with execution timing latency benchmarks.
  - Preloaded starter queries demonstrating DBMS concepts (Multi-table joins, revenue analytics, weak entity lookups).

---

## ⚡ Network & Media Architecture

### 1. Platform-Aware Base URL Auto-Resolution
The Flutter client dynamically determines the correct backend API endpoint based on runtime environment:
* **Flutter Web**: Automatically binds to `http://${Uri.base.host}:8000/api` (connects to whichever host served the web page, whether localhost or LAN Wi-Fi).
* **Desktop (Windows / macOS / Linux)**: Defaults directly to `http://localhost:8000/api`.
* **Mobile Devices (Android / iOS)**: Automatically points to the active host machine LAN IP (`http://10.74.88.1:8000/api`).
* **Android Emulator**: Supports 1-tap switching to `http://10.0.2.2:8000/api`.

### 2. In-App Server Diagnostics Dialog
Accessible from the top header or settings on any screen:
* Live connectivity ping with millisecond round-trip latency metrics.
* Quick preset chips for 1-tap switching between Wi-Fi Network, Localhost, and Android Emulator.
* Custom URL input field with validation.

### 3. Resilient In-Memory Image Pipeline
* **Flutter Native Image Pipeline**: All images load via Flutter's hardware-accelerated image pipeline, completely eliminating browser **CORS** restrictions on Flutter Web.
* **In-Memory Cache**: Configured in `main.dart` with a generous **200 MB / 2,000 images** cache limit (`PaintingBinding.instance.imageCache`), preventing re-downloading.
* **`gaplessPlayback: true`**: Eliminates white flash or flicker during state updates and re-renders.
* **Graceful Fallbacks**: Themed placeholders and fallback icons if an external image link fails.

---

## 🗄️ Database Design & Schema (3NF)

The database adheres strictly to Third Normal Form (3NF) with strong referential integrity, composite primary keys for weak entities, and cascading operations.

### Relational Schema Tables:
1. **`USERS`**: `(User_Id [PK], User_Name, User_Phone, Password, Street, Area, State, Pincode)`
2. **`DELIVERY_AGENT`**: `(Agent_Id [PK], Agent_Name, Agent_Phone, Password, VehicleNO, V_Type, Has_license, Rating)`
3. **`RESTAURANT`**: `(Rest_Id [PK], RName, RLocation, RPhone, Password, RRating, Image_Url)`
4. **`REST_ITEMS`**: `(Rest_Id [FK], Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Image_Url) [Composite PK: (Rest_Id, Item_Name)]`
5. **`DARK_STORE`**: `(Store_Id [PK], DS_Phone, Password, DS_Street, DS_Area, DS_State, DS_Pincode)`
6. **`GROCERIES`** *(Weak Entity of DARK_STORE)*: `(Store_Id [FK], Item_Name, Price, Available_count, Image_Url) [Composite PK: (Store_Id, Item_Name)]`
7. **`ORDERS`**: `(Order_Id [PK], User_Id [FK], Agent_Id [FK], Rest_Id [FK], Store_Id [FK], Order_Review, PlacedAt, DeliveredAt, Delivery_Addr, Agent_Rating, Status, Total_Amount, Delivery_Fee, Tip_Amount)`
8. **`ORDER_ITEM`** *(M:N Orders to Dishes)*: `(Order_Id [FK], Rest_Id [FK], Item_Name, Food_quantity) [Composite PK: (Order_Id, Rest_Id, Item_Name)]`
9. **`ORDER_GROCERY`** *(M:N Orders to Groceries)*: `(Order_Id [FK], Store_Id [FK], Item_Name, Quantity) [Composite PK: (Order_Id, Store_Id, Item_Name)]`
10. **`PAYMENT`** *(1:1 Order to Payment)*: `(Payment_Id [PK], Order_Id [FK, UNIQUE], Payment_Method, Amount)`

### ACID Integrity & Rollback Mechanics:
* Order placement executes inside a transactional block that decrements grocery stock counts (`Available_count`).
* Order cancellations automatically reverse stock decrements and update order state to `Cancelled`.

---

## 🔌 REST API Reference

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/auth/login` | Unified authentication resolving role (User, Agent, Restaurant, Dark Store) |
| `POST` | `/api/auth/register/{role}` | Register new account with role-tailored attributes and auto-assigned image |
| `GET` | `/api/users` | List all users |
| `GET` | `/api/users/{id}` | Get specific user profile with saved addresses |
| `GET` | `/api/restaurants` | List all restaurants with ratings and banner URLs |
| `GET` | `/api/restaurants/{id}/menu` | Retrieve menu catalog for a specific restaurant |
| `POST` | `/api/restaurants/{id}/menu` | Add new dish to restaurant menu |
| `PUT` | `/api/restaurants/{id}/menu/{name}` | Update dish pricing, discount, or image URL |
| `DELETE`| `/api/restaurants/{id}/menu/{name}` | Remove a dish from the menu |
| `GET` | `/api/dark-stores` | List all dark store hubs |
| `GET` | `/api/dark-stores/{id}/groceries` | List inventory stock for a dark store hub |
| `POST` | `/api/dark-stores/{id}/groceries` | Add grocery item to dark store inventory |
| `PUT` | `/api/dark-stores/{id}/groceries/{name}`| Update grocery count or price |
| `DELETE`| `/api/dark-stores/{id}/groceries/{name}`| Delete item from dark store inventory |
| `GET` | `/api/delivery-agents` | List delivery agents and live statuses |
| `GET` | `/api/orders` | Fetch orders filtered by user, restaurant, store, or agent |
| `POST` | `/api/orders` | Transactional placement of food or grocery order |
| `PUT` | `/api/orders/{id}/status` | Update order progression status (`Preparing`, `Out for Delivery`, `Delivered`) |
| `POST` | `/api/orders/{id}/cancel` | Cancel order with automatic stock recovery |
| `POST` | `/api/visualizer/query` | Execute read-only analytical SQL query with benchmark timing |
| `GET` | `/health` | Health check and MySQL connection heartbeat |

*Interactive Swagger documentation available at `http://localhost:8000/docs`.*

---

## 🚀 Getting Started & Local Setup

### Prerequisites
* **Flutter SDK**: 3.22+ or newer
* **Python**: 3.10+
* **MySQL Server**: 8.0+

---

### Step 1: Database Setup (MySQL)
Open MySQL command line or MySQL Workbench:
```sql
SOURCE database/schema.sql;
SOURCE database/sample_data.sql;
```

Configure your `.env` file in the project root:
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=dbms_project
```

---

### Step 2: Start the Python FastAPI Backend
From the root directory:
```powershell
# 1. Install dependencies
pip install -r requirements.txt

# 2. Run backend (accessible from localhost & other devices on LAN)
python -m backend.main
```
*(Or double click `start_server.bat`)*

* Backend will be active on `http://localhost:8000` and `http://10.74.88.1:8000`.

---

### Step 3: Run the Flutter Frontend

#### Option A: Web Browser (Chrome / Edge)
```powershell
cd flutter_app
flutter run -d chrome
```

#### Option B: Multi-Device LAN Access (Phones & Tablets on Wi-Fi / Hotspot)
```powershell
# Run the web server binding to all network interfaces
cd flutter_app
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
```
*(Or double click `start_web.bat`)*
* On your phone or another laptop connected to the same Wi-Fi, open: `http://10.74.88.1:3000`

#### Option C: Windows Desktop
```powershell
cd flutter_app
flutter run -d windows
```

---

## 🔑 Default Test Accounts

All preloaded test accounts use the default password: **`123456`**.

| Role | Phone Number | Name / Entity | Dashboard Route |
| :--- | :--- | :--- | :--- |
| **Customer** | `9810000001` | Aarav Choudhury | User Dashboard (Food & Groceries) |
| **Customer** | `9810000002` | Vivaan Mukherjee | User Dashboard (Food & Groceries) |
| **Restaurant** | `0800000001` | Royal Palace 1 | Restaurant Partner Dashboard |
| **Restaurant** | `0800000002` | Spice House 1 | Restaurant Partner Dashboard |
| **Dark Store** | `9810099999` | Indiranagar Hub (Store 1) | Dark Store Quick-Commerce Hub |
| **Delivery Agent** | `9876500001` | Krishna Singh | Delivery Agent Fleet App |
| **Delivery Agent** | `9876500002` | Pranav Kulkarni | Delivery Agent Fleet App |

---

## 📁 Project Structure

```text
dbms_project/
│
├── flutter_app/                                # 📱 Flutter Multiplatform Client
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart                           # Entry point & 200MB ImageCache config
│   │   ├── theme/
│   │   │   └── app_theme.dart                  # Material 3 colors, typography, styles
│   │   ├── models/
│   │   │   └── models.dart                     # Type-safe Dart models & JSON parsers
│   │   ├── services/
│   │   │   └── api_service.dart                # HTTP client & dynamic IP auto-resolver
│   │   ├── utils/
│   │   │   └── item_image_helper.dart          # Cached image widget & curated galleries
│   │   ├── widgets/
│   │   │   ├── server_config_dialog.dart       # Live latency & IP preset switcher
│   │   │   └── floating_cart_bar.dart          # Sticky cart notification bar
│   │   └── screens/
│   │       ├── landing/web_landing_screen.dart # Enterprise public marketing landing page
│   │       ├── auth_screen.dart                # Unified phone login & role registration
│   │       ├── role_selection_screen.dart      # Interactive role selector
│   │       ├── user/                           # Customer food & grocery dashboard & cart
│   │       ├── restaurant/                     # Restaurant partner kitchen & menu CRUD
│   │       ├── dark_store/                     # Dark store inventory & stock alerts
│   │       ├── delivery_agent/                 # Delivery fleet tasks, route & earnings
│   │       ├── dashboard/                      # Big-screen operations command center
│   │       └── visualizer/                     # Live SQL console & DBMS schema explorer
│
├── backend/                                    # ⚡ Python FastAPI REST Engine
│   ├── main.py                                 # Server entry point & CORS configuration
│   ├── config.py                               # Environment loader & DB credentials
│   ├── database.py                             # MySQL connection pool & cursor handlers
│   ├── image_migration.py                      # Schema migrations & curated HD banners
│   ├── order_service.py                        # Order lifecycle & schema initialization
│   ├── grocery_service.py                      # Seed inventory for quick-commerce stores
│   └── routes/
│       ├── auth_routes.py                      # Multi-role authentication & registration
│       ├── user_routes.py                      # Customer profile & addresses endpoints
│       ├── restaurant_routes.py                # Restaurant info & menu item CRUD
│       ├── grocery_routes.py                   # Dark store & grocery inventory CRUD
│       ├── delivery_routes.py                  # Agent status, assignments & earnings
│       ├── order_routes.py                     # ACID order placement & status transitions
│       └── visualizer_routes.py                # Live SQL query execution & metadata
│
├── database/                                   # 🗄️ Relational MySQL Database
│   ├── schema.sql                              # DDL schema for all 10 normalized tables
│   ├── sample_data.sql                         # 100+ comprehensive realistic mock rows
│   └── queries.sql                             # Analytical, join, and aggregation queries
│
├── start_server.bat                            # 1-Click script to run backend server
├── start_web.bat                               # 1-Click script to run Flutter web on LAN
├── requirements.txt                            # Python dependencies
├── .env.example                                # Template for MySQL environment variables
└── README.md                                   # Comprehensive platform documentation
```

---

<p align="center">
  <b>BiteHub</b> • Engineered with ❤️ for Database Management Systems
</p>

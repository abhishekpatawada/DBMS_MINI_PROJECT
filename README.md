# DBMS Project - Food & Grocery Delivery Platform

A local database management system college project built with **Python**, **Streamlit**, and **MySQL**.

---

## 🏗️ Project Architecture

```text
dbms_project/
│
├── app.py                      # Main Streamlit application entry point
├── requirements.txt            # Python dependencies
├── README.md                   # Project documentation
├── .gitignore                  # Git ignore configuration
├── .env.example                # Sample environment variables template
│
├── frontend/                   # Streamlit UI views & components
│   ├── __init__.py
│   ├── user/                   # Customer dashboard views
│   │   ├── __init__.py
│   │   └── dashboard.py
│   ├── delivery_agent/         # Delivery personnel portal
│   │   ├── __init__.py
│   │   └── dashboard.py
│   ├── restaurant/             # Restaurant management portal
│   │   ├── __init__.py
│   │   └── dashboard.py
│   └── dark_store/             # Dark store inventory management
│       ├── __init__.py
│       └── dashboard.py
│
├── backend/                    # Business logic and database interface
│   ├── __init__.py
│   ├── config.py               # Environment configuration loader
│   ├── database.py             # Reusable MySQL connection manager & query helpers
│   ├── user_service.py         # Customer CRUD logic
│   ├── order_service.py        # Order placement and tracking logic
│   ├── restaurant_service.py   # Restaurant and menu management
│   ├── grocery_service.py      # Dark store stock & inventory operations
│   ├── delivery_service.py     # Agent dispatch and transit updates
│   └── payment_service.py      # Payment transaction handler
│
├── database/                   # SQL schemas and queries
│   ├── schema.sql              # MySQL DDL table definitions & constraints
│   ├── sample_data.sql         # Starter mock data
│   └── queries.sql             # Useful analytical and operational queries
│
├── models/                     # Python data classes representing entities
│   ├── __init__.py
│   ├── user.py
│   ├── order.py
│   ├── restaurant.py
│   ├── grocery.py
│   ├── delivery_agent.py
│   └── payment.py
│
└── utils/                      # Helper utilities
    ├── __init__.py
    └── helpers.py              # Formatting & helper functions
```

---

## 📊 Database Entities & Schema

The relational schema is defined in [database/schema.sql](database/schema.sql):

- **`users`**: Customer profiles with delivery addresses (`User_Id`, `User_Name`, `User_Phone`, `Street`, `Area`, `State`, `Pincode`).
- **`delivery_agent`**: Delivery fleet information (`Agent_Id`, `Agent_Name`, `Agent_Phone`, `VehicleNO`, `V_Type`, `Has_license`, `Rating`).
- **`restaurant`**: Restaurant listings (`Rest_Id`, `RName`, `RLocation`, `RPhone`, `RRating`).
- **`rest_items`**: Menu items with dynamic final price calculation (`Rest_Id`, `Item_Name`, `Food_Name`, `Is_Veg`, `BasePrice`, `Discount`, `FinalPrice`).
- **`dark_store`**: Local fulfillment centers (`Store_Id`, `DS_Street`, `DS_Area`, `DS_State`, `DS_Pincode`).
- **`groceries`**: Inventory per dark store (`Store_Id`, `Item_Name`, `Price`, `Available_count`).
- **`orders`**: Placed orders tracking user and assigned agent (`Order_Id`, `User_Id`, `Agent_Id`, `Order_Type`, `Order_Status`, `Total_Amount`, `Order_Date`).
- **`order_items`**: Line items per order (`Item_Order_Id`, `Order_Id`, `Item_Name`, `Quantity`, `Item_Price`, `Subtotal`).
- **`payments`**: Payment records (`Payment_Id`, `Order_Id`, `Payment_Method`, `Payment_Status`, `Transaction_Date`, `Amount`).

---

## 🚀 Setup & Installation

### 1. Prerequisites
- Python 3.10+
- MySQL Server (Local instance, XAMPP, or MySQL Workbench)

### 2. Configure Environment Variables
Copy `.env.example` to `.env` and set your local MySQL credentials:

```bash
cp .env.example .env
```

Edit `.env`:
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=dbms_project
```

### 3. Initialize MySQL Database
Run the SQL scripts in MySQL CLI or MySQL Workbench:

```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/sample_data.sql
```

### 4. Install Dependencies
```bash
pip install -r requirements.txt
```

### 5. Launch the Streamlit App
```bash
streamlit run app.py
```

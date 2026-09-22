# DBMS Project - Food & Grocery Delivery Platform

A full-stack multi-vendor Food & Grocery delivery database management system built with **Flutter** (Frontend), **Python FastAPI** (Backend REST API), and **MySQL** (Database).

---

## 📱 User Interface Navigation Flow

1. **Screen 1: Role Selection**
   - Choose one of the 4 roles:
     - 👤 **Customer (User)**
     - 🛵 **Delivery Agent**
     - 🏪 **Restaurant Partner**
     - 🏬 **Dark Store Hub**
2. **Screen 2: Sign In / Sign Up (with Phone Number)**
   - **Sign In**: Login using registered phone number / identifier.
   - **Sign Up**: Register new profile with dynamic form fields tailored to the chosen role.
3. **Screen 3: Role-Specific Dashboards (Full CRUD)**
   - **Customer**: Place orders from restaurants/dark stores, view live orders, cancel/delete orders.
   - **Delivery Agent**: View assigned drop-offs, fast-action status updates (`Out for Delivery`, `Delivered`).
   - **Restaurant Partner**: Full menu management (Add/Edit/Delete dishes), set discounts, update order progress.
   - **Dark Store Hub**: Real-time grocery inventory (Add/Edit stock/Delete items), fulfill store dispatches.

---

## 🏗️ Project Structure

```text
dbms_project/
│
├── flutter_app/                        # 📱 Flutter Cross-Platform Client
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart                   # Flutter entry point & app theme
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Material 3 design system
│   │   ├── models/
│   │   │   └── models.dart             # JSON-serializable Dart entities
│   │   ├── services/
│   │   │   └── api_service.dart        # Centralized HTTP client
│   │   └── screens/
│   │       ├── role_selection_screen.dart   # Screen 1: Role Selection
│   │       ├── auth_screen.dart             # Screen 2: Sign In / Sign Up
│   │       ├── user/                        # Screen 3: Customer Dashboard
│   │       ├── delivery_agent/              # Screen 3: Agent Dashboard
│   │       ├── restaurant/                  # Screen 3: Restaurant Dashboard
│   │       └── dark_store/                  # Screen 3: Dark Store Hub
│
├── backend/                            # ⚡ Python FastAPI REST API
│   ├── main.py                         # FastAPI app & CORS configuration
│   ├── config.py                       # Environment configuration loader
│   ├── database.py                     # MySQL connection manager & query helpers
│   ├── routes/
│   │   ├── auth_routes.py              # Phone login & registration API
│   │   ├── user_routes.py              # User CRUD endpoints
│   │   ├── restaurant_routes.py        # Restaurant & Menu CRUD endpoints
│   │   ├── grocery_routes.py           # Dark Store & Grocery CRUD endpoints
│   │   ├── delivery_routes.py          # Delivery Agent CRUD endpoints
│   │   └── order_routes.py             # Transactional Order & Status endpoints
│   └── ... (service modules)
│
├── database/                           # 🗄️ MySQL Database
│   ├── schema.sql                      # DDL for all ER tables & foreign keys
│   ├── sample_data.sql                 # Starter mock data
│   └── queries.sql                     # Analytical and operational queries
│
├── requirements.txt                    # Python dependencies
├── .env.example                        # MySQL configuration template
└── README.md                           # Documentation
```

---

## 🚀 How to Run Locally

### 1. Database Setup (MySQL)
Run the SQL scripts in MySQL CLI or MySQL Workbench:
```sql
SOURCE database/schema.sql;
SOURCE database/sample_data.sql;
```

Configure your `.env` file in the root directory:
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=dbms_project
```

---

### 2. Start the Python FastAPI Backend
Install Python dependencies:
```bash
pip install -r requirements.txt
```

Run the backend server:
```bash
uvicorn backend.main:app --reload --port 8000
```
- **REST API URL**: `http://localhost:8000`
- **Interactive Swagger Documentation**: `http://localhost:8000/docs`

---

### 3. Start the Flutter Frontend
Navigate to the `flutter_app` directory:
```bash
cd flutter_app
flutter pub get
```

Run on Chrome (Web), Windows Desktop, or Mobile emulator:
```bash
flutter run -d chrome
# or
flutter run -d windows
```

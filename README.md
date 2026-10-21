# BiteHub - Food & Grocery Delivery Platform
> *"Your cravings, our command."*

A full-stack multi-vendor Food & Grocery delivery database management system built with **Flutter** (Frontend), **Python FastAPI** (Backend REST API), and **MySQL** (Database).

---

## 📱 User Interface Navigation Flow

1. **Screen 1: Unified Sign In / Create Account (BiteHub Auth)**
   - **Sign In**: Direct login using mobile number & password. Automatically detects role (Customer, Delivery Agent, Restaurant, or Dark Store) and routes to the appropriate dashboard.
   - **Create Account**: Prompts user to choose their role (*Customer, Delivery Agent, Restaurant, or Dark Store Hub*) and dynamically renders role-tailored registration fields.
2. **Screen 2: Role-Specific Dashboards (Full CRUD)**
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
│   │       ├── auth_screen.dart             # Screen 1: Unified Login & Registration
│   │       ├── user/                        # Screen 2: Customer Dashboard
│   │       ├── delivery_agent/              # Screen 2: Agent Dashboard
│   │       ├── restaurant/                  # Screen 2: Restaurant Dashboard
│   │       └── dark_store/                  # Screen 2: Dark Store Hub
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

Run the backend server (accessible from other devices on Wi-Fi):
```bash
# Double click start_server.bat OR run:
uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
```
- **Local API URL**: `http://localhost:8000`
- **Wi-Fi Network API URL**: `http://10.102.3.137:8000` (or your laptop's Wi-Fi IP from `ipconfig`)
- **Interactive Swagger Documentation**: `http://localhost:8000/docs`

---

### 3. Start the Flutter Frontend

#### Option A: Access from Phone / Other Devices (Web)
```bash
# Double click start_web.bat OR run:
cd flutter_app
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
```
Then on your phone or other device connected to the same Wi-Fi, open in browser:
`http://10.102.3.137:3000`

#### Option B: Run Locally on Laptop (Desktop / Chrome)
```bash
cd flutter_app
flutter run -d chrome
# or
flutter run -d windows
```

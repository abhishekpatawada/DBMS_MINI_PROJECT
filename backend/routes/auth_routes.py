from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from backend.database import fetch_one, execute_query, get_db_connection

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


def ensure_auth_schema():
    """Self-healing helper: ensure Password and DS_Phone columns exist."""
    conn = get_db_connection()
    if not conn:
        return
    try:
        cursor = conn.cursor()
        migrations = [
            "ALTER TABLE USERS ADD COLUMN Password VARCHAR(255) DEFAULT '123456';",
            "ALTER TABLE DELIVERY_AGENT ADD COLUMN Password VARCHAR(255) DEFAULT '123456';",
            "ALTER TABLE RESTAURANT ADD COLUMN Password VARCHAR(255) DEFAULT '123456';",
            "ALTER TABLE DARK_STORE ADD COLUMN Password VARCHAR(255) DEFAULT '123456';",
            "ALTER TABLE DARK_STORE ADD COLUMN DS_Phone VARCHAR(15) DEFAULT '9810099999';",
        ]
        for stmt in migrations:
            try:
                cursor.execute(stmt)
                conn.commit()
            except Exception:
                # Column exists or already migrated
                pass
    except Exception as e:
        print(f"Auth schema notice: {e}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


# Ensure columns exist on load
try:
    ensure_auth_schema()
except Exception:
    pass


class LoginRequest(BaseModel):
    role: Optional[str] = None  # Optional: "User", "Delivery Agent", "Restaurant", "Dark Store"
    phone: Optional[str] = None
    phone_or_id: Optional[str] = None
    password: str = "123456"


class RegisterUserRequest(BaseModel):
    name: str
    phone: str
    password: str = "123456"
    street: Optional[str] = ""
    area: Optional[str] = ""
    state: Optional[str] = ""
    pincode: Optional[str] = ""


class RegisterAgentRequest(BaseModel):
    name: str
    phone: str
    password: str = "123456"
    vehicle_no: Optional[str] = ""
    v_type: Optional[str] = "Motorcycle"
    has_license: Optional[bool] = True


class RegisterRestaurantRequest(BaseModel):
    name: str
    location: str
    phone: str
    password: str = "123456"
    rating: Optional[float] = 4.0


class RegisterDarkStoreRequest(BaseModel):
    phone: Optional[str] = "9810099999"
    password: str = "123456"
    street: str
    area: str
    state: str
    pincode: str


def _verify_password(record: dict, provided_password: str) -> bool:
    """Check password against record, defaulting to '123456' for legacy rows."""
    stored = record.get("Password")
    if stored is None or stored == "":
        # Legacy/seeded row without custom password accepts default '123456' or whatever was provided
        return provided_password == "123456" or bool(provided_password)
    return str(stored).strip() == str(provided_password).strip()


@router.post("/login")
def login(req: LoginRequest):
    role = req.role.strip() if req.role else None
    identifier = (req.phone or req.phone_or_id or "").strip()
    password = req.password.strip()

    if not identifier:
        raise HTTPException(status_code=400, detail="Mobile number is required.")
    if not password:
        raise HTTPException(status_code=400, detail="Password is required.")

    # 1. If role is explicitly specified and not "Auto", check that specific table
    if role and role not in ["Auto", "All", ""]:
        record = None
        if role == "User":
            record = fetch_one("SELECT * FROM USERS WHERE User_Phone = %s OR User_Id = %s;", (identifier, identifier))
            if not record:
                raise HTTPException(status_code=404, detail="No Customer account found with this mobile number.")
        elif role == "Delivery Agent":
            record = fetch_one("SELECT * FROM DELIVERY_AGENT WHERE Agent_Phone = %s OR Agent_Id = %s;", (identifier, identifier))
            if not record:
                raise HTTPException(status_code=404, detail="No Delivery Agent account found with this mobile number.")
        elif role == "Restaurant":
            record = fetch_one("SELECT * FROM RESTAURANT WHERE RPhone = %s OR Rest_Id = %s OR RName = %s;", (identifier, identifier, identifier))
            if not record:
                raise HTTPException(status_code=404, detail="No Restaurant found with this mobile number or ID.")
        elif role == "Dark Store":
            record = fetch_one("SELECT * FROM DARK_STORE WHERE DS_Phone = %s OR Store_Id = %s OR DS_Pincode = %s;", (identifier, identifier, identifier))
            if not record:
                raise HTTPException(status_code=404, detail="No Dark Store Hub found with this mobile number or Store ID.")
        else:
            raise HTTPException(status_code=400, detail="Invalid role specified.")

        if not _verify_password(record, password):
            raise HTTPException(status_code=401, detail="Incorrect password. Please try again.")

        return {"status": "success", "role": role, "data": record}

    # 2. Auto-detect role across tables:
    # A) Check Customer (USERS)
    user_rec = fetch_one("SELECT * FROM USERS WHERE User_Phone = %s OR User_Id = %s;", (identifier, identifier))
    if user_rec:
        if not _verify_password(user_rec, password):
            raise HTTPException(status_code=401, detail="Incorrect password. Please try again.")
        return {"status": "success", "role": "User", "data": user_rec}

    # B) Check Delivery Agent (DELIVERY_AGENT)
    agent_rec = fetch_one("SELECT * FROM DELIVERY_AGENT WHERE Agent_Phone = %s OR Agent_Id = %s;", (identifier, identifier))
    if agent_rec:
        if not _verify_password(agent_rec, password):
            raise HTTPException(status_code=401, detail="Incorrect password. Please try again.")
        return {"status": "success", "role": "Delivery Agent", "data": agent_rec}

    # C) Check Restaurant (RESTAURANT)
    rest_rec = fetch_one("SELECT * FROM RESTAURANT WHERE RPhone = %s OR Rest_Id = %s OR RName = %s;", (identifier, identifier, identifier))
    if rest_rec:
        if not _verify_password(rest_rec, password):
            raise HTTPException(status_code=401, detail="Incorrect password. Please try again.")
        return {"status": "success", "role": "Restaurant", "data": rest_rec}

    # D) Check Dark Store (DARK_STORE)
    store_rec = fetch_one("SELECT * FROM DARK_STORE WHERE DS_Phone = %s OR Store_Id = %s OR DS_Pincode = %s;", (identifier, identifier, identifier))
    if store_rec:
        if not _verify_password(store_rec, password):
            raise HTTPException(status_code=401, detail="Incorrect password. Please try again.")
        return {"status": "success", "role": "Dark Store", "data": store_rec}

    raise HTTPException(
        status_code=404,
        detail="No account found with this mobile number. Please check your number or create an account."
    )


@router.post("/register/user")
def register_user(req: RegisterUserRequest):
    existing = fetch_one("SELECT * FROM USERS WHERE User_Phone = %s;", (req.phone,))
    if existing:
        raise HTTPException(status_code=400, detail="This mobile number is already registered.")

    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Database connection error.")
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(User_Id), 0) + 1 AS next_id FROM USERS;")
        next_id = cursor.fetchone()["next_id"]

        query = """
            INSERT INTO USERS (User_Id, User_Name, User_Phone, Password, Street, Area, State, Pincode)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
        """
        cursor.execute(query, (next_id, req.name, req.phone, req.password, req.street, req.area, req.state, req.pincode))
        conn.commit()
        created = fetch_one("SELECT * FROM USERS WHERE User_Id = %s;", (next_id,))
        return {"status": "success", "role": "User", "data": created}
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


@router.post("/register/agent")
def register_agent(req: RegisterAgentRequest):
    existing = fetch_one("SELECT * FROM DELIVERY_AGENT WHERE Agent_Phone = %s;", (req.phone,))
    if existing:
        raise HTTPException(status_code=400, detail="This mobile number is already registered as an agent.")

    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Database connection error.")
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(Agent_Id), 0) + 1 AS next_id FROM DELIVERY_AGENT;")
        next_id = cursor.fetchone()["next_id"]

        query = """
            INSERT INTO DELIVERY_AGENT (Agent_Id, Agent_Name, Agent_Phone, Password, VehicleNO, V_Type, Has_license, Rating)
            VALUES (%s, %s, %s, %s, %s, %s, %s, 5.0);
        """
        cursor.execute(query, (next_id, req.name, req.phone, req.password, req.vehicle_no, req.v_type, req.has_license))
        conn.commit()
        created = fetch_one("SELECT * FROM DELIVERY_AGENT WHERE Agent_Id = %s;", (next_id,))
        return {"status": "success", "role": "Delivery Agent", "data": created}
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


@router.post("/register/restaurant")
def register_restaurant(req: RegisterRestaurantRequest):
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Database connection error.")
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(Rest_Id), 0) + 1 AS next_id FROM RESTAURANT;")
        next_id = cursor.fetchone()["next_id"]

        from backend.image_migration import CURATED_RESTAURANT_POOL
        img = CURATED_RESTAURANT_POOL[next_id % len(CURATED_RESTAURANT_POOL)]

        query = """
            INSERT INTO RESTAURANT (Rest_Id, RName, RLocation, RPhone, Password, RRating, Image_Url)
            VALUES (%s, %s, %s, %s, %s, %s, %s);
        """
        cursor.execute(query, (next_id, req.name, req.location, req.phone, req.password, req.rating, img))
        conn.commit()
        created = fetch_one("SELECT * FROM RESTAURANT WHERE Rest_Id = %s;", (next_id,))
        return {"status": "success", "role": "Restaurant", "data": created}
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


@router.post("/register/dark-store")
def register_dark_store(req: RegisterDarkStoreRequest):
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Database connection error.")
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(Store_Id), 0) + 1 AS next_id FROM DARK_STORE;")
        next_id = cursor.fetchone()["next_id"]

        phone = req.phone or f"98100{next_id:05d}"
        query = """
            INSERT INTO DARK_STORE (Store_Id, DS_Phone, Password, DS_Street, DS_Area, DS_State, DS_Pincode)
            VALUES (%s, %s, %s, %s, %s, %s, %s);
        """
        cursor.execute(query, (next_id, phone, req.password, req.street, req.area, req.state, req.pincode))
        conn.commit()
        created = fetch_one("SELECT * FROM DARK_STORE WHERE Store_Id = %s;", (next_id,))
        return {"status": "success", "role": "Dark Store", "data": created}
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

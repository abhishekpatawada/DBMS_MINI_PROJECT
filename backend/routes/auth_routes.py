from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from backend.database import fetch_one, execute_query, get_db_connection

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


class LoginRequest(BaseModel):
    role: str  # "User", "Delivery Agent", "Restaurant", "Dark Store"
    phone_or_id: str


class RegisterUserRequest(BaseModel):
    name: str
    phone: str
    street: Optional[str] = ""
    area: Optional[str] = ""
    state: Optional[str] = ""
    pincode: Optional[str] = ""


class RegisterAgentRequest(BaseModel):
    name: str
    phone: str
    vehicle_no: Optional[str] = ""
    v_type: Optional[str] = "Motorcycle"
    has_license: Optional[bool] = True


class RegisterRestaurantRequest(BaseModel):
    name: str
    location: str
    phone: Optional[str] = ""
    rating: Optional[float] = 4.0


class RegisterDarkStoreRequest(BaseModel):
    street: str
    area: str
    state: str
    pincode: str


@router.post("/login")
def login(req: LoginRequest):
    role = req.role.strip()
    identifier = req.phone_or_id.strip()

    if role == "User":
        user = fetch_one("SELECT * FROM USERS WHERE User_Phone = %s OR User_Id = %s;", (identifier, identifier))
        if not user:
            raise HTTPException(status_code=404, detail="User not found with this phone number.")
        return {"status": "success", "role": "User", "data": user}

    elif role == "Delivery Agent":
        agent = fetch_one("SELECT * FROM DELIVERY_AGENT WHERE Agent_Phone = %s OR Agent_Id = %s;", (identifier, identifier))
        if not agent:
            raise HTTPException(status_code=404, detail="Delivery Agent not found with this phone number.")
        return {"status": "success", "role": "Delivery Agent", "data": agent}

    elif role == "Restaurant":
        restaurant = fetch_one("SELECT * FROM RESTAURANT WHERE RPhone = %s OR Rest_Id = %s OR RName = %s;", (identifier, identifier, identifier))
        if not restaurant:
            raise HTTPException(status_code=404, detail="Restaurant not found with this phone/ID.")
        return {"status": "success", "role": "Restaurant", "data": restaurant}

    elif role == "Dark Store":
        store = fetch_one("SELECT * FROM DARK_STORE WHERE Store_Id = %s OR DS_Pincode = %s OR DS_Area = %s;", (identifier, identifier, identifier))
        if not store:
            raise HTTPException(status_code=404, detail="Dark Store not found with this ID/Pincode.")
        return {"status": "success", "role": "Dark Store", "data": store}

    else:
        raise HTTPException(status_code=400, detail="Invalid role specified.")


@router.post("/register/user")
def register_user(req: RegisterUserRequest):
    existing = fetch_one("SELECT * FROM USERS WHERE User_Phone = %s;", (req.phone,))
    if existing:
        raise HTTPException(status_code=400, detail="User phone already registered.")
    
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Database connection error.")
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(User_Id), 0) + 1 AS next_id FROM USERS;")
        next_id = cursor.fetchone()["next_id"]
        
        query = """
            INSERT INTO USERS (User_Id, User_Name, User_Phone, Street, Area, State, Pincode)
            VALUES (%s, %s, %s, %s, %s, %s, %s);
        """
        cursor.execute(query, (next_id, req.name, req.phone, req.street, req.area, req.state, req.pincode))
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
        raise HTTPException(status_code=400, detail="Agent phone already registered.")
    
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Database connection error.")
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(Agent_Id), 0) + 1 AS next_id FROM DELIVERY_AGENT;")
        next_id = cursor.fetchone()["next_id"]

        query = """
            INSERT INTO DELIVERY_AGENT (Agent_Id, Agent_Name, Agent_Phone, VehicleNO, V_Type, Has_license, Rating)
            VALUES (%s, %s, %s, %s, %s, %s, 5.0);
        """
        cursor.execute(query, (next_id, req.name, req.phone, req.vehicle_no, req.v_type, req.has_license))
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

        query = """
            INSERT INTO RESTAURANT (Rest_Id, RName, RLocation, RPhone, RRating)
            VALUES (%s, %s, %s, %s, %s);
        """
        cursor.execute(query, (next_id, req.name, req.location, req.phone, req.rating))
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

        query = """
            INSERT INTO DARK_STORE (Store_Id, DS_Street, DS_Area, DS_State, DS_Pincode)
            VALUES (%s, %s, %s, %s, %s);
        """
        cursor.execute(query, (next_id, req.street, req.area, req.state, req.pincode))
        conn.commit()
        created = fetch_one("SELECT * FROM DARK_STORE WHERE Store_Id = %s;", (next_id,))
        return {"status": "success", "role": "Dark Store", "data": created}
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

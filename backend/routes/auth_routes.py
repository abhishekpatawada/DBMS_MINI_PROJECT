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
        user = fetch_one("SELECT * FROM users WHERE User_Phone = %s OR User_Id = %s;", (identifier, identifier))
        if not user:
            raise HTTPException(status_code=404, detail="User not found with this phone number.")
        return {"status": "success", "role": "User", "data": user}

    elif role == "Delivery Agent":
        agent = fetch_one("SELECT * FROM delivery_agent WHERE Agent_Phone = %s OR Agent_Id = %s;", (identifier, identifier))
        if not agent:
            raise HTTPException(status_code=404, detail="Delivery Agent not found with this phone number.")
        return {"status": "success", "role": "Delivery Agent", "data": agent}

    elif role == "Restaurant":
        restaurant = fetch_one("SELECT * FROM restaurant WHERE RPhone = %s OR Rest_Id = %s OR RName = %s;", (identifier, identifier, identifier))
        if not restaurant:
            raise HTTPException(status_code=404, detail="Restaurant not found with this phone/ID.")
        return {"status": "success", "role": "Restaurant", "data": restaurant}

    elif role == "Dark Store":
        store = fetch_one("SELECT * FROM dark_store WHERE Store_Id = %s OR DS_Pincode = %s OR DS_Area = %s;", (identifier, identifier, identifier))
        if not store:
            raise HTTPException(status_code=404, detail="Dark Store not found with this ID/Pincode.")
        return {"status": "success", "role": "Dark Store", "data": store}

    else:
        raise HTTPException(status_code=400, detail="Invalid role specified.")


@router.post("/register/user")
def register_user(req: RegisterUserRequest):
    existing = fetch_one("SELECT * FROM users WHERE User_Phone = %s;", (req.phone,))
    if existing:
        raise HTTPException(status_code=400, detail="User phone already registered.")
    
    query = """
        INSERT INTO users (User_Name, User_Phone, Street, Area, State, Pincode)
        VALUES (%s, %s, %s, %s, %s, %s);
    """
    if execute_query(query, (req.name, req.phone, req.street, req.area, req.state, req.pincode)):
        created = fetch_one("SELECT * FROM users WHERE User_Phone = %s;", (req.phone,))
        return {"status": "success", "role": "User", "data": created}
    raise HTTPException(status_code=500, detail="Failed to register user.")


@router.post("/register/agent")
def register_agent(req: RegisterAgentRequest):
    existing = fetch_one("SELECT * FROM delivery_agent WHERE Agent_Phone = %s;", (req.phone,))
    if existing:
        raise HTTPException(status_code=400, detail="Agent phone already registered.")
    
    query = """
        INSERT INTO delivery_agent (Agent_Name, Agent_Phone, VehicleNO, V_Type, Has_license, Rating)
        VALUES (%s, %s, %s, %s, %s, 5.0);
    """
    if execute_query(query, (req.name, req.phone, req.vehicle_no, req.v_type, req.has_license)):
        created = fetch_one("SELECT * FROM delivery_agent WHERE Agent_Phone = %s;", (req.phone,))
        return {"status": "success", "role": "Delivery Agent", "data": created}
    raise HTTPException(status_code=500, detail="Failed to register agent.")


@router.post("/register/restaurant")
def register_restaurant(req: RegisterRestaurantRequest):
    query = """
        INSERT INTO restaurant (RName, RLocation, RPhone, RRating)
        VALUES (%s, %s, %s, %s);
    """
    if execute_query(query, (req.name, req.location, req.phone, req.rating)):
        created = fetch_one("SELECT * FROM restaurant ORDER BY Rest_Id DESC LIMIT 1;")
        return {"status": "success", "role": "Restaurant", "data": created}
    raise HTTPException(status_code=500, detail="Failed to register restaurant.")


@router.post("/register/dark-store")
def register_dark_store(req: RegisterDarkStoreRequest):
    query = """
        INSERT INTO dark_store (DS_Street, DS_Area, DS_State, DS_Pincode)
        VALUES (%s, %s, %s, %s);
    """
    if execute_query(query, (req.street, req.area, req.state, req.pincode)):
        created = fetch_one("SELECT * FROM dark_store ORDER BY Store_Id DESC LIMIT 1;")
        return {"status": "success", "role": "Dark Store", "data": created}
    raise HTTPException(status_code=500, detail="Failed to register dark store.")

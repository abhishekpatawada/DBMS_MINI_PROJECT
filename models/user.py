from dataclasses import dataclass
from typing import Optional


@dataclass
class User:
    User_Id: Optional[int]
    User_Name: str
    User_Phone: str
    Street: Optional[str] = None
    Area: Optional[str] = None
    State: Optional[str] = None
    Pincode: Optional[str] = None

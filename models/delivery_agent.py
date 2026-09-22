from dataclasses import dataclass
from typing import Optional


@dataclass
class DeliveryAgent:
    Agent_Id: Optional[int]
    Agent_Name: str
    Agent_Phone: str
    VehicleNO: Optional[str] = None
    V_Type: Optional[str] = None
    Has_license: bool = True
    Rating: float = 5.0

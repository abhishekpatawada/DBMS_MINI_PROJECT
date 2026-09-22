from dataclasses import dataclass
from typing import Optional


@dataclass
class DarkStore:
    Store_Id: Optional[int]
    DS_Street: Optional[str] = None
    DS_Area: Optional[str] = None
    DS_State: Optional[str] = None
    DS_Pincode: Optional[str] = None


@dataclass
class GroceryItem:
    Store_Id: int
    Item_Name: str
    Price: float = 0.0
    Available_count: int = 0

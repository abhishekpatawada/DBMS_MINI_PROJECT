from dataclasses import dataclass
from typing import Optional
from datetime import datetime


@dataclass
class Order:
    Order_Id: Optional[int]
    User_Id: int
    Agent_Id: Optional[int] = None
    Order_Type: str = "Restaurant"
    Order_Status: str = "Placed"
    Total_Amount: float = 0.0
    Order_Date: Optional[datetime] = None


@dataclass
class OrderItem:
    Item_Order_Id: Optional[int]
    Order_Id: int
    Item_Name: str
    Quantity: int = 1
    Item_Price: float = 0.0
    Subtotal: Optional[float] = None

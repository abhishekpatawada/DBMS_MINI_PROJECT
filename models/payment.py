from dataclasses import dataclass
from typing import Optional
from datetime import datetime


@dataclass
class Payment:
    Payment_Id: Optional[int]
    Order_Id: int
    Payment_Method: str
    Payment_Status: str = "Completed"
    Transaction_Date: Optional[datetime] = None
    Amount: float = 0.0

from dataclasses import dataclass
from typing import Optional


@dataclass
class Restaurant:
    Rest_Id: Optional[int]
    RName: str
    RLocation: str
    RPhone: Optional[str] = None
    RRating: float = 4.0


@dataclass
class RestaurantItem:
    Rest_Id: int
    Item_Name: str
    Food_Name: Optional[str] = None
    Is_Veg: bool = True
    BasePrice: float = 0.0
    Discount: float = 0.0
    FinalPrice: Optional[float] = None

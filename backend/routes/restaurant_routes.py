from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from backend.restaurant_service import (
    get_all_restaurants,
    get_restaurant_by_id,
    create_restaurant,
    update_restaurant,
    delete_restaurant,
    get_restaurant_menu,
    add_restaurant_item,
    update_restaurant_item,
    delete_restaurant_item,
    get_all_dishes,
    get_restaurant_revenue_analytics
)

router = APIRouter(prefix="/api/restaurants", tags=["Restaurants"])


class RestaurantCreateUpdate(BaseModel):
    name: str
    location: str
    phone: Optional[str] = ""
    rating: Optional[float] = 4.0


class MenuItemCreate(BaseModel):
    item_name: str
    food_name: Optional[str] = ""
    is_veg: Optional[bool] = True
    base_price: float
    discount: Optional[float] = 0.0
    image_url: Optional[str] = None


class MenuItemUpdate(BaseModel):
    new_item_name: str
    food_name: Optional[str] = ""
    is_veg: Optional[bool] = True
    base_price: float
    discount: Optional[float] = 0.0
    image_url: Optional[str] = None


@router.get("")
def list_restaurants():
    return get_all_restaurants()


@router.get("/dishes/all")
def list_all_dishes():
    return get_all_dishes()


@router.get("/{rest_id}")
def get_restaurant(rest_id: int):
    rest = get_restaurant_by_id(rest_id)
    if not rest:
        raise HTTPException(status_code=404, detail="Restaurant not found.")
    return rest


@router.post("")
def add_restaurant(req: RestaurantCreateUpdate):
    if create_restaurant(req.name, req.location, req.phone, req.rating):
        return {"status": "success", "message": "Restaurant created"}
    raise HTTPException(status_code=400, detail="Failed to create restaurant.")


@router.put("/{rest_id}")
def edit_restaurant(rest_id: int, req: RestaurantCreateUpdate):
    if update_restaurant(rest_id, req.name, req.location, req.phone, req.rating):
        return {"status": "success", "message": "Restaurant updated"}
    raise HTTPException(status_code=400, detail="Failed to update restaurant.")


@router.delete("/{rest_id}")
def remove_restaurant(rest_id: int):
    if delete_restaurant(rest_id):
        return {"status": "success", "message": "Restaurant deleted"}
    raise HTTPException(status_code=400, detail="Failed to delete restaurant.")


# --- Menu Items ---

@router.get("/{rest_id}/menu")
def list_menu(rest_id: int):
    return get_restaurant_menu(rest_id)


@router.post("/{rest_id}/menu")
def add_menu_item(rest_id: int, req: MenuItemCreate):
    if add_restaurant_item(rest_id, req.item_name, req.food_name, req.is_veg, req.base_price, req.discount, req.image_url):
        return {"status": "success", "message": "Menu item added"}
    raise HTTPException(status_code=400, detail="Failed to add menu item.")


@router.put("/{rest_id}/menu/{item_name}")
def edit_menu_item(rest_id: int, item_name: str, req: MenuItemUpdate):
    if update_restaurant_item(rest_id, item_name, req.new_item_name, req.food_name, req.is_veg, req.base_price, req.discount, req.image_url):
        return {"status": "success", "message": "Menu item updated"}
    raise HTTPException(status_code=400, detail="Failed to update menu item.")


@router.delete("/{rest_id}/menu/{item_name}")
def remove_menu_item(rest_id: int, item_name: str):
    if delete_restaurant_item(rest_id, item_name):
        return {"status": "success", "message": "Menu item deleted"}
    raise HTTPException(status_code=400, detail="Failed to delete menu item.")


# --- Big Screen Revenue Dashboard Analytics ---

@router.get("/{rest_id}/revenue-analytics")
def restaurant_revenue_analytics(rest_id: int):
    analytics = get_restaurant_revenue_analytics(rest_id)
    if not analytics:
        raise HTTPException(status_code=404, detail="Restaurant analytics unavailable.")
    return analytics


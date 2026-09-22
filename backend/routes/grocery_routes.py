from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from backend.grocery_service import (
    get_all_dark_stores,
    get_store_by_id,
    create_dark_store,
    update_dark_store,
    delete_dark_store,
    get_groceries_by_store,
    add_grocery_item,
    update_grocery_item,
    delete_grocery_item
)

router = APIRouter(prefix="/api/dark-stores", tags=["Dark Stores & Groceries"])


class DarkStoreCreateUpdate(BaseModel):
    street: str
    area: str
    state: str
    pincode: str


class GroceryItemCreate(BaseModel):
    item_name: str
    price: float
    available_count: int


class GroceryItemUpdate(BaseModel):
    new_item_name: str
    price: float
    available_count: int


@router.get("")
def list_dark_stores():
    return get_all_dark_stores()


@router.get("/{store_id}")
def get_dark_store(store_id: int):
    store = get_store_by_id(store_id)
    if not store:
        raise HTTPException(status_code=404, detail="Dark store not found.")
    return store


@router.post("")
def add_dark_store(req: DarkStoreCreateUpdate):
    if create_dark_store(req.street, req.area, req.state, req.pincode):
        return {"status": "success", "message": "Dark store created"}
    raise HTTPException(status_code=400, detail="Failed to create dark store.")


@router.put("/{store_id}")
def edit_dark_store(store_id: int, req: DarkStoreCreateUpdate):
    if update_dark_store(store_id, req.street, req.area, req.state, req.pincode):
        return {"status": "success", "message": "Dark store updated"}
    raise HTTPException(status_code=400, detail="Failed to update dark store.")


@router.delete("/{store_id}")
def remove_dark_store(store_id: int):
    if delete_dark_store(store_id):
        return {"status": "success", "message": "Dark store deleted"}
    raise HTTPException(status_code=400, detail="Failed to delete dark store.")


# --- Groceries ---

@router.get("/{store_id}/groceries")
def list_groceries(store_id: int):
    return get_groceries_by_store(store_id)


@router.post("/{store_id}/groceries")
def add_grocery(store_id: int, req: GroceryItemCreate):
    if add_grocery_item(store_id, req.item_name, req.price, req.available_count):
        return {"status": "success", "message": "Grocery item added"}
    raise HTTPException(status_code=400, detail="Failed to add grocery item.")


@router.put("/{store_id}/groceries/{item_name}")
def edit_grocery(store_id: int, item_name: str, req: GroceryItemUpdate):
    if update_grocery_item(store_id, item_name, req.new_item_name, req.price, req.available_count):
        return {"status": "success", "message": "Grocery item updated"}
    raise HTTPException(status_code=400, detail="Failed to update grocery item.")


@router.delete("/{store_id}/groceries/{item_name}")
def remove_grocery(store_id: int, item_name: str):
    if delete_grocery_item(store_id, item_name):
        return {"status": "success", "message": "Grocery item deleted"}
    raise HTTPException(status_code=400, detail="Failed to delete grocery item.")

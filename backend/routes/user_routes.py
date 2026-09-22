from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from backend.user_service import get_all_users, get_user_by_id, create_user, update_user, delete_user

router = APIRouter(prefix="/api/users", tags=["Users"])


class UserCreateUpdate(BaseModel):
    name: str
    phone: str
    street: Optional[str] = ""
    area: Optional[str] = ""
    state: Optional[str] = ""
    pincode: Optional[str] = ""


@router.get("")
def list_users():
    return get_all_users()


@router.get("/{user_id}")
def get_user(user_id: int):
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")
    return user


@router.post("")
def add_user(req: UserCreateUpdate):
    if create_user(req.name, req.phone, req.street, req.area, req.state, req.pincode):
        return {"status": "success", "message": "User created successfully"}
    raise HTTPException(status_code=400, detail="Failed to create user.")


@router.put("/{user_id}")
def edit_user(user_id: int, req: UserCreateUpdate):
    if update_user(user_id, req.name, req.phone, req.street, req.area, req.state, req.pincode):
        return {"status": "success", "message": "User updated successfully"}
    raise HTTPException(status_code=400, detail="Failed to update user.")


@router.delete("/{user_id}")
def remove_user(user_id: int):
    if delete_user(user_id):
        return {"status": "success", "message": "User deleted successfully"}
    raise HTTPException(status_code=400, detail="Failed to delete user.")

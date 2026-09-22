from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
from backend.order_service import (
    get_all_orders,
    get_user_orders,
    get_order_by_id,
    get_order_items,
    create_order_with_items,
    update_order_status,
    delete_order
)
from backend.delivery_service import assign_agent_to_order

router = APIRouter(prefix="/api/orders", tags=["Orders"])


class OrderItemInput(BaseModel):
    name: str
    quantity: int
    price: float


class PlaceOrderRequest(BaseModel):
    user_id: int
    agent_id: Optional[int] = None
    order_type: str  # "Restaurant" or "Grocery"
    payment_method: str  # "UPI", "Credit Card", "Debit Card", "Cash on Delivery"
    items: List[OrderItemInput]


class UpdateStatusRequest(BaseModel):
    status: str


class AssignAgentRequest(BaseModel):
    agent_id: Optional[int] = None


@router.get("")
def list_orders():
    return get_all_orders()


@router.get("/user/{user_id}")
def list_user_orders(user_id: int):
    return get_user_orders(user_id)


@router.get("/{order_id}")
def get_order(order_id: int):
    order = get_order_by_id(order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found.")
    items = get_order_items(order_id)
    return {"order": order, "items": items}


@router.post("")
def place_order(req: PlaceOrderRequest):
    items_dicts = [item.model_dump() for item in req.items]
    success, order_id = create_order_with_items(
        user_id=req.user_id,
        agent_id=req.agent_id,
        order_type=req.order_type,
        items=items_dicts,
        payment_method=req.payment_method
    )
    if success:
        return {"status": "success", "order_id": order_id, "message": "Order placed successfully"}
    raise HTTPException(status_code=400, detail="Failed to place order.")


@router.put("/{order_id}/status")
def change_order_status(order_id: int, req: UpdateStatusRequest):
    if update_order_status(order_id, req.status):
        return {"status": "success", "message": f"Order status updated to {req.status}"}
    raise HTTPException(status_code=400, detail="Failed to update status.")


@router.put("/{order_id}/assign")
def change_order_agent(order_id: int, req: AssignAgentRequest):
    if assign_agent_to_order(order_id, req.agent_id):
        return {"status": "success", "message": "Agent assigned to order"}
    raise HTTPException(status_code=400, detail="Failed to assign agent.")


@router.delete("/{order_id}")
def remove_order(order_id: int):
    if delete_order(order_id):
        return {"status": "success", "message": "Order deleted"}
    raise HTTPException(status_code=400, detail="Failed to delete order.")

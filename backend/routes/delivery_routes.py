from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from backend.delivery_service import (
    get_all_delivery_agents,
    get_agent_by_id,
    create_delivery_agent,
    update_delivery_agent,
    delete_delivery_agent,
    get_agent_assigned_orders,
    update_order_status,
    assign_agent_to_order
)

router = APIRouter(prefix="/api/delivery-agents", tags=["Delivery Agents"])


class AgentCreateUpdate(BaseModel):
    name: str
    phone: str
    vehicle_no: Optional[str] = ""
    v_type: Optional[str] = "Motorcycle"
    has_license: Optional[bool] = True
    rating: Optional[float] = 5.0


class AssignAgentRequest(BaseModel):
    agent_id: Optional[int] = None


class OrderStatusRequest(BaseModel):
    status: str


@router.get("")
def list_agents():
    return get_all_delivery_agents()


@router.get("/{agent_id}")
def get_agent(agent_id: int):
    agent = get_agent_by_id(agent_id)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found.")
    return agent


@router.post("")
def add_agent(req: AgentCreateUpdate):
    if create_delivery_agent(req.name, req.phone, req.vehicle_no, req.v_type, req.has_license, req.rating):
        return {"status": "success", "message": "Delivery Agent created"}
    raise HTTPException(status_code=400, detail="Failed to create agent.")


@router.put("/{agent_id}")
def edit_agent(agent_id: int, req: AgentCreateUpdate):
    if update_delivery_agent(agent_id, req.name, req.phone, req.vehicle_no, req.v_type, req.has_license, req.rating):
        return {"status": "success", "message": "Delivery Agent updated"}
    raise HTTPException(status_code=400, detail="Failed to update agent.")


@router.delete("/{agent_id}")
def remove_agent(agent_id: int):
    if delete_delivery_agent(agent_id):
        return {"status": "success", "message": "Delivery Agent deleted"}
    raise HTTPException(status_code=400, detail="Failed to delete agent.")


@router.get("/{agent_id}/orders")
def list_agent_orders(agent_id: int):
    return get_agent_assigned_orders(agent_id)

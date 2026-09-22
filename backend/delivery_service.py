from backend.database import fetch_all, fetch_one, execute_query


def get_all_delivery_agents() -> list:
    """Retrieve all delivery agents (Read)."""
    query = "SELECT * FROM delivery_agent ORDER BY Agent_Id ASC;"
    return fetch_all(query)


def get_agent_by_id(agent_id: int) -> dict | None:
    """Retrieve delivery agent by ID (Read)."""
    query = "SELECT * FROM delivery_agent WHERE Agent_Id = %s;"
    return fetch_one(query, (agent_id,))


def create_delivery_agent(name: str, phone: str, vehicle_no: str, v_type: str, has_license: bool = True, rating: float = 5.0) -> bool:
    """Register a new delivery agent (Create)."""
    query = """
        INSERT INTO delivery_agent (Agent_Name, Agent_Phone, VehicleNO, V_Type, Has_license, Rating)
        VALUES (%s, %s, %s, %s, %s, %s);
    """
    return execute_query(query, (name, phone, vehicle_no, v_type, has_license, rating))


def update_delivery_agent(agent_id: int, name: str, phone: str, vehicle_no: str, v_type: str, has_license: bool, rating: float) -> bool:
    """Update delivery agent details (Update)."""
    query = """
        UPDATE delivery_agent
        SET Agent_Name = %s, Agent_Phone = %s, VehicleNO = %s, V_Type = %s, Has_license = %s, Rating = %s
        WHERE Agent_Id = %s;
    """
    return execute_query(query, (name, phone, vehicle_no, v_type, has_license, rating, agent_id))


def delete_delivery_agent(agent_id: int) -> bool:
    """Delete a delivery agent (Delete)."""
    query = "DELETE FROM delivery_agent WHERE Agent_Id = %s;"
    return execute_query(query, (agent_id,))


def get_agent_assigned_orders(agent_id: int) -> list:
    """Retrieve all active/past orders assigned to a specific delivery agent."""
    query = """
        SELECT o.Order_Id, o.User_Id, u.User_Name, u.User_Phone, 
               CONCAT(u.Street, ', ', u.Area, ', ', u.State, ' - ', u.Pincode) AS Delivery_Address,
               o.Order_Type, o.Order_Status, o.Total_Amount, o.Order_Date
        FROM orders o
        JOIN users u ON o.User_Id = u.User_Id
        WHERE o.Agent_Id = %s
        ORDER BY o.Order_Date DESC;
    """
    return fetch_all(query, (agent_id,))


def update_order_status(order_id: int, status: str) -> bool:
    """Update order status (Update)."""
    query = "UPDATE orders SET Order_Status = %s WHERE Order_Id = %s;"
    return execute_query(query, (status, order_id))


def assign_agent_to_order(order_id: int, agent_id: int | None) -> bool:
    """Assign or reassign delivery agent to an order (Update)."""
    query = "UPDATE orders SET Agent_Id = %s WHERE Order_Id = %s;"
    return execute_query(query, (agent_id, order_id))

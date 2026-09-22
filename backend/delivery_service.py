from backend.database import fetch_all, fetch_one, execute_query


def get_all_delivery_agents() -> list:
    """Retrieve all delivery agents."""
    query = "SELECT * FROM delivery_agent ORDER BY Rating DESC;"
    return fetch_all(query)


def get_agent_by_id(agent_id: int) -> dict | None:
    """Retrieve delivery agent by ID."""
    query = "SELECT * FROM delivery_agent WHERE Agent_Id = %s;"
    return fetch_one(query, (agent_id,))


def get_agent_assigned_orders(agent_id: int) -> list:
    """Retrieve all active orders assigned to a specific delivery agent."""
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


def update_agent_order_status(order_id: int, status: str) -> bool:
    """Update order status by agent."""
    query = "UPDATE orders SET Order_Status = %s WHERE Order_Id = %s;"
    return execute_query(query, (status, order_id))

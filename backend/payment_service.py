from backend.database import fetch_all, fetch_one, execute_query


def get_payment_by_order(order_id: int) -> dict | None:
    """Retrieve payment details for an order."""
    query = "SELECT * FROM payments WHERE Order_Id = %s;"
    return fetch_one(query, (order_id,))


def create_payment(order_id: int, method: str, amount: float, status: str = "Completed") -> bool:
    """Record a payment for an order."""
    query = """
        INSERT INTO payments (Order_Id, Payment_Method, Payment_Status, Amount)
        VALUES (%s, %s, %s, %s);
    """
    return execute_query(query, (order_id, method, status, amount))

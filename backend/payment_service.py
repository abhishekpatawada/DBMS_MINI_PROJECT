from backend.database import fetch_all, fetch_one, execute_query, get_db_connection


def get_payment_by_order(order_id: int) -> dict | None:
    """Retrieve payment details for an order."""
    query = "SELECT * FROM PAYMENT WHERE Order_Id = %s;"
    return fetch_one(query, (order_id,))


def create_payment(order_id: int, method: str, amount: float) -> bool:
    """Record a payment for an order."""
    conn = get_db_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(Payment_Id), 0) + 1 AS next_id FROM PAYMENT;")
        pay_res = cursor.fetchone()
        next_pid = pay_res["next_id"] if pay_res else 1

        query = """
            INSERT INTO PAYMENT (Payment_Id, Order_Id, Payment_Method, Amount)
            VALUES (%s, %s, %s, %s);
        """
        cursor.execute(query, (next_pid, order_id, method, amount))
        conn.commit()
        return True
    except Exception as e:
        print(f"Error creating payment: {e}")
        conn.rollback()
        return False
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

from backend.database import fetch_all, fetch_one, execute_query, get_db_connection


def get_all_users() -> list:
    """Retrieve all users."""
    query = "SELECT * FROM USERS ORDER BY User_Id ASC;"
    return fetch_all(query)


def get_user_by_id(user_id: int) -> dict | None:
    """Retrieve user by ID."""
    query = "SELECT * FROM USERS WHERE User_Id = %s;"
    return fetch_one(query, (user_id,))


def create_user(name: str, phone: str, street: str, area: str, state: str, pincode: str) -> bool:
    """Create a new user (Create)."""
    conn = get_db_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT COALESCE(MAX(User_Id), 0) + 1 AS next_id FROM USERS;")
        next_id = cursor.fetchone()["next_id"]

        query = """
            INSERT INTO USERS (User_Id, User_Name, User_Phone, Street, Area, State, Pincode)
            VALUES (%s, %s, %s, %s, %s, %s, %s);
        """
        cursor.execute(query, (next_id, name, phone, street, area, state, pincode))
        conn.commit()
        return True
    except Exception as e:
        print(f"Error creating user: {e}")
        conn.rollback()
        return False
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


def update_user(user_id: int, name: str, phone: str, street: str, area: str, state: str, pincode: str) -> bool:
    """Update existing user details (Update)."""
    query = """
        UPDATE USERS
        SET User_Name = %s, User_Phone = %s, Street = %s, Area = %s, State = %s, Pincode = %s
        WHERE User_Id = %s;
    """
    return execute_query(query, (name, phone, street, area, state, pincode, user_id))


def delete_user(user_id: int) -> bool:
    """Delete a user and cascading records (Delete)."""
    query = "DELETE FROM USERS WHERE User_Id = %s;"
    return execute_query(query, (user_id,))

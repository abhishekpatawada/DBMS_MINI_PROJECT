from backend.database import fetch_all, fetch_one, execute_query


def get_all_users() -> list:
    """Retrieve all users."""
    query = "SELECT * FROM users ORDER BY User_Id ASC;"
    return fetch_all(query)


def get_user_by_id(user_id: int) -> dict | None:
    """Retrieve user by ID."""
    query = "SELECT * FROM users WHERE User_Id = %s;"
    return fetch_one(query, (user_id,))


def create_user(name: str, phone: str, street: str, area: str, state: str, pincode: str) -> bool:
    """Create a new user."""
    query = """
        INSERT INTO users (User_Name, User_Phone, Street, Area, State, Pincode)
        VALUES (%s, %s, %s, %s, %s, %s);
    """
    return execute_query(query, (name, phone, street, area, state, pincode))

import mysql.connector
from mysql.connector import Error
from backend.config import DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME


def get_db_connection():
    """Establish and return a connection to the MySQL database."""
    try:
        connection = mysql.connector.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
        )
        return connection
    except Error as e:
        print(f"Error connecting to MySQL database: {e}")
        return None


def execute_query(query: str, params: tuple = None) -> bool:
    """Execute an INSERT, UPDATE, or DELETE query."""
    conn = get_db_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor()
        cursor.execute(query, params or ())
        conn.commit()
        return True
    except Error as e:
        print(f"Database execute error: {e}")
        conn.rollback()
        return False
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


def fetch_all(query: str, params: tuple = None) -> list:
    """Execute a SELECT query and return all results as a list of dictionaries."""
    conn = get_db_connection()
    if not conn:
        return []
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        records = cursor.fetchall()
        return records
    except Error as e:
        print(f"Database fetch_all error: {e}")
        return []
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


def fetch_one(query: str, params: tuple = None) -> dict | None:
    """Execute a SELECT query and return a single result as a dictionary."""
    conn = get_db_connection()
    if not conn:
        return None
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        record = cursor.fetchone()
        return record
    except Error as e:
        print(f"Database fetch_one error: {e}")
        return None
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


def test_connection() -> tuple[bool, str]:
    """Test MySQL database connection and return status and message."""
    conn = get_db_connection()
    if conn and conn.is_connected():
        conn.close()
        return True, "Successfully connected to MySQL database."
    return False, "Failed to connect to MySQL database. Check your .env configuration."

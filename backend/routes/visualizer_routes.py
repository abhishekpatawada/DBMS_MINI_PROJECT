"""
Visualizer & SQL Workbench API Routes.
"""
from fastapi import APIRouter
from pydantic import BaseModel
from visualizer.schema_inspector import get_schema_metadata
from visualizer.query_analyzer import execute_sql_workbench, analyze_sql_query

router = APIRouter(prefix="/api/visualizer", tags=["SQL Visualizer & Workbench"])


class QueryExecutionRequest(BaseModel):
    query: str
    max_rows: int = 100


PRESET_QUERIES = [
    {
        "id": "all_orders_joined",
        "title": "1. Multi-Table Order Trace (Users + Orders + Agents + Payments)",
        "category": "Complex JOINs",
        "description": "Performs 4-table JOIN displaying order details, customer info, delivery rider details, and payment method.",
        "sql": """SELECT 
    o.Order_Id,
    u.User_Name AS Customer,
    u.User_Phone,
    da.Agent_Name AS Delivery_Rider,
    da.VehicleNO,
    p.Payment_Method,
    p.Amount,
    o.PlacedAt,
    o.DeliveredAt,
    o.Agent_Rating
FROM orders o
JOIN users u ON o.User_Id = u.User_Id
LEFT JOIN delivery_agent da ON o.Agent_Id = da.Agent_Id
LEFT JOIN payment p ON o.Order_Id = p.Order_Id
ORDER BY o.Order_Id ASC
LIMIT 15;"""
    },
    {
        "id": "restaurant_menu_pricing",
        "title": "2. Restaurant Menu & Discount Calculation",
        "category": "Computed Attributes",
        "description": "Examines restaurant items with base price, discount percentage, and calculated final price.",
        "sql": """SELECT 
    r.RName AS Restaurant,
    r.RLocation AS Location,
    ri.Item_Name AS Dish,
    ri.Food_Name AS Category,
    ri.Is_Veg,
    ri.BasePrice,
    ri.Discount AS Discount_Percent,
    ri.FinalPrice
FROM rest_items ri
JOIN restaurant r ON ri.Rest_Id = r.Rest_Id
ORDER BY r.RName, ri.FinalPrice DESC
LIMIT 20;"""
    },
    {
        "id": "weak_entity_groceries",
        "title": "3. Dark Store Grocery Inventory (Weak Entity Inspection)",
        "category": "Weak Entity",
        "description": "Demonstrates the weak entity relationship where Groceries rely on (Store_Id, Item_Name).",
        "sql": """SELECT 
    ds.Store_Id,
    ds.DS_Area AS Dark_Store_Area,
    ds.DS_State AS State,
    g.Item_Name AS Product,
    g.Price AS Unit_Price,
    g.Available_count AS In_Stock
FROM groceries g
JOIN dark_store ds ON g.Store_Id = ds.Store_Id
ORDER BY ds.Store_Id, g.Available_count ASC
LIMIT 20;"""
    },
    {
        "id": "order_items_junction",
        "title": "4. Order Items Breakdown (M:N Relationship)",
        "category": "M:N Junction",
        "description": "Inspects the ORDER_ITEM relationship entity associating orders with restaurant dishes.",
        "sql": """SELECT 
    oi.Order_Id,
    r.RName AS Restaurant,
    oi.Item_Name,
    oi.Food_quantity,
    ri.FinalPrice AS Unit_Price,
    (oi.Food_quantity * ri.FinalPrice) AS Total_Item_Cost
FROM order_item oi
JOIN rest_items ri ON oi.Rest_Id = ri.Rest_Id AND oi.Item_Name = ri.Item_Name
JOIN restaurant r ON oi.Rest_Id = r.Rest_Id
ORDER BY oi.Order_Id ASC
LIMIT 15;"""
    },
    {
        "id": "revenue_aggregation",
        "title": "5. Revenue & Transaction Count by Payment Method",
        "category": "Aggregations",
        "description": "Aggregates revenue, transaction volume, and average order value per payment gateway.",
        "sql": """SELECT 
    p.Payment_Method,
    COUNT(p.Payment_Id) AS Total_Transactions,
    SUM(p.Amount) AS Total_Revenue,
    ROUND(AVG(p.Amount), 2) AS Average_Order_Value
FROM payment p
GROUP BY p.Payment_Method
ORDER BY Total_Revenue DESC;"""
    },
    {
        "id": "top_rated_agents",
        "title": "6. Top Rated Delivery Riders with Licensing",
        "category": "Filtered Query",
        "description": "Filters licensed delivery riders having a customer rating above 4.5.",
        "sql": """SELECT 
    Agent_Id,
    Agent_Name,
    Agent_Phone,
    VehicleNO,
    V_Type,
    Rating
FROM delivery_agent
WHERE Has_license = TRUE AND Rating >= 4.70
ORDER BY Rating DESC, Agent_Name ASC
LIMIT 20;"""
    },
    {
        "id": "all_users_list",
        "title": "7. Customer Directory by State & City",
        "category": "Actor Query",
        "description": "Retrieves registered user demographic and location information.",
        "sql": """SELECT 
    User_Id,
    User_Name,
    User_Phone,
    Street,
    Area,
    State,
    Pincode
FROM users
ORDER BY State, Area, User_Name
LIMIT 25;"""
    }
]


@router.get("/schema")
def get_schema():
    """Retrieve full database metadata, tables, columns, and foreign key relations."""
    return get_schema_metadata()


@router.get("/presets")
def get_presets():
    """Get categorized sample queries for demonstration and evaluation."""
    return {"success": True, "presets": PRESET_QUERIES}


@router.post("/execute")
def execute_query(req: QueryExecutionRequest):
    """Execute raw SQL query and return execution statistics, columns, rows, and touched tables."""
    return execute_sql_workbench(req.query, req.max_rows)


@router.post("/analyze")
def analyze_query(req: QueryExecutionRequest):
    """Analyze query to detect touched tables and syntax properties without executing."""
    return {"success": True, "analysis": analyze_sql_query(req.query)}

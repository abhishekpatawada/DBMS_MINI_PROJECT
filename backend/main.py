from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.database import test_connection
from backend.routes.auth_routes import router as auth_router
from backend.routes.user_routes import router as user_router
from backend.routes.restaurant_routes import router as restaurant_router
from backend.routes.grocery_routes import router as grocery_router
from backend.routes.delivery_routes import router as delivery_router
from backend.routes.order_routes import router as order_router

app = FastAPI(
    title="DBMS Project REST API",
    description="Backend API for Food & Grocery Multi-Vendor Delivery System",
    version="1.0.0"
)

# Enable CORS for Flutter Web / Desktop / Mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API Routers
app.include_router(auth_router)
app.include_router(user_router)
app.include_router(restaurant_router)
app.include_router(grocery_router)
app.include_router(delivery_router)
app.include_router(order_router)


@app.get("/")
def root():
    is_connected, msg = test_connection()
    return {
        "app": "DBMS Project API",
        "database_connected": is_connected,
        "database_message": msg,
        "docs_url": "/docs"
    }


@app.get("/health")
def health():
    is_connected, msg = test_connection()
    return {"status": "ok" if is_connected else "database_down", "message": msg}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)

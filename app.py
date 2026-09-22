import streamlit as st
from backend.database import test_connection
from frontend.user.dashboard import render_user_view
from frontend.delivery_agent.dashboard import render_delivery_agent_view
from frontend.restaurant.dashboard import render_restaurant_view
from frontend.dark_store.dashboard import render_dark_store_view

# Page Configuration
st.set_page_config(
    page_title="DBMS Project",
    page_icon="📦",
    layout="wide",
    initial_sidebar_state="expanded"
)

# App Title & Header
st.title("DBMS Project")
st.caption("Food & Grocery Multi-Vendor Delivery Management System")

# Sidebar - Role Selection & DB Status
with st.sidebar:
    st.header("Navigation")
    
    role = st.selectbox(
        "Select Role",
        options=["User", "Delivery Agent", "Restaurant", "Dark Store"],
        index=0,
        help="Select a role to view its dedicated portal"
    )
    
    st.divider()
    st.subheader("Database Status")
    is_connected, msg = test_connection()
    if is_connected:
        st.success("🟢 MySQL Connected")
    else:
        st.warning("🔴 MySQL Disconnected")
        st.caption("Configure `.env` using `.env.example`.")

# Main View Routing based on Selected Role
if role == "User":
    render_user_view()
elif role == "Delivery Agent":
    render_delivery_agent_view()
elif role == "Restaurant":
    render_restaurant_view()
elif role == "Dark Store":
    render_dark_store_view()

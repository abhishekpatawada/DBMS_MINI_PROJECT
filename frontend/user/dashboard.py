import streamlit as st


def render_user_view():
    """Render the placeholder dashboard for User role."""
    st.header("👤 Customer Portal")
    st.info("Browse restaurant menus, order dark store groceries, track orders, and view order history.")
    
    col1, col2 = st.columns(2)
    with col1:
        st.subheader("🍽️ Browse Restaurants")
        st.caption("View menus, veg/non-veg selections, and discounted pricing.")
    with col2:
        st.subheader("🛒 Dark Store Essentials")
        st.caption("Browse fast delivery daily groceries with real-time stock availability.")

import streamlit as st


def render_restaurant_view():
    """Render the placeholder dashboard for Restaurant role."""
    st.header("🏪 Restaurant Partner Portal")
    st.info("Manage menu items, toggle food availability, set discounts, and monitor incoming orders.")
    
    col1, col2 = st.columns(2)
    with col1:
        st.subheader("📋 Menu Management")
        st.caption("Add new dishes, configure base prices, and manage discounts.")
    with col2:
        st.subheader("🔔 Incoming Orders")
        st.caption("Accept and prepare orders in real-time.")

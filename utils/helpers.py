def format_currency(amount: float) -> str:
    """Format float amount into INR currency string."""
    try:
        return f"₹{float(amount):,.2f}"
    except (ValueError, TypeError):
        return f"₹0.00"


def format_status_badge(status: str) -> str:
    """Return colored emoji tag for order status."""
    status_map = {
        "Placed": "🟡 Placed",
        "Preparing": "🟠 Preparing",
        "Out for Delivery": "🚚 Out for Delivery",
        "Delivered": "✅ Delivered",
        "Cancelled": "❌ Cancelled",
    }
    return status_map.get(status, status)

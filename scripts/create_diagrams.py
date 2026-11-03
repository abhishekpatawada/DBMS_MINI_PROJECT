import os
from PIL import Image, ImageDraw, ImageFont

os.makedirs("report_assets", exist_ok=True)

# Helper font loader with fallback
def get_font(size=14, bold=False):
    font_names = [
        "timesbd.ttf" if bold else "times.ttf",
        "arialbd.ttf" if bold else "arial.ttf",
        "calibrib.ttf" if bold else "calibri.ttf"
    ]
    for fn in font_names:
        try:
            return ImageFont.truetype(f"C:\\Windows\\Fonts\\{fn}", size)
        except Exception:
            pass
    return ImageFont.load_default()

# -------------------------------------------------------------
# 1. UVCE Emblem / Seal Generator
# -------------------------------------------------------------
def create_uvce_logo():
    w, h = 500, 500
    img = Image.new("RGBA", (w, h), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)

    # Outer ornate circular badge
    gold = (184, 134, 11)
    dark_gold = (139, 90, 0)
    
    # Concentric circles
    draw.ellipse([20, 20, 480, 480], outline=gold, width=6)
    draw.ellipse([35, 35, 465, 465], outline=dark_gold, width=3)
    draw.ellipse([60, 60, 440, 440], outline=gold, width=4)

    # Sanskrit / College Motto Ribbon
    f_title = get_font(20, bold=True)
    f_sub = get_font(16, bold=True)
    f_motto = get_font(18, bold=True)

    draw.text((250, 80), "UNIVERSITY OF VISVESVARAYA", fill=dark_gold, font=f_sub, anchor="mm")
    draw.text((250, 110), "COLLEGE OF ENGINEERING", fill=dark_gold, font=f_sub, anchor="mm")
    
    # Mythical Gandaberunda / Double-headed eagle simplified emblem
    # Crown
    draw.polygon([(250, 150), (230, 180), (270, 180)], outline=dark_gold, fill=(255, 223, 128), width=3)
    draw.ellipse([240, 135, 260, 155], outline=dark_gold, fill=(218, 165, 32), width=3)
    
    # Two heads
    draw.arc([190, 180, 240, 230], start=180, end=360, fill=dark_gold, width=4)
    draw.arc([260, 180, 310, 230], start=180, end=360, fill=dark_gold, width=4)
    draw.polygon([(185, 205), (170, 215), (190, 220)], fill=dark_gold) # left beak
    draw.polygon([(315, 205), (330, 215), (310, 220)], fill=dark_gold) # right beak

    # Wings
    draw.arc([120, 210, 240, 320], start=160, end=330, fill=dark_gold, width=5)
    draw.arc([260, 210, 380, 320], start=210, end=20, fill=dark_gold, width=5)
    
    # Body Shield
    draw.polygon([(250, 350), (190, 240), (310, 240)], outline=dark_gold, fill=(255, 248, 220), width=4)
    draw.text((250, 275), "UVCE", fill=dark_gold, font=get_font(28, bold=True), anchor="mm")
    draw.text((250, 305), "ESTD 1917", fill=dark_gold, font=get_font(14, bold=True), anchor="mm")

    # Bottom scroll
    draw.rectangle([130, 390, 370, 435], outline=dark_gold, fill=(255, 250, 230), width=3)
    draw.text((250, 412), "विद्यया सर्वत्र गौरवम्", fill=dark_gold, font=f_motto, anchor="mm")

    img.save("report_assets/uvce_logo.png")
    print("Created uvce_logo.png")

# -------------------------------------------------------------
# 2. Figure 1: Comprehensive ER Diagram
# -------------------------------------------------------------
def create_er_diagram():
    w, h = 1600, 1200
    img = Image.new("RGB", (w, h), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    f_box = get_font(18, bold=True)
    f_rel = get_font(16, bold=True)
    f_attr = get_font(14, bold=False)
    f_attr_pk = get_font(14, bold=True)
    f_card = get_font(16, bold=True)

    # Box styles
    ent_border = (30, 41, 59)
    ent_bg = (248, 250, 252)
    rel_border = (79, 70, 229)
    rel_bg = (238, 242, 255)
    attr_border = (100, 116, 139)
    attr_bg = (255, 255, 255)

    def draw_entity(x, y, text, is_weak=False):
        bw, bh = 180, 60
        left, top = x - bw//2, y - bh//2
        draw.rectangle([left, top, left+bw, top+bh], fill=ent_bg, outline=ent_border, width=3)
        if is_weak:
            draw.rectangle([left+5, top+5, left+bw-5, top+bh-5], outline=ent_border, width=2)
        draw.text((x, y), text, fill=ent_border, font=f_box, anchor="mm")
        return (left, top, bw, bh)

    def draw_relation(x, y, text, is_identifying=False):
        rw, rh = 130, 60
        pts = [(x, y - rh//2), (x + rw//2, y), (x, y + rh//2), (x - rw//2, y)]
        draw.polygon(pts, fill=rel_bg, outline=rel_border, width=3)
        if is_identifying:
            inner_pts = [(x, y - rh//2 + 6), (x + rw//2 - 10, y), (x, y + rh//2 - 6), (x - rw//2 + 10, y)]
            draw.polygon(inner_pts, outline=rel_border, width=2)
        draw.text((x, y), text, fill=rel_border, font=f_rel, anchor="mm")

    def draw_attribute(x, y, text, is_pk=False, is_multi=False):
        aw, ah = 130, 42
        left, top = x - aw//2, y - ah//2
        draw.ellipse([left, top, left+aw, top+ah], fill=attr_bg, outline=attr_border, width=2)
        if is_multi:
            draw.ellipse([left+4, top+3, left+aw-4, top+ah-3], outline=attr_border, width=1)
        font = f_attr_pk if is_pk else f_attr
        draw.text((x, y), text, fill=(15, 23, 42), font=font, anchor="mm")
        if is_pk:
            # Underline primary key
            draw.line([(x - 35, y + 8), (x + 35, y + 8)], fill=(15, 23, 42), width=2)

    # 1. Main Center Entity: ORDERS
    draw_entity(800, 550, "ORDERS")
    draw_attribute(700, 450, "Order_Id", is_pk=True)
    draw_line_attr = lambda ax, ay, ex, ey: draw.line([(ax, ay), (ex, ey)], fill=(148, 163, 184), width=2)
    draw_line_attr(700, 450, 750, 520)
    draw_attribute(800, 430, "Status")
    draw_line_attr(800, 430, 800, 520)
    draw_attribute(900, 450, "Total_Amount")
    draw_line_attr(900, 450, 850, 520)
    draw_attribute(920, 500, "PlacedAt")
    draw_line_attr(920, 500, 880, 540)

    # 2. USERS Entity (Top Left)
    draw_entity(300, 200, "USERS")
    draw_attribute(180, 120, "User_Id", is_pk=True)
    draw_line_attr(180, 120, 240, 175)
    draw_attribute(300, 100, "User_Name")
    draw_line_attr(300, 100, 300, 170)
    draw_attribute(420, 120, "User_Phone", is_multi=True)
    draw_line_attr(420, 120, 360, 175)
    draw_attribute(160, 200, "Address")
    draw_line_attr(160, 200, 210, 200)

    # Relation: USERS places ORDERS
    draw_relation(550, 370, "places")
    draw.line([(300, 230), (550, 370)], fill=(71, 85, 105), width=3)
    draw.line([(550, 370), (760, 525)], fill=(71, 85, 105), width=3)
    draw.text((370, 270), "1", fill=(225, 29, 72), font=f_card)
    draw.text((700, 480), "N", fill=(225, 29, 72), font=f_card)

    # 3. RESTAURANT Entity (Top Right)
    draw_entity(1300, 200, "RESTAURANT")
    draw_attribute(1180, 110, "Rest_Id", is_pk=True)
    draw_line_attr(1180, 110, 1240, 175)
    draw_attribute(1300, 90, "RName")
    draw_line_attr(1300, 90, 1300, 170)
    draw_attribute(1420, 110, "RLocation")
    draw_line_attr(1420, 110, 1360, 175)
    draw_attribute(1440, 190, "RRating")
    draw_line_attr(1440, 190, 1390, 200)

    # Relation: RESTAURANT prepares ORDERS
    draw_relation(1050, 370, "prepares")
    draw.line([(1300, 230), (1050, 370)], fill=(71, 85, 105), width=3)
    draw.line([(1050, 370), (840, 525)], fill=(71, 85, 105), width=3)
    draw.text((1220, 280), "1", fill=(225, 29, 72), font=f_card)
    draw.text((900, 480), "N", fill=(225, 29, 72), font=f_card)

    # 4. REST_ITEMS Entity (Weak / Dependent on RESTAURANT)
    draw_entity(1300, 550, "REST_ITEMS")
    draw_attribute(1450, 490, "Item_Name", is_pk=True)
    draw_line_attr(1450, 490, 1390, 530)
    draw_attribute(1470, 550, "BasePrice")
    draw_line_attr(1470, 550, 1390, 550)
    draw_attribute(1450, 610, "Discount")
    draw_line_attr(1450, 610, 1390, 570)
    draw_attribute(1300, 660, "Is_Veg")
    draw_line_attr(1300, 660, 1300, 580)

    # Relation: RESTAURANT serves REST_ITEMS
    draw_relation(1300, 375, "serves")
    draw.line([(1300, 230), (1300, 375)], fill=(71, 85, 105), width=3)
    draw.line([(1300, 375), (1300, 520)], fill=(71, 85, 105), width=3)
    draw.text((1315, 270), "1", fill=(225, 29, 72), font=f_card)
    draw.text((1315, 470), "N", fill=(225, 29, 72), font=f_card)

    # Relation: ORDER_ITEM (M:N between ORDERS and REST_ITEMS)
    draw_relation(1050, 550, "includes")
    draw.line([(890, 550), (1050, 550)], fill=(71, 85, 105), width=3)
    draw.line([(1050, 550), (1210, 550)], fill=(71, 85, 105), width=3)
    draw.text((920, 525), "M", fill=(225, 29, 72), font=f_card)
    draw.text((1180, 525), "N", fill=(225, 29, 72), font=f_card)
    # Relationship attribute: Quantity
    draw_attribute(1050, 470, "Food_quantity")
    draw_line_attr(1050, 470, 1050, 520)

    # 5. DARK_STORE Entity (Bottom Right)
    draw_entity(1300, 950, "DARK_STORE")
    draw_attribute(1440, 900, "Store_Id", is_pk=True)
    draw_line_attr(1440, 900, 1380, 930)
    draw_attribute(1450, 960, "DS_Phone")
    draw_line_attr(1450, 960, 1390, 960)
    draw_attribute(1440, 1020, "DS_Area")
    draw_line_attr(1440, 1020, 1380, 980)

    # 6. GROCERIES Entity (Weak Entity of DARK_STORE)
    draw_entity(800, 950, "GROCERIES", is_weak=True)
    draw_attribute(660, 900, "Item_Name", is_pk=True)
    draw_line_attr(660, 900, 720, 930)
    draw_attribute(650, 960, "Price")
    draw_line_attr(650, 960, 710, 960)
    draw_attribute(660, 1020, "Available_count")
    draw_line_attr(660, 1020, 720, 980)

    # Identifying Relation: stocks (DARK_STORE -> GROCERIES)
    draw_relation(1050, 950, "stocks", is_identifying=True)
    draw.line([(1210, 950), (1050, 950)], fill=(71, 85, 105), width=3)
    draw.line([(1050, 950), (890, 950)], fill=(71, 85, 105), width=3)
    draw.text((1180, 925), "1", fill=(225, 29, 72), font=f_card)
    draw.text((920, 925), "N", fill=(225, 29, 72), font=f_card)

    # Relation: ORDERS contains GROCERIES (M:N)
    draw_relation(800, 750, "contains")
    draw.line([(800, 580), (800, 750)], fill=(71, 85, 105), width=3)
    draw.line([(800, 750), (800, 920)], fill=(71, 85, 105), width=3)
    draw.text((815, 620), "M", fill=(225, 29, 72), font=f_card)
    draw.text((815, 870), "N", fill=(225, 29, 72), font=f_card)
    draw_attribute(930, 750, "Quantity")
    draw_line_attr(930, 750, 865, 750)

    # 7. DELIVERY_AGENT Entity (Bottom Left)
    draw_entity(300, 950, "DELIVERY_AGENT")
    draw_attribute(160, 880, "Agent_Id", is_pk=True)
    draw_line_attr(160, 880, 230, 925)
    draw_attribute(150, 950, "Agent_Name")
    draw_line_attr(150, 950, 210, 950)
    draw_attribute(160, 1020, "VehicleNO")
    draw_line_attr(160, 1020, 230, 975)
    draw_attribute(300, 1060, "Rating")
    draw_line_attr(300, 1060, 300, 980)

    # Relation: DELIVERY_AGENT fulfills ORDERS
    draw_relation(550, 750, "delivers")
    draw.line([(300, 920), (550, 750)], fill=(71, 85, 105), width=3)
    draw.line([(550, 750), (760, 575)], fill=(71, 85, 105), width=3)
    draw.text((370, 840), "1", fill=(225, 29, 72), font=f_card)
    draw.text((700, 620), "N", fill=(225, 29, 72), font=f_card)

    # 8. PAYMENT Entity (Middle Left)
    draw_entity(300, 550, "PAYMENT")
    draw_attribute(170, 480, "Payment_Id", is_pk=True)
    draw_line_attr(170, 480, 230, 525)
    draw_attribute(160, 550, "Payment_Method")
    draw_line_attr(160, 550, 210, 550)
    draw_attribute(170, 620, "Amount")
    draw_line_attr(170, 620, 230, 575)

    # Relation: ORDERS has PAYMENT (1:1)
    draw_relation(550, 550, "pays_for")
    draw.line([(710, 550), (550, 550)], fill=(71, 85, 105), width=3)
    draw.line([(550, 550), (390, 550)], fill=(71, 85, 105), width=3)
    draw.text((670, 525), "1", fill=(225, 29, 72), font=f_card)
    draw.text((430, 525), "1", fill=(225, 29, 72), font=f_card)

    img.save("report_assets/figure1_er_diagram.png")
    print("Created figure1_er_diagram.png")

# -------------------------------------------------------------
# 3. Figure 2: Relational Model Schema Diagram
# -------------------------------------------------------------
def create_relational_model():
    w, h = 1600, 1100
    img = Image.new("RGB", (w, h), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    f_title = get_font(18, bold=True)
    f_col = get_font(14, bold=False)
    f_pk = get_font(14, bold=True)

    def draw_table(x, y, name, cols, pk_count=1, width=700):
        th = 32
        ch = 28
        total_h = th + ch * len(cols)
        # Header
        draw.rectangle([x, y, x + width, y + th], fill=(79, 70, 229), outline=(55, 48, 163), width=2)
        draw.text((x + 15, y + th//2), name, fill=(255, 255, 255), font=f_title, anchor="lm")
        # Body
        draw.rectangle([x, y + th, x + width, y + total_h], fill=(248, 250, 252), outline=(203, 213, 225), width=2)
        
        for i, (c_name, c_type, c_key) in enumerate(cols):
            cy = y + th + i * ch
            # Alternating rows
            if i % 2 == 1:
                draw.rectangle([x + 2, cy, x + width - 2, cy + ch], fill=(241, 245, 249))
            font = f_pk if "PK" in c_key else f_col
            fill = (15, 23, 42) if "PK" in c_key else (51, 65, 85)
            draw.text((x + 15, cy + ch//2), c_name, fill=fill, font=font, anchor="lm")
            draw.text((x + 300, cy + ch//2), c_type, fill=(100, 116, 139), font=f_col, anchor="lm")
            badge_color = (225, 29, 72) if "PK" in c_key else ((16, 185, 129) if "FK" in c_key else (148, 163, 184))
            draw.text((x + width - 80, cy + ch//2), c_key, fill=badge_color, font=f_pk, anchor="lm")
        return total_h

    # Left Column Tables
    y_l = 40
    # 1. USERS
    y_l += draw_table(60, y_l, "USERS", [
        ("User_Id", "INT", "PK"),
        ("User_Name", "VARCHAR(100)", ""),
        ("User_Phone", "VARCHAR(15)", "UNIQUE"),
        ("Password", "VARCHAR(255)", ""),
        ("Street, Area, State, Pincode", "VARCHAR", "")
    ]) + 30

    # 2. ORDERS
    y_l += draw_table(60, y_l, "ORDERS", [
        ("Order_Id", "INT", "PK"),
        ("User_Id", "INT", "FK -> USERS"),
        ("Rest_Id", "INT", "FK -> RESTAURANT"),
        ("Store_Id", "INT", "FK -> DARK_STORE"),
        ("Agent_Id", "INT", "FK -> AGENT"),
        ("PlacedAt, DeliveredAt", "DATETIME", ""),
        ("Status", "VARCHAR(50)", ""),
        ("Total_Amount", "DECIMAL(10,2)", "")
    ]) + 30

    # 3. ORDER_ITEM
    y_l += draw_table(60, y_l, "ORDER_ITEM", [
        ("Order_Id", "INT", "PK, FK -> ORDERS"),
        ("Rest_Id", "INT", "PK, FK -> REST_ITEMS"),
        ("Item_Name", "VARCHAR(100)", "PK, FK -> REST_ITEMS"),
        ("Food_quantity", "INT", "")
    ]) + 30

    # 4. ORDER_GROCERY
    draw_table(60, y_l, "ORDER_GROCERY", [
        ("Order_Id", "INT", "PK, FK -> ORDERS"),
        ("Store_Id", "INT", "PK, FK -> GROCERIES"),
        ("Item_Name", "VARCHAR(100)", "PK, FK -> GROCERIES"),
        ("Quantity", "INT", "")
    ])

    # Right Column Tables
    y_r = 40
    # 5. RESTAURANT
    y_r += draw_table(840, y_r, "RESTAURANT", [
        ("Rest_Id", "INT", "PK"),
        ("RName", "VARCHAR(100)", ""),
        ("RLocation", "VARCHAR(200)", ""),
        ("RPhone", "VARCHAR(15)", ""),
        ("RRating", "DECIMAL(3,2)", ""),
        ("Image_Url", "VARCHAR(500)", "")
    ]) + 30

    # 6. REST_ITEMS
    y_r += draw_table(840, y_r, "REST_ITEMS", [
        ("Rest_Id", "INT", "PK, FK -> RESTAURANT"),
        ("Item_Name", "VARCHAR(100)", "PK"),
        ("Food_Name", "VARCHAR(100)", ""),
        ("Is_Veg", "BOOLEAN", ""),
        ("BasePrice, Discount, FinalPrice", "DECIMAL", ""),
        ("Image_Url", "VARCHAR(500)", "")
    ]) + 30

    # 7. DARK_STORE
    y_r += draw_table(840, y_r, "DARK_STORE", [
        ("Store_Id", "INT", "PK"),
        ("DS_Phone", "VARCHAR(15)", ""),
        ("DS_Street, DS_Area, DS_State, Pincode", "VARCHAR", "")
    ]) + 30

    # 8. GROCERIES
    y_r += draw_table(840, y_r, "GROCERIES", [
        ("Store_Id", "INT", "PK, FK -> DARK_STORE"),
        ("Item_Name", "VARCHAR(100)", "PK"),
        ("Price", "DECIMAL(10,2)", ""),
        ("Available_count", "INT", ""),
        ("Image_Url", "VARCHAR(500)", "")
    ]) + 30

    # 9. DELIVERY_AGENT
    draw_table(840, y_r, "DELIVERY_AGENT", [
        ("Agent_Id", "INT", "PK"),
        ("Agent_Name", "VARCHAR(100)", ""),
        ("Agent_Phone", "VARCHAR(15)", ""),
        ("VehicleNO, V_Type, Has_license", "VARCHAR", ""),
        ("Rating", "DECIMAL(3,2)", "")
    ])

    img.save("report_assets/figure2_relational_model.png")
    print("Created figure2_relational_model.png")

# -------------------------------------------------------------
# 4. High-Fidelity UI Screen Mockups (Figures 3 to 8)
# -------------------------------------------------------------
def create_ui_mockup(filename, title, subtitle, cards_data, accent_color=(79, 70, 229)):
    w, h = 1200, 680
    img = Image.new("RGB", (w, h), (248, 250, 252))
    draw = ImageDraw.Draw(img)

    f_title = get_font(24, bold=True)
    f_sub = get_font(16, bold=False)
    f_card_t = get_font(18, bold=True)
    f_card_b = get_font(14, bold=False)

    # App Bar
    draw.rectangle([0, 0, w, 70], fill=accent_color)
    draw.text((30, 22), "BiteHub", fill=(255, 255, 255), font=get_font(26, bold=True))
    draw.text((150, 25), "•  " + title, fill=(224, 231, 255), font=get_font(20, bold=False))
    draw.text((w - 200, 25), "🟢 Server: 10.74.88.1", fill=(255, 255, 255), font=get_font(15, bold=True))

    # Header section
    draw.rectangle([30, 90, w - 30, 160], fill=(255, 255, 255), outline=(226, 232, 240), width=2)
    draw.text((50, 105), title, fill=(15, 23, 42), font=f_title)
    draw.text((50, 135), subtitle, fill=(100, 116, 139), font=f_sub)

    # 4 Content Cards
    card_w = (w - 60 - 45) // 4
    for i, (c_title, c_val, c_tag, c_desc) in enumerate(cards_data):
        cx = 30 + i * (card_w + 15)
        cy = 180
        draw.rectangle([cx, cy, cx + card_w, cy + 220], fill=(255, 255, 255), outline=(226, 232, 240), width=2)
        # Top banner in card
        draw.rectangle([cx, cy, cx + card_w, cy + 8], fill=accent_color)
        draw.text((cx + 15, cy + 25), c_title, fill=(30, 41, 59), font=f_card_t)
        draw.text((cx + 15, cy + 60), c_val, fill=accent_color, font=get_font(26, bold=True))
        # Tag pill
        draw.rectangle([cx + 15, cy + 105, cx + 120, cy + 130], fill=(238, 242, 255), outline=(199, 210, 254))
        draw.text((cx + 25, cy + 112), c_tag, fill=accent_color, font=get_font(12, bold=True))
        draw.text((cx + 15, cy + 150), c_desc, fill=(100, 116, 139), font=f_card_b)

    # Bottom Data Table / Console Mockup
    draw.rectangle([30, 420, w - 30, 640], fill=(255, 255, 255), outline=(226, 232, 240), width=2)
    draw.rectangle([30, 420, w - 30, 460], fill=(241, 245, 249))
    draw.text((50, 432), "RECENT LIVE ACTIVITY / TRANSACTION LOGS", fill=(71, 85, 105), font=get_font(14, bold=True))

    rows = [
        ("ORD #1084", "Royal Palace 1 - Chicken Biryani x2", "Aarav Choudhury (Indiranagar)", "₹720.00", "Out for Delivery (Agent #1)"),
        ("ORD #1085", "Instamart Store 1 - Amul Milk, Bread, Eggs", "Vivaan Mukherjee (Koramangala)", "₹215.00", "Delivered (Agent #2)"),
        ("ORD #1086", "Spice House 1 - Butter Paneer, Garlic Naan", "Aditya Kulkarni (Whitefield)", "₹460.00", "Preparing (Kitchen Accepted)"),
        ("ORD #1087", "Taste of Bawarchi 1 - Mutton Dum Biryani", "Pari Malhotra (Jayanagar)", "₹580.00", "Order Placed (Paid via UPI)")
    ]

    for j, (col1, col2, col3, col4, col5) in enumerate(rows):
        ry = 465 + j * 42
        if j % 2 == 1:
            draw.rectangle([32, ry, w - 32, ry + 40], fill=(248, 250, 252))
        draw.text((50, ry + 12), col1, fill=(15, 23, 42), font=get_font(13, bold=True))
        draw.text((160, ry + 12), col2, fill=(30, 41, 59), font=get_font(13, bold=False))
        draw.text((520, ry + 12), col3, fill=(71, 85, 105), font=get_font(13, bold=False))
        draw.text((820, ry + 12), col4, fill=(16, 185, 129), font=get_font(13, bold=True))
        draw.text((950, ry + 12), col5, fill=accent_color, font=get_font(13, bold=True))

    img.save(f"report_assets/{filename}")
    print(f"Created {filename}")

if __name__ == "__main__":
    create_uvce_logo()
    create_er_diagram()
    create_relational_model()

    # Figures 3 to 8
    create_ui_mockup("figure3_landing.png", "Enterprise Landing Portal & Unified Auth",
                     "Multi-Role Gateway for Customers, Restaurants, Dark Stores, and Delivery Fleet",
                     [("Total Users", "1,248+", "Active", "Verified Phone Logins"),
                      ("Restaurants", "45+", "Onboarded", "100% Menu Digitalized"),
                      ("Dark Stores", "12 Hubs", "10-Min Fast", "Live Stocked Marts"),
                      ("Fleet Riders", "85+", "Available", "GPS Integrated Fleet")])

    create_ui_mockup("figure4_customer.png", "Customer Food & Hyperlocal Grocery Experience",
                     "Dual-Delivery Engine with Curated Banners, Multi-Item Smart Cart & Live Tracking",
                     [("Biryani Feasts", "₹299", "Best Seller", "Royal Palace 1 (4.8★)"),
                      ("Fresh Dairy", "₹32", "In Stock", "Indiranagar Hub (10m)"),
                      ("Discount Code", "-20%", "FEAST20", "Flat 20% on all orders"),
                      ("Active Order", "ORD #1084", "On the Way", "Arriving in 12 mins")],
                     accent_color=(16, 185, 129))

    create_ui_mockup("figure5_restaurant.png", "Restaurant Partner Kitchen & Menu Management",
                     "Live Order Fulfillment Pipeline with Integrated 100+ HD Food Photo Gallery",
                     [("Live Orders", "6 Pending", "Urgent", "Kitchen preparing now"),
                      ("Today Sales", "₹14,850", "+18.2%", "38 orders fulfilled"),
                      ("Menu Items", "24 Dishes", "CRUD Active", "Full Price & Discount Control"),
                      ("Rating", "4.82★", "Superb", "Based on 310 reviews")],
                     accent_color=(234, 88, 12))

    create_ui_mockup("figure6_darkstore.png", "Dark Store Quick-Commerce Inventory Hub",
                     "Real-Time Stock Monitoring, Low-Stock Warning Badges & Packing Pipeline",
                     [("SKUs Listed", "350 Items", "6 Categories", "Fruits, Dairy, Snacks"),
                      ("Low Stock", "3 Warning", "Restock Now", "Below 5 threshold units"),
                      ("Dispatched", "64 Bags", "100% on time", "Average packing: 2.8 mins"),
                      ("Inventory Val", "₹1,84,200", "Live Valuation", "Synced with MySQL DB")],
                     accent_color=(13, 148, 136))

    create_ui_mockup("figure7_delivery.png", "Delivery Agent Fleet App & Route Execution",
                     "Instant Task Feed, Status Progression (Picked Up -> Delivered) & Earnings",
                     [("Assigned", "ORD #1084", "Urgent", "Pickup: Royal Palace 1"),
                      ("Drop-off", "Indiranagar", "2.1 km", "Customer: Aarav C."),
                      ("Today Payout", "₹840.00", "7 Deliveries", "Base Pay + ₹110 Tips"),
                      ("Agent Rating", "4.92★", "Top Rider", "KA-08-DF-1001 (Bike)")],
                     accent_color=(59, 130, 246))

    create_ui_mockup("figure8_sql_visualizer.png", "Live SQL Visualizer & DBMS Query Explorer",
                     "Direct In-App Relational Database Query Console with Latency Benchmarking",
                     [("Tables Analyzed", "10 Tables", "3NF Schema", "Relational Integrity OK"),
                      ("Query Timing", "14.2 ms", "Optimized", "InnoDB Indexed Execution"),
                      ("ACID Tests", "Passed", "Zero Lock", "Auto-Rollback on Cancel"),
                      ("Active Conns", "8 Live", "FastAPI Pool", "Port 3306 Healthy")],
                     accent_color=(124, 58, 237))


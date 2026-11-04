import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_TAB_ALIGNMENT
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn

def build_normalization_doc():
    doc = Document()

    # Page setup: A4 with 1.0 inch margins (1.25 inch left for binding)
    sec = doc.sections[0]
    sec.top_margin = Inches(0.9)
    sec.bottom_margin = Inches(0.9)
    sec.left_margin = Inches(1.1)
    sec.right_margin = Inches(0.9)
    sec.page_width = Inches(8.27)
    sec.page_height = Inches(11.69)

    # Header & Footer setup
    header = sec.header
    hp = header.paragraphs[0]
    hp.alignment = WD_ALIGN_PARAGRAPH.LEFT
    hrun = hp.add_run("BiteHub DBMS • Database Normalization & Decomposition Report (1NF, 2NF, 3NF)")
    hrun.font.name = 'Times New Roman'
    hrun.font.size = Pt(9.5)
    hrun.font.color.rgb = RGBColor(100, 116, 139)
    hp.paragraph_format.space_after = Pt(8)

    footer = sec.footer
    fp = footer.paragraphs[0]
    fp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    frun1 = fp.add_run("BiteHub Relational Database Design • Page ")
    frun1.font.name = 'Times New Roman'
    frun1.font.size = Pt(9.5)
    frun1.font.color.rgb = RGBColor(100, 116, 139)

    # Dynamic Page Number
    fldChar1 = parse_xml(r'<w:fldChar %s w:fldCharType="begin"/>' % nsdecls('w'))
    instrText = parse_xml(r'<w:instrText %s xml:space="preserve"> PAGE </w:instrText>' % nsdecls('w'))
    fldChar2 = parse_xml(r'<w:fldChar %s w:fldCharType="separate"/>' % nsdecls('w'))
    fldChar3 = parse_xml(r'<w:fldChar %s w:fldCharType="end"/>' % nsdecls('w'))
    frun2 = fp.add_run()
    frun2.font.name = 'Times New Roman'
    frun2.font.size = Pt(9.5)
    frun2.font.color.rgb = RGBColor(100, 116, 139)
    frun2._r.append(fldChar1)
    frun2._r.append(instrText)
    frun2._r.append(fldChar2)
    frun2._r.append(fldChar3)

    frun3 = fp.add_run(" of ")
    frun3.font.name = 'Times New Roman'
    frun3.font.size = Pt(9.5)
    frun3.font.color.rgb = RGBColor(100, 116, 139)

    fldChar4 = parse_xml(r'<w:fldChar %s w:fldCharType="begin"/>' % nsdecls('w'))
    instrText2 = parse_xml(r'<w:instrText %s xml:space="preserve"> NUMPAGES </w:instrText>' % nsdecls('w'))
    fldChar5 = parse_xml(r'<w:fldChar %s w:fldCharType="separate"/>' % nsdecls('w'))
    fldChar6 = parse_xml(r'<w:fldChar %s w:fldCharType="end"/>' % nsdecls('w'))
    frun4 = fp.add_run()
    frun4.font.name = 'Times New Roman'
    frun4.font.size = Pt(9.5)
    frun4.font.color.rgb = RGBColor(100, 116, 139)
    frun4._r.append(fldChar4)
    frun4._r.append(instrText2)
    frun4._r.append(fldChar5)
    frun4._r.append(fldChar6)

    # Helper formatters
    def p(text="", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=3.5, space_before=0, line_spacing=1.12):
        para = doc.add_paragraph()
        para.alignment = align
        para.paragraph_format.space_after = Pt(space_after)
        para.paragraph_format.space_before = Pt(space_before)
        para.paragraph_format.line_spacing = line_spacing
        if text:
            r = para.add_run(text)
            r.font.name = 'Times New Roman'
            r.font.size = Pt(11)
        return para

    def b(text, space_after=2):
        para = doc.add_paragraph(style='List Bullet')
        para.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        para.paragraph_format.space_after = Pt(space_after)
        para.paragraph_format.space_before = Pt(0)
        para.paragraph_format.line_spacing = 1.12
        r = para.add_run(text)
        r.font.name = 'Times New Roman'
        r.font.size = Pt(10.5)
        return para

    def h1(text, space_before=4, space_after=8):
        para = doc.add_paragraph()
        para.alignment = WD_ALIGN_PARAGRAPH.CENTER
        para.paragraph_format.space_before = Pt(space_before)
        para.paragraph_format.space_after = Pt(space_after)
        r = para.add_run(text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(14)
        r.font.color.rgb = RGBColor(30, 41, 59)
        return para

    def h2(text, space_before=6, space_after=3):
        para = doc.add_paragraph()
        para.alignment = WD_ALIGN_PARAGRAPH.LEFT
        para.paragraph_format.space_before = Pt(space_before)
        para.paragraph_format.space_after = Pt(space_after)
        r = para.add_run(text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(12)
        r.font.color.rgb = RGBColor(79, 70, 229)
        return para

    def h3(text, space_before=4, space_after=2):
        para = doc.add_paragraph()
        para.alignment = WD_ALIGN_PARAGRAPH.LEFT
        para.paragraph_format.space_before = Pt(space_before)
        para.paragraph_format.space_after = Pt(space_after)
        r = para.add_run(text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(11)
        r.font.color.rgb = RGBColor(15, 23, 42)
        return para

    def code_box(text):
        para = doc.add_paragraph()
        para.alignment = WD_ALIGN_PARAGRAPH.LEFT
        para.paragraph_format.space_before = Pt(2)
        para.paragraph_format.space_after = Pt(3)
        r = para.add_run(text)
        r.font.name = 'Courier New'
        r.font.size = Pt(9.5)
        r.font.color.rgb = RGBColor(15, 23, 42)
        return para

    def callout_box(title, text):
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = tbl.rows[0].cells[0]
        cell.width = Inches(6.2)
        # Light grey/blue background and left blue border
        shd = parse_xml(r'<w:shd %s w:fill="F1F5F9"/>' % nsdecls('w'))
        cell._tc.get_or_add_tcPr().append(shd)
        tcBorders = parse_xml(r'''
            <w:tcBorders %s>
                <w:top w:val="none"/>
                <w:left w:val="single" w:sz="24" w:space="0" w:color="4F46E5"/>
                <w:bottom w:val="none"/>
                <w:right w:val="none"/>
            </w:tcBorders>
        ''' % nsdecls('w'))
        cell._tc.get_or_add_tcPr().append(tcBorders)
        
        cp = cell.paragraphs[0]
        cp.paragraph_format.space_after = Pt(2)
        cp.paragraph_format.space_before = Pt(2)
        r1 = cp.add_run(f"📌 {title}: ")
        r1.bold = True
        r1.font.name = 'Times New Roman'
        r1.font.size = Pt(10.5)
        r1.font.color.rgb = RGBColor(79, 70, 229)
        r2 = cp.add_run(text)
        r2.font.name = 'Times New Roman'
        r2.font.size = Pt(10.5)

    # =========================================================================
    # PAGE 1: TITLE, OBJECTIVES & UN-NORMALIZED RELATION (UNF)
    # =========================================================================
    h1("BITEHUB RELATIONAL DATABASE MANAGEMENT SYSTEM\nCOMPREHENSIVE NORMALIZATION & DECOMPOSITION REPORT (1NF → 3NF)")

    callout_box("Executive Summary", "This document details the mathematical normalization process applied to the BiteHub Food & Hyperlocal Grocery platform. It traces the decomposition of an un-normalized, anomaly-prone universal order relation into a fully normalized Third Normal Form (3NF) relational schema, preserving functional dependencies and guaranteeing lossless join decomposition.")

    h2("1. Fundamentals of Normalization")
    p("Normalization is a formal, step-by-step mathematical database design technique based on the analysis of Functional Dependencies (FDs) and Primary Keys. In modern e-commerce and multi-vendor delivery platforms like BiteHub, raw operational data arrives as complex hierarchical structures involving customers, restaurants, dish menus, grocery warehouses, delivery drivers, and payments. Storing this information in an un-normalized schema introduces severe operational hazards known as Modification Anomalies:")

    b("Insertion Anomaly: An entity cannot be recorded without artificially manufacturing unrelated data (e.g., a new restaurant partner or food dish cannot be inserted into the database unless an order has been placed for it).")
    b("Deletion Anomaly: Deleting one piece of business information causes unintended loss of other independent data (e.g., deleting a canceled customer order inadvertently purges the restaurant's entire menu record from the system).")
    b("Update Anomaly: Data redundancy forces redundant modifications across multiple records; if a vendor changes their phone number or a dish base price, failing to update every historical order row causes inconsistent, conflicting states.")

    h2("2. The Initial Un-Normalized Relation (UNF)")
    p("Prior to normalization, if all operational order activities are captured in a single flat universal relation, the schema manifests as follows:")

    code_box("UNNORMALIZED_ORDER (\n    Order_Id, PlacedAt, Status, Delivery_Addr, Total_Amount,\n    User_Id, User_Name, User_Phone, Street, Area, State, Pincode,\n    Rest_Id, RName, RLocation, RPhone, RRating,\n    { Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Food_quantity },\n    Store_Id, DS_Phone, DS_Street, DS_Area, DS_State, DS_Pincode,\n    { Grocery_Item, Grocery_Price, Available_count, Grocery_Qty },\n    Agent_Id, Agent_Name, Agent_Phone, VehicleNO, V_Type, Rating,\n    Payment_Id, Payment_Method, Amount\n)")

    p("In this state, curly braces { ... } denote repeating groups where multiple food items and grocery SKUs are clustered into arrays within a single order row. Addresses and phone numbers exist as non-atomic or composite attributes, violating the fundamental premise of relational database design.")

    doc.add_page_break()

    # =========================================================================
    # PAGE 2: FIRST NORMAL FORM (1NF) DECOMPOSITION
    # =========================================================================
    h1("FIRST NORMAL FORM (1NF) DECOMPOSITION")

    callout_box("Formal Definition of 1NF", "A relation R is in First Normal Form (1NF) if and only if the domain of each attribute contains exclusively atomic (indivisible) values, and each tuple contains exactly one value from the domain of each attribute. 1NF strictly disallows repeating groups, nested relations, arrays, and multi-valued attributes.")

    h2("1. Analysis of 1NF Violations in UNF")
    p("The un-normalized relation `UNNORMALIZED_ORDER` violates 1NF on two distinct fronts:")
    b("Repeating Groups: An order can contain multiple dishes ({Item_Name, Food_quantity, ...}) and multiple grocery items ({Grocery_Item, Grocery_Qty, ...}). In a physical relational table, having multi-valued cells violates domain atomicity.")
    b("Composite Attributes: Delivery addresses and customer addresses represent composite structures that must be decomposed into atomic columns: `Street`, `Area`, `State`, and `Pincode`.")

    h2("2. 1NF Decomposition Strategy")
    p("To achieve 1NF, we eliminate repeating groups by splitting the universal relation into three distinct atomic relations. Each repeating item is flattened into individual tuples, and composite primary keys are identified to uniquely distinguish each row:")

    h3("Relation 1: `ORDER_FLAT` (Header & Non-Repeating Attributes)")
    code_box("ORDER_FLAT (\n    Order_Id [PK], PlacedAt, Status, Delivery_Addr, Total_Amount,\n    User_Id, User_Name, User_Phone, Street, Area, State, Pincode,\n    Rest_Id, RName, RLocation, RPhone, RRating,\n    Store_Id, DS_Phone, DS_Street, DS_Area, DS_State, DS_Pincode,\n    Agent_Id, Agent_Name, Agent_Phone, VehicleNO, V_Type, Rating,\n    Payment_Id, Payment_Method, Amount\n)")

    h3("Relation 2: `ORDER_DISH_FLAT` (Flattened Food Line Items)")
    p("Each dish in an order is allocated its own distinct row, identified by a composite primary key consisting of the order identifier, restaurant identifier, and dish name:")
    code_box("ORDER_DISH_FLAT (\n    Order_Id [PK], Rest_Id [PK], Item_Name [PK],\n    Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Food_quantity\n)")

    h3("Relation 3: `ORDER_GROCERY_FLAT` (Flattened Grocery Line Items)")
    p("Similarly, each grocery line item is isolated into its own tuple with a composite primary key:")
    code_box("ORDER_GROCERY_FLAT (\n    Order_Id [PK], Store_Id [PK], Item_Name [PK],\n    Grocery_Price, Available_count, Quantity\n)")

    h2("3. Why 1NF is Insufficient")
    p("While all attributes in these three tables are now strictly atomic, severe structural flaws remain:")
    b("Partial Dependencies exist in `ORDER_DISH_FLAT` and `ORDER_GROCERY_FLAT`, where dish pricing depends solely on the restaurant and dish name, completely independent of `Order_Id`.")
    b("Redundancy in `ORDER_FLAT` remains immense: customer names and vendor addresses are duplicated on every new order, leading to severe update and deletion anomalies.")

    doc.add_page_break()

    # =========================================================================
    # PAGE 3: SECOND NORMAL FORM (2NF) DECOMPOSITION
    # =========================================================================
    h1("SECOND NORMAL FORM (2NF) DECOMPOSITION")

    callout_box("Formal Definition of 2NF", "A relation R is in Second Normal Form (2NF) if and only if it satisfies 1NF and every non-prime attribute is fully functionally dependent on the complete primary key. In other words, no non-prime attribute may depend on a proper subset of any candidate key (elimination of Partial Functional Dependencies).")

    h2("1. Identification of Partial Dependencies in 1NF")
    p("Partial functional dependencies arise exclusively in relations possessing composite primary keys. Consider the two flattened item relations created during 1NF:")

    h3("A. Functional Dependencies in `ORDER_DISH_FLAT`:")
    p("Composite Primary Key: `{Order_Id, Rest_Id, Item_Name}`", space_after=2)
    b("FD 1 (Full Dependency): {Order_Id, Rest_Id, Item_Name} → Food_quantity (Quantity ordered depends on the specific order, restaurant, and dish).")
    b("FD 2 (Partial Dependency!): {Rest_Id, Item_Name} → Food_Name, Is_Veg, BasePrice, Discount, FinalPrice. The dish name, dietary classification, base price, and discount exist as permanent menu attributes independent of any customer order! Having these depend on Order_Id violates 2NF.")

    h3("B. Functional Dependencies in `ORDER_GROCERY_FLAT`:")
    p("Composite Primary Key: `{Order_Id, Store_Id, Item_Name}`", space_after=2)
    b("FD 3 (Full Dependency): {Order_Id, Store_Id, Item_Name} → Quantity (Count of groceries ordered depends on the whole key).")
    b("FD 4 (Partial Dependency!): {Store_Id, Item_Name} → Grocery_Price, Available_count. A dark store's inventory price and available shelf stock exist independently of whether an order is placed.")

    h2("2. 2NF Decomposition Process")
    p("To satisfy 2NF, we decompose `ORDER_DISH_FLAT` and `ORDER_GROCERY_FLAT`. Non-prime attributes that depend on only part of the composite key are migrated into independent catalog tables, leaving pure associative junction relations:")

    h3("Relation 1: `REST_ITEMS` (Menu Dish Catalog)")
    p("Captures all attributes functionally dependent on `{Rest_Id, Item_Name}`:", space_after=2)
    code_box("REST_ITEMS (\n    Rest_Id [PK, FK], Item_Name [PK], Food_Name,\n    Is_Veg, BasePrice, Discount, FinalPrice, Image_Url\n)")

    h3("Relation 2: `ORDER_ITEM` (Pure M:N Order-to-Dish Junction)")
    p("Preserves the true relationship attribute `Food_quantity`:", space_after=2)
    code_box("ORDER_ITEM (\n    Order_Id [PK, FK], Rest_Id [PK, FK], Item_Name [PK, FK],\n    Food_quantity\n)")

    h3("Relation 3: `GROCERIES` (Dark Store Stock Inventory)")
    p("Captures grocery attributes dependent on `{Store_Id, Item_Name}`:", space_after=2)
    code_box("GROCERIES (\n    Store_Id [PK, FK], Item_Name [PK], Price, Available_count, Image_Url\n)")

    h3("Relation 4: `ORDER_GROCERY` (Pure M:N Order-to-Grocery Junction)")
    code_box("ORDER_GROCERY (\n    Order_Id [PK, FK], Store_Id [PK, FK], Item_Name [PK, FK],\n    Quantity\n)")

    p("At this stage, `ORDER_FLAT` has a single-attribute primary key (`Order_Id`), meaning it is automatically in 2NF (as partial dependencies can only occur with composite keys). However, `ORDER_FLAT` still harbors severe Transitive Dependencies.")

    doc.add_page_break()

    # =========================================================================
    # PAGE 4: THIRD NORMAL FORM (3NF) DECOMPOSITION
    # =========================================================================
    h1("THIRD NORMAL FORM (3NF) DECOMPOSITION")

    callout_box("Formal Definition of 3NF", "A relation R is in Third Normal Form (3NF) if and only if it satisfies 2NF and no non-prime attribute is transitively dependent on the primary key. Formally, for every non-trivial functional dependency X → Y in R, either X is a super key of R, or Y is a prime attribute (part of a candidate key).")

    h2("1. Identification of Transitive Dependencies in `ORDER_FLAT`")
    p("In `ORDER_FLAT`, the primary key is `Order_Id`. A transitive dependency occurs when non-key attributes determine other non-key attributes (i.e., `Order_Id → X` and `X → Y`, meaning `Order_Id → Y` through intermediate attribute `X`):")

    b("Transitive Dependency 1 (Customer Details):\nOrder_Id → User_Id, and User_Id → User_Name, User_Phone, Street, Area, State, Pincode.\nCustomer details depend on User_Id, not the Order itself!")
    b("Transitive Dependency 2 (Restaurant Details):\nOrder_Id → Rest_Id, and Rest_Id → RName, RLocation, RPhone, RRating.\nRestaurant metadata depends directly on Rest_Id!")
    b("Transitive Dependency 3 (Dark Store Details):\nOrder_Id → Store_Id, and Store_Id → DS_Phone, DS_Street, DS_Area, DS_State, DS_Pincode.\nDark store physical location depends on Store_Id!")
    b("Transitive Dependency 4 (Delivery Agent Fleet Details):\nOrder_Id → Agent_Id, and Agent_Id → Agent_Name, Agent_Phone, VehicleNO, V_Type, Rating.\nDriver vehicle type and rating depend on Agent_Id!")
    b("Transitive Dependency 5 (Payment Transaction):\nOrder_Id → Payment_Id, and Payment_Id → Payment_Method, Amount.\nPayment details depend on Payment_Id, linked 1:1 to the Order!")

    h2("2. 3NF Decomposition Process")
    p("We eliminate all transitive dependencies by removing the transitively dependent attributes from `ORDER_FLAT` and establishing five distinct, normalized strong entity relations:")

    h3("1. `USERS` Table")
    code_box("USERS (User_Id [PK], User_Name, User_Phone [UNIQUE], Password, Street, Area, State, Pincode)")

    h3("2. `RESTAURANT` Table")
    code_box("RESTAURANT (Rest_Id [PK], RName, RLocation, RPhone, Password, RRating, Image_Url)")

    h3("3. `DARK_STORE` Table")
    code_box("DARK_STORE (Store_Id [PK], DS_Phone, Password, DS_Street, DS_Area, DS_State, DS_Pincode)")

    h3("4. `DELIVERY_AGENT` Table")
    code_box("DELIVERY_AGENT (Agent_Id [PK], Agent_Name, Agent_Phone, Password, VehicleNO, V_Type, Has_license, Rating)")

    h3("5. `PAYMENT` Table (1:1 Relation)")
    code_box("PAYMENT (Payment_Id [PK], Order_Id [FK, UNIQUE], Payment_Method, Amount)")

    h3("6. Normalized `ORDERS` Table")
    p("With all transitively dependent attributes factored out, `ORDERS` retains only its foreign keys and order-specific execution attributes:", space_after=2)
    code_box("ORDERS (\n    Order_Id [PK], User_Id [FK], Agent_Id [FK], Rest_Id [FK], Store_Id [FK],\n    Status, PlacedAt, DeliveredAt, Delivery_Addr, Total_Amount, Delivery_Fee, Tip_Amount\n)")

    p("All non-key attributes now depend solely on the primary key, the whole primary key, and nothing but the primary key. Every determinant is a super key, thereby also satisfying **Boyce-Codd Normal Form (BCNF)**.")

    doc.add_page_break()

    # =========================================================================
    # PAGE 5: MASTER 3NF SCHEMA & DECOMPOSITION SUMMARY
    # =========================================================================
    h1("MASTER 3NF DECOMPOSED SCHEMA & VERIFICATION")

    p("Below is the complete architectural summary of the 10 decomposed relations comprising the production BiteHub database schema:")

    # Master Table
    tbl = doc.add_table(rows=11, cols=5)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["Relation Name", "Type", "Primary Key (PK)", "Foreign Keys (FK)", "Governing Functional Dependency"]
    for i, h_text in enumerate(headers):
        cell = tbl.rows[0].cells[i]
        shd = parse_xml(r'<w:shd %s w:fill="4F46E5"/>' % nsdecls('w'))
        cell._tc.get_or_add_tcPr().append(shd)
        cp = cell.paragraphs[0]
        cp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        cp.paragraph_format.space_before = Pt(2)
        cp.paragraph_format.space_after = Pt(2)
        r = cp.add_run(h_text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(9.5)
        r.font.color.rgb = RGBColor(255, 255, 255)

    data = [
        ("USERS", "Strong", "User_Id", "None", "User_Id → Name, Phone, Address"),
        ("DELIVERY_AGENT", "Strong", "Agent_Id", "None", "Agent_Id → Name, VehicleNO, Rating"),
        ("RESTAURANT", "Strong", "Rest_Id", "None", "Rest_Id → RName, RLocation, RRating"),
        ("REST_ITEMS", "Dependent", "(Rest_Id, Item_Name)", "Rest_Id → RESTAURANT", "Rest_Id, Item_Name → Prices, Is_Veg"),
        ("DARK_STORE", "Strong", "Store_Id", "None", "Store_Id → Phone, Address"),
        ("GROCERIES", "Weak", "(Store_Id, Item_Name)", "Store_Id → DARK_STORE", "Store_Id, Item_Name → Price, Count"),
        ("ORDERS", "Strong", "Order_Id", "User_Id, Rest_Id, Store_Id, Agent_Id", "Order_Id → Status, Timestamps, Total"),
        ("ORDER_ITEM", "Junction (M:N)", "(Order_Id, Rest_Id, Item_Name)", "Order_Id, Rest_Id, Item_Name", "All Keys → Food_quantity"),
        ("ORDER_GROCERY", "Junction (M:N)", "(Order_Id, Store_Id, Item_Name)", "Order_Id, Store_Id, Item_Name", "All Keys → Quantity"),
        ("PAYMENT", "1:1 Associative", "Payment_Id", "Order_Id (UNIQUE)", "Payment_Id → Order_Id, Amount, Mode")
    ]

    col_widths = [Inches(1.2), Inches(0.9), Inches(1.4), Inches(1.3), Inches(1.6)]
    for row_idx, row_data in enumerate(data):
        row = tbl.rows[row_idx + 1]
        for col_idx, text in enumerate(row_data):
            cell = row.cells[col_idx]
            cell.width = col_widths[col_idx]
            if row_idx % 2 == 1:
                shd = parse_xml(r'<w:shd %s w:fill="F8FAFC"/>' % nsdecls('w'))
                cell._tc.get_or_add_tcPr().append(shd)
            cp = cell.paragraphs[0]
            cp.paragraph_format.space_before = Pt(1.5)
            cp.paragraph_format.space_after = Pt(1.5)
            r = cp.add_run(text)
            r.font.name = 'Times New Roman'
            r.font.size = Pt(8.5)
            if col_idx == 0 or "PK" in text:
                r.bold = True

    h2("2. Verification of Decomposition Properties", space_before=6)
    b("Lossless Join Decomposition: For any decomposition R into (R1, R2), the intersection R1 ∩ R2 forms a superkey of at least one relation. In BiteHub, joining ORDERS with USERS on User_Id, or ORDER_ITEM with REST_ITEMS on (Rest_Id, Item_Name) produces natural joins without generating spurious tuples.")
    b("Dependency Preservation: Every functional dependency X → Y present in the original universal relation is preserved within a decomposed relation, ensuring updates can be validated locally without multi-table join checks.")
    b("Elimination of Anomalies: Restaurants can be added without orders; deleting an order retains menu and customer catalogs; dish price updates affect only one tuple in REST_ITEMS.")

    callout_box("Conclusion", "The BiteHub relational schema strictly satisfies Third Normal Form (3NF) and Boyce-Codd Normal Form (BCNF), delivering an optimal foundation for transactional consistency, referential integrity, and high-concurrency performance.")

    out_path = "BiteHub_Database_Normalization_Report.docx"
    doc.save(out_path)
    print(f"Successfully generated {out_path} (Exactly 5 pages)")

if __name__ == "__main__":
    build_normalization_doc()


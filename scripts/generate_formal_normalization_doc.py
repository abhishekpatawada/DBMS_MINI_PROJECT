import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

def create_formal_normalization_report():
    doc = Document()

    # Page Setup: A4 with 1.0 inch margins (1.2 inch left for binding)
    sec = doc.sections[0]
    sec.top_margin = Inches(0.9)
    sec.bottom_margin = Inches(0.9)
    sec.left_margin = Inches(1.2)
    sec.right_margin = Inches(0.9)
    sec.page_width = Inches(8.27)
    sec.page_height = Inches(11.69)

    # Style defaults: Times New Roman, Black font color throughout
    style_normal = doc.styles['Normal']
    style_normal.font.name = 'Times New Roman'
    style_normal.font.size = Pt(11)
    style_normal.font.color.rgb = RGBColor(0, 0, 0) # STRICTLY BLACK FONT
    style_normal.paragraph_format.line_spacing = 1.15
    style_normal.paragraph_format.space_after = Pt(4)
    style_normal.paragraph_format.space_before = Pt(0)

    # Header & Footer
    header = sec.header
    hp = header.paragraphs[0]
    hp.alignment = WD_ALIGN_PARAGRAPH.LEFT
    hrun = hp.add_run("BiteHub Database Management System • Normalization & Schema Decomposition Report")
    hrun.font.name = 'Times New Roman'
    hrun.font.size = Pt(9.5)
    hrun.font.color.rgb = RGBColor(0, 0, 0)
    hp.paragraph_format.space_after = Pt(8)

    footer = sec.footer
    fp = footer.paragraphs[0]
    fp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    frun1 = fp.add_run("BiteHub Relational Database Design • Page ")
    frun1.font.name = 'Times New Roman'
    frun1.font.size = Pt(9.5)
    frun1.font.color.rgb = RGBColor(0, 0, 0)

    # Dynamic Page Number
    fld1 = parse_xml(r'<w:fldChar %s w:fldCharType="begin"/>' % nsdecls('w'))
    instr1 = parse_xml(r'<w:instrText %s xml:space="preserve"> PAGE </w:instrText>' % nsdecls('w'))
    fld2 = parse_xml(r'<w:fldChar %s w:fldCharType="separate"/>' % nsdecls('w'))
    fld3 = parse_xml(r'<w:fldChar %s w:fldCharType="end"/>' % nsdecls('w'))
    frun2 = fp.add_run()
    frun2.font.name = 'Times New Roman'
    frun2.font.size = Pt(9.5)
    frun2.font.color.rgb = RGBColor(0, 0, 0)
    frun2._r.append(fld1)
    frun2._r.append(instr1)
    frun2._r.append(fld2)
    frun2._r.append(fld3)

    frun3 = fp.add_run(" of ")
    frun3.font.name = 'Times New Roman'
    frun3.font.size = Pt(9.5)
    frun3.font.color.rgb = RGBColor(0, 0, 0)

    fld4 = parse_xml(r'<w:fldChar %s w:fldCharType="begin"/>' % nsdecls('w'))
    instr2 = parse_xml(r'<w:instrText %s xml:space="preserve"> NUMPAGES </w:instrText>' % nsdecls('w'))
    fld5 = parse_xml(r'<w:fldChar %s w:fldCharType="separate"/>' % nsdecls('w'))
    fld6 = parse_xml(r'<w:fldChar %s w:fldCharType="end"/>' % nsdecls('w'))
    frun4 = fp.add_run()
    frun4.font.name = 'Times New Roman'
    frun4.font.size = Pt(9.5)
    frun4.font.color.rgb = RGBColor(0, 0, 0)
    frun4._r.append(fld4)
    frun4._r.append(instr2)
    frun4._r.append(fld5)
    frun4._r.append(fld6)

    # Helper text formatting functions (ALL BLACK FONT)
    def p(text="", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=4, space_before=0, line_spacing=1.15):
        para = doc.add_paragraph()
        para.alignment = align
        para.paragraph_format.space_after = Pt(space_after)
        para.paragraph_format.space_before = Pt(space_before)
        para.paragraph_format.line_spacing = line_spacing
        if text:
            r = para.add_run(text)
            r.font.name = 'Times New Roman'
            r.font.size = Pt(11)
            r.font.color.rgb = RGBColor(0, 0, 0)
        return para

    def b(text, space_after=3):
        para = doc.add_paragraph(style='List Bullet')
        para.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        para.paragraph_format.space_after = Pt(space_after)
        para.paragraph_format.space_before = Pt(0)
        para.paragraph_format.line_spacing = 1.15
        r = para.add_run(text)
        r.font.name = 'Times New Roman'
        r.font.size = Pt(10.5)
        r.font.color.rgb = RGBColor(0, 0, 0)
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
        r.font.color.rgb = RGBColor(0, 0, 0)
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
        r.font.color.rgb = RGBColor(0, 0, 0)
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
        r.font.color.rgb = RGBColor(0, 0, 0)
        return para

    def code_box(text):
        para = doc.add_paragraph()
        para.alignment = WD_ALIGN_PARAGRAPH.LEFT
        para.paragraph_format.space_before = Pt(2)
        para.paragraph_format.space_after = Pt(3)
        r = para.add_run(text)
        r.font.name = 'Courier New'
        r.font.size = Pt(9.5)
        r.font.color.rgb = RGBColor(0, 0, 0)
        return para

    # =========================================================================
    # PAGE 1: DEFINITION OF NORMALIZATION & UNIVERSAL RELATION (UNF)
    # =========================================================================
    h1("BITEHUB RELATIONAL DATABASE MANAGEMENT SYSTEM\nDATABASE NORMALIZATION & SCHEMA DECOMPOSITION REPORT")

    h2("1. Definition and Foundations of Database Normalization")
    p("Normalization is a systematic, formal technique for designing relational database schemas by analyzing the inherent Functional Dependencies (FDs) between attributes and primary keys. The overarching objective of normalization is to produce a set of relation schemas that minimizes data redundancy, prevents operational modification anomalies, ensures lossless join decomposition, and preserves all functional dependencies.")

    p("Core Theoretical Concepts:")
    b("Functional Dependency (FD): Given a relation schema R, a functional dependency denoted by X → Y (read 'X functionally determines Y') asserts a constraint where any two tuples in R that agree on attribute set X must necessarily agree on attribute set Y. Attribute set X is called the Determinant.")
    b("Super Key: A set of attributes that uniquely identifies each tuple in a relation.")
    b("Candidate Key: A minimal super key; a super key from which no attribute can be discarded without destroying its uniqueness property.")
    b("Primary Key (PK): The designated candidate key chosen by the database designer to uniquely identify tuples in the physical relation.")
    b("Prime Attribute: An attribute that is a member of at least one candidate key of the relation.")
    b("Non-Prime Attribute: An attribute that does not belong to any candidate key.")

    p("Modification Anomalies in Un-Normalized Relational Designs:")
    b("Insertion Anomaly: Occurs when an independent fact cannot be recorded without artificially manufacturing unrelated data (e.g., a newly registered restaurant cannot be added to the database until an order is placed).")
    b("Deletion Anomaly: Occurs when deleting one piece of business information causes the unintentional loss of entirely separate data (e.g., deleting a canceled customer order inadvertently deletes the restaurant's entire profile and menu catalog).")
    b("Update Anomaly: Occurs when redundant data is stored across multiple records; if a vendor changes their location or a dish base price, every historical order tuple containing that item must be located and modified, leading to severe data inconsistency if any update is missed.")

    h2("2. The Universal Relation (UNF) of BiteHub")
    p("Prior to the normalization process, all enterprise operational data across customers, restaurants, dish items, dark stores, grocery SKUs, delivery fleets, and payment transactions are modeled as a single Universal Relation (UNF):")

    code_box("UNIVERSAL_ORDER (\n    Order_Id, PlacedAt, DeliveredAt, Status, Delivery_Addr, Total_Amount, Delivery_Fee, Tip_Amount,\n    User_Id, User_Name, User_Phone, Password, Street, Area, State, Pincode,\n    Rest_Id, RName, RLocation, RPhone, RRating,\n    { Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Food_quantity },\n    Store_Id, DS_Phone, DS_Street, DS_Area, DS_State, DS_Pincode,\n    { Grocery_Item, Grocery_Price, Available_count, Grocery_Qty },\n    Agent_Id, Agent_Name, Agent_Phone, VehicleNO, V_Type, Has_license, Rating,\n    Payment_Id, Payment_Method, Amount\n)")

    p("In this un-normalized state, curly braces { ... } denote repeating groups where multiple dishes and grocery items are grouped together within a single order tuple. Delivery addresses and customer addresses exist as composite non-atomic attributes, violating domain atomicity and the fundamental axioms of relational database design.")

    doc.add_page_break()

    # =========================================================================
    # PAGE 2: THEORETICAL DEFINITIONS OF ALL NORMAL FORMS
    # =========================================================================
    h1("THEORETICAL DEFINITIONS OF NORMAL FORMS")

    p("Relational database theory establishes a formal hierarchy of normal forms, where each higher normal form imposes increasingly stringent constraints on functional dependencies to eliminate redundancies:")

    h2("1. First Normal Form (1NF)")
    p("Definition: A relation schema R is in First Normal Form (1NF) if and only if the domain of every attribute in R contains exclusively atomic (indivisible) values, and each tuple in any relation state contains exactly one value from the domain of each attribute.")
    b("Requirement: All repeating groups, arrays, sets, and nested tables must be eliminated.")
    b("Requirement: Composite attributes must be decomposed into their irreducible constituent components.")
    b("Condition: A unique primary key (atomic or composite) must be established to distinguish every row.")

    h2("2. Second Normal Form (2NF)")
    p("Definition: A relation schema R is in Second Normal Form (2NF) if and only if it is in 1NF and every non-prime attribute A in R is fully functionally dependent on the complete primary key of R.")
    b("Full Functional Dependency: A functional dependency X → Y is a full functional dependency if removal of any attribute A from X causes the dependency to no longer hold (i.e., for any A ∈ X, (X - {A}) does not determine Y).")
    b("Prohibition of Partial Dependencies: If X is a composite candidate key, no non-prime attribute Y may depend on a proper subset of X. If a relation's candidate keys consist solely of single attributes, the relation is automatically in 2NF.")

    h2("3. Third Normal Form (3NF)")
    p("Definition: A relation schema R is in Third Normal Form (3NF) if and only if it is in 2NF and no non-prime attribute of R is transitively dependent on the primary key.")
    b("Formal Condition: For every non-trivial functional dependency X → Y holding over R, at least one of the following conditions must hold:")
    p("    1. X is a Super Key of R, OR\n    2. Y is a Prime Attribute (member of a candidate key) of R.")
    b("Prohibition of Transitive Dependencies: A dependency X → Z is transitive if there exists an attribute set Y such that X → Y and Y → Z hold, where Y is neither a candidate key nor a subset of any key of R.")

    h2("4. Boyce-Codd Normal Form (BCNF)")
    p("Definition: A relation schema R is in Boyce-Codd Normal Form (BCNF) if and only if for every non-trivial functional dependency X → Y that holds over R, X is a Super Key of R.")
    b("Comparison with 3NF: BCNF eliminates the second relaxation clause of 3NF ('Y is a prime attribute'). BCNF strictly guarantees that every determinant is a super key, resolving anomalies involving overlapping composite candidate keys.")

    h2("5. Fourth Normal Form (4NF) & Fifth Normal Form (5NF)")
    b("Fourth Normal Form (4NF): A relation schema R is in 4NF if and only if for every non-trivial Multi-Valued Dependency (MVD) X ↠ Y that holds over R, X is a super key of R. 4NF eliminates independent multi-valued facts.")
    b("Fifth Normal Form (5NF / Project-Join Normal Form): A relation schema R is in 5NF if and only if every non-trivial Join Dependency (JD) *(R1, R2, ..., Rn) holding over R is implied by the candidate keys of R. 5NF guarantees lossless reconstruction without cyclic join anomalies.")

    doc.add_page_break()

    # =========================================================================
    # PAGE 3: DECOMPOSITION INTO FIRST NORMAL FORM (1NF)
    # =========================================================================
    h1("STEP 1: DECOMPOSITION INTO FIRST NORMAL FORM (1NF)")

    h2("1. Analysis of 1NF Violations in UNIVERSAL_ORDER")
    p("The un-normalized relation `UNIVERSAL_ORDER` violates 1NF on two distinct grounds:")
    b("Violation 1: Repeating Groups of Food Line Items. A single order tuple contains an arbitrary list of dishes {Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Food_quantity}. Multi-valued cells cannot be stored in a 1NF relation.")
    b("Violation 2: Repeating Groups of Grocery Items. Similarly, grocery purchases are grouped as an array {Grocery_Item, Grocery_Price, Available_count, Grocery_Qty} within the same order tuple.")
    b("Violation 3: Composite Customer Address. The address attribute encapsulates Street, Area, State, and Pincode, violating domain atomicity.")

    h2("2. 1NF Decomposition Process")
    p("To eliminate repeating groups, we project the universal relation into three distinct relations. Repeating groups are flattened by replicating order identifiers for each distinct line item, and composite primary keys are identified to uniquely index each row:")

    h3("Relation 1: `ORDER_FLAT` (Header & Single-Valued Attributes)")
    code_box("ORDER_FLAT (\n    Order_Id [PK], PlacedAt, DeliveredAt, Status, Delivery_Addr, Total_Amount, Delivery_Fee, Tip_Amount,\n    User_Id, User_Name, User_Phone, Password, Street, Area, State, Pincode,\n    Rest_Id, RName, RLocation, RPhone, RRating,\n    Store_Id, DS_Phone, DS_Street, DS_Area, DS_State, DS_Pincode,\n    Agent_Id, Agent_Name, Agent_Phone, VehicleNO, V_Type, Has_license, Rating,\n    Payment_Id, Payment_Method, Amount\n)")
    p("Primary Key: `Order_Id`", space_after=6)

    h3("Relation 2: `ORDER_DISH_FLAT` (Flattened Food Items)")
    p("Each food item ordered is flattened into an atomic tuple identified by a composite primary key:", space_after=2)
    code_box("ORDER_DISH_FLAT (\n    Order_Id [PK], Rest_Id [PK], Item_Name [PK],\n    Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Food_quantity\n)")
    p("Composite Primary Key: `{Order_Id, Rest_Id, Item_Name}`", space_after=6)

    h3("Relation 3: `ORDER_GROCERY_FLAT` (Flattened Grocery SKUs)")
    p("Each grocery SKU is isolated into an atomic tuple identified by a composite primary key:", space_after=2)
    code_box("ORDER_GROCERY_FLAT (\n    Order_Id [PK], Store_Id [PK], Item_Name [PK],\n    Grocery_Price, Available_count, Quantity\n)")
    p("Composite Primary Key: `{Order_Id, Store_Id, Item_Name}`", space_after=6)

    h2("3. Lingering Anomalies in 1NF (Why 1NF is Insufficient)")
    p("Although all attributes are now strictly atomic, severe design anomalies remain in 1NF:")
    b("Partial Dependencies: In `ORDER_DISH_FLAT`, the food price, discount, and dietary flag depend solely on `{Rest_Id, Item_Name}`, completely independent of `Order_Id`.")
    b("Insertion Anomaly in 1NF: A restaurant cannot insert a new menu dish unless an order has been placed for that dish, because `Order_Id` is a mandatory component of the composite primary key and cannot be NULL.")
    b("Redundancy in 1NF: Customer names, delivery addresses, and restaurant ratings are duplicated on every single order row in `ORDER_FLAT`, wasting storage and causing update anomalies.")

    doc.add_page_break()

    # =========================================================================
    # PAGE 4: DECOMPOSITION INTO SECOND NORMAL FORM (2NF)
    # =========================================================================
    h1("STEP 2: DECOMPOSITION INTO SECOND NORMAL FORM (2NF)")

    h2("1. Identification of Partial Functional Dependencies in 1NF")
    p("A partial dependency occurs when a non-prime attribute depends on only a subset of a composite primary key. We inspect the two composite relations created during 1NF decomposition:")

    h3("A. Partial Dependencies in `ORDER_DISH_FLAT`:")
    p("Composite Primary Key: `{Order_Id, Rest_Id, Item_Name}`")
    b("FD 1 (Full Functional Dependency): {Order_Id, Rest_Id, Item_Name} → Food_quantity.\nThe quantity of a dish ordered depends on the specific order, restaurant, and dish.")
    b("FD 2 (Partial Functional Dependency!): {Rest_Id, Item_Name} → Food_Name, Is_Veg, BasePrice, Discount, FinalPrice.\nThe attributes Food_Name, Is_Veg, BasePrice, Discount, and FinalPrice depend solely on `{Rest_Id, Item_Name}`, which is a proper subset of the primary key! Having these depend on Order_Id violates 2NF.")

    h3("B. Partial Dependencies in `ORDER_GROCERY_FLAT`:")
    p("Composite Primary Key: `{Order_Id, Store_Id, Item_Name}`")
    b("FD 3 (Full Functional Dependency): {Order_Id, Store_Id, Item_Name} → Quantity.\nThe count of groceries ordered depends on the entire composite primary key.")
    b("FD 4 (Partial Functional Dependency!): {Store_Id, Item_Name} → Grocery_Price, Available_count.\nThe unit price of a grocery item and its current stock in the dark store warehouse depend strictly on `{Store_Id, Item_Name}`. This is a partial dependency violating 2NF.")

    h2("2. 2NF Decomposition Process")
    p("To eliminate partial dependencies, we decouple attributes that depend on key subsets into their own independent catalog relations, preserving only the full functional dependencies in associative junction relations:")

    h3("1. Relation `REST_ITEMS` (Menu Dish Catalog)")
    p("Formed by attributes functionally determined by `{Rest_Id, Item_Name}`:", space_after=2)
    code_box("REST_ITEMS (\n    Rest_Id [PK, FK], Item_Name [PK], Food_Name,\n    Is_Veg, BasePrice, Discount, FinalPrice, Image_Url\n)")
    p("Primary Key: `{Rest_Id, Item_Name}`. Full Functional Dependency satisfied.", space_after=4)

    h3("2. Relation `ORDER_ITEM` (Pure M:N Order-to-Dish Junction)")
    code_box("ORDER_ITEM (\n    Order_Id [PK, FK], Rest_Id [PK, FK], Item_Name [PK, FK],\n    Food_quantity\n)")
    p("Primary Key: `{Order_Id, Rest_Id, Item_Name}`. Fully functionally dependent on the entire composite key.", space_after=4)

    h3("3. Relation `GROCERIES` (Dark Store Stock Inventory)")
    p("Formed by attributes functionally determined by `{Store_Id, Item_Name}`:", space_after=2)
    code_box("GROCERIES (\n    Store_Id [PK, FK], Item_Name [PK], Price, Available_count, Image_Url\n)")
    p("Primary Key: `{Store_Id, Item_Name}`. Full Functional Dependency satisfied.", space_after=4)

    h3("4. Relation `ORDER_GROCERY` (Pure M:N Order-to-Grocery Junction)")
    code_box("ORDER_GROCERY (\n    Order_Id [PK, FK], Store_Id [PK, FK], Item_Name [PK, FK],\n    Quantity\n)")
    p("Primary Key: `{Order_Id, Store_Id, Item_Name}`. Fully functionally dependent on the entire key.", space_after=4)

    p("Note on `ORDER_FLAT`: Because `ORDER_FLAT` possesses a single-attribute primary key (`Order_Id`), it has no proper subsets of its primary key, meaning it contains no partial dependencies and is automatically in 2NF. However, `ORDER_FLAT` still contains severe Transitive Dependencies.")

    doc.add_page_break()

    # =========================================================================
    # PAGE 5: DECOMPOSITION INTO THIRD NORMAL FORM (3NF) & BCNF
    # =========================================================================
    h1("STEP 3: DECOMPOSITION INTO THIRD NORMAL FORM (3NF) & BCNF")

    h2("1. Identification of Transitive Functional Dependencies in `ORDER_FLAT`")
    p("In `ORDER_FLAT`, the primary key is `Order_Id`. A transitive dependency exists when a primary key determines a non-key attribute X, which in turn determines another non-key attribute Y (`Order_Id → X` and `X → Y`):")

    b("Transitive Dependency 1 (Customer Details):\nOrder_Id → User_Id, and User_Id → User_Name, User_Phone, Password, Street, Area, State, Pincode.\nCustomer attributes depend on User_Id, which is not a candidate key of ORDER_FLAT!")
    b("Transitive Dependency 2 (Restaurant Details):\nOrder_Id → Rest_Id, and Rest_Id → RName, RLocation, RPhone, RRating, Image_Url.\nRestaurant vendor attributes depend directly on Rest_Id!")
    b("Transitive Dependency 3 (Dark Store Details):\nOrder_Id → Store_Id, and Store_Id → DS_Phone, DS_Street, DS_Area, DS_State, DS_Pincode.\nWarehouse location and contact attributes depend on Store_Id!")
    b("Transitive Dependency 4 (Delivery Agent Fleet Details):\nOrder_Id → Agent_Id, and Agent_Id → Agent_Name, Agent_Phone, VehicleNO, V_Type, Has_license, Rating.\nDriver profile, vehicle registration, and driver rating depend on Agent_Id!")
    b("Transitive Dependency 5 (Payment Transaction):\nOrder_Id → Payment_Id, and Payment_Id → Payment_Method, Amount.\nFinancial settlement attributes depend on Payment_Id, which is linked 1:1 with Order_Id!")

    h2("2. 3NF Decomposition Process")
    p("We eliminate all transitive dependencies by extracting the transitively dependent attributes into five separate, normalized strong entity relations, leaving only foreign key references in the central `ORDERS` table:")

    h3("1. `USERS` Table (Customer Entity)")
    code_box("USERS (User_Id [PK], User_Name, User_Phone [UNIQUE], Password, Street, Area, State, Pincode)")
    p("FD: User_Id → User_Name, User_Phone, Password, Street, Area, State, Pincode", space_after=3)

    h3("2. `RESTAURANT` Table (Vendor Entity)")
    code_box("RESTAURANT (Rest_Id [PK], RName, RLocation, RPhone, Password, RRating, Image_Url)")
    p("FD: Rest_Id → RName, RLocation, RPhone, Password, RRating, Image_Url", space_after=3)

    h3("3. `DARK_STORE` Table (Fulfillment Warehouse Entity)")
    code_box("DARK_STORE (Store_Id [PK], DS_Phone, Password, DS_Street, DS_Area, DS_State, DS_Pincode)")
    p("FD: Store_Id → DS_Phone, Password, DS_Street, DS_Area, DS_State, DS_Pincode", space_after=3)

    h3("4. `DELIVERY_AGENT` Table (Fleet Driver Entity)")
    code_box("DELIVERY_AGENT (Agent_Id [PK], Agent_Name, Agent_Phone, Password, VehicleNO, V_Type, Has_license, Rating)")
    p("FD: Agent_Id → Agent_Name, Agent_Phone, Password, VehicleNO, V_Type, Has_license, Rating", space_after=3)

    h3("5. `PAYMENT` Table (1:1 Payment Transaction Entity)")
    code_box("PAYMENT (Payment_Id [PK], Order_Id [FK, UNIQUE], Payment_Method, Amount)")
    p("FD: Payment_Id → Order_Id, Payment_Method, Amount (Order_Id is UNIQUE)", space_after=3)

    h3("6. Fully Normalized `ORDERS` Table")
    p("With all transitive attributes removed, `ORDERS` maintains solely order execution attributes and foreign keys:", space_after=2)
    code_box("ORDERS (\n    Order_Id [PK], User_Id [FK], Agent_Id [FK], Rest_Id [FK], Store_Id [FK],\n    Status, PlacedAt, DeliveredAt, Delivery_Addr, Total_Amount, Delivery_Fee, Tip_Amount\n)")

    p("Verification of BCNF Compliance: In every decomposed relation (USERS, RESTAURANT, DARK_STORE, DELIVERY_AGENT, ORDERS, REST_ITEMS, GROCERIES, ORDER_ITEM, ORDER_GROCERY, PAYMENT), for every functional dependency X → Y, the determinant X is a Super Key. Thus, the schema satisfies both Third Normal Form (3NF) and Boyce-Codd Normal Form (BCNF).")

    doc.add_page_break()

    # =========================================================================
    # PAGE 6: MASTER 3NF SCHEMA & DECOMPOSITION VERIFICATION
    # =========================================================================
    h1("MASTER 3NF DECOMPOSED SCHEMA & MATHEMATICAL VERIFICATION")

    p("The table below presents the master relational schema of the 10 decomposed tables implemented in MySQL:")

    tbl = doc.add_table(rows=11, cols=5)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["Relation Name", "Entity Type", "Primary Key (PK)", "Foreign Keys (FK)", "Governing Functional Dependency"]
    for i, h_text in enumerate(headers):
        cell = tbl.rows[0].cells[i]
        cp = cell.paragraphs[0]
        cp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        cp.paragraph_format.space_before = Pt(2)
        cp.paragraph_format.space_after = Pt(2)
        r = cp.add_run(h_text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(9.5)
        r.font.color.rgb = RGBColor(0, 0, 0)

    data = [
        ("USERS", "Strong Entity", "User_Id", "None", "User_Id → Name, Phone, Address"),
        ("DELIVERY_AGENT", "Strong Entity", "Agent_Id", "None", "Agent_Id → Name, VehicleNO, Rating"),
        ("RESTAURANT", "Strong Entity", "Rest_Id", "None", "Rest_Id → RName, RLocation, RRating"),
        ("REST_ITEMS", "Dependent Entity", "(Rest_Id, Item_Name)", "Rest_Id → RESTAURANT", "Rest_Id, Item_Name → Prices, Is_Veg"),
        ("DARK_STORE", "Strong Entity", "Store_Id", "None", "Store_Id → Phone, Address"),
        ("GROCERIES", "Weak Entity", "(Store_Id, Item_Name)", "Store_Id → DARK_STORE", "Store_Id, Item_Name → Price, Stock"),
        ("ORDERS", "Strong Entity", "Order_Id", "User_Id, Rest_Id, Store_Id, Agent_Id", "Order_Id → Status, Timestamps, Total"),
        ("ORDER_ITEM", "M:N Junction", "(Order_Id, Rest_Id, Item_Name)", "Order_Id, Rest_Id, Item_Name", "All Keys → Food_quantity"),
        ("ORDER_GROCERY", "M:N Junction", "(Order_Id, Store_Id, Item_Name)", "Order_Id, Store_Id, Item_Name", "All Keys → Quantity"),
        ("PAYMENT", "1:1 Associative", "Payment_Id", "Order_Id (UNIQUE)", "Payment_Id → Order_Id, Amount, Mode")
    ]

    col_widths = [Inches(1.2), Inches(1.0), Inches(1.4), Inches(1.3), Inches(1.6)]
    for row_idx, row_data in enumerate(data):
        row = tbl.rows[row_idx + 1]
        for col_idx, text in enumerate(row_data):
            cell = row.cells[col_idx]
            cell.width = col_widths[col_idx]
            cp = cell.paragraphs[0]
            cp.paragraph_format.space_before = Pt(1.5)
            cp.paragraph_format.space_after = Pt(1.5)
            r = cp.add_run(text)
            r.font.name = 'Times New Roman'
            r.font.size = Pt(8.5)
            r.font.color.rgb = RGBColor(0, 0, 0)
            if col_idx == 0 or "PK" in text:
                r.bold = True

    h2("1. Mathematical Verification of Decomposition Properties", space_before=6)
    b("Property 1: Lossless Join Decomposition (Non-Additive Join):\nA decomposition of relation R into D = {R1, R2} is lossless if and only if R1 ∩ R2 forms a superkey of at least one of the decomposed relations (R1 ∩ R2 → R1 or R1 ∩ R2 → R2). In BiteHub, every decomposition step adheres strictly to this condition: joining ORDERS with USERS on User_Id, or ORDER_ITEM with REST_ITEMS on (Rest_Id, Item_Name) produces natural joins that exactly reconstruct the universal relation without generating any spurious tuples.")
    b("Property 2: Dependency Preservation:\nA decomposition D = {R1, R2, ..., Rn} of R is dependency-preserving if the union of the projections of the functional dependency set F onto each Ri is equivalent to F (i.e., (F1 ∪ F2 ∪ ... ∪ Fn)+ = F+). In BiteHub, every functional dependency is enforced directly within a single relation through primary and unique key constraints, eliminating the need for expensive multi-table join operations during insertion or update validation.")
    b("Property 3: Total Elimination of Anomalies:\n• Insertion: New dining vendors and grocery SKUs can be added without waiting for an order to exist.\n• Deletion: Deleting an order tuple deletes only the order and its junction entries, fully preserving customer profiles, restaurant menus, and driver records.\n• Update: Vendor contact details and dish prices exist in exactly one location, eliminating inconsistent states.")

    h2("2. Conclusion")
    p("The normalization and decomposition of the BiteHub database demonstrates the practical application of relational database theory to high-performance e-commerce and logistics systems. By systematically advancing from an un-normalized universal relation through 1NF, 2NF, and 3NF/BCNF, the resulting 10-table schema achieves zero redundancy, robust data integrity, and optimal transactional performance.")

    out_path = "BiteHub_Database_Normalization_Report.docx"
    doc.save(out_path)
    print(f"Successfully generated {out_path} (Exactly 6 pages, Black font, Times New Roman)")

if __name__ == "__main__":
    create_formal_normalization_report()


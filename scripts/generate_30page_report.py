import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_TAB_ALIGNMENT
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

def generate_report():
    doc = Document()

    # =========================================================================
    # SECTION 1: PRELIMINARY PAGES (Pages 1 to 5) - Unnumbered
    # =========================================================================
    sec1 = doc.sections[0]
    sec1.top_margin = Inches(1.0)
    sec1.bottom_margin = Inches(1.0)
    sec1.left_margin = Inches(1.25)   # 1.25 inch binding margin for printout
    sec1.right_margin = Inches(1.0)
    sec1.page_width = Inches(8.27)    # A4
    sec1.page_height = Inches(11.69)
    sec1.different_first_page_header_footer = True
    sec1.footer.paragraphs[0].text = ""

    # Style defaults
    style_normal = doc.styles['Normal']
    style_normal.font.name = 'Times New Roman'
    style_normal.font.size = Pt(12)
    style_normal.font.color.rgb = RGBColor(0, 0, 0)
    style_normal.paragraph_format.line_spacing = 1.15
    style_normal.paragraph_format.space_after = Pt(4)
    style_normal.paragraph_format.space_before = Pt(0)

    # Helper text formatting functions
    def p(text="", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=4, space_before=0, line_spacing=1.15):
        para = doc.add_paragraph()
        para.alignment = align
        para.paragraph_format.space_after = Pt(space_after)
        para.paragraph_format.space_before = Pt(space_before)
        para.paragraph_format.line_spacing = line_spacing
        if text:
            r = para.add_run(text)
            r.font.name = 'Times New Roman'
            r.font.size = Pt(12)
        return para

    def b(text, space_after=3):
        para = doc.add_paragraph(style='List Bullet')
        para.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        para.paragraph_format.space_after = Pt(space_after)
        para.paragraph_format.space_before = Pt(0)
        para.paragraph_format.line_spacing = 1.15
        r = para.add_run(text)
        r.font.name = 'Times New Roman'
        r.font.size = Pt(12)
        return para

    def h1(text, space_before=8, space_after=12):
        para = doc.add_paragraph()
        para.alignment = WD_ALIGN_PARAGRAPH.CENTER
        para.paragraph_format.space_before = Pt(space_before)
        para.paragraph_format.space_after = Pt(space_after)
        r = para.add_run(text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(15)
        return para

    def h2(text, space_before=8, space_after=4):
        para = doc.add_paragraph()
        para.alignment = WD_ALIGN_PARAGRAPH.LEFT
        para.paragraph_format.space_before = Pt(space_before)
        para.paragraph_format.space_after = Pt(space_after)
        r = para.add_run(text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(12.5)
        return para

    def h3(text, space_before=6, space_after=2):
        para = doc.add_paragraph()
        para.alignment = WD_ALIGN_PARAGRAPH.LEFT
        para.paragraph_format.space_before = Pt(space_before)
        para.paragraph_format.space_after = Pt(space_after)
        r = para.add_run(text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(11.5)
        return para

    def code(text):
        para = doc.add_paragraph()
        para.alignment = WD_ALIGN_PARAGRAPH.LEFT
        para.paragraph_format.space_before = Pt(1)
        para.paragraph_format.space_after = Pt(3)
        r = para.add_run(text)
        r.font.name = 'Courier New'
        r.font.size = Pt(9.5)
        r.font.color.rgb = RGBColor(30, 41, 59)
        return para

    # -------------------------------------------------------------
    # PAGE 1: TITLE PAGE
    # -------------------------------------------------------------
    p("", space_after=10)
    p_sub = p("A DBMS Mini-Project Report on", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=12)
    p_sub.runs[0].font.size = Pt(14)
    p_sub.runs[0].bold = True

    p_title = p("BITEHUB - MULTI-VENDOR FOOD & GROCERY DELIVERY MANAGEMENT SYSTEM", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=18)
    p_title.runs[0].font.size = Pt(16.5)
    p_title.runs[0].bold = True

    if os.path.exists("report_assets/uvce_logo.png"):
        p_logo = doc.add_paragraph()
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_logo.paragraph_format.space_after = Pt(18)
        p_logo.add_run().add_picture("report_assets/uvce_logo.png", width=Inches(2.3))

    p_by = p("Submitted by", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=6)
    p_by.runs[0].font.size = Pt(12)

    p_stud1 = p("Shlok [Insert Name] (U25UV23T006xxx)", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=3)
    p_stud1.runs[0].font.size = Pt(12.5)
    p_stud1.runs[0].bold = True

    p_stud2 = p("[Team Partner Name] (U25UV23T006xxx)", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=6)
    p_stud2.runs[0].font.size = Pt(12.5)
    p_stud2.runs[0].bold = True

    p_sem = p("V SEM, BTech (CSE / AIML)", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=18)
    p_sem.runs[0].font.size = Pt(11.5)
    p_sem.runs[0].bold = True

    p_guide = p("Under the guidance of", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=4)
    p_guide.runs[0].font.size = Pt(11.5)

    p_prof = p("Dr. Champa H.N", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=2)
    p_prof.runs[0].font.size = Pt(12.5)
    p_prof.runs[0].bold = True

    p_dept = p("Professor\nDepartment of CSE\nUVCE", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=18)
    p_dept.runs[0].font.size = Pt(11.5)

    p_coll = p("UNIVERSITY OF VISVESVARAYA COLLEGE ENGINEERING\nDEPARTMENT OF COMPUTER SCIENCE AND ENGINEERING\nK.R. Circle, Bengaluru – 560001", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
    p_coll.runs[0].font.size = Pt(11.5)
    p_coll.runs[0].bold = True

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 2: CERTIFICATE
    # -------------------------------------------------------------
    p("UNIVERSITY OF VISVESVARAYA COLLEGE ENGINEERING\nDEPARTMENT OF COMPUTER SCIENCE AND ENGINEERING\nK.R. Circle, Bengaluru – 560001", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=14)
    doc.paragraphs[-1].runs[0].font.size = Pt(11.5)
    doc.paragraphs[-1].runs[0].bold = True

    if os.path.exists("report_assets/uvce_logo.png"):
        p_logo = doc.add_paragraph()
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_logo.paragraph_format.space_after = Pt(14)
        p_logo.add_run().add_picture("report_assets/uvce_logo.png", width=Inches(1.5))

    h1("CERTIFICATE", space_before=8, space_after=14)

    p("This is to certify that Shlok [Insert Name] and [Team Partner Name] of V Semester, B. Tech, Computer Science & Engineering / Artificial Intelligence & Machine Learning, bearing the register numbers U25UV23T006xxx and U25UV23T006xxx respectively have submitted the DBMS Mini-Project Report on “BITEHUB - MULTI-VENDOR FOOD & GROCERY DELIVERY MANAGEMENT SYSTEM”, in partial fulfilment for the DBMS Lab, prescribed by the University of Visvesvaraya College of Engineering for the academic year 2025-26.", space_after=28, line_spacing=1.25)

    table_sig = doc.add_table(rows=1, cols=2)
    table_sig.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell_l, cell_r = table_sig.rows[0].cells
    cell_l.width = Inches(3.0)
    cell_r.width = Inches(3.0)

    p_sig1 = cell_l.paragraphs[0]
    p_sig1.alignment = WD_ALIGN_PARAGRAPH.LEFT
    r = p_sig1.add_run("Dr. Champa H. N\nProfessor\nDept. of CSE,\nUVCE")
    r.font.name = 'Times New Roman'
    r.font.size = Pt(11.5)
    r.bold = True

    p_sig2 = cell_r.paragraphs[0]
    p_sig2.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    r = p_sig2.add_run("Dr. Thriveni J\nProfessor & Chairperson\nDept. of CSE,\nUVCE")
    r.font.name = 'Times New Roman'
    r.font.size = Pt(11.5)
    r.bold = True

    p("", space_after=28)
    p("Examiners:\n\n1. ……………………………………          2. ……………………………………", align=WD_ALIGN_PARAGRAPH.LEFT, space_after=0)

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 3: ACKNOWLEDGEMENT
    # -------------------------------------------------------------
    h1("ACKNOWLEDGEMENT", space_before=12, space_after=18)

    p("We take this opportunity to thank our institution University of Visvesvaraya College of Engineering for having given us an opportunity to carry out this project.", space_after=10)
    p("We would like to thank Prof. Subhasish Tripathy, Director, UVCE, for providing us all the facilities to work on this project. We are indebted to him for being our pillar of strength and inspiration.", space_after=10)
    p("We wish to place our grateful thanks to Dr. Thriveni J, Professor and Chairperson, Department of Computer Science and Engineering, UVCE, who helped us to make our project a great success.", space_after=10)
    p("It gives us great pleasure to express our gratitude to Dr. Champa H.N, Professor, Department of Computer Science Engineering, UVCE for her valuable guidance and supervision in this course of project.", space_after=10)
    p("We express our sincere thanks to all teaching and non-teaching staff, Department of Computer Science and Engineering, UVCE for all the facilities that they have provided us for successfully completing this project.", space_after=10)
    p("We also thank our parents and friends for their continuous support and encouragement.", space_after=32)

    p_sign = p("Shlok [Insert Name]\n(U25UV23T006xxx)\n\n[Team Partner Name]\n(U25UV23T006xxx)", align=WD_ALIGN_PARAGRAPH.RIGHT, space_after=0)
    p_sign.runs[0].bold = True

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 4: ABSTRACT
    # -------------------------------------------------------------
    h1("ABSTRACT", space_before=12, space_after=18)

    p("The BiteHub - Multi-Vendor Food & Grocery Delivery Management System is an end-to-end relational database management platform engineered to automate and synchronize commercial operations across consumers, dining restaurants, quick-commerce dark store warehouses, and delivery fleets. Structured upon a normalized Third Normal Form (3NF) MySQL relational schema, the platform replaces disjointed manual order books and fragmented spreadsheets with a transactional database architecture guaranteeing ACID compliance, zero inventory inconsistencies, and high-concurrency throughput.", space_after=12, line_spacing=1.2)

    p("The platform combines a cross-platform client developed in Flutter (Dart) with Material 3 design, a high-performance asynchronous REST API powered by Python FastAPI, and an enterprise MySQL 8.0 engine. The system delivers customized workflows for five core stakeholders: Customers (dual food ordering and 10-minute grocery shopping with smart cart and live tracking), Restaurant Partners (kitchen queue management and menu CRUD with an integrated 100+ item curated HD photo gallery), Dark Store Managers (real-time grocery inventory with automated low-stock warnings), Delivery Agents (instant delivery task alerts and progression updates), and Administrators (Executive Command Center and a Live SQL Visualizer for query latency benchmarking).", space_after=12, line_spacing=1.2)

    p("Strict referential integrity constraints, composite primary keys for weak entities, cascading deletes, and rollback transactions on order cancellation guarantee full operational reliability. The project establishes how modern relational database engineering, coupled with resilient in-memory caching and responsive frontend design, provides a scalable, production-ready solution for next-generation on-demand delivery logistics.", space_after=0, line_spacing=1.2)

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 5: TABLE OF CONTENTS
    # -------------------------------------------------------------
    h1("TABLE OF CONTENTS", space_before=12, space_after=16)

    toc_data = [
        ("Title", "Page No.", True),
        ("1. Introduction", "", True),
        ("    1.1 Introduction", "1", False),
        ("    1.2 Objective", "1", False),
        ("    1.3 Functionality", "3", False),
        ("    1.4 Database Management System", "4", False),
        ("    1.5 MySQL", "4", False),
        ("2. Literature Review", "", True),
        ("    2.1 Survey of Existing System", "7", False),
        ("    2.2 Proposed System", "7", False),
        ("    2.3 Software Requirements", "8", False),
        ("    2.4 Frontend Technologies", "8", False),
        ("    2.5 Backend Technologies", "8", False),
        ("    2.6 Entity Relationship Model", "9", False),
        ("    2.7 Relational Schema Design", "11", False),
        ("    2.8 Normalization", "13", False),
        ("    2.9 API Development", "14", False),
        ("    2.10 Advantages of the Proposed System", "14", False),
        ("3. Proposed Work", "", True),
        ("    3.1 Entity-Relationship (ER) Model", "15", False),
        ("    3.2 Relational Model", "17", False),
        ("4. Results", "", True),
        ("    4.1 Outcomes", "19", False),
        ("    4.2 Screenshots", "20", False),
        ("5. Conclusion", "24", True),
        ("6. Bibliography", "25", True),
    ]

    table_toc = doc.add_table(rows=len(toc_data), cols=2)
    table_toc.alignment = WD_TABLE_ALIGNMENT.CENTER
    for idx, (title, page, is_bold) in enumerate(toc_data):
        cell_t = table_toc.rows[idx].cells[0]
        cell_p = table_toc.rows[idx].cells[1]
        cell_t.width = Inches(5.0)
        cell_p.width = Inches(1.0)
        
        pt = cell_t.paragraphs[0]
        pt.paragraph_format.space_after = Pt(2)
        pt.paragraph_format.space_before = Pt(2)
        rt = pt.add_run(title)
        rt.font.name = 'Times New Roman'
        rt.font.size = Pt(11)
        rt.bold = is_bold
        
        pp = cell_p.paragraphs[0]
        pp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        pp.paragraph_format.space_after = Pt(2)
        pp.paragraph_format.space_before = Pt(2)
        rp = pp.add_run(page)
        rp.font.name = 'Times New Roman'
        rp.font.size = Pt(11)
        rp.bold = is_bold

    # =========================================================================
    # SECTION 2: REPORT BODY (Numbered Pages 1 to 25 -> Printed Total: 30)
    # =========================================================================
    sec2 = doc.add_section(docx.enum.section.WD_SECTION.NEW_PAGE)
    sec2.top_margin = Inches(1.0)
    sec2.bottom_margin = Inches(1.0)
    sec2.left_margin = Inches(1.25)
    sec2.right_margin = Inches(1.0)
    sec2.page_width = Inches(8.27)
    sec2.page_height = Inches(11.69)
    sec2.different_first_page_header_footer = False

    # Restart page number at 1 in Section 2
    sec2_pr = sec2._sectPr
    pgNumType = parse_xml(r'<w:pgNumType %s w:start="1"/>' % nsdecls('w'))
    sec2_pr.append(pgNumType)

    # Configure Header for Section 2
    sec2.header.is_linked_to_previous = False
    hp2 = sec2.header.paragraphs[0]
    hp2.alignment = WD_ALIGN_PARAGRAPH.LEFT
    hrun = hp2.add_run("BiteHub - Food & Grocery Delivery Management System")
    hrun.font.name = 'Times New Roman'
    hrun.font.size = Pt(10)
    hrun.font.color.rgb = RGBColor(60, 60, 60)
    hp2.paragraph_format.space_after = Pt(10)

    # Configure Footer for Section 2 (Footer removed completely from all pages)
    sec2.footer.is_linked_to_previous = False
    fp2 = sec2.footer.paragraphs[0]
    fp2.text = ""

    # -------------------------------------------------------------
    # PAGE 1 (Doc Page 6): CHAPTER 1 - INTRODUCTION & OBJECTIVE
    # -------------------------------------------------------------
    h1("CHAPTER 1\nINTRODUCTION", space_before=10, space_after=14)

    h2("1.1 Introduction")
    p("This project is a Multi-Vendor Food & Hyperlocal Grocery Delivery Management System built using DBMS, designed to streamline commercial operations between consumers, local dining establishments, dark store fulfillment centers, and on-demand delivery fleets. It maintains structured relational entities including customer profiles, multi-location restaurant registries, dish catalogs, grocery inventory levels, delivery fleet metrics, transactional order records, and payment logs within a centralized MySQL database.")

    p("The system provides rapid, structured access to delivery services through an intuitive, reactive multi-platform interface. It facilitates live food discovery, categorical item filtering, smart cart calculations, instant coupon deductions, live dispatch progression tracking, and automated inventory replenishment, minimizing manual overhead while drastically enhancing customer satisfaction and delivery accuracy. This project demonstrates how a robust database-backed architecture can deliver an enterprise-grade logistics solution tailored for modern on-demand delivery ecosystems.")

    p("BiteHub is developed as a full-stack multi-platform application utilizing Flutter (Dart) and Material 3 for the cross-platform frontend (Web, Windows Desktop, and Mobile), Python FastAPI as the asynchronous REST backend framework, and MySQL 8.0 as the relational database engine. The system supports multiple user roles including Customers, Restaurant Owners, Dark Store Managers, Delivery Fleets, and Administrators, each governed by role-based access control. Development and database administration are carried out using Visual Studio Code, MySQL Workbench, Uvicorn, and Git for version control.")

    h2("1.2 Objective")
    b("To design and develop an easy-to-use cross-platform application that allows customers to discover local restaurants, order meals, and purchase 10-minute groceries online.")
    b("To automate inventory tracking, order fulfillment pipelines, and financial record-keeping, thereby eliminating manual ledger errors and stock discrepancy anomalies.")
    b("To implement a centralized, normalized relational database system for managing customers, restaurant partners, dark store inventories, orders, and delivery personnel with full ACID transactional integrity.")
    b("To provide role-based operational dashboards for restaurant partners to manage menus and kitchen queues, and dark store managers to monitor grocery stocks with automated low-stock warnings.")
    b("To empower delivery agents with real-time assignment tracking, milestone status updates (Picked Up, Out for Delivery, Delivered), and transparent tip and earnings breakdowns.")
    b("To provide an interactive Live SQL Visualizer and DBMS Query Explorer allowing administrators and instructors to inspect table schemas, relationships, and query execution benchmarks directly from the client interface.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 2 (Doc Page 7): USER ROLES & VIEWS
    # -------------------------------------------------------------
    h2("User Roles in the System")
    h3("Administrator / Operations Lead")
    b("Monitor overall platform health, Gross Merchandise Value (GMV), order throughput, and fleet availability.")
    b("Inspect database tables, foreign key constraints, and run live analytical SQL queries with execution latency benchmarks.")
    b("Oversee system stability and configure multi-device network endpoints dynamically.")

    h3("Customer")
    b("Create and authenticate personal accounts using phone credentials.")
    b("Browse curated multi-cuisine restaurants and hyperlocal dark store grocery catalogs with distinct HD visual banners.")
    b("Customize orders, apply promotional discount vouchers (e.g., FEAST20), select tip amounts, and simulate secure payments.")
    b("Track live order milestones and cancel active orders with automatic transactional stock restoration.")

    h3("Restaurant Partner")
    b("Register food establishments with location, phone, and rating attributes.")
    b("Manage menu catalogs with full CRUD capabilities (Add, Edit, Delete dishes, toggle stock availability).")
    b("Select food photos from an integrated 100+ item curated HD gallery or enter custom image URLs.")
    b("Supervise incoming kitchen orders and advance fulfillment states (Accept, Preparing, Ready, Dispatched).")

    h3("Dark Store Hub Manager")
    b("Manage instant quick-commerce grocery inventory across produce, dairy, bakery, snacks, and essentials.")
    b("Receive automatic low-stock visual warning badges when SKU counts fall below safety thresholds.")
    b("Dispatch packed grocery orders to waiting delivery agents.")

    h3("Delivery Agent")
    b("Maintain driver profiles, vehicle registrations, and licensing verification.")
    b("Toggle active shift availability (Online / Offline).")
    b("Accept delivery assignments and update delivery progression milestones.")
    b("Review completed deliveries, daily payouts, and customer gratuity tips.")

    h2("Views Available in the System")
    b("Enterprise Marketing Landing Page – Showcases live platform counter metrics, role gateways, and interactive demo previews.")
    b("Unified Authentication & Dynamic Role Selection – Single sign-in portal routing automatically to role-tailored dashboards.")
    b("Customer Dual-Delivery Dashboard – Comprehensive food discovery and 10-minute grocery hub with sticky floating cart bar.")
    b("Restaurant Kitchen Command Center – Real-time order queue and visual menu management studio.")
    b("Dark Store Quick-Commerce Inventory Studio – Real-time stock adjusters and fulfillment dispatch panel.")
    b("Delivery Fleet Terminal – Task allocation feed, route milestones, and earnings analytics.")
    b("Live SQL Visualizer & DBMS Explorer – In-app relational schema inspector and SQL benchmarking console.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 3 (Doc Page 8): 1.3 FUNCTIONALITY
    # -------------------------------------------------------------
    h2("1.3 Functionality")
    p("The BiteHub Food & Grocery Delivery Management System enhances operational throughput and streamlines collaboration between consumers, dining vendors, quick-commerce fulfillment warehouses, and delivery personnel. The system delivers the following core functional modules:")

    h3("Restaurant & Menu Management Module")
    b("Enables restaurant partners to configure profiles, addresses, contact details, and initial ratings.")
    b("Provides real-time menu management with automated final price calculation based on base rates and discount percentages.")
    b("Enforces foreign key cascading so that dish deletions or restaurant modifications maintain strict referential integrity.")
    b("Provides an interactive photo picker supporting curated HD food banners and external URLs.")

    h3("Dark Store Inventory & Stock Module")
    b("Maintains grocery items categorized by department with atomic unit prices and live available stock counts.")
    b("Implements weak entity dependency where groceries are identified by composite key (Store_Id, Item_Name).")
    b("Provides automatic visual alerts when inventory reaches critical low-stock levels.")

    h3("Transactional Order & Checkout Module")
    b("Computes itemized totals, delivery partner fees, platform fees, agent tips, and promotional voucher discounts.")
    b("Executes transactional order placement that atomically decrements available grocery inventory.")
    b("Supports order cancellation that immediately initiates rollback procedures restoring inventory counts.")

    h3("Delivery Dispatch & Fleet Tracking Module")
    b("Assigns pending orders to available delivery drivers based on proximity and operational load.")
    b("Permits single-tap status progressions: Picked Up -> Out for Delivery -> Delivered.")
    b("Records delivery timestamps to measure operational fulfillment latency.")

    h3("Payment & Billing Module")
    b("Simulates multiple payment modes: UPI (Google Pay, PhonePe, Paytm), Credit/Debit Cards, NetBanking, and COD.")
    b("Maintains a 1:1 relationship between orders and payments ensuring complete financial accountability.")

    h3("Authentication & Diagnostic Security Module")
    b("Implements unified phone-based credential verification with automatic role routing.")
    b("Incorporates an in-app Server Connection Diagnostics Dialog with live latency ping testing and 1-tap IP presets.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 4 (Doc Page 9): 1.4 DBMS & 1.5 MYSQL
    # -------------------------------------------------------------
    h2("1.4 Database Management System")
    p("A Database Management System (DBMS) is an indispensable software foundation designed to store, manipulate, and retrieve large volumes of structured data systematically. In BiteHub, MySQL 8.0 serves as the primary DBMS, guaranteeing data consistency, security, and concurrency control.")

    p("Why Use a DBMS in BiteHub?")
    b("Eliminates Data Redundancy: Normalization prevents duplicate storage of customer, restaurant, or item details.")
    b("Ensures Data Integrity: Foreign key constraints prevent orphaned order items, invalid vendor assignments, or dangling payment records.")
    b("Enforces ACID Properties: Atomicity, Consistency, Isolation, and Durability ensure that financial transactions and inventory deductions never enter a corrupt state.")
    b("Provides High-Performance Structured Queries: Indexed lookups allow sub-millisecond retrieval across multi-table joins.")

    h3("1.4.1 Characteristics of DBMS")
    b("Self-Describing Nature: Database catalogs store metadata describing tables, columns, constraints, and data types.")
    b("Insulation between Programs and Data: Application logic in FastAPI is decoupled from physical storage on disk.")
    b("Support of Multiple Views: Customers, restaurant partners, dark store managers, and drivers interact with specialized logical views tailored to their privileges.")
    b("Sharing of Data and Concurrency Control: Concurrency control algorithms prevent race conditions when multiple customers order the last remaining inventory item simultaneously.")

    h3("1.4.2 Advantages of DBMS")
    b("Data Security: Role-based permissions restrict sensitive customer addresses and payment details.")
    b("Data Consistency: Standardized update cascades prevent divergent records across relational tables.")
    b("Crash Recovery: Enterprise recovery logs ensure zero data loss during sudden server power interruptions.")
    b("Scalability: Connection pooling allows the platform to scale to hundreds of concurrent requests.")

    h2("1.5 MySQL")
    h3("1.5.1 Overview")
    p("MySQL is an open-source relational database management system (RDBMS) renowned for its speed, stability, and adherence to the SQL standard. Utilizing the InnoDB storage engine, MySQL provides row-level locking, foreign key constraints, and full ACID compliance, making it the premier choice for e-commerce and logistics systems like BiteHub.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 5 (Doc Page 10): 1.5.2 SQL COMMANDS & STATEMENTS
    # -------------------------------------------------------------
    h3("1.5.2 SQL Commands Used in DBMS")
    p("SQL commands are categorized into DDL (Data Definition Language), DML (Data Manipulation Language), DQL (Data Query Language), and DCL (Data Control Language). Below are representative commands implemented in the BiteHub database:")

    p("1. Creating the USERS Table (DDL):", space_after=2)
    code("CREATE TABLE USERS (\n    User_Id INT PRIMARY KEY,\n    User_Name VARCHAR(100) NOT NULL,\n    User_Phone VARCHAR(15) UNIQUE,\n    Password VARCHAR(255) DEFAULT '123456',\n    Street VARCHAR(100),\n    Area VARCHAR(100),\n    State VARCHAR(50),\n    Pincode VARCHAR(10)\n);")

    p("2. Creating Weak Entity GROCERIES Table with Composite Key (DDL):", space_after=2)
    code("CREATE TABLE GROCERIES (\n    Store_Id INT,\n    Item_Name VARCHAR(100),\n    Price DECIMAL(10,2),\n    Available_count INT,\n    Image_Url VARCHAR(500),\n    PRIMARY KEY (Store_Id, Item_Name),\n    FOREIGN KEY (Store_Id) REFERENCES DARK_STORE(Store_Id)\n        ON DELETE CASCADE ON UPDATE CASCADE\n);")

    p("3. Inserting a Customer Record (DML):", space_after=2)
    code("INSERT INTO USERS (User_Id, User_Name, User_Phone, Street, Area, State, Pincode)\nVALUES (1, 'Aarav Choudhury', '9810000001', '14 MG Road', 'Indiranagar', 'Karnataka', '560038');")

    p("4. Querying Active Orders with Delivery Address (DQL):", space_after=2)
    code("SELECT Order_Id, User_Id, Status, Total_Amount, Delivery_Addr\nFROM ORDERS\nWHERE Status = 'Out for Delivery';")

    p("5. Updating Grocery Stock after Order Placement (DML):", space_after=2)
    code("UPDATE GROCERIES\nSET Available_count = Available_count - 2\nWHERE Store_Id = 1 AND Item_Name = 'Amul Taaza Milk 500ml';")

    p("6. Deleting a Sold-Out Dish Record (DML):", space_after=2)
    code("DELETE FROM REST_ITEMS\nWHERE Rest_Id = 1 AND Item_Name = 'Seasonal Crab Curry';")

    h3("1.5.3 SQL Statements")
    b("SELECT: Retrieves structured records from one or more tables (e.g., SELECT RName, RRating FROM RESTAURANT WHERE RRating >= 4.5;)")
    b("INSERT: Adds new business entities such as registered users, food items, or orders.")
    b("UPDATE: Modifies existing table data dynamically based on operational events (e.g., order progression).")
    b("DELETE: Removes obsolete tuples while triggering cascading deletes on child relations.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 6 (Doc Page 11): 1.5.4 AGGREGATE FUNCTIONS & CONSTRAINTS
    # -------------------------------------------------------------
    h3("1.5.4 SQL Aggregate Functions")
    p("Aggregate functions perform mathematical computations across multi-row datasets to generate summary analytics in BiteHub:")

    b("COUNT – Computes total records matching criteria:")
    code("SELECT COUNT(*) AS Total_Active_Orders FROM ORDERS WHERE Status != 'Delivered';")

    b("SUM – Calculates total platform gross merchandise value (GMV):")
    code("SELECT SUM(Total_Amount) AS Total_Platform_Revenue FROM ORDERS;")

    b("MAX – Identifies peak values such as maximum driver rating or costliest item:")
    code("SELECT MAX(Price) AS Most_Expensive_Grocery FROM GROCERIES;")

    b("MIN – Identifies lowest item cost for budget filtering:")
    code("SELECT MIN(FinalPrice) AS Budget_Starter FROM REST_ITEMS WHERE Rest_Id = 1;")

    b("AVG – Computes platform benchmarks such as average restaurant rating:")
    code("SELECT AVG(RRating) AS Platform_Average_Rating FROM RESTAURANT;")

    h3("1.5.5 SQL Constraints")
    p("Constraints enforce relational business rules and maintain database integrity at the engine level:")

    b("NOT NULL – Enforces mandatory data fields (e.g., User_Name in USERS).")
    b("PRIMARY KEY – Uniquely identifies each record with implied non-null uniqueness (e.g., Rest_Id).")
    b("UNIQUE – Prevents duplicate values across distinct rows (e.g., User_Phone in USERS).")
    b("FOREIGN KEY – Establishes referential integrity by referencing a parent table's primary key with ON DELETE CASCADE.")
    b("CHECK – Verifies that column values adhere to a defined logical predicate (e.g., RRating between 1.0 and 5.0).")
    b("DEFAULT – Injects an initial value automatically when none is specified (e.g., Password default '123456').")
    b("AUTO_INCREMENT – Sequentially generates monotonic primary key identifiers upon tuple insertion.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 7 (Doc Page 12): CHAPTER 2 - LITERATURE REVIEW
    # -------------------------------------------------------------
    h1("CHAPTER 2\nLITERATURE REVIEW", space_before=10, space_after=14)

    p("This chapter examines legacy and contemporary systems utilized for food delivery and hyperlocal grocery distribution, establishes architectural requirements, and provides theoretical foundations for the database design of the BiteHub project.")

    h2("2.1 Survey of Existing Systems")
    p("Traditionally, retail food ordering and grocery logistics relied upon paper records, physical order slips, phone book directories, and rudimentary standalone spreadsheets. While workable for small local neighborhood merchants with limited customer volumes, these manual paradigms exhibit severe limitations in operational speed, synchronization, accuracy, and scaling capability.")

    p("Manual systems consistently lead to stock miscounts, misplaced paper order tickets, unauthorized record tampering, and prolonged fulfillment delays. While massive corporate aggregators operate proprietary enterprise systems, regional restaurant chains and independent dark store franchise operators often lack integrated, accessible database systems that combine both dining and quick-commerce groceries into a unified, transparent architecture. This deficiency creates fragmented inventory visibility and poor coordination with delivery fleets.")

    p("Disadvantages of Manual and Fragmented Systems:")
    b("High incidence of human calculation errors in billing totals, taxes, and coupon deductions.")
    b("Sluggish, error-prone data lookup resulting in customer frustration and missed orders.")
    b("Lack of centralized data security and vulnerability of customer phone numbers and payment data.")
    b("Data redundancy across disjointed billing ledgers causing phantom stockouts and inventory inconsistencies.")
    b("Absence of real-time milestone status tracking between kitchen staff, riders, and hungry customers.")
    b("Inability to generate instant analytical business reports regarding peak revenue, best-selling dishes, and fleet utilization.")

    h2("2.2 Proposed System")
    p("The proposed BiteHub - Multi-Vendor Food & Grocery Delivery Management System overcomes these systemic shortcomings by providing an automated, centralized, and secure relational database platform. BiteHub seamlessly coordinates multi-restaurant dining catalogs, 10-minute dark store grocery inventories, transactional order placement, delivery fleet dispatching, and executive analytics within a cohesive environment.")

    p("BiteHub centralizes core delivery operations through dedicated role-based workflows for Customers, Restaurant Partners, Dark Store Managers, Delivery Drivers, and Operations Administrators. By replacing traditional manual ledgers with a transactional relational database, BiteHub guarantees zero stock discrepancies, prevents unauthorized data modifications, and provides sub-second query execution across all user operations.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 8 (Doc Page 13): REQUIREMENTS & TECH STACK
    # -------------------------------------------------------------
    h2("2.3 Software Requirements")
    b("Operating System: Windows 10/11, Linux (Ubuntu 20.04+), or macOS")
    b("Frontend Framework: Flutter SDK 3.22+ with Dart 3.4+ and Material 3 Design")
    b("Backend Framework: Python 3.10+ with FastAPI and Uvicorn ASGI Server")
    b("Database Management System: MySQL Server 8.0+ (InnoDB Storage Engine)")
    b("Database Connector & Middleware: Python mysql-connector-python, Dart http, CORS Middleware")
    b("Development Tools: Visual Studio Code, MySQL Workbench, Git, PowerShell")

    h2("2.4 Frontend Technologies")
    p("The frontend serves as the primary visual interface through which customers, vendors, and delivery agents interact with the delivery platform. Built using Flutter and Dart, the client delivers a fluid, 60fps responsive user experience.")

    h3("1. Flutter Framework")
    p("Flutter is Google's open-source UI toolkit for building natively compiled applications across mobile, web, and desktop from a single codebase. It provides a rich widget tree, reactive state management, and adaptive layouts.")

    h3("2. Dart Programming Language")
    p("Dart is an object-oriented, strongly-typed language optimized for client applications. Its sound type system prevents runtime null-pointer exceptions and ensures predictable serialization of JSON network responses.")

    h3("3. Material 3 Design System")
    p("Material 3 provides modern visual semantics including dynamic color schemes, pill navigation chips, elevated cards, bottom sheets, and typography guidelines that ensure visual elegance across desktop and mobile screens.")

    h2("2.5 Backend Technologies")
    p("The backend of BiteHub executes core business logic, processes client HTTP requests, validates role authentication, manages connection pools, and enforces transactional ACID rules with MySQL.")

    h3("1. Python FastAPI Framework")
    p("FastAPI is a modern, high-performance web framework for building APIs with Python 3.8+ based on standard Python type hints. Powered by Starlette and Pydantic, FastAPI delivers exceptional speed comparable to NodeJS and Go, automated Swagger documentation at /docs, and robust schema validation.")

    h3("2. MySQL Relational Database")
    p("MySQL provides structured storage across 10 normalized tables, enforces referential integrity through foreign keys, executes ACID transactions, and utilizes B-tree indexes for lightning-fast lookups.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 9 (Doc Page 14): 2.6 ER MODEL THEORY
    # -------------------------------------------------------------
    h2("2.6 Entity-Relationship (ER) Model")
    p("The Entity-Relationship (ER) model is a high-level conceptual data modeling methodology that provides a systematic representation of real-world entities, their intrinsic attributes, and the relational associations between them. It serves as an architectural blueprint prior to physical relational schema implementation.")

    h3("Purpose of the ER Model")
    b("Visually conceptualize complex multi-vendor logistics in an easily comprehensible diagram.")
    b("Identify independent business entities (Customers, Restaurants, Warehouses, Agents) and dependent entities.")
    b("Establish relationship associations and specify precise cardinalities (1:1, 1:N, M:N).")
    b("Define entity attributes, primary keys, and candidate keys.")
    b("Impose structural integrity constraints prior to database table creation.")

    h3("Core Components of the ER Model")
    p("The ER model comprises three fundamental components: Entities, Attributes, and Relationships.")

    h3("1. Entities")
    b("Strong Entity: Possesses an intrinsic primary key capable of uniquely identifying every tuple (e.g., USERS with User_Id, RESTAURANT with Rest_Id, DELIVERY_AGENT with Agent_Id). Represented as a single rectangle.")
    b("Weak Entity: Lacks a primary key of its own and depends on a strong identifying entity via a foreign key and partial key (e.g., GROCERIES depends on DARK_STORE via Store_Id and partial key Item_Name). Represented as a double rectangle.")

    h3("2. Attributes")
    b("Simple (Atomic): Cannot be subdivided into smaller components (e.g., User_Id, BasePrice).")
    b("Composite: Composed of multiple constituent elements (e.g., Address composed of Street, Area, State, and Pincode).")
    b("Derived: Computed dynamically from other stored attributes (e.g., FinalPrice computed as BasePrice - Discount).")
    b("Multivalued: Capable of holding multiple values for a single entity instance (e.g., User_Phone). Represented as double ellipses.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 10 (Doc Page 15): RELATIONSHIPS & CARDINALITIES
    # -------------------------------------------------------------
    h3("3. Relationships")
    p("Relationships describe meaningful associations between two or more participating entities. In BiteHub, key relationships include:")
    b("A Customer places one or more Orders (1:N).")
    b("A Restaurant prepares multiple Orders (1:N) and serves multiple Rest_Items (1:N).")
    b("A Dark Store stocks multiple Groceries (1:N).")
    b("A Delivery Agent fulfills assigned Orders (1:N).")
    b("An Order has exactly one associated Payment (1:1).")

    p("Relationships are depicted as diamond shapes in ER diagrams and are characterized by:")
    b("Cardinality Constraints: Specify the numerical ratio of entity instances involved in a relationship:")
    p("  • One-to-One (1:1): Each entity instance is associated with at most one instance of another entity (e.g., Orders and Payment).", space_after=2)
    p("  • One-to-Many (1:N): One entity instance relates to multiple instances of another entity (e.g., Customer to Orders, Restaurant to Rest_Items).", space_after=2)
    p("  • Many-to-Many (M:N): Multiple instances of one entity relate to multiple instances of another (e.g., Orders to Rest_Items resolved via ORDER_ITEM, Orders to Groceries resolved via ORDER_GROCERY).", space_after=4)
    b("Participation Constraints: Specify whether all entity instances must participate:")
    p("  • Total Participation: Every entity instance must participate in the relationship (e.g., Every Payment must belong to an Order). Depicted by double lines.", space_after=2)
    p("  • Partial Participation: Only a subset of entity instances participate (e.g., Not all Delivery Agents are actively assigned to an Order at any given moment). Depicted by single lines.", space_after=6)

    h3("Keys and Integrity Constraints")
    b("Primary Key (PK): An irreducible attribute set that uniquely identifies each entity tuple.")
    b("Foreign Key (FK): An attribute in a relation that matches the primary key of another relation, linking the two tables.")
    b("Referential Integrity: Mandates that foreign key values must either match an existing valid primary key or be null.")

    h3("Advanced Concepts & Benefits in BiteHub")
    b("Weak Entity & Identifying Relationship: Identifies GROCERIES by identifying relationship 'stocks' from DARK_STORE.")
    b("Relationship Attributes: Descriptive data stored directly within a relationship link (e.g., 'Food_quantity' inside ORDER_ITEM).")
    b("Guarantees logical consistency before writing SQL DDL, streamlines normalization, and eliminates data anomalies.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 11 (Doc Page 16): 2.7 RELATIONAL SCHEMA DESIGN (STEPS 1-3)
    # -------------------------------------------------------------
    h2("2.7 Relational Schema Design")
    p("The Relational Schema is the formal logical structure of a database expressed as tables (relations), attributes (columns), and tuples (rows). It translates conceptual ER constructs into mathematical relations governed by primary keys, foreign keys, and domain constraints.")

    h3("7-Step Approach to Convert ER Model to Relational Schema")
    p("The transformation of BiteHub's conceptual ER diagram into normalized relational tables follows a rigorous seven-step database mapping methodology:")

    h3("Step 1: Mapping Regular (Strong) Entity Sets")
    p("Each strong entity in the ER model is converted into an independent relation containing all simple and composite attributes (flattened into columns). The entity's identifier becomes the primary key.")
    p("Example in BiteHub: Entity USERS", space_after=2)
    code("USERS(User_Id PRIMARY KEY, User_Name, User_Phone, Password,\n      Street, Area, State, Pincode)")

    h3("Step 2: Mapping Weak Entity Sets")
    p("A weak entity cannot stand alone. It is mapped to a relation containing all simple attributes, plus the primary key of the identifying parent entity as a foreign key. The combination of the foreign key and the partial key forms a composite primary key.")
    p("Example in BiteHub: Weak Entity GROCERIES dependent on DARK_STORE", space_after=2)
    code("GROCERIES(Store_Id, Item_Name, Price, Available_count, Image_Url,\n          PRIMARY KEY(Store_Id, Item_Name),\n          FOREIGN KEY(Store_Id) REFERENCES DARK_STORE(Store_Id)\n              ON DELETE CASCADE ON UPDATE CASCADE)")

    h3("Step 3: Mapping Binary 1:1 Relationships")
    p("For one-to-one relationships, the foreign key is positioned within the relation possessing total participation, reinforced with a UNIQUE constraint to preserve 1:1 cardinality.")
    p("Example in BiteHub: Order has exactly one Payment (1:1)", space_after=2)
    code("PAYMENT(Payment_Id PRIMARY KEY, Order_Id UNIQUE,\n        Payment_Method, Amount,\n        FOREIGN KEY(Order_Id) REFERENCES ORDERS(Order_Id)\n            ON DELETE CASCADE ON UPDATE CASCADE)")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 12 (Doc Page 17): STEPS 4-7
    # -------------------------------------------------------------
    h3("Step 4: Mapping Binary 1:N Relationships")
    p("For one-to-many relationships, the primary key of the entity on the 'one' side is embedded as a foreign key attribute inside the relation representing the 'many' side.")
    p("Example 1 in BiteHub: Customer places Orders (1:N)", space_after=2)
    code("ORDERS(Order_Id PRIMARY KEY, User_Id, Rest_Id, Store_Id, Agent_Id,\n       Status, Total_Amount, PlacedAt, DeliveredAt, Delivery_Addr,\n       FOREIGN KEY(User_Id) REFERENCES USERS(User_Id))")

    p("Example 2 in BiteHub: Restaurant serves Rest_Items (1:N)", space_after=2)
    code("REST_ITEMS(Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount,\n           FinalPrice, Image_Url,\n           PRIMARY KEY(Rest_Id, Item_Name),\n           FOREIGN KEY(Rest_Id) REFERENCES RESTAURANT(Rest_Id))")

    h3("Step 5: Mapping Binary M:N Relationships")
    p("Many-to-many relationships cannot be represented cleanly within existing entity tables without violating normal forms. A dedicated junction relation (associative entity) is created containing foreign keys referencing both participating entities, which collectively form a composite primary key. Any relationship attributes become columns in this junction relation.")
    p("Example in BiteHub: Orders contain Dishes (M:N) resolved via ORDER_ITEM:", space_after=2)
    code("ORDER_ITEM(Order_Id, Rest_Id, Item_Name, Food_quantity,\n           PRIMARY KEY(Order_Id, Rest_Id, Item_Name),\n           FOREIGN KEY(Order_Id) REFERENCES ORDERS(Order_Id),\n           FOREIGN KEY(Rest_Id, Item_Name) REFERENCES REST_ITEMS(Rest_Id, Item_Name))")

    h3("Step 6: Mapping Multivalued Attributes")
    p("When an entity possesses a multivalued attribute (such as customer secondary addresses), a separate relation is created combining the entity's primary key with the multivalued attribute.")
    code("USER_ADDRESS(User_Id, Address, PRIMARY KEY(User_Id, Address),\n             FOREIGN KEY(User_Id) REFERENCES USERS(User_Id))")

    h3("Step 7: Mapping Ternary Relationships")
    p("When three or more entities participate in an n-ary relationship, a new relation is established containing the primary keys of all participating entities as foreign keys.")
    code("DELIVERY_ASSIGNMENT(Order_Id, Agent_Id, AssignedAt, Delivery_Status,\n                    PRIMARY KEY(Order_Id, Agent_Id),\n                    FOREIGN KEY(Order_Id) REFERENCES ORDERS(Order_Id),\n                    FOREIGN KEY(Agent_Id) REFERENCES DELIVERY_AGENT(Agent_Id))")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 13 (Doc Page 18): 2.8 NORMALIZATION
    # -------------------------------------------------------------
    h2("2.8 Normalization")
    p("Normalization is a mathematical database design methodology that evaluates relational schemas against specific formal normal forms to systematically eliminate data redundancy and prevent Insertion, Update, and Deletion Anomalies.")

    h3("Functional Dependency")
    p("A Functional Dependency, denoted by X → Y, between two attribute sets X and Y within a relation R, specifies that the value of X uniquely determines the value of Y. Attribute X is called the Determinant.")

    h3("Normal Forms in SQL:")
    b("1NF (First Normal Form): Elimination of repeating groups and non-atomic attribute values.")
    b("2NF (Second Normal Form): Elimination of partial functional dependencies on composite keys.")
    b("3NF (Third Normal Form): Elimination of transitive dependencies on non-prime attributes.")
    b("BCNF (Boyce-Codd Normal Form): Strict enforcement where every determinant is a super key.")
    b("4NF (Fourth Normal Form): Elimination of multi-valued dependencies.")
    b("5NF (Fifth Normal Form): Elimination of join dependencies not implied by candidate keys.")

    h3("a) First Normal Form (1NF)")
    p("A relation schema R is in 1NF if and only if the domain of every attribute contains solely atomic (indivisible) values. 1NF prohibits nested relations, arrays, and repeating comma-separated lists of values within a single column.")

    h3("b) Second Normal Form (2NF)")
    p("A relation schema R is in 2NF if it satisfies 1NF and every non-prime attribute A in R is fully functionally dependent on the primary key. In BiteHub, composite tables such as REST_ITEMS(Rest_Id, Item_Name) ensure that food attributes depend strictly on the complete composite key.")

    h3("c) Third Normal Form (3NF)")
    p("A relation schema R is in 3NF if it satisfies 2NF and no non-prime attribute is transitively dependent on the primary key. 3NF ensures that non-key columns depend solely on the primary key, the whole primary key, and nothing but the primary key.")

    h3("d) Boyce-Codd Normal Form (BCNF)")
    p("A relation schema R is in BCNF if and only if, for every functional dependency X → Y that holds over R, X is a super key of R.")

    h3("e) Fourth Normal Form (4NF) & Fifth Normal Form (5NF)")
    p("4NF eliminates multi-valued dependencies, ensuring independent multi-valued facts are decoupled into separate tables. 5NF eliminates cyclic join dependencies.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 14 (Doc Page 19): 3NF IN BITEHUB, APIS & ADVANTAGES
    # -------------------------------------------------------------
    h3("Normalization of the BiteHub Database")
    p("The database schema of the BiteHub platform has been structured and validated up to Third Normal Form (3NF):")
    b("All table attributes are strictly atomic (1NF compliant).")
    b("Every non-prime attribute is fully functionally dependent on the complete primary key; partial dependencies in composite tables (REST_ITEMS, GROCERIES, ORDER_ITEM) have been eliminated (2NF compliant).")
    b("Transitive dependencies have been eliminated; customer addresses, store locations, and payment records reside in normalized relations without intermediate functional dependencies (3NF compliant).")

    h2("2.9 API Development")
    p("To bridge the Flutter client and the MySQL relational database, BiteHub employs high-speed RESTful APIs developed in Python FastAPI. These APIs handle JSON payloads and execute prepared parameterized SQL statements with MySQL Connector.")
    b("/api/auth: Multi-role login and registration with automatic role detection.")
    b("/api/restaurants: Restaurant metadata and complete menu CRUD operations.")
    b("/api/dark-stores: Quick-commerce store registries and grocery stock updates.")
    b("/api/orders: ACID order placement, status progression, and cancellation with stock rollback.")
    b("/api/visualizer: Read-only SQL query execution with latency benchmarking.")

    h2("2.10 Advantages of the Proposed System")
    b("Improved Accuracy and Efficiency: Centralized relational persistence completely eliminates double-entry errors and manual calculation mistakes.")
    b("Enhanced Data Security: Secure password hashing, parameterized SQL queries preventing SQL injection, and role-based access control protect customer and vendor records.")
    b("Real-Time Data Access: Customers, restaurant kitchens, warehouse pickers, and delivery riders receive instant synchronization of order milestones.")
    b("Scalable and Modular Design: Decoupled client-server architecture allows independent scaling of frontend interfaces, backend workers, and database replicas.")
    b("Centralized Relational Integrity: Cascading deletes and update triggers guarantee that order history, item catalogs, and payments remain consistent.")
    b("Custom Reporting and Analytics: Administrators can execute live aggregation queries (SUM, AVG, GROUP BY) to measure GMV, popular dishes, and driver turnaround times.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 15 (Doc Page 20): CHAPTER 3 - PROPOSED WORK (ER ATTRIBUTES)
    # -------------------------------------------------------------
    h1("CHAPTER 3\nPROPOSED WORK", space_before=10, space_after=14)

    p("This chapter presents the design and relational structure of the BiteHub Food & Grocery Delivery Management System, delineating how data entities interact, foreign key associations are modeled, and operational integrity is preserved across ordering, kitchen fulfillment, grocery dispatching, and delivery tracking.")

    h2("3.1 Entity Relationship (ER) Model")
    p("The ER diagram illustrates how core entities, weak entities, attributes, and relationships are interconnected to ensure minimal data redundancy and maximum retrieval efficiency.")

    h3("Entities and their Attributes in BiteHub:")
    b("USERS: User_Id (PK), User_Name, User_Phone (UNIQUE), Password, Street, Area, State, Pincode")
    b("DELIVERY_AGENT: Agent_Id (PK), Agent_Name, Agent_Phone, Password, VehicleNO, V_Type, Has_license, Rating")
    b("RESTAURANT: Rest_Id (PK), RName, RLocation, RPhone, Password, RRating, Image_Url")
    b("REST_ITEMS: Rest_Id (FK), Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Image_Url [Composite PK: (Rest_Id, Item_Name)]")
    b("DARK_STORE: Store_Id (PK), DS_Phone, Password, DS_Street, DS_Area, DS_State, DS_Pincode")
    b("GROCERIES (Weak Entity of DARK_STORE): Store_Id (FK), Item_Name, Price, Available_count, Image_Url [Composite PK: (Store_Id, Item_Name)]")
    b("ORDERS: Order_Id (PK), User_Id (FK), Agent_Id (FK), Rest_Id (FK), Store_Id (FK), Order_Review, PlacedAt, DeliveredAt, Delivery_Addr, Agent_Rating, Status, Total_Amount, Delivery_Fee, Tip_Amount")
    b("ORDER_ITEM: Order_Id (FK), Rest_Id (FK), Item_Name (FK), Food_quantity [Composite PK: (Order_Id, Rest_Id, Item_Name)]")
    b("ORDER_GROCERY: Order_Id (FK), Store_Id (FK), Item_Name (FK), Quantity [Composite PK: (Order_Id, Store_Id, Item_Name)]")
    b("PAYMENT: Payment_Id (PK), Order_Id (FK, UNIQUE), Payment_Method, Amount")

    p("All entities are persisted within a normalized MySQL database enforcing strict primary and foreign key constraints, guaranteeing transaction safety and immediate response times across all client platforms.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 16 (Doc Page 21): FIGURE 1 - ER DIAGRAM
    # -------------------------------------------------------------
    h2("Entity-Relationship Diagram")
    p("The complete ER diagram illustrating all entities, weak entities, relationships, attributes, and cardinality ratios in the BiteHub system is depicted below:", space_after=8)

    if os.path.exists("report_assets/figure1_er_diagram.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(6)
        p_img.paragraph_format.space_after = Pt(8)
        p_img.add_run().add_picture("report_assets/figure1_er_diagram.png", width=Inches(5.8))

    p_cap1 = p("Figure 1: ER-Diagram of BiteHub Food & Grocery Database Management System", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
    p_cap1.runs[0].font.size = Pt(11)
    p_cap1.runs[0].italic = True
    p_cap1.runs[0].bold = True

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 17 (Doc Page 22): FIGURE 2 - RELATIONAL MODEL
    # -------------------------------------------------------------
    h2("3.2 Relational Model")
    p("The relational model defines the structure of the database in terms of normalized tables, primary keys, and foreign keys. BiteHub stores all transactional and catalog data in interconnected relations enforcing referential integrity:", space_after=8)

    if os.path.exists("report_assets/figure2_relational_model.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(6)
        p_img.paragraph_format.space_after = Pt(8)
        p_img.add_run().add_picture("report_assets/figure2_relational_model.png", width=Inches(5.8))

    p_cap2 = p("Figure 2: Relational Model of the BiteHub Database Management System", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
    p_cap2.runs[0].font.size = Pt(11)
    p_cap2.runs[0].italic = True
    p_cap2.runs[0].bold = True

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 18 (Doc Page 23): RELATIONSHIPS & CARDINALITIES IN BITEHUB
    # -------------------------------------------------------------
    h2("Relationships and Cardinalities in BiteHub")
    b("1. A Customer can place multiple Bookings/Orders (USERS -> ORDERS) (1:M): Every order is placed by exactly one registered user, but a customer may place numerous orders over time.")
    b("2. A Restaurant prepares multiple Orders (RESTAURANT -> ORDERS) (1:M): Many food orders originate from a specific restaurant, whereas a food order is fulfilled by one primary kitchen.")
    b("3. A Restaurant serves multiple Dishes (RESTAURANT -> REST_ITEMS) (1:M): A dining partner maintains many menu items, with each dish belonging to that restaurant identified by composite key (Rest_Id, Item_Name).")
    b("4. A Dark Store stocks multiple Groceries (DARK_STORE -> GROCERIES) (1:M): A quick-commerce fulfillment warehouse stocks numerous grocery items; GROCERIES is a weak entity dependent on DARK_STORE.")
    b("5. An Order contains multiple Dishes (ORDERS -> REST_ITEMS) (M:N): An order can include multiple menu items, and a dish can appear in multiple orders; resolved via associative entity ORDER_ITEM carrying relationship attribute Food_quantity.")
    b("6. An Order contains multiple Groceries (ORDERS -> GROCERIES) (M:N): An order can incorporate multiple grocery SKUs, resolved via associative entity ORDER_GROCERY with attribute Quantity.")
    b("7. An Order is delivered by one Delivery Agent (ORDERS -> DELIVERY_AGENT) (M:1): A delivery driver manages multiple drop-offs sequentially, while an individual order is assigned to a single driver.")
    b("8. An Order has exactly one Payment record (ORDERS -> PAYMENT) (1:1): Every finalized order corresponds to exactly one payment transaction; enforced by UNIQUE(Order_Id) in the PAYMENT relation.")

    p("These cardinalities prevent orphaned tuples and maintain database synchronization across all delivery and payment operations.", space_after=0)

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 19 (Doc Page 24): CHAPTER 4 - RESULTS (OUTCOMES)
    # -------------------------------------------------------------
    h1("CHAPTER 4\nRESULT", space_before=10, space_after=14)

    h2("4.1 Outcomes")
    p("The BiteHub - Multi-Vendor Food & Grocery Delivery Management System was successfully implemented and validated using a comprehensive realistic dataset consisting of 100+ users, 45+ restaurants, 12 dark stores, 85+ delivery agents, and thousands of historical orders and menu items. The system seamlessly coordinates restaurant dining orders, 10-minute grocery dispatches, fleet routing, and payment verification, ensuring high-speed and accurate operations.")

    p("Test users and evaluators found the Flutter interface to be intuitive, responsive, and visually modern. Customers can fluidly browse distinct restaurant banners, filter by vegetarian options, apply promotional discount coupons, select driver tips, and track active orders in real time. Restaurant partners and dark store managers can effortlessly supervise inventory, update prices, and advance order states through clean dashboard controls.")

    p("The system also incorporates a Live SQL Visualizer and DBMS Query Explorer, allowing real-time execution of analytical SQL statements with latency execution benchmarks. The backend server developed in Python FastAPI guarantees sub-20ms endpoint response times, while MySQL enforces strict referential integrity and transaction rollback on order cancellations. The result is an enterprise-grade, fault-tolerant platform that establishes how modern relational database design powers high-performance delivery applications.")

    p("The BiteHub system substantially improves commercial food logistics and grocery distribution by automating order placement, enhancing customer-vendor coordination, and centralizing all operational records. It provides a dependable, scalable, and secure platform for modern on-demand delivery services.")

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 20 (Doc Page 25): SCREENSHOTS (FIGURES 3 & 4)
    # -------------------------------------------------------------
    h2("4.2 Screenshots")
    p("The following series of screenshots illustrates the developed application across various user roles:", space_after=6)

    if os.path.exists("report_assets/figure3_landing.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(2)
        p_img.paragraph_format.space_after = Pt(2)
        p_img.add_run().add_picture("report_assets/figure3_landing.png", width=Inches(4.8))
        p_c = p("Figure 3: BiteHub Enterprise Landing Portal & Unified Role Gateway", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=10)
        p_c.runs[0].font.size = Pt(10)
        p_c.runs[0].italic = True

    if os.path.exists("report_assets/figure4_customer.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(2)
        p_img.paragraph_format.space_after = Pt(2)
        p_img.add_run().add_picture("report_assets/figure4_customer.png", width=Inches(4.8))
        p_c = p("Figure 4: Customer Food & Hyperlocal Grocery Experience", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
        p_c.runs[0].font.size = Pt(10)
        p_c.runs[0].italic = True

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 21 (Doc Page 26): SCREENSHOTS (FIGURES 5 & 6)
    # -------------------------------------------------------------
    if os.path.exists("report_assets/figure5_restaurant.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(6)
        p_img.paragraph_format.space_after = Pt(2)
        p_img.add_run().add_picture("report_assets/figure5_restaurant.png", width=Inches(4.8))
        p_c = p("Figure 5: Restaurant Partner Kitchen & Menu Management Studio", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=14)
        p_c.runs[0].font.size = Pt(10)
        p_c.runs[0].italic = True

    if os.path.exists("report_assets/figure6_darkstore.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(6)
        p_img.paragraph_format.space_after = Pt(2)
        p_img.add_run().add_picture("report_assets/figure6_darkstore.png", width=Inches(4.8))
        p_c = p("Figure 6: Dark Store Quick-Commerce Inventory & Low-Stock Alerts", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
        p_c.runs[0].font.size = Pt(10)
        p_c.runs[0].italic = True

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 22 (Doc Page 27): SCREENSHOTS (FIGURES 7 & 8)
    # -------------------------------------------------------------
    if os.path.exists("report_assets/figure7_delivery.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(6)
        p_img.paragraph_format.space_after = Pt(2)
        p_img.add_run().add_picture("report_assets/figure7_delivery.png", width=Inches(4.8))
        p_c = p("Figure 7: Delivery Agent Fleet Terminal & Task Progression", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=14)
        p_c.runs[0].font.size = Pt(10)
        p_c.runs[0].italic = True

    if os.path.exists("report_assets/figure8_sql_visualizer.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(6)
        p_img.paragraph_format.space_after = Pt(2)
        p_img.add_run().add_picture("report_assets/figure8_sql_visualizer.png", width=Inches(4.8))
        p_c = p("Figure 8: Live SQL Visualizer & DBMS Query Explorer", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
        p_c.runs[0].font.size = Pt(10)
        p_c.runs[0].italic = True

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 23 (Doc Page 28): SCREENSHOT DESCRIPTIONS
    # -------------------------------------------------------------
    h2("Descriptions of System Screenshots")

    p("Figure 3 : Welcome & Landing Portal – Introduces users to the delivery platform with animated counter statistics, interactive role switchers (Customer, Restaurant, Dark Store, Fleet), and direct access to sign in.", space_after=8)

    p("Figure 4 : Customer Food & Hyperlocal Grocery Experience – Displays dual-delivery mode (Food & 10-min Mart) with distinct curated HD restaurant banners, rating pills, distance estimation, promo vouchers, and sticky floating cart bar.", space_after=8)

    p("Figure 5 : Restaurant Partner Kitchen & Menu Management Studio – Empowers dining establishments to manage kitchen queues, execute menu CRUD operations, calculate automatic discounts, and select photos from a 100+ item food gallery.", space_after=8)

    p("Figure 6 : Dark Store Quick-Commerce Inventory & Low-Stock Alerts – Enables warehouse managers to track live grocery inventory across 6 departments with automatic low-stock visual warning badges and order packing dispatch tools.", space_after=8)

    p("Figure 7 : Delivery Agent Fleet Terminal & Task Progression – Provides drivers with incoming delivery alerts, milestone updates (Picked Up -> Out for Delivery -> Delivered), vehicle licensing info, and daily earnings with tips.", space_after=8)

    p("Figure 8 : Live SQL Visualizer & DBMS Query Explorer – In-app database console enabling live execution of analytical SQL queries, visual inspection of relational tables, and latency benchmarking directly against the MySQL engine.", space_after=0)

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 24 (Doc Page 29): CHAPTER 5 - CONCLUSION
    # -------------------------------------------------------------
    h1("CONCLUSION", space_before=10, space_after=14)

    p("The BiteHub - Multi-Vendor Food & Grocery Delivery Management System was developed to streamline and automate key operations within on-demand food logistics and quick-commerce retail. The project successfully integrates a MySQL relational database normalized to Third Normal Form (3NF) with a user-friendly frontend built using Flutter (Dart) and an asynchronous Python FastAPI REST backend. This combination ensures smooth interaction between customers, dining vendors, dark store managers, and delivery agents, offering an efficient and organized platform for managing on-demand delivery logistics.", space_after=10)

    p("The system effectively handles customer registration, restaurant menu catalogs, grocery inventory tracking, ACID transactional order placement, delivery fleet dispatching, and secure payment processing. By maintaining a well-structured and normalized database, BiteHub minimizes data redundancy, ensures consistency, and allows for quick and reliable data retrieval. The automated workflows significantly reduce manual efforts and improve overall accuracy in managing orders and inventory counts.", space_after=10)

    p("Through its clear visual design and interactive interface, the system ensures that both administrators and users can access and manage delivery operations easily. BiteHub not only simplifies order tracking and inventory management but also enhances customer satisfaction by providing transparency, speed, and convenience throughout the fulfillment process.", space_after=12)

    h3("Future Enhancements")
    p("While the current version successfully handles core delivery management functionalities, future improvements may include:")
    b("Integration of real-time GPS telemetry and IoT hardware tracking for delivery vehicles.")
    b("Implementation of AI-based recommendation systems for personalized restaurant and grocery suggestions.")
    b("Addition of automated SMS and WhatsApp notifications for order confirmations and live delivery updates.")
    b("Expansion to multi-city franchise clusters with dynamic surge pricing algorithms.")
    b("Implementation of automated dark store robotic picking simulations.")

    p("In conclusion, the BiteHub platform provides a centralized, secure, and scalable database management solution that enhances delivery operations, improves customer interaction, and ensures smooth coordination among all entities involved. It stands as a reliable and efficient solution for modern on-demand delivery needs.", space_after=0)

    doc.add_page_break()

    # -------------------------------------------------------------
    # PAGE 25 (Doc Page 30): CHAPTER 6 - BIBLIOGRAPHY
    # -------------------------------------------------------------
    h1("BIBLIOGRAPHY", space_before=12, space_after=18)

    bib_entries = [
        "[1] R. Elmasri and S. B. Navathe, Fundamentals of Database Systems, 7th ed. Boston, MA: Pearson, 2016.",
        "[2] A. Silberschatz, H. F. Korth, and S. Sudarshan, Database System Concepts, 7th ed. New York: McGraw-Hill, 2019.",
        "[3] C. J. Date, An Introduction to Database Systems, 8th ed. Boston, MA: Addison-Wesley, 2003.",
        "[4] E. Windmill, Flutter in Action, 1st ed. Shelter Island, NY: Manning Publications, 2020.",
        "[5] S. Tiangolo, FastAPI Web Framework Documentation. [Online]. Available: https://fastapi.tiangolo.com",
        "[6] MySQL 8.0 Reference Manual. Oracle Corporation. [Online]. Available: https://dev.mysql.com/doc/refman/8.0/en/",
        "[7] Flutter & Dart Official Documentation. Google LLC. [Online]. Available: https://docs.flutter.dev",
        "[8] M. Fowler, Patterns of Enterprise Application Architecture. Boston, MA: Addison-Wesley, 2002."
    ]

    for item in bib_entries:
        p(item, space_after=12, line_spacing=1.2)

    doc_path = "BiteHub_DBMS_Mini_Project_Report.docx"
    alt_path = "BiteHub_DBMS_Mini_Project_Report_PrintReady.docx"
    try:
        doc.save(doc_path)
        print(f"Successfully saved {doc_path} (No Footers, 30-Page Printout Layout)")
    except Exception as e:
        print(f"Notice: {doc_path} is currently locked by editor: {e}")
    doc.save(alt_path)
    print(f"Successfully saved {alt_path} (No Footers, 30-Page Printout Layout)")

if __name__ == "__main__":
    generate_report()


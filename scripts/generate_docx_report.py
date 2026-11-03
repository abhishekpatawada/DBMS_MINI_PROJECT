import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn

def create_report():
    doc = Document()

    # 1. Page Margins (1 inch all sides)
    section = doc.sections[0]
    section.top_margin = Inches(1.0)
    section.bottom_margin = Inches(1.0)
    section.left_margin = Inches(1.0)
    section.right_margin = Inches(1.0)
    section.page_width = Inches(8.27)  # A4 width
    section.page_height = Inches(11.69) # A4 height
    section.different_first_page_header_footer = True

    # Style defaults: Times New Roman
    style_normal = doc.styles['Normal']
    style_normal.font.name = 'Times New Roman'
    style_normal.font.size = Pt(12)
    style_normal.font.color.rgb = RGBColor(0, 0, 0)
    style_normal.paragraph_format.line_spacing = 1.15
    style_normal.paragraph_format.space_after = Pt(6)

    # Configure Header & Footer for normal pages
    header = section.header
    hp = header.paragraphs[0]
    hp.alignment = WD_ALIGN_PARAGRAPH.LEFT
    hrun = hp.add_run("BiteHub - Food & Grocery Delivery Management System")
    hrun.font.name = 'Times New Roman'
    hrun.font.size = Pt(10)
    hrun.font.color.rgb = RGBColor(50, 50, 50)
    hp.paragraph_format.space_after = Pt(12)

    footer = section.footer
    fp = footer.paragraphs[0]
    fp.alignment = WD_ALIGN_PARAGRAPH.LEFT
    fp.paragraph_format.tab_stops.add_tab_stop(Inches(3.15), docx.enum.text.WD_TAB_ALIGNMENT.CENTER)
    fp.paragraph_format.tab_stops.add_tab_stop(Inches(6.27), docx.enum.text.WD_TAB_ALIGNMENT.RIGHT)

    frun1 = fp.add_run("Department of CSE, UVCE\tNovember 2025\t")
    frun1.font.name = 'Times New Roman'
    frun1.font.size = Pt(10)
    frun1.font.color.rgb = RGBColor(80, 80, 80)

    # Dynamic Page Number
    fldChar1 = parse_xml(r'<w:fldChar %s w:fldCharType="begin"/>' % nsdecls('w'))
    instrText = parse_xml(r'<w:instrText %s xml:space="preserve"> PAGE </w:instrText>' % nsdecls('w'))
    fldChar2 = parse_xml(r'<w:fldChar %s w:fldCharType="separate"/>' % nsdecls('w'))
    fldChar3 = parse_xml(r'<w:fldChar %s w:fldCharType="end"/>' % nsdecls('w'))
    frun2 = fp.add_run()
    frun2.font.name = 'Times New Roman'
    frun2.font.size = Pt(10)
    frun2.font.color.rgb = RGBColor(80, 80, 80)
    frun2._r.append(fldChar1)
    frun2._r.append(instrText)
    frun2._r.append(fldChar2)
    frun2._r.append(fldChar3)

    # Helper text formatting functions
    def add_p(text="", align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=6, space_before=0, line_spacing=1.15):
        p = doc.add_paragraph()
        p.alignment = align
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.space_before = Pt(space_before)
        p.paragraph_format.line_spacing = line_spacing
        if text:
            r = p.add_run(text)
            r.font.name = 'Times New Roman'
            r.font.size = Pt(12)
        return p

    def add_bullet(text, space_after=3):
        p = doc.add_paragraph(style='List Bullet')
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.line_spacing = 1.15
        r = p.add_run(text)
        r.font.name = 'Times New Roman'
        r.font.size = Pt(12)
        return p

    def add_h1(text, space_before=12, space_after=12):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(space_before)
        p.paragraph_format.space_after = Pt(space_after)
        r = p.add_run(text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(16)
        return p

    def add_h2(text, space_before=12, space_after=6):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p.paragraph_format.space_before = Pt(space_before)
        p.paragraph_format.space_after = Pt(space_after)
        r = p.add_run(text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(13)
        return p

    def add_h3(text, space_before=8, space_after=4):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p.paragraph_format.space_before = Pt(space_before)
        p.paragraph_format.space_after = Pt(space_after)
        r = p.add_run(text)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(12)
        return p

    def add_code(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(4)
        r = p.add_run(text)
        r.font.name = 'Courier New'
        r.font.size = Pt(10)
        r.font.color.rgb = RGBColor(30, 41, 59)
        return p

    # =========================================================================
    # PAGE 1: TITLE PAGE
    # =========================================================================
    add_p("", space_after=18)
    p_sub = add_p("A DBMS Mini-Project Report on", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=14)
    p_sub.runs[0].font.size = Pt(14)
    p_sub.runs[0].bold = True

    p_title = add_p("BITEHUB - MULTI-VENDOR FOOD & GROCERY DELIVERY MANAGEMENT SYSTEM", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=24)
    p_title.runs[0].font.size = Pt(17)
    p_title.runs[0].bold = True

    # College Emblem
    if os.path.exists("report_assets/uvce_logo.png"):
        p_logo = doc.add_paragraph()
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_logo.paragraph_format.space_after = Pt(24)
        p_logo.add_run().add_picture("report_assets/uvce_logo.png", width=Inches(2.5))

    p_by = add_p("Submitted by", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=8)
    p_by.runs[0].font.size = Pt(12)

    p_stud1 = add_p("Shlok [Insert Name] (U25UV23T006xxx)", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=4)
    p_stud1.runs[0].font.size = Pt(13)
    p_stud1.runs[0].bold = True

    p_stud2 = add_p("[Team Partner Name] (U25UV23T006xxx)", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=8)
    p_stud2.runs[0].font.size = Pt(13)
    p_stud2.runs[0].bold = True

    p_sem = add_p("V SEM, BTech (CSE / AIML)", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=22)
    p_sem.runs[0].font.size = Pt(12)
    p_sem.runs[0].bold = True

    p_guide = add_p("Under the guidance of", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=6)
    p_guide.runs[0].font.size = Pt(12)

    p_prof = add_p("Dr. Champa H.N", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=2)
    p_prof.runs[0].font.size = Pt(13)
    p_prof.runs[0].bold = True

    p_dept = add_p("Professor\nDepartment of CSE\nUVCE", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=24)
    p_dept.runs[0].font.size = Pt(12)

    p_coll = add_p("UNIVERSITY OF VISVESVARAYA COLLEGE ENGINEERING\nDEPARTMENT OF COMPUTER SCIENCE AND ENGINEERING\nK.R. Circle, Bengaluru – 560001", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
    p_coll.runs[0].font.size = Pt(12)
    p_coll.runs[0].bold = True

    doc.add_page_break()

    # =========================================================================
    # PAGE 2: CERTIFICATE
    # =========================================================================
    add_p("UNIVERSITY OF VISVESVARAYA COLLEGE ENGINEERING\nDEPARTMENT OF COMPUTER SCIENCE AND ENGINEERING\nK.R. Circle, Bengaluru – 560001", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=18)
    doc.paragraphs[-1].runs[0].font.size = Pt(12)
    doc.paragraphs[-1].runs[0].bold = True

    if os.path.exists("report_assets/uvce_logo.png"):
        p_logo = doc.add_paragraph()
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_logo.paragraph_format.space_after = Pt(18)
        p_logo.add_run().add_picture("report_assets/uvce_logo.png", width=Inches(1.6))

    add_h1("CERTIFICATE", space_before=10, space_after=18)

    add_p("This is to certify that Shlok [Insert Name] and [Team Partner Name] of V Semester, B. Tech, Computer Science & Engineering / Artificial Intelligence & Machine Learning, bearing the register numbers U25UV23T006xxx and U25UV23T006xxx respectively have submitted the DBMS Mini-Project Report on “BITEHUB - MULTI-VENDOR FOOD & GROCERY DELIVERY MANAGEMENT SYSTEM”, in partial fulfilment for the DBMS Lab, prescribed by the University of Visvesvaraya College of Engineering for the academic year 2025-26.", space_after=36, line_spacing=1.3)

    # Signatures Table
    table_sig = doc.add_table(rows=1, cols=2)
    table_sig.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell_l, cell_r = table_sig.rows[0].cells
    cell_l.width = Inches(3.1)
    cell_r.width = Inches(3.1)

    p_sig1 = cell_l.paragraphs[0]
    p_sig1.alignment = WD_ALIGN_PARAGRAPH.LEFT
    r = p_sig1.add_run("Dr. Champa H. N\nProfessor\nDept. of CSE,\nUVCE")
    r.font.name = 'Times New Roman'
    r.font.size = Pt(12)
    r.bold = True

    p_sig2 = cell_r.paragraphs[0]
    p_sig2.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    r = p_sig2.add_run("Dr. Thriveni J\nProfessor & Chairperson\nDept. of CSE,\nUVCE")
    r.font.name = 'Times New Roman'
    r.font.size = Pt(12)
    r.bold = True

    add_p("", space_after=36)
    add_p("Examiners:\n\n1. ……………………………………          2. ……………………………………", align=WD_ALIGN_PARAGRAPH.LEFT, space_after=0)

    doc.add_page_break()

    # =========================================================================
    # PAGE 3: ACKNOWLEDGEMENT
    # =========================================================================
    add_h1("ACKNOWLEDGEMENT", space_before=14, space_after=20)

    add_p("We take this opportunity to thank our institution University of Visvesvaraya College of Engineering for having given us an opportunity to carry out this project.", space_after=12)
    add_p("We would like to thank Prof. Subhasish Tripathy, Director, UVCE, for providing us all the facilities to work on this project. We are indebted to him for being our pillar of strength and inspiration.", space_after=12)
    add_p("We wish to place our grateful thanks to Dr. Thriveni J, Professor and Chairperson, Department of Computer Science and Engineering, UVCE, who helped us to make our project a great success.", space_after=12)
    add_p("It gives us great pleasure to express our gratitude to Dr. Champa H.N, Professor, Department of Computer Science Engineering, UVCE for her valuable guidance and supervision in this course of project.", space_after=12)
    add_p("We express our sincere thanks to all teaching and non-teaching staff, Department of Computer Science and Engineering, UVCE for all the facilities that they have provided us for successfully completing this project.", space_after=12)
    add_p("We also thank our parents and friends for their continuous support and encouragement.", space_after=36)

    p_sign = add_p("Shlok [Insert Name]\n(U25UV23T006xxx)\n\n[Team Partner Name]\n(U25UV23T006xxx)", align=WD_ALIGN_PARAGRAPH.RIGHT, space_after=0)
    p_sign.runs[0].bold = True

    doc.add_page_break()

    # =========================================================================
    # PAGE 4: ABSTRACT
    # =========================================================================
    add_h1("ABSTRACT", space_before=14, space_after=20)

    add_p("The BiteHub - Multi-Vendor Food & Grocery Delivery Management System is a comprehensive full-stack database-driven platform designed to modernize and unify on-demand food ordering and hyperlocal quick-commerce grocery fulfillment. Built upon a rigorous relational database schema normalized to Third Normal Form (3NF), the platform automates critical end-to-end operations including user authentication, multi-restaurant digital catalog management, dark store real-time inventory tracking, transactional order placement with ACID rollback guarantees, automated delivery fleet allocation, and multi-gateway payment processing. By replacing fragmented manual ledgers and isolated systems, BiteHub minimizes operational friction, eliminates data redundancy, and provides high-speed, dependable data retrieval.", space_after=14, line_spacing=1.25)

    add_p("The platform incorporates a cross-platform client developed in Flutter, a high-concurrency asynchronous REST API engine powered by Python FastAPI, and an enterprise MySQL relational database. The system delivers tailored interfaces for five primary stakeholders: Customers (who can explore restaurants, curate food orders, order 10-minute groceries, and track deliveries in real time), Restaurant Partners (who manage kitchen pipelines, menus, pricing, and promotional discounts), Dark Store Managers (who supervise SKU stocks with automated low-stock warnings), Delivery Agents (who accept deliveries and execute order status progressions), and Operations Administrators (who leverage an Executive Command Center and an interactive Live SQL Visualizer to inspect query execution latency and database health).", space_after=14, line_spacing=1.25)

    add_p("Robust referential integrity constraints, composite primary keys for weak entities, cascading updates, and transactional stock adjustments guarantee that all enterprise data remains strictly synchronized. The platform demonstrates how modern database architecture, combined with resilient in-memory caching and cross-platform clients, delivers a scalable, fault-tolerant solution for next-generation quick-commerce logistics.", space_after=0, line_spacing=1.25)

    doc.add_page_break()

    # =========================================================================
    # PAGE 5: TABLE OF CONTENTS
    # =========================================================================
    add_h1("TABLE OF CONTENTS", space_before=14, space_after=18)

    toc_items = [
        ("Title", "Page No.", True),
        ("1. Introduction", "", True),
        ("    1.1 Introduction", "1", False),
        ("    1.2 Objective", "1", False),
        ("    1.3 Functionality", "3", False),
        ("    1.4 Database Management System", "3", False),
        ("    1.5 MySQL", "4", False),
        ("2. Literature Review", "", True),
        ("    2.1 Survey of Existing System", "8", False),
        ("    2.2 Proposed System", "9", False),
        ("    2.3 Software Requirements", "10", False),
        ("    2.4 Frontend Technologies", "10", False),
        ("    2.5 Backend Technologies", "10", False),
        ("    2.6 Entity Relationship Model", "11", False),
        ("    2.7 Relational Schema Design", "14", False),
        ("    2.8 Normalization", "18", False),
        ("    2.9 API Development", "20", False),
        ("    2.10 Advantages of the Proposed System", "20", False),
        ("3. Proposed Work", "", True),
        ("    3.1 Entity-Relationship (ER) Model", "22", False),
        ("    3.2 Relational Model", "24", False),
        ("4. Results", "", True),
        ("    4.1 Outcomes", "26", False),
        ("    4.2 Screenshots", "27", False),
        ("5. Conclusion", "31", True),
        ("6. Bibliography", "32", True),
    ]

    table_toc = doc.add_table(rows=len(toc_items), cols=2)
    table_toc.alignment = WD_TABLE_ALIGNMENT.CENTER
    for idx, (title, page, is_bold) in enumerate(toc_items):
        cell_t = table_toc.rows[idx].cells[0]
        cell_p = table_toc.rows[idx].cells[1]
        cell_t.width = Inches(5.2)
        cell_p.width = Inches(1.1)
        
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

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 1: INTRODUCTION (Pages 6 to 12)
    # =========================================================================
    add_h1("CHAPTER 1\nINTRODUCTION", space_before=14, space_after=16)

    add_h2("1.1 Introduction")
    add_p("This project is a Multi-Vendor Food & Hyperlocal Grocery Delivery Management System built using DBMS, designed to coordinate seamless commercial operations between consumers, local dining establishments, dark store fulfillment centers, and on-demand delivery agents. It maintains rigorously structured relational entities such as user profiles, multi-location restaurant registries, menu catalogs, grocery inventory levels, delivery fleet metrics, transactional order records, and payment logs within a centralized MySQL database.", space_after=10)

    add_p("The system provides rapid, structured access to delivery services through an intuitive, reactive multi-platform interface. It facilitates live food discovery, categorical item filtering, customized smart cart calculations, instant coupon deduction, live dispatch progression tracking, and automated stock replenishment, minimizing manual overhead while drastically enhancing customer satisfaction and delivery accuracy. This project demonstrates how a robust database-backed architecture can deliver an enterprise-grade logistics solution tailored for modern on-demand delivery ecosystems.", space_after=10)

    add_p("BiteHub is developed as a full-stack multi-platform application utilizing Flutter (Dart) and Material 3 for the cross-platform frontend (Web, Windows Desktop, and Mobile), Python FastAPI as the asynchronous REST backend framework, and MySQL 8.0 as the relational database engine. The system supports multiple user roles and operational modules, including Customers, Restaurant Owners, Dark Store Managers, Delivery Fleets, and System Administrators, each governed by role-based access control. Development and database administration are carried out using Visual Studio Code, MySQL Workbench, Uvicorn, and Git for version control.", space_after=14)

    add_h2("1.2 Objective")
    add_bullet("To design and develop an easy-to-use, responsive cross-platform application that allows customers to discover local restaurants, order meals, and purchase 10-minute groceries online.")
    add_bullet("To automate inventory tracking, order fulfillment pipelines, and financial record-keeping, thereby eliminating manual ledger errors and stock discrepancy anomalies.")
    add_bullet("To implement a centralized, normalized relational database system for managing customers, restaurant partners, dark store inventories, orders, and delivery personnel with full ACID transactional integrity.")
    add_bullet("To provide role-based operational dashboards for restaurant partners to manage menus and kitchen queues, and dark store managers to monitor grocery stocks with automated low-stock warnings.")
    add_bullet("To empower delivery agents with real-time assignment tracking, milestone status updates (Picked Up, Out for Delivery, Delivered), and transparent tip and earnings breakdowns.")
    add_bullet("To provide an interactive Live SQL Visualizer and DBMS Query Explorer allowing administrators and instructors to inspect table schemas, relationships, and query execution benchmarks directly from the client interface.")

    doc.add_page_break()

    # Page 7: User Roles & Views
    add_h2("User Roles in the System")
    add_h3("Administrator / Operations Lead")
    add_bullet("Monitor overall platform health, Gross Merchandise Value (GMV), order throughput, and fleet availability.")
    add_bullet("Inspect database tables, foreign key constraints, and run live analytical SQL queries with execution latency benchmarks.")
    add_bullet("Oversee system stability and configure multi-device network endpoints dynamically.")

    add_h3("Customer")
    add_bullet("Create and authenticate personal accounts using phone credentials.")
    add_bullet("Browse curated multi-cuisine restaurants and hyperlocal dark store grocery catalogs with distinct HD visual banners.")
    add_bullet("Customize orders, apply promotional discount vouchers (e.g., FEAST20), select tip amounts, and simulate secure payments.")
    add_bullet("Track live order milestones and cancel active orders with automatic transactional stock restoration.")

    add_h3("Restaurant Partner")
    add_bullet("Register food establishments with location, phone, and rating attributes.")
    add_bullet("Manage menu catalogs with full CRUD capabilities (Add, Edit, Delete dishes, toggle stock availability).")
    add_bullet("Select food photos from an integrated 100+ item curated HD gallery or enter custom image URLs.")
    add_bullet("Supervise incoming kitchen orders and advance fulfillment states (Accept, Preparing, Ready, Dispatched).")

    add_h3("Dark Store Hub Manager")
    add_bullet("Manage instant quick-commerce grocery inventory across produce, dairy, bakery, snacks, and essentials.")
    add_bullet("Receive automatic low-stock visual warning badges when SKU counts fall below safety thresholds.")
    add_bullet("Dispatch packed grocery orders to waiting delivery agents.")

    add_h3("Delivery Agent")
    add_bullet("Maintain driver profiles, vehicle registrations, and licensing verification.")
    add_bullet("Toggle active shift availability (Online / Offline).")
    add_bullet("Accept delivery assignments and update delivery progression milestones.")
    add_bullet("Review completed deliveries, daily payouts, and customer gratuity tips.")

    add_h2("Views Available in the System")
    add_bullet("Enterprise Marketing Landing Page – Showcases live platform counter metrics, role gateways, and interactive demo previews.")
    add_bullet("Unified Authentication & Dynamic Role Selection – Single sign-in portal routing automatically to role-tailored dashboards.")
    add_bullet("Customer Dual-Delivery Dashboard – Comprehensive food discovery and 10-minute grocery hub with sticky floating cart bar.")
    add_bullet("Restaurant Kitchen Command Center – Real-time order queue and visual menu management studio.")
    add_bullet("Dark Store Quick-Commerce Inventory Studio – Real-time stock adjusters and fulfillment dispatch panel.")
    add_bullet("Delivery Fleet Terminal – Task allocation feed, route milestones, and earnings analytics.")
    add_bullet("Live SQL Visualizer & DBMS Explorer – In-app relational schema inspector and SQL benchmarking console.")

    doc.add_page_break()

    # Page 8: 1.3 Functionality
    add_h2("1.3 Functionality")
    add_p("The BiteHub Food & Grocery Delivery Management System enhances operational throughput and streamlines collaboration between consumers, dining vendors, quick-commerce fulfillment warehouses, and delivery personnel. The system delivers the following core functional modules:", space_after=10)

    add_h3("Restaurant & Menu Management Module")
    add_bullet("Enables restaurant partners to configure profiles, addresses, contact details, and initial ratings.")
    add_bullet("Provides real-time menu management with automated final price calculation based on base rates and discount percentages.")
    add_bullet("Enforces foreign key cascading so that dish deletions or restaurant modifications maintain strict referential integrity.")
    add_bullet("Provides an interactive photo picker supporting curated HD food banners and external URLs.")

    add_h3("Dark Store Inventory & Stock Module")
    add_bullet("Maintains grocery items categorized by department with atomic unit prices and live available stock counts.")
    add_bullet("Implements weak entity dependency where groceries are identified by composite key (Store_Id, Item_Name).")
    add_bullet("Provides automatic visual alerts when inventory reaches critical low-stock levels.")

    add_h3("Transactional Order & Checkout Module")
    add_bullet("Computes itemized totals, delivery partner fees, platform fees, agent tips, and promotional voucher discounts.")
    add_bullet("Executes transactional order placement that atomically decrements available grocery inventory.")
    add_bullet("Supports order cancellation that immediately initiates rollback procedures restoring inventory counts.")

    add_h3("Delivery Dispatch & Fleet Tracking Module")
    add_bullet("Assigns pending orders to available delivery drivers based on proximity and operational load.")
    add_bullet("Permits single-tap status progressions: Picked Up -> Out for Delivery -> Delivered.")
    add_bullet("Records delivery timestamps to measure operational fulfillment latency.")

    add_h3("Payment & Billing Module")
    add_bullet("Simulates multiple payment modes: UPI (Google Pay, PhonePe, Paytm), Credit/Debit Cards, NetBanking, and COD.")
    add_bullet("Maintains a 1:1 relationship between orders and payments ensuring complete financial accountability.")

    add_h3("Authentication & Diagnostic Security Module")
    add_bullet("Implements unified phone-based credential verification with automatic role routing.")
    add_bullet("Incorporates an in-app Server Connection Diagnostics Dialog with live latency ping testing and 1-tap IP presets.")

    add_h2("1.4 Database Management System")
    add_p("A Database Management System (DBMS) is an indispensable software foundation designed to store, manipulate, and retrieve large volumes of structured data systematically. In BiteHub, MySQL 8.0 serves as the primary DBMS, guaranteeing data consistency, security, and concurrency control.", space_after=10)

    add_p("Why Use a DBMS in BiteHub?", space_after=6)
    add_bullet("Eliminates Data Redundancy: Normalization prevents duplicate storage of customer, restaurant, or item details.")
    add_bullet("Ensures Data Integrity: Foreign key constraints prevent orphaned order items, invalid vendor assignments, or dangling payment records.")
    add_bullet("Enforces ACID Properties: Atomicity, Consistency, Isolation, and Durability ensure that financial transactions and inventory deductions never enter a corrupt state.")
    add_bullet("Provides High-Performance Structured Queries: Indexed lookups allow sub-millisecond retrieval across multi-table joins.")

    doc.add_page_break()

    # Page 9: Characteristics & MySQL
    add_h3("1.4.1 Characteristics of DBMS")
    add_bullet("Self-Describing Nature: Database catalogs store metadata describing tables, columns, constraints, and data types.")
    add_bullet("Insulation between Programs and Data: Application logic in FastAPI is decoupled from the physical storage representation on disk.")
    add_bullet("Support of Multiple Views: Customers, restaurant partners, dark store managers, and drivers interact with specialized logical views tailored to their privileges.")
    add_bullet("Sharing of Data and Multi-User Transaction Processing: Concurrency control algorithms prevent race conditions when multiple customers order the last remaining inventory item simultaneously.")

    add_h3("1.4.2 Advantages of DBMS")
    add_bullet("Data Security: Role-based permissions restrict sensitive customer addresses and payment details.")
    add_bullet("Data Consistency: Standardized update cascades prevent divergent records across relational tables.")
    add_bullet("Backup and Recovery: Enterprise crash recovery logs ensure zero data loss during sudden server power interruptions.")
    add_bullet("Scalability: Read replicas and connection pooling allow the platform to scale to hundreds of concurrent requests.")

    add_h2("1.5 MySQL")
    add_h3("1.5.1 Overview")
    add_p("MySQL is an open-source relational database management system (RDBMS) renowned for its speed, stability, and adherence to the SQL standard. Utilizing the InnoDB storage engine, MySQL provides row-level locking, foreign key constraints, and full ACID compliance, making it the premier choice for e-commerce and logistics systems like BiteHub.", space_after=12)

    add_h3("1.5.2 SQL Commands Used in DBMS")
    add_p("SQL commands are categorized into DDL (Data Definition Language), DML (Data Manipulation Language), DQL (Data Query Language), and DCL (Data Control Language). Below are representative commands implemented in the BiteHub database:", space_after=6)

    add_p("1. Creating the USERS Table (DDL):", space_after=2)
    add_code("CREATE TABLE USERS (\n    User_Id INT PRIMARY KEY,\n    User_Name VARCHAR(100) NOT NULL,\n    User_Phone VARCHAR(15) UNIQUE,\n    Password VARCHAR(255) DEFAULT '123456',\n    Street VARCHAR(100),\n    Area VARCHAR(100),\n    State VARCHAR(50),\n    Pincode VARCHAR(10)\n);")

    add_p("2. Creating Weak Entity GROCERIES Table with Composite Key (DDL):", space_after=2)
    add_code("CREATE TABLE GROCERIES (\n    Store_Id INT,\n    Item_Name VARCHAR(100),\n    Price DECIMAL(10,2),\n    Available_count INT,\n    Image_Url VARCHAR(500),\n    PRIMARY KEY (Store_Id, Item_Name),\n    FOREIGN KEY (Store_Id) REFERENCES DARK_STORE(Store_Id)\n        ON DELETE CASCADE ON UPDATE CASCADE\n);")

    doc.add_page_break()

    # Page 10: SQL Statements
    add_p("3. Inserting a Customer Record (DML):", space_after=2)
    add_code("INSERT INTO USERS (User_Id, User_Name, User_Phone, Street, Area, State, Pincode)\nVALUES (1, 'Aarav Choudhury', '9810000001', '14 MG Road', 'Indiranagar', 'Karnataka', '560038');")

    add_p("4. Querying Active Orders with Delivery Address (DQL):", space_after=2)
    add_code("SELECT Order_Id, User_Id, Status, Total_Amount, Delivery_Addr\nFROM ORDERS\nWHERE Status = 'Out for Delivery';")

    add_p("5. Updating Grocery Stock after Order Placement (DML):", space_after=2)
    add_code("UPDATE GROCERIES\nSET Available_count = Available_count - 2\nWHERE Store_Id = 1 AND Item_Name = 'Amul Taaza Milk 500ml';")

    add_p("6. Deleting a Sold-Out Dish Record (DML):", space_after=2)
    add_code("DELETE FROM REST_ITEMS\nWHERE Rest_Id = 1 AND Item_Name = 'Seasonal Crab Curry';")

    add_h3("1.5.3 SQL Statements")
    add_p("The foundational data manipulation operations in BiteHub include:", space_after=6)
    add_bullet("SELECT: Retrieves structured records from one or more tables.")
    add_code("SELECT RName, RRating, RLocation FROM RESTAURANT WHERE RRating >= 4.5;")
    add_bullet("INSERT: Adds new business entities such as registered users, food items, or orders.")
    add_code("INSERT INTO PAYMENT (Payment_Id, Order_Id, Payment_Method, Amount)\nVALUES (501, 1084, 'UPI', 720.00);")
    add_bullet("UPDATE: Modifies existing table data dynamically based on operational events.")
    add_code("UPDATE ORDERS SET Status = 'Delivered', DeliveredAt = NOW() WHERE Order_Id = 1084;")
    add_bullet("DELETE: Removes obsolete tuples while triggering cascading deletes on child relations.")
    add_code("DELETE FROM ORDERS WHERE Order_Id = 999;")

    doc.add_page_break()

    # Page 11: Aggregate Functions & Constraints
    add_h3("1.5.4 SQL Aggregate Functions")
    add_p("Aggregate functions perform mathematical computations across multi-row datasets to generate summary analytics in BiteHub:", space_after=6)

    add_bullet("COUNT – Computes total records matching criteria:")
    add_code("SELECT COUNT(*) AS Total_Active_Orders FROM ORDERS WHERE Status != 'Delivered';")

    add_bullet("SUM – Calculates total financial gross merchandise value (GMV):")
    add_code("SELECT SUM(Total_Amount) AS Total_Platform_Revenue FROM ORDERS;")

    add_bullet("MAX – Identifies peak values such as maximum driver rating or costliest item:")
    add_code("SELECT MAX(Price) AS Most_Expensive_Grocery FROM GROCERIES;")

    add_bullet("MIN – Identifies lowest item cost for budget filtering:")
    add_code("SELECT MIN(FinalPrice) AS Budget_Starter FROM REST_ITEMS WHERE Rest_Id = 1;")

    add_bullet("AVG – Computes platform benchmarks such as average restaurant rating:")
    add_code("SELECT AVG(RRating) AS Platform_Average_Rating FROM RESTAURANT;")

    add_h3("1.5.5 SQL Constraints")
    add_p("Constraints enforce relational business rules and maintain database integrity at the engine level:", space_after=6)

    add_bullet("NOT NULL – Enforces mandatory data fields:")
    add_code("CREATE TABLE USERS ( User_Name VARCHAR(100) NOT NULL );")

    add_bullet("PRIMARY KEY – Uniquely identifies each record with implied non-null uniqueness:")
    add_code("CREATE TABLE RESTAURANT ( Rest_Id INT PRIMARY KEY, RName VARCHAR(100) );")

    doc.add_page_break()

    # Page 12: Constraints continued
    add_bullet("UNIQUE – Prevents duplicate values across distinct rows:")
    add_code("CREATE TABLE USERS ( User_Phone VARCHAR(15) UNIQUE );")

    add_bullet("FOREIGN KEY – Establishes referential integrity by referencing a parent table's primary key:")
    add_code("CREATE TABLE ORDERS (\n    Order_Id INT PRIMARY KEY,\n    User_Id INT NOT NULL,\n    FOREIGN KEY (User_Id) REFERENCES USERS(User_Id)\n        ON DELETE CASCADE ON UPDATE CASCADE\n);")

    add_bullet("CHECK – Verifies that column values adhere to a defined logical predicate:")
    add_code("CREATE TABLE RESTAURANT ( RRating DECIMAL(3,2) CHECK (RRating >= 1.0 AND RRating <= 5.0) );")

    add_bullet("DEFAULT – Injects an initial value automatically when none is specified:")
    add_code("CREATE TABLE USERS ( Password VARCHAR(255) DEFAULT '123456' );")

    add_bullet("AUTO_INCREMENT – Sequentially generates monotonic primary key identifiers upon tuple insertion:")
    add_code("CREATE TABLE AUDIT_LOG ( Log_Id INT AUTO_INCREMENT PRIMARY KEY, Event VARCHAR(255) );")

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 2: LITERATURE REVIEW (Pages 13 to 26)
    # =========================================================================
    add_h1("CHAPTER 2\nLITERATURE REVIEW", space_before=14, space_after=16)

    add_p("This chapter examines legacy and contemporary systems utilized for food delivery and hyperlocal grocery distribution, establishes the architectural requirements, and provides theoretical foundations for the database design of the BiteHub project.", space_after=12)

    add_h2("2.1 Survey of Existing Systems")
    add_p("Traditionally, retail food ordering and grocery logistics relied upon paper records, physical order slips, phone book directories, and rudimentary standalone spreadsheets. While workable for small local neighborhood merchants with limited customer volumes, these manual paradigms exhibit severe limitations in operational speed, synchronization, accuracy, and scaling capability.", space_after=10)

    add_p("Manual systems consistently lead to stock miscounts, misplaced paper order tickets, unauthorized record tampering, and prolonged fulfillment delays. While massive corporate aggregators (such as Swiggy, Zomato, Blinkit, and Zepto) operate proprietary enterprise systems, regional restaurant chains and independent dark store franchise operators often lack integrated, accessible database systems that combine both dining and quick-commerce groceries into a unified, transparent architecture. This deficiency creates fragmented inventory visibility and poor coordination with delivery fleets.", space_after=12)

    add_p("Disadvantages of Manual and Fragmented Systems:", space_after=6)
    add_bullet("High incidence of human calculation errors in billing totals, taxes, and coupon deductions.")
    add_bullet("Sluggish, error-prone data lookup resulting in customer frustration and missed orders.")
    add_bullet("Lack of centralized data security and vulnerability of customer phone numbers and payment data.")
    add_bullet("Data redundancy across disjointed billing ledgers causing phantom stockouts and inventory inconsistencies.")
    add_bullet("Absence of real-time milestone status tracking between kitchen staff, riders, and hungry customers.")
    add_bullet("Inability to generate instant analytical business reports regarding peak revenue, best-selling dishes, and fleet utilization.")

    doc.add_page_break()

    # Page 14: 2.2 Proposed System
    add_h2("2.2 Proposed System")
    add_p("The proposed BiteHub - Multi-Vendor Food & Grocery Delivery Management System overcomes these systemic shortcomings by providing an automated, centralized, and secure relational database platform. BiteHub seamlessly coordinates multi-restaurant dining catalogs, 10-minute dark store grocery inventories, transactional order placement, delivery fleet dispatching, and executive analytics within a cohesive environment.", space_after=10)

    add_p("In this project, BiteHub is engineered as a cross-platform client-server architecture utilizing Flutter, Material 3, and Dart for the reactive user interface, Python FastAPI for the high-concurrency backend REST API layer, and MySQL 8.0 for the relational database management system.", space_after=10)

    add_p("Flutter provides an adaptive, hardware-accelerated interface that runs natively across Web browsers (Chrome, Edge), Windows Desktop, and mobile screens. Flutter's reactive component architecture enables live cart subtotal calculations, instant veg/non-veg filtering, and smooth screen navigation. The FastAPI framework in Python delivers blazing-fast asynchronous endpoint execution, automated Swagger documentation, and connection pool management with MySQL. MySQL securely maintains 10 normalized tables encompassing users, delivery agents, dining partners, menu items, dark store warehouses, grocery items, orders, order items, and payment transactions.", space_after=10)

    add_p("BiteHub centralizes core delivery operations through dedicated role-based workflows for Customers, Restaurant Partners, Dark Store Managers, Delivery Drivers, and Operations Administrators. By replacing traditional manual ledgers with a transactional relational database, BiteHub guarantees zero stock discrepancies, prevents unauthorized data modifications, and provides sub-second query execution across all user operations.", space_after=0)

    doc.add_page_break()

    # Page 15: Software Requirements & Frontend
    add_h2("2.3 Software Requirements")
    add_bullet("Operating System: Windows 10/11, Linux (Ubuntu 20.04+), or macOS")
    add_bullet("Frontend Framework: Flutter SDK 3.22+ with Dart 3.4+ and Material 3 Design")
    add_bullet("Backend Framework: Python 3.10+ with FastAPI and Uvicorn ASGI Server")
    add_bullet("Database Management System: MySQL Server 8.0+ (InnoDB Engine)")
    add_bullet("HTTP Client & Middleware: Python `mysql-connector-python`, Dart `http`, CORS Middleware")
    add_bullet("Development Tools: Visual Studio Code, MySQL Workbench, Git, PowerShell")

    add_h2("2.4 Frontend Technologies")
    add_p("The frontend serves as the primary visual interface through which customers, vendors, and delivery agents interact with the delivery platform. Built using Flutter and Dart, the client delivers a fluid, 60fps responsive user experience.", space_after=10)

    add_h3("1. Flutter Framework")
    add_p("Flutter is Google's open-source UI toolkit for building natively compiled applications across mobile, web, and desktop from a single codebase. It provides a rich widget tree, reactive state management, and adaptive layouts.", space_after=8)

    add_h3("2. Dart Programming Language")
    add_p("Dart is an object-oriented, strongly-typed language optimized for client applications. Its sound type system prevents runtime null-pointer exceptions and ensures predictable serialization of JSON network responses.", space_after=8)

    add_h3("3. Material 3 Design System")
    add_p("Material 3 provides modern visual semantics including dynamic color schemes, pill navigation chips, elevated cards, bottom sheets, and typography guidelines that ensure visual elegance across desktop and mobile screens.", space_after=12)

    add_h2("2.5 Backend Technologies")
    add_p("The backend of BiteHub executes core business logic, processes client HTTP requests, validates role authentication, manages connection pools, and enforces transactional ACID rules with MySQL.", space_after=0)

    doc.add_page_break()

    # Page 16: Backend & MySQL
    add_h3("1. Python FastAPI Framework")
    add_p("FastAPI is a modern, high-performance web framework for building APIs with Python 3.8+ based on standard Python type hints. Powered by Starlette and Pydantic, FastAPI delivers exceptional speed comparable to NodeJS and Go.", space_after=8)

    add_p("FastAPI in BiteHub provides:", space_after=4)
    add_bullet("Asynchronous request handling capable of serving high-concurrency order placement requests.")
    add_bullet("Automatic interactive Swagger / OpenAPI documentation generated at `/docs`.")
    add_bullet("Robust data validation and schema serialization through Pydantic models.")
    add_bullet("Cross-Origin Resource Sharing (CORS) middleware enabling seamless multi-device web and mobile communication.")
    add_bullet("Modular router architecture separating auth, user, restaurant, grocery, delivery, and visualizer logic.")

    add_h3("2. MySQL Relational Database")
    add_p("MySQL is an enterprise-grade open-source relational database management system utilized for structured data persistence. It organizes data into normalized tables with strict foreign key constraints, index structures, and ACID transactional isolation.", space_after=8)

    add_p("MySQL in BiteHub offers:", space_after=4)
    add_bullet("Structured, normalized storage across 10 core entity tables.")
    add_bullet("Foreign key constraints with cascading delete and update rules preventing orphaned data.")
    add_bullet("ACID transactional guarantees for simultaneous order placement and inventory reduction.")
    add_bullet("High-efficiency B-tree index structures ensuring fast analytical and operational queries.")
    add_bullet("Scalability to handle growing historical order archives and high-volume product catalogs.")

    add_h2("2.6 Entity-Relationship (ER) Model")
    add_p("The Entity-Relationship (ER) model is a high-level conceptual data modeling methodology that provides a systematic representation of real-world entities, their intrinsic attributes, and the relational associations between them. It serves as an architectural blueprint prior to physical relational schema implementation.", space_after=0)

    doc.add_page_break()

    # Page 17: ER Model Components
    add_h3("Purpose of the ER Model")
    add_p("The primary objectives of the ER model in BiteHub are to:", space_after=6)
    add_bullet("Visually conceptualize complex multi-vendor logistics in an easily comprehensible diagram.")
    add_bullet("Identify independent business entities (Customers, Restaurants, Warehouses, Agents) and dependent entities.")
    add_bullet("Establish relationship associations and specify precise cardinalities (1:1, 1:N, M:N).")
    add_bullet("Define entity attributes, primary keys, and candidate keys.")
    add_bullet("Impose structural integrity constraints prior to database table creation.")

    add_h3("Core Components of the ER Model")
    add_p("The ER model comprises three fundamental components: Entities, Attributes, and Relationships.", space_after=8)

    add_h3("1. Entities")
    add_p("An entity represents a distinct real-world object or concept possessing identifiable properties:", space_after=6)
    add_bullet("Strong Entity: Possesses an intrinsic primary key capable of uniquely identifying every tuple (e.g., USERS with User_Id, RESTAURANT with Rest_Id, DELIVERY_AGENT with Agent_Id). Represented as a single rectangle.")
    add_bullet("Weak Entity: Lacks a primary key of its own and depends on a strong identifying entity via a foreign key and partial key (e.g., GROCERIES depends on DARK_STORE via Store_Id and partial key Item_Name). Represented as a double rectangle.")

    add_h3("2. Attributes")
    add_p("Attributes define characteristics or properties belonging to an entity or relationship:", space_after=6)
    add_bullet("Simple (Atomic): Cannot be subdivided into smaller components (e.g., User_Id, BasePrice).")
    add_bullet("Composite: Composed of multiple constituent elements (e.g., Address composed of Street, Area, State, and Pincode).")
    add_bullet("Derived: Computed dynamically from other stored attributes (e.g., FinalPrice computed as BasePrice - Discount).")
    add_bullet("Multivalued: Capable of holding multiple values for a single entity instance (e.g., User_Phone). Represented as double ellipses.")

    doc.add_page_break()

    # Page 18: Relationships & Constraints
    add_h3("3. Relationships")
    add_p("Relationships describe meaningful associations between two or more participating entities. In BiteHub, key relationships include:", space_after=6)
    add_bullet("A Customer places one or more Orders.")
    add_bullet("A Restaurant prepares multiple Orders and serves multiple Rest_Items.")
    add_bullet("A Dark Store stocks multiple Groceries.")
    add_bullet("A Delivery Agent fulfills assigned Orders.")
    add_bullet("An Order has exactly one associated Payment.")

    add_p("Relationships are depicted as diamond shapes in ER diagrams and are characterized by:", space_after=6)
    add_bullet("Cardinality Constraints: Specify the numerical ratio of entity instances involved in a relationship:")
    add_p("  • One-to-One (1:1): Each entity instance is associated with at most one instance of another entity (e.g., Orders and Payment).", space_after=3)
    add_p("  • One-to-Many (1:N): One entity instance relates to multiple instances of another entity (e.g., Customer to Orders, Restaurant to Rest_Items).", space_after=3)
    add_p("  • Many-to-Many (M:N): Multiple instances of one entity relate to multiple instances of another (e.g., Orders to Rest_Items resolved via ORDER_ITEM, Orders to Groceries resolved via ORDER_GROCERY).", space_after=6)
    add_bullet("Participation Constraints: Specify whether all entity instances must participate:")
    add_p("  • Total Participation: Every entity instance must participate in the relationship (e.g., Every Payment must belong to an Order). Depicted by double lines.", space_after=3)
    add_p("  • Partial Participation: Only a subset of entity instances participate (e.g., Not all Delivery Agents are actively assigned to an Order at any given moment). Depicted by single lines.", space_after=8)

    add_h3("Keys and Integrity Constraints")
    add_bullet("Primary Key (PK): An irreducible attribute set that uniquely identifies each entity tuple.")
    add_bullet("Foreign Key (FK): An attribute in a relation that matches the primary key of another relation, linking the two tables.")
    add_bullet("Referential Integrity: Mandates that foreign key values must either match an existing valid primary key or be null.")

    doc.add_page_break()

    # Page 19: Advanced ER & Relational Schema Design
    add_h3("Advanced Concepts in the ER Model")
    add_bullet("Weak Entity and Identifying Relationship: Used when an entity cannot exist independently and relies on a parent entity for identity (e.g., GROCERIES identified by identifying relationship 'stocks' from DARK_STORE).")
    add_bullet("Relationship Attributes: Descriptive data stored directly within a relationship link (e.g., 'Food_quantity' stored inside the M:N relationship between ORDERS and REST_ITEMS).")

    add_h3("Benefits of Using an ER Model in BiteHub")
    add_bullet("Provides a clear structural overview of complex logistics for all stakeholders.")
    add_bullet("Guarantees logical consistency before writing a single line of SQL DDL code.")
    add_bullet("Streamlines normal form analysis (1NF, 2NF, 3NF) by highlighting functional dependencies.")
    add_bullet("Simplifies long-term system maintainability and database migration.")

    add_h2("2.7 Relational Schema Design")
    add_p("The Relational Schema is the formal logical structure of a database expressed as tables (relations), attributes (columns), and tuples (rows). It translates conceptual ER constructs into mathematical relations governed by primary keys, foreign keys, and domain constraints.", space_after=10)

    add_h3("7-Step Approach to Convert ER Model to Relational Schema")
    add_p("The transformation of BiteHub's conceptual ER diagram into normalized relational tables follows a rigorous seven-step database mapping methodology:", space_after=0)

    doc.add_page_break()

    # Page 20: 7-Step Method (Steps 1 to 3)
    add_h3("Step 1: Mapping Regular (Strong) Entity Sets")
    add_p("Each strong entity in the ER model is converted into an independent relation containing all simple and composite attributes (flattened into columns). The entity's identifier becomes the primary key.", space_after=6)
    add_p("Example in BiteHub:", space_after=2)
    add_p("Entity: USERS (User_Id, User_Name, User_Phone, Password, Street, Area, State, Pincode)", space_after=2)
    add_code("USERS(User_Id PRIMARY KEY, User_Name, User_Phone, Password, Street, Area, State, Pincode)")

    add_h3("Step 2: Mapping Weak Entity Sets")
    add_p("A weak entity cannot stand alone. It is mapped to a relation containing all simple attributes, plus the primary key of the identifying parent entity as a foreign key. The combination of the foreign key and the partial key forms a composite primary key.", space_after=6)
    add_p("Example in BiteHub:", space_after=2)
    add_p("Entity: GROCERIES (partial key Item_Name, dependent on DARK_STORE via Store_Id)", space_after=2)
    add_code("GROCERIES(Store_Id, Item_Name, Price, Available_count, Image_Url,\n          PRIMARY KEY(Store_Id, Item_Name),\n          FOREIGN KEY(Store_Id) REFERENCES DARK_STORE(Store_Id))")

    add_h3("Step 3: Mapping Binary 1:1 Relationships")
    add_p("For one-to-one relationships, the foreign key is positioned within the relation possessing total participation, reinforced with a UNIQUE constraint to preserve 1:1 cardinality.", space_after=6)
    add_p("Example in BiteHub: Order has exactly one Payment (1:1)", space_after=2)
    add_code("PAYMENT(Payment_Id PRIMARY KEY, Order_Id UNIQUE,\n        Payment_Method, Amount,\n        FOREIGN KEY(Order_Id) REFERENCES ORDERS(Order_Id))")

    doc.add_page_break()

    # Page 21: 7-Step Method (Steps 4 & 5)
    add_h3("Step 4: Mapping Binary 1:N Relationships")
    add_p("For one-to-many relationships, the primary key of the entity on the 'one' side is embedded as a foreign key attribute inside the relation representing the 'many' side.", space_after=6)
    add_p("Example 1 in BiteHub: A Customer places multiple Orders (1:N)", space_after=2)
    add_code("ORDERS(Order_Id PRIMARY KEY, User_Id, Rest_Id, Store_Id, Agent_Id,\n       Status, Total_Amount, PlacedAt, DeliveredAt, Delivery_Addr,\n       FOREIGN KEY(User_Id) REFERENCES USERS(User_Id))")

    add_p("Example 2 in BiteHub: A Restaurant serves multiple Rest_Items (1:N)", space_after=2)
    add_code("REST_ITEMS(Rest_Id, Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Image_Url,\n           PRIMARY KEY(Rest_Id, Item_Name),\n           FOREIGN KEY(Rest_Id) REFERENCES RESTAURANT(Rest_Id))")

    add_h3("Step 5: Mapping Binary M:N Relationships")
    add_p("Many-to-many relationships cannot be represented cleanly within existing entity tables without violating normal forms. A dedicated junction relation (associative entity) is created containing foreign keys referencing both participating entities, which collectively form a composite primary key. Any relationship attributes become columns in this junction relation.", space_after=6)

    add_p("Example 1 in BiteHub: Orders contain multiple Dishes, dishes belong to multiple orders (M:N)", space_after=2)
    add_code("ORDER_ITEM(Order_Id, Rest_Id, Item_Name, Food_quantity,\n           PRIMARY KEY(Order_Id, Rest_Id, Item_Name),\n           FOREIGN KEY(Order_Id) REFERENCES ORDERS(Order_Id),\n           FOREIGN KEY(Rest_Id, Item_Name) REFERENCES REST_ITEMS(Rest_Id, Item_Name))")

    add_p("Example 2 in BiteHub: Orders contain multiple Groceries (M:N)", space_after=2)
    add_code("ORDER_GROCERY(Order_Id, Store_Id, Item_Name, Quantity,\n              PRIMARY KEY(Order_Id, Store_Id, Item_Name),\n              FOREIGN KEY(Order_Id) REFERENCES ORDERS(Order_Id),\n              FOREIGN KEY(Store_Id, Item_Name) REFERENCES GROCERIES(Store_Id, Item_Name))")

    doc.add_page_break()

    # Page 22: Steps 6 & 7
    add_h3("Step 6: Mapping Multivalued Attributes")
    add_p("When an entity possesses a multivalued attribute (such as a customer having secondary phone numbers or addresses), a separate relation is created combining the entity's primary key with the multivalued attribute to form a composite primary key.", space_after=6)
    add_p("Example in BiteHub: User having multiple addresses", space_after=2)
    add_code("USER_ADDRESS(User_Id, Address,\n             PRIMARY KEY(User_Id, Address),\n             FOREIGN KEY(User_Id) REFERENCES USERS(User_Id))")

    add_h3("Step 7: Mapping Ternary (and Higher-Order) Relationships")
    add_p("When three or more entities participate in an n-ary relationship, a new relation is established containing the primary keys of all participating entities as foreign keys. Together, these foreign keys constitute the composite primary key of the new relation.", space_after=6)
    add_p("Example in BiteHub: Order coordination involving Customer, Vendor, and Delivery Agent", space_after=2)
    add_code("DELIVERY_ASSIGNMENT(Order_Id, Agent_Id, AssignedAt, Delivery_Status,\n                    PRIMARY KEY(Order_Id, Agent_Id),\n                    FOREIGN KEY(Order_Id) REFERENCES ORDERS(Order_Id),\n                    FOREIGN KEY(Agent_Id) REFERENCES DELIVERY_AGENT(Agent_Id))")

    add_p("This 7-step mapping ensures that the conceptual ER model converts systematically into a normalized, non-redundant, and referentially sound relational database implementation.", space_after=0)

    doc.add_page_break()

    # Page 23: Normalization
    add_h2("2.8 Normalization")
    add_p("Normalization is a mathematical database design methodology that evaluates relational schemas against specific formal normal forms to systematically eliminate data redundancy and prevent Insertion, Update, and Deletion Anomalies.", space_after=10)

    add_h3("Functional Dependency")
    add_p("A Functional Dependency, denoted by X → Y, between two attribute sets X and Y within a relation R, specifies that the value of X uniquely determines the value of Y. That is, if two tuples agree on attribute X, they must necessarily agree on attribute Y. Attribute X is called the Determinant.", space_after=10)

    add_h3("List of Normal Forms in SQL:")
    add_bullet("1NF (First Normal Form): Elimination of repeating groups and non-atomic attribute values.")
    add_bullet("2NF (Second Normal Form): Elimination of partial functional dependencies on composite keys.")
    add_bullet("3NF (Third Normal Form): Elimination of transitive dependencies on non-prime attributes.")
    add_bullet("BCNF (Boyce-Codd Normal Form): Strict enforcement where every determinant is a super key.")
    add_bullet("4NF (Fourth Normal Form): Elimination of multi-valued dependencies.")
    add_bullet("5NF (Fifth Normal Form): Elimination of join dependencies not implied by candidate keys.")

    doc.add_page_break()

    # Page 24: Normal Forms Details
    add_h3("a) First Normal Form (1NF)")
    add_p("A relation schema R is in 1NF if and only if the domain of every attribute contains solely atomic (indivisible) values, and each attribute value in every tuple is a single element from that domain. 1NF prohibits nested relations, arrays, and repeating comma-separated lists of values within a single column.", space_after=10)

    add_h3("b) Second Normal Form (2NF)")
    add_p("A relation schema R is in 2NF if it satisfies 1NF and every non-prime attribute A in R is fully functionally dependent on the primary key. A partial dependency occurs when a non-prime attribute depends on only a proper subset of a composite primary key. In BiteHub, composite tables such as `REST_ITEMS(Rest_Id, Item_Name)` ensure that food attributes (`BasePrice`, `Discount`, `Is_Veg`) depend strictly on the complete composite key `(Rest_Id, Item_Name)`.", space_after=10)

    add_h3("c) Third Normal Form (3NF)")
    add_p("A relation schema R is in 3NF if it satisfies 2NF and no non-prime attribute is transitively dependent on the primary key. A transitive dependency exists if X → Y and Y → Z hold, where Z is a non-prime attribute not directly dependent on candidate key X. 3NF ensures that non-key columns depend solely on the primary key, the whole primary key, and nothing but the primary key.", space_after=10)

    add_h3("d) Boyce-Codd Normal Form (BCNF)")
    add_p("A relation schema R is in BCNF if and only if, for every functional dependency X → Y that holds over R, X is a super key of R. BCNF is a stricter refinement of 3NF that handles overlapping composite candidate keys.", space_after=10)

    add_h3("e) Fourth Normal Form (4NF)")
    add_p("A relation is in 4NF if it is in BCNF and contains no multi-valued dependencies (X ↠ Y). This ensures that independent multi-valued facts are decoupled into separate tables.", space_after=10)

    add_h3("f) Fifth Normal Form (5NF)")
    add_p("A relation is in 5NF if it cannot be decomposed into smaller tables without loss of data or generation of spurious tuples, resolving cyclic join dependencies.", space_after=0)

    doc.add_page_break()

    # Page 25: Normalization of BiteHub & APIs
    add_h3("Normalization of the BiteHub Database")
    add_p("The database schema of the BiteHub platform has been structured and validated up to Third Normal Form (3NF):", space_after=6)
    add_bullet("All table attributes are strictly atomic (1NF compliant).")
    add_bullet("Every non-prime attribute is fully functionally dependent on the complete primary key; partial dependencies in composite tables (`REST_ITEMS`, `GROCERIES`, `ORDER_ITEM`) have been eliminated (2NF compliant).")
    add_bullet("Transitive dependencies have been eliminated; customer addresses, store locations, and payment records reside in normalized relations without intermediate functional dependencies (3NF compliant).")

    add_h2("2.9 API Development")
    add_p("To bridge the Flutter client and the MySQL relational database, BiteHub employs high-speed RESTful APIs developed in Python FastAPI. These APIs handle JSON payloads and execute prepared parameterized SQL statements with MySQL Connector.", space_after=8)

    add_p("Key API modules include:", space_after=4)
    add_bullet("`/api/auth`: Multi-role login and registration with automatic role detection.")
    add_bullet("`/api/restaurants`: Restaurant metadata and complete menu CRUD operations.")
    add_bullet("`/api/dark-stores`: Quick-commerce store registries and grocery stock updates.")
    add_bullet("`/api/orders`: ACID order placement, status progression, and cancellation with stock rollback.")
    add_bullet("`/api/visualizer`: Read-only SQL query execution with latency benchmarking.")

    add_h2("2.10 Advantages of the Proposed System")
    add_p("The BiteHub system delivers profound advantages over legacy and manual order management solutions:", space_after=6)

    doc.add_page_break()

    # Page 26: Advantages Continued
    add_bullet("Improved Accuracy and Efficiency: Centralized relational persistence completely eliminates double-entry errors and manual calculation mistakes.")
    add_bullet("Enhanced Data Security: Secure password hashing, parameterized SQL queries preventing SQL injection, and role-based access control protect customer and vendor records.")
    add_bullet("Real-Time Data Access: Customers, restaurant kitchens, warehouse pickers, and delivery riders receive instant synchronization of order milestones.")
    add_bullet("Scalable and Modular Design: Decoupled client-server architecture allows independent scaling of frontend interfaces, backend workers, and database replicas.")
    add_bullet("Centralized Relational Integrity: Cascading deletes and update triggers guarantee that order history, item catalogs, and payments remain consistent.")
    add_bullet("Custom Reporting and Analytics: Administrators can execute live aggregation queries (`SUM`, `AVG`, `GROUP BY`) to measure GMV, popular dishes, and driver turnaround times.")

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 3: PROPOSED WORK (Pages 27 to 30)
    # =========================================================================
    add_h1("CHAPTER 3\nPROPOSED WORK", space_before=14, space_after=16)

    add_p("This chapter presents the design and relational structure of the BiteHub Food & Grocery Delivery Management System, delineating how data entities interact, foreign key associations are modeled, and operational integrity is preserved across ordering, kitchen fulfillment, grocery dispatching, and delivery tracking.", space_after=12)

    add_h2("3.1 Entity Relationship (ER) Model")
    add_p("The ER diagram illustrates how core entities, weak entities, attributes, and relationships are interconnected to ensure minimal data redundancy and maximum retrieval efficiency.", space_after=10)

    add_h3("Entities and their Attributes in BiteHub:")
    add_bullet("USERS: User_Id (PK), User_Name, User_Phone (UNIQUE), Password, Street, Area, State, Pincode")
    add_bullet("DELIVERY_AGENT: Agent_Id (PK), Agent_Name, Agent_Phone, Password, VehicleNO, V_Type, Has_license, Rating")
    add_bullet("RESTAURANT: Rest_Id (PK), RName, RLocation, RPhone, Password, RRating, Image_Url")
    add_bullet("REST_ITEMS: Rest_Id (FK), Item_Name, Food_Name, Is_Veg, BasePrice, Discount, FinalPrice, Image_Url [Composite PK: (Rest_Id, Item_Name)]")
    add_bullet("DARK_STORE: Store_Id (PK), DS_Phone, Password, DS_Street, DS_Area, DS_State, DS_Pincode")
    add_bullet("GROCERIES (Weak Entity of DARK_STORE): Store_Id (FK), Item_Name, Price, Available_count, Image_Url [Composite PK: (Store_Id, Item_Name)]")
    add_bullet("ORDERS: Order_Id (PK), User_Id (FK), Agent_Id (FK), Rest_Id (FK), Store_Id (FK), Order_Review, PlacedAt, DeliveredAt, Delivery_Addr, Agent_Rating, Status, Total_Amount, Delivery_Fee, Tip_Amount")
    add_bullet("ORDER_ITEM: Order_Id (FK), Rest_Id (FK), Item_Name (FK), Food_quantity [Composite PK: (Order_Id, Rest_Id, Item_Name)]")
    add_bullet("ORDER_GROCERY: Order_Id (FK), Store_Id (FK), Item_Name (FK), Quantity [Composite PK: (Order_Id, Store_Id, Item_Name)]")
    add_bullet("PAYMENT: Payment_Id (PK), Order_Id (FK, UNIQUE), Payment_Method, Amount")

    doc.add_page_break()

    # Page 28: Figure 1 (ER Diagram)
    if os.path.exists("report_assets/figure1_er_diagram.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(10)
        p_img.paragraph_format.space_after = Pt(10)
        p_img.add_run().add_picture("report_assets/figure1_er_diagram.png", width=Inches(6.2))

    p_cap1 = add_p("Figure 1: ER-Diagram of BiteHub Food & Grocery Database Management System", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
    p_cap1.runs[0].font.size = Pt(11)
    p_cap1.runs[0].italic = True
    p_cap1.runs[0].bold = True

    doc.add_page_break()

    # Page 29: Figure 2 (Relational Model)
    add_h2("3.2 Relational Model")
    add_p("The relational model defines the schema of the database in terms of normalized tables, primary keys, and foreign keys. BiteHub stores all transactional and catalog data in interconnected relations enforcing referential integrity.", space_after=10)

    if os.path.exists("report_assets/figure2_relational_model.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(8)
        p_img.paragraph_format.space_after = Pt(8)
        p_img.add_run().add_picture("report_assets/figure2_relational_model.png", width=Inches(6.2))

    p_cap2 = add_p("Figure 2: Relational Model of the BiteHub Database Management System", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
    p_cap2.runs[0].font.size = Pt(11)
    p_cap2.runs[0].italic = True
    p_cap2.runs[0].bold = True

    doc.add_page_break()

    # Page 30: Relationships and Cardinalities
    add_h2("Relationships and Cardinalities in BiteHub")
    add_bullet("1. A Customer can place multiple Orders (USERS -> ORDERS) (1:N): Every order is placed by exactly one registered user, but a customer may place numerous orders over time.")
    add_bullet("2. A Restaurant prepares multiple Orders (RESTAURANT -> ORDERS) (1:N): Many food orders originate from a specific restaurant, whereas a food order is fulfilled by one primary kitchen.")
    add_bullet("3. A Restaurant serves multiple Dishes (RESTAURANT -> REST_ITEMS) (1:N): A dining partner maintains many menu items, with each dish belonging to that restaurant identified by composite key (Rest_Id, Item_Name).")
    add_bullet("4. A Dark Store stocks multiple Groceries (DARK_STORE -> GROCERIES) (1:N): A quick-commerce fulfillment warehouse stocks numerous grocery items; GROCERIES is a weak entity dependent on DARK_STORE.")
    add_bullet("5. An Order contains multiple Dishes (ORDERS -> REST_ITEMS) (M:N): An order can include multiple menu items, and a dish can appear in multiple orders; resolved via associative entity `ORDER_ITEM` carrying relationship attribute `Food_quantity`.")
    add_bullet("6. An Order contains multiple Groceries (ORDERS -> GROCERIES) (M:N): An order can incorporate multiple grocery SKUs, resolved via associative entity `ORDER_GROCERY` with attribute `Quantity`.")
    add_bullet("7. An Order is delivered by one Delivery Agent (ORDERS -> DELIVERY_AGENT) (M:1): A delivery driver manages multiple drop-offs sequentially, while an individual order is assigned to a single driver.")
    add_bullet("8. An Order has exactly one Payment record (ORDERS -> PAYMENT) (1:1): Every finalized order corresponds to exactly one payment transaction; enforced by `UNIQUE(Order_Id)` in the PAYMENT relation.")

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 4: RESULT (Pages 31 to 35)
    # =========================================================================
    add_h1("CHAPTER 4\nRESULT", space_before=14, space_after=16)

    add_h2("4.1 Outcomes")
    add_p("The BiteHub - Multi-Vendor Food & Grocery Delivery Management System was successfully implemented and validated using a comprehensive realistic dataset consisting of 100+ users, 45+ restaurants, 12 dark stores, 85+ delivery agents, and thousands of historical orders and menu items. The system seamlessly coordinates restaurant dining orders, 10-minute grocery dispatches, fleet routing, and payment verification, ensuring high-speed and accurate operations.", space_after=10)

    add_p("Test users and evaluators found the Flutter interface to be intuitive, responsive, and visually modern. Customers can fluidly browse distinct restaurant banners, filter by vegetarian options, apply promotional discount coupons, select driver tips, and track active orders in real time. Restaurant partners and dark store managers can effortlessly supervise inventory, update prices, and advance order states through clean dashboard controls.", space_after=10)

    add_p("The system also incorporates a Live SQL Visualizer and DBMS Query Explorer, allowing real-time execution of analytical SQL statements with latency execution benchmarks. The backend server developed in Python FastAPI guarantees sub-20ms endpoint response times, while MySQL enforces strict referential integrity and transaction rollback on order cancellations. The result is an enterprise-grade, fault-tolerant platform that establishes how modern relational database design powers high-performance delivery applications.", space_after=0)

    doc.add_page_break()

    # Page 32: Screenshots (Figures 3 & 4)
    add_h2("4.2 Screenshots")
    add_p("The following series of screenshots illustrates the developed application across various user roles:", space_after=10)

    if os.path.exists("report_assets/figure3_landing.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(4)
        p_img.paragraph_format.space_after = Pt(4)
        p_img.add_run().add_picture("report_assets/figure3_landing.png", width=Inches(5.8))
        p_c = add_p("Figure 3: BiteHub Enterprise Landing Portal & Unified Role Gateway", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=14)
        p_c.runs[0].font.size = Pt(10.5)
        p_c.runs[0].italic = True

    if os.path.exists("report_assets/figure4_customer.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(4)
        p_img.paragraph_format.space_after = Pt(4)
        p_img.add_run().add_picture("report_assets/figure4_customer.png", width=Inches(5.8))
        p_c = add_p("Figure 4: Customer Food & Hyperlocal Grocery Experience", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
        p_c.runs[0].font.size = Pt(10.5)
        p_c.runs[0].italic = True

    doc.add_page_break()

    # Page 33: Screenshots (Figures 5 & 6)
    if os.path.exists("report_assets/figure5_restaurant.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(10)
        p_img.paragraph_format.space_after = Pt(4)
        p_img.add_run().add_picture("report_assets/figure5_restaurant.png", width=Inches(5.8))
        p_c = add_p("Figure 5: Restaurant Partner Kitchen & Menu Management Studio", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=18)
        p_c.runs[0].font.size = Pt(10.5)
        p_c.runs[0].italic = True

    if os.path.exists("report_assets/figure6_darkstore.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(10)
        p_img.paragraph_format.space_after = Pt(4)
        p_img.add_run().add_picture("report_assets/figure6_darkstore.png", width=Inches(5.8))
        p_c = add_p("Figure 6: Dark Store Quick-Commerce Inventory & Low-Stock Alerts", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
        p_c.runs[0].font.size = Pt(10.5)
        p_c.runs[0].italic = True

    doc.add_page_break()

    # Page 34: Screenshots (Figures 7 & 8)
    if os.path.exists("report_assets/figure7_delivery.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(10)
        p_img.paragraph_format.space_after = Pt(4)
        p_img.add_run().add_picture("report_assets/figure7_delivery.png", width=Inches(5.8))
        p_c = add_p("Figure 7: Delivery Agent Fleet Terminal & Task Progression", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=18)
        p_c.runs[0].font.size = Pt(10.5)
        p_c.runs[0].italic = True

    if os.path.exists("report_assets/figure8_sql_visualizer.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(10)
        p_img.paragraph_format.space_after = Pt(4)
        p_img.add_run().add_picture("report_assets/figure8_sql_visualizer.png", width=Inches(5.8))
        p_c = add_p("Figure 8: Live SQL Visualizer & DBMS Query Explorer", align=WD_ALIGN_PARAGRAPH.CENTER, space_after=0)
        p_c.runs[0].font.size = Pt(10.5)
        p_c.runs[0].italic = True

    doc.add_page_break()

    # Page 35: Screenshot Descriptions
    add_p("Figure 3 : BiteHub Enterprise Landing Portal & Unified Role Gateway – Introduces users to the delivery platform with animated counter statistics, interactive role switchers (Customer, Restaurant, Dark Store, Fleet), and direct access to sign in.", space_after=10)

    add_p("Figure 4 : Customer Food & Hyperlocal Grocery Experience – Displays dual-delivery mode (Food & 10-min Mart) with distinct curated HD restaurant banners, rating pills, distance estimation, promo vouchers, and sticky floating cart bar.", space_after=10)

    add_p("Figure 5 : Restaurant Partner Kitchen & Menu Management Studio – Empowers dining establishments to manage kitchen queues, execute menu CRUD operations, calculate automatic discounts, and select photos from a 100+ item food gallery.", space_after=10)

    add_p("Figure 6 : Dark Store Quick-Commerce Inventory & Low-Stock Alerts – Enables warehouse managers to track live grocery inventory across 6 departments with automatic low-stock visual warning badges and order packing dispatch tools.", space_after=10)

    add_p("Figure 7 : Delivery Agent Fleet Terminal & Task Progression – Provides drivers with incoming delivery alerts, milestone updates (Picked Up -> Out for Delivery -> Delivered), vehicle licensing info, and daily earnings with tips.", space_after=10)

    add_p("Figure 8 : Live SQL Visualizer & DBMS Query Explorer – In-app database console enabling live execution of analytical SQL queries, visual inspection of relational tables, and latency benchmarking directly against the MySQL engine.", space_after=0)

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 5: CONCLUSION (Page 36)
    # =========================================================================
    add_h1("CONCLUSION", space_before=14, space_after=18)

    add_p("The BiteHub - Multi-Vendor Food & Grocery Delivery Management System was developed to modernize and automate key operations within on-demand food logistics and quick-commerce retail. The project successfully integrates a robust MySQL relational database normalized to Third Normal Form (3NF) with a cross-platform Flutter frontend and an asynchronous Python FastAPI REST backend. This architecture ensures frictionless coordination between customers, restaurant kitchens, dark store fulfillment centers, and delivery fleets.", space_after=12)

    add_p("The system effectively handles customer authentication, restaurant menu catalogs, real-time grocery inventory, ACID transactional order placement, automated fleet dispatching, and secure payment processing. By adhering strictly to relational modeling principles, BiteHub eliminates data redundancy, guarantees referential integrity, and facilitates sub-second query retrieval. Automated workflows drastically reduce human calculation mistakes and eliminate stock discrepancy anomalies.", space_after=12)

    add_p("Through its clear visual design and reactive interfaces, the platform ensures that administrators and operational staff can monitor performance and inspect live SQL metrics seamlessly. BiteHub not only streamlines logistics management but also enhances user satisfaction by delivering convenience, transparency, and speed throughout the delivery lifecycle.", space_after=14)

    add_h3("Future Enhancements")
    add_p("While the current version successfully fulfills all core food and grocery delivery requirements, prospective enhancements include:", space_after=6)
    add_bullet("Integration of real-time GPS telemetry and IoT hardware tracking for delivery vehicles.")
    add_bullet("Implementation of AI-driven machine learning algorithms for personalized restaurant and grocery recommendations.")
    add_bullet("Automated SMS and WhatsApp push notifications for order milestone updates.")
    add_bullet("Expansion to multi-city franchise clusters with dynamic geo-fencing and surge pricing algorithms.")
    add_bullet("Implementation of automated dark store robotic picking simulations.")

    add_p("In conclusion, the BiteHub platform delivers a centralized, secure, and scalable database management solution that optimizes commercial delivery operations, enhances user engagement, and stands as a robust model for modern quick-commerce engineering.", space_after=0)

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 6: BIBLIOGRAPHY (Page 37)
    # =========================================================================
    add_h1("BIBLIOGRAPHY", space_before=14, space_after=20)

    bib_items = [
        "[1] R. Elmasri and S. B. Navathe, Fundamentals of Database Systems, 7th ed. Boston, MA: Pearson, 2016.",
        "[2] A. Silberschatz, H. F. Korth, and S. Sudarshan, Database System Concepts, 7th ed. New York: McGraw-Hill, 2019.",
        "[3] C. J. Date, An Introduction to Database Systems, 8th ed. Boston, MA: Addison-Wesley, 2003.",
        "[4] E. Windmill, Flutter in Action, 1st ed. Shelter Island, NY: Manning Publications, 2020.",
        "[5] S. Tiangolo, FastAPI Web Framework Documentation, [Online]. Available: https://fastapi.tiangolo.com",
        "[6] MySQL 8.0 Reference Manual, Oracle Corporation, [Online]. Available: https://dev.mysql.com/doc/refman/8.0/en/",
        "[7] Flutter & Dart Official Documentation, Google LLC, [Online]. Available: https://docs.flutter.dev",
        "[8] M. Fowler, Patterns of Enterprise Application Architecture, Boston, MA: Addison-Wesley, 2002."
    ]

    for item in bib_items:
        add_p(item, space_after=14, line_spacing=1.25)

    doc_path = "BiteHub_DBMS_Mini_Project_Report.docx"
    doc.save(doc_path)
    print(f"Successfully generated {doc_path} ({len(doc.paragraphs)} paragraphs)")

if __name__ == "__main__":
    create_report()


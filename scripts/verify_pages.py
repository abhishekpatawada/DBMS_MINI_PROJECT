import docx

doc = docx.Document("BiteHub_Database_Normalization_Report.docx")
page_breaks = 0
for p in doc.paragraphs:
    for r in p.runs:
        if "w:type=\"page\"" in r._r.xml:
            page_breaks += 1

print(f"File: BiteHub_Database_Normalization_Report.docx")
print(f"Total Paragraphs: {len(doc.paragraphs)}")
print(f"Total Tables: {len(doc.tables)}")
print(f"Total Sections: {len(doc.sections)}")
print(f"Explicit Page Breaks: {page_breaks}")
print(f"Total Pages = {page_breaks + len(doc.sections)}")

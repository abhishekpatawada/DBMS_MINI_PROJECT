import docx
from docx.shared import RGBColor

doc = docx.Document("BiteHub_Database_Normalization_Report.docx")
page_breaks = 0
non_black_runs = 0
non_times_runs = 0

for p in doc.paragraphs:
    for r in p.runs:
        if "w:type=\"page\"" in r._r.xml:
            page_breaks += 1
        if r.font.color and r.font.color.rgb and r.font.color.rgb != RGBColor(0, 0, 0):
            non_black_runs += 1
        if r.font.name and r.font.name != "Times New Roman" and r.font.name != "Courier New":
            non_times_runs += 1

print(f"Total Paragraphs: {len(doc.paragraphs)}")
print(f"Total Tables: {len(doc.tables)}")
print(f"Total Sections: {len(doc.sections)}")
print(f"Explicit Page Breaks: {page_breaks}")
print(f"Total Document Pages: {page_breaks + len(doc.sections)}")
print(f"Non-Black Font Runs: {non_black_runs}")
print(f"Non-Times/Courier Runs: {non_times_runs}")


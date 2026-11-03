import docx
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

d = docx.Document()
s1 = d.sections[0]
d.add_paragraph("Preliminary Page")
s2 = d.add_section()
d.add_paragraph("Body Page")

# Set page number restart to 1 in section 2
pgNumType = parse_xml(r'<w:pgNumType %s w:start="1"/>' % nsdecls('w'))
s2._sectPr.append(pgNumType)

d.save("test_sec.docx")
print("Section test passed successfully!")


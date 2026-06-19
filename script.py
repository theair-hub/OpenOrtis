import re
from pathlib import Path
from lxml import etree

# ── Paths ─────────────────────────────────────────────────────────────────
HERE     = Path(__file__).parent          # cartella dello script
xml_file = HERE / "data" / "Ortis_1817.xml"
xsl_file = HERE / "ortis_edition.xsl"
out_file = HERE / "viewer_edition.html"

# ── Parse & trasforma ──────────────────────────────────────────────────────
xml       = etree.parse(str(xml_file))
xsl       = etree.parse(str(xsl_file))
transform = etree.XSLT(xsl)
result    = transform(xml)

# ── Serializza ────────────────────────────────────────────────────────────
html = etree.tostring(result, pretty_print=True, encoding="unicode", method="html")

# ── Fix: lxml escapa il contenuto di <script> e <style> ───────────────────
def unescape_tag_content(html, tag):
    pattern = re.compile(
        r'(<' + tag + r'(?:\s[^>]*)?>)(.*?)(</\s*' + tag + r'\s*>)',
        re.DOTALL | re.IGNORECASE
    )
    def fix(m):
        content = m.group(2)
        for old, new in [('&amp;','&'),('&lt;','<'),('&gt;','>'),('&apos;',"'"),('&quot;','"')]:
            content = content.replace(old, new)
        return m.group(1) + content + m.group(3)
    return pattern.sub(fix, html)

html = unescape_tag_content(html, 'script')
html = unescape_tag_content(html, 'style')

# ── Scrivi output ─────────────────────────────────────────────────────────
out_file.write_text(html, encoding="utf-8")
print("HTML generato:", out_file)
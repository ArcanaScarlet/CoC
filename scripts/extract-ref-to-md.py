# -*- coding: utf-8 -*-
"""Extract plain text from 参考資料 files and save as .md"""
import re
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

REF = Path(__file__).resolve().parent.parent / "参考資料"
NS = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}


def read_text_file(path: Path) -> str:
    raw = path.read_bytes()
    for enc in ("utf-8-sig", "utf-8", "cp932", "shift_jis", "euc_jp"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace")


def docx_to_plain(path: Path) -> str:
    parts = []
    with zipfile.ZipFile(path) as zf:
        xml = zf.read("word/document.xml")
    root = ET.fromstring(xml)
    for p in root.iter("{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p"):
        texts = []
        for t in p.iter("{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t"):
            if t.text:
                texts.append(t.text)
            if t.tail:
                texts.append(t.tail)
        line = "".join(texts).strip()
        if line:
            parts.append(line)
        elif parts and parts[-1] != "":
            parts.append("")
    text = "\n".join(parts)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip() + "\n"


def main():
    if not REF.is_dir():
        raise SystemExit(f"Missing folder: {REF}")

    for path in sorted(REF.iterdir()):
        if path.name.startswith("."):
            continue
        if path.suffix.lower() == ".md":
            continue

        stem = path.stem
        if path.suffix.lower() == ".docx":
            out = REF / f"{stem}.md"
        elif path.suffix.lower() == ".txt":
            if (REF / f"{stem}.docx").exists():
                out = REF / f"{stem}_txt.md"
            else:
                out = REF / f"{stem}.md"
        else:
            out = REF / f"{path.name}.md"
        if path.suffix.lower() == ".docx":
            body = docx_to_plain(path)
        elif path.suffix.lower() == ".txt":
            body = read_text_file(path)
        else:
            print(f"SKIP (unsupported): {path.name}")
            continue

        # Plain text only — no markdown formatting beyond raw content
        out.write_text(body, encoding="utf-8", newline="\n")
        print(f"OK: {out.name} ({len(body)} chars)")

    print("Done.")


if __name__ == "__main__":
    main()
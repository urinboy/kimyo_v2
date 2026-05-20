# -*- coding: utf-8 -*-
"""Parse repo-root users.txt -> database/data/student_users_from_txt.php"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
USERS_TXT = ROOT / "users.txt"
OUT_PHP = Path(__file__).resolve().parents[1] / "database" / "data" / "student_users_from_txt.php"

DISTRICT_MAP = [
    ("ELLIKQALA", "ellikkala", "Ellikkala tumani"),
    ("SHUMANAY", "shumanay", "Shumanay tumani"),
    ("SHOMANAY", "shumanay", "Shumanay tumani"),
    ("MANBADA", "unknown", None),
]

# Manbada tuman ko'rsatilmagan 19- va 21-maktablar — mobil API (KarakalpakDistricts) bo'yicha:
QANLIQOL_DISTRICT = "Qanliko'l tumani"

ROW_RE = re.compile(r"^\s*(\d+)\s*\|\s*(.+?)\s*$")


def norm_class_slug(raw: str) -> str:
    s = raw.strip().lower()
    if "ko'rsatilmagan" in s or "ko/rsatilmagan" in s:
        return "xx"
    s = re.sub(r"[^0-9a-z]", "", s)
    return s or "x"


def parse_year_key(header: str) -> str:
    m = re.search(r"(\d{4})-(\d{4})", header)
    if not m:
        return "0000"
    return m.group(1)[2:] + m.group(2)[2:]


def parse_class_raw(header: str) -> str:
    m = re.search(r"Sinf:\s*(.+?)\s*---\s*$", header)
    if m:
        return m.group(1).strip()
    m2 = re.search(r"Sinf:\s*(.+)$", header.rstrip("-").strip())
    return m2.group(1).strip() if m2 else "x"


def grade_for_db(raw: str) -> str:
    if len(raw) <= 50:
        return raw
    return raw[:47] + "..."


def php_escape(s: str) -> str:
    return (
        s.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\n", "\\n")
    )


def main() -> None:
    lines = USERS_TXT.read_text(encoding="utf-8").splitlines()

    district_slug = "unknown"
    district_api: str | None = None
    school: int | None = None
    skip_students = False
    current_header = ""

    rows: list[dict] = []

    for line in lines:
        t = line.strip()

        if t.startswith("TUMAN:"):
            key = t.upper()
            district_slug = "unknown"
            district_api = None
            for needle, dslug, dapi in DISTRICT_MAP:
                if needle in key:
                    district_slug = dslug
                    district_api = dapi
                    break
            continue

        if t.startswith("MAKTAB:"):
            m = re.search(r"(\d+)-maktab", t)
            school = int(m.group(1)) if m else None
            continue

        if t.startswith("--- O") and "quv yili:" in t:
            current_header = t
            skip_students = bool(
                school == 21
                and "2023-2024" in t
                and "ko'rsatilmagan" in t.lower()
            )
            continue

        if "Eslatma: ro'yxat 7-maktab" in line:
            skip_students = True
            continue

        if t.startswith("T/R") or t.startswith("----+") or not t:
            continue

        mo = ROW_RE.match(line)
        if not mo or school is None:
            continue
        if skip_students:
            continue

        idx = int(mo.group(1))
        name = mo.group(2).strip()
        if not name or name == "FISH":
            continue

        class_raw = parse_class_raw(current_header)
        yk = parse_year_key(current_header)
        cslug = norm_class_slug(class_raw)

        username = f"{district_slug}_m{school}_{cslug}_{yk}_{idx:03d}"
        username = username.lower()
        if len(username) > 64:
            username = username[:64]

        row_district = district_api
        if school in (19, 21):
            row_district = QANLIQOL_DISTRICT

        rows.append(
            {
                "username": username,
                "name": name,
                "district_api": row_district,
                "school_number": school,
                "grade": grade_for_db(class_raw),
                "year_key": yk,
            }
        )

    seen: set[str] = set()
    dupes: list[str] = []
    for r in rows:
        u = r["username"]
        if u in seen:
            dupes.append(u)
        seen.add(u)

    if dupes:
        raise SystemExit(f"Duplicate usernames: {dupes[:20]} ... total {len(dupes)}")

    OUT_PHP.parent.mkdir(parents=True, exist_ok=True)

    lines_out = [
        "<?php",
        "",
        "/**",
        " * Avtogeneratsiya: api/scripts/build_student_users_data.py (users.txt)",
        " * Qo'lda tahrirlamang — skriptni qayta ishga tushiring.",
        " *",
        f" * Yozuvlar soni: {len(rows)}",
        " */",
        "",
        "return [",
    ]

    for r in rows:
        dist = "null" if r["district_api"] is None else "'" + php_escape(r["district_api"]) + "'"
        lines_out.append("    [")
        lines_out.append(f"        'username' => '{php_escape(r['username'])}',")
        lines_out.append(f"        'name' => '{php_escape(r['name'])}',")
        lines_out.append(f"        'district_api' => {dist},")
        lines_out.append(f"        'school_number' => {r['school_number']},")
        lines_out.append(f"        'grade' => '{php_escape(r['grade'])}',")
        lines_out.append(f"        'year_key' => '{php_escape(r['year_key'])}',")
        lines_out.append("    ],")

    lines_out.append("];")
    lines_out.append("")

    OUT_PHP.write_text("\n".join(lines_out), encoding="utf-8")
    print(f"Wrote {len(rows)} rows -> {OUT_PHP}")


if __name__ == "__main__":
    main()

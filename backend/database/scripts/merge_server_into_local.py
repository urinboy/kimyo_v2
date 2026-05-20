"""
Server SQLite dumpidagi qatorlarni lokal bazaga QO‘SHISH (asosiy kalit bo‘yicha yo‘q bo‘lganlar).

XAVFSIZLIK:
  - --apply faqat quyidagilarni yaratadi:
      * database.sqlite.pre_merge_<vaqt>.bak   — lokalning to‘liq zaxirasi
      * database.merge_<vaqt>.sqlite            — ishlatish uchun nusxa (asl database.sqlite ga tegmaydi)
  - Server fayl faqat o‘qiladi (ATTACH ... mode=ro).

Tartib (FK): lesson_lab_items → reviews → quiz_attempts → quiz_attempt_answers →
            task_submissions → task_answers → personal_access_tokens
  - sessions jadvali ixtiyoriy (--with-sessions).

Dry-run (standart):
  python merge_server_into_local.py

Qo‘llash:
  python merge_server_into_local.py --apply

Keyin .env dagi yo‘lni vaqtincha merge faylga yo‘naltiring yoki tayyor bo‘lgach
database.sqlite ni zaxira bilan almashtiring.

Ixtiyoriy yo‘llar:
  python merge_server_into_local.py --local "C:\\path\\database.sqlite" --server "C:\\path\\server.sqlite"
"""
from __future__ import annotations

import argparse
import shutil
import sqlite3
import sys
from datetime import datetime
from pathlib import Path


def connect_ro(path: Path) -> sqlite3.Connection:
    uri = path.resolve().as_uri() + "?mode=ro"
    return sqlite3.connect(uri, uri=True)


def attach_ro(conn: sqlite3.Connection, path: Path, alias: str) -> None:
    uri = path.resolve().as_uri() + "?mode=ro"
    conn.execute(f"ATTACH DATABASE {repr(uri)} AS {alias}")


MERGE_TABLES_INTEGER_PK: list[str] = [
    "lesson_lab_items",
    "reviews",
    "quiz_attempts",
    "quiz_attempt_answers",
    "task_submissions",
    "task_answers",
    "personal_access_tokens",
]


def count_would_insert(conn: sqlite3.Connection, table: str, pk: str = "id") -> int:
    esc_t = table.replace('"', '""')
    esc_pk = pk.replace('"', '""')
    sql = (
        f'SELECT COUNT(*) FROM srv."{esc_t}" s '
        f'WHERE NOT EXISTS (SELECT 1 FROM main."{esc_t}" m WHERE m."{esc_pk}" = s."{esc_pk}")'
    )
    return int(conn.execute(sql).fetchone()[0])


def dry_run(local: Path, server: Path, with_sessions: bool) -> None:
    conn = connect_ro(local)
    try:
        attach_ro(conn, server, "srv")
        print("[Dry-run] Qo‘shiladigan qatorlar (main = lokal, srv = server):\n")
        total = 0
        for t in MERGE_TABLES_INTEGER_PK:
            n = count_would_insert(conn, t, "id")
            total += n
            print(f"  {t}: {n}")
        if with_sessions:
            n = count_would_insert(conn, "sessions", "id")
            total += n
            print(f"  sessions: {n}")
        print(f"\n  JAMI (taxminiy): {total}")
        print("\nEslatma: sessions — cookie/session ma’lumoti; lokal dev uchun odatda kerak emas.")
    finally:
        conn.close()


def apply_merge(local: Path, server: Path, with_sessions: bool) -> Path:
    """Laravel / boshqa jarayonlar `database.sqlite` ni ochiq tutmasin — fayl qulflashi mumkin."""
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    base = local.parent
    backup = base / f"database.sqlite.pre_merge_{ts}.bak"
    work = base / f"database.merge_{ts}.sqlite"

    shutil.copy2(local, backup)
    shutil.copy2(local, work)

    dest = sqlite3.connect(work)
    try:
        attach_ro(dest, server, "srv")
        dest.execute("PRAGMA foreign_keys = ON")

        insert_tpl = (
            'INSERT INTO "{t}" SELECT * FROM srv."{t}" s '
            'WHERE NOT EXISTS (SELECT 1 FROM main."{t}" m WHERE m."id" = s."id")'
        )

        dest.execute("BEGIN IMMEDIATE")
        try:
            for t in MERGE_TABLES_INTEGER_PK:
                sql = insert_tpl.format(t=t.replace('"', '""'))
                dest.execute(sql)

            if with_sessions:
                t = "sessions"
                sql = insert_tpl.format(t=t.replace('"', '""'))
                dest.execute(sql)

            dest.execute("COMMIT")
        except Exception:
            dest.execute("ROLLBACK")
            raise

        dest.execute("DETACH DATABASE srv")
    finally:
        dest.close()

    print("\nMerge yakunlandi.")
    print(f"  Zaxira (asl lokal nusxasi): {backup}")
    print(f"  Ishlangan fayl:             {work}")
    print(
        "\nKeyingi qadam: tekshirib ko‘ring (php artisan serve / admin). "
        "Ma’qullansa database.sqlite ni ushbu fayl bilan almashtiring "
        "(yoki .env da sqlite yo‘lini merge faylga qo‘ying)."
    )
    return work


def main() -> None:
    parser = argparse.ArgumentParser(description="Server SQLite → lokal (zaxira bilan)")
    parser.add_argument("--local", type=Path, default=None, help="Lokal database.sqlite")
    parser.add_argument("--server", type=Path, default=None, help="Serverdan olingan .sqlite dump")
    parser.add_argument("--apply", action="store_true", help="Zaxira + merge_* fayl yaratish")
    parser.add_argument(
        "--with-sessions",
        action="store_true",
        help="sessions jadvalini ham serverdan qo‘shish",
    )
    args = parser.parse_args()

    base = Path(__file__).resolve().parents[1]
    local = args.local or (base / "database.sqlite")
    server = args.server or (base / "database (1).sqlite")

    if not local.is_file():
        print(f"Yo‘q: {local}", file=sys.stderr)
        sys.exit(1)
    if not server.is_file():
        print(f"Yo‘q: {server}", file=sys.stderr)
        sys.exit(1)

    if args.apply:
        apply_merge(local, server, args.with_sessions)
    else:
        dry_run(local, server, args.with_sessions)


if __name__ == "__main__":
    main()

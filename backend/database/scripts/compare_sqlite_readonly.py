"""
Ikki SQLite bazani faqat o‘qish (URI mode=ro) rejimida solishtiradi.
Asl fayllarga yozmaydi.

Ishlatish:
  python database/scripts/compare_sqlite_readonly.py path/to/local.sqlite path/to/server.sqlite
"""
from __future__ import annotations

import sqlite3
import sys
from pathlib import Path


def connect_ro(p: Path) -> sqlite3.Connection:
    uri = p.resolve().as_uri() + "?mode=ro"
    return sqlite3.connect(uri, uri=True)


def table_names(con: sqlite3.Connection) -> list[str]:
    rows = con.execute(
        """
        SELECT name FROM sqlite_master
        WHERE type='table' AND name NOT LIKE 'sqlite_%'
        ORDER BY name
        """
    ).fetchall()
    return [r[0] for r in rows]


def create_sql(con: sqlite3.Connection, name: str) -> str | None:
    row = con.execute(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name=?",
        (name,),
    ).fetchone()
    return row[0] if row else None


def norm_sql(sql: str | None) -> str:
    if not sql:
        return ""
    return " ".join(sql.split())


def row_count(con: sqlite3.Connection, name: str) -> int | str:
    try:
        esc = name.replace('"', '""')
        q = f'SELECT COUNT(*) FROM "{esc}"'
        return int(con.execute(q).fetchone()[0])
    except sqlite3.Error as e:
        return f"ERROR: {e}"


def pragma_cols(con: sqlite3.Connection, name: str) -> tuple[str, ...]:
    esc = name.replace('"', '""')
    rows = con.execute(f'PRAGMA table_info("{esc}")').fetchall()
    # cid, name, type, notnull, dflt_value, pk
    return tuple(f"{r[1]}:{r[2]}:pk={r[5]}" for r in rows)


def report_pair(label_a: str, label_b: str, path_a: Path, path_b: Path) -> None:
    print(f"\n{'=' * 72}")
    print(f"A (LOCAL-ish):  {label_a}")
    print(f"              {path_a}")
    print(f"B (SERVER-ish): {label_b}")
    print(f"              {path_b}")
    print("=" * 72)

    ca = connect_ro(path_a)
    cb = connect_ro(path_b)
    try:
        ta = set(table_names(ca))
        tb = set(table_names(cb))

        only_a = sorted(ta - tb)
        only_b = sorted(tb - ta)
        common = sorted(ta & tb)

        if only_a:
            print("\n[Faqat A da jadvallar]", len(only_a))
            for t in only_a:
                print(f"  + {t}  (rows={row_count(ca, t)})")

        if only_b:
            print("\n[Faqat B da jadvallar]", len(only_b))
            for t in only_b:
                print(f"  + {t}  (rows={row_count(cb, t)})")

        schema_mismatch: list[str] = []
        count_diff: list[tuple[str, int | str, int | str]] = []

        print("\n[Umumiy jadvallar]", len(common))
        print(f"{'table':<42} {'rows_A':>10} {'rows_B':>10} {'schema':>8}")

        for name in common:
            sa = create_sql(ca, name)
            sb = create_sql(cb, name)
            schema_ok = norm_sql(sa) == norm_sql(sb)
            if not schema_ok:
                schema_mismatch.append(name)
                smark = "DIFF"
            else:
                smark = "OK"

            na = row_count(ca, name)
            nb = row_count(cb, name)
            if isinstance(na, int) and isinstance(nb, int) and na != nb:
                count_diff.append((name, na, nb))

            print(f"{name:<42} {str(na):>10} {str(nb):>10} {smark:>8}")

        if schema_mismatch:
            print("\n[SKHEMA farqi — dikkat bilan qarating]")
            for name in schema_mismatch:
                print(f"\n--- {name} ---")
                ca_cols = pragma_cols(ca, name)
                cb_cols = pragma_cols(cb, name)
                if ca_cols != cb_cols:
                    print("  PRAGMA table_info farqi:")
                    print("    A:", ca_cols)
                    print("    B:", cb_cols)
                print("  CREATE A:", (create_sql(ca, name) or "")[:500])
                print("  CREATE B:", (create_sql(cb, name) or "")[:500])

        print("\n[Qatorlar soni farqi]")
        if not count_diff:
            print("  (farq yo‘q yoki hisoblashda xato)")
        else:
            def _delta_mag(row: tuple[str, int | str, int | str]) -> int:
                _, na, nb = row
                if isinstance(na, int) and isinstance(nb, int):
                    return abs(nb - na)
                return 0

            for name, na, nb in sorted(count_diff, key=_delta_mag, reverse=True):
                delta = ""
                if isinstance(na, int) and isinstance(nb, int):
                    delta = f" (delta {nb - na:+d})"
                print(f"  {name}: A={na} B={nb}{delta}")

        # Laravel migrations
        if "migrations" in common:
            ma = ca.execute('SELECT migration, batch FROM migrations ORDER BY batch, migration').fetchall()
            mb = cb.execute('SELECT migration, batch FROM migrations ORDER BY batch, migration').fetchall()
            sa_m = set(ma)
            sb_m = set(mb)
            print("\n[Laravel migrations]")
            print(f"  A jami yozuvlar: {len(ma)}")
            print(f"  B jami yozuvlar: {len(mb)}")
            only_ma = sorted(sa_m - sb_m)
            only_mb = sorted(sb_m - sa_m)
            if only_ma:
                print(f"  Faqat A da ({len(only_ma)}):")
                for r in only_ma[:30]:
                    print(f"    {r}")
                if len(only_ma) > 30:
                    print(f"    ... +{len(only_ma) - 30} ta")
            if only_mb:
                print(f"  Faqat B da ({len(only_mb)}):")
                for r in only_mb[:30]:
                    print(f"    {r}")
                if len(only_mb) > 30:
                    print(f"    ... +{len(only_mb) - 30} ta")
            if not only_ma and not only_mb:
                print("  Migratsiya ro‘yxati to‘liq mos keladi.")

    finally:
        ca.close()
        cb.close()


def main() -> None:
    if len(sys.argv) >= 3:
        pa = Path(sys.argv[1])
        pb = Path(sys.argv[2])
        report_pair(sys.argv[1], sys.argv[2], pa, pb)
        return

    base = Path(__file__).resolve().parents[1]
    pairs = [
        (
            "database.sqlite (asosiy lokal)",
            "database (1).sqlite (ehtimoliy server dump)",
            base / "database.sqlite",
            base / "database (1).sqlite",
        ),
        (
            "database.sqlite",
            "backup/database.sqlite",
            base / "database.sqlite",
            base / "backup" / "database.sqlite",
        ),
        (
            "database.sqlite",
            "backup/database (1).sqlite",
            base / "database.sqlite",
            base / "backup" / "database (1).sqlite",
        ),
    ]

    for la, lb, pa, pb in pairs:
        if not pa.is_file():
            print(f"[skip] yo‘q: {pa}")
            continue
        if not pb.is_file():
            print(f"[skip] yo‘q: {pb}")
            continue
        report_pair(la, lb, pa, pb)


if __name__ == "__main__":
    main()

"""
Run Queries
-----------
Executes every .sql file in sql/ against the built database and prints
formatted results. Useful for verifying all queries work end to end and
for generating the report output shown in reports/sample_output.md.

Run from the repository root (after build_database.py):
    python run_queries.py
"""

import os
import sqlite3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "data", "security_analytics.db")
SQL_DIR = os.path.join(BASE_DIR, "sql")

QUERY_FILES = [
    "01_failed_login_report.sql",
    "02_brute_force_detection_cte.sql",
    "03_incident_metrics_view.sql",
    "04_executive_summary_aggregation.sql",
]


def run_query_file(conn, filename):
    path = os.path.join(SQL_DIR, filename)
    with open(path, encoding="utf-8") as f:
        script = f.read()

    cursor = conn.cursor()

    if filename == "03_incident_metrics_view.sql":
        # This file contains DDL (DROP VIEW / CREATE VIEW); executescript
        # handles multiple statements, then we separately query the view.
        cursor.executescript(script)
        rows = cursor.execute(
            "SELECT * FROM v_incident_metrics_by_category ORDER BY total_incidents DESC"
        ).fetchall()
        columns = [d[0] for d in cursor.description]
    else:
        # Single SELECT statement (with leading comments) - execute() returns
        # a cursor we can fetch directly from.
        cursor.execute(script)
        rows = cursor.fetchall()
        columns = [d[0] for d in cursor.description] if cursor.description else []

    return columns, rows


def print_table(columns, rows):
    if not rows:
        print("(no rows)")
        return
    widths = [max(len(str(c)), max((len(str(r[i])) for r in rows), default=0)) for i, c in enumerate(columns)]
    header = "  ".join(str(c).ljust(w) for c, w in zip(columns, widths))
    print(header)
    print("-" * len(header))
    for row in rows:
        print("  ".join(str(v).ljust(w) for v, w in zip(row, widths)))


if __name__ == "__main__":
    conn = sqlite3.connect(DB_PATH)
    for filename in QUERY_FILES:
        print("=" * 70)
        print(filename)
        print("=" * 70)
        columns, rows = run_query_file(conn, filename)
        print_table(columns, rows)
        print()
    conn.close()

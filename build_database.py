"""
Build Database
--------------
Creates a fresh SQLite database from the schema and seed data files.
SQLite is used so the project runs anywhere with Python, no database
server required, while every query is written in standard SQL that
translates directly to MySQL/PostgreSQL with minor syntax changes
(noted in README.md).

Run from the repository root:
    python build_database.py
"""

import os
import sqlite3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "data", "security_analytics.db")
SCHEMA_FILE = os.path.join(BASE_DIR, "sql", "schema.sql")
SEED_FILE = os.path.join(BASE_DIR, "sql", "seed_data.sql")


def build():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)
    with open(SCHEMA_FILE, encoding="utf-8") as f:
        conn.executescript(f.read())
    with open(SEED_FILE, encoding="utf-8") as f:
        conn.executescript(f.read())
    conn.commit()

    auth_count = conn.execute("SELECT COUNT(*) FROM authentication_logs").fetchone()[0]
    incident_count = conn.execute("SELECT COUNT(*) FROM incidents").fetchone()[0]
    conn.close()

    print(f"Database built: {DB_PATH}")
    print(f"  authentication_logs: {auth_count} rows")
    print(f"  incidents: {incident_count} rows")


if __name__ == "__main__":
    build()

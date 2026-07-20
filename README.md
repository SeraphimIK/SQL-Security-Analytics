# SQL Security Analytics

Simulated authentication log and security incident data, analyzed with SQL:
failed login reporting, brute-force/enumeration detection using CTEs, a
reusable incident metrics view, and an executive summary rollup.

## Project structure
```
SQL-Security-Analytics/
├── README.md
├── LICENSE
├── requirements.txt
├── build_database.py              # Creates the SQLite DB from schema + seed data
├── run_queries.py                 # Runs every query file and prints results
├── data/
│   └── security_analytics.db      # Generated on run
├── sql/
│   ├── schema.sql                 # Table definitions
│   ├── seed_data.sql              # Simulated sample data (155 auth events, 8 incidents)
│   ├── 01_failed_login_report.sql       # Aggregation, GROUP BY
│   ├── 02_brute_force_detection_cte.sql # CTE (WITH clause), self-join
│   ├── 03_incident_metrics_view.sql     # CREATE VIEW, date math
│   └── 04_executive_summary_aggregation.sql  # Multi-metric KPI rollup
├── reports/
│   └── sample_output.md           # Captured output + interpretation
├── docs/
└── screenshots/
```

## Why SQLite
This project uses SQLite so it runs anywhere with Python, no database
server to install. Every query uses standard SQL (CTEs, views,
aggregation, joins) that translates directly to MySQL or PostgreSQL. The
one exception: stored procedures were part of the original scope, but
SQLite doesn't support them (no server-side procedural extension). The
view in `03_incident_metrics_view.sql` demonstrates the same
"reusable, named query" concept in the dialect this project actually
runs.

## How to run
```bash
python build_database.py
python run_queries.py
```

`build_database.py` creates `data/security_analytics.db` from
`sql/schema.sql` and `sql/seed_data.sql`. `run_queries.py` executes each
query file against it and prints formatted results, matching
`reports/sample_output.md`.

## What each query demonstrates
| File | SQL concept | What it finds |
|---|---|---|
| `01_failed_login_report.sql` | Aggregation, GROUP BY, ORDER BY | Failed login volume per source IP |
| `02_brute_force_detection_cte.sql` | CTEs, self-join, CASE logic | Brute force + enumeration detection, flags success-after-failure |
| `03_incident_metrics_view.sql` | CREATE VIEW, date math | Reusable incident metrics by category, including mean time to close |
| `04_executive_summary_aggregation.sql` | UNION ALL, scalar subqueries | Single KPI-style executive summary |

## Notes on the data
`sql/seed_data.sql` is fabricated example data generated for this
project (155 authentication events and 8 incidents across a 5-day
period), not from a real system or a real employer.

## Future improvements
- Port schema/queries to PostgreSQL and add actual stored procedures
- Add a query for geographic anomaly detection (impossible travel)
- Add a Tableau/Power BI connection example against the SQLite file

## References
- NIST SP 800-61 (Computer Security Incident Handling Guide) for incident
  categorization conventions used in `incidents.category`

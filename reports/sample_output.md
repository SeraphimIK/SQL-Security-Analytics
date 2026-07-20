# Sample Query Output

Actual output from `python run_queries.py` against the seeded database
(`data/security_analytics.db`), captured here for reference without
needing to rebuild the project.

```
======================================================================
01_failed_login_report.sql
======================================================================
source_ip       failed_attempts  distinct_usernames_tried  first_seen           last_seen
---------------------------------------------------------------------------------------------------
203.0.113.55    9                2                         2026-07-12 02:14:02  2026-07-12 02:14:18
198.51.100.9    7                5                         2026-07-13 09:41:03  2026-07-13 09:41:21
185.220.101.47  6                1                         2026-07-14 14:22:02  2026-07-14 14:22:12
10.0.1.15       2                2                         2026-07-11 11:13:14  2026-07-12 08:25:11
10.0.1.31       2                2                         2026-07-12 17:47:09  2026-07-13 16:44:13
10.0.2.19       2                2                         2026-07-10 07:05:20  2026-07-11 17:41:39
10.0.1.22       1                1                         2026-07-12 07:05:51  2026-07-12 07:05:51

======================================================================
02_brute_force_detection_cte.sql
======================================================================
source_ip       failure_count  distinct_usernames  success_followed_burst  assessment
-------------------------------------------------------------------------------------------------------------
203.0.113.55    9              2                   YES                     Brute force, possible compromise
198.51.100.9    7              5                   NO                      Brute force + username enumeration
185.220.101.47  6              1                   NO                      Brute force, no successful login

======================================================================
03_incident_metrics_view.sql
======================================================================
category                   total_incidents  open_incidents  closed_incidents  avg_days_to_close
-----------------------------------------------------------------------------------------------
Brute Force                2                0               2                 0.0
Phishing                   2                0               2                 0.5
Data Exfiltration Attempt  1                1               0                 None
Malware                    1                0               1                 2.0
Policy Violation           1                0               1                 1.0
Username Enumeration       1                0               1                 0.0

======================================================================
04_executive_summary_aggregation.sql
======================================================================
metric                                           value
------------------------------------------------------
Total authentication events                      155
Total failed logins                              29
Overall failure rate (%)                         18.7
Distinct source IPs seen                         8
Source IPs flagged as brute force (5+ failures)  3
Total security incidents logged                  8
Open incidents                                   1
Critical/High severity incidents                 3
```

## Interpretation
Three source IPs cross the brute-force threshold (5+ failures). Of those,
`203.0.113.55` is the most concerning: 9 failed attempts followed by a
successful login within the same burst, a pattern consistent with a
successful credential attack rather than a failed one. `198.51.100.9`
shows username enumeration behavior (5 distinct usernames from one IP)
without ever succeeding. These findings tie directly to the "Brute Force"
and "Username Enumeration" incident records in `sql/seed_data.sql`.

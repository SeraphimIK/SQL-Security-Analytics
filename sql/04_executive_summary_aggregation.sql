-- 04_executive_summary_aggregation.sql
-- Rolls up authentication activity and incident data into a single
-- executive-level summary. Demonstrates: multiple aggregations, UNION,
-- scalar subqueries used to build a KPI-style report.

SELECT 'Total authentication events' AS metric,
       CAST(COUNT(*) AS TEXT) AS value
FROM authentication_logs

UNION ALL

SELECT 'Total failed logins',
       CAST(COUNT(*) AS TEXT)
FROM authentication_logs WHERE event_result = 'failure'

UNION ALL

SELECT 'Overall failure rate (%)',
       CAST(ROUND(
           100.0 * (SELECT COUNT(*) FROM authentication_logs WHERE event_result = 'failure')
           / (SELECT COUNT(*) FROM authentication_logs), 1
       ) AS TEXT)

UNION ALL

SELECT 'Distinct source IPs seen',
       CAST(COUNT(DISTINCT source_ip) AS TEXT)
FROM authentication_logs

UNION ALL

SELECT 'Source IPs flagged as brute force (5+ failures)',
       CAST(COUNT(*) AS TEXT)
FROM (
    SELECT source_ip FROM authentication_logs
    WHERE event_result = 'failure'
    GROUP BY source_ip
    HAVING COUNT(*) >= 5
)

UNION ALL

SELECT 'Total security incidents logged',
       CAST(COUNT(*) AS TEXT)
FROM incidents

UNION ALL

SELECT 'Open incidents',
       CAST(COUNT(*) AS TEXT)
FROM incidents WHERE status = 'Open'

UNION ALL

SELECT 'Critical/High severity incidents',
       CAST(COUNT(*) AS TEXT)
FROM incidents WHERE severity IN ('Critical', 'High');

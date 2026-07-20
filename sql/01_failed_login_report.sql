-- 01_failed_login_report.sql
-- Basic report: failed login count per source IP, ordered by volume.
-- Demonstrates: aggregation, GROUP BY, ORDER BY

SELECT
    source_ip,
    COUNT(*) AS failed_attempts,
    COUNT(DISTINCT username) AS distinct_usernames_tried,
    MIN(event_time) AS first_seen,
    MAX(event_time) AS last_seen
FROM authentication_logs
WHERE event_result = 'failure'
GROUP BY source_ip
ORDER BY failed_attempts DESC;

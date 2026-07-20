-- 02_brute_force_detection_cte.sql
-- Flags source IPs with a high volume of failed logins in a short window,
-- and checks whether a success immediately followed the failure burst.
-- Demonstrates: CTEs (WITH clause), subqueries, conditional logic

WITH failure_counts AS (
    SELECT
        source_ip,
        COUNT(*) AS failure_count,
        COUNT(DISTINCT username) AS distinct_usernames
    FROM authentication_logs
    WHERE event_result = 'failure'
    GROUP BY source_ip
),
flagged_ips AS (
    SELECT source_ip, failure_count, distinct_usernames
    FROM failure_counts
    WHERE failure_count >= 5
),
success_after_failure AS (
    SELECT DISTINCT a.source_ip
    FROM authentication_logs a
    JOIN authentication_logs b
        ON a.source_ip = b.source_ip
        AND a.event_result = 'success'
        AND b.event_result = 'failure'
        AND a.event_time > b.event_time
        AND (strftime('%s', a.event_time) - strftime('%s', b.event_time)) <= 60
)
SELECT
    f.source_ip,
    f.failure_count,
    f.distinct_usernames,
    CASE WHEN s.source_ip IS NOT NULL THEN 'YES' ELSE 'NO' END AS success_followed_burst,
    CASE
        WHEN f.distinct_usernames >= 3 THEN 'Brute force + username enumeration'
        WHEN s.source_ip IS NOT NULL THEN 'Brute force, possible compromise'
        ELSE 'Brute force, no successful login'
    END AS assessment
FROM flagged_ips f
LEFT JOIN success_after_failure s ON f.source_ip = s.source_ip
ORDER BY f.failure_count DESC;

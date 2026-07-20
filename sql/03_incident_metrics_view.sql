-- 03_incident_metrics_view.sql
-- Creates a reusable view summarizing incident metrics by category,
-- including mean time to close (in days) for closed incidents.
-- Demonstrates: CREATE VIEW, date math, conditional aggregation

DROP VIEW IF EXISTS v_incident_metrics_by_category;

CREATE VIEW v_incident_metrics_by_category AS
SELECT
    category,
    COUNT(*) AS total_incidents,
    SUM(CASE WHEN status = 'Open' THEN 1 ELSE 0 END) AS open_incidents,
    SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) AS closed_incidents,
    ROUND(AVG(
        CASE WHEN status = 'Closed'
        THEN julianday(date_closed) - julianday(date_opened)
        END
    ), 1) AS avg_days_to_close
FROM incidents
GROUP BY category;

-- Usage:
-- SELECT * FROM v_incident_metrics_by_category ORDER BY total_incidents DESC;

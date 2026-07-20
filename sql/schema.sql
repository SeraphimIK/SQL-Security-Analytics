-- Schema: SQL Security Analytics
-- SQLite dialect (portable, no server required to run this project)

DROP TABLE IF EXISTS authentication_logs;
CREATE TABLE authentication_logs (
    log_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    event_time    TEXT NOT NULL,     -- ISO 8601 'YYYY-MM-DD HH:MM:SS'
    source_ip     TEXT NOT NULL,
    username      TEXT NOT NULL,
    system_name   TEXT NOT NULL,
    event_result  TEXT NOT NULL CHECK (event_result IN ('success', 'failure'))
);

DROP TABLE IF EXISTS incidents;
CREATE TABLE incidents (
    incident_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    date_opened   TEXT NOT NULL,
    category      TEXT NOT NULL,      -- Phishing, Malware, Brute Force, Policy Violation, etc.
    severity      TEXT NOT NULL CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
    status        TEXT NOT NULL CHECK (status IN ('Open', 'Closed')),
    date_closed   TEXT,
    related_ip    TEXT,
    description   TEXT
);

CREATE INDEX idx_auth_source_ip ON authentication_logs(source_ip);
CREATE INDEX idx_auth_event_time ON authentication_logs(event_time);
CREATE INDEX idx_incidents_category ON incidents(category);

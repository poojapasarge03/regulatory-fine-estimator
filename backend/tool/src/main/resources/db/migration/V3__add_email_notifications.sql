-- Migration: Add email notification support to User and RegulatoryViolation entities

-- Add email column WITHOUT unique constraint first, using unique default per user
ALTER TABLE app_user
ADD COLUMN IF NOT EXISTS email VARCHAR(255),
ADD COLUMN IF NOT EXISTS email_notifications_enabled BOOLEAN NOT NULL DEFAULT true;

-- Set unique email per user based on their id to avoid duplicates
UPDATE app_user SET email = 'user-' || id || '@example.com' WHERE email IS NULL;

-- Now make it NOT NULL and add unique constraint
ALTER TABLE app_user ALTER COLUMN email SET NOT NULL;
ALTER TABLE app_user ADD CONSTRAINT app_user_email_key UNIQUE (email);

-- Add email-related columns to regulatory_violation table
ALTER TABLE regulatory_violation
ADD COLUMN IF NOT EXISTS deadline TIMESTAMP,
ADD COLUMN IF NOT EXISTS estimated_fine NUMERIC(15, 2),
ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS email_sent BOOLEAN DEFAULT false;

-- Create email_notification_log table
CREATE TABLE IF NOT EXISTS email_notification_log (
    id BIGSERIAL PRIMARY KEY,
    recipient_email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    template_name VARCHAR(100) NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    error_message TEXT,
    violation_id BIGINT REFERENCES regulatory_violation(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_email_notification_log_sent_at ON email_notification_log(sent_at);
CREATE INDEX IF NOT EXISTS idx_email_notification_log_recipient ON email_notification_log(recipient_email);
CREATE INDEX IF NOT EXISTS idx_email_notification_log_violation ON email_notification_log(violation_id);
CREATE INDEX IF NOT EXISTS idx_regulatory_violation_deadline ON regulatory_violation(deadline);
CREATE INDEX IF NOT EXISTS idx_regulatory_violation_severity ON regulatory_violation(severity);
CREATE INDEX IF NOT EXISTS idx_regulatory_violation_status ON regulatory_violation(status);

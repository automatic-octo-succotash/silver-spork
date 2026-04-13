BEGIN;

CREATE TABLE crm.oauth_state (
    id INT PRIMARY KEY DEFAULT 1,
    access_token TEXT NOT NULL,
    refresh_token TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT single_row_check CHECK (id = 1)
);

COMMENT ON TABLE crm.oauth_state IS 'Stores the global rotating OAuth2 token state for the RD Station CRM v2 integration.';

COMMIT;

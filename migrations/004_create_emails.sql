CREATE TABLE emails (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  external_id  TEXT NOT NULL,
  provider     TEXT NOT NULL,
  sender       TEXT NOT NULL,
  sender_email TEXT NOT NULL,
  subject      TEXT,
  received_at  TIMESTAMP NOT NULL,
  status       TEXT NOT NULL DEFAULT 'received',
  created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT emails_provider_valid CHECK (provider IN ('gmail', 'outlook')),
  CONSTRAINT emails_status_valid   CHECK (status IN ('received', 'parsed', 'processed')),
  CONSTRAINT emails_external_id_provider_unique UNIQUE (external_id, provider)
);

CREATE INDEX ON emails (provider, external_id);
CREATE INDEX ON emails (sender_email);
CREATE INDEX ON emails (received_at DESC);
CREATE INDEX ON emails (status);

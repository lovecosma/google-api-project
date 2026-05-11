CREATE TABLE batch_metrics (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  batch_timestamp TIMESTAMP NOT NULL,
  new_emails      INTEGER NOT NULL,
  errors          INTEGER NOT NULL,
  duration_ms     INTEGER NOT NULL,
  success         BOOLEAN NOT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX ON batch_metrics (batch_timestamp DESC);
CREATE INDEX ON batch_metrics (success);
CREATE INDEX ON batch_metrics (created_at DESC);

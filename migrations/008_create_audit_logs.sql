CREATE TABLE audit_logs (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id   UUID REFERENCES orders(id) ON DELETE SET NULL,
  action     TEXT NOT NULL,
  actor_type TEXT NOT NULL,
  actor_id   UUID REFERENCES users(id) ON DELETE SET NULL,
  details    JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT audit_logs_actor_type_valid CHECK (actor_type IN ('system', 'user'))
);

CREATE INDEX ON audit_logs (order_id);
CREATE INDEX ON audit_logs (actor_id);
CREATE INDEX ON audit_logs (action);
CREATE INDEX ON audit_logs (created_at DESC);
CREATE INDEX ON audit_logs (action, created_at DESC);

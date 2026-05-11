CREATE TABLE approvals (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  approver_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  action      TEXT NOT NULL,
  comments    TEXT,
  changes     JSONB,
  created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT approvals_action_valid CHECK (action IN ('approved', 'rejected'))
);

CREATE INDEX ON approvals (order_id);
CREATE INDEX ON approvals (approver_id);
CREATE INDEX ON approvals (created_at DESC);

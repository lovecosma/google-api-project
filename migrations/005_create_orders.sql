CREATE TABLE orders (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email_id         UUID NOT NULL REFERENCES emails(id) ON DELETE CASCADE,
  customer_id      UUID REFERENCES customers(id) ON DELETE SET NULL,
  status           TEXT NOT NULL DEFAULT 'extracted',
  extracted_data   JSONB NOT NULL,
  order_summary    TEXT,
  confidence_score DECIMAL(3, 2),
  validated_data   JSONB,
  approved_by      UUID REFERENCES users(id) ON DELETE SET NULL,
  approved_at      TIMESTAMP,
  approval_notes   TEXT,
  rejection_reason TEXT,
  total_amount     DECIMAL(10, 2),
  shipment_id      TEXT,
  tracking_number  TEXT,
  invoice_url      TEXT,
  flagged_issues   TEXT[] DEFAULT '{}',
  fraud_flags      TEXT[] DEFAULT '{}',
  created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMP NOT NULL DEFAULT NOW(),
  fulfilled_at     TIMESTAMP,
  shipped_at       TIMESTAMP,
  CONSTRAINT orders_status_valid CHECK (
    status IN ('extracted', 'validated', 'needs_review', 'approved', 'rejected', 'fulfilled', 'shipped')
  ),
  CONSTRAINT orders_confidence_score_range CHECK (
    confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1)
  )
);

CREATE INDEX ON orders (email_id);
CREATE INDEX ON orders (customer_id);
CREATE INDEX ON orders (status);
CREATE INDEX ON orders (status, created_at DESC);
CREATE INDEX ON orders (created_at DESC);
CREATE INDEX ON orders (confidence_score);
CREATE INDEX ON orders (approved_by);

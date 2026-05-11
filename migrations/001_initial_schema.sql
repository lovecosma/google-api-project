-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. customers
CREATE TABLE customers (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email               TEXT UNIQUE NOT NULL,
  name                TEXT,
  credit              DECIMAL(10, 2) NOT NULL DEFAULT 0,
  order_count         INTEGER NOT NULL DEFAULT 0,
  average_order_value DECIMAL(10, 2) DEFAULT 0,
  last_order_at       TIMESTAMP,
  fraud_score         INTEGER DEFAULT 0,
  created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT customers_credit_non_negative CHECK (credit >= 0)
);

CREATE INDEX ON customers (created_at DESC);
CREATE INDEX ON customers (fraud_score DESC);

-- 2. products
CREATE TABLE products (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sku             TEXT UNIQUE NOT NULL,
  name            TEXT NOT NULL,
  description     TEXT,
  price           DECIMAL(10, 2) NOT NULL,
  inventory_count INTEGER NOT NULL DEFAULT 0,
  aliases         TEXT[] DEFAULT '{}',
  category        TEXT,
  active          BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT products_price_non_negative CHECK (price >= 0)
);

CREATE INDEX ON products (name);
CREATE INDEX ON products (category);
CREATE INDEX ON products (active);
CREATE INDEX ON products (inventory_count);

-- 3. users
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         TEXT UNIQUE NOT NULL,
  name          TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'viewer',
  password_hash TEXT,
  active        BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT users_role_valid CHECK (role IN ('viewer', 'approver', 'admin'))
);

CREATE INDEX ON users (role);

-- 4. emails
CREATE TABLE emails (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  external_id TEXT NOT NULL,
  provider    TEXT NOT NULL,
  sender      TEXT NOT NULL,
  sender_email TEXT NOT NULL,
  subject     TEXT,
  received_at TIMESTAMP NOT NULL,
  status      TEXT NOT NULL DEFAULT 'received',
  created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT emails_provider_valid CHECK (provider IN ('gmail', 'outlook')),
  CONSTRAINT emails_status_valid   CHECK (status IN ('received', 'parsed', 'processed')),
  CONSTRAINT emails_external_id_provider_unique UNIQUE (external_id, provider)
);

CREATE INDEX ON emails (provider, external_id);
CREATE INDEX ON emails (sender_email);
CREATE INDEX ON emails (received_at DESC);
CREATE INDEX ON emails (status);

-- 5. orders
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

-- 6. order_items
CREATE TABLE order_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id   UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity     INTEGER NOT NULL,
  unit_price   DECIMAL(10, 2) NOT NULL,
  variant_data JSONB,
  created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX ON order_items (order_id);
CREATE INDEX ON order_items (product_id);

-- 7. approvals
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

-- 8. audit_logs
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

-- 9. batch_metrics
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

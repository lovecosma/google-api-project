CREATE EXTENSION IF NOT EXISTS "pgcrypto";

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

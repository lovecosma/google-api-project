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

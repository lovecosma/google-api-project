CREATE TABLE order_products (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id   UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity     INTEGER NOT NULL,
  unit_price   DECIMAL(10, 2) NOT NULL,
  variant_data JSONB,
  created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX ON order_products (order_id);
CREATE INDEX ON order_products (product_id);

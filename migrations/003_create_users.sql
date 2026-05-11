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

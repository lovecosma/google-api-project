require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const MIGRATION_FILE = path.join(__dirname, '..', 'migrations', '001_initial_schema.sql');

async function migrate() {
  const client = new Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();

  try {
    const sql = fs.readFileSync(MIGRATION_FILE, 'utf8');
    await client.query(sql);
    console.log('Migration complete.');
  } finally {
    await client.end();
  }
}

migrate().catch(err => {
  console.error('Migration failed:', err.message);
  process.exit(1);
});

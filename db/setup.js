// Cria e popula o banco a partir dos scripts .sql desta pasta.
// Uso: npm run db:setup   (ou npm run db:reset para apagar tudo antes)
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const scripts = [
  '01_create.sql',
  '02_populate.sql',
  '04_more_data.sql',
  '05_adjustments.sql',
];

async function main() {
  if (!process.env.DATABASE_URL) {
    console.error('DATABASE_URL não definida (veja o .env.example)');
    process.exit(1);
  }

  const client = new Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();

  try {
    if (process.argv.includes('--reset')) {
      console.log('apagando schema public...');
      await client.query('DROP SCHEMA public CASCADE; CREATE SCHEMA public;');
    }

    for (const file of scripts) {
      const sql = fs.readFileSync(path.join(__dirname, file), 'utf8');
      process.stdout.write(`rodando ${file}... `);
      await client.query(sql);
      console.log('ok');
    }

    const { rows } = await client.query('SELECT COUNT(*) AS total FROM v_catalog');
    console.log(`pronto, ${rows[0].total} backing tracks no catálogo`);
  } finally {
    await client.end();
  }
}

main().catch((err) => {
  console.error('\nfalhou:', err.message);
  process.exit(1);
});

const db = require('./config/database.js');

db.query('SELECT table_name FROM information_schema.tables WHERE table_schema = $1', ['public'])
  .then(res => {
    console.log('✓ DB Connected Successfully!');
    console.log('Tables found:', res.rows.map(r => r.table_name).join(', '));
    process.exit(0);
  })
  .catch(err => {
    console.error('✗ DB Connection Failed:', err.message);
    process.exit(1);
  });

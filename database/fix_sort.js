const mysql=require('mysql2/promise'); 
require('dotenv').config({path: '.env'}); 
mysql.createConnection({
  host: process.env.DB_HOST || 'localhost', 
  user: process.env.DB_USER || 'root', 
  password: process.env.DB_PASSWORD || 'Yash@mysql25', 
  database: process.env.DB_NAME || 'rathi_traders'
}).then(async c => {
  await c.query('UPDATE categories SET sort_order = 1 WHERE slug = "bath-soaps"');
  await c.query('UPDATE categories SET sort_order = 2 WHERE slug = "shampoos"');
  console.log("Done"); 
  process.exit(0);
});

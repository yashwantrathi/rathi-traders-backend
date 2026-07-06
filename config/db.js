const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
dotenv.config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'rathi_traders',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4',
  timezone: '+05:30'
});

// Initialize DB: create database if not exists, then run schema
async function initializeDB() {
  const tempConn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true
  });

  try {
    await tempConn.query(`CREATE DATABASE IF NOT EXISTS \`${process.env.DB_NAME || 'rathi_traders'}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
    await tempConn.query(`USE \`${process.env.DB_NAME || 'rathi_traders'}\`;`);
    
    const fs = require('fs');
    const path = require('path');
    const schemaPath = path.join(__dirname, '../database/schema.sql');
    
    if (fs.existsSync(schemaPath)) {
      const schema = fs.readFileSync(schemaPath, 'utf8');
      const statements = schema.split(/;\s*\n/).filter(s => s.trim().length > 0);
      for (const stmt of statements) {
        const trimmed = stmt.trim();
        if (trimmed) {
          try {
            await tempConn.query(trimmed + ';');
          } catch (e) {
            // Ignore duplicate entry errors during seeding
            if (!e.message.includes('Duplicate entry') && !e.message.includes('already exists')) {
              console.warn('SQL Warning:', e.message.substring(0, 100));
            }
          }
        }
      }
      console.log('✅ Database initialized successfully');
    }
  } catch (err) {
    console.error('❌ Database initialization error:', err.message);
  } finally {
    await tempConn.end();
  }
}

module.exports = { pool, initializeDB };

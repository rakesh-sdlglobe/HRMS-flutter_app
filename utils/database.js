// database/db.js
require('dotenv').config();
const sql = require('mssql');

const dbSettings = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_HOST,
  database: process.env.DB_NAME,
  options: {
    encrypt: true,
    trustServerCertificate: true // Change to true for local certificate
  }
};

// Create a SQL Server pool
const pool = new sql.ConnectionPool(dbSettings);

// Connect to SQL Server
pool.connect(err => {
  if (err) {
    console.error('Error connecting to database: ', err);
    return;
  }
  console.log('Connected to SQL Server database');
});

module.exports = pool;

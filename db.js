const sql = require('mssql');
const fs = require('fs');
const path = require('path');
const dbConfig = require('./dbConfig');

// Function to connect to the database
async function connectToDb() {
  try {
    let pool = await sql.connect(dbConfig);
    console.log('Connected to the database');
    return pool;
  } catch (err) {
    console.error('Database connection failed:', err);
    throw err;
  }
}

// Function to initialize the database schema
async function initializeDb() {
  const schemaPath = path.join(__dirname, './schema.sql');
  const schema = fs.readFileSync(schemaPath, 'utf8');

  let pool = await connectToDb();
  try {
    await pool.request().query(schema);
    console.log('Database schema initialized successfully');
  } catch (err) {
    console.error('Error initializing database schema:', err);
    throw err;
  }
}

module.exports = {
  connectToDb,
  initializeDb
};

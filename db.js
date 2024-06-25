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

// Function to read and parse SQL file
function getQueries(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const queries = {};
  const sections = content.split('-- ');

  sections.forEach(section => {
    const [name, ...queryParts] = section.split('\n');
    const query = queryParts.join('\n').trim();
    if (name && query) {
      queries[name.trim()] = query;
    }
  });

  return queries;
}

// Load queries from the SQL file
const queries = getQueries(path.join(__dirname, './queries.sql'));

// Function to execute a query by name
async function executeQuery(queryName, params = []) {
  let pool = await connectToDb();
  try {
    let request = pool.request();

    params.forEach(param => {
      request.input(param.name, param.type, param.value);
    });
    let query = queries[queryName];
    if (!query) {
      throw new Error(`Query not found: ${queryName}`);
    }
    let result = await request.query(query);
    console.log('Query executed successfully:', result);
    return result;
  } catch (err) {
    console.error('Query execution failed:', err);
    throw err;
  }
}

async function deleteExpiredLinks() {
  let pool = await connectToDb();
  try {
    let result = await pool.request().query(queries['deleteExpiredLinks']);
    console.log('Expired links deleted successfully:', result.rowsAffected);
  } catch (err) {
    console.error('Failed to delete expired links:', err);
  }
}


module.exports = {
  connectToDb,
  initializeDb,
  executeQuery,
  deleteExpiredLinks // Export the new function
};
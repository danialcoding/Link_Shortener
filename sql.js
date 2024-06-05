const fs = require('fs');
const sql = require('mssql');

const dbConfig = {
    user: 'your_username',
    password: 'your_password',
    server: 'your_server',
    database: 'UrlShortenerDB',
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
};

async function executeSqlFile(filePath) {
    const sqlQuery = fs.readFileSync(filePath, 'utf-8');
    const queries = sqlQuery.split(/;\s*$/m);

    try {
        const pool = await sql.connect(dbConfig);

        for (const query of queries) {
            if (query.trim()) {
                await pool.request().query(query);
            }
        }

        console.log('SQL file executed successfully.');
    } catch (err) {
        console.error('Error executing SQL file', err);
    } finally {
        sql.close();
    }
}

executeSqlFile('queries.sql');

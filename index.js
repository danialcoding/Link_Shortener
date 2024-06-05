const express = require('express');
const bodyParser = require('body-parser');
const sql = require('mssql');
const shortid = require('shortid');

const app = express();
app.use(bodyParser.json());

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

sql.connect(dbConfig).catch(err => console.log(err));

// Endpoint to create a new short URL
app.post('/api/shorten', async (req, res) => {
    const { originalUrl } = req.body;
    const shortCode = shortid.generate();

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('OriginalUrl', sql.NVarChar, originalUrl)
            .input('ShortCode', sql.NVarChar, shortCode)
            .query('INSERT INTO Urls (OriginalUrl, ShortCode) VALUES (@OriginalUrl, @ShortCode); SELECT SCOPE_IDENTITY() AS Id');

        res.status(201).send({ id: result.recordset[0].Id, shortCode });
    } catch (err) {
        res.status(500).send({ message: 'Error creating short URL', error: err });
    }
});

// Endpoint to redirect to the original URL
app.get('/:shortCode', async (req, res) => {
    const { shortCode } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('ShortCode', sql.NVarChar, shortCode)
            .query('SELECT OriginalUrl FROM Urls WHERE ShortCode = @ShortCode');

        if (result.recordset.length > 0) {
            // Update last accessed date
            await pool.request()
                .input('ShortCode', sql.NVarChar, shortCode)
                .execute('UpdateLastAccessed');

            res.redirect(result.recordset[0].OriginalUrl);
        } else {
            res.status(404).send({ message: 'URL not found' });
        }
    } catch (err) {
        res.status(500).send({ message: 'Error redirecting to original URL', error: err });
    }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});

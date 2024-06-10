const express = require('express');
const bodyParser = require('body-parser');
const db = require('./db');
const sql = require('mssql');
const crypto = require('crypto');

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Initialize the database schema
(async () => {
  try {
    await db.initializeDb();
  } catch (err) {
    console.error('Failed to initialize database:', err);
    process.exit(1);
  }
})();

// Function to generate a short code
function generateShortCode() {
  return crypto.randomBytes(3).toString('hex');
}



// Endpoint to create a short URL
app.post('/shorten', async (req, res) => {
  const { originalUrl } = req.body;
  const shortCode = generateShortCode();

  try {
    let params = [
      { name: 'originalUrl', type: sql.NVarChar, value: originalUrl },
      { name: 'shortCode', type: sql.NVarChar, value: shortCode }
    ];
    await db.executeQuery('insertLink', params);
    res.status(201).send({ shortCode });
  } catch (err) {
    console.error('Error inserting URL into database:', err);
    res.status(500).send('Server error');
  }
});

// Endpoint to redirect to the original URL
app.get('/:shortCode', async (req, res) => {
  const { shortCode } = req.params;

  try {
    let params = [
      { name: 'shortCode', type: sql.NVarChar, value: shortCode }
    ];
    let result = await db.executeQuery('getLinkByShortCode', params);
    if (result.recordset.length > 0) {
      const originalUrl = result.recordset[0].original_url;
      // Log the visit
      await db.executeQuery('insertLinkVisit', params);
      res.redirect(originalUrl);
    } else {
      res.status(404).send('URL not found');
    }
  } catch (err) {
    console.error('Error fetching URL from database:', err);
    res.status(500).send('Server error');
  }
});

// Dashboard endpoints

// Get daily new links
app.get('/dashboard/daily-new-links', async (req, res) => {
  try {
    let result = await db.executeQuery('getDailyNewLinks');
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching daily new links:', err);
    res.status(500).send('Server error');
  }
});

// Get daily link visits
app.get('/dashboard/daily-link-visits', async (req, res) => {
  try {
    let result = await db.executeQuery('getDailyLinkVisits');
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching daily link visits:', err);
    res.status(500).send('Server error');
  }
});

// Get top 3 links by visits
app.get('/dashboard/top-3-links', async (req, res) => {
  try {
    let result = await db.executeQuery('getTop3Links');
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching top 3 links:', err);
    res.status(500).send('Server error');
  }
});

// Get all links with stats
app.get('/dashboard/all-links-with-stats', async (req, res) => {
  try {
    let result = await db.executeQuery('getAllLinksWithStats');
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching all links with stats:', err);
    res.status(500).send('Server error');
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

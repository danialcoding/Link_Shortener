// dbConfig.js
const dbConfig = {
    //server: 'DANIAL\\MSSQLSERVER01',
    server: 'DANIAL',
    database: 'link_shortener',
    user: 'danial',
    password: 'KING.d@1382',

    options: {
        //encrypt: true, // Use this if you're on Windows Azure
        trustServerCertificate: true // For local development
      }
};
  
  module.exports = dbConfig;
  
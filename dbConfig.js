// dbConfig.js
const dbConfig = {
    //server: 'DANIAL\\MSSQLSERVER01',
    //server: 'DANIAL',
    server: 'DANIAL\\SQLEXPRESS',
    database: 'link_shortener',
    user: 'danial',
    password: '',

    options: {
        //encrypt: true, // Use this if you're on Windows Azure
        trustServerCertificate: true // For local development
      }
};
  
  module.exports = dbConfig;
  
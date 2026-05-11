require('dotenv').config();

const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY;

console.log('Google API Key loaded:', GOOGLE_API_KEY ? 'yes' : 'no');

require('dotenv').config();
const http = require('http');
const { createOAuthClient, SCOPES } = require('../gmail/client');

const REDIRECT_PORT = 3000;
const REDIRECT_URI = `http://localhost:${REDIRECT_PORT}`;

async function authorize() {
  const auth = createOAuthClient(REDIRECT_URI);

  const authUrl = auth.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES,
    prompt: 'consent',
  });

  console.log('\nOpen this URL in your browser:\n');
  console.log(authUrl);
  console.log('\nWaiting for authorization...');

  const code = await waitForCode();
  const { tokens } = await auth.getToken(code);

  console.log('\nAdd this to your .env file:\n');
  console.log(`GMAIL_REFRESH_TOKEN=${tokens.refresh_token}`);
}

function waitForCode() {
  return new Promise((resolve, reject) => {
    const server = http.createServer((req, res) => {
      const url = new URL(req.url, REDIRECT_URI);
      const code = url.searchParams.get('code');
      const error = url.searchParams.get('error');

      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end('<h1>Authorization complete. You can close this tab.</h1>');
      server.close();

      if (error) return reject(new Error(`OAuth error: ${error}`));
      resolve(code);
    });

    server.listen(REDIRECT_PORT);
  });
}

authorize().catch(err => {
  console.error('Authorization failed:', err.message);
  process.exit(1);
});

require('dotenv').config();
const { createGmailClient } = require('./src/gmail/client');
const { fetchUnreadEmails } = require('./src/services/fetchUnreadEmails');

async function main() {
  const gmail = createGmailClient();
  const emails = await fetchUnreadEmails(gmail);
  console.log(`Fetched ${emails.length} unread email(s):`);
  console.log(JSON.stringify(emails, null, 2));
}

main().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});

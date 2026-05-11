const GMAIL_QUERY = 'is:unread label:INBOX';
const BATCH_SIZE = 50;

async function listMessages(gmail) {
  const response = await gmail.users.messages.list({
    userId: 'me',
    q: GMAIL_QUERY,
    maxResults: BATCH_SIZE,
  });
  return response.data.messages || [];
}

async function getMessage(gmail, id) {
  const response = await gmail.users.messages.get({
    userId: 'me',
    id,
    format: 'full',
  });
  return response.data;
}

module.exports = { listMessages, getMessage, BATCH_SIZE, GMAIL_QUERY };

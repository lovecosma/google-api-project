const { listMessages, getMessage } = require('../gmail/messages');
const { parseMessage } = require('../gmail/parser');

async function fetchUnreadEmails(gmail) {
  const messageRefs = await listMessages(gmail);

  const emails = await Promise.all(
    messageRefs.map(async ({ id }) => {
      const message = await getMessage(gmail, id);
      return parseMessage(message);
    })
  );

  return emails;
}

module.exports = { fetchUnreadEmails };

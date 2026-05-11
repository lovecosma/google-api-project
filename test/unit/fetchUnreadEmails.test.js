const { fetchUnreadEmails } = require('../../src/services/fetchUnreadEmails');
const { parseMessage, parseFrom, extractBody } = require('../../src/gmail/parser');

const toBase64 = (text) => Buffer.from(text).toString('base64url');

const PLAIN_TEXT = 'Please send 10 units of Widget A.';
const HTML_TEXT = '<p>Please send 10 units of Widget A.</p>';
const BATCH_SIZE = 50;

const makeHeaders = (overrides = {}) => {
  const defaults = {
    From: 'Alice Smith <alice@buyer.com>',
    Subject: 'Order Request',
    Date: 'Mon, 15 Jan 2024 10:30:00 +0000',
  };
  return Object.entries({ ...defaults, ...overrides })
    .map(([name, value]) => ({ name, value }));
};

const makePlainMessage = (id = 'msg_001', headerOverrides = {}) => ({
  id,
  payload: {
    mimeType: 'text/plain',
    headers: makeHeaders(headerOverrides),
    body: { data: toBase64(PLAIN_TEXT) },
  },
});

const makeMultipartMessage = (id = 'msg_002', parts = []) => ({
  id,
  payload: {
    mimeType: 'multipart/alternative',
    headers: makeHeaders(),
    body: {},
    parts,
  },
});

const makeGmailClient = (messageIds = [], messageFactory = makePlainMessage) => ({
  users: {
    messages: {
      list: jest.fn().mockResolvedValue({
        data: { messages: messageIds.map(id => ({ id, threadId: `thread_${id}` })) },
      }),
      get: jest.fn().mockImplementation(({ params }) =>
        Promise.resolve({ data: messageFactory(params?.id ?? 'msg_001') })
      ),
    },
  },
});

// parseFrom
describe('parseFrom', () => {
  it('extracts the sender name from a full From header', () => {
    const { sender } = parseFrom('Alice Smith <alice@buyer.com>');
    expect(sender).toBe('Alice Smith');
  });

  it('extracts the sender email from a full From header', () => {
    const { senderEmail } = parseFrom('Alice Smith <alice@buyer.com>');
    expect(senderEmail).toBe('alice@buyer.com');
  });

  it('uses the raw value as sender when no display name is present', () => {
    const { sender } = parseFrom('alice@buyer.com');
    expect(sender).toBe('alice@buyer.com');
  });

  it('uses the raw value as senderEmail when no display name is present', () => {
    const { senderEmail } = parseFrom('alice@buyer.com');
    expect(senderEmail).toBe('alice@buyer.com');
  });

  it('returns null sender when fromHeader is null', () => {
    const { sender } = parseFrom(null);
    expect(sender).toBeNull();
  });

  it('returns null senderEmail when fromHeader is null', () => {
    const { senderEmail } = parseFrom(null);
    expect(senderEmail).toBeNull();
  });
});

// extractBody
describe('extractBody', () => {
  it('returns decoded body from a text/plain message', () => {
    const payload = { mimeType: 'text/plain', body: { data: toBase64(PLAIN_TEXT) } };
    expect(extractBody(payload)).toBe(PLAIN_TEXT);
  });

  it('returns text/plain part from a multipart message', () => {
    const payload = {
      mimeType: 'multipart/alternative',
      parts: [
        { mimeType: 'text/plain', body: { data: toBase64(PLAIN_TEXT) } },
        { mimeType: 'text/html', body: { data: toBase64(HTML_TEXT) } },
      ],
    };
    expect(extractBody(payload)).toBe(PLAIN_TEXT);
  });

  it('falls back to text/html when no text/plain part exists', () => {
    const payload = {
      mimeType: 'multipart/alternative',
      parts: [
        { mimeType: 'text/html', body: { data: toBase64(HTML_TEXT) } },
      ],
    };
    expect(extractBody(payload)).toBe(HTML_TEXT);
  });

  it('returns null when there is no body data', () => {
    const payload = { mimeType: 'text/plain', body: {} };
    expect(extractBody(payload)).toBeNull();
  });
});

// parseMessage
describe('parseMessage', () => {
  it('sets externalId from the message id', () => {
    const { externalId } = parseMessage(makePlainMessage('msg_abc'));
    expect(externalId).toBe('msg_abc');
  });

  it('extracts sender name from the From header', () => {
    const { sender } = parseMessage(makePlainMessage());
    expect(sender).toBe('Alice Smith');
  });

  it('extracts sender email from the From header', () => {
    const { senderEmail } = parseMessage(makePlainMessage());
    expect(senderEmail).toBe('alice@buyer.com');
  });

  it('extracts the subject', () => {
    const { subject } = parseMessage(makePlainMessage());
    expect(subject).toBe('Order Request');
  });

  it('parses receivedAt as a Date from the Date header', () => {
    const { receivedAt } = parseMessage(makePlainMessage());
    expect(receivedAt).toEqual(new Date('Mon, 15 Jan 2024 10:30:00 +0000'));
  });

  it('returns null receivedAt when the Date header is missing', () => {
    const { receivedAt } = parseMessage(makePlainMessage('msg_001', { Date: undefined }));
    expect(receivedAt).toBeNull();
  });

  it('extracts the body text', () => {
    const { bodyText } = parseMessage(makePlainMessage());
    expect(bodyText).toBe(PLAIN_TEXT);
  });
});

// fetchUnreadEmails
describe('fetchUnreadEmails', () => {
  it('queries for unread inbox messages', async () => {
    const gmail = makeGmailClient([]);
    await fetchUnreadEmails(gmail);
    expect(gmail.users.messages.list).toHaveBeenCalledWith(
      expect.objectContaining({ q: 'is:unread label:INBOX' })
    );
  });

  it(`requests at most ${BATCH_SIZE} messages`, async () => {
    const gmail = makeGmailClient([]);
    await fetchUnreadEmails(gmail);
    expect(gmail.users.messages.list).toHaveBeenCalledWith(
      expect.objectContaining({ maxResults: BATCH_SIZE })
    );
  });

  it('returns an empty array when there are no unread messages', async () => {
    const gmail = makeGmailClient([]);
    const emails = await fetchUnreadEmails(gmail);
    expect(emails).toHaveLength(0);
  });

  it('fetches full details for each message', async () => {
    const gmail = makeGmailClient(['msg_001', 'msg_002']);
    await fetchUnreadEmails(gmail);
    expect(gmail.users.messages.get).toHaveBeenCalledTimes(2);
  });

  it('returns one parsed email per message', async () => {
    const gmail = makeGmailClient(['msg_001', 'msg_002']);
    const emails = await fetchUnreadEmails(gmail);
    expect(emails).toHaveLength(2);
  });
});

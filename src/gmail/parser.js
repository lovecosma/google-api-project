function parseHeader(headers, name) {
  const header = headers.find(h => h.name.toLowerCase() === name.toLowerCase());
  return header ? header.value : null;
}

function parseFrom(fromHeader) {
  if (!fromHeader) return { sender: null, senderEmail: null };

  const match = fromHeader.match(/^(.+?)\s*<(.+?)>$/);
  if (match) {
    return { sender: match[1].trim(), senderEmail: match[2].trim() };
  }

  return { sender: fromHeader.trim(), senderEmail: fromHeader.trim() };
}

function decodeBody(data) {
  if (!data) return null;
  return Buffer.from(data, 'base64url').toString('utf8');
}

function extractBody(payload) {
  if (payload.mimeType === 'text/plain') {
    return decodeBody(payload.body?.data);
  }

  if (payload.parts) {
    const plainPart = payload.parts.find(p => p.mimeType === 'text/plain');
    if (plainPart) return decodeBody(plainPart.body?.data);

    const htmlPart = payload.parts.find(p => p.mimeType === 'text/html');
    if (htmlPart) return decodeBody(htmlPart.body?.data);
  }

  return null;
}

function parseMessage(message) {
  const { id, payload } = message;
  const headers = payload.headers || [];

  const fromHeader = parseHeader(headers, 'From');
  const { sender, senderEmail } = parseFrom(fromHeader);
  const subject = parseHeader(headers, 'Subject');
  const dateHeader = parseHeader(headers, 'Date');
  const receivedAt = dateHeader ? new Date(dateHeader) : null;
  const bodyText = extractBody(payload);

  return { externalId: id, sender, senderEmail, subject, receivedAt, bodyText };
}

module.exports = { parseFrom, extractBody, parseMessage };

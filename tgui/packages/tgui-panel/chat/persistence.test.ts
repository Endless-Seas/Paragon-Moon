import { describe, expect, it } from 'bun:test';

import { MAX_PERSISTED_MESSAGES } from './constants';
import { sanitizePersistedMessages } from './use-chat-persistence';

describe('panel chat persistence', () => {
  it('keeps the chat sanitization policy and bounded saved history', () => {
    const sanitizedMarkup = [
      sanitizePersistedMessages([
        {
          type: 'ooc',
          createdAt: 1,
          html: '<a href="https://example.com">link</a>',
        },
      ])[0]?.html ?? '',
      sanitizePersistedMessages([
        {
          type: 'ooc',
          createdAt: 1,
          html: '<video src="x"></video>',
        },
      ])[0]?.html ?? '',
      sanitizePersistedMessages([
        {
          type: 'ooc',
          createdAt: 1,
          html: '<img src="x" onerror="alert(1)">',
        },
      ])[0]?.html ?? '',
      sanitizePersistedMessages([
        {
          type: 'ooc',
          createdAt: 1,
          html: '<span>safe</span>',
        },
      ])[0]?.html ?? '',
    ];
    const messages = sanitizePersistedMessages(
      Array.from({ length: MAX_PERSISTED_MESSAGES + 3 }, (_, index) => ({
        type: 'ooc',
        createdAt: index + 1,
        text: `message-${index}`,
      })),
    );
    expect(messages).toHaveLength(MAX_PERSISTED_MESSAGES);
    expect(messages[0]?.text).toBe('message-3');
    expect(messages.at(-1)?.text).toBe('message-1002');
    expect(sanitizedMarkup[0]).not.toContain('<a');
    expect(sanitizedMarkup[1]).not.toContain('<video');
    expect(sanitizedMarkup[2]).not.toContain('onerror');
    expect(sanitizedMarkup[3]).toContain('safe');
  });
});

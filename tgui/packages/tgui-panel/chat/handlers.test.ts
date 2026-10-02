import { afterEach, describe, expect, it, mock, spyOn } from 'bun:test';

import {
  chatMessage,
  chatReliabilityLimits,
  resetChatReliability,
} from './handlers';
import { chatRenderer } from './renderer';

describe('panel chat transport reliability', () => {
  const sendMessage = mock();

  afterEach(() => {
    resetChatReliability();
    sendMessage.mockClear();
    // @ts-expect-error BYOND is supplied by the native client.
    delete globalThis.Byond;
  });

  it('requests numeric gaps once and accepts the requested message', () => {
    // @ts-expect-error BYOND is supplied by the native client.
    globalThis.Byond = { sendMessage };
    const processBatch = spyOn(chatRenderer, 'processBatch').mockImplementation(
      () => undefined,
    );

    chatMessage(JSON.stringify({ sequence: 10, content: { text: 'ten' } }));
    chatMessage(JSON.stringify({ sequence: 12, content: { text: 'twelve' } }));
    chatMessage(
      JSON.stringify({ sequence: 12, content: { text: 'duplicate' } }),
    );
    chatMessage(JSON.stringify({ sequence: 11, content: { text: 'eleven' } }));

    expect(sendMessage.mock.calls).toEqual([['chat/resend', 11]]);
    expect(processBatch).toHaveBeenCalledTimes(3);
    processBatch.mockRestore();
  });

  it('renders late unrequested messages that DM delivered out of order', () => {
    const timer = spyOn(globalThis, 'setTimeout').mockImplementation(
      (() => 1) as unknown as typeof setTimeout,
    );
    // @ts-expect-error BYOND is supplied by the native client.
    globalThis.Byond = { sendMessage };
    const processBatch = spyOn(chatRenderer, 'processBatch').mockImplementation(
      () => undefined,
    );

    chatMessage(JSON.stringify({ sequence: 0, content: {} }));
    chatMessage(JSON.stringify({ sequence: 10, content: {} }));
    // 1..5 were never requested (only the last four gaps are), but must show.
    for (let sequence = 1; sequence < 10; sequence++) {
      chatMessage(JSON.stringify({ sequence, content: {} }));
    }
    chatMessage(JSON.stringify({ sequence: 3, content: {} }));

    expect(processBatch).toHaveBeenCalledTimes(11);
    timer.mockRestore();
    processBatch.mockRestore();
  });

  it('caps resend requests and sequence history', () => {
    const callbacks: (() => void)[] = [];
    const timer = spyOn(globalThis, 'setTimeout').mockImplementation(((
      callback: () => void,
    ) => {
      callbacks.push(callback as () => void);
      return callbacks.length as any;
    }) as typeof setTimeout);
    const clearTimer = spyOn(globalThis, 'clearTimeout').mockImplementation(
      () => undefined,
    );
    // @ts-expect-error BYOND is supplied by the native client.
    globalThis.Byond = { sendMessage };
    const processBatch = spyOn(chatRenderer, 'processBatch').mockImplementation(
      () => undefined,
    );

    chatMessage(JSON.stringify({ sequence: 0, content: {} }));
    chatMessage(
      JSON.stringify({
        sequence: chatReliabilityLimits.maxSequenceHistory + 100,
        content: {},
      }),
    );

    expect(sendMessage.mock.calls.length).toBe(1);
    while (callbacks.length) callbacks.shift()!();
    expect(sendMessage.mock.calls.length).toBe(
      chatReliabilityLimits.maxResendRequests,
    );
    expect(chatReliabilityLimits.maxSequenceHistory).toBe(1000);
    expect(sendMessage.mock.calls[0]).toEqual(['chat/resend', 1096]);
    timer.mockRestore();
    clearTimer.mockRestore();
    processBatch.mockRestore();
  });
});

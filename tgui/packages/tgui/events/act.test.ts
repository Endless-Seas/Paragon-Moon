import { describe, expect, it } from 'bun:test';

import { ActionTransport, splitPayload } from './act';

function fixture() {
  const sent: { type: string; payload: any }[] = [];
  const errors: string[] = [];
  type Callback = () => void;
  const pending = new Map<number, Callback>();
  let nextId = 0;
  const transport = new ActionTransport(
    (type, payload) => sent.push({ type, payload }),
    (message) => errors.push(message),
    ((callback: () => void) => {
      const id = ++nextId;
      pending.set(id, callback);
      return id;
    }) as any,
    ((id: number) => pending.delete(id)) as any,
  );
  const tick = () => {
    const [id, callback] = pending.entries().next().value!;
    pending.delete(id);
    callback();
  };
  return { transport, sent, errors, pending, tick };
}

describe('chunk transport', () => {
  it('splits encoded Unicode without dropping, splitting or duplicating characters', () => {
    const text = JSON.stringify({ text: 'Zażółć 🦊 !\'()* "\\'.repeat(700) });
    const chunks = splitPayload(text);
    expect(chunks.join('')).toBe(text);
    expect(
      chunks.every(
        (chunk) =>
          encodeURIComponent(chunk).replace(/[!'()*]/g, '___').length <= 1024,
      ),
    ).toBe(true);
    expect(chunks.every((chunk) => chunk.length > 0)).toBe(true);
  });

  it('ignores stale/duplicate acknowledgements and completes without sending an undefined chunk', () => {
    const { transport, sent, pending, errors, tick } = fixture();
    transport.enqueue(
      'act/submit',
      JSON.stringify({ text: 'x'.repeat(2300) }),
      1,
    );
    const { id, chunkCount } = sent[0].payload;
    transport.response(null as any);
    transport.acknowledge(null as any);
    transport.reject(null as any);
    transport.response({ id: 'stale', allow: true });
    expect(sent).toHaveLength(1);
    transport.response({ id, allow: true });
    for (let index = 0; index < chunkCount; index++) {
      tick();
      const chunk = sent.at(-1)!;
      expect(chunk.type).toBe('payloadChunk');
      expect(chunk.payload.index).toBe(index);
      expect(typeof chunk.payload.chunk).toBe('string');
      transport.acknowledge({ id, index: index + 1 });
      transport.acknowledge({ id, index });
      transport.acknowledge({ id, index });
    }
    expect(pending.size).toBe(0);
    expect(sent).toHaveLength(chunkCount + 1);
    expect(errors).toEqual([]);
  });

  it('bounds concurrency, handles rejection, and forgets transfers on reuse', () => {
    const { transport, sent, pending, errors } = fixture();
    const text = JSON.stringify({ text: 'x'.repeat(2200) });
    transport.enqueue('act/submit', text, 1);
    transport.enqueue('act/submit', text, 1);
    transport.enqueue('act/submit', text, 1);
    expect(errors).toHaveLength(1);
    expect(sent).toHaveLength(1);
    const id = sent[0].payload.id;
    transport.cancel();
    transport.response({ id, allow: true });
    transport.acknowledge({ id, index: 0 });
    expect(pending.size).toBe(0);
    transport.enqueue('act/submit', text, 2);
    const next = sent.at(-1)!.payload;
    expect(next.session).toBe(2);
    expect(next.id).not.toBe(id);
    transport.response({ id: next.id, allow: false });
    expect(pending.size).toBe(0);
    expect(errors).toHaveLength(2);
  });

  it('retries lost requests a bounded number of times then clears its timer', () => {
    const { transport, sent, pending, errors, tick } = fixture();
    transport.enqueue('act/submit', '{}', 1);
    tick();
    tick();
    tick();
    expect(
      sent.filter(({ type }) => type === 'oversizedPayloadRequest'),
    ).toHaveLength(3);
    expect(errors).toHaveLength(1);
    expect(pending.size).toBe(0);
  });
});

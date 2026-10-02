/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */
import { atom } from 'jotai';

import { createLogger } from '../logging';
import { backendStateAtom, store } from './store';

const logger = createLogger('transport');
const CHUNK_SIZE = 1024;
const MAX_CHUNKS = 32;
const ACK_TIMEOUT = 5000;
export const actionErrorAtom = atom<string | null>(null);

/** Count encoded code points, never cut a Unicode surrogate pair. */
export function splitPayload(text: string, limit = CHUNK_SIZE): string[] {
  const chunks: string[] = [];
  let chunk = '';
  let size = 0;
  for (const character of text) {
    // BYOND's url_encode also escapes punctuation left alone by encodeURIComponent.
    const encodedSize = encodeURIComponent(character).replace(
      /[!'()*]/g,
      '___',
    ).length;
    if (size + encodedSize > limit) {
      chunks.push(chunk);
      chunk = '';
      size = 0;
    }
    chunk += character;
    size += encodedSize;
  }
  if (chunk) chunks.push(chunk);
  return chunks;
}

type Transfer = {
  id: string;
  type: string;
  session: number;
  chunks: string[];
  index: number;
  requested: boolean;
  retries: number;
  interval: number;
};

type Scheduler = (
  callback: () => void,
  delay: number,
) => ReturnType<typeof setTimeout>;

/** One acknowledged chunk at a time, with bounded storage and retries. */
export class ActionTransport {
  private queue: Transfer[] = [];
  private timer: ReturnType<typeof setTimeout> | undefined;
  private serial = 0;

  constructor(
    private send: (type: string, payload: object) => void,
    private fail: (message: string) => void,
    // Wrapped so the timer globals are never invoked with the transport as `this`,
    // which browsers reject with "Illegal invocation".
    private schedule: Scheduler = (callback, delay) =>
      setTimeout(callback, delay),
    private unschedule: (
      timer: ReturnType<typeof setTimeout> | undefined,
    ) => void = (timer) => clearTimeout(timer),
  ) {}

  enqueue(type: string, text: string, session: number) {
    const chunks = splitPayload(text);
    if (chunks.length > MAX_CHUNKS || this.queue.length >= 2) {
      this.fail(
        'This submission is too large, or another submission is still pending. Shorten it or wait and try again.',
      );
      return;
    }
    this.queue.push({
      id: `${session}-${Date.now()}-${++this.serial}`,
      type,
      session,
      chunks,
      index: 0,
      requested: false,
      retries: 0,
      interval: 750,
    });
    if (this.queue.length === 1) this.transmit();
  }

  private transmit() {
    const transfer = this.queue[0];
    if (!transfer) return;
    this.unschedule(this.timer);
    // Install the timeout before sending, so synchronous test transports work.
    this.timer = this.schedule(() => {
      if (transfer.retries++ < 2) this.transmit();
      else {
        this.finish(
          'The submission timed out. Check your connection and try again.',
        );
      }
    }, ACK_TIMEOUT);
    if (!transfer.requested) {
      this.send('oversizedPayloadRequest', {
        id: transfer.id,
        type: transfer.type,
        session: transfer.session,
        chunkCount: transfer.chunks.length,
      });
    } else {
      this.send('payloadChunk', {
        id: transfer.id,
        session: transfer.session,
        index: transfer.index,
        chunk: transfer.chunks[transfer.index],
      });
    }
  }

  response(payload: { id: string; allow: boolean; interval?: number }) {
    if (
      !payload ||
      typeof payload.id !== 'string' ||
      typeof payload.allow !== 'boolean'
    ) {
      return;
    }
    const transfer = this.queue[0];
    if (!transfer || transfer.id !== payload.id || transfer.requested) return;
    if (!payload.allow) {
      this.finish(
        'The server could not accept this submission. Reopen the window and try again.',
      );
      return;
    }
    this.unschedule(this.timer);
    transfer.requested = true;
    transfer.retries = 0;
    transfer.interval = Number.isFinite(payload.interval)
      ? Math.max(750, Math.min(10000, payload.interval!))
      : 750;
    this.timer = this.schedule(() => this.transmit(), transfer.interval);
  }

  acknowledge(payload: { id: string; index: number }) {
    if (
      !payload ||
      typeof payload.id !== 'string' ||
      !Number.isInteger(payload.index)
    ) {
      return;
    }
    const transfer = this.queue[0];
    if (
      !transfer ||
      !transfer.requested ||
      transfer.id !== payload.id ||
      transfer.index !== payload.index
    ) {
      return;
    }
    this.unschedule(this.timer);
    transfer.index++;
    transfer.retries = 0;
    if (transfer.index === transfer.chunks.length) {
      this.finish();
    } else {
      this.timer = this.schedule(() => this.transmit(), transfer.interval);
    }
  }

  reject(payload: { id: string }) {
    if (!payload || typeof payload.id !== 'string') return;
    if (this.queue[0]?.id === payload.id) {
      this.finish(
        'The submission expired or the window is no longer interactive. Reopen it and try again.',
      );
    }
  }

  cancel() {
    this.unschedule(this.timer);
    const transfer = this.queue[0];
    this.queue = [];
    if (transfer) {
      this.send('cancelPayload', {
        id: transfer.id,
        session: transfer.session,
      });
    }
  }

  private finish(error?: string) {
    this.unschedule(this.timer);
    const transfer = this.queue.shift();
    if (error) {
      if (transfer) {
        this.send('cancelPayload', {
          id: transfer.id,
          session: transfer.session,
        });
      }
      this.fail(error);
    }
    if (this.queue.length) {
      this.timer = this.schedule(() => this.transmit(), 750);
    }
  }
}

const transport = new ActionTransport(
  (type, payload) => Byond.sendMessage(type, payload),
  (message) => {
    logger.warn(message);
    store.set(actionErrorAtom, message);
  },
);

export const acknowledgePayloadChunk = (payload) =>
  transport.acknowledge(payload);
export const oversizePayloadResponse = (payload) => transport.response(payload);
export const rejectPayload = (payload) => transport.reject(payload);
export function cancelTransfers() {
  transport.cancel();
  store.set(actionErrorAtom, null);
}

export function sendAct(
  action: string,
  payload: object = {},
  session: number | undefined,
) {
  const { config, suspended, suspending } = store.get(backendStateAtom);
  if (
    suspended ||
    suspending ||
    !config.window ||
    config.window.session !== session
  ) {
    return;
  }
  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
    logger.error('Payload for act() must be an object', payload);
    return;
  }
  store.set(actionErrorAtom, null);
  const type = `act/${action}`;
  const text = JSON.stringify(payload);
  const header = {
    type,
    payload: text,
    tgui: 1,
    window_id: Byond.windowId,
    windowSession: config.window.session,
  };
  const urlSize = Object.entries(header).reduce(
    (size, [key, value]) =>
      size +
      encodeURIComponent(key).length +
      encodeURIComponent(value).length +
      2,
    0,
  );
  if (urlSize >= 2048) {
    transport.enqueue(type, text, config.window.session);
  } else {
    Byond.sendMessage({ type, payload, windowSession: config.window.session });
  }
}
